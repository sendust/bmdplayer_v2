/*
AHK for arduino control with LCD keypad shield
Use Serial port for communication
Usable Output port : 2, 3, 11, 12, 13  (15, 16, 17, 18, 19  --> analog input pin as digital out)

Arduino port usage
0, 1 : serial port communication with PC
4,5,6,7,8,9 ; LCD Keypad control
10 ; LCD Keypad backlight control

serial port write method : (4 byte command)

result := sp.RS232_Write("A, B, C, D")
A = COMMAND, 0xAB ; digitalWrite
B = port number (2, 3, 11, 12, 13, 15, 16, 17, 18, 19)
C = 1 or 0 (Digital High, Low)
D = Don't care

*/


#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
title = Arduino LCD KEYPAD Test..... 2019/9/20

#include serialport_class.ahk

Gui, margin, 10, 10

Gui, add, button, w100 h50 hwndhbutton1 gbutton1, button1
Gui, add, button, xp+110 w100 h50 hwndhbutton1 gbutton2, button2
Gui, add, button, xp+110 w100 h50 hwndhbutton1 gbutton3, button3
Gui, add, button, xp+110 w100 h50 hwndhbutton1 gbutton4, button4
Gui, add, Edit, xm w500 h500 hwndheditbox ReadOnly, Status
Gui, -MinimizeBox
Gui, show,, %title%

count_data_recv := 0

cmd_recv := Object("EEFF", "SELECT", "22DD", "LEFT", "24DB", "RIGHT", "11EE", "UP", "21DE", "DOWN")
cmd_list := get_cmdlist(cmd_recv)

sp := new serialport("COM17", 9600, "N", 8, 1)

if !sp.RS232_Initialize()
	ExitApp

rdata := ""
byte_received := 0

while(1)
{
	data := sp.RS232_Read_Hex(1, byte_received)		; read single byte
	if byte_received
	{
		rdata .= data
		if ((StrLen(rdata)) = 4 and (InStr(cmd_list, rdata)))
		{
		count_data_recv += 1
		consoleout(rdata . " ------ " . cmd_recv[rdata] . " ------- "  .  count_data_recv)
		rdata := ""
		}
	}
	if StrLen(rdata) > 4
	rdata := ""
	sleep, 10
}



return


get_cmdlist(cmdlist)
{
	list := ""
	for key, val in cmdlist
		list .= key . "|"
	return list
}


button1:
result := sp.RS232_Write("0xAB,10, 0, 0x01")
consoleout("Command write result is " . result)
return

button2:
result := sp.RS232_Write("0xAB,10, 1, 0x02")
consoleout("Command write result is " . result)
return

button3:
result := sp.RS232_Write("0xAB,15,1,0x03")
consoleout("Command write result is " . result)
return

button4:
result := sp.RS232_Write("0xAB,15,0,0x04")
consoleout("Command write result is " . result)
return

GuiClose:
ExitApp



consoleout(text)
{
 global heditbox
 Appendtext(heditbox, "`r`n" . text) 
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
