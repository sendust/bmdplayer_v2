#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consi"stent starting directory.
SetBatchLines, -1
#Include socket.ahk
#SingleInstance force
#NoTrayIcon

address := ["127.0.0.1", 5253]
monitor := new SocketUDP()
monitor.Bind(address)
monitor.onRecv := Func("OnUDPRecv")

startx := A_ScreenWidth - 500
starty := 10
title := "Caspar v2.1 OSC Monitor by sendust 20190816"

osc_field := Object()
array_16bit := Object()
array_32bit := Object()
haudio := Object()


Loop, 1
	array_8bit[A_Index] := A_Index

loop, 16
	array_16bit[A_Index] := A_Index - 1			; create 16 index with value 0~15

Loop, 32
	array_32bit[A_Index] := A_Index			; create 32bit index with value  1~32



array_level := Object()

temp := ""
Loop, 100
{
	temp .= "|"
	array_level[A_Index] := temp
}

; /channel/1/mixer/audio/1/dBFS

Loop, 8
{
	osc_field.message[A_Index] := "/channel/1/mixer/audio/" . A_Index . "/dBFS"			; for osc 2.1
	osc_field.len[A_Index] := StrLen(osc_field.message[A_Index])
}

osc_field.message[9] := "/channel/1/stage/layer/1/file/frame"
osc_field.len[9] := StrLen(osc_field.message[9])


Gui, add, edit, w400 h20 hwndhtext1 ReadOnly Center, info
Gui, add, edit, w400 h30 hwndhtext2 ReadOnly Center, info2
Gui, add, Text, xm yp+40, CH1
Gui, add, Text, xp+40 yp w300 hwndhaudio1, --
Gui, add, Text, xm yp+15, CH2
Gui, add, Text, xp+40 yp w300 hwndhaudio2, --
Gui, add, Text, xm yp+15, CH3
Gui, add, Text, xp+40 yp w300 hwndhaudio3, --
Gui, add, Text, xm yp+15, CH4
Gui, add, Text, xp+40 yp w300 hwndhaudio4, --
Gui, add, Text, xm yp+15, CH5
Gui, add, Text, xp+40 yp w300 hwndhaudio5, --
Gui, add, Text, xm yp+15, CH6
Gui, add, Text, xp+40 yp w300 hwndhaudio6, --
Gui, add, Text, xm yp+15, CH7
Gui, add, Text, xp+40 yp w300 hwndhaudio7, --
Gui, add, Text, xm yp+15, CH8
Gui, add, Text, xp+40 yp w300 hwndhaudio8, --


Gui, show, x%startx% y%starty%, %title%
Gui, -MinimizeBox

Gui, font, s15 bold
GuiControl, font, %htext2%

haudio := [haudio1, haudio2, haudio3, haudio4, haudio5, haudio6, haudio7, haudio8]

return



secondtotc_drop(sec)
{
	sec := format("{:10.3f}", sec)
	sec_out := Floor(sec)
	frame_out := sec - sec_out
	hour_out := sec_out // 3600
	minute_out := "00" . Mod(sec_out // 60, 60)
	second_out := "00" . Mod(sec_out, 60)
	frame_out := "00" . Floor(frame_out * 30)			; NTSC 29.97 frame

	minute_out := SubStr(minute_out, -1)
	second_out := SubStr(second_out, -1)
	frame_out := SubStr(frame_out, -1)
	
	return % hour_out . ":" . minute_out . ":" . second_out . ";" . frame_out
}


onUDPRecv(this)
{
	global  htext1, htext2, osc_field, array_16bit, array_32bit, array_level
	global haudio
	buffer := ""
	offset_found := 0
	message := ""
	
	length := this.Recv(buffer)			; UDP length
	;FileAppend, % StrGet(&buffer, length, "cp437") . "`r`n", *
	Loop, % Round((length - osc_field.len[9]) / 4)			; OSC message is consist of 4 byte block
	{
		message :=  StrGet(&buffer  + A_Index * 4, osc_field.len[1], "cp437") 	; Human readable message

			;FileAppend,  %message%`r`n, *													; For Capture osc message
			if RegExMatch(message, "/channel/1/mixer/audio/\d/dBFS")
			{
				;FileAppend,  %message%`r`n, *													; For Capture osc message
				offset_found := A_Index * 4 
				a := Format("{:02X}", NumGet(&buffer, offset_found + osc_field.len[1] + 7, "UChar"))
				b := Format("{:02X}", NumGet(&buffer, offset_found + osc_field.len[1] + 8, "UChar"))
				c := Format("{:02X}", NumGet(&buffer, offset_found + osc_field.len[1] + 9, "UChar"))
				d := Format("{:02X}", NumGet(&buffer, offset_found + osc_field.len[1] + 10, "UChar"))
				nb_audio := SubStr(message, 24, 1)
				level1 := "0x" . a . b . c . d			; Convert 4 byte HEX number
				;FileAppend,  %message%  %nb_audio%   %level1%`r`n, *													; For Capture osc message
				level1 := HexToFloat(level1) / 10 + 10				; Convert Hex to float number
				level1 := round(1.5**level1) + 1							; Make favorite Level meter response
				
	/*
				;----------------------------- debugging purpose --------------------------------------
				FileAppend, % message . "`r`n--------------------- length " . length . "`r`n", *
				for key, val in array_16bit
				{
					test := NumGet(&buffer, offset_found + osc_field.len[1] + val, "UChar")
					test_hex := format("{:#X}", test)
					FileAppend, % val . " ---> " . test . " --- " . chr(test) . " ---- " .   test_hex . "`r`n", *
				}
				FileAppend, % "-----------------------`r`n" . IEEE754(a,b,c,d)  . "`r`n", *
				;----------------------------- debugging purpose --------------------------------------
	*/
				GuiControl,, % haudio[nb_audio], % array_level[level1]
			}

		message :=  StrGet(&buffer  + A_Index  * 4, osc_field.len[9], "cp437") 			; Human readable message
		
		if (InStr(message, osc_field.message[9]))													; check if there is interest data field
		{
			offset_found := A_Index * 4
			a1 := NumGet(&buffer, offset_found + osc_field.len[9] + 9, "UChar")
			b1 := NumGet(&buffer, offset_found + osc_field.len[9] + 10, "UChar")
			c1 := NumGet(&buffer, offset_found + osc_field.len[9] + 11, "UChar")
			d1 := NumGet(&buffer, offset_found + osc_field.len[9] + 12, "UChar")
			
			a2 := NumGet(&buffer, offset_found + osc_field.len[9] + 17, "UChar")
			b2 := NumGet(&buffer, offset_found + osc_field.len[9] + 18, "UChar")
			c2 := NumGet(&buffer, offset_found + osc_field.len[9] + 19, "UChar")
			d2 := NumGet(&buffer, offset_found + osc_field.len[9] + 20, "UChar")
			
			frame1 := a1 * 2**32+ b1 * 2 ** 16 + c1 * 2 ** 8 + d1
			frame2 := a2 * 2**32+ b2 * 2 ** 16 + c2 * 2 ** 8 + d2
			
			GuiControl,, %htext2%, %frame1% / %frame2%
			message_found := osc_field.message[9]
			GuiControl,, %htext1%, %offset_found% / %length% - %message_found%
		}
	}
}

show_debuginfo(param)			; Display content of 16 bit array
{
	info := ""
	Loop, 16
		info .= format("bit-{:02d}", A_Index) . " - " . format("{:03d}", param[A_Index]) .  " - " .  format("{:02x}", param[A_Index]) .  "  - " . Chr(param[A_Index]) .  "`r`n"
	ToolTip %info%
}


HexToFloat(x) { ; No 32-bit floats are supported by sprintf!
   Return (1-2*(x>>31)) * (2**((x>>23 & 255)-150)) * (0x800000 | x & 0x7FFFFF)
}

HexToDouble(x) {
   VarSetCapacity(S,99)
   DllCall("msvcrt\sprintf", Str,S, Str,"%f","Int64",x)
   Return S
}

FloatToHex(f) {
   VarSetCapacity(S,10)
   DllCall("msvcrt\sprintf", Str,S, Str,"0x%08X","Float",f)
   Return S
}

DoubleToHex(d) {
   VarSetCapacity(S,18)
   DllCall("msvcrt\sprintf", Str,S, Str,"0x%016I64X","Double",d)
   Return S
}


GuiClose:
ExitApp


;--------------------------------------------------------------------------------------------------------------------------------------


IEEE754(a,b,c,d)
{
	sign := (a >> 7)
	sign := (-1) ** sign
	exponent := (a <<1) + (b>>7) - 127
	if exponent > 62				; Prevent mis calculation from too large value
		exponent := 62

	fr1 := (((b>> 6) & 0x01) * 2**(-1))
	fr2 := (((b>> 5) & 0x01) * 2**(-2))
	fr3 := (((b>> 4) & 0x01) * 2**(-3))
	fr4 := (((b>> 3) & 0x01) * 2**(-4))
	fr5 := (((b>> 2) & 0x01) * 2**(-5))
	fr6 := (((b>> 1) & 0x01) * 2**(-6))
	fr7 := (((b>> 0) & 0x01) * 2**(-7))
	
	fr8 := (((c >> 7) & 0x01)* 2**(-8))
	fr9 := (((c >> 6) & 0x01)* 2**(-9))
	fr10 := (((c >> 5) & 0x01)* 2**(-10))
	fr11 := (((c >> 4) & 0x01)* 2**(-11))
	fr12 := (((c >> 3) & 0x01)* 2**(-12))
	fr13 := (((c >> 2) & 0x01)* 2**(-13))
	fr14 := (((c >> 1) & 0x01)* 2**(-14))
	fr15 := (((c >> 0) & 0x01)* 2**(-15))
	
	fr16 := (((d >> 7) & 0x01)* 2**(-16))
	fr17 := (((d >> 6) & 0x01)* 2**(-17))
	fr18 := (((d >> 5) & 0x01)* 2**(-18))
	fr19 := (((d >> 4) & 0x01)* 2**(-19))
	fr20 := (((d >> 3) & 0x01)* 2**(-20))
	fr21 := (((d >> 2) & 0x01)* 2**(-21))
	fr22 := (((d >> 1) & 0x01)* 2**(-22))
	fr23 := (((d >> 0) & 0x01)* 2**(-23))
	
	fraction := 1.0 + fr1 + fr2 + fr3 + fr4 + fr5 + fr6 + fr7 + fr8 + fr9 + fr10 + fr11 + fr12 + fr13 + fr14 + fr15 + fr16 + fr17 + fr18 + fr19 + fr20 + fr21 + fr22 + fr23
	result := sign * fraction * (2**exponent)
	
	OutputDebug,%sign%  %exponent%  %fraction% %result%
	;FileAppend, %sign%  %exponent%  %fraction%  --  %result%`r`n, *
	return result
}

IEEE754_backup(a,b,c,d)
{
	sign := (a >> 7)
	exponent := (a <<1) + (b>>7) - 127

	fr1 := (((b>> 6) & 0x01) * 2**(-1))
	fr2 := (((b>> 5) & 0x01) * 2**(-2))
	fr3 := (((b>> 4) & 0x01) * 2**(-3))
	fr4 := (((b>> 3) & 0x01) * 2**(-4))
	fr5 := (((b>> 2) & 0x01) * 2**(-5))
	fr6 := (((b>> 1) & 0x01) * 2**(-6))
	fr7 := (((b>> 0) & 0x01) * 2**(-7))
	
	fr8 := (((c >> 7) & 0x01)* 2**(-8))
	fr9 := (((c >> 6) & 0x01)* 2**(-9))
	fr10 := (((c >> 5) & 0x01)* 2**(-10))
	fr11 := (((c >> 4) & 0x01)* 2**(-11))
	fr12 := (((c >> 3) & 0x01)* 2**(-12))
	fr13 := (((c >> 2) & 0x01)* 2**(-13))
	fr14 := (((c >> 1) & 0x01)* 2**(-14))
	fr15 := (((c >> 0) & 0x01)* 2**(-15))
	
	fr16 := (((d >> 7) & 0x01)* 2**(-16))
	fr17 := (((d >> 6) & 0x01)* 2**(-17))
	fr18 := (((d >> 5) & 0x01)* 2**(-18))
	fr19 := (((d >> 4) & 0x01)* 2**(-19))
	fr20 := (((d >> 3) & 0x01)* 2**(-20))
	fr21 := (((d >> 2) & 0x01)* 2**(-21))
	fr22 := (((d >> 1) & 0x01)* 2**(-22))
	fr23 := (((d >> 0) & 0x01)* 2**(-23))
	
	result := ((-1)**sign) * (1.0 + fr1 + fr2 + fr3 + fr4 + fr5 + fr6 + fr7 + fr8 + fr9 + fr10 + fr11 + fr12 + fr13 + fr14 + fr15 + fr16 + fr17 + fr18 + fr19 + fr20 + fr21 + fr22 + fr23) * (2**exponent)
	
	OutputDebug, %sign%  %exponent%  %result%
	return result
}



onUDPRecv3(this)
{
	global osc_field1, osc_field1_len, htext1, htext2, bit_32, array_level
	buffer := ""
	offset_found := 0
	message := ""
	length := this.Recv(buffer)			; UDP length
	Loop, % length - 32
	{
		message :=  StrGet(&buffer + A_Index, osc_field1_len, "cp437") 			; Human readable message
		;FileAppend, %message%`r`n, osc_v22.log														; For Capture osc message
		if (InStr(message, osc_field1))																		; check if there is interest data field
		{
			offset_found := A_Index
			message :=  StrGet(&buffer + A_Index, osc_field1_len, "cp437") 			; Human readable message (extend)
			temp0 :=NumGet(&buffer, offset_found + osc_field1_len + 0, "UChar")
			temp1 := NumGet(&buffer, offset_found + osc_field1_len + 1, "UChar")
			temp2 :=NumGet(&buffer, offset_found + osc_field1_len + 2, "UChar")
			temp3 :=NumGet(&buffer, offset_found + osc_field1_len + 3, "UChar")
			temp4 := NumGet(&buffer, offset_found + osc_field1_len + 4, "UChar")
			temp5 :=  NumGet(&buffer, offset_found + osc_field1_len + 5, "UChar")
			temp6 :=  NumGet(&buffer, offset_found + osc_field1_len + 6, "UChar")
			temp7 :=  NumGet(&buffer, offset_found + osc_field1_len + 7, "UChar")
			temp8 := NumGet(&buffer, offset_found + osc_field1_len + 8, "UChar")
			temp9 :=  NumGet(&buffer, offset_found + osc_field1_len + 9, "UChar")
			temp10 :=  NumGet(&buffer, offset_found + osc_field1_len + 10, "UChar")
			temp11 :=  NumGet(&buffer, offset_found + osc_field1_len + 11, "UChar")
			temp12 := NumGet(&buffer, offset_found + osc_field1_len + 12, "UChar")
			temp13 := NumGet(&buffer, offset_found + osc_field1_len + 13, "UChar")
			temp14 :=  NumGet(&buffer, offset_found + osc_field1_len + 14, "UChar")
			temp15 :=NumGet(&buffer, offset_found + osc_field1_len + 15, "UChar")
			GuiControl,, %htext1%,  %offset_found%/%length% - %message%
			time_pos := format("{:10.3f}", IEEE754(temp7, temp8, temp9, temp10))
			time_duration := format("{:10.3f}", IEEE754(temp11, temp12, temp13, temp14))
			GuiControl,, %htext2%,  %time_pos% / %time_duration%
		}
	}
}


onUDPRecv5(this)
{
	global osc_field1, osc_field1_len, htext1, htext2
	buffer := ""
	offset_found := 0
	message := ""
	length := this.Recv(buffer)			; UDP length
	Loop, % length - 32
	{
		message :=  StrGet(&buffer + A_Index, osc_field1_len, "cp437") 			; Human readable message
		;FileAppend, %message%`r`n, osc_v22.log														; For Capture osc message
		if (InStr(message, osc_field1))																		; check if there is interest data field
		{
			offset_found := A_Index
			message :=  StrGet(&buffer + A_Index, osc_field1_len, "cp437") 			; Human readable message (extend)
			temp0 :=NumGet(&buffer, offset_found + osc_field1_len + 0, "UChar")
			temp1 := NumGet(&buffer, offset_found + osc_field1_len + 1, "UChar")
			temp2 :=NumGet(&buffer, offset_found + osc_field1_len + 2, "UChar")
			temp3 :=NumGet(&buffer, offset_found + osc_field1_len + 3, "UChar")
			temp4 := NumGet(&buffer, offset_found + osc_field1_len + 4, "UChar")
			temp5 :=  NumGet(&buffer, offset_found + osc_field1_len + 5, "UChar")
			temp6 :=  NumGet(&buffer, offset_found + osc_field1_len + 6, "UChar")
			temp7 :=  NumGet(&buffer, offset_found + osc_field1_len + 7, "UChar")
			temp8 := NumGet(&buffer, offset_found + osc_field1_len + 8, "UChar")
			temp9 :=  NumGet(&buffer, offset_found + osc_field1_len + 9, "UChar")
			temp10 :=  NumGet(&buffer, offset_found + osc_field1_len + 10, "UChar")
			temp11 :=  NumGet(&buffer, offset_found + osc_field1_len + 11, "UChar")
			temp12 := NumGet(&buffer, offset_found + osc_field1_len + 12, "UChar")
			temp13 := NumGet(&buffer, offset_found + osc_field1_len + 13, "UChar")
			temp14 :=  NumGet(&buffer, offset_found + osc_field1_len + 14, "UChar")
			temp15 :=NumGet(&buffer, offset_found + osc_field1_len + 15, "UChar")
			GuiControl,, %htext1%,  %offset_found%/%length% - %message%
			time_pos := format("{:10.3f}", IEEE754(temp7, temp8, temp9, temp10))
			time_duration := format("{:10.3f}", IEEE754(temp11, temp12, temp13, temp14))
			GuiControl,, %htext2%,  %time_pos% / %time_duration%
		}
	}
}

