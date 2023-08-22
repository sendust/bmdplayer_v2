/*
AHK for arduino control with LCD keypad shield
Use Serial port for communication
Usable Output port : 2, 3, 11, 12, 13  (15, 16, 17, 18, 19  --> analog input pin as digital out)
Digital 13 : On Board LED
A0 ; keypad input ADC 0
A1 ; pin 15
A2 ; pin 16
A3 ; pin 17
A4 ; pin 18  (SDA)
A5 ; pin 19  (SCL)

Arduino port usage
0, 1 : serial port communication with PC  (0=RXD, 1=TXD)
4,5,6,7,8,9 ; LCD Keypad control
10 ; LCD Keypad backlight control

serial port write method : (4 byte command)

result := sp.RS232_Write("A, B, C, D")
A = COMMAND, 0xAB ; digitalWrite
B = port number (2, 3, 11, 12, 13, 15, 16, 17, 18, 19)
C = 1 or 0 (Digital High, Low)
D = Don't care

Sony 422 protocol added 2020/4/14
Script maintained by sendust
Last edit  ; 2020/6/11
2020/6/11 Button order configured with TS-4 APC Remote Box



*/



#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#WinActivateForce
#NoTrayIcon
SendMode Event
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, -1
#Include socket.ahk
#include serialport_class_20191005.ahk
#SingleInstance ignore
Menu, Tray, Icon, imageres.dll, 142			; change Tray Icon

title =  Player Remote by sendust 20200415

Gui, Margin, 10, 10
Gui, add, Text, w350 h40 hwndhtext Center, Ξ SENDUST Remote Ξ
Gui, add, Checkbox, xm yp+50 w150 h20 gchk_serialremote vchk_serial hwndhchk_serial, External Remote BOX
Gui, add, Checkbox, xm yp+20 w150 h20 gchk_sonyremote vchk_sony hwndhchk_sony, SONY Remote
Gui, Font, s20
Gui, add, button, xm yp+30 w150 h50 gbutton1, LOAD
Gui, add, button, xp+200 yp w150 h50 gbutton2, NEXT
Gui, add, Progress, xm yp+52 w150 h5 cGreen hwndhbutton1, 100
Gui, add, Progress, xp+200 yp w150 h5 cGreen hwndhbutton2, 100
Gui, add, button, xm  yp+20 w150 h50 gbutton3, PLAY
Gui, add, button, xp+200 yp w150 h50 gbutton4, PAUSE
Gui, add, Progress, xm  yp+52 w150 h5 cGreen hwndhbutton3, 100
Gui, add, Progress, xp+200 yp w150 h5 cGreen hwndhbutton4, 100
Gui, Font, s8
Gui, add, Edit, xm w350 h50 hwndheditbox ReadOnly, Application Started -------------
Gui, -MinimizeBox
Gui, show,, %title%


Gui, Font, s20 bold
GuiControl, font, %htext%

ledcontrol := [hbutton1, hbutton2, hbutton3, hbutton4]
remoteudp := new SocketUDP()	
remoteudp.Connect(get_remote_address())
ledalloff(ledcontrol)

chk_serial := 0
chk_sony := 0
count_data_recv := 0
count_sony_recv := 0
count_loop := 0
rdata := ""
rdata_sony := ""
byte_received := 0
;cmd_recv := Object("EEFF", "SELECT", "22DD", "LEFT", "24DB", "RIGHT", "11EE", "UP", "21DE", "DOWN")			; Arduino lcd key shield button order
;keypad_to_goto := object("RIGHT", "button1", "LEFT", "button2", "UP", "button3", "DOWN", "button4", "SELECT", "button4")
cmd_recv := Object("22DD", "PAUSE", "24DB", "REW", "11EE", "NEXT", "21DE", "PLAY")			; SBS TS-4 APC REMOTE BOX button order
keypad_to_goto := object("REW", "button1", "NEXT", "button2", "PLAY", "button3", "PAUSE", "button4")
cmd_list := get_cmdlist(cmd_recv)

sonycmd := Object()
sonycmd["001111-"] := Func("sony_return_deviceid")
sonycmd["200020-"] := Func("sony_stop")
sonycmd["200121-"] := Func("sony_play")
sonycmd["100111-"] := Func("sony_ack")
sonycmd["610C016E-"] := Func("sony_currenttimesense")		; LTC Request
sonycmd["61200485-"] := Func("sony_statussense")		; Status Request (from data 0 to 4 byte)

