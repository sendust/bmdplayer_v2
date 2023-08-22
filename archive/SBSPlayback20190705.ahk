#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#WinActivateForce
SendMode Event
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, -1
#Include socket.ahk
#Include mediainfo.ahk
#include console_class_sendust.ahk
#SingleInstance ignore
Menu, Tray, Icon, Shell32.dll, 138			; change Tray Icon

title =  sMXF Player v2.2 by sendust 20190705
Gui, Margin, 10, 10
Gui, add, GroupBox, w350 h210, Media Information
Gui, add, text, xp+10 yp+20  w330 h180  multi hwndhmediainfo, Media Property

Gui, add, text, xm yp+210, IN
Gui, add, edit, xp+50 yp w100 h40 r1 limit12 hwndhcue_in vcue_in , 00:00:00.000
Gui, add, button, xp+120 yp w50 h20 hwndhreset  greset , RESET

;Gui, add, Checkbox, xp+100 yp hwndhchk_loop vchk_loop gchk_loop, LOOP
Gui, add, DDL, xp+70 yp w100 hwndhchk_loop vchk_loop gchk_loop choose1, NO LOOP|SINGLE CLIP|PLAYLIST

Gui, add, text, xm yp+30, OUT
Gui, add, edit, xp+50 yp w100 h40 r1 limit12 hwndhcue_out vcue_out 
Gui, add, button, xp+120 yp w50 h20 hwndhreset2  greset2, CLEAR

Gui, add, Checkbox, xp+70 yp hwndhchk_sdiwindow vchk_sdiwindow gsdi_window, SDI WINDOW
Gui, add, Checkbox, xp yp+20 hwndhchk_autoload vchk_autoload gautoload, AUTO LOAD

Gui, add, button, xm w80 h30 hwndhpreview gpreview, PREVIEW
Gui, add, button, xp+90 w80 h30 hwndhpreviewlast gpreviewlast hwndhpreviewlast, PVW-LAST

Gui, add, button, xp+120 yp w60 h30 hwndhsetin gsetin, IN
Gui, add, button, xp+70 yp w60 h30 hwndhsetout gsetout, OUT

Gui, add, Progress, xm yp+40 w350 h5 cblack, 100 ; Horizontal bar --------------------------------------------
Gui, add, Progress, xm yp+5 w350 h5 hwndhpbposition cRed, 0 			; Clip Playback Position

Gui, add, button, xm yp+20 w100 h40 hwndhload gload, LOAD`r`nPREROLL
Gui, add, button, xp+120  yp w100 h40 hwndhplay gplay, PLAY
Gui, add, button, xp+120  yp w100 h40 hwndhpause gpause, PAUSE

Gui, add, Progress, xm yp+42 w100 h5 cred hwndhloadled, 100
Gui, add, Progress, xp+120 yp w100 h5 cred hwndhplayled, 100
Gui, add, Progress, xp+120 yp w100 h5 cred hwndhpauseled, 100

Gui, add, text, xm yp+15 w350 h20 center  hwndhtext_tc , --/--
Gui, add, text, xm yp+30 w350 h20  center hwndhrem_tc , REM --:--:--

Gui, add, button, xm yp+40 w120 h30 hwndhopenmedia gopenmedia, MEDIA Folder
Gui, add, button, xp+140 yp w80 h30 hwndhmount gmount, MOUNT
Gui, add, button, xp+100 yp w100 h30 gaddlist hwndhaddlist, ADD ▶

Gui, add, Text, xm yp+40, Monitor Audio Select
Gui, add, DDL, xp+140 yp-5 w80 hwndhaudiomonl vaudiomonl choose1 gaudiomonsel, CH1|CH2|CH3|CH4|CH5|CH6|CH7|CH8|CH1+CH3
Gui, add, DDL, xp+100 w80 hwndhaudiomonr vaudiomonr choose2 gaudiomonsel, CH1|CH2|CH3|CH4|CH5|CH6|CH7|CH8|CH2+CH4

Gui, add, Progress, xm+360 ym w5 h550, 100			; vertical bar -----------------------------------------------------

Gui, add, ListView, xm+370 ym w400 h440 hwndhlistview vlistview glvclick NoSortHdr NoSort ReadOnly, STATUS|TITLE|IN|OUT|DURATION|CLIP LIST
Gui, add, DDL, xm+390 yp+450 w60 hwndhplselect vplselect choose1, LIST1|LIST2|LIST3|LIST4|LIST5|LIST6|LIST7|LIST8|LIST9
Gui, add, button, xp+100 yp w60 h20 gplsave, SAVE
Gui, add, button, xp+100 yp w60 h20 gplload, LOAD
Gui, add, button, xp+100 yp w65 h20 glvrename, RENAME

Gui, add, button, xm+390 yp+30 w60 h30 glvdeletesingle, DELETE
Gui, add, button, xp+100 yp w60 h30 gmoveup, ▲
Gui, add, button, xp+100 yp w60 h30 gmovedown, ▼

Gui, add, button, xm+390 yp+40 w60 h30 ghelpbox , HELP
Gui, add, button, xp+100 yp w160 h30 glistplay, PLAYLIST PLAY
Gui, add, Progress, xp yp+32 w160 h5 cred hwndhlistplayled, 100

Gui, add, text, xp+200 yp-55 w50 h50 Right hwndhpbnumber, ##

Gui, add, StatusBar, hwndhstatus, Please wait until Caspar Engine ready !!
Gui, -MinimizeBox
Gui  +hwndhmygui
Gui, show,, %title%

Gui, Font, s15 Bold
GuiControl, Font, %htext_tc%

Gui, Font, s15 Bold
GuiControl, Font, %hrem_tc%

Gui, Font, s25 Bold
GuiControl, Font, %hpbnumber%

Gui, Font, s12
GuiControl, Font, %hmediainfo%


addressamcp := ["127.0.0.1", "5250"]

logfile = %A_WorkingDir%\SBSPlayer.log
media := Object()
	media.fullpath := ""
mpv := Object()
	mpv.fullpath := A_WorkingDir . "\bin\mpv.com"
	mpv.pid := -1
