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

title =  sMXF Player Remote by sendust 20191004

Gui, Margin, 10, 10
Gui, add, Text, w350 h40 hwndhtext Center, -= sMXF Remote =-
Gui, add, Checkbox, xm yp+50 w150 h20 gchk_serialremote vchk_serial hwndhchk_serial, External Remote BOX
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
count_data_recv := 0
count_loop := 0
rdata := ""
byte_received := 0
cmd_recv := Object("EEFF", "SELECT", "22DD", "LEFT", "24DB", "RIGHT", "11EE", "UP", "21DE", "DOWN")
keypad_to_goto := object("SELECT", "button1", "LEFT", "button2", "RIGHT", "button3", "UP", "button4", "DOWN", "button4")
cmd_list := get_cmdlist(cmd_recv)



while(1)		; Read serial port data
{
	if chk_serial
	{
		count_loop += 1
		if ((count_loop & 0x0F) = 0x0F)				; check if LSB 4 bit is 1000
			sp.RS232_Write(send_blink_serialdata(13))			; blink remote controller LED (User can check if connection is valid)
		
		data := sp.RS232_Read_Hex(1, byte_received)		; read single byte
		if byte_received
		{
			rdata .= data
			if ((StrLen(rdata)) = 4 and (InStr(cmd_list, rdata)))				; 2 byet HEX data received and there is valid command string
				{
					count_data_recv += 1
					consoleout(rdata . " ------ " . cmd_recv[rdata] . " ------- "  .  count_data_recv)
					SetTimer, % keypad_to_goto[cmd_recv[rdata]], -1
					rdata := ""
				}
		}
		if StrLen(rdata) > 4
			rdata := ""
	}
	sleep, 30				; sleep time less than 30ms introduce arduino hang up or comport error
}

return

send_blink_serialdata(port = 13)
{
	static onoff = FALSE
	onoff := !onoff
	command := "0xAB"
	return command . "," . port . "," . onoff . "," . "0"
}

chk_serialremote:
GuiControlGet, chk_serial
if chk_serial
{
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


button1:
ledalloff(ledcontrol)
GuiControl,, %hbutton1%, 100
remoteudp.sendText("__LOAD__")
consoleout("LOAD button Pressed")
if chk_serial
	sp.RS232_Write("0xAB, 10, 0, 0x01")			; arduino pin xx to HIGH or LOW
return


button2:
ledalloff(ledcontrol)
GuiControl,, %hbutton2%, 100
remoteudp.sendText("__NEXT__")
consoleout("NEXT button Pressed")
if chk_serial
	sp.RS232_Write("0xAB, 10, 1, 0x01")			; arduino pin xx to HIGH or LOW
return

button3:
ledalloff(ledcontrol)
GuiControl,, %hbutton3%, 100
remoteudp.sendText("__PLAY__")
consoleout("PLAY button Pressed")
if chk_serial
	sp.RS232_Write("0xAB, 10, 0, 0x01")			; arduino pin xx to HIGH or LOW
return


button4:
ledalloff(ledcontrol)
GuiControl,, %hbutton4%, 100
remoteudp.sendText("__PAUSE_")
consoleout("PAUSE button Pressed")
if chk_serial
	sp.RS232_Write("0xAB, 10, 1, 0x01")			; arduino pin xx to HIGH or LOW
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