while(1)		; Read serial port data
{
	Sleep, 1			; AHK minimun valid sleep value is 10~15 (value 1 introduce 15~16ms delay)
	
	if chk_serial
	{
		count_loop += 1
		if ((count_loop & 0x0F) = 0x0F)				; check if LSB 4 bit is 1000
			sp.RS232_Write(send_blink_serialdata(12))			; blink remote controller LED (User can check if connection is valid)


		data := sp.RS232_Read_Hex(20, byte_received)		; read 20 byte, byte_received value is HEX Value (0x00 = no data)
		if byte_received
		{	
			rdata .= data
			FileAppend, `r`n%data%  -  %byte_received% ----- %A_TickCount%, *
			if ((StrLen(rdata) >= 4) and (InStr(cmd_list, data)))	; read 2 byte and there is valid command data
				{	
					count_data_recv += 1
					consoleout(rdata . " ------ " . cmd_recv[rdata] . " ------- "  .  count_data_recv)
					SetTimer, % keypad_to_goto[cmd_recv[rdata]], -1
					rdata := ""				; clear buffer after  protocol process
				}
		}
		else
			rdata := ""					; clear buffer if there is no data
	}
	
	if chk_sony
	{
		data := sp_sony.RS232_Read_Hex(40, byte_received)		; read 40 byte, byte_received value is HEX Value (0x00 = no data), sony 422 maximum length is 18 byte
		if byte_received
		{
			rdata_sony .= data									; join fragmented recv data
			if (StrLen(rdata_sony) >= 6)						; data recv length is more than 3 byte (sony 422 mininum command length)
			{
				obj_cmd := sonycmd[rdata_sony . "-"]
				FileAppend, `r`n%rdata_sony% ------------ %A_TickCount%, *
				if (obj_cmd.Name)								; There is valid function for sony 422 command
				{
					obj_cmd.Call(sp_sony, rdata_sony)
					rdata_sony := ""								; clear buffer after  protocol process
				}
			
			}
		}
		else
			rdata_sony := ""				; clear buffer if there is no data
	}

}

return

send_blink_serialdata(port = 13)
{
	static onoff = FALSE
	onoff := !onoff
	command := "0xAB"
	return command . "," . port . "," . onoff . "," . "0"
}

/*

1::
 result := sp_sony.RS232_Write("0x20,0x01,0x21")		; play
return


2::
 result := sp_sony.RS232_Write("0x20,0x00,0x20")			; stop
return


get_id:
3::
 result := sp_sony.RS232_Write("0x00,0x11,0x11")			; get device id
return

*/


chk_serialremote:
GuiControlGet, chk_serial
if chk_serial
{
	count_data_recv := 0
	sp := new serialport(get_comport(), 9600, "N", 8, 1)
	consoleout("Opening COMPORT Result is " . sp.RS232_Initialize())
	if (sp.RS232_FileHandle < 0)
	{
		GuiControl,, %hchk_serial%, 0
		chk_serial := 0
		consoleout("Error opening COM port " . get_comport())
	}
	else
		consoleout("OPEN COMPORT " . get_comport())
}
else
	consoleout("Closing COMPORT Result is " . sp.RS232_close())
	

return



chk_sonyremote:
GuiControlGet, chk_sony
if chk_sony
{
	count_data_recv := 0
	sp_sony := new serialport(get_sonyport(), 38400, "O", 8, 1)			;port := "COM2", baud := 9600, parity := "N", data := 8, stop := 1)
	consoleout("Opening COMPORT Result is " . sp_sony.RS232_Initialize())
	if (sp_sony.RS232_FileHandle < 0)
	{
		GuiControl,, %hchk_sony%, 0
		chk_sony := 0
		consoleout("Error opening COM port " . get_sonyport())
	}
	else
	{
		consoleout("OPEN COMPORT " . get_sonyport())
		;SetTimer, get_id, 20
	}
	
}
else
{
	consoleout("Closing COMPORT Result is " . sp_sony.RS232_close())
	;SetTimer, get_id, Off
}
return


ledalloff(objlist)
{
	for key, val in objlist
		GuiControl,, %val%, 0
	
}

get_cmdlist(cmdlist)
{
	list := ""
	for key, val in cmdlist
		list .= key . "|"
	return list
}

get_comport()
{
	IniRead, com, sbsplayback_remote.ini, remote, com, COM1	
	return com
}

get_sonyport()
{
	IniRead, com, sbsplayback_remote.ini, remote, sonycom, COM2
	return com
}


button1:
ledalloff(ledcontrol)
GuiControl,, %hbutton1%, 100
remoteudp.sendText("__LOAD__")
consoleout("LOAD button Pressed")
;if chk_serial
	;sp.RS232_Write("0xAB, 10, 1, 0x01")			; arduino pin xx to HIGH or LOW
return


button2:
ledalloff(ledcontrol)
GuiControl,, %hbutton2%, 100
remoteudp.sendText("__NEXT__")
consoleout("NEXT button Pressed")
;if chk_serial
	;sp.RS232_Write("0xAB, 10, 1, 0x01")			; arduino pin xx to HIGH or LOW
return

button3:
ledalloff(ledcontrol)
GuiControl,, %hbutton3%, 100
remoteudp.sendText("__PLAY__")
consoleout("PLAY button Pressed")
;if chk_serial
	;sp.RS232_Write("0xAB, 10, 1, 0x01")			; arduino pin xx to HIGH or LOW