mpv_filter := Object()
audio_monitor := object()
lvdata := Object()
	lvdata.pbindex := 0
caspar := Object()
	caspar.title := "CasparCG Server "
	caspar.fullpath := "S:\CasparCG Server 2.0.7\CasparCG Server\Server\casparcg.exe"
	caspar.mediapath := "S:\CasparCG Server 2.0.7\CasparCG Server\Server\media"
	caspar.pid := 0
	caspar.listplay := 0
	caspar.pbindex := 0
	caspar.timeremold  := 5184000			; 48 Hours in frame
	caspar.foregroundfileold := "---"			; apply any text
buttoncontrol := object()
	buttoncontrol := [hsetin, hsetout, hpreview, hload, haddlist, hpreviewlast]		; disable these button while busy

info_caspar := Object()			; decoded value from caspar info command return

mi := object()
mi := new MediaInfo
mpvrun := Object()				; mpv console object

buttonled := object()
	buttonled := [hloadled, hplayled, hpauseled, hlistplayled]

for key, val in buttonled
	GuiControl, Hide, %val%				; hide all LED 

IniRead, temp, splay.ini, caspar, caspar_fullpath
caspar.fullpath := temp
IniRead, temp, splay.ini, caspar, caspar_mediapath
caspar.mediapath := temp

/*
mpv_filter["mono-1"] := "--lavfi-complex=[aid1]asplit[as1][as2];[as1]pan=stereo|c0=c0|c1=c0[ao];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
mpv_filter["mono-2"] := "--lavfi-complex=[aid1][aid2]amerge=inputs=2[a1];[a1]asplit[as1][as2];[as1]pan=stereo|c0=c0|c1=c1[ao];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
mpv_filter["mono-4"] := "--lavfi-complex=[aid1][aid2][aid3][aid4]amerge=inputs=4[a1];[a1]asplit[as1][as2];[as1]pan=stereo|c0=c0+c2|c1=c1+c3[ao];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
mpv_filter["mono-8"] := "--lavfi-complex=[aid1][aid2][aid3][aid4][aid5][aid6][aid7][aid8]amerge=inputs=8[a1];[a1]asplit[as1][as2];[as1]pan=stereo|c0=c0+c2|c1=c1+c3[ao];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
mpv_filter["stereo-1"] := "--lavfi-complex=[aid1]asplit[as1][as2];[as1]pan=stereo|c0=c0|c1=c1[ao];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
mpv_filter["stereo-2"] := "--lavfi-complex=[aid1][aid2]amerge=inputs=2[a1];[a1]asplit[as1][as2];[as1]pan=stereo|c0=c0|c1=c1[ao];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
mpv_filter["stereo-3"] := "--lavfi-complex=[aid1][aid2][aid3]amerge=inputs=3[a1];[a1]asplit[as1][as2];[as1]pan=stereo|c0=c0|c1=c1[ao];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
*/
mpv_filter["noaudio"] := ""
mpv_filter["mono-1"] := "--lavfi-complex=[aid1]asplit[as1][as2];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
mpv_filter["mono-2"] := "--lavfi-complex=[aid1][aid2]amerge=inputs=2[a1];[a1]asplit[as1][as2];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
mpv_filter["mono-4"] := "--lavfi-complex=[aid1][aid2][aid3][aid4]amerge=inputs=4[a1];[a1]asplit[as1][as2];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
mpv_filter["mono-8"] := "--lavfi-complex=[aid1][aid2][aid3][aid4][aid5][aid6][aid7][aid8]amerge=inputs=8[a1];[a1]asplit[as1][as2];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
mpv_filter["stereo-1"] := "--lavfi-complex=[aid1]asplit[as1][as2];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
mpv_filter["stereo-2"] := "--lavfi-complex=[aid1][aid2]amerge=inputs=2[a1];[a1]asplit[as1][as2];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
mpv_filter["stereo-3"] := "--lavfi-complex=[aid1][aid2][aid3]amerge=inputs=3[a1];[a1]asplit[as1][as2];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"

audio_monitor["CH1"] := "c0"
audio_monitor["CH2"] := "c1"
audio_monitor["CH3"] := "c2"
audio_monitor["CH4"] := "c3"
audio_monitor["CH5"] := "c4"
audio_monitor["CH6"] := "c5"
audio_monitor["CH7"] := "c6"
audio_monitor["CH8"] := "c7"
audio_monitor["CH1+CH3"] := "c0+c2"
audio_monitor["CH2+CH4"] := "c1+c3"



mpv_filter["stereo-4"] := mpv_filter["mono-4"]
mpv_filter["5.1-1"] := mpv_filter["stereo-1"]
mpv_filter["7.1-1"] := mpv_filter["stereo-1"]
mpv_filter["8-1"] := mpv_filter["stereo-1"]
mpv_filter["16-1"] := mpv_filter["stereo-1"]

mpv_filter["2 channels-1"] := mpv_filter["stereo-1"]
mpv_filter["2 channels-2"] := mpv_filter["stereo-2"]
mpv_filter["2 channels-3"] := mpv_filter["stereo-3"]
mpv_filter["2 channels-4"] := mpv_filter["stereo-4"]

mpv_filter["4 channels-1"] := mpv_filter["stereo-1"]
mpv_filter["5 channels-1"] := mpv_filter["stereo-1"]
mpv_filter["6 channels-1"] := mpv_filter["stereo-1"]
mpv_filter["7 channels-1"] := mpv_filter["stereo-1"]
mpv_filter["8 channels-1"] := mpv_filter["stereo-1"]
mpv_filter["16 channels-1"] := mpv_filter["stereo-1"]
mpv_filter["32 channels-1"] := mpv_filter["stereo-1"]


looparray := object()
looparray["NO LOOP"] := "LOOP 0"
looparray["SINGLE CLIP"] := "LOOP 1"
looparray["PLAYLIST"] := "LOOP 0"
caspar.loop := "LOOP 0"					; Set Default value


checklogfile(logfile)
initcaspar(caspar)


casparamcp := new SocketTCP()		; Establish tcp connection with Caspar CG Server

Loop, 20							; Try to connect caspar CG server 
{
	updatelog("Try to connect caspar engine " . A_Index . " Times")
	try casparamcp.Connect(addressamcp)
	catch, err
		updatelog(err.Message)
	errormessage := err.Message
	if InStr(errormessage, "error")
	{
		Sleep, 300
		ToolTip, %A_Index% - %errormessage%
		continue
	}
	else
		ToolTip
		break
}
casparamcp.onRecv := Func("OnAMCP_TCPRecv")  		; Finish loading casparCG

GuiControl,, %hstatus%, % "Caspar CG launched with PID " . caspar.pid
updatelog("Caspar CG launched with PID " . caspar.pid)

caspar.loop := looparray[chk_loop]

Gui, Submit, NoHide
gosub, audiomonsel

SetTimer, casparpbchk, -1000
return


#IfWinActive, Preview play...
~i::gosub setin
~o::gosub setout
enter::gosub addlist


#If WinActive(title)
PGUP::
if caspar.listplay		; During listplaying, pbindex cannot be modified manually
{
	GuiControl,, %hstatus%, Please release PLAYLIST PLAY MODE !!!
	return
}

if (caspar.pbindex > 1)				
	{
		caspar.pbindex -= 1
		updatepropertytextlv(caspar, media)
		if chk_autoload
		gosub, load
	}
return

PGDN::
if caspar.listplay   				; During listplaying, pbindex cannot be modified manually
{
	GuiControl,, %hstatus%, Please release PLAYLIST PLAY MODE !!!
	return
}

if (caspar.pbindex < LV_GetCount() )	
{
	caspar.pbindex += 1
	updatepropertytextlv(caspar, media)
	if chk_autoload
	gosub, load
}
return




checklogfile(chkfile)
{
	FileGetSize, size, %chkfile%
	updatelog("Log file size is " . size . " Bytes")
	if (size > 1000000)
	{
		SplitPath, chkfile, outfilename, outdir, outextension, outnamenoext, outdrive
		FormatTime, outputvar,, yyyyMMdd-HHmmss
		FileMove, %chkfile%, %outdir%\%outnamenoext%_%outputvar%.%A_MSec%.%outextension%, 0
	}
		
}

audiomonsel:
GuiControlGet, audiomonl
GuiControlGet, audiomonr

audio_monitor_filter := ";[as1]pan=stereo|c0=" . audio_monitor[audiomonl] . "|c1=" . audio_monitor[audiomonr] . "[ao]"
;[as1]pan=stereo|c0=c0+c2|c1=c1+c3[ao]
updatelog(audio_monitor_filter)

return



sdi_window:		; Open or Close SDI Preview window
GuiControlGet, chk_sdiwindow

if !chk_sdiwindow
{
	if WinExist("Channel Grid")
	{
		WinClose, Channel Grid
		WinWaitClose, Channel Grid
		updatelog("Clear previous channel grid window")
	}
		return
}
else
{
	if WinExist("Channel Grid")
		return
	
	try
	{
		casparamcp.sendText("set 2 mode NTSC`r`n")			; set channel_grid window format
		Sleep, 300
		casparamcp.sendText("channel_grid`r`n")			; set channel_grid window format
	}
	catch, err
		updatelog(err.Message)
	
	updatelog("send Channel grid command")
	WinWait, Channel Grid
	WinActivate, Channel Grid
	updatelog("Wait channel grid window")
	WinWaitActive, Channel Grid
	WinMove, Channel Grid,, 10, 10, 736, 518
	updatelog("Complete Channel grid window move, resize")
}

return


autoload:
GuiControlGet, chk_autoload
updatelog("AUTO LOAD " . chk_autoload)
return

casparpbchk:
xmlfile := SubStr(tcptext, InStr(tcptext, "<?xml"))			; Find xml header
if StrLen(xmlfile) > 20
{
	info_caspar := read_caspar_info(xmlfile)
	
	; ToolTip % showobjectlist(info_caspar)

	caspar.timerem := info_caspar.time2_clip + info_caspar.time1_clip - info_caspar.time1_foreground
	caspar.foregroundfile := info_caspar.filename_foreground
	caspar.backgroundfile := info_caspar.filename_background
	caspar.nb_times  := info_caspar.time2_clip

	/*
	time1_clip ; seek position (at load)
	time2_clip ; duration (at load)
	
	time1_foreground ; current pb position
	time2_foreground ; file duration
    */	

	if (caspar.foregroundfile <> caspar.foregroundfileold)
		WinSetTitle, ahk_id %hmygui%, , % title . "  --  " . caspar.foregroundfile

	caspar.foregroundfileold := caspar.foregroundfile
	
	if (caspar.listplay and (caspar.timerem > caspar.timeremold)) 	; next clip load foreground, update media property text
	{
		caspar.pbindex += 1
		if ((caspar.pbindex > LV_GetCount()) and (chk_loop = "PLAYLIST"))		; Last clip 
			caspar.pbindex := 1
		updatepropertytextlv(caspar, media)
		;GuiControl,, %hpbnumber%,  % caspar.pbindex
	}
			
	;ToolTip, % caspar.pbindex . "  " . caspar.timerem . "/" . caspar.timeremold  . "  -  " . caspar.foregroundfile . "   -  " . caspar.backgroundfile
	GuiControl,, %htext_tc%, %  secondtotc_drop(info_caspar.time1_foreground - info_caspar.time1_clip) . "  /  " .  secondtotc_drop(info_caspar.time2_clip)
	GuiControl,, %hrem_tc%, % "REM " . secondtotc_drop(caspar.timerem)
	GuiControl,, %hpbposition%, % 100 - ((caspar.timerem / caspar.nb_times) * 100)
	
	if (caspar.listplay and (caspar.timerem < 4) and (caspar.timerem > 2))			; current play is listplay and remaining time is between 4 and 3
		if !caspar.backgroundfile
		{
			if (caspar.pbindex <= LV_GetCount() - 1)					; loadbg conditions (within 5 second remain, there is no background layer, this is listplay, listindex is maxindex -1)
			{
				lvdata := lv_getall(caspar.pbindex+1)
				loadlvclip(caspar, lvdata)
			}
			if ((caspar.pbindex = LV_GetCount()) and (chk_loop = "PLAYLIST"))		; PLAYLSIT LOOP CASE, Last clip playing, load first clip
			{
				lvdata := lv_getall(1)						
				loadlvclip(caspar, lvdata)
			}
		}

	caspar.timeremold := caspar.timerem
}
try
	casparamcp.sendText("info 1-1`r`n")
