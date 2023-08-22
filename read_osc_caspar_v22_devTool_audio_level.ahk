#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, -1
#Include socket.ahk

	count := 0
	address := ["127.0.0.1", 5253]
	monitor := new SocketUDP()
	monitor.Bind(address)
	monitor.onRecv := Func("OnUDPRecv")

osc_field1 := "channel/1/stage/layer/1/foreground/file/time"
osc_field1 := "/channel/1/mixer/audio/volume"
;osc_field1 := "channel/1/stage/layer/1/foreground/file/frame"
osc_field1_len := StrLen(osc_field1)

bit_32 := Object()

Loop, 32
	bit_32[A_Index] := A_Index

array_level := Object()
temp := ""
Loop, 100
{
	temp .= "|"
	array_level[A_Index] := temp
}


Gui, font, s15
Gui, add, text, w600 h20 hwndhtext1, info
Gui, add, text, w600 h20 hwndhtext2, info2
Gui, add, text, xm yp+30 w600 h100 hwndhdata1, data1
Gui, add, text, xm yp+30 w600 h100 hwndhdata2, data2
Gui, add, text, xm yp+30 w600 h100 hwndhdata3, data3
Gui, add, text, xm yp+30 w600 h100 hwndhdata4, data4
Gui, add, text, xm yp+30 w600 h100 hwndhdata5, data5
Gui, add, text, xm yp+30 w600 h100 hwndhdata6, data6
Gui, add, text, xm yp+30 w600 h100 hwndhdata7, data7
Gui, add, text, xm yp+30 w600 h100 hwndhdata8, data8
Gui, add, text, xm yp+30 w600 h100 hwndhdata9, data9
Gui, add, text, xm yp+30 w600 h100 hwndhdata10, data10
Gui, add, text, xm yp+30 w600 h100 hwndhdata11, data11
Gui, add, text, xm yp+30 w600 h100 hwndhdata12, data12
Gui, add, text, xm yp+30 w600 h100 hwndhdata13, data13
Gui, add, text, xm yp+30 w600 h100 hwndhdata14, data14
Gui, add, text, xm yp+30 w600 h100 hwndhdata15, data15
Gui, add, text, xm yp+30 w600 h100 hwndhdata16, data16

Gui, show

return


