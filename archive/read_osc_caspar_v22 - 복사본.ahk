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
monitor.SetReuseAddr()
monitor.SetBroadcast()
monitor.Bind(address)
monitor.onRecv := Func("OnUDPRecv")

startx := A_ScreenWidth - 500
starty := 10
title := "Caspar v2.2 OSC Monitor by sendust 20200324"

osc_field := object()
array_16bit := Object()
array_32bit := Object()


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


osc_field.message[1] := "/channel/1/stage/layer/1/foreground/file/time"
;osc_field.message[1] :=  "/channel/1/stage/layer/1/foreground/loop"		; bit-6 True or False
;osc_field.message[1] :=  "/channel/1/stage/layer/1/foreground/paused"			; bit-4 True or False
;osc_field.message[1] := "/channel/1/stage/layer/1/foreground/file/clip"
osc_field.len[1] := StrLen(osc_field.message[1])

osc_field.message[2] := "/channel/1/mixer/audio/volume"
osc_field.len[2] := StrLen(osc_field.message[2])


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

return



secondtotc_drop(sec)			; changed 2020/3/23
{
	frames := Round(sec * 29.97)
	return frametotc(frames)
}


frametotc(frames)					; changed 2020/3/23  (NTSC Drop frame Applied)
{
	framerate := 29.97
	fps_int := Round(framerate)
	sizeBigCycle := 17982			; every 10 minute, there is no tc drop
	sizeWeeCycle := 1798			; every  1 minute, there is tc drop
	numBigCycles := frames // sizeBigCycle
	tailFrames := frames - (numBigCycles * sizeBigCycle)
	
	if (tailFrames < (sizeWeeCycle + 2))
		numWeeCycles := 1
	else
		numWeeCycles := (tailFrames - 2) // sizeWeeCycle + 1
	
	numSkips1 := numWeeCycles - 1
	numSkips2 := numBigCycles * 9
	numSkips3 := numSkips1 + numSkips2
	framesSkipped := numSkips3 * 2
	adjustedFrames := frames + framesSkipped
	
	frame := Mod(adjustedFrames, fps_int)
	seconds := Mod(adjustedFrames // fps_int, 60)
	minutes := Mod(adjustedFrames // (fps_int * 60), 60)
	hours := adjustedFrames // (fps_int * 3600)
	
	return  format("{1:.01d}:{2:.02d}:{3:.02d};{4:.02d}", hours, minutes, seconds, frame)
}


onUDPRecv(this)
{
	global  htext1, htext2, osc_field, array_16bit, array_32bit, array_level
	global haudio1, haudio2, haudio3, haudio4, haudio5, haudio6, haudio7, haudio8
	buffer := ""
	temp := Object()
	offset_found := 0
	message := ""
	int32max := 2*32 / 2

	length := this.Recv(buffer)			; UDP length
	Loop, % (length - osc_field.len[1]) / 4
	{
		message :=  StrGet(&buffer + A_Index * 4, osc_field.len[2], "cp437") 			; Human readable message
		;FileAppend, %message%`r`n, *														; For Capture osc message

		if (InStr(message, osc_field.message[2]))													; check if there is Audio level meter data
		{
			offset_found := A_Index* 4

			temp1 := NumGet(&buffer, offset_found + osc_field.len[2] + 14, "UChar") * 0x1000000 + NumGet(&buffer, offset_found + osc_field.len[2] + 15, "UChar") * 0x10000 + NumGet(&buffer, offset_found + osc_field.len[2] + 16, "UChar") * 0x100 + NumGet(&buffer, offset_found + osc_field.len[2] + 17, "UChar")
			temp2 := NumGet(&buffer, offset_found + osc_field.len[2] + 18, "UChar") * 0x1000000 + NumGet(&buffer, offset_found + osc_field.len[2] + 19, "UChar") * 0x10000 + NumGet(&buffer, offset_found + osc_field.len[2] + 20, "UChar") * 0x100 + NumGet(&buffer, offset_found + osc_field.len[2] + 21, "UChar")
			temp3 := NumGet(&buffer, offset_found + osc_field.len[2] + 22, "UChar") * 0x1000000 + NumGet(&buffer, offset_found + osc_field.len[2] + 23, "UChar") * 0x10000 + NumGet(&buffer, offset_found + osc_field.len[2] + 24, "UChar") * 0x100 + NumGet(&buffer, offset_found + osc_field.len[2] + 25, "UChar")
			temp4 := NumGet(&buffer, offset_found + osc_field.len[2] + 26, "UChar") * 0x1000000 + NumGet(&buffer, offset_found + osc_field.len[2] + 27, "UChar") * 0x10000 + NumGet(&buffer, offset_found + osc_field.len[2] + 28, "UChar") * 0x100 + NumGet(&buffer, offset_found + osc_field.len[2] + 29, "UChar")
			temp5 := NumGet(&buffer, offset_found + osc_field.len[2] + 30, "UChar") * 0x1000000 + NumGet(&buffer, offset_found + osc_field.len[2] + 31, "UChar") * 0x10000 + NumGet(&buffer, offset_found + osc_field.len[2] + 32, "UChar") * 0x100 + NumGet(&buffer, offset_found + osc_field.len[2] + 33, "UChar")
			temp6 := NumGet(&buffer, offset_found + osc_field.len[2] + 34, "UChar") * 0x1000000 + NumGet(&buffer, offset_found + osc_field.len[2] + 35, "UChar") * 0x10000 + NumGet(&buffer, offset_found + osc_field.len[2] + 36, "UChar") * 0x100 + NumGet(&buffer, offset_found + osc_field.len[2] + 37, "UChar")
			temp7 := NumGet(&buffer, offset_found + osc_field.len[2] + 38, "UChar") * 0x1000000 + NumGet(&buffer, offset_found + osc_field.len[2] + 39, "UChar") * 0x10000 + NumGet(&buffer, offset_found + osc_field.len[2] + 40, "UChar") * 0x100 + NumGet(&buffer, offset_found + osc_field.len[2] + 41, "UChar")
			temp8 := NumGet(&buffer, offset_found + osc_field.len[2] + 42, "UChar") * 0x1000000 + NumGet(&buffer, offset_found + osc_field.len[2] + 43, "UChar") * 0x10000 + NumGet(&buffer, offset_found + osc_field.len[2] + 44, "UChar") * 0x100 + NumGet(&buffer, offset_found + osc_field.len[2] + 45, "UChar")

			temp1 := Log(temp1 / int32max) *2
			temp2 := Log(temp2 / int32max) *2
			temp3 := Log(temp3 / int32max) *2
			temp4 := Log(temp4 / int32max) *2
			temp5 := Log(temp5 / int32max) *2
			temp6 := Log(temp6 / int32max) *2
			temp7 := Log(temp7 / int32max) *2
			temp8 := Log(temp8 / int32max) *2
			
			temp1 := temp1 = "-inf" ? "-inf " : array_level[Round(1.4**temp1)]
			temp2 := temp2 = "-inf" ? "-inf " : array_level[Round(1.4**temp2)]
			temp3 := temp3 = "-inf" ? "-inf " : array_level[Round(1.4**temp3)]
			temp4 := temp4 = "-inf" ? "-inf " : array_level[Round(1.4**temp4)]
			temp5 := temp5 = "-inf" ? "-inf " : array_level[Round(1.4**temp5)]
			temp6 := temp6 = "-inf" ? "-inf " : array_level[Round(1.4**temp6)]
			temp7 := temp7 = "-inf" ? "-inf " : array_level[Round(1.4**temp7)]
			temp8 := temp8 = "-inf" ? "-inf " : array_level[Round(1.4**temp8)]
			
			GuiControl,, %haudio1%, %temp1%
			GuiControl,, %haudio2%, %temp2%
			GuiControl,, %haudio3%, %temp3%
			GuiControl,, %haudio4%, %temp4%
			GuiControl,, %haudio5%, %temp5%
			GuiControl,, %haudio6%, %temp6%
			GuiControl,, %haudio7%, %temp7%
			GuiControl,, %haudio8%, %temp8%
		}
		
		message :=  StrGet(&buffer + A_Index * 4, osc_field.len[1], "cp437") 			; Human readable message
		if (InStr(message, osc_field.message[1]))													; check if there is interest data field
		{
			offset_found := A_Index * 4
			for key, val in array_16bit
				temp[key] := NumGet(&buffer, offset_found + osc_field.len[1] + val, "UChar")
			GuiControl,, %htext1%,  %offset_found%/%length% - %message%
			;time_pos := format("{:10.3f}", IEEE754(temp[8], temp[9], temp[10], temp[11]))
			;time_duration := format("{:10.3f}", IEEE754(temp[12], temp[13], temp[14], temp[15]))
			;time_pos := secondtotc_drop(IEEE754(temp[8], temp[9], temp[10], temp[11]))
			time_pos := secondtotc_drop(HexToFloat(temp[8] * 0x1000000 + temp[9] * 0x10000 + temp[10] * 0x100 + temp[11]))				; Get 4 byte Hex number
			time_duration := secondtotc_drop(HexToFloat(temp[12] * 0x1000000 +  temp[13] * 0x10000 + temp[14] * 0x100 + temp[15]))			; Get 4 byte Hex number
			;show_debuginfo(temp)
			GuiControl,, %htext2%,  %time_pos% / %time_duration%
		}
	}
}

show_debuginfo(param)
{
	info := ""
	Loop, 16
		info .= format("bit-{:02d}", A_Index) . " - " . format("{:03d}", param[A_Index]) .  " - " .  format("{:02x}", param[A_Index]) .  "  - " . Chr(param[A_Index]) .  "`r`n"
	ToolTip %info%
}


HexToFloat(x) { ; No 32-bit floats are supported by sprintf!
   Return (1-2*(x>>31)) * (2**((x>>23 & 255)-150)) * (0x800000 | x & 0x7FFFFF)
}


GuiClose:
ExitApp


;=============================================== Deprecate functions, subroutine ======================================

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




onUDPRecv2(this)
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


IEEE754(a,b,c,d)
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

	OutputDebug,%sign%  %exponent%  %result%
	return result
}

