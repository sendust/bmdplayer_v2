#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, -1
#Include socket.ahk

	count := 0
	addressamcp := ["127.0.0.1", "5250"]
	casparamcp := new SocketTCP()
	
	casparamcp.Connect(addressamcp)
	

	address := ["127.0.0.1", 6250]
	monitor := new SocketUDP()
try
{
	monitor.Bind(address)
	monitor.onRecv := Func("OnUDPRecv")
}	catch, e
	ToolTip There is error %e%


return

/*
onUDPRecv(this)
{
	global count
	buffer := ""
	message := ""
	data := object()
	count += 1			; count UDP packet
	count_data := 0		; count OSC data portion
	length := this.Recv(buffer)			; UDP length
	;osc := StrGet(&buffer, length, "UTF-8")
	Loop, %length%
	{
		byte_data := NumGet(&buffer, A_index - 1, "UChar" )
		message .=  Chr(byte_data)			; Human readable message
		if InStr(message, "file/frame,")		; check if there is interest data field
		{
			count_data +=1								; data follows after interest
			data[count_data] := byte_data 			; make data field
			;ToolTip OSC Received  %count_data%  %byte_data%
			if count_data > 20						; data field limit
			{
				frame := data[12] + data[11] * 2**8 + data[10] * 2**16 + data[9] * 2**32
				totalframe := data[20]+ data[19] * 2**8 + data[18] * 2**16 + data[17] * 2**32
				ToolTip %frame%/%totalframe%
				message := ""
				data := ""
				count_data := 0
			}
		}
	}
	;FileAppend, %message%, rawosc.log
}
*/
/*
onUDPRecv(this)
{
	global count
	buffer := ""
	message := ""
	data := object()
	count += 1			; count UDP packet
	count_data := 0		; count OSC data portion
	length := this.Recv(buffer)			; UDP length
	;osc := StrGet(&buffer, length, "UTF-8")
	Loop, %length%
	{
		byte_data := NumGet(&buffer, A_index - 1, "UChar" )
		message .=  Chr(byte_data)			; Human readable message
		if InStr(message, "channel/1/stage/layer/1/file/time")		; check if there is interest data field
		{
			count_data +=1								; data follows after interest
			data[count_data] := byte_data 			; make data field
			data_show := ""
			if (count_data > 20)
			{
				data_show := binarytoserial(data)
				timems := data[12] + data[11] * 2**8 + data[10] * 2**16
				;data_show := data[16] . A_Tab . data[15] . A_Tab . data[14] . A_Tab . data[13] . A_Tab . data[12] . A_Tab . data[11] . A_Tab . data[10] . A_Tab . data[9] . A_Tab . data[8] . A_Tab . data[7] . data[6] . A_Tab . data[5] . A_Tab . data[4] . A_Tab . data[3] . A_Tab . data[2] . A_Tab . data[1]
				;FileAppend, %data_show%`r`n, output2.txt
				ToolTip OSC Received %timems%
				break
			}
				;FileAppend, %message% - %byte_data%`r`n, osc_text.txtqq
		}
	}
	;FileAppend, %message%, rawosc.log
}

*/
/*

onUDPRecv(this)
{
	global count
	buffer := ""
	message := ""
	data := object()
	count += 1			; count UDP packet
	count_data := 0		; count OSC data portion
	length := this.Recv(buffer)			; UDP length
	;osc := StrGet(&buffer, length, "UTF-8")
	Loop, %length%
	{
		byte_data := NumGet(&buffer, A_index - 1, "UChar" )
		message .=  Chr(byte_data)			; Human readable message
		if InStr(message, "/channel/1")		; check if there is interest data field
		{
			count_data +=1								; data follows after interest
			data[count_data] := byte_data 			; make data field
			data_show := ""
			if (count_data > 40)
			{
				data_show := binarytoserial(data)
				FileAppend, %A_Min%:%A_Sec%.%A_MSec% - %message%`r`n, output3.txt
				ToolTip OSC Received %A_Min%:%A_Sec%.%A_MSec% 
				break
			}
				;FileAppend, %message% - %byte_data%`r`n, osc_text.txtqq
		}
	}
	;FileAppend, %message%, rawosc.log
}

*/


onUDPRecv(this)
{
	buffer := ""
	length := this.Recv(buffer)			; UDP length
	osc := StrGet(&buffer+20, length-20, "UTF-8")
	foundpos := InStr(osc, "/channel/1/stage/layer/1/file/frame")
	if foundpos
	{
		offset_found := 45
		frame := NumGet(&buffer, offset_found + 22, "UChar") +   NumGet(&buffer, offset_found + 21, "UChar")* 2**8 +  NumGet(&buffer, offset_found + 20, "UChar") * 2**16 +  NumGet(&buffer, offset_found + 19, "UChar") * 2**32
		totalframe := NumGet(&buffer, offset_found + 30, "UChar") +   NumGet(&buffer, offset_found + 29, "UChar")* 2**8 +  NumGet(&buffer, offset_found + 28, "UChar") * 2**16 +  NumGet(&buffer, offset_found + 27, "UChar") * 2**32
		ToolTip %frame%/%totalframe%
	}
}




binarytoserial(in)
{
	out := ""
	Loop, % in.MaxIndex()
		out .= in[A_Index] . A_Tab
	return out
}


/*
data array 1~21
44 104 104 0 0 0 0 0 0 0 0 251 0 0 0 0 0 0 1 12 0 
44 104 104 0 0 0 0 0 0 0 0 252 0 0 0 0 0 0 1 12 0 
44 104 104 0 0 0 0 0 0 0 0 253 0 0 0 0 0 0 1 12 0 
44 104 104 0 0 0 0 0 0 0 0 254 0 0 0 0 0 0 1 12 0 
44 104 104 0 0 0 0 0 0 0 0 255 0 0 0 0 0 0 1 12 0 
44 104 104 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 12 0 
44 104 104 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 1 12 0 
44 104 104 0 0 0 0 0 0 0 1 2 0 0 0 0 0 0 1 12 0 
44 104 104 0 0 0 0 0 0 0 1 3 0 0 0 0 0 0 1 12 0 
44 104 104 0 0 0 0 0 0 0 1 4 0 0 0 0 0 0 1 12 0 
44 104 104 0 0 0 0 0 0 0 1 5 0 0 0 0 0 0 1 12 0 

*/



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

esc::
ExitApp