onUDPRecv(this)
{
	global osc_field1, osc_field1_len, htext1, htext2, bit_32, array_level
	global  hdata1, hdata2, hdata3, hdata4, hdata5, hdata6, hdata7, hdata8, hdata9, hdata10, hdata11, hdata12, hdata13, hdata14, hdata15, hdata16
	buffer := ""
	offset_found := 0
	message := ""
	length := this.Recv(buffer)			; UDP length
	int32max := 2*32 / 2

	Loop, % length - 32
	{
		message :=  StrGet(&buffer + A_Index, osc_field1_len, "cp437") 			; Human readable message
		;FileAppend, %message%`r`n, osc_v22.log														; For Capture osc message
		if (InStr(message, osc_field1))																		; check if there is interest data field
		{
			offset_found := A_Index
			message :=  StrGet(&buffer + A_Index, osc_field1_len + 12, "cp437") 			; Human readable message (extend)
			
			for key, value in bit_32
			{
				temp := Format("{:03d}  ", key)
				;FileAppend, %temp%, *
			}
			;FileAppend, `r`n, *
			for key, value in bit_32
			{
				temp :=NumGet(&buffer, offset_found + osc_field1_len + value, "UChar")
				temp := Format("{:03d}  ", temp)
				;FileAppend, %temp%, *
			}
			;FileAppend, `r`n, *
			
			temp0 :=NumGet(&buffer, offset_found + osc_field1_len + 14, "UChar") * 2**32 + NumGet(&buffer, offset_found + osc_field1_len + 15, "UChar") * 2**16 + NumGet(&buffer, offset_found + osc_field1_len + 16, "UChar") * 2**8 + NumGet(&buffer, offset_found + osc_field1_len + 17, "UChar")
			
			temp1 := NumGet(&buffer, offset_found + osc_field1_len + 18, "UChar") * 2**32 + NumGet(&buffer, offset_found + osc_field1_len + 19, "UChar") * 2**16 + NumGet(&buffer, offset_found + osc_field1_len + 20, "UChar") * 2**8 + NumGet(&buffer, offset_found + osc_field1_len + 21, "UChar")
			
			temp2 := NumGet(&buffer, offset_found + osc_field1_len + 22, "UChar") * 2**32 + NumGet(&buffer, offset_found + osc_field1_len + 23, "UChar") * 2**16 + NumGet(&buffer, offset_found + osc_field1_len + 24, "UChar") * 2**8 + NumGet(&buffer, offset_found + osc_field1_len + 25, "UChar")
			
			temp3 :=NumGet(&buffer, offset_found + osc_field1_len + 26, "UChar") * 2**32 + NumGet(&buffer, offset_found + osc_field1_len + 27, "UChar") * 2**16 + NumGet(&buffer, offset_found + osc_field1_len + 28, "UChar") * 2**8 + NumGet(&buffer, offset_found + osc_field1_len + 29, "UChar")
			
			temp4 :=NumGet(&buffer, offset_found + osc_field1_len + 30, "UChar") * 2**32 + NumGet(&buffer, offset_found + osc_field1_len + 31, "UChar") * 2**16 + NumGet(&buffer, offset_found + osc_field1_len + 32, "UChar") * 2**8 + NumGet(&buffer, offset_found + osc_field1_len + 33, "UChar")
			
			temp5 :=  NumGet(&buffer, offset_found + osc_field1_len + 34, "UChar") * 2**32 + NumGet(&buffer, offset_found + osc_field1_len + 35, "UChar") * 2**16 + NumGet(&buffer, offset_found + osc_field1_len + 36, "UChar") * 2**8 + NumGet(&buffer, offset_found + osc_field1_len + 37, "UChar")
			
			temp6 :=  NumGet(&buffer, offset_found + osc_field1_len + 38, "UChar") * 2**32 + NumGet(&buffer, offset_found + osc_field1_len + 39, "UChar") * 2**16 + NumGet(&buffer, offset_found + osc_field1_len + 40, "UChar") * 2**8 + NumGet(&buffer, offset_found + osc_field1_len + 41, "UChar")
			
			temp7 :=  NumGet(&buffer, offset_found + osc_field1_len + 42, "UChar") * 2**32 + NumGet(&buffer, offset_found + osc_field1_len + 43, "UChar") * 2**16 + NumGet(&buffer, offset_found + osc_field1_len + 44, "UChar") * 2**8 + NumGet(&buffer, offset_found + osc_field1_len + 45, "UChar")
			
		

			temp0 := Round(Log(temp0 / int32max) *2)
			temp1 := Round(Log(temp1 / int32max) *2)
			temp2 := Round(Log(temp2 / int32max) *2)
			temp3 := Round(Log(temp3 / int32max) *2)
			temp4 := Round(Log(temp4 / int32max) *2)
			temp5 := Round(Log(temp5 / int32max) *2)
			temp6 := Round(Log(temp6 / int32max) *2)
			temp7 := Round(Log(temp7 / int32max) *2)
			
			FileAppend, %temp0%`r`n, * 
			
			temp0 := temp0 = "-inf" ? "-inf " : array_level[temp0]
			temp1 := temp1 = "-inf" ? "-inf " : array_level[temp1]
			temp2 := temp2 = "-inf" ? "-inf " : array_level[temp2]
			temp3 := temp3 = "-inf" ? "-inf " : array_level[temp3]
			temp4 := temp4 = "-inf" ? "-inf " : array_level[temp4]
			temp5 := temp5 = "-inf" ? "-inf " : array_level[temp5]
			temp6 := temp6 = "-inf" ? "-inf " : array_level[temp6]
			temp7 := temp7 = "-inf" ? "-inf " : array_level[temp7]



			temp8 := 
			temp9 :=  
			temp10 :=  
			temp11 :=  
			temp12 := 
			temp13 :=
			temp14 :=  
			temp15 :=
			GuiControl,, %htext1%,  %offset_found% - %message%


			GuiControl,, %hdata1%, 0 - %temp0%
			GuiControl,, %hdata2%, 1 - %temp1%
			GuiControl,, %hdata3%, 2 - %temp2%
			GuiControl,, %hdata4%, 3 - %temp3%
			GuiControl,, %hdata5%, 4 - %temp4%
			GuiControl,, %hdata6%, 5 - %temp5%
			GuiControl,, %hdata7%, 6 - %temp6%
			GuiControl,, %hdata8%,  7 - %temp7%
			GuiControl,, %hdata9%, 8 - %temp8%
			GuiControl,, %hdata10%,  9 - %temp9%
			GuiControl,, %hdata11%,  10 - %temp10%
			GuiControl,, %hdata12%, 11 - %temp11%
			GuiControl,, %hdata13%, 12 - %temp12%
			GuiControl,, %hdata14%, 13 - %temp13%
			GuiControl,, %hdata15%, 14 - %temp14%
			GuiControl,, %hdata16%, 15 - %temp15%
			
			time_pos := IEEE754(temp7, temp8, temp9, temp10)
			time_duration := IEEE754(temp11, temp12, temp13, temp14)
			
			GuiControl,, %htext2%,  %time_pos% / %time_duration%
			
			;ToolTip % time_pos . "    " . time_duration
			;frame := NumGet(&buffer, offset_found + osc_field1_len + 10, "UChar") +  NumGet(&buffer, offset_found + osc_field1_len + 9, "UChar") * 2 ** 8+  NumGet(&buffer, offset_found + osc_field1_len + 8, "UChar") * 2 ** 16 +  NumGet(&buffer, offset_found + osc_field1_len + 7, "UChar")  * 2 ** 32
			;GuiControl,, %htext1%, % frame / 1000
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


IEEE754_2(a,b,c,d)
{
	sign := (a >> 7)
	exponent := (a <<1) + (b>>7) - 127
	fr1 := ((b & 0x40) >> 6) * 2**(-1)
	fr2 := ((b & 0x20) >> 5) * 2**(-2)
	fr3 := ((b & 0x10) >> 4) * 2**(-3)
	fr4 := ((b & 0x08) >> 3) * 2**(-4)
	fr5 := ((b & 0x04) >> 2) * 2**(-5)
	fr6 := ((b & 0x02) >> 1) * 2**(-6)
	fr7 := ((b & 0x01) >> 0) * 2**(-7)
	fr8 := ((c & 0x80) >> 7) * 2**(-8)
	fr9 := ((c & 0x40) >> 6) * 2**(-9)
	fr10 := ((c & 0x20) >> 5) * 2**(-10)
	fr11 := ((c & 0x10) >> 4) * 2**(-11)
	fr12 := ((c & 0x08) >> 3) * 2**(-12)
	fr13 := ((c & 0x04) >> 2) * 2**(-13)
	fr14 := ((c & 0x02) >> 1) * 2**(-14)
	fr15 := ((c & 0x01) >> 0) * 2**(-15)
	fr16 := ((d & 0x80) >> 7) * 2**(-16)
	fr17 := ((d & 0x40) >> 6) * 2**(-17)
	fr18 := ((d & 0x20) >> 5) * 2**(-18)
	fr19 := ((d & 0x10) >> 4) * 2**(-19)
	fr20 := ((d & 0x08) >> 3) * 2**(-20)
	fr21 := ((d & 0x04) >> 2) * 2**(-21)
	fr22 := ((d & 0x02) >> 1) * 2**(-22)
	fr23 := ((d & 0x01) >> 0) * 2**(-23)

	
	result := ((-1)**sign) * (1.0 + fr1 + fr2 + fr3 + fr4 + fr5 + fr6 + fr7 + fr8 + fr9 + fr10 + fr11 + fr12 + fr13 + fr14 + fr15 + fr16 + fr17 + fr18 + fr19 + fr20 + fr21 + fr22 + fr23) * (2**exponent)
	
	OutputDebug,%sign%  %exponent%  %result%
	return result
	
}


GuiClose:
esc::
ExitApp