catch, err
	updatelog(err.Message)
	
if ((caspar.pbindex = LV_GetCount()) and !caspar.timerem and caspar.listplay)		; pbindex reach LV count and no remaing frame -- Finish listplay
{
	caspar.listplay := 0
	updatelog("Finish Playlist Play")
	GuiControl,, %hstatus%, Finish Playlist Play
}
SetTimer, casparpbchk, -300
return



loadlvclip(byref caspar, byref lvdata)
{
	global hstatus, casparamcp
	caspar.in := tctoframe_drop(lvdata.in) * 2			; x2  for interlaced video
	if lvdata.out			; if there is out point
	{
		caspar.out := tctoframe_drop(lvdata.out) * 2  	; x2  for interlaced video
		caspar.duration := "LENGTH " . (caspar.out - caspar.in +1)
			updatelog("LV Clip duration is " . caspar.duration)
	}
	else 
	{
		caspar.duration := ""			; there is no out point
		updatelog("LV Clip is OPEN END")
	}

	try
	{
		casparamcp.sendText("loadbg 1-1 """ . lvdata.clip . """ SEEK " . caspar.in . " " . caspar.duration .  " MIX 10 auto`r`n")		; next clip load background
	}
	catch, err
	
	updatelog(err.Message)
	updatelog("loadbg 1-1 """ . lvdata.clip . """ SEEK " . caspar.in . " " . caspar.duration .  " MIX 10 auto`r`n")
	GuiControl,, %hstatus%,% "LV Clip loaded -- " . lvdata.clip	. "  /  " . caspar.in . "  /  " . caspar.duration
}



helpbox:
FileRead, helpfile, helpfile.txt
MsgBox,,Help Information, %helpfile%
return


clearlv:
LV_Delete()
return



splitcasparpath(casparmedia)
{
	temp := StrSplit(casparmedia, "/")
	return temp[temp.MaxIndex()]				; return Media name only (Without path name)
}


addlist:
if !media.fullpath
	return
Gui, Submit, NoHide

lvdata.status := LV_GetCount()+1
lvdata.clip := caspar.medianame
lvdata.in := cue_in
lvdata.out := cue_out
if (tctosecond(cue_in, 29.97) >= tctosecond(cue_out, 29.97))			; 
	lvdata.out := ""
lvdata.duration := ""
lvdata.title := splitcasparpath(caspar.medianame)

lv_addall(lvdata)
LV_ModifyCol(, AutoHdr)
updatelogall("Adding -- [" . lvdata.status . " - " . lvdata.clip  . " - " . lvdata.in . " - " . lvdata.out . "]" )
SetTimer, removetooltip, -1000
return


lvdeletesingle:
if !LV_GetNext(0)
	return
Loop, % LV_GetCount("S")
	LV_Delete(LV_GetNext(0))

return


lvrename:
if !LV_GetNext(0)
	return
row := LV_GetNext(0)
lvdata := lv_getall(row)
InputBox, outputvar, Input New title, Please type new title, , , , , , , , % lvdata.title
lvdata.title := outputvar
lv_modifyall(row, lvdata)
LV_ModifyCol()
return




moveup:
if LV_GetNext(0) < 2
	return
row := LV_GetNext(0)

lvdata := lv_getall(row - 1)
lv_modifyall(row - 1, lv_getall(row))
lv_modifyall(row, lvdata)
LV_Modify(row, "-Select")
LV_Modify(row-1, "Select")
LV_ModifyCol()
return

movedown:
if LV_GetNext(0) >= LV_GetCount()
	return
row := LV_GetNext(0)
lvdata := lv_getall(row)
lv_modifyall(row, lv_getall(row + 1))
lv_modifyall(row + 1, lvdata)
LV_Modify(row+1, "Select")
LV_Modify(row, "-Select")
LV_ModifyCol()
return


lvclick:
if !LV_GetNext(0)
	return
if caspar.listplay
{
	updatelogall("You cannot edit during playlist playing")
	SetTimer, removetooltip, -2000
	return
}
if ((A_GuiEvent = "DoubleClick") or (A_GuiEvent = "D"))
{
	if !caspar.listplay					; During listplaying, pbindex cannot be modified manually
	{
		;caspar.timeremold  := 5184000			; prevent unwanted pbindex increasing
		caspar.pbindex := LV_GetNext(0)
	}
	updatepropertytextlv(caspar, media)
	if chk_autoload
		gosub, load
	;ToolTip % caspar.pbindex
}

return







updatepropertytextlv(byref caspar, byref media)
{
	global hcue_in, hcue_out, hmediainfo, hstatus, hpbnumber
	lvdata := lv_getall(caspar.pbindex)
	caspar.timeremold  := 5184000			; prevent unwanted pbindex increasing during list play
	caspar.medianame := lvdata.clip
	GuiControl, text, %hcue_in%, % lvdata.in
	GuiControl, text, %hcue_out%, % lvdata.out
	media.fullpath := ""
	caspartowinpath(caspar, media)		; find real path by caspar media name
	GuiControl,,%hmediainfo%, % "Load Clip --------------`r`n`r`n" . "[" . lvdata.status . "] - " . lvdata.title . "`r`n`r`n" . lvdata.clip . "`r`n`r`n" . lvdata.in . " - " . lvdata.out
	GuiControl,, %hpbnumber%, % caspar.pbindex
	GuiControl,,%hstatus%, % "Preview LOAD -- " . media.fullpath
}




caspartowinpath(byref caspar, byref media)
{
	tempfile := caspar.mediapath . caspar.medianame
	tempfile := StrReplace(tempfile, "/", "\")
	path := caspar.mediapath
	Loop, Files, %path%\*.*, R
	{
		SplitPath, A_LoopFileFullPath, outfilename, outdir, outextension, outnamenoext, outdrive
		name = %outdir%\%outnamenoext%
		if (name = tempfile)
		{
			media.fullpath := A_LoopFileFullPath
			media.filename := outfilname
		}
	}
}




;before     STATUS|CLIP LIST|TITLE|IN|OUT
;after       STATUS|TITLE|IN|OUT|DURATION|CLIP LIST

lv_addall(data)
{
	;LV_Add(,data.status, data.clip, data.in, data.out)
	LV_Add(,data.status, data.title, data.in, data.out, data.duration, data.clip)	
}

lv_modifyall(row, data)
{
	;LV_Modify(row,, data.status, data.clip, data.in, data.out)
	LV_Modify(row,, data.status, data.title,data.in, data.out, data.duration, data.clip)
}

lv_getall(row)
{
	data := object()
	LV_GetText(temp, row, 1)
	data.status := temp
	LV_GetText(temp, row, 2)
	data.title := temp
	LV_GetText(temp, row, 3)
	data.in := temp
	LV_GetText(temp, row, 4)
	data.out := temp
	LV_GetText(temp, row, 5)
	data.duration := temp
	LV_GetText(temp, row, 6)
	data.clip := temp
	return data
}



onAMCP_TCPRecv(this)			; ACMP protocol receiving message
{
	global hstatus, tcptext
	tcptext := this.RecvText()
	text_short := SubStr(tcptext,1,20)  			; logging first 20 character
	if !InStr(text_short, "INFO")
	{
		GuiControl,, %hstatus%, %text_short%
		updatelog(text_short)	
	}
}


initcaspar(ByRef cas)
{
	fullpath := cas.fullpath
	title := cas.title
	if !WinExist(title)
	{
		SplitPath, fullpath, outfilename, outdir, outextension, outnamenoext, outdrive
		run, "%fullpath%", %outdir%, Minimize, pid
		WinWait, ahk_pid %pid%,, 3
		IfWinNotExist, ahk_pid %pid%
			MsgBox "Fail to launch Caspar"
	cas.pid := pid
	} else
	{
		WinGet, pid, pid, %title%
		cas.pid := pid
	}
}



plsave:
Gui, Submit, NoHide
FileDelete, %plselect%.txt
Loop, % LV_GetCount()
{
	lvdata := lv_getall(A_Index)
	FileAppend, % lvdata.status . "|" . lvdata.title . "|" . lvdata.in . "|" . lvdata.out .  "|" . lvdata.duration . "|" .  lvdata.clip  "`r`n", %plselect%.txt
	ToolTip, % A_Index . " Line saved ~~"
	Sleep, 10
}
SetTimer, removetooltip, -1000
return



plload:
Gui, Submit, NoHide
LV_Delete()
Loop, Read, %plselect%.txt
{
	readarray := StrSplit(A_LoopReadLine, "|")
	lvdata.status := A_Index
	lvdata.title := readarray[2]
	lvdata.in := readarray[3]
	lvdata.out := readarray[4]
	lvdata.duration := readarray[5]
	lvdata.clip := readarray[6]
	lv_addall(lvdata)
}
LV_ModifyCol()
return



preview:

GuiControlGet, cue_in
mpv.start := cue_in
runpreview(media, mpv)
SetTimer, mpvchk, -500
return


previewlast:

GuiControlGet, cue_out
if cue_out
	mpv.start := cue_out
else
	mpv.start := -0.3
runpreview(media, mpv)
SetTimer, mpvchk, -500
return


mpvchk:
Process, Exist, % mpv.pid
If !ErrorLevel			; There is no mpv console process
{
	GuiControl,, %hstatus%, Preview Window Closed
	updatelog("Preview Window Closed")
	mpv.pid := -1
	SetTimer, mpvchk, Off
	mpvrun := ""
	ToolTip								; Remove any tool tip
	return
}
temp := mpvrun.read()
;Loop, parse, temp, `r
;	FileAppend, % A_Index . "   " . A_LoopField . "  -  " . StrLen(A_LoopField) . "`r`n", mpvoutput2.txt
get_pvw_position2(temp, mpv)
;ToolTip % mpv.pos
SetTimer, mpvchk, -300
return



get_pvw_position2(mpvout, ByRef mpv)			; old manner (clip board capture)
{
	global hstatus
	Process, Exist, % mpv.pid
	if ErrorLevel			; There is mpv console process
	{
		Loop, Parse, mpvout, `r, `n
		{
				foundpos := RegExMatch(A_LoopField, "V:\s+[0-9]+:[0-9]+:[0-9]+.[0-9]+", position)		; Find time code information from last 70 character
			if foundpos
			{
				mpv.pos  := SubStr(position, 4)
				return mpv.pos
			}
			else
				return 0
		}
	}
	else			; there is no mpv console process
	{
		mpv.pos := "00:00:00.00"
		mpv.pid := -1
		GuiControl,, %hstatus%, There is no preview window
		return 0
	}
}

/*
	Loop, Parse, Clipboard, `n, `r
		lastline := A_LoopField

*/


openmedia:
run, % caspar.mediapath
return


mount:
mklink(caspar.mediapath)
return


setin2:		; old version (windows console capture)
if !WinExist("Preview play")
{
	ToolTip, There is no preview indow
	SetTimer, removetooltip, -1000
	return
}
get_pvw_position(mpv)
GuiControl, text, %hcue_in%, % mpv.pos
updatelogall("Set in point  " . mpv.pos)
SetTimer, removetooltip, -1000
WinActivate, Preview play
return


setout2: 	; old version (windows console capture)
if !WinExist("Preview play")
{
	ToolTip, There is no preview indow
	SetTimer, removetooltip, -1000
	return
}

get_pvw_position(mpv)
GuiControl, text, %hcue_out%, % mpv.pos
updatelogall("Set out point  " . mpv.pos)
SetTimer, removetooltip, -1000
WinActivate, Preview play
return


setin:			; New version (get position from pipe handle)
Process, Exist, % mpv.pid
if ErrorLevel
{
	temp := mpvrun.read()
	get_pvw_position2(temp, mpv)
	GuiControl, text, %hcue_in%, % mpv.pos
	updatelogall("Set in point  " . mpv.pos)
	SetTimer, removetooltip, -1000
}
return

setout:	 	; New version (get position from pipe handle)
Process, Exist, % mpv.pid
if ErrorLevel
{
	temp := mpvrun.read()
	get_pvw_position2(temp, mpv)
	GuiControl, text, %hcue_out%, % mpv.pos
	updatelogall("Set in point  " . mpv.pos)
	SetTimer, removetooltip, -1000
}
return



reset:
GuiControl,,%hcue_in%, 00:00:00.000
updatelog("TC Reset")
return

reset2:
GuiControl,,%hcue_out%
updatelog("TC OUT Reset")
return


; NO LOOP|SINGLE CLIP|PLAYLIST
chk_loop:
GuiControlGet, chk_loop,,%hchk_loop%
caspar.loop := looparray[chk_loop]
if (chk_loop = "SINGLE CLIP")
	caspar.listplay := 0

try
{	
	casparamcp.sendText("CALL 1-1 " . caspar.loop . "`r`n")
}
catch, err
	updatelog(err.Message)

updatelog("CALL 1-1 " . caspar.loop)
return


load:
GuiControlGet, cue_in,, %hcue_in%
GuiControlGet, cue_out,, %hcue_out%
GuiControlGet, chk_loop,, %hchk_loop%
;caspar.loop := looparray[chk_loop]
;ToolTip % chk_loop . "   " . caspar.loop
caspar.loop := (chk_loop = "SINGLE CLIP") ? "LOOP" : ""
;if (chk_loop =  "SINGLE CLIP")
;	caspar.loop := "LOOP"
caspar.listplay := 0

caspar.in := tctoframe_drop(cue_in) * 2				; for interlaced video, x2 is req.

resetcasparudp(casparudp)

if cue_out			; if there is out point
{
	caspar.out := tctoframe_drop(cue_out) * 2   		; for interlaced video, x2 is req.
	if caspar.out > caspar.in				; out point is behind in point (correct)
	{
		caspar.duration := "LENGTH " . (caspar.out - caspar.in + 1)
		GuiControl,, %hstatus%, % caspar.duration
	}
	else 
	{
		caspar.duration := ""			; out point is before in point (invalid)
		GuiControl,, %hstatus%, OPEN END
	}
} else
	caspar.duration := ""		; there is no out point


try
{	
	casparamcp.sendText("load 1-1 """ . caspar.medianame . """ SEEK " . caspar.in . " " . caspar.duration . " " . caspar.loop . "`r`n")
}
catch, err
	updatelog(err.Message)
	
updatelog("load 1-1 """ . caspar.medianame . """ SEEK " . caspar.in . " " . caspar.duration . " " . caspar.loop )

SetTimer, casparpbchk, -1000
ledon(hloadled)

return



ledon(handle)
{
	global buttonled
	for key, val in buttonled
	GuiControl, Hide, %val%				; hide all LED 
	GuiControl, Show, %handle%		; Turn on LED
}



resetcasparudp(byref casparudp)
{
	global addressudp
	casparudp := ""
	casparudp := new SocketUDP()
	try
	{
		casparudp.bind(addressudp)
		casparudp.onRecv := Func("OnOSC_UDPRecv")	
	}
	catch, err
		updatelog(err.Message)	
}

play:
caspar.listplay := 0

resetcasparudp(casparudp)

try
{	
	casparamcp.sendText("play 1-1`r`n")
	Sleep, 100
	casparamcp.sendText("info 1-1`r`n")
	;casparamcp.sendText("CALL 1-1 " . caspar.loop . "`r`n")
}
catch, err
	updatelog(err.Message)
updatelog("Play command 1-1")

SetTimer, casparpbchk, -1000
ledon(hplayled)
return

listplay:
caspar.listplay := 1
caspar.timeremold  := 5184000			; prevent unwanted pbindex increasing
updatelog("pb index is " . caspar.pbindex)

resetcasparudp(casparudp)

try
{	
	casparamcp.sendText("play 1-1`r`n")
	casparamcp.sendText("info 1-1`r`n")
}
catch, err
	updatelog(err.Message)
updatelog("Play command 1-1")

SetTimer, casparpbchk, -1000
ledon(hlistplayled)
;GuiControl,, %hpbnumber%,  % caspar.pbindex
return



pause:
caspar.listplay := 0

resetcasparudp(casparudp)

try
{	
	casparamcp.sendText("pause 1-1`r`n")
}
catch, err
	updatelog(err.Message)
updatelog("Pause command 1-1 ")
SetTimer, casparpbchk, off

ledon(hpauseled)
return


GuiDropFiles:
if !InStr(A_GuiEvent, caspar.mediapath)
{
	GuiControl,, %hmediainfo%, 경로 확인 !! `r`n`r`nMEDIA 폴더에 있는 클립만 로드 할 수 있습니다.
	return
}

for key, val in buttoncontrol				; Disable some buttons
	GuiControl, Disable, %val%
Sleep, 60		; wait until button disabled

GuiControl,, %hmediainfo%, 파일 분석중~~!!`r`n기다릴것

GuiControl, text, %hcue_in%, 00:00:00.000
GuiControl, text, %hcue_out%

media.fullpath := A_GuiEvent
SplitPath, A_GuiEvent, outfilename,  outdir, outextension, outnamenoext
caspar.medianame := outdir .  "/" . outnamenoext
caspar.medianame := StrReplace(caspar.medianame, caspar.mediapath, "")
caspar.medianame := StrReplace(caspar.medianame, "\", "/")
; analyse_media(media)
analyse_media(media, mi)
updatepropertytext(hmediainfo, media)

for key, val in buttoncontrol			; Enable some buttons
	GuiControl, Enable, %val%

/*
for key, val in media
	updatelog(key . "  ----> " . val)
*/
return




GuiClose:
;temp := mpv.pid
;WinClose, ahk_pid %temp%
Run, taskkill /f /im mpv.com,, Hide
Run, taskkill /f /im mpv.exe,, Hide

MsgBox, 4, Close Option, Caspar 엔진도 같이 닫을까요 ? (Yes - 송출 종료됨, No - 송출은 유지됨)
IfMsgBox yes
{
	try
	{	
		casparamcp.sendText("clear 1`r`n")
		Sleep, 200
		casparamcp.sendText("gl gc`r`n")
		Sleep, 200
	}
	catch, err
		updatelog(err.Message)
		
		while WinExist(caspar.title)
		{
			ControlSend,,q{enter}, % caspar.title
			Sleep, 200
		}
	ExitApp
} else
ExitApp


removetooltip:
ToolTip
return



; run, "C:\Util\mpv-i686-20170423\mpv.com" -vf "yadif`,scale=1280:720" --osd-level=3 --osd-fractions --title "Editor Play - %file_name%" "%file_full%",,Minimize,play_pid  ; escape character ` is used. for comma (,)
;  run, c:\util\mpv-i686-20170423\mpv.com --lavfi-complex=[aid1][aid2][aid3][aid4]amerge=inputs=4[a1];[a1]asplit[as1][as2];[as1]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf]yadif=0[deint];[deint]scale=1280:720[vsize];[vsize][vvolume]overlay=x=20:y=20[vo];[as2]pan=stereo|c0=c0+c2|c1=c1+c3[ao] --osd-level=3 --osd-fractions --title "Editor Play - %file_name%" "%file_full%",,Minimize,play_pid    ; yadif=0 ; 1 frame per 1 frame, yadif=1 ; 1frame for each field

get_pvw_position(ByRef mpv)
{
	global hstatus
	pid := mpv.pid
	Clipboard := ""
	;WinShow, ahk_pid %pid%
	WinActivate, ahk_pid %pid%
	WinWaitActive, ahk_pid %pid%,, 1
	IfWinActive, ahk_pid %pid%
	{
		SendInput, {Esc}
		SendInput, !{Space}
		SendInput, es{Enter}
		ClipWait, 2
	}
	;WinHide, ahk_pid %pid%
	Loop, Parse, Clipboard, `n, `r
		lastline := A_LoopField
	RegExMatch(lastline, "V:\s+[0-9]+:[0-9]+:[0-9]+.[0-9]+", position)
	mpv.pos  := SubStr(position, 4)
	IfWinNotExist, MPV Control Console
	{
		mpv.pos := "00:00:00.00"
		GuiControl,, %hstatus%, There is no preview window
	}
	updatelog("PB Position sensing : " . mpv.pos)
}


runpreview(media, byref mpv)
{
	global mpv_filter, audio_monitor_filter, mpvrun, casparudp
	key := media.audio_format
	lavfilter := mpv_filter[key] . audio_monitor_filter
	geometry := ""
	
	Process, Exist, % mpv.pid
	if ErrorLevel
	{
		updatelog("Send term signal to pid " . mpv.pid)
		Process, Close, % mpv.pid
	}
	
	if WinExist("Preview play")			; Save previous mpv windows position
{
	WinGetPos, x, y, width, height, Preview play
	mpv.xpos := x + 8
	mpv.ypos := y + 30
	WinClose, Preview play
}

	if mpv.xpos and mpv.ypos
	{
		if ((mpv.xpos < 0) or (mpv.xpos > A_ScreenWidth))
			mpv.xpos := 100
		if ((mpv.ypos < 0) or (mpv.ypos > A_ScreenHeight))
			mpv.ypos := 100
		geometry := "--geometry=" . mpv.xpos . ":" . mpv.ypos			; restore last windows position
		
	}
	mpvpath := mpv.fullpath
	mediapath := media.fullpath
	start := mpv.start
	
	;IfWinExist, MPV Control Console
	;	WinClose, MPV Control Console

	title := "Preview play... " . media.fullpath
	runtext = %mpvpath% %lavfilter% --start %start% %geometry% --pause --keep-open --force-window=yes --window-scale=0.5 --hr-seek=yes --osd-level=3 --osd-fractions  "%mediapath%" --title "%title%"
	;Run, %mpvpath% %lavfilter% --start %start% %geometry% --pause --keep-open --force-window=yes --window-scale=0.5 --hr-seek=yes --osd-level=3 --osd-fractions  --no-audio "%mediapath%" --title "%title%",,,pid
	;mpv.pid := pid
	;WinWait, ahk_pid %pid%,, 5
	;WinSetTitle, ahk_pid %pid%,, MPV Control Console
	;WinMove,  ahk_pid %pid%, ,20000 ,20000			; move away outside visible area
	mpvrun := new consolerun(runtext,, "CP850")
	mpv.pid := mpvrun.pid
	WinWait, %title%,, 3
	WinSet, Style, -0x20000, %title%					; remove minimize button
	WinSet, Style, -0x30000, %title%					; remove maximize button
	;WinHide, ahk_pid %pid%
	;updatelog(runtext)
	updatelog("MPV launched with PID " . mpv.pid . "/ Geometry " . geometry)
}



updatelog(text)
{
	global logfile
	FileAppend, [%A_DD%] %A_Hour%:%A_Min%.%A_sec%_%A_MSec%  - %text%`r`n, %logfile%
}

updatelogall(text)
{
	global hstatus
	ToolTip, % text
	updatelog(text)
	GuiControl,, %hstatus%, % text
}

showobjectlist(myobject)
{
	temp := ""
	for key, val in myobject
		temp .= key . " ---->  " . val . "`r`n"
	ToolTip %temp%
}


updatepropertytext(handle, media_in)
{
	SplitPath, % media_in.fullpath, outfilename
	property := outfilename . "`r`n-----------------------`r`n" . "Resolution : " . media_in.resolution . "`r`n" . "Codec : " . media_in.codecv . "`r`n"
		. "Audio Format : " . media_in.audio_format . "`r`n" . "Duration: " . media_in.duration . " (" . secondtotc_drop(media_in.duration) . ")`r`n" . "Total Frame : " . media_in.durationframe . "`r`n"
		. "Framerate: " . media_in.framerate . "`r`n" . "StartTC: " . media_in.start  . "`r`n" . "ScanType: " . media_in.scantype
	updatelog(property)
	GuiControl, text, %handle%, %property%
}

analyse_media(ByRef media, o_mi)			; new, 2019/4/3 from mediainfo.dll
{
	global hstatus
	GuiControl,, %hstatus%, Analysing Media...Please wait
	o_mi.open(media.fullpath)
	
	media.duration := o_mi.getvideo("Duration") / 1000	
	media.start := o_mi.gettimecode()	
	media.resolution := o_mi.getvideo("Width") . "x" . o_mi.getvideo("Height")
	media.resolution := StrLen(media.resolution) < 3 ? o_mi.getimage("Width") . "x" . o_mi.getimage("Height") : media.resolution
	media.framerate := o_mi.getvideo("FrameRate")
	media.audio_format := o_mi.getaudiocount()
	media.codecv := o_mi.getvideo("Format")
	media.durationframe :=  o_mi.getvideo("FrameCount")	
	media.scantype := o_mi.getvideo("ScanType")	
	GuiControl,, %hstatus%, Finish Analysing Media
	
}


tctosecond(intime, fps)						; changed 2018/12/10
{
		if fps < 1
			fps := 30
		hh := SubStr(intime, 1, 2)			; ffmpeg output example   [ Duration: 00:06:56.42, start: 1.033367, bitrate: 9524 kb/s ]
		mm := SubStr(intime, 4, 2)			;						  [ timecode        : 11:10:59;25 ]
		ss := SubStr(intime, 7, 2)
		separator := SubStr(intime, 9, 1)
		IfEqual, separator, .				;  separator is . (00:06:56.42 format)
			ss := SubStr(intime, 7, 5)
		IfEqual, separator, `;
			ss := SubStr(intime, 7, 2) + SubStr(intime, 10,2) / fps
		IfEqual, separator, :				; separator is : (00:06:00:33 format, Gopro case)		added 2018/12/10
			ss := SubStr(intime, 7, 2) + SubStr(intime, 10,2) / fps

		return hh * 3600 + mm * 60 + ss	
}

frametotc(frame)
{
	second := frame/29.97
	return % secondtotc_drop(second)
}

tctoframe_drop(intime)
{
	second := tctosecond(intime, 29.97)
	return % round(second * 29.97)
}



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



mklink(lnk)
{
	global hstatus
	FileSelectFolder, folder, ::{20d04fe0-3aea-1069-a2d8-08002b30309d}, 2, 마운트할 폴더를 선택 하세요
	folder := RegExReplace(folder, "\\$")  ; Removes the trailing backslash, if present.
	if folder =
	{
		;MsgBox, Youd didn't select a folder
		return
	}
	else
	{
		;MsgBox, You selected folder "%folder%"
		mountpoint := lnk . "\" . "mount" . "1"
		while % FileExist(mountpoint)
			mountpoint := lnk . "\" . "mount" . A_Index
		RunWait, %comspec% /c mklink /d "%mountpoint%" "%folder%",,Hide
		if errorlevel
			GuiControl,, %hstatus%, 마운트 실패
		else
		{
			GuiControl,, %hstatus%, %mountpoint% 이름으로 %folder% 마운트 됨
			updatelog(mountpoint . " 이름으로 " . folder . " 폴더 마운트 됨")
		}
	}
}


read_caspar_info(text)
{
	static xml
	static info := object()
	xml := new ReadXml()
	xml.load(text)
	
	result  := xml.find_node_two("//channel/framerate")
	info.fps1_channel := result[1]
	info.fps2_channel := result[2]
	
	result  := xml.find_node_two("//channel/stage/layer/layer_1/foreground/file/time")
	info.time1_foreground := result[1]
	info.time2_foreground := result[2]
	result  := xml.find_node_two("//channel/stage/layer/layer_1/foreground/file/clip")
	info.time1_clip := result[1]
	info.time2_clip := result[2]

	result  := xml.find_node_two("//channel/stage/layer/layer_1/background/producer")
	info.producer_background := result[1]
	result  := xml.find_node_two("//channel/stage/layer/layer_1/background/file/name")
	info.filename_background := result[1]
	result  := xml.find_node_two("//channel/stage/layer/layer_1/background/file/path")
	info.filepath_background := result[1]
	
	result  := xml.find_node_two("//channel/stage/layer/layer_1/foreground/file/name")
	info.filename_foreground := result[1]
	result  := xml.find_node_two("//channel/stage/layer/layer_1/foreground/file/path")
	info.filepath_foreground := result[1]
	result  := xml.find_node_two("//channel/stage/layer/layer_1/foreground/file/streams/file/streams_0/fps")
	info.fps1_stream := result[1]
	info.fps2_stream := result[2]
	result  := xml.find_node_two("//channel/stage/layer/layer_1/foreground/loop")
	info.loop_foreground := result[1]
	result  := xml.find_node_two("//channel/stage/layer/layer_1/foreground/paused")
	info.paused_foreground := result[1]
	result  := xml.find_node_two("//channel/stage/layer/layer_1/foreground/producer")
	info.producer_foreground := result[1]
	
	return info
}



; Read XML class by sendust. 2019/7/4
; Example
;
;  xml := new ReadXml()
;  xml.load(text)
;  xml.find_node("//root/brench")
;  xml.find_node_two("//root/brench")    ----- result is array
;

class ReadXml
{
	static docxml
	__New()
	{
		this.docxml := ComObjCreate("MSXML2.DOMDocument.6.0")
		this.docxml.async := false
	}

	load(xml)
	{
		result := this.docxml.loadXML(xml)
		return result
	}

	find_node(text)
	{
		doctext := this.docxml.selectSingleNode(text)
		return doctext.text
	}

	find_node_two(text)
	{
		node := Object()
		doctext := this.docxml.selectNodes(text)
		node[1] := doctext.item(0).text
		node[2] := doctext.nextNode.text
		return node
	}

	__Delete()
	{
		this.docxml := ""
	}

}

