/*		
	SBS Player (single channel)
	Powered by CasparCG Engine
	Code by sendust
	Last Modified 2020/10/5

	2020/6/9 	Improve log routine (monitor log size before writing log)
	2020/6/10  	Enable SDI multi channel handling
						Improve  mpv playlist play (special character enabled)
						Improve background load (smooth clip load)
	2020/6/11 	Improve Try - catch statement  (print err object detail)
						Improve playlist play (stable play between repeative pause and play condition)
	2020/6/12	Improve mpv preview button behavior (enable, disable)
	2020/6/16   Improve [caspar.pbindex_next]  check logic (move from lvload to casparpbchk)
	2020/6/17   introduce RESUME command (play, listplay routine)
	2020/6/18   Improve PAUSE, PLAYLIST PLAY repeative action behavior
	2020/6/22   Improve prev, next by remote (Enable list view coloring)
				        change cut transition mix rate (1 -> 0)
	2020/6/23   Improve LV related logging (lvclick, prev, next)
						Improve amcp recv text logging
	2020/7/3 	remove unused variable  caspar.pbindex_old
						LV load related Log level up
	2020/7/6		check finish day
						Prepare for compiled version
	2020/7/7 	Disable preview-list button until mpv launched
	2020/7/9		add Goto while preview windows   (short cut key  - 'g')
						introduce caspar.preparenext variable
						reset caspar.loadbg_try flag on load subroutine	(enhance play / resume decision logic)
	2020/7/10	apply LV delete, move up, down restriction while playlist playing
	2020/7/15	Multiple file drag and drop -> add list automatically
	2020/7/16	Improve LV move, delete (pbindex follows LV changes)
						Add watchdog timer (Monitor caspar amcp response)
	2020/7/17	Improve watchdog routine
						Improve LV move
	2020/7/20 	Improve watch dog, LV move
	2020/7/21	add TC Preset button
	2020/7/23	Improve LV rename 'cancel'
	2020/7/24	Improve tctoframe, check binary files are exist before start
						Improve Engine termination process while GUI closing
	2020/7/28	Improve analysis_media (audio, picture)
	2020/7/29	Improve AMCP return check routine
	2020/8/3		Introduce caspar.frame_dissolve,   (user change dissolve frame in ini file)
	2020/8/14	Improve caspar launch routine
	2020/9/11	Change playlist DDL GUI size
	2020/9/29	Add playlist load confirm dialogue
	2020/10/5	Save playlist to logfile as text format
	
	
*/

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#WinActivateForce

SendMode Event
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, -1
#Include socket.ahk
#Include mediainfo.ahk
#include console_class_sendust.ahk
#Include LVA.ahk			; Coloring List view (Playlist)
#SingleInstance ignore
Menu, Tray, Icon, Shell32.dll, 138			; change Tray Icon

count_event := 0

ahk_exe = ahk
if A_IsCompiled
	ahk_exe = exe


title := "sendust multi channel player - " . get_casparchannel(A_ScriptName) . " -  2020/10/5"
finishday :=  20211231235959
title_remote := "Player" . get_casparchannel(A_ScriptFullPath) . " Remote by sendust"
binary_remote := A_ScriptDir . "\SBSPlayback_remote" . get_casparchannel(A_ScriptFullPath) . "." . ahk_exe
pid_remote := -1
;osc_reader := A_WorkingDir . "\read_osc_caspar_v22." . ahk_exe
osc_reader := A_ScriptDir . "\level_meter12." . ahk_exe					; new, 2 ch sdi, each 8 channel audio
osc_reader_title := "Caspar v2.2 OSC Monitor by sendust"

Gui, Margin, 10, 10
Gui, add, Picture, xm+5 ym+10 w340 h200 hwndhbitmap_mediainfo, player_bmp_base.bmp
Gui, add, GroupBox, xm ym w350 h210, Media Information
Gui, add, text, xp+10 yp+20  w330 h180  cWhite multi hwndhmediainfo BackgroundTrans

Gui, add, text, xm yp+205, IN
Gui, add, edit, xp+50 yp w100 h40 r1 limit12 hwndhcue_in vcue_in , 00:00:00.000
Gui, add, button, xp+120 yp w50 h20 hwndhreset  greset , RESET

;Gui, add, Checkbox, xp+100 yp hwndhchk_loop vchk_loop gchk_loop, LOOP
Gui, add, DDL, xp+70 yp w100 hwndhchk_loop vchk_loop gchk_loop choose1, NO LOOP|SINGLE CLIP|PLAYLIST

Gui, add, text, xm yp+30, OUT
Gui, add, edit, xp+50 yp w100 h40 r1 limit12 hwndhcue_out vcue_out 
Gui, add, button, xp+120 yp w50 h20 hwndhreset2  greset2, CLEAR

Gui, add, Checkbox, xp+70 yp hwndhchk_sdiwindow vchk_sdiwindow gsdi_window, SDI WINDOW
Gui, add, Checkbox, xp yp+20 hwndhchk_autoload vchk_autoload gautoload, AUTO LOAD

Gui, add, button, xm w80 h30 hwndhpreview gpreview, PVW-FILE
Gui, add, button, xp+90 w80 h30 hwndhpreviewsdi gpreviewsdi , PVW-SDI

Gui, add, button, xp+100 yp w40 h30 hwndhsetin gsendin, IN
Gui, add, button, xp+50 yp w40 h30 hwndhsetout gsendout, OUT
Gui, add, button, xp+60 yp w50 h30 hwndhjumpto gjumpto, JUMP

Gui, add, Slider, xm yp+40 w350 h20 AltSubmit vslide_seek gseek_bar
;Gui, add, Progress, xm yp+40 w350 h5 cblack, 100 ; Horizontal bar --------------------------------------------
Gui, add, Progress, xm+10 yp+20 w330 h5 hwndhpbposition cRed, 0 			; Clip Playback Position

Gui, add, button, xm yp+10 w100 h40 hwndhload gload, LOAD |◁`r`nPREROLL
Gui, add, button, xp+120  yp w100 h40 hwndhplay gplay, PLAY   ▷
Gui, add, button, xp+120  yp w100 h40 hwndhpause gpause, PAUSE   ∥

Gui, add, Progress, xm yp+42 w100 h5 cred hwndhloadled, 100
Gui, add, Progress, xp+120 yp w100 h5 cred hwndhplayled, 100
Gui, add, Progress, xp+120 yp w100 h5 cred hwndhpauseled, 100

Gui, add, text, xm yp+15 w350 h20 center  hwndhtext_tc , --/--
Gui, add, text, xm yp+30 w350 h20  center hwndhrem_tc , REM --:--:--

Gui, add, button, xm yp+40 w120 h30 hwndhopenmedia gopenmedia, MEDIA Folder
Gui, add, button, xp+140 yp w80 h30 hwndhmount gmount, MOUNT
Gui, add, button, xp+100 yp w100 h30 gaddlist hwndhaddlist, ADD ▶

; Gui, add, Text, xm yp+50, Monitor Audio Select
Gui, add, DDL, xm yp+50  w80 hwndhaudiomonl vaudiomonl choose1 gaudiomonsel, CH1|CH2|CH3|CH4|CH5|CH6|CH7|CH8|CH1+CH3
Gui, add, DDL, xp+90 w80 hwndhaudiomonr vaudiomonr choose2 gaudiomonsel, CH1|CH2|CH3|CH4|CH5|CH6|CH7|CH8|CH2+CH4
Gui, add, Checkbox, xp+120 yp hwndhchk_bgload vchk_bgload gdissolve, Load Background

Gui, add, Progress, xm+360 ym w5 h550, 100			; vertical bar -----------------------------------------------------

Gui, add, Text, xm+370 ym w200 h30 hwndhplist_duration, PL DUR 00:00:00.000
Gui, add, button, xp+280 yp-5 w120 h30 hwndhpreviewlist gpreviewlist, PVW-PLIST
Gui, add, ListView, xm+370 ym+30 w800 h410 hwndhlistview vVLV glvclick NoSortHdr NoSort ReadOnly -LV0x10, STATUS|TITLE|IN|OUT|DURATION|CLIP LIST
Gui, add, DDL, xm+390 yp+420 w75 hwndhplselect vplselect choose1, LIST1|LIST2|LIST3|LIST4|LIST5|LIST6|LIST7|LIST8|LIST9|sLISTA|sLISTB|sLISTC|sLISTD
Gui, add, button, xp+100 yp w60 h20 gplsave, SAVE
Gui, add, button, xp+100 yp w60 h20 gplload, LOAD
Gui, add, button, xp+100 yp w65 h20 glvrename, RENAME

Gui, add, button, xm+390 yp+30 w60 h30 glvdeletesingle, DELETE
Gui, add, button, xp+100 yp w60 h30 gmoveup, ▲
Gui, add, button, xp+100 yp w60 h30 gmovedown, ▼

Gui, add, button, xm+390 yp+40 w60 h30 ghelpbox , HELP
Gui, add, button, xp+100 yp w160 h30 glistplay, PLAYLIST PLAY
Gui, add, Progress, xp yp+32 w160 h5 cred hwndhlistplayled, 100

Gui, add, text, xp+200 yp-70 w50 h50 Right hwndhpbnumber, ##
Gui, add, Checkbox, xp-10 yp+50 w100 hwndhchk_dissolve vchk_dissolve gdissolve, DISSOLVE
Gui, add, Checkbox, xp yp+20 w100 hwndhchk_remote vchk_remote gremote, REMOTE

Gui, add, GroupBox, xp+105 yp-110 w100 h125 cRed, IN PRESET
Gui, add, Button, xp+10 yp+20 w80 h30 gtc_preset1 hwndhpreset1, 00:00:00.700
Gui, add, Button, xp yp+35 w80 h30 gtc_preset2 hwndhpreset2, 00:00:10.000
Gui, add, Button, xp yp+35 w80 h30 gtc_preset3 hwndhpreset3, 00:00:00.000


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
GuiControl, Font, %hplist_duration%

Gui, Font, cWhite
GuiControl, Font, %hmediainfo%
GuiControl,,%hmediainfo%, Media Property

GuiControl, disable, %hchk_sdiwindow%
GuiControl,, %hbitmap_mediainfo%, % getbmpfile(A_ScriptFullPath)

addressamcp := ["127.0.0.1", "5250"]
chk_autoload := 0

logfile := getlogfile(A_ScriptFullPath)
updatelog("------------------  Application Start -----------------------")

media := Object()
	media.fullpath := ""
	media.audio_format  := "mono-8"				; set default audio format (For media)
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
	caspar.pid := -1
	caspar.listplay := 0
	caspar.listload := 0
	caspar.pbindex := 0
	caspar.preindex := 0
	caspar.pbindex_max := 0
	caspar.timeremold  := 5184000			; 48 Hours in frame
	caspar.foregroundfileold := "---"			; apply any text
	caspar.transition := ""
	caspar.status := "PAUSE"
	caspar.preparenext := 3

preset := Object()
resources := Object()


buttoncontrol := object()
	buttoncontrol := [hsetin, hsetout, hpreview, hload, haddlist, hpreviewlast]		; disable these button while busy

info_caspar := Object()			; decoded value from caspar info command return
duration_plist := object()				; store playlist each duration (duration sum)

mi := object()
mi := new MediaInfo
mpvrun := Object()				; mpv console object
mpv_inout_file := Object()			; mpv file output (title, duration, in, out)
caspar_inout_file := Object()				; caspar file output (title, in, out, pb position ...)
	caspar_inout_file["path"] := "NONE"
	caspar_inout_file["duration"] := "NONE"
	caspar_inout_file["mark_in"] := 0
	caspar_inout_file["mark_out"] := 0
	caspar_inout_file["position_pb"] := 0

buttonled := object()
	buttonled := [hloadled, hplayled, hpauseled, hlistplayled]

for key, val in buttonled
	GuiControl, Hide, %val%				; hide all LED 

IniRead, temp, % getinifile(A_ScriptFullPath), caspar, caspar_fullpath
caspar.fullpath := temp
IniRead, temp, % getinifile(A_ScriptFullPath), caspar, caspar_mediapath
caspar.mediapath := temp
IniRead, temp, % getinifile(A_ScriptFullPath), caspar, character_out
caspar.character_out := temp
IniRead, temp, % getinifile(A_ScriptFullPath), caspar, port_tc
caspar.port_tc := temp
IniRead, temp, % getinifile(A_ScriptFullPath), caspar, html_tc
caspar.html_tc := temp
IniRead, temp, % getinifile(A_ScriptFullPath), caspar, grid_out
caspar.grid_out := temp
IniRead, temp, % getinifile(A_ScriptFullPath), caspar, clean_out, % get_casparchannel(A_ScriptFullPath)
caspar.chindex := temp
IniRead, temp, % getinifile(A_ScriptFullPath), caspar, frame_dissolve, 10
caspar.frame_dissolve := temp


IniRead, temp, % getinifile(A_ScriptFullPath), preset, preset1, 00:00:01.000
preset.preset1 := temp
IniRead, temp, % getinifile(A_ScriptFullPath), preset, preset2, 00:00:02.000
preset.preset2 := temp
IniRead, temp, % getinifile(A_ScriptFullPath), preset, preset3, 00:00:03.000
preset.preset3 := temp

GuiControl,, %hpreset1%, % preset.preset1
GuiControl,, %hpreset2%, % preset.preset2
GuiControl,, %hpreset3%, % preset.preset3

IniRead, temp,  % getinifile(A_ScriptFullPath), caspar, shared_list, c:\temp
caspar.shared_list := temp


; update 2020/3/19 --------------- tc osd display
tc_udp := Object()
tc_udp := new SocketUDP()
temp := caspar.port_tc
tc_udp.connect(["127.0.0.1", caspar.port_tc])
tc_osd := object()
tc_osd.line1 :=""
tc_osd.line2 :=""
; update 2020/3/19 --------------- tc osd display


watchdog := object()
watchdog.tick_current := A_TickCount
watchdog.count := 3					; invalid response count limit

resources.push(caspar.fullpath)
resources.push(mpv.fullpath)
resources.push(A_ScriptDir . "\mediainfo.dll")
resources.push(A_ScriptDir . "\mark_inout.lua")
resources.push(A_ScriptDir . "\mark_inout_file.lua")
resources.push(A_ScriptDir . "\level_meter12." . ahk_exe)
resources.push(A_ScriptDir . "\sbsplayback_remote" . get_casparchannel(A_ScriptFullPath) . "." . ahk_exe)
resources.push(A_ScriptDir . "\log")
resources.push(A_ScriptDir . "\helpfile.txt")

if check_exist(resources)			; Check if there is all necessary files
{
	MsgBox,, ATTENTION, % check_exist(resources) . " File(folder) is not exist. Terminate Program~~" , 4
	updatelog(check_exist(resources) . "file(folder) is not exist")
	ExitApp
}

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

Gui, Submit, NoHide

initcaspar(caspar)					; launch caspar engine

SetTimer, initcaspar_stage2, -2000		; connect tcp and enable characger out
gosub, audiomonsel		; get audio monitor selection
gosub, dissolve				; get dissolve and load bg value

LVA_ListViewAdd("VLV", "")						; Enable playlist coloring, added 2019/10/6
OnMessage("0x4E", "LVA_OnNotify")			; Enable playlist coloring, added 2019/10/6


Run, %osc_reader%

checkfinishday(finishday)

return


check_exist(lists)
{
	for key, val in lists
	{
		if !FileExist(val)
			return val
	}
	return 0
}

seek_bar:																	; added 2019/9/30
if ((A_GuiEvent = 5) or (A_GuiEvent = 4))			; drag slide bar or drag and release mouse button
{
	GuiControlGet, slide_seek
	caspar.jumpto := Floor(caspar.in + (caspar.out - caspar.in) * slide_seek / 100.3)		; / 101 for safe end search
	ToolTip, % frametotc(caspar.jumpto / 2)				; interlaced video ( /2 req..)
	SetTimer, removetooltip, -1000
}

return


initcaspar_stage2:

SetTimer, watchdog_chk, Off
casparamcp := new SocketTCP()		; Establish tcp connection with Caspar CG Server

caspar.listplay := 0

Loop, 20							; Try to connect caspar CG server 
{
	updatelog("Try to connect caspar engine " . A_Index . " Times")
	try casparamcp.Connect(addressamcp)
	catch, err
		updatelog("--" . A_LineNumber . "--" . printobjectlist(err))
	errormessage := err.Message
	if InStr(errormessage, "error")
	{
		Sleep, 300
		ToolTip, %A_Index% - %errormessage%
		continue
	}
	else
	{
		ToolTip
		break
	}
}
casparamcp.onRecv := Func("OnAMCP_TCPRecv")  		; Finish loading casparCG

GuiControl,, %hstatus%, % "Caspar CG launched with PID " . caspar.pid
updatelog("Caspar CG launched with PID " . caspar.pid)

caspar.loop := looparray[chk_loop]

try					; update 2020/3/19 --------------------------------------------------------------------
{
	casparamcp.sendText("Log Level warning`r`n")				; set log level to warning
	Sleep, 200
	casparamcp.sendText("remove " . caspar.grid_out . " screen`r`n")				; Remove screen consumer
	Sleep, 200
}
catch, err
	updatelog("--" . A_LineNumber . "--" . printobjectlist(err))

if caspar.character_out
{
	try
	{
		casparamcp.sendText("load " . caspar.character_out . "-1 route://" .  caspar.chindex . "-1`r`n")				; duplicate character out channel with master channel
		Sleep, 150
		casparamcp.sendText("play " . caspar.character_out . "-1 route://" . caspar.chindex . "-1`r`n")				; synchronize play with master channel
		Sleep, 150
		casparamcp.sendText("play " . caspar.character_out . "-2 [html] " . caspar.html_tc . "`r`n")				; load html tc
		Sleep, 150
		;casparamcp.sendText("play " . caspar.character_out . "-2 `r`n")				; Play html tc
	}
	catch, err
		updatelog("--" . A_LineNumber . "--" . printobjectlist(err))
}    				; update 2020/3/19 --------------------------------------------------------------------

SetTimer, watchdog_chk, 3000
SetTimer, casparpbchk, -1000
return


watchdog_chk:
if (A_TickCount - watchdog.tick_amcp) > 2000			; amcp is not response within specified periods
{
	watchdog.count -= 1
	updatelog("Caspar engine is not response  /_/_/_/_/_/_/_/_/_/_/_/_/_/_/  [" . watchdog.count . "]")
	GuiControl,, %hstatus%, % "Caspar Engine is not response ///////////////// [" . watchdog.count . "]"
}
else
	watchdog.count := 3

if ((!watchdog.count) and (get_casparchannel(A_ScriptFullPath) = 1))			; restart caspar (force terminate)
{
	watchdog.count := 3
	updatelog("Try to  restart Engine /_/_/_/_/_/_/_/_/_/_/_/_/_/")
	GuiControl,, %hstatus%, Try to restart Engine ///////////////////
	ControlSend,,q{enter}, % caspar.title
	try
		RunWait, taskkill /f /im casparcg.exe,, Hide
	catch, e
		updatelog("--" . A_LineNumber . "--" . printobjectlist(e))
	Sleep, 1000											; wait until taskkill complete	(mandatory line !!!! 2020/7/17)
	WinKill, % caspar.title,, 2					; force to quit casparcg
	initcaspar(caspar)								; launch caspar engine again
	SetTimer, initcaspar_stage2, -2000
}

return


remote:
GuiControlGet, chk_remote

if chk_remote
{
	WinClose, %title_remote%
	remoteudp := new SocketUDP()
	remoteudp.Bind(get_remote_address())
	remoteudp.onRecv := Func("OnRemoteRecv")
	Run, %binary_remote% 1 , %A_WorkingDir%, Minimize, pid_remote
}
else
{
	remoteudp.onRecv := ""
	remoteudp.Disconnect()
	remoteudp := ""
	WinClose, %title_remote%
	pid_remote := -1
}

return


get_remote_address()
{
	IniRead, address, % getinifile(A_ScriptFullPath), remote, address, 127.0.0.1
	IniRead, port, % getinifile(A_ScriptFullPath), remote, port, 8989
	address_array := Object()
	address_array.push(address)
	address_array.push(port)
	return address_array
}

OnRemoteRecv(this)
{
	global caspar, media
	buffer := ""
	length := this.Recv(buffer)
	command_recv := StrGet(&buffer, length, "cp437")
	updatelog("Remote command [" . command_recv . "] received")
	
	if (command_recv = "__LOAD__")
	{
		SetTimer, load, -1
	}
	
	if (command_recv = "__NEXT__")
	{
		if (caspar.listplay)
		{
			updatelogall("Cannot jump to next !! Please release playlist play !!")
			settimer, removetooltip, -1000
			return
		}
		if (caspar.pbindex < LV_GetCount() )	
		{
			caspar.pbindex += 1
			updatelog("Load LV clip with line number " . caspar.pbindex)
			updatepropertytextlv(caspar, media)
			caspar.listload := 1				; update 2020/6/22
				SetTimer, load, -1
		}
	}
	
	if (command_recv = "__PREV__")				; add prev command 2020/6/16
	{
		if (caspar.listplay)
		{
			updatelogall("Cannot jump to previous !! Please release playlist play !!")
			settimer, removetooltip, -1000
			return
		}
		if (caspar.pbindex > 1 )	
		{
			caspar.pbindex -= 1
			updatelog("Load LV clip with line number " . caspar.pbindex)
			updatepropertytextlv(caspar, media)
			caspar.listload := 1				; update 2020/6/22
				SetTimer, load, -1
		}
	}
	
	
	if (command_recv = "__PLAY__")
		SetTimer, play, -1
	
	if (command_recv = "__PLAYL_")
		SetTimer, listplay, -1
	
	if (command_recv = "__PAUSE_")
		SetTimer, pause, -1
}


jumpto:
updatelog("Jump to Button Pressed")
if !caspar.out					; out point is zero  (invalid lv data is loaded when last playlist play)
{
	updatelog("Invalid Mark out point")
	return
}

GuiControlGet, slide_seek
caspar.jumpto := Floor(caspar.in + (caspar.out - caspar.in) * slide_seek / 100.3)		; / 101 for safe end search

casparamcp.sendText("call " . caspar.chindex . "-1 seek " . caspar.jumpto . "`r`n")
updatelog("call " . caspar.chindex . "-1 seek " . caspar.jumpto)
caspar.timeremold := 999999999
SetTimer, casparpbchk, -600								; added 2019/8/19   prevent unwanted pb_index incresing

return


dissolve:
GuiControlGet, chk_dissolve
GuiControlGet, chk_bgload

if chk_dissolve
	caspar.transition := " MIX " .  caspar.frame_dissolve . "  "			; changed 2020/8/3
else
	caspar.transition := " MIX 0 "				; changed from 1 to 0  (2020/6/22)
printobjectlist(caspar)
return


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
		;casparamcp.sendText("set 2 mode NTSC`r`n")			; set channel_grid window format
		casparamcp.sendText("mixer " .  caspar.grid_out . " grid 2`r`n")			; window consumer 3 -> make 2x2 multiview
		Sleep, 300
		casparamcp.sendText("channel_grid`r`n")			; set channel_grid window format
	}
	catch, err
		updatelog("--" . A_LineNumber . "--" . printobjectlist(err))
	
	updatelog("send Channel grid command")
	WinWait, Channel Grid,, 5
	WinActivate, Channel Grid
	updatelog("Wait channel grid window")
	WinWaitActive, Channel Grid,, 5
	WinMove, Channel Grid,, 10, 10, 736, 518
	WinSet, Style, -0x20000, Channel Grid Window					; remove minimize button
	WinSet, Style, -0x30000, Channel Grid Window					; remove maximize button
	updatelog("Complete Channel grid window move, resize")
}


return


autoload:
GuiControlGet, chk_autoload
updatelog("AUTO LOAD " . chk_autoload)
return


casparpbchk:

;FileAppend, % caspar.in . "  " . caspar.out . "`r`n", *
xmlfile := SubStr(tcptext, InStr(tcptext, "<?xml"))			; Find xml header
if (SubStr(xmlfile, 1, 5) = "<?xml")				; there is valid xml return text		improve 2020/6/12 (changed, string length detection -> find xml header)
{
	info_caspar := read_caspar_info(xmlfile)
	;showobjectlist(info_caspar)
	caspar.timerem := info_caspar.time2_clip + info_caspar.time1_clip - info_caspar.time1_foreground
	caspar.foregroundfile := info_caspar.filename_foreground
	caspar.backgroundfile := info_caspar.filename_background
	caspar.nb_times  := info_caspar.time2_clip
	
	caspar_inout_file["position_pb"] := info_caspar.time1_foreground
	caspar_inout_file["duration"] := info_caspar.time2_foreground
	if (caspar.timeremold = caspar.timerem)						; update 2020/3/19 for osd character status report
	{
		caspar_inout_file["paused_foreground"] := 1
		caspar.status := "PAUSE"
	}
	else
	{
		caspar_inout_file["paused_foreground"] := 0
		caspar.status := "PLAY"
	}
	/*
	time1_clip ; seek position (at load)
	time2_clip ; duration (at load)
	
	time1_foreground ; current pb position
	time2_foreground ; file duration
    */	

	if (caspar.foregroundfile <> caspar.foregroundfileold)				; There is foreground file name change
		WinSetTitle, ahk_id %hmygui%, , % title . "  --  " . caspar.foregroundfile

	caspar.foregroundfileold := caspar.foregroundfile
	
	;if (caspar.listplay and (caspar.timerem > caspar.timeremold) and caspar.timerem) 	; next clip load foreground, update media property tex
	if (caspar.loadbg_try and (caspar.timerem > caspar.timeremold) and caspar.timerem) 	; next clip load foreground, update media property text, changed 2020/6/18
	{
		updatelog("increse pbindex --------- condition is ")
		updatelog("--" . A_LineNumber . "--" . printobjectlist(caspar))
		caspar.pbindex := caspar.pbindex_next
		lv_color_row(caspar.pbindex)								; apply LV row coloring
		caspar.pbindex_next += 1									; increase pbindex_next
		caspar.loadbg_try := 0
		if (mpv.pid < 0)
			updatepropertytextlv(caspar, media)							; update listplay information if there is no MPV Editing
		;GuiControl,, %hpbnumber%,  % caspar.pbindex
	}
	

	caspar.pbindex_next := caspar.pbindex + 1				;  move to here (2020/6/16)
	if (caspar.listplay and (caspar.pbindex = caspar.pbindex_max) and (chk_loop = "PLAYLIST"))		; PLAYLSIT LOOP CASE, Last clip playing, load first clip
		caspar.pbindex_next := 1
	
	
	; update 2020/3/19  osd display, GUI time code display code update -----------------------------------------------------------------------------------------------------
	tc_osd.line1 := "[" . caspar.status . "] " . secondtotc_drop(info_caspar.time1_foreground - info_caspar.time1_clip) . "/" .  secondtotc_drop(info_caspar.time2_clip)
	tc_osd.line2 := "REM " . secondtotc_drop(caspar.timerem)
	if (caspar.listplay and (caspar.pbindex < caspar.pbindex_max))
		tc_osd.line2 := "REM " . secondtotc_drop(caspar.timerem) . "/" . secondtotc_drop(caspar.timerem + duration_plist[caspar.pbindex+1])		

	/*			; detailed status report
	if (caspar.character_out)
		tc_udp.sendtext(tc_osd.line1 . "<br>" . tc_osd.line2)
	*/
	
	if (caspar.character_out)		; Very simple status report (TS-6 request)
		tc_udp.sendtext(secondtotc_drop(info_caspar.time1_foreground - info_caspar.time1_clip) )
	
	;ToolTip, % caspar.pbindex . "  " . caspar.timerem . "/" . caspar.timeremold  . "  -  " . caspar.foregroundfile . "   -  " . caspar.backgroundfile
	GuiControl,, %htext_tc%, % tc_osd.line1
	GuiControl,, %hrem_tc%, % tc_osd.line2
	GuiControl,, %hpbposition%, % 100 - ((caspar.timerem / caspar.nb_times) * 100)
	
	; check if there is valid caspar.timerem   2020/6/11 (there is  caspar.timerem is null case)
	if (caspar.listplay and (caspar.timerem < caspar.preparenext) and !caspar.loadbg_try and (caspar.pbposition <= caspar.pbindex_max) and caspar.timerem)			; current play is listplay and remaining time is less than 6
	{
		lvdata := lv_getall(caspar.pbindex_next)
		if (lvdata.title = "=== PAUSE ===")					; Next line is pause
		{
			caspar.listplay := 0
			GuiControl, +cBlue, %hlistplayled%
			GuiControl,, %hstatus%, Next Line is Playlist Pause
			updatelog("Next line is Pause, index is " . caspar.pbindex_next)
		}
		else																			; Next line is contains normal clip information (in, out, dur, clip name)
		{
			updatelog("`r`n -------------------  Load LV clip  ---------------------------")
			updatelog("--" . A_LineNumber . "--" . printobjectlist(caspar))
			;updatelog(printobjectlist(info_caspar))
			loadlvclip(caspar, lvdata)				
			caspar.loadbg_try := 1
		}
	}
	if (caspar.timerem)			; check if caspar.timerem is not null
		caspar.timeremold := caspar.timerem
}

	casparamcp.sendText("info " . caspar.chindex . "-1`r`n")


if ((caspar.pbindex = caspar.pbindex_max) and (caspar.timerem < 0.1) and caspar.listplay and (chk_loop != "PLAYLIST"))		; pbindex reach LV count and no remaing frame -- Finish listplay
{
	caspar.listplay := 0
	updatelog("Finish Playlist Play")
	GuiControl, +cBlue, %hlistplayled%
	GuiControl,, %hstatus%, Finish Playlist Play
}

if (caspar.timerem < 0.1 and !caspar.listplay)				; Change Playled to Blue
	GuiControl, +cBlue, %hplayled%
else
	GuiControl, +cRed, %hplayled%

GuiControl,, %hpbnumber%, % caspar.pbindex	

;SetTimer, casparpbchk, -50			; before 2020/6/18 
SetTimer, casparpbchk, -100			; after 2020/6/19

return

lv_color_row(nbr)
{
	global VLV
	Loop, % LV_GetCount()
		LVA_SetCell("VLV", A_Index, 0, "0xFFFFFF")						; Initialize playlist color
	LVA_SetCell("VLV", nbr, 0, "0x56B2C4")			; Update Single playlist color
	LVA_Refresh("VLV")	
	LV_Modify(nbr, "-Select")

}

lv_color_row_reset()
{
	global VLV
	Loop, % LV_GetCount()
	{
		LVA_SetCell("VLV", A_Index, 0, "0xFFFFFF")						; Initialize playlist color
		LV_Modify(A_Index, "-Select")
	}
	LVA_Refresh("VLV")	
}

loadlvclip(byref caspar, byref lvdata)
{
	global hstatus, casparamcp
	caspar.in := tctoframe_drop(lvdata.in) * 2			; x2  for interlaced video
	caspar.out := tctoframe_drop(lvdata.out) * 2  	; x2  for interlaced video
	caspar.duration := "LENGTH " . (caspar.out - caspar.in)
	updatelog("LV Clip duration is " . caspar.duration)
	
	text_to_send := "loadbg " . caspar.chindex . "-1 """ . lvdata.clip . """ SEEK " . caspar.in . " " . caspar.duration .  " " . caspar.transition . " auto`r`n"	
	casparamcp.sendText(text_to_send)		; next clip load background
	updatelog("Playlist loading index is  [" . caspar.pbindex . "]")
	updatelog("[loadlvclip]   " . text_to_send)
	GuiControl,, %hstatus%,% "LV Clip loaded -- " . lvdata.clip	. "  /  " . caspar.in . "  /  " . caspar.duration
}




helpbox:

Run, %osc_reader%
FileRead, helpfile, helpfile.txt
MsgBox,,Help Information, %helpfile%
return


clearlv:
LV_Delete()
duration_plist := get_plist_duration()		; update playlist duration array
return



splitcasparpath(casparmedia)
{
	temp := StrSplit(casparmedia, "/")
	return temp[temp.MaxIndex()]				; return Media name only (Without path name)
}


addlist:
updatelog("Add list Button Pressed")
if !media.fullpath
	return
Gui, Submit, NoHide

caspar.medianame := winpathtocaspar(media.fullpath, caspar.mediapath)
lvdata.status := LV_GetCount()+1
lvdata.clip := caspar.medianame
lvdata.in := cue_in
lvdata.out := cue_out

if (tctosecond(cue_in, 29.97) >= tctosecond(cue_out, 29.97))			; Mark out point is prior to Mark in point
{
	lvdata.out := secondtotc(media.duration)
	MsgBox,, Attention, Out 지점 오류. 클립 끝까지 확장합니다, 1
}

lvdata.duration := get_tc_duration(cue_in, cue_out)

lvdata.title := splitcasparpath(caspar.medianame)

lv_addall(lvdata)
LV_ModifyCol(, AutoHdr)
updatelogall("Adding -- [" . lvdata.status . " - " . lvdata.clip  . " - " . lvdata.in . " - " . lvdata.out . "]" )
SetTimer, removetooltip, -1000

duration_plist := get_plist_duration()		; update playlist duration array
if caspar.listplay
	updatepropertytextlv(caspar, media)										; Restore playlist play information added 2019/8/21
caspar.pbindex_max := LV_GetCount()

return

get_tc_duration(a, b)
{
	duration := tctosecond(b) - tctosecond(a)
	return secondtotc(duration)
}


get_plist_duration()
{
	global hplist_duration
	mylist := Object()
	mylist_new := Object()
	listdata := Object()
	Loop, % LV_GetCount()
	{
		listdata := lv_getall(A_Index)
		mylist[A_Index] := tctosecond(listdata.duration)
	}
	maxindex := mylist.MaxIndex()
	
	mylist_new[maxindex] := mylist[maxindex]
	
	Loop, % maxindex - 1
		mylist_new[maxindex - A_Index] := mylist[maxindex - A_Index] + mylist_new[maxindex - A_Index +1]
	show_duration := "PL DUR " . secondtotc(mylist_new[1])
	GuiControl,, %hplist_duration%, %show_duration%		; show total playlist duration
	return mylist_new
}


lvdeletesingle:
if !LV_GetNext(0)
	return

/*
if (caspar.listplay and (row <= caspar.pbindex ))
{
	updatelogall("Cannot delete while playlist playing  /selected row = " . row . "  / Current play index is  " . caspar.pbindex)
	SetTimer, removetooltip, -1000
	return
}
*/

Loop, % LV_GetCount("S")
{
	row := LV_GetNext(0)
	LV_Delete(row)
	renumber_pl()

	if (row = caspar.pbindex)				; delete current pbindex row
	{
		updatelog("Delete current playing item    -  lv number is " . row)
		lv_color_row_reset()
	}
	
	if (row < caspar.pbindex )				; deleted row changes caspar pbindex
	{
		caspar.pbindex -= 1
		updatelog("Change caspar pbindex, new index is " . caspar.pbindex)
		lv_color_row(caspar.pbindex)
		updatepropertytextlv(caspar, media)
	}

	updatelog("Delete single row " . row)

}

duration_plist := get_plist_duration()		; update playlist duration array
caspar.pbindex_max := LV_GetCount()

return


lvrename:
if !LV_GetNext(0)
	return
row := LV_GetNext(0)
lvdata := lv_getall(row)
lvdata.title := get_rename(lvdata.title)
lv_modifyall(row, lvdata)
LV_ModifyCol()
updatelog("Rename Playlist  number [" . row . "]    with new title   // " . lvdata.title)
return


get_rename(title_old)
{
InputBox, outputvar, Input New title, Please type new title, , , , , , , , %title_old%
if ErrorLevel
    return	title_old
return outputvar
}



moveup:
Critical
if LV_GetNext(0) < 2
	return
row := LV_GetNext(0)
if !row
	return

/*
if (caspar.listplay)
	if (row <= caspar.pbindex + 1)
	{
		updatelogall("Cannot move up prior playback index / selected row = " . row . " / playback index is " . caspar.pbindex)
		SetTimer, removetooltip, -1000
		return
	}
*/

updatelog("LV move up / selected row number " . row)
lvdata := lv_getall(row - 1)
lv_modifyall(row - 1, lv_getall(row))
lv_modifyall(row, lvdata)
LV_Modify(row, "-Select")
LV_Modify(row-1, "Select")
LV_ModifyCol()
duration_plist := get_plist_duration()		; update playlist duration array
renumber_pl()

if (row = caspar.pbindex + 1)					; selected row moves caspar pbindex
{
	caspar.pbindex += 1
	lv_color_row(caspar.pbindex)
	updatepropertytextlv(caspar, media)
	return
}


if (row = caspar.pbindex)
{
	caspar.pbindex -= 1
	lv_color_row(caspar.pbindex)
	LV_Modify(row, "-Select")
	LV_Modify(row-1, "Select")
	updatepropertytextlv(caspar, media)	
}


return

renumber_pl()
{
	lvdata := Object()
	Loop, % LV_GetCount()
	{
		lvdata := lv_getall(A_Index)
		lvdata.status := A_Index
		lv_modifyall(A_Index, lvdata)
	}
}


movedown:
Critical
if LV_GetNext(0) >= LV_GetCount()
	return
row := LV_GetNext(0)

if !row
	return

/*
if (caspar.listplay)
	if (row <= caspar.pbindex)
	{
		updatelogall("Cannot move down prior playback index  / selected row = " . row . " / playback index is " . caspar.pbindex)
		SetTimer, removetooltip, -1000
		return
	}
*/

updatelog("LV move down / selected row number " . row)
lvdata := lv_getall(row)
lv_modifyall(row, lv_getall(row + 1))
lv_modifyall(row + 1, lvdata)
LV_Modify(row+1, "Select")
LV_Modify(row, "-Select")
LV_ModifyCol()
duration_plist := get_plist_duration()		; update playlist duration array
renumber_pl()


if (row = caspar.pbindex - 1)				; selected row moves caspar pbindex
{
	caspar.pbindex -= 1
	lv_color_row(caspar.pbindex)
	updatepropertytextlv(caspar, media)
	return
}

if (row = caspar.pbindex)
{
	caspar.pbindex += 1
	lv_color_row(caspar.pbindex)
	LV_Modify(row, "-Select")
	LV_Modify(row+1, "Select")
	updatepropertytextlv(caspar, media)	
}


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
		;caspar.preindex := LV_GetNext(0)
		updatelog("Load LV clip by Click or Drag,  LV line number " . caspar.pbindex)
		if chk_pause(caspar.preindex)
		{
			GuiControl,, %hstatus%, Cannot load Pause Line, try another Line
			return												; LV Pause row is selected
		}
		;caspar.pbindex_next := caspar.pbindex + 1				; disabled 2020/6/16			--> this live moves to casparpbchk routine
		;if caspar.pbindex_next > LV_GetCount()						; pbindex_next variable added 2019/7/10
		;	caspar.pbindex_next := 1
		; FileAppend, % caspar.pbindex "  " caspar.pbindex_next "   ", *
	}
	updatepropertytextlv(caspar, media)
	caspar.listload := 1			; added 2019/10/6
	if chk_autoload
		SetTimer, load, -1
	;ToolTip % caspar.pbindex
}

return


chk_pause(pbindex)
{
	data := Object()
	data := lv_getall(pbindex)
	if (data.title = "=== PAUSE ===")
		return 1								; PAUSE title is selected
	else
		return 0
}




updatepropertytextlv(byref caspar, byref media)
{
	global hcue_in, hcue_out, hmediainfo, hstatus, hpbnumber
	lvdata := lv_getall(caspar.pbindex)
	updatelog("Get Media from LV list index " . caspar.pbindex)
	updatelog("--" . A_LineNumber . "--" . printobjectlist(lvdata))
	caspar.timeremold  := 5184000			; prevent unwanted pbindex increasing during list play
	caspar.medianame := lvdata.clip
	GuiControl, text, %hcue_in%, % lvdata.in
	GuiControl, text, %hcue_out%, % lvdata.out
	media.fullpath := ""
	caspartowinpath(caspar, media)		; find real path by caspar media name
	GuiControl,,%hmediainfo%, % "Load Clip --------------`r`n`r`n" . "[" . lvdata.status . "] - " . lvdata.title . "`r`n`r`n" . lvdata.clip . "`r`n`r`n" . lvdata.in . " - " . lvdata.out . "`r`n`r`nDUR [" . lvdata.duration . "]"
	GuiControl,,%hstatus%, % "Update Media Property -- " . media.fullpath
}




caspartowinpath(byref caspar, byref media)
{
	tempfile := caspar.mediapath . caspar.medianame
	tempfile := StrReplace(tempfile, "/", "\")
	path := caspar.mediapath
	Loop, Files, %path%\*.*, R
	{
		SplitPath, A_LoopFileFullPath, outfilename, outdir, outextension, outnamenoext, outdrive
		if (outextension = "srt")				; skip srt extension
			continue
		name = %outdir%\%outnamenoext%
		if (name = tempfile)
		{
			media.fullpath := A_LoopFileFullPath
			media.filename := outfilname
		}
	}
}


list_to_winpath(medianame)
{
	global caspar
	tempfile := caspar.mediapath . medianame
	tempfile := StrReplace(tempfile, "/", "\")
	path := caspar.mediapath
	Loop, Files, %path%\*.*, R
	{
		SplitPath, A_LoopFileFullPath, outfilename, outdir, outextension, outnamenoext, outdrive
		name = %outdir%\%outnamenoext%
		if (name = tempfile)
			return  A_LoopFileFullPath
	}
	return 
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
	global hstatus, tcptext, watchdog
	tcptext := this.RecvText()
	text_short := SubStr(tcptext,1,40)  			; check  first 40 character
	if !InStr(text_short, "INFO")
	{
		GuiControl,, %hstatus%, %text_short%
		;updatelog(text_short)	
		updatelog(tcptext)	
	}
	watchdog.tick_amcp := A_TickCount
}


initcaspar(ByRef cas)
{
	fullpath := cas.fullpath
	title := cas.title
	if !WinExist(title)
	{
		SplitPath, fullpath, outfilename, outdir, outextension, outnamenoext, outdrive
		run, "%fullpath%", %outdir%, Minimize UseErrorLevel, pid
		updatelog("run engine with parameter " . fullpath . " `r`n      working dir is " . outdir . "`r`n     Error Level is " . ErrorLevel)
		WinWait, ahk_pid %pid%,, 3
		updatelog("Engine pid is " . pid)
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
temp_plist := ""
updatelog("Save playlist  //  Playlist file is     " . getfile_plist(plselect))
FileDelete, % getfile_plist(plselect)
Loop, % LV_GetCount()
{
	lvdata := lv_getall(A_Index)
	FileAppend, % lvdata.status . "|" . lvdata.title . "|" . lvdata.in . "|" . lvdata.out .  "|" . lvdata.duration . "|" .  lvdata.clip  "`r`n", % getfile_plist(plselect)
	temp_plist .= lvdata.status . A_Tab . lvdata.title . A_Tab . lvdata.in . A_Tab . lvdata.out .  A_Tab . lvdata.duration . A_Tab .  lvdata.clip  "`r`n"
	ToolTip, % A_Index . " Line saved ~~"
	Sleep, 10
}
updatelog("Save playlist with ----------------`r`n" . temp_plist)
SetTimer, removetooltip, -1000
GuiControl,, %hstatus%,  SAVE PLAYLIST
return


getfile_plist(list)
{
	global caspar
	file_name := A_WorkingDir . "\PLIST\" . list . ".txt"
	if (SubStr(list, 1, 1) = "s")
		file_name := caspar.shared_list . "\" . list . ".txt"
	;updatelog("Playlist file is     " . file_name)
	return file_name
}


plload:
Gui, Submit, NoHide
MsgBox, 4, ATTENTION, 정말로 플레이 리스트를 불러 올까요 ?				; added 2020/9/29
IfMsgBox, No
	return
LV_Delete()
temp_plist := ""
updatelog("Load playlist  //  Playlist file is     " . getfile_plist(plselect))
Loop, Read, % getfile_plist(plselect)
{
	readarray := StrSplit(A_LoopReadLine, "|")
	lvdata.status := A_Index
	lvdata.title := readarray[2]
	lvdata.in := readarray[3]
	lvdata.out := readarray[4]
	lvdata.duration := readarray[5]
	lvdata.clip := readarray[6]
	lv_addall(lvdata)
	temp_plist .= lvdata.status . A_Tab . lvdata.title . A_Tab . lvdata.in . A_Tab . lvdata.out .  A_Tab . lvdata.duration . A_Tab .  lvdata.clip  "`r`n"
}
LV_ModifyCol()
lv_color_row_reset()							; add 2020/7/16 (Reset lv coloring)
duration_plist := get_plist_duration()		; update playlist duration array
caspar.pbindex_max := LV_GetCount()
GuiControl,, %hstatus%,  LOAD PLAYLIST
updatelog("Load playlist with ----------------`r`n" . temp_plist)
return


preview:
GuiControl, Disable, %hpreview%					; disable preview button
GuiControlGet, cue_in
GuiControlGet, cue_out

mpv.script := A_WorkingDir . "\mark_inout_file.lua"
caspar_inout_file["load_me"] := "false"
writeobjectlist(caspar_inout_file, A_Temp . "\caspar_inout.txt")

runpreview(media, mpv)
GuiControl,, %hstatus%, % "Preview MPV Launched with PID " . mpv.pid

SetTimer, mpvchk_once, -100
return

mpvchk_once:
Process, Exist, % mpv.pid
If !ErrorLevel			; There is no mpv console process, there is problem
{
	GuiControl,, %hstatus%, % "Error Opening Preview window, PID " . mpv.pid
	GuiControl, Enable, %hpreview%
	GuiControl, Enable, %hpreviewsdi%
	GuiControl, Enable, %hpreviewlist%
	mpv.pid := -1
}
else
	GuiControl,, %hstatus%, % "Preparing for Preview window, PID " . mpv.pid

mpv.tickcount := A_TickCount
SetTimer, mpvchk, -100				; read console coutput and clean them
SetTimer, mpvchk_title, -50			; check if mpv run fails
return



mpvchk_title:

Process, Exist, % mpv.pid
If !ErrorLevel			; There is no mpv console process, there is problem
{
	GuiControl,, %hstatus%, % "Error Opening Preview window, PID " . mpv.pid
	mpv.pid := -1
	SetTimer, mpvchk_title, off
	return
}

if WinExist("Preview play...")
{
	WinSet, Style, -0x20000, Preview play...					; remove minimize button
	WinSet, Style, -0x30000, Preview play...					; remove maximize button
	WinActivate, Preview play...
	GuiControl,, %hstatus%, % "Preview window Opened "  . (A_TickCount - mpv.tickcount) / 1000 . " sec"
}
else
{
	GuiControl,, %hstatus%, % "Preparing for Preview window  --- " . (A_TickCount - mpv.tickcount) / 1000 . " sec"
	SetTimer, mpvchk_title, -50
}

if (((A_TickCount - mpv.tickcount) / 1000) > 60)					; no more waiting preview window (30 second)
{
	SetTimer, mpvchk_title, off
	GuiControl,, %hstatus%, % "Preparing for Preview window  --- Please wait more time"
}
return



previewsdi:
GuiControl, Disable, %hpreviewsdi%					; disable preview-sdi button
;caspar_inout_file["mark_in"] := tctosecond(cue_in)
;caspar_inout_file["mark_out"] := tctosecond(cue_out)

if (media.fullpath != info_caspar.filepath_foreground)			; restore media.fullpath from caspar foreground playback file
{
	GuiControl,, %hstatus%, There is difference between caspar pb clip and media loaded clip
	updatelog(" There is difference between caspar pb clip and media loaded clip, analysing media - " . info_caspar.filepath_foreground)
	media.fullpath := info_caspar.filepath_foreground
	analyse_media(media, mi)
	updatepropertytext(hmediainfo, media)
}



caspar_inout_file["mark_in"] := info_caspar.time1_clip				; get mark in from sdi channel
caspar_inout_file["mark_out"] := info_caspar.time1_clip + info_caspar.time2_clip		; get mark out from sdi channel
caspar_inout_file["path"] := info_caspar.filepath_foreground
caspar_inout_file["load_me"] := "true"


writeobjectlist(caspar_inout_file, A_Temp . "\caspar_inout.txt")
;showobjectlist(caspar_inout_file)

GuiControl,, %hcue_in%, % secondtotc( info_caspar.time1_clip)							; restore mark in, out from caspar loaded clip information
GuiControl,, %hcue_out%, % secondtotc( info_caspar.time1_clip + info_caspar.time2_clip)


mpv.script := A_WorkingDir . "\mark_inout_file.lua"
runpreview(media, mpv)
GuiControl,, %hstatus%, % "Preview MPV Launched with PID " . mpv.pid
SetTimer, mpvchk_once, -500

return

writeobjectlist(obj, outfile)
{
	hfile := FileOpen(outfile, "w")
	for key, value in obj
	{
		hfile.WriteLine(key)
		if (!value)
			value := 0
		hfile.WriteLine(value)
	}	
	hfile.Close()
}

previewlist:
if !LV_GetCount()
	return
GuiControl, Disable, %hpreviewlist%					; disable preview list button
runpreview_edl()
SetTimer, mpvchk_once, -200
return


/*
MPV edl format
mpv edl://file1.mov,0,30

filename, start tc, duration
for special charactered filename, you must specify total filename character count
example ; 
%15%c:\temp\123.txt
*/

get_plist_edl()				; Get mpv edl url from Play list
{
	global media, mpv
	listdata := Object()
	edl_segment := ""
	Loop, % LV_GetCount()
	{
		listdata := lv_getall(A_Index)
		if (listdata.title = "=== PAUSE ===")			; ignore PAUSE line
			continue
		edl_fullpath := list_to_winpath(listdata.clip)
		edl_fullpath = "%edl_fullpath%"
		FileDelete, get_byte.txt								; update 2020/6/10		(special character enabled)
		FileAppend, %edl_fullpath%, get_byte.txt, UTF-8
		FileGetSize, get_byte, get_byte.txt
		FileDelete, get_byte.txt
		get_byte := get_byte  - 5							; count exact fullpath character count (consider hangul, english, special character)
		edl_in := tctosecond(listdata.in)
		edl_duration := tctosecond(listdata.duration)
		edl_segment .= ";%" . get_byte . "%" . edl_fullpath . "," . edl_in . "," . edl_duration
	}
	return "edl://" . SubStr(edl_segment, 2)		; ignore first ";" symbol
}

get_pl_first_audio()			; get audio format from Playlist first clip
{
	global mi
	if !LV_GetCount()
		return 0
	media := Object()
	lv_data  := Object()
	lv_data := lv_getall(1)
	media.fullpath := list_to_winpath(lv_data.clip)
	analyse_media(media, mi)
	return media.audio_format
}

runpreview_edl()					; mpv edl mode run
{
	global mpv_filter, audio_monitor_filter, mpv, media
	if !LV_GetCount()
		return
	
	if !media.audio_format
		key := get_pl_first_audio()
	else
		key := media.audio_format
	lavfilter := mpv_filter[key] . audio_monitor_filter
	geometry := ""

	WinClose, Preview play...					; added 2020/6/10   (close first for multi channel player)
	
	Process, Exist, % mpv.pid
	if ErrorLevel
	{
		WinClose, Preview play...
		Process, Close, % mpv.pid
		updatelog("Send term signal to pid " . mpv.pid)
		mpv.pid := -1
	}
	
	geometry := "--geometry=" . mpv.xpos . ":" . mpv.ypos			; restore last windows position
	if !mpv.xpos																					; There is no position info. (first run)
		geometry := ""
	
	mpvpath := mpv.fullpath
	mediapath := get_plist_edl()
	start := 0

	title := "Preview play... " . "<<Play list>>"
	mpv.title := title
	script := ""

	runtext = %mpvpath% %lavfilter%  %geometry%  %script%   --pause --keep-open --force-window=yes --window-scale=0.5 --hr-seek=yes --osd-level=3 --osd-fractions  --title "%title%"  %mediapath%
	FileAppend, %runtext%, *								; for debugging
	Run, %runtext%,, Hide, pid_mpv
	mpv.pid := pid_mpv
	updatelog("MPV launched with PID " . mpv.pid . "/ Geometry " . geometry)
}


mpvchk:
Process, Exist, % mpv.pid
If !ErrorLevel			; There is no mpv console process
{
	GuiControl,, %hstatus%, Preview Window Closed
	GuiControl, Enable, %hpreview%
	GuiControl, Enable, %hpreviewsdi%
	GuiControl, Enable, %hpreviewlist%
	updatelog("Preview Window Closed")
	if caspar.listplay
		updatepropertytextlv(caspar, media)										; Restore playlist play information added 2019/7/30
	mpv.pid := -1
	SetTimer, mpvchk, Off
	mpvrun := ""
	ToolTip								; Remove any tool tip
	return
}

if WinExist("Preview play")			; Save previous mpv windows position
{
	WinGetPos, x, y, width, height, Preview play
	mpv.xpos := x + 8
	mpv.ypos := y + 30
	if ((mpv.xpos < 0) or (mpv.xpos > A_ScreenWidth))
			mpv.xpos := 100
		if ((mpv.ypos < 0) or (mpv.ypos > A_ScreenHeight))
			mpv.ypos := 100
}

clear_mpv_console(mpvrun, mpv)

;Loop, parse, temp, `r
;	FileAppend, % A_Index . "   " . A_LoopField . "  -  " . StrLen(A_LoopField) . "`r`n", mpvoutput2.txt

SetTimer, mpvchk, -300
return

clear_mpv_console(mpvrun, mpv)
{
	temp := mpvrun.read()
	get_pvw_position2(temp, mpv)
	;ToolTip % mpv.pos
	;FileAppend, %temp%, *
	return mpv.pid
}

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


get_mpvout(mpvout_file)
{
	global hstatus
	count := 0
	mpv_text := Object()
	hfile := FileOpen(mpvout_file, "r", "UTF-8")				; add utf-8 option,  2020/7/9
	while(!hfile.AtEOF)
	{

		line1 := hfile.ReadLine()
		line2 := hfile.ReadLine()

		line1 := StrReplace(line1, "`r`n", "")
		line2 := StrReplace(line2, "`r`n", "")   
		mpv_text[line1] := line2	
		count += 1
	}
	hfile.close()
	;printobjectlist(mpv_text)
	return mpv_text
}



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

sendin:
updatelog("[IN] button Pressed")
if process_exist(mpv.pid)
{
	updatelog("send key stroke [i] to mpv player")
	ControlSend,, i, % mpv.title
}
	SetTimer, setin, -100
return


sendout:
updatelog("[OUT] button Pressed")
if process_exist(mpv.pid)
{
	updatelog("send key stroke [o] to mpv player")
	ControlSend,, o, % mpv.title
}
	SetTimer, setout, -100
return



setin:			; New version (get position from mpv file out 2019/7/10
GuiControlGet, chk_autoload
if process_exist(mpv.pid)
{
	mpv_inout_file := get_mpvout(A_Temp . "\mpvinout.txt")
	temp := mpv_inout_file["mark_in"]
	updatelog("in point is get from mpv  pb position . " . temp)
	;showobjectlist(mpv_inout_file)
	GuiControl, text, %hcue_in%, % secondtotc(temp)
	if chk_autoload
		SetTimer, load, -1
}
else
{
	; get timefrom foreground pb position, new, 2020/6/10
	updatelog("in point is get from caspar  pb position . " . info_caspar.time1_foreground)
	GuiControl, text, %hcue_in%, % secondtotc( info_caspar.time1_foreground	)
}
	updatelogall("Set in point  " . temp)
	SetTimer, removetooltip, -1000
return


setout:			; New version (get position from mpv file out 2019/7/10
if process_exist(mpv.pid)
{
	mpv_inout_file := get_mpvout(A_Temp . "\mpvinout.txt")
	temp := mpv_inout_file["mark_out"]
		updatelog("out point is get from mpv  pb position . " . temp)
	;showobjectlist(mpv_inout_file)
	GuiControl, text, %hcue_out%, % secondtotc(temp)
}
else
{
			; get timefrom foreground pb position, new, 2020/6/10
	updatelog("out point is get from caspar  pb position . " . info_caspar.time1_foreground)
	GuiControl, text, %hcue_out%, % secondtotc( info_caspar.time1_foreground	)
}
	updatelogall("Set out point  " . temp)
	SetTimer, removetooltip, -1000
	
return


setpbposition:
Critical
if process_exist(mpv.pid)
{
	mpv_inout_file := get_mpvout(A_Temp . "\mpvinout.txt")
	
	if !InStr(mpv_inout_file["path"], StrReplace(caspar.foregroundfile, "/", "\"))			; mpv playback file and caspar foregound file is different
	{
		updatelogall("Preview file, SDI file is different / SET new pb position failed")
		updatelog("caspar pb file is " . StrReplace(caspar.foregroundfile, "/", "\"))
		updatelog("mpv pb file is " . mpv_inout_file["path"])
		
		return
	}
	temp := mpv_inout_file["position_pb"]
		updatelog("playback position is get from mpv  pb position  " . temp)
		
	caspar.jumpto :=  Round( temp * 29.97) * 2 				; for interlaced video, x2 is req.
	casparamcp.sendText("call " . caspar.chindex . "-1 seek " . caspar.jumpto . "`r`n")
	updatelog("call " . caspar.chindex . "-1 seek " . caspar.jumpto)
	caspar.timeremold := 999999999
	SetTimer, casparpbchk, -600								; added 2019/8/19   prevent unwanted pb_index incresing
}

return



syncplay:
GuiControlGet, chk_autoload
Process, Exist, % mpv.pid
if ErrorLevel and chk_autoload
{
	casparamcp.sendText("play " . caspar.chindex . "-1`r`n")
	updatelog("Sync play started")
}
return



setin3:			; New version (get position from pipe handle)
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

setout3:	 	; New version (get position from pipe handle)
Process, Exist, % mpv.pid
if ErrorLevel
{
	temp := mpvrun.read()
	get_pvw_position2(temp, mpv)
	GuiControl, text, %hcue_out%, % mpv.pos
	updatelogall("Set Out point  " . mpv.pos)
	SetTimer, removetooltip, -1000
}
return



reset:
GuiControl,,%hcue_in%, 00:00:00.000
updatelog("TC Reset")
return

reset2:
GuiControl,,%hcue_out%, % secondtotc(media.duration)
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
	casparamcp.sendText("CALL " . caspar.chindex . "-1 " . caspar.loop . "`r`n")
}
catch, err
	updatelog("--" . A_LineNumber . "--" . printobjectlist(err))

updatelog("CALL " . caspar.chindex . "-1 " . caspar.loop)
return


load:
GuiControlGet, cue_in,, %hcue_in%
GuiControlGet, cue_out,, %hcue_out%
GuiControlGet, chk_loop,, %hchk_loop%
updatelog("[LOAD] Button Pressed. current timerem is " . caspar.timerem)
;caspar.loop := looparray[chk_loop]
;ToolTip % chk_loop . "   " . caspar.loop
caspar.loop := (chk_loop = "SINGLE CLIP") ? "LOOP" : ""
;if (chk_loop =  "SINGLE CLIP")
;	caspar.loop := "LOOP"
caspar.listplay := 0
caspar.loadbg_try := 0				; added 2020/7/9

caspar.in := tctoframe_drop(cue_in) * 2				; for interlaced video, x2 is req.

caspar.medianame := winpathtocaspar(media.fullpath, caspar.mediapath)

;resetcasparudp(casparudp)

if cue_out			; if there is out point
{
	caspar.out := tctoframe_drop(cue_out) * 2   		; for interlaced video, x2 is req.
	if caspar.out > caspar.in				; out point is behind in point (correct)
	{
		caspar.duration := "LENGTH " . (caspar.out - caspar.in)
		GuiControl,, %hstatus%, % caspar.duration
	}
	else 
	{
		caspar.duration := ""			; out point is before in point (invalid)
		GuiControl,, %hstatus%, OPEN END
	}
} else
	caspar.duration := ""		; there is no out point

/*
cmd_load := "load "	

if chk_bgload
	cmd_load := "loadbg "  			; added 2020/3/17 (clip load without black screen refresh)

cmd_load := "loadbg "				; changed 2020/6/10
*/

try
{	
	casparamcp.sendText("loadbg " . caspar.chindex . "-1 """ . caspar.medianame . """ SEEK " . caspar.in . " " . caspar.duration . " " . caspar.loop . "`r`n")
}
catch, err
	updatelog("--" . A_LineNumber . "--" . printobjectlist(err))
	
if (!chk_bgload)
try
{	
	casparamcp.sendText("play " . caspar.chindex . "-1 `r`n")				; changed 2020/6/10			(smooth clip load, show first frame on load)
	casparamcp.sendText("pause " . caspar.chindex . "-1 `r`n")
}
catch, err
	updatelog("--" . A_LineNumber . "--" . printobjectlist(err))
	
updatelog(cmd_load . caspar.chindex . "-1 """ . caspar.medianame . """ SEEK " . caspar.in . " " . caspar.duration . " " . caspar.loop )

SetTimer, casparpbchk, -1000
ledon(hloadled)
if caspar.listload
	lv_color_row(caspar.pbindex)
else
	lv_color_row_reset()
return



tc_preset1:
Critical

row := 0
Loop
{
	row := LV_GetNext(row)
	if not row
		break
	updatelog("LV Timecode in preset1 / selected row number " . row)
	lvdata := lv_getall(row)
	
	if (tctosecond(preset.preset1, 29.97) <= tctosecond(lvdata.out, 29.97))
	{
		lvdata.in := preset.preset1
		lvdata.duration := get_tc_duration(lvdata.in, lvdata.out)
		lv_modifyall(row, lvdata)
		updatelog("Apply new TC in " . lvdata.in . ",  / New duration is " . lvdata.duration)
	}
}

duration_plist := get_plist_duration()		; update playlist duration array

return



tc_preset2:
Critical

row := 0
Loop
{
	row := LV_GetNext(row)
	if not row
		break
	updatelog("LV Timecode in preset2 / selected row number " . row)
	lvdata := lv_getall(row)
	
	if (tctosecond(preset.preset2, 29.97) <= tctosecond(lvdata.out, 29.97))
	{
		lvdata.in := preset.preset2
		lvdata.duration := get_tc_duration(lvdata.in, lvdata.out)
		lv_modifyall(row, lvdata)
		updatelog("Apply new TC in " . lvdata.in . ",  / New duration is " . lvdata.duration)
	}
}

duration_plist := get_plist_duration()		; update playlist duration array

return



tc_preset3:
Critical

row := 0
Loop
{
	row := LV_GetNext(row)
	if not row
		break
	updatelog("LV Timecode in preset2 / selected row number " . row)
	lvdata := lv_getall(row)
	
	if (tctosecond(preset.preset3, 29.97) <= tctosecond(lvdata.out, 29.97))
	{
		lvdata.in := preset.preset3
		lvdata.duration := get_tc_duration(lvdata.in, lvdata.out)
		lv_modifyall(row, lvdata)
		updatelog("Apply new TC in " . lvdata.in . ",  / New duration is " . lvdata.duration)
	}
}

duration_plist := get_plist_duration()		; update playlist duration array

return


ledon(handle)
{
	global buttonled
	for key, val in buttonled
	GuiControl, Hide, %val%				; hide all LED 
	GuiControl, Show, %handle%		; Turn on LED
	GuiControl, +cRed, %handle%
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
		updatelog("--" . A_LineNumber . "--" . printobjectlist(err))
}

play:
updatelog("[PLAY] Button Pressed. current timerem is " . caspar.timerem)
caspar.listplay := 0

;resetcasparudp(casparudp)

caspar.cmd_play := "PLAY "

;if ((caspar.timerem < caspar.preparenext) and (!chk_bgload))			; changed 2020/7/9
if ((caspar.loadbg_try) and (!chk_bgload))
	caspar.cmd_play := "RESUME "

try
{	
	casparamcp.sendText(caspar.cmd_play . caspar.chindex . "-1`r`n")
;	Sleep, 100
;	casparamcp.sendText("info " . caspar.chindex . "-1`r`n")
	;casparamcp.sendText("CALL 1-1 " . caspar.loop . "`r`n")
}
catch, err
	updatelog("--" . A_LineNumber . "--" . printobjectlist(err))
updatelog("[play command] " . caspar.cmd_play . caspar.chindex . "-1")
updatelog("pb index is " . caspar.pbindex)

;SetTimer, casparpbchk, -1000				; disabled 2020/4/1
ledon(hplayled)
return

listplay:
updatelog("[PLAYLIST PLAY] Button Pressed. current timerem is " . caspar.timerem)
caspar.listplay := 1
;caspar.loadbg_try := 0							; removed 2020/6/18
caspar.timeremold  := 5184000			; prevent unwanted pbindex increasing
updatelog("pb index is " . caspar.pbindex)

;resetcasparudp(casparudp)

caspar.cmd_play := "PLAY "
;if ((caspar.timerem < caspar.preparenext) and (!chk_bgload))			; changed 2020/7/9
if ((caspar.loadbg_try) and (!chk_bgload))
	caspar.cmd_play := "RESUME "

try
{	
	casparamcp.sendText(caspar.cmd_play  . caspar.chindex . "-1`r`n")
;	Sleep, 100
;	casparamcp.sendText("info " . caspar.chindex . "-1`r`n")
}
catch, err
	updatelog("--" . A_LineNumber . "--" . printobjectlist(err))
updatelog("[list play commad] " . caspar.cmd_play  . caspar.chindex . "-1")
updatelog("pb index is " . caspar.pbindex)

;SetTimer, casparpbchk, -1000
ledon(hlistplayled)
;GuiControl,, %hpbnumber%,  % caspar.pbindex
return



pause:
caspar.listplay := 0
updatelog("[PAUSE] Button Pressed. current timerem is " . caspar.timerem)
;resetcasparudp(casparudp)

try
{	
	casparamcp.sendText("pause " . caspar.chindex . "-1`r`n")
}
catch, err
	updatelog("--" . A_LineNumber . "--" . printobjectlist(err))
updatelog("Pause command " . caspar.chindex . "-1 ")
;SetTimer, casparpbchk, off

ledon(hpauseled)
return


GuiDropFiles:
if !InStr(A_GuiEvent, caspar.mediapath)
{
	GuiControl,, %hmediainfo%, 경로 확인 !! `r`n`r`nMEDIA 폴더에 있는 클립만 로드 할 수 있습니다.
	return
}

caspar.listload := 0			; added 2019/10/6

for key, val in buttoncontrol				; Disable some buttons
	GuiControl, Disable, %val%
Sleep, 30		; wait until button disabled

GuiControl,, %hmediainfo%, 파일 분석중~~!!`r`n기다릴것
Sleep, 30		; wait until text gui changed

Loop, parse, A_GuiEvent, "`n", "`r"	
{
	media.fullpath := A_LoopField
	analyse_media(media, mi)
	updatepropertytext(hmediainfo, media)
	GuiControl, text, %hcue_in%, % auto_markin(media.fullpath)
	GuiControl, text, %hcue_out%, % secondtotc(media.duration)
	if InStr(A_GuiEvent, "`n")							; multiple files are dropped
	{
		updatelog("multiple file drop is detected, add file to playlist  [ " . media.fullpath . " ]")
		gosub, addlist
	}
}

for key, val in buttoncontrol			; Enable some buttons
GuiControl, Enable, %val%

if chk_autoload			; added 2020/6/10
	SetTimer, load, -1
return


get_firstline(text)						; get single file from multiple file list
{
	list_file := Object()
	list_file :=StrSplit(text, "`n", "`r")
	return list_file[1]
}

auto_markin(fullpath)					;  find sbs cm pattern			2020/7/9
{
	mark_in = 00:00:00.000
	flag1_sbscm := 0
	flag2_sbscm := 0
	
	SplitPath, fullpath, outfilename, outdir, outextension, outnamenoext, outdrive

	if (RegExMatch(outfilename, "폐막식"))
		flag1_sbscm := 1
	

	if (flag1_sbscm and flag2_sbscm)
		mark_in = 00:00:00.700

	return mark_in
}



winpathtocaspar(fullpath, mediapath)
{
	;FileAppend, % fullpath . "`r`n" . mediapath, *
	SplitPath, fullpath, outfilename,  outdir, outextension, outnamenoext
	temp := outdir .  "/" . outnamenoext
	temp := StrReplace(temp, mediapath, "")
	temp := StrReplace(temp, "\", "/")
	return temp
}

GuiContextMenu:

if (A_GuiControl = "ADD ▶")				; Right Click ADD Button
{
	plist_add_pause()
	duration_plist := get_plist_duration()		; update playlist duration array, added 2019/8/23
	caspar.pbindex_max := LV_GetCount()
	updatelog("Add playlist pause")
}
return



GuiClose:
;temp := mpv.pid
;WinClose, ahk_pid %temp%
SetTimer, watchdog_chk, off
Run, taskkill /f /im mpv.com,, Hide
Run, taskkill /f /im mpv.exe,, Hide		; close all mpv player
WinClose, %osc_reader_title%			; close osc reader
WinClose, %title_remote%				; close remote proceessor
updatelog("------------------  Application Close -----------------------")
MsgBox, 4, Close Option, Caspar 엔진도 같이 닫을까요 ? (Yes - 송출 종료됨, No - 송출은 유지됨)
IfMsgBox yes			; close app with closing caspar
{
	SetTimer, casparpbchk, off
	try
	{	
		casparamcp.sendText("clear " caspar.chindex . "`r`n")
		Sleep, 200
	}catch, err
			updatelog("--" . A_LineNumber . "--" . printobjectlist(err))
	if (get_window_count(title) > 1)	; there is another sendust player
		ExitApp					; exit app immediately
	while WinExist(caspar.title)
	{
		updatelog("There is Engine process, Try to close it ")
		ControlSend,,q{enter}, % caspar.title
		Sleep, 500
		ControlSend,,q{enter}, % caspar.title
		Sleep, 500
		RunWait, taskkill /f /im casparcg.exe,, Hide
	}
	ExitApp
} else					; exit app with closing caspar
ExitApp

removetooltip:
ToolTip
return


get_window_count(wintitle)
{
	newtitle := SubStr(wintitle, 1, 20)		; match first 20 character			(title : sendust multi channel player - x -   2020/x/x )
	WinGet, id, List, %newtitle%
	return id				; retuen number of window with wintitle
}




plist_add_pause()
{
	data := Object()
	data.in := "00:00:00.000"
	data.out := "00:00:00.000"
	data.duration := "00:00:00.000"
	data.clip := "=== PAUSE ==="
	data.title := "=== PAUSE ==="
	data.status := LV_GetCount() + 1
	lv_addall(data)
	LV_ModifyCol(, AutoHdr)
}

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
	global mpv_filter, audio_monitor_filter, mpvrun
	key := media.audio_format
	lavfilter := mpv_filter[key] . audio_monitor_filter
	geometry := ""
	
	Process, Exist, % mpv.pid
	if ErrorLevel
	{
		WinClose, Preview play...
		Process, Close, % mpv.pid
		updatelog("Send term signal to pid " . mpv.pid)
	}
	
	geometry := "--geometry=" . mpv.xpos . ":" . mpv.ypos			; restore last windows position
	if !mpv.xpos																					; There is no position info. (first run)
		geometry := ""
	
	mpvpath := mpv.fullpath
	mediapath := media.fullpath
	start := mpv.start
	
	;IfWinExist, MPV Control Console
	;	WinClose, MPV Control Console

	title := "Preview play... " . media.fullpath
	mpv.title := title
	if mpv.script
	{
		script := mpv.script
		script = "%script%"
		script = --script=%script%
	}
	else
		script := ""

	runtext = %mpvpath% %lavfilter%  %geometry%  %script%   --pause --keep-open --force-window=yes --window-scale=0.5 --hr-seek=yes --osd-level=3 --osd-fractions  "%mediapath%" --title "%title%"
	;Run, %mpvpath% %lavfilter% --start %start% %geometry% --pause --keep-open --force-window=yes --window-scale=0.5 --hr-seek=yes --osd-level=3 --osd-fractions  --no-audio "%mediapath%" --title "%title%",,,pid
	;mpv.pid := pid
	;WinWait, ahk_pid %pid%,, 5
	;WinSetTitle, ahk_pid %pid%,, MPV Control Console
	;WinMove,  ahk_pid %pid%, ,20000 ,20000			; move away outside visible area

	mpvrun := new consolerun(runtext,, "CP850")
	mpv.pid := mpvrun.pid
	;WinWait, %title%,, 3
	;WinSet, Style, -0x20000, %title%					; remove minimize button
	;WinSet, Style, -0x30000, %title%					; remove maximize button
	;WinHide, ahk_pid %pid%
	;updatelog(runtext)
	updatelog("MPV launched with PID " . mpv.pid . "/ Geometry " . geometry)
}


checklogfile(chkfile)
{
	FileGetSize, size, %chkfile%
	if (size > 3000000)
	{
		SplitPath, chkfile, outfilename, outdir, outextension, outnamenoext, outdrive
		FormatTime, outputvar,, yyyyMMdd-HHmmss
		FileMove, %chkfile%, %outdir%\%outnamenoext%_%outputvar%.%A_MSec%.%outextension%, 0
		return 1
	}
	else
		return 0
		
}

getlogfile(filename)
{
	SplitPath, filename, outfilename, outdir, outextension, outnamenoext, outdrive
	filename_new = %outdir%\log\%outnamenoext%.log
	return filename_new
}

getinifile(filename)
{
	SplitPath, filename, outfilename, outdir, outextension, outnamenoext, outdrive
	filename_new = %outdir%\%outnamenoext%.ini
	return filename_new
}

getbmpfile(filename)
{
	SplitPath, filename, outfilename, outdir, outextension, outnamenoext, outdrive
	filename_new = %outdir%\%outnamenoext%.bmp
	return filename_new
}

get_casparchannel(filename)
{
	SplitPath, filename, outfilename, outdir, outextension, outnamenoext, outdrive
	index := SubStr(outnamenoext, 0)
	if !RegExMatch(index, "\d")				; last character is not a decimal number
		index := 1
	return  index			; return last character 
}



updatelog(text)
{
	global logfile
	FormatTime, time_log,, yyyy/MM/dd HH:mm.ss
	if checklogfile(logfile)
		FileAppend, [%time_log%_%A_MSec%]  - Backup old log file .................`r`n, %logfile%
	FileAppend, [%time_log%_%A_MSec%]  - %text%`r`n, %logfile%
}

updatelogall(text)
{
	global hstatus
	ToolTip, % text
	updatelog(text)
	if hstatus
		GuiControl,, %hstatus%, % text
}

showobjectlist(myobject)
{
	temp := ""
	for key, val in myobject
		temp .= key . " ---->  " . val . "`r`n"
	ToolTip % temp
}

printobjectlist(myobject)
{
	temp := "`r`n--------------------   Print object list  ------------------------`r`n"
	for key, val in myobject
		temp .= key . " ---->  " . val . "`r`n"
	FileAppend, %temp%, *
	return temp
}



updatepropertytext(handle, media_in)
{
	SplitPath, % media_in.fullpath, outfilename
	property := outfilename . "`r`n-----------------------`r`n" . "Resolution : " . media_in.resolution . "`r`n" . "Codec : " . media_in.codecv . "`r`n"
		. "Audio Format : " . media_in.audio_format . "`r`n" . "Duration: " . media_in.duration . " (" . secondtotc_drop(media_in.duration) . ")`r`n" . "Total Frame : " . media_in.durationframe . "`r`n"
		. "Framerate: " . media_in.framerate . "`r`n" . "StartTC: " . media_in.start  . "`r`n" . "ScanType: " . media_in.scantype
	updatelog("`r`nUpdate property text with ----------------  `r`n" . property)
	GuiControl, text, %handle%, %property%
}

analyse_media(ByRef media, o_mi)			; new, 2019/4/3 from mediainfo.dll
{
	global hstatus
	static picture_extension := "jpg,bmp,tga,gif,tiff,psd,ai,jpeg,jfif,png"
	GuiControl,, %hstatus%, Analysing Media...Please wait
	o_mi.open(media.fullpath)
	
	media.extension := o_mi.getgeneral("FileExtension")
	media.duration := o_mi.getvideo("Duration") / 1000
	if (media.duration =	"")																	; added 2020/3/6 (video first, general second)
	media.duration := o_mi.getgeneral("Duration") / 1000			; Modified 2019/7/11 for audio only media
	media.start := o_mi.gettimecode()	
	media.resolution := o_mi.getvideo("Width") . "x" . o_mi.getvideo("Height")
	media.resolution := StrLen(media.resolution) < 3 ? o_mi.getimage("Width") . "x" . o_mi.getimage("Height") : media.resolution
	media.framerate := o_mi.getvideo("FrameRate")
	media.audio_format := o_mi.getaudiocount()
	media.codecv := o_mi.getvideo("Format")
	media.durationframe :=  o_mi.getvideo("FrameCount")	
	media.scantype := o_mi.getvideo("ScanType")	
	
	
	if ((InStr(picture_extension, media.extension)))				; added 2020/3/16			for time lapse picture
	{
	media.codecv := "picture"
	media.duration := 1 / 29.97
	media.durationframe := 1
	}
	
	GuiControl,, %hstatus%, Finish Analysing Media
	
}


tctosecond(intime, fps = 29.97)						;   changed 2018/12/10	
{																			;	input tc format is 00:00:00.000 or 00:00:00;00  or 00:00:00:00
		if fps < 1
			fps := 29.97
		if !RegExMatch(intime, "\d\d:\d\d:\d\d")			; intime is not valid tc format
			return 0									; added 2020/7/24
		intime = %intime%00000				; add '00000' to end
		hh := SubStr(intime, 1, 2)			; ffmpeg output example   [ Duration: 00:06:56.42, start: 1.033367, bitrate: 9524 kb/s ]
		mm := SubStr(intime, 4, 2)			;						  [ timecode        : 11:10:59;25 ]
		ss := SubStr(intime, 7, 2)
		separator := SubStr(intime, 9, 1)       
		IfEqual, separator, .				;  separator is . (00:06:56.421 format)
			ss := SubStr(intime, 7, 6)
		IfEqual, separator, `;
			ss := SubStr(intime, 7, 2) + SubStr(intime, 10,2) / fps
		IfEqual, separator, :				; separator is : (00:06:00:33 format, Gopro case)		added 2018/12/10
			ss := SubStr(intime, 7, 2) + SubStr(intime, 10,2) / fps

		return hh * 3600 + mm * 60 + ss	
}

frametotc_old_backup(frame)
{
	second := frame/29.97
	return % secondtotc_drop(second)
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

tctoframe_drop(intime)
{
	second := tctosecond(intime, 29.97)
	return % round(second * 29.97)
}


secondtotc(sec)				; unit is milisecond
{
	sec := format("{:10.3f}", sec)
	sec_out := Floor(sec)
	frame_out := format("{:0.3f}", sec - sec_out)
	hour_out := format("{:02d}", sec_out // 3600)
	minute_out := format("{:02d}",  Mod(sec_out // 60, 60))
	second_out := format("{:02d}", Mod(sec_out, 60))

	return % hour_out . ":" . minute_out . ":" . second_out . "." . SubStr(frame_out, -2)
}



secondtotc_drop(sec)			; changed 2020/3/23
{
	frames := Round(sec * 29.97)
	return frametotc(frames)
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
		{
			GuiControl,, %hstatus%, 마운트 실패
			return 1
		}
		else
		{
			GuiControl,, %hstatus%, %mountpoint% 이름으로 %folder% 마운트 됨
			updatelog(mountpoint . " 이름으로 " . folder . " 폴더 마운트 됨")
			return 0
		}
	}
}

process_exist(pid)			; added 2020/3/4
{
	Process, Exist, %pid%, 
	return ErrorLevel
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
	info.filepath_foreground := StrReplace(result[1], "////", "/")						; replace four / to single /			added 2019/7/25
	info.filepath_foreground := StrReplace(info.filepath_foreground, "/", "\")
	;FileAppend, % info.filepath_foreground . "`r`n" , *
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


checkfinishday(day)
{
	app_life := A_Now
	EnvSub, app_life, %day%, DD
	if app_life > 0
	{
		MsgBox,, 알림, 사용기간 만료`r`n새로운 버전을 받으세요`r`n문의 : SBS 미디어 IT 팀, 4
		ExitApp	
	}
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




#IfWinActive, Preview play...				; Creates context-sensitive hotkeys and hotstrings.
~i::
if process_exist(mpv.pid)
	SetTimer, setin, -100				; Wait until mpv finish writing mpvinout.txt
return

~o::
if process_exist(mpv.pid)
	SetTimer, setout, -100				; Wait until mpv finish writing mpvinout.txt
return

~g::
if process_exist(mpv.pid)
	SetTimer, setpbposition, -100				; Wait until mpv finish writing mpvinout.txt
return


~space::
if process_exist(mpv.pid)
	SetTimer, syncplay, -1
return

~enter::
if process_exist(mpv.pid)
	SetTimer, addlist, -1
return


#If WinActive(title)			;  Creates context-sensitive hotkeys and hotstrings.
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
			SetTimer, load, -1
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
		SetTimer, load, -1
}
return

~!^+1::
GuiControl, Enable, %hchk_sdiwindow%
return

~^!1::
ListVars
updatelog("--" . A_LineNumber . "--" . printobjectlist(caspar))
updatelog("--" . A_LineNumber . "--" . printobjectlist(info_caspar))
updatelog("--" . A_LineNumber . "--" . printobjectlist(watchdog))
updatelog("--" . A_LineNumber . "--" . printobjectlist(media))
casparamcp.sendText("play " . caspar.character_out . "-2 [html] " . caspar.html_tc . "`r`n")				; load html tc
FileAppend, File encoding is %A_FileEncoding% `r`n, *
return


