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
osc_field1_len := StrLen(osc_field1)

Gui, font, s15
Gui, add, text, w600 h100 hwndhtext1, info
Gui, show



return


onUDPRecv(this)
{
	global osc_field1, osc_field1_len, htext1
	buffer := ""
	offset_found := 0
	message := ""
	length := this.Recv(buffer)			; UDP length
	Loop, % length - 30
	{
		message :=  StrGet(&buffer + A_Index, osc_field1_len, "cp437") 			; Human readable message
		;FileAppend, %message%`r`n, osc_v22.log
		if (InStr(message, osc_field1))		; check if there is interest data field
		{
			offset_found := A_Index
			;temp := StrGet(&buffer + offset_found  + osc_field1_len, 20, "cp437") 
			;FileAppend, %message% - %offset_found% - %temp% `r`n, osc3.log
			temp1 := NumGet(&buffer, offset_found + osc_field1_len + 1, "UChar")
			temp2 := NumGet(&buffer, offset_found + osc_field1_len + 2, "UChar")
			temp3 := NumGet(&buffer, offset_found + osc_field1_len + 3, "UChar")
			temp4 := NumGet(&buffer, offset_found + osc_field1_len + 4, "UChar")
			temp5 := NumGet(&buffer, offset_found + osc_field1_len + 5, "UChar")
			temp6 := NumGet(&buffer, offset_found + osc_field1_len + 6, "UChar")
			temp7 := NumGet(&buffer, offset_found + osc_field1_len + 7, "UChar")
			temp8 := NumGet(&buffer, offset_found + osc_field1_len + 8, "UChar")
			temp9 := NumGet(&buffer, offset_found + osc_field1_len + 9, "UChar")
			temp10 := NumGet(&buffer, offset_found + osc_field1_len + 10, "UChar")
			temp11 := NumGet(&buffer, offset_found + osc_field1_len + 11, "UChar")
			temp12 := NumGet(&buffer, offset_found + osc_field1_len + 12, "UChar")
			temp13 := NumGet(&buffer, offset_found + osc_field1_len + 13, "UChar")
			temp14 := NumGet(&buffer, offset_found + osc_field1_len + 14, "UChar")
			temp15 := NumGet(&buffer, offset_found + osc_field1_len + 15, "UChar")
			temp16 := NumGet(&buffer, offset_found + osc_field1_len + 16, "UChar")
			;ToolTip %offset_found% - %osc_field1_len% - %frame%
			GuiControl,, %htext1%,  %offset_found% / %temp1% - %temp2% - %temp3% - %temp4% - %temp5% - %temp6% - %temp7% - %temp8% - %temp9% - %temp10% - %temp11% - %temp12% - %temp13% - %temp14% - %temp15% - %temp16%
		}
	}
	;FileAppend, %message%, rawosc.log
}


onUDPRecv2(this)
{
	global count
	buffer := ""
	message := ""
	data := ""
	count += 1			; count UDP packet
	count_data := 0		; count OSC data portion
	length := this.Recv(buffer)			; UDP length
	;osc := StrGet(&buffer, length, "UTF-8")
	Loop, %length%
	{
		byte_data := NumGet(&buffer, A_index - 1, "UChar" )
		message .=  Chr(byte_data)			; Human readable message
		if InStr(message, "channel/1/stage/layer/1/foreground/file/time,")		; check if there is interest data field
		{
			count_data +=1								; data follows after interest
			data .= byte_data . " "			; make data field
			ToolTip OSC Received  %count_data%  %byte_data%
			if count_data > 20						; data field limit
			{
				FileAppend, %data%`r`n, osc.log
				message := ""
				data := ""
				count_data := 0
			}
		}
	}
	;FileAppend, %message%, rawosc.log
}


^+1::
buffer := "#bundle"		; 35 98 117 110 100 108 101 0
buffer := "file/time"			; 102 105 108 101 47 116 105 109 101 0
binary := ""
;Loop, 10
	;binary .= NumGet(&buffer, (A_Index - 1) * 2, "UChar") . " "
;	MsgBox %binary%

test := StrGet(&buffer+6, 6, "UTF-8")
MsgBox %test%


return

;	osc format, Frames elapsed on file playback / Total frames
;  /file/time,ffA*=qA+8


GuiClose:
esc::
ExitApp