return


button4:
ledalloff(ledcontrol)
GuiControl,, %hbutton4%, 100
remoteudp.sendText("__PAUSE_")
consoleout("PAUSE button Pressed")
;if chk_serial
	;sp.RS232_Write("0xAB, 10, 0, 0x01")			; arduino pin xx to HIGH or LOW
return


showobjectlist(obj)
{
	for key, val in obj
	consoleout(key . " ----> " . val)
}

get_remote_address()
{

	IniRead, address, sbsplayback_remote.ini, remote, address, 127.0.0.1
	IniRead, port, sbsplayback_remote.ini, remote, port, 8989
	address_array := Object()
	address_array.push(address)
	address_array.push(port)

	return address_array
}


GuiClose:
ExitApp


consoleout(text)
{
 global heditbox
 Appendtext(heditbox, "`r`n[" . A_DD . "]" . A_Hour . ":" . A_Min . "." . A_Sec . " -- " .  text) 
 FileAppend, `r`n%text%, *
}

AppendText(hEdit, Text)
{
  SendMessage, 0x000E, 0, 0,, ahk_id %hEdit% ;WM_GETTEXTLENGTH
  SendMessage, 0x00B1, ErrorLevel, ErrorLevel,, ahk_id %hEdit% ;EM_SETSEL
  SendMessage, 0x00C2, False, &Text,, ahk_id %hEdit% ;EM_REPLACESEL
}

AppendTextLine(hEdit, Text) 
{
  Text := "`r`n" . Text
  SendMessage, 0x000E, 0, 0,, ahk_id %hEdit% ;WM_GETTEXTLENGTH
  SendMessage, 0x00B1, ErrorLevel, ErrorLevel,, ahk_id %hEdit% ;EM_SETSEL
  SendMessage, 0x00C2, False, &Text,, ahk_id %hEdit% ;EM_REPLACESEL
}


sony_return_deviceid(o_sp, full_cmd)
{
	o_sp.RS232_Write("0x12, 0x11, 0x20, 0xE2, 0x25")			; send device ID		(HDW-M2000)
	return o_sp.RS232_Write("0x10,0x01,0x11")						; send ACK
}


sony_stop(o_sp, full_cmd)
{
	FileAppend, "`r`nStop command received `r`n", *
	consoleout(full_cmd . " ------ " .  A_TickCount)
	SetTimer, button4, -1
	return o_sp.RS232_Write("0x10,0x01,0x11")					; send ACK
}


sony_play(o_sp, full_cmd)
{
	FileAppend, "`r`nPlay command received `r`n", *
	consoleout(full_cmd . " ------ " .  A_TickCount)
	SetTimer, button3, -1
	return o_sp.RS232_Write("0x10,0x01,0x11")					; send ACK
}


sony_currenttimesense(o_sp, full_cmd)			; current time sense,  LTC time request
{
	return o_sp.RS232_Write("0x74, 0x04, 0x00, 0x00, 0x00, 0x11, 0x89")
}

sony_ack(o_sp, full_cmd)
{
	FileAppend, "`r`nACK command received `r`n", *
}

sony_statussense(o_sp, full_cmd)				; status sense, from data 0  to 4 byte
{
	return o_sp.RS232_Write("0x74, 0x20, 0x00, 0xA0, 0x00, 0x00, 0x34")
}



/*  serial port read _ old code


while(1)		; Read serial port data
{
	if chk_serial
	{
		count_loop += 1
		if ((count_loop & 0x0F) = 0x0F)				; check if LSB 4 bit is 1000
			sp.RS232_Write(send_blink_serialdata(12))			; blink remote controller LED (User can check if connection is valid)
		
		data := sp.RS232_Read_Hex(255, byte_received)		; read 255 byte, byte_received value is HEX Value (0x00 = no data)
		if byte_received
		{
			FileAppend, `r`n%data%  -  %byte_received%, *
			;if (data <> "00")			; ignore "00" stgring (Remote power off case, added 2019/10/17)
			;	rdata .= data
			;if (byte_received = "0x2")
			;	rdata := data
			;if ((StrLen(rdata)) = 4 and (InStr(cmd_list, rdata)))				; 2 byet HEX data received and there is valid command string
			;if (InStr(cmd_list, rdata))				; 2 byet HEX data received and there is valid command string
			if ((byte_received = "0x2") and (InStr(cmd_list, rdata)))
				{	
					rdata := data
					count_data_recv += 1
					consoleout(rdata . " ------ " . cmd_recv[rdata] . " ------- "  .  count_data_recv)
					SetTimer, % keypad_to_goto[cmd_recv[rdata]], -1
					rdata := ""
				}
		}
		;if StrLen(rdata) > 4
		;	rdata := ""
	}
	sleep, 30				; sleep time less than 30ms introduce arduino hang up or comport error
}


*/