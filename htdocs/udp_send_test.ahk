﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Include socket.ahk
#SingleInstance force




address := ["127.0.0.1", 40000]
sendudp := new SocketUDP()
;sendudp.connect(address)
temp = 40000
sendudp.connect(["127.0.0.1", temp])




SetTimer, sendtext, 300


return


sendtext:
FormatTime, time_log,, yyyy/MM/dd HH:mm.ss
sendudp.SendText("[PLAY]<br>" . time_log)
FileAppend, %time_log%`r`n, *
return



!esc::ExitApp



printobjectlist(myobject)
{
	temp := ""
	for key, val in myobject
		temp .= key . " ---->  " . val . "`r`n"
	FileAppend, %temp%, *
	return temp
}

