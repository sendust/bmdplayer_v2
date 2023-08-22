/*
	SBS Player (single channel)
	Powered by CasparCG Engine
	Code by sendust

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
	2020/11/5 	Code updated with Layed Remote client operation (introduce new ini items)
						Improve media fullpath processing (remove last back slash)
						Add unload button
	2020/11/6	Change unload button (Right click of Load,Preroll -> Unload)
						Improve Open Media Folder (Try, catch)
						Improve client mode relative path manipulation (Preview-SDI)
						Disable logging for xml tagged text
	2020/11/9	Remove unused variable (caspar.preindex)
						Introduce Debug mode
	2020/11/10	Remove unused vairable (lvdata.pbindex)
						Improve unload  for character video layer
	2020/11/12	unload introduce caspar.listplay = 0
	2020/11/17	fix  caspar.loop variable
	2020/11/18	improve  chk_loop routine (hide playlist play led when single loop is selected)
	2020/11/19	Read remote on from INI (auto remote on)
						Improve SDI channel preview
						bug fix. [ loadbg .... loop 0 ]
	2020/11/25	Reload TC html while execute unloading
	2020/11/30  introduce flags.simple_tc variable
						status is EJECT if there is no foreground file
						Improve pbindex incresing condition while playlist loop
	2020/12/02	remove playlist save delay (10ms, no visual effect while saving)
	2020/12/15  Space bar play (for TS-6)
	2020/12/16	Reset TC Layer in Help routine (Recover TC display html page)
	2020/12/19	Introduce TTS feature (play, playlist play)
	2020/12/21 Improve TTS,
	                   Playlist clear all
	2020/12/25 Remove LV Coloring (for stability issue)
						Improve Playlist play mark indication while move up, down
	2020/12/27	Default audio format is mono-8 while old playlist loading
						Bug fix (playlist add by  [ENTER] while playlist playing
						Caspara info reader by python enabled (CPU load reduced 1~2%), Improve stability
	2020/12/29  Improve remote on, off routine
	2020/12/30	Improve ListPlay pbindex display routine (check if pbindex > 0)
						Display REDBAR when LOADBG FAIL
	2021/1/5		Python UDP socket refresh while HELP button pressed
						Improve watchdog tick update
	2021/1/8		casparamcp ; change socket.ahk  (block tcp -> nonblock tcp)
						Remove try, catch in socket_nonblock.ahk
	2021/1/9		Watchdog reconnect udp port for  python caspar info and  remote udp port  in case of time tick failure
						Introduce udp remote class
						Engine Restart Msgbox in watchdog routine
	2021/1/11	Bug fix  ---  Remote force on
	2021/1/15 	Watchdog monitors remote application
	2021/1/18	http post for ALT CM
						Check Engine running time in watchdog
						Show engine age in help box
	2021/1/20	c_commercial class (powered by cho.)
	2021/1/25	add bandType in commercial class (require decision_cm.txt)
	2021/2/1		multiple HTTP post
	2021/2/5		New remote command (__ALTCM_)
	2021/2/26	Change tcp send delay (50 -> 25)
						CM duration postroll margin (ini config, 5000 default)
	2021/3/2		add seek command at load time  (accurate frame start)
						Restore tcp send delay (25 -> 50)
	2021/3/8		v2.1 compatible (caspar.field_factor = 1 or 2)
	2021/3/9		Separate python info reader between 2.1 and 2.3
	2021/3/12	play 1-1 empty before routing channel for character (for poor osc protocol v2.1 or less)
	2021/3/16   Improve load (v2.1 v2.3)
						replace python info reader -> python osc reader
						variables  caspar.nb_times, caspar.timerem in casparpbchk routine acquired  from python osc information
	2021/3/19	Improve loadbg and seek
						loadbg with image file does not trigger seek command (prevent casparcg exception error)
	2021/3/23	Jump command sends even frame number only
						Add cm extra margin in ini
	2021/3/24	Improve casparpbchk routine.    [playlist play -> update next item property auto update condition]
	2021/3/25	Improve Engine startup, shutdown routine
	2021/3/26	Improve Engine health monitor class
	2021/3/29	Improve Load routine.		(After loadbg, PLAY -> PAUSE  single line execution)
	2021/4/1		Improve addlist routine when mark in and mark out is reverse time order
						Improve setin routine
	2021/4/19	Auto scroll Listview to show currently playing list item
	2021/6/15	Support Playlist Insert Mode (item, pause)
	2021/6/16	Improve renumber_pl() function.
						Improve pbindex tracking while add, delete, move up, down
	2021/7/2     Introduce flags object
						New Load algorithm for listview load (by click, remote)
						Separate caspar.pbindex, playlist.selected_row
	2022/1/21   add class   "show_liveTC" (under dev.....)
	2022/2/14	Disable mpv consolerun class
						change mpvchk_once timer (-300ms)
	2022/4/18	Improve load:  routine  (playlist load, playlist.pbindex variable)
	2022/5/11   add keyboard seek funciton, shortcut
	2023/2/16	Keyboard seek (L,R,U,D) distance from config file (ini)
*/

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#WinActivateForce

SendMode Event
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, -1
;#Include socket.ahk
#Include socket_nonblock.ahk				; Non block 2021/1/8
#Include mediainfo.ahk
;#include console_class_sendust.ahk		; Disabled 2022/2/14
#Include CreateFormData.ahk										; for http post
#Include BinArr.ahk ; https://gist.github.com/tmplinshi/a97d9a99b9aa5a65fd20,   for http post
;#Include LVA.ahk			; Coloring List view (Playlist)
#SingleInstance ignore
Menu, Tray, Icon, Shell32.dll, 138			; change Tray Icon

ahk_exe = ahk
if A_IsCompiled
	ahk_exe = exe

flags := Object()				; New 2021/7/2


title := "sendust multi channel player - " . get_casparchannel(A_ScriptName) . " -  2022/5/11"

flags.engine_version := "2.3"				; Select 2.1 or 2.3
flags.largelv := 0
flags.debug_mode := 0
flags.simple_tc := 1					; flags.simple_tc ; simplified TC display (for SBS ts-6)			; 2020/11/30
flags.from_explorer := 0

finishday :=  20291231235959
title_remote := "Player" . get_casparchannel(A_ScriptFullPath) . " Remote by sendust"
binary_remote := A_ScriptDir . "\SBSPlayback_remote" . get_casparchannel(A_ScriptFullPath) . "." . ahk_exe
pid_remote := -1
;osc_reader := A_WorkingDir . "\read_osc_caspar_v22." . ahk_exe
osc_reader := A_ScriptDir . "\level_meter12." . ahk_exe					; new, 2 ch sdi, each 8 channel audio
osc_reader_title := "Caspar v2.2 OSC Monitor by sendust"
osc_reader :=  A_ScriptDir . "\dummy." . ahk_exe			; osc level meter is replaced by python script (2021/3/16~)
osc_reader_title := flags.engine_version = "2.3" ?  osc_reader_title : "Caspar v2.1 OSC Monitor by sendust"
script_python_info := flags.engine_version = "2.3" ?  "osc_v23.py" : "osc_v21.py"
;osc_reader := flags.engine_version = "2.3" ? osc_reader : A_ScriptDir . "\dummy." . ahk_exe


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
Gui, add, Checkbox, xm+150 yp+25 hwndhchk_autoadd vchk_autoadd gchkbox_update, AUTO ADD				; subroutine changed 2021/6/14 (---> chkbox_update)
Gui, add, Checkbox, xp+90 yp hwndhchk_autoload vchk_autoload gchkbox_update, AUTO LOAD						; subroutine changed 2021/6/14 (---> chkbox_update)

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
Gui, add, Checkbox, xp+120 yp hwndhchk_bgload vchk_bgload gchkbox_update, Load Background

Gui, add, Progress, xm+360 ym w5 h550, 100			; vertical bar -----------------------------------------------------

Gui, add, Text, xm+370 ym w180 h30 hwndhplist_duration, PL DUR 00:00:00.000
Gui, add, button, xp+200 yp-5 w120 h30 hwndhpreviewlist gpreviewlist, PVW-PLIST
Gui, add, Progress, xp+130 yp w150 h30 cRed hwndhchannel_condition, 100
if flags.largelv
	Gui, add, ListView, xm+370 ym+30 w1500 h710 hwndhlistview vVLV glvclick NoSortHdr NoSort ReadOnly AltSubmit -LV0x10, STATUS|TITLE|IN|OUT|DURATION|CLIP LIST|AUDIO
else
	Gui, add, ListView, xm+370 ym+30 w800 h410 hwndhlistview vVLV glvclick NoSortHdr NoSort ReadOnly AltSubmit -LV0x10, STATUS|TITLE|IN|OUT|DURATION|CLIP LIST|AUDIO
if flags.largelv
	Gui, add, DDL, xm+390 yp+720 w75 hwndhplselect vplselect choose1, LIST1|LIST2|LIST3|LIST4|LIST5|LIST6|LIST7|LIST8|LIST9|sLISTA|sLISTB|sLISTC|sLISTD
else
	Gui, add, DDL, xm+390 yp+420 w75 hwndhplselect vplselect choose1, LIST1|LIST2|LIST3|LIST4|LIST5|LIST6|LIST7|LIST8|LIST9|sLISTA|sLISTB|sLISTC|sLISTD
Gui, add, button, xp+100 yp w60 h20 gplsave hwndhplsave, SAVE
Gui, add, button, xp+100 yp w60 h20 gplload hwndhplload, LOAD
Gui, add, button, xp+100 yp w65 h20 glvrename, RENAME

Gui, add, button, xm+390 yp+30 w60 h30 glvdeletesingle, DELETE
Gui, add, button, xp+100 yp w60 h30 gmoveup, ▲
Gui, add, button, xp+100 yp w60 h30 gmovedown, ▼

Gui, add, button, xm+390 yp+40 w60 h30 ghelpbox , HELP
Gui, add, button, xp+100 yp w160 h30 glistplay, PLAYLIST PLAY
Gui, add, Progress, xp yp+32 w160 h5 cred hwndhlistplayled, 100

Gui, add, text, xp+200 yp-70 w50 h50 Right hwndhpbnumber, ##
Gui, add, Checkbox, xp-10 yp+50 w100 hwndhchk_dissolve vchk_dissolve gchkbox_update, DISSOLVE					; subroutine changed 2021/6/14 (---> chkbox_update)
Gui, add, Checkbox, xp yp+20 w100 hwndhchk_remote vchk_remote gremote, REMOTE

Gui, add, GroupBox, xp+105 yp-110 w100 h125 cRed, IN PRESET
Gui, add, Button, xp+10 yp+20 w80 h30 gtc_preset1 hwndhpreset1, 00:00:00.700
Gui, add, Button, xp yp+35 w80 h30 gtc_preset2 hwndhpreset2, 00:00:10.000
Gui, add, Button, xp yp+35 w80 h30 gtc_preset3 hwndhpreset3, 00:00:00.000

Gui, add, Button, xp+120 yp-80 w100 h40 gcommercial , 대체광고시작


if (flags.debug_mode)
{
	Gui, add, text, xp+100 yp-90 w300 h400 hwndhdebug1, Debug1
	Gui, add, text, xm yp+120 w300 h240 hwndhdebug2, Debug2
	Gui, add, text, xp+310 yp w300 h240 hwndhdebug3, Debug3
	Gui, add, text, xp+310 yp w250 h240 hwndhdebug4, Debug4
}

Gui, add, StatusBar, hwndhstatus, Please wait until Caspar Engine ready !!
Gui, -MinimizeBox
Gui  +hwndhmygui
Gui, show,, %title%


if flags.largelv
{
	Gui, Font, s13 Bold
	GuiControl, Font, %hlistview%
}

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

if (flags.debug_mode)
{
	Gui, Font, s7 cBlack Normal
	GuiControl, Font, %hdebug1%
	GuiControl, Font, %hdebug2%
	GuiControl, Font, %hdebug3%
	GuiControl, Font, %hdebug4%
}

chk_autoload := 0

logfile := getlogfile(A_ScriptFullPath)
updatelog("------------------  Application Start -----------------------")
updatelog("Engine version is " . flags.engine_version)

python_info := new class_python_info("127.0.0.1", 34410)				; added 2020/12/27
python_info.run_reader()



media := Object()
	media.fullpath := ""
	media.audio_format  := "mono-8"				; set default audio format (For media)
mpv := Object()
	mpv.fullpath := A_WorkingDir . "\bin\mpv.com"
	mpv.pid := -1
mpv_filter := Object()
audio_monitor := object()
lvdata := Object()
caspar := Object()
	caspar.title := "CasparCG Server"
	caspar.fullpath := "S:\CasparCG Server 2.0.7\CasparCG Server\Server\casparcg.exe"	  ; Assign Default binary
	caspar.mediapath := "S:\CasparCG Server 2.0.7\CasparCG Server\Server\media"			; Assign Default media path
	caspar.pid := -1
	caspar.listplay := 0
	caspar.listload := 0
	caspar.pbindex := 0
	;caspar.preindex := 0			; deprecated  2020/11/9
	caspar.pbindex_max := 0
	caspar.timeremold  := 5184000			; 48 Hours in frame
	caspar.foregroundfileold := "---"			; apply any text
	caspar.transition := ""
	caspar.status := "PAUSE"
	caspar.preparenext := 3				; time in second (loadbg execute time while list play)

if (flags.engine_version = "2.1")		; version higher than 2.3 require field rate (frame x 2)
	caspar.field_factor := 1
else
	caspar.field_factor := 2


preset := Object()
resources := Object()						; essential file list for program launch

buttoncontrol := object()
	buttoncontrol := [hsetin, hsetout, hpreview, hload, haddlist, hpreviewlast]		; disable these button while busy

info_caspar := Object()			; decoded value from caspar info command return
info_caspar.time_tickold := -1
duration_plist := object()				; store playlist each duration (duration sum)

mi := object()
mi := new MediaInfo
;mpvrun := Object()				; mpv console object			; Disabled 2022/2/14
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
caspar.mediapath := RegExReplace(temp, "\\$")  ; Removes the trailing backslash, if present.
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
IniRead, temp, % getinifile(A_ScriptFullPath), client, remote_client, 0
caspar.remote_client := temp
IniRead, temp, % getinifile(A_ScriptFullPath), client, address_caspar, 127.0.0.1
caspar.address_caspar := temp
IniRead, temp, % getinifile(A_ScriptFullPath), client, layer_caspar, 1
caspar.layer_caspar := temp

IniRead, temp, % getinifile(A_ScriptFullPath), client, keyboard_seek, 0
flags.keyboard_seek := temp

IniRead, temp, % getinifile(A_ScriptFullPath), client, keyboard_seek_lr, 1
flags.keyboard_seek_lr := temp

IniRead, temp, % getinifile(A_ScriptFullPath), client, keyboard_seek_ud, 0.033
flags.keyboard_seek_ud := temp

caspar.channel_layer := caspar.chindex . "-" . caspar.layer_caspar

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


IniRead, temp,  % getinifile(A_ScriptFullPath), preview, sub_path , c:\temp
mpv.sub_path := temp		; read subtitle path

IniRead, chk_remote,  % getinifile(A_ScriptFullPath), remote, force_on, 0			; read auto remote on
GuiControl,, %hchk_remote%, %chk_remote%
updatelog("Serial Remote parameter from INI is " . chk_remote)


/*
; update 2020/3/19 --------------- tc osd display
tc_udp := Object()
tc_udp := new SocketUDP()
temp := caspar.port_tc
tc_udp.connect(["127.0.0.1", caspar.port_tc])
; update 2020/3/19 --------------- tc osd display
*/


tc_osd := object()
tc_osd.line1 :=""
tc_osd.line2 :=""



watchdog := object()
watchdog.tick_current := A_TickCount
watchdog.count_max := 5
watchdog.count := watchdog.count_max					; invalid response count limit
watchdog.interval := 2500


if !caspar.remote_client
	resources.push(caspar.fullpath)				; caspar.exe is not mandatory for remote client  2020/11/5
resources.push(mpv.fullpath)
resources.push(A_ScriptDir . "\mediainfo.dll")
resources.push(A_ScriptDir . "\mark_inout.lua")
resources.push(A_ScriptDir . "\mark_inout_file.lua")
;resources.push(osc_reader)
;resources.push(binary_remote)
resources.push(A_ScriptDir . "\log")
resources.push(A_ScriptDir . "\helpfile.txt")
resources.push(A_ScriptDir . "\" . script_python_info)
;resources.push(A_ScriptDir . "\remote.py")						; new  2020/1/5
resources.push(A_ScriptDir . "\decision_cm.txt")						; new  2020/1/5

if check_exist(resources)			; Check if there is all necessary files
{
	MsgBox,, ATTENTION, % check_exist(resources) . " File(folder) is not exist. Terminate Program~~" , 4
	updatelog(check_exist(resources) . "file(folder) is not exist")
	ExitApp
}

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

if !caspar.remote_client			; Check if remote client mode
{
	initcaspar(caspar)					; launch caspar engine
	;Run, %osc_reader%				; run osc only local client mode			 disabled 2021/3/16 ~
	Sleep, 500
}

casparamcp := new c_tcpsend(caspar.address_caspar, 5250)
commercial := new c_commercial(caspar)

playlist := new c_playlist													; Create new playlist object
playlist.read_config(getinifile(A_ScriptFullPath)) 			; read playlist configuration

SetTimer, initcaspar_stage2, -2000		; connect tcp and enable characger out
gosub, audiomonsel		; get audio monitor selection
gosub, chkbox_update				; get dissolve,load bg, auto load, auto add value
SetTimer, remote, -3000


/*
LVA_ListViewAdd("VLV", "")						; Enable playlist coloring, added 2019/10/6
OnMessage("0x4E", "LVA_OnNotify")			; Enable playlist coloring, added 2019/10/6
*/																; Disabled 2020/12/25
checkfinishday(finishday)
printobjectlist(playlist)
printobjectlist(flags)


;SetTimer, showflags, 300
return

showflags()
{
	global flags
	showobjectlist(flags)
}


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
	ToolTip, % frametotc(caspar.jumpto / caspar.field_factor)				; interlaced video ( /2 req.., v2.3 higher)
	SetTimer, removetooltip, -1000
}

return


initcaspar_stage2:

SetTimer, watchdog_chk, Off
caspar.listplay := 0

GuiControl,, %hstatus%, % "Caspar CG launched with PID " . caspar.pid
updatelog("Caspar CG launched with PID " . caspar.pid)

caspar.loop := looparray[chk_loop]

casparamcp.sendText("Log Level warning`r`n")				; set log level to warning
Sleep, 100
if !caspar.remote_client
{
	casparamcp.sendText("remove " . caspar.grid_out . " screen`r`n")				; Remove screen consumer
	Sleep, 100
}


if caspar.character_out				; only valid for local client mode
{
	if (ProcessRunningTime(caspar.pid) < 5)		; age of caspar engine is less than 5 second
	{
		casparamcp.sendText("play " . caspar.channel_layer . " empty`r`n")   ; play empty layer before channel duplication (for poor osc protocol v2.1 or less)
		sleep, 50
	}
	casparamcp.sendText("play " . caspar.character_out . "-1 route://" . caspar.chindex . "-1`r`n")				; synchronize play with master channel
	Sleep, 50
	casparamcp.sendText("play " . caspar.character_out . "-2 [html] " . caspar.html_tc . "`r`n")				; load html tc
	Sleep, 50
}    				; update 2020/3/19 --------------------------------------------------------------------

SetTimer, watchdog_chk, % watchdog.interval
SetTimer, casparpbchk, -1000
return

watchdog_chk:
;casparamcp.sendText("info " .  caspar.channel_layer . "`r`n")			; double check engine response, 2020/12/27
casparamcp.sendText("info`r`n")			; double check engine response, 2021/1/5			; Simplified heartbeat command


print("Watchdog is running... // Engine running time (minute)  is    " . (health.age / 60))
if !WinExist(python_info.reader_title)
{
	python_info.run_reader()
	updatelog("Python info reader is not found, start by watchdog")
}

if ((A_TickCount - watchdog.tick_amcp) > 2700)			; amcp is not response within specified periods
{
	watchdog.count -= 1
	print("Watch dog warning ~~~~~~~~" . watchdog.count)
	updatelog("Caspar engine is not response  /_/_/_/_/_/_/_/_/_/_/_/_/_/_/  [" . watchdog.count . "]")
	GuiControl,, %hstatus%, % "Caspar Engine is not response ///////////////// [" . watchdog.count . "]"
}
else
	watchdog.count := watchdog.count_max

if (info_caspar.time_tickold = info_caspar.time_tick)				; Check time_tick from python udp packet is valid
{
	print("Python udp time tick halt !!!!!!!!!!!!!!!!!", true)
	;----------------   Reset python UDP socket ------------------------------  added 2021/1/9
	python_info := ""
	python_info := new class_python_info("127.0.0.1", 34410)
	python_info.run_reader()
	;----------------------------------------------------------------------------
	print("Restart pytnon udp class", true)

	if chk_remote							; Reconnect remote udp listen port
	{
		print("Restart pytnon remote udp class", true)
		remotes := ""
		remotes := new class_remote_udp(title_remote)
	}
}

if ((!watchdog.count) and (get_casparchannel(A_ScriptFullPath) = 1))			; restart caspar (force terminate)
{
	watchdog.count := watchdog.count_max
	SetTimer, watchdog_chk, off
	MsgBox, 0x4 , ATTENTION !!!,  엔진 응답이 없습니다. 수동으로 엔진을 재시작 할까요 ?, 7
	IfMsgBox, Yes
	{
		print("CasparCG Restart msgbox yes selected ", true)
		updatelog("Try to  restart Engine /_/_/_/_/_/_/_/_/_/_/_/_/_/")
		GuiControl,, %hstatus%, Try to restart Engine ///////////////////
		ControlSend,,q{enter}, % caspar.title
		try
			RunWait, taskkill /f /im casparcg.exe,, Hide
		catch, e
			updatelog("--" . A_LineNumber . "--" . printobjectlist(e))
		Sleep, 1000											; wait until taskkill complete	(mandatory line !!!! 2020/7/17)
		WinKill, % caspar.title,, 2					; force to quit casparcg
		if !caspar.remote_client					; check if client is local or remote
			initcaspar(caspar)								; launch caspar engine again (only local client)
		SetTimer, initcaspar_stage2, -2000
	}
	IfMsgBox, No
	{
		print("CasparCG Restart msgbox no selected ", true)
		SetTimer, watchdog_chk, % watchdog.interval
	}
	IfMsgBox, Timeout
	{
		print("CasparCG Restart msgbox Timeout selected ", true)
		SetTimer, watchdog_chk, % watchdog.interval
	}
}


if chk_remote										; Watch external remote application is alive
{
	if !WinExist("Player1 Remote by sendust")
	{
		print("External remote not found, remote triggered by watchdog", true)
		pid_remote := run_externalremote()
	}
}

health := new c_engine_health_byexe("casparcg.exe")
health.probe()
health.logresult()

if (health.age > 84600)				; Check if caspar Engine is runs very long time
{
	GuiControl,, %hstatus%, % "-------->>> 엔진 종료 후 재시작을 추천 합니다. !!!!!!  <<<--------    "  . (health.age / 3600) . "  시간 경과함"
	if (health.age < 84660)
		updatelog("Caspar Engine runs Very long time " . (health.age  / 3600 ) . "   Hours")
}

info_caspar.time_tickold := info_caspar.time_tick
return

class c_engine_health
{
	pid := -1
	memoryusage := 0
	cpuload := 0
	age := 0

	__New(pid)
	{
		this.pid := pid
	}

	probe()
	{
		pid := this.pid
		this.memoryusage := GetProcessMemoryUsage(pid)
		this.cpuload := CPULoad()
		this.age := ProcessRunningTime(pid)
	}

	logresult()
	{
		age := this.age / 3600
		memoryusage := this.memoryusage
		cpuload := this.cpuload

		;FileAppend, % "`n" . A_Year . "/" . A_MM . "/" . A_DD . " - " . A_Hour . ":" .  A_Min . "." . A_Sec . " ---- (AGE) " . age . " Hour/ (RAM) " .  memoryusage . " MB / (CPU) "  . cpuload  . " %" , %A_ScriptDir%\log\Engine_monitor_%A_Year%_%A_MM%_%A_DD%.log
		FileAppend, % "`n" . A_Year . "/" . A_MM . "/" . A_DD . " - " . A_Hour . ":" .  A_Min . "." . A_Sec . " ----  " . age . " Hour/  " .  memoryusage . " MB /  "  . cpuload  . " %" , %A_ScriptDir%\log\Engine_monitor_%A_Year%_%A_MM%_%A_DD%.log
	}
}



class c_engine_health_byexe
{
	pid := -1
	memoryusage := 0
	cpuload := 0
	age := 0

	__New(name_image)
	{
		Process, Exist, %name_image%
		this.pid := ErrorLevel
	}

	probe()
	{
		pid := this.pid
		this.memoryusage := GetProcessMemoryUsage(pid)
		this.cpuload := CPULoad()
		this.age := ProcessRunningTime(pid)
	}

	logresult()
	{
		age := this.age / 3600
		memoryusage := this.memoryusage
		cpuload := this.cpuload

		;FileAppend, % "`n" . A_Year . "/" . A_MM . "/" . A_DD . " - " . A_Hour . ":" .  A_Min . "." . A_Sec . " ---- (AGE) " . age . " Hour/ (RAM) " .  memoryusage . " MB / (CPU) "  . cpuload  . " %" , %A_ScriptDir%\log\Engine_monitor_%A_Year%_%A_MM%_%A_DD%.log
		FileAppend, % "`n" . A_Year . "/" . A_MM . "/" . A_DD . " - " . A_Hour . ":" .  A_Min . "." . A_Sec . " ----  " . age . " Hour/  " .  memoryusage . " MB /  "  . cpuload  . " %" , %A_ScriptDir%\log\Engine_monitor_%A_Year%_%A_MM%_%A_DD%.log
	}
}


class class_remote_udp					; New 2021/1/9		remote class
{
	remoteudp := Object()
	title_remote := ""
	pid_remote := -1

	__New(title_remote)
	{
		print("Create udp remote class....", true)
		this.title_remote := title_remote
		this.remoteudp := new SocketUDP()
		this.remoteudp.Bind(get_remote_address())
		this.remoteudp.onRecv := Func("OnRemoteRecv")
	}

	run_remotehost()
	{
		print("Run external remote host ", true)
		title_remote := this.title_remote
		print("Run remote host application", true)
		WinClose, %title_remote%
		WinWaitClose, %title_remote%,, 3
	try
	{
		;Run, %binary_remote% 1 , %A_WorkingDir%, Minimize, pid_remote							; ahk script mode
		Run, python.exe remote.py, %A_WorkingDir%, Minimize, pid_remote				; Python script mode
		this.pid_remote := pid_remote
	}
	catch, err
		updatelog(printobjectlist(err))
	}

	stop_remotehost()
	{
		print("Stop external remote host ", true)
		title_remote := this.title_remote
		WinKill, %title_remote%,, 3
		this.pid_remote := -1
	}

	__Delete()
	{
		print("Delete udp remote class.....", true)
		try
		{
			this.remoteudp.onRecv := ""
			this.remoteudp.Disconnect()
			this.remoteudp := ""
		}
		catch, err
			updatelog(printobjectlist(err))
	}
}


remote:
GuiControlGet, chk_remote
if chk_remote
{
	remotes := new class_remote_udp(title_remote)
	remotes.run_remotehost()
}
else
{
	remotes.stop_remotehost()
	remotes := ""
}

return

run_externalremote()
{
	pid_remote := -1
	try
	{
		;Run, %binary_remote% 1 , %A_WorkingDir%, Minimize, pid_remote							; ahk script mode
		Run, python.exe remote.py, %A_WorkingDir%, Minimize, pid_remote				; Python script mode
	}
	catch, err
		updatelog(printobjectlist(err))
	return pid_remote
}


remote_oldbackup:
GuiControlGet, chk_remote

if chk_remote
{
	WinClose, %title_remote%
	WinWaitClose, %title_remote%,, 3
	remoteudp := new SocketUDP()
	remoteudp.Bind(get_remote_address())
	remoteudp.onRecv := Func("OnRemoteRecv")
	pid_remote := run_externalremote()
}
else
{
	remoteudp.onRecv := ""
	remoteudp.Disconnect()
	remoteudp := ""
	WinKill, %title_remote%,, 3
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
	global caspar, media, flags, playlist
	buffer := ""
	length := this.Recv(buffer)
	command_recv := StrGet(&buffer, length, "cp437")
	updatelog("Remote command [" . command_recv . "] received")

	if (command_recv = "__LOAD__")
		SetTimer, load, -1

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
			playlist.selected_row := caspar.pbindex
			updatelog("Load LV clip with line number " . caspar.pbindex)
			updatepropertytextlv(caspar, media)
			;caspar.listload := 1				; update 2020/6/22
			flags.from_explorer := 0
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
			playlist.selected_row := caspar.pbindex
			updatelog("Load LV clip with line number " . caspar.pbindex)
			updatepropertytextlv(caspar, media)
			;caspar.listload := 1				; update 2020/6/22
			flags.from_explorer := 0
				SetTimer, load, -1
		}
	}


	if (command_recv = "__PLAY__")
		SetTimer, play, -1

	if (command_recv = "__PLAYL_")
		SetTimer, listplay, -1

	if (command_recv = "__PAUSE_")
		SetTimer, pause, -1

	if (command_recv = "__ALTCM_")
		SetTimer, commercial, -1
}



OnRemoteRecv_old(this)
{
	global caspar, media, flags
	buffer := ""
	length := this.Recv(buffer)
	command_recv := StrGet(&buffer, length, "cp437")
	updatelog("Remote command [" . command_recv . "] received")

	if (command_recv = "__LOAD__")
		SetTimer, load, -1

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
			;caspar.listload := 1				; update 2020/6/22
			flags.from_explorer := 0
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
			;caspar.listload := 1				; update 2020/6/22
			flags.from_explorer := 0
				SetTimer, load, -1
		}
	}


	if (command_recv = "__PLAY__")
		SetTimer, play, -1

	if (command_recv = "__PLAYL_")
		SetTimer, listplay, -1

	if (command_recv = "__PAUSE_")
		SetTimer, pause, -1

	if (command_recv = "__ALTCM_")
		SetTimer, commercial, -1
}


jumpto:
updatelog("Jump to Button Pressed")
if !caspar.out					; out point is zero  (invalid lv data is loaded when last playlist play)
{
	updatelog("Invalid Mark out point")
	return
}

GuiControlGet, slide_seek
caspar.jumpto := Round((caspar.in + (caspar.out - caspar.in) * slide_seek / 100.3)/2)*2		; / 101 for safe end search,   ; make even number  2021/3/23

;casparamcp.sendText("call " . caspar.chindex . "- seek " . caspar.jumpto . "`r`n")
casparamcp.sendText("call " . caspar.channel_layer . " seek " . caspar.jumpto . "`r`n")
updatelog("call " .  caspar.channel_layer . " seek " . caspar.jumpto)
caspar.timeremold := 999999999
SetTimer, casparpbchk, -600								; added 2019/8/19   prevent unwanted pb_index incresing

return


dissolve:
GuiControlGet, chk_dissolve
GuiControlGet, chk_bgload

if chk_dissolve
	caspar.transition := " MIX " .  caspar.frame_dissolve . "  "			; changed 2020/8/3
else
	caspar.transition := ""							; change from [MIX 0]  to [null]			change 2021/3/2
	; caspar.transition := " MIX 0 "				; changed from 1 to 0  (2020/6/22)
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

	;casparamcp.sendText("set 2 mode NTSC`r`n")			; set channel_grid window format
	casparamcp.sendText("mixer " .  caspar.grid_out . " grid 2`r`n")			; window consumer 3 -> make 2x2 multiview
	Sleep, 300
	casparamcp.sendText("channel_grid`r`n")			; set channel_grid window format


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


chkbox_update:
GuiControlGet, chk_autoload
GuiControlGet, chk_autoadd
GuiControlGet, chk_dissolve
GuiControlGet, chk_bgload

if chk_dissolve
	caspar.transition := " MIX " .  caspar.frame_dissolve . "  "			; changed 2020/8/3
else
	caspar.transition := ""							; change from [MIX 0]  to [null]			change 2021/3/2
	; caspar.transition := " MIX 0 "				; changed from 1 to 0  (2020/6/22)
printobjectlist(caspar)

print("auto load / auto add / dissolve / bgload  = " . chk_autoload . "  /  " . chk_autoadd . "  /  " . chk_dissolve . "  /  " . chk_bgload, true, true)

return



casparpbchk:
;; New check with python enabled ----------------------  2020/12/27

	if (flags.debug_mode)
	{
		GuiControl,, %hdebug1%, % "caspar" . "`n" . printobjectlist(caspar)
		GuiControl,, %hdebug2%, % "info_caspar" . "`n" . printobjectlist(info_caspar)
		GuiControl,, %hdebug3%, % "media" . "`n" . printobjectlist(media)
		GuiControl,, %hdebug4%, % "lvdata" . "`n" . printobjectlist(lvdata) . "`n" . chk_loop
	}


	;caspar.timerem := info_caspar.time2_clip + info_caspar.time1_clip - info_caspar.time1_foreground				; old manner
	;caspar.nb_times  := info_caspar.time2_clip														; old manner
	caspar.timerem := info_caspar.time_rem													; change 2021/3/16
	caspar.nb_times  := info_caspar.time_rem + info_caspar.time_run			; change 2021/3/16
	caspar.foregroundfile := info_caspar.filename_foreground
	caspar.backgroundfile := info_caspar.filename_background



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

	if (!caspar.foregroundfile)				; added 2020/11/30
		caspar.status := "EJECT"				; status is EJECT if there is no foreground file
	/*
	time1_clip ; seek position (at load)
	time2_clip ; duration (at load)

	time1_foreground ; current pb position
	time2_foreground ; file duration
    */

	if (caspar.foregroundfile <> caspar.foregroundfileold)				; There is foreground file name change
	{
		WinSetTitle, ahk_id %hmygui%, , % title . " [" . caspar.address_caspar . "/" . caspar.channel_layer . "]  --  " . caspar.foregroundfile
		updatelog("foreground file change detected  -- " . caspar.foregroundfile)
	}

	caspar.foregroundfileold := caspar.foregroundfile

	;if (caspar.listplay and (caspar.timerem > caspar.timeremold) and caspar.timerem) 	; next clip load foreground, update media property tex
	if (chk_loop != "SINGLE CLIP")					; added 2020/11/30
		if (caspar.listplay)										; added 2021/3/24
		{
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
		}


	caspar.pbindex_next := caspar.pbindex + 1				;  move to here (2020/6/16)
	if (caspar.listplay and (caspar.pbindex = caspar.pbindex_max) and (chk_loop = "PLAYLIST"))		; PLAYLSIT LOOP CASE, Last clip playing, load first clip
		caspar.pbindex_next := 1


	; update 2020/3/19  osd display, GUI time code display code update -----------------------------------------------------------------------------------------------------
	tc_osd.line1 := "[" . caspar.status . "] " . secondtotc_drop(info_caspar.time_run) . "/" .  secondtotc_drop(caspar.nb_times)
	tc_osd.line2 := "REM " . secondtotc_drop(caspar.timerem)
	if (caspar.listplay and (caspar.pbindex < caspar.pbindex_max))
		tc_osd.line2 := "REM " . secondtotc_drop(caspar.timerem) . "/" . secondtotc_drop(caspar.timerem + duration_plist[caspar.pbindex+1])

	/*			; detailed status report (Default)
	if (caspar.character_out)
		tc_udp.sendtext(tc_osd.line1 . "<br>" . tc_osd.line2)
	*/

/*		Disbled by python caspar info reader ==============   2020/12/27
	if (caspar.character_out)
		if (flags.simple_tc)
			tc_udp.sendtext(secondtotc_drop(info_caspar.time1_foreground - info_caspar.time1_clip) )		; Very simple status report (TS-6 request)
		else
			tc_udp.sendtext(tc_osd.line1 . "<br>" . tc_osd.line2)					; detailed status report (Default)
*/

	;ToolTip, % caspar.pbindex . "  " . caspar.timerem . "/" . caspar.timeremold  . "  -  " . caspar.foregroundfile . "   -  " . caspar.backgroundfile
	GuiControl,, %htext_tc%, % tc_osd.line1
	GuiControl,, %hrem_tc%, % tc_osd.line2
	if (caspar.nb_times)
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
		else												; Next line is contains normal clip information (in, out, dur, clip name)
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


;	casparamcp.sendText("info " .  caspar.channel_layer . "`r`n")


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
;SetTimer, casparpbchk, -100			; after 2020/6/19
SetTimer, casparpbchk, -500			; python info enabled (2020/12/27)

return


casparpbchk_without_python_reader:

;FileAppend, % caspar.in . "  " . caspar.out . "`r`n", *
xmlfile := SubStr(tcptext, InStr(tcptext, "<?xml"))			; Find xml header
if (SubStr(xmlfile, 1, 5) = "<?xml")				; there is valid xml return text		improve 2020/6/12 (changed, string length detection -> find xml header)
{
	info_caspar := read_caspar_info(xmlfile)
	;showobjectlist(info_caspar)
	;showobjectlist(caspar)

	if (flags.debug_mode)
	{
		GuiControl,, %hdebug2%, % printobjectlist(info_caspar)
		GuiControl,, %hdebug1%, % printobjectlist(caspar)
		GuiControl,, %hdebug3%, % printobjectlist(media)
		GuiControl,, %hdebug4%, % printobjectlist(lvdata) . "`n" . chk_loop
	}

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

	if (!caspar.foregroundfile)				; added 2020/11/30
		caspar.status := "EJECT"				; status is EJECT if there is no foreground file
	/*
	time1_clip ; seek position (at load)
	time2_clip ; duration (at load)

	time1_foreground ; current pb position
	time2_foreground ; file duration
    */

	if (caspar.foregroundfile <> caspar.foregroundfileold)				; There is foreground file name change
	{
		WinSetTitle, ahk_id %hmygui%, , % title . " [" . caspar.address_caspar . "/" . caspar.channel_layer . "]  --  " . caspar.foregroundfile
		updatelog("foreground file change detected  -- " . caspar.foregroundfile)
	}

	caspar.foregroundfileold := caspar.foregroundfile

	;if (caspar.listplay and (caspar.timerem > caspar.timeremold) and caspar.timerem) 	; next clip load foreground, update media property tex
	if (chk_loop != "SINGLE CLIP")					; added 2020/11/30
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

	/*			; detailed status report (Default)
	if (caspar.character_out)
		tc_udp.sendtext(tc_osd.line1 . "<br>" . tc_osd.line2)
	*/

	if (caspar.character_out)
		if (flags.simple_tc)
			tc_udp.sendtext(secondtotc_drop(info_caspar.time1_foreground - info_caspar.time1_clip) )		; Very simple status report (TS-6 request)
		else
			tc_udp.sendtext(tc_osd.line1 . "<br>" . tc_osd.line2)					; detailed status report (Default)


	;ToolTip, % caspar.pbindex . "  " . caspar.timerem . "/" . caspar.timeremold  . "  -  " . caspar.foregroundfile . "   -  " . caspar.backgroundfile
	GuiControl,, %htext_tc%, % tc_osd.line1
	GuiControl,, %hrem_tc%, % tc_osd.line2
	if (caspar.nb_times)
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
		else												; Next line is contains normal clip information (in, out, dur, clip name)
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

	casparamcp.sendText("info " .  caspar.channel_layer . "`r`n")


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
	if (nbr <= 0)				; check if nbr > 1			added 2020/12/30
		return
	lv_color_row_reset()
	LV_GetText(outputvar, nbr, 1)
	FileAppend, Change LV row %outputvar% ---- %nbr%  , *
	LV_Modify(nbr,,"■ " . outputvar . " ▶")
	;LV_Modify(nbr, "-Select")
	LV_ModifyCol(1, "autohdr")
	LV_Modify(nbr, "Vis")				; Added 2021/4/19	Auto scroll listview and show to user
}

lv_color_row_reset()
{
	Loop, % LV_GetCount()
	{
		LV_Modify(A_Index,, A_Index)
	}
}


/*

lv_color_row_backup(nbr)
{
	global VLV
	Loop, % LV_GetCount()
		LVA_SetCell("VLV", A_Index, 0, "0xFFFFFF")						; Initialize playlist color
	LVA_SetCell("VLV", nbr, 0, "0x56B2C4")			; Update Single playlist color
	LVA_Refresh("VLV")
	LV_Modify(nbr, "-Select")

}

lv_color_row_reset_backup()
{
	global VLV
	Loop, % LV_GetCount()
	{
		LVA_SetCell("VLV", A_Index, 0, "0xFFFFFF")						; Initialize playlist color
		LV_Modify(A_Index, "-Select")
	}
	LVA_Refresh("VLV")
}

*/

loadlvclip(byref caspar, byref lvdata)
{
	global hstatus, casparamcp
	caspar.in := tctoframe_drop(lvdata.in) * caspar.field_factor			; x2  for interlaced video for v2.3 and higher
	caspar.out := tctoframe_drop(lvdata.out) * caspar.field_factor  	; x2  for interlaced video
	caspar.duration := "LENGTH " . (caspar.out - caspar.in)
	updatelog("LV Clip duration is " . caspar.duration)

	/*			Disabled 2021/3/30			; powered by New Python osc reader
	if (caspar.out > 0)						; for Engine version 2.1 and lower // added  2021/3/8
	{
		casparamcp.sendText("data store mark_in " . caspar.in . "`r`n")
		casparamcp.sendText("data store mark_out " . caspar.out . "`r`n")
	}
	*/
	text_to_send := "loadbg " .  caspar.channel_layer . " """ . lvdata.clip . """ SEEK " . caspar.in . " " . caspar.duration .  " " . caspar.transition .  "  auto`r`n"
	casparamcp.sendText(text_to_send)		; next clip load background
	updatelog("Playlist loading index is  [" . caspar.pbindex . "]")
	updatelog("[loadlvclip]   " . text_to_send)
	GuiControl,, %hstatus%,% "LV Clip loaded -- " . lvdata.clip	. "  /  " . caspar.in . "  /  " . caspar.duration
}



helpbox:
updatelog("Help button pressed")
;if (!caspar.remote_client)			; Check if remote client mode
	;Run, %osc_reader%			; Disabled 2021/3/16 ~

;----------------   Reset python UDP socket ------------------------------  added 2021/1/5
python_info := ""
python_info := new class_python_info("127.0.0.1", 34410)
python_info.run_reader()
;----------------------------------------------------------------------------

updatelog("Close python reader by help button")
WinClose, % python_info.reader_title

if caspar.character_out				; only valid for local client mode, Added 2020/12/16
{

	casparamcp.sendText("clear " . caspar.character_out . "-2`r`n")				; Clear TC
	casparamcp.sendText("play " . caspar.character_out . "-2 [html] " . caspar.html_tc . "`r`n")				; load html tc

}    				; update 2020/3/19 --------------------------------------------------------------------


FileRead, helpfile, helpfile.txt
MsgBox,,Help Information, % helpfile . "`nEngine running Hour " . (health.age / 3600)
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


addlist_old:
updatelog("Add list Button Pressed")
if !media.fullpath
	return
Gui, Submit, NoHide

caspar.medianame := winpathtocaspar(media.fullpath, caspar.mediapath)
lvdata.status := LV_GetCount()+1
lvdata.clip := caspar.medianame
lvdata.in := cue_in
lvdata.out := cue_out
lvdata.audio_format := media.audio_format

if (tctosecond(cue_in, 29.97) >= tctosecond(cue_out, 29.97))			; Mark out point is prior to Mark in point
{
	lvdata.out := secondtotc(media.duration)
	if caspar.listload					; clip is loaded from playlist,  to get correct media duration we have to analysis media again
	{
		analyse_media(media, mi)
		lvdata.out := secondtotc(media.duration)
		updatelog("Clip is loaded from playlist, mark in and mark out is not time order --> analysis media  and get entire duration to correct Mark out")
	}
	cue_out := lvdata.out													; added 2021/4/1
	GuiControl,,%hcue_out%, % lvdata.out								; added 2021/4/1
	MsgBox,, Attention, Out 지점 오류. 클립 끝까지 확장합니다, 1
}

lvdata.duration := get_tc_duration(cue_in, cue_out)

lvdata.title := splitcasparpath(caspar.medianame)

if (playlist.insertmode and playlist.selected_row)				; insert mode and there is selected row
{
	lv_insertall(playlist.selected_row+1, lvdata)
	renumber_pl()
	print("Insert Playlist at line number " . playlist.selected_row , true, true)
	pbindex_insert_chk()
}
else
{
	lv_addall(lvdata)
	print("Add Playlist at last line", true, true)
}

LV_ModifyCol(, AutoHdr)
updatelogall("Adding -- [" . lvdata.status . " - " . lvdata.clip  . " - " . lvdata.in . " - " . lvdata.out . "]" )
SetTimer, removetooltip, -1000

duration_plist := get_plist_duration()		; update playlist duration array
;if caspar.listplay																; Restore playlist play information added 2019/8/21
;	updatepropertytextlv(caspar, media)							'; Removed 2020/12/27  (property text update is done when mpv closed)
caspar.pbindex_max := LV_GetCount()

return



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
lvdata.audio_format := media.audio_format

if (tctosecond(cue_in, 29.97) >= tctosecond(cue_out, 29.97))			; Mark out point is prior to Mark in point
{
	lvdata.out := secondtotc(media.duration)
	;if caspar.listload					; clip is loaded from playlist,  to get correct media duration we have to analysis media again  (before 2021/7/2)
	if !flags.from_explorer					; clip is loaded from playlist,  to get correct media duration we have to analysis media again (new 2021/7/2)
	{
		analyse_media(media, mi)
		lvdata.out := secondtotc(media.duration)
		updatelog("Clip is loaded from playlist, mark in and mark out is not time order --> analysis media  and get entire duration to correct Mark out")
	}
	cue_out := lvdata.out													; added 2021/4/1
	GuiControl,,%hcue_out%, % lvdata.out								; added 2021/4/1
	MsgBox,, Attention, Out 지점 오류. 클립 끝까지 확장합니다, 1
}

lvdata.duration := get_tc_duration(cue_in, cue_out)

lvdata.title := splitcasparpath(caspar.medianame)

if (playlist.insertmode and playlist.selected_row)				; insert mode and there is selected row
{
	lv_insertall(playlist.selected_row+1, lvdata)
	renumber_pl()
	print("Insert Playlist at line number " . playlist.selected_row , true, true)
}
else
{
	lv_addall(lvdata)
	print("Add Playlist at last line", true, true)
}

LV_ModifyCol(, AutoHdr)
updatelogall("Adding -- [" . lvdata.status . " - " . lvdata.clip  . " - " . lvdata.in . " - " . lvdata.out . "]" )
SetTimer, removetooltip, -1000

duration_plist := get_plist_duration()		; update playlist duration array
;if caspar.listplay																; Restore playlist play information added 2019/8/21
;	updatepropertytextlv(caspar, media)							'; Removed 2020/12/27  (property text update is done when mpv closed)
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


lvdeletesingle_old:
if !LV_GetNext(0)
	return

if (LV_GetCount("S") = LV_GetCount())				; delete all LV
{
	LV_Delete()
	caspar.pbindex := 0
	updatelog("Clear Current Playlist")
}

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

	if (row > caspar.pbindex )				; deleted row  does not caspar pbindex
		lv_color_row(caspar.pbindex)		; added 2020/12/27

		updatelog("Delete single row " . row)

}

duration_plist := get_plist_duration()		; update playlist duration array
caspar.pbindex_max := LV_GetCount()

return



lvdeletesingle:
if !LV_GetNext(0)
	return

if (LV_GetCount("S") = LV_GetCount())				; delete all LV
{
	LV_Delete()
	caspar.pbindex := 0
	updatelog("Clear Current Playlist")
}

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
	updatepropertytextlv(caspar, media)
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



moveup_old:
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

if caspar.pbindex
	lv_color_row(caspar.pbindex)				; added 2020/12/25

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


moveup:					; Changed 2021/6/16 with  new 'renumber_pl()'
Critical
if LV_GetNext(0) < 2
	return
row := LV_GetNext(0)
if !row
	return

updatelog("LV move up / selected row number " . row)
lvdata := lv_getall(row - 1)
lv_modifyall(row - 1, lv_getall(row))
lv_modifyall(row, lvdata)
LV_Modify(row, "-Select")
LV_Modify(row-1, "Select")
LV_ModifyCol()
duration_plist := get_plist_duration()		; update playlist duration array
renumber_pl()
updatepropertytextlv(caspar, media)
return



renumber_pl_old()
{
	lvdata := Object()
	Loop, % LV_GetCount()
	{
		lvdata := lv_getall(A_Index)
		lvdata.status := A_Index
		lv_modifyall(A_Index, lvdata)
	}
}


renumber_pl()			; New 2021/6/16
{
	global caspar, media
	lvdata := Object()
	Loop, % LV_GetCount()
	{
		lvdata := lv_getall(A_Index)
		status := RegExReplace(lvdata.status, "\d+", A_Index)				; Replace status with new ordered number
		len_status := StrLen(RegExReplace(lvdata.status, "\d+", ""))		; Check if current row is loaded in sdi channel
		lvdata.status := status
		lv_modifyall(A_Index, lvdata)
		if len_status			; There is "■ ▶" mark
		{
			caspar.pbindex := A_Index				; This is new playback index
			print("New playback index is " . A_Index, true, true)
		}
	}
}


movedown_old:
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

if caspar.pbindex
	lv_color_row(caspar.pbindex)				; added 2020/12/25

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



movedown:				; Changed 2021/6/16 with  new 'renumber_pl()'
Critical
if LV_GetNext(0) >= LV_GetCount()
	return
row := LV_GetNext(0)

if !row
	return

updatelog("LV move down / selected row number " . row)
lvdata := lv_getall(row)
lv_modifyall(row, lv_getall(row + 1))
lv_modifyall(row + 1, lvdata)
LV_Modify(row+1, "Select")
LV_Modify(row, "-Select")
LV_ModifyCol()
duration_plist := get_plist_duration()		; update playlist duration array
renumber_pl()
updatepropertytextlv(caspar, media)
return



lvclick:			; New 2021/6/16
if (A_GuiEvent = "I")
	return
if (A_GuiEvent = "C")
	return

print("Listview GUI Event is [ " . A_GuiEvent . " ]")
playlist.selected_row :=LV_GetNext(0)
print("Selected row is " . playlist.selected_row,, true)
if !playlist.selected_row
	return


if ((A_GuiEvent = "DoubleClick") or (A_GuiEvent = "D"))
{
	if caspar.listplay
	{
		updatelogall("You cannot edit during playlist playing")
		SetTimer, removetooltip, -2000
		return
	}
	else		; During listplaying, pbindex cannot be modified manually
	{
		updatelog("Load LV clip by Click or Drag,  LV line number " . playlist.selected_row )
		if chk_pause(playlist.selected_row )
		{
			GuiControl,, %hstatus%, Cannot load Pause Line, try another Line
			return												; LV Pause row is selected
		}
		flags.from_explorer := 0		; new 2021/7/2
		updatepropertytextlv_click(playlist.selected_row)
		;caspar.pbindex := playlist.selected_row                            ; Disabled   2021/7/2
	}

	;caspar.listload := 1			; added 2019/10/6			Disabled 2021/7/2
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
	global hcue_in, hcue_out, hmediainfo, hstatus, hpbnumber, lvdata
	lvdata := lv_getall(caspar.pbindex)
	updatelog("Get Media from LV list index " . caspar.pbindex)
	updatelog("--" . A_LineNumber . "--`r`n----lvdata object is----`r`n" . printobjectlist(lvdata))
	caspar.timeremold  := 5184000			; prevent unwanted pbindex increasing during list play
	caspar.medianame := lvdata.clip
	GuiControl, text, %hcue_in%, % lvdata.in
	GuiControl, text, %hcue_out%, % lvdata.out
	media.fullpath := ""
	; caspartowinpath(caspar, media)		; find real path by caspar media name
	media.fullpath := caspartowinpath(caspar)		; find real path by caspar media name
	media.filename := get_filenameonly(media.fullpath)
	media.audio_format := lvdata.audio_format
	GuiControl,,%hmediainfo%, % "Load Clip --------------`r`n`r`n" . "[" . lvdata.status . "] - " . lvdata.title . "`r`n`r`n" . lvdata.clip . "`r`n`r`n" . lvdata.in . " - " . lvdata.out . "`r`n`r`nDUR [" . lvdata.duration . "]"
	GuiControl,,%hstatus%, % "Update Media Property -- " . media.fullpath
}

caspartowinpath(byref caspar)
{
	tempfile := caspar.mediapath . caspar.medianame
	tempfile := StrReplace(tempfile, "/", "\")
	path := caspar.mediapath
	print("Start casparpath scan (Get media name from caspar.medianame) = " . path, true)
	Loop, Files, %path%\*.*, R
	{
		SplitPath, A_LoopFileFullPath, outfilename, outdir, outextension, outnamenoext, outdrive
		if (outextension = "srt")				; skip srt extension
			continue
		name = %outdir%\%outnamenoext%
		;FileAppend, `r`n%name%, *
		if (name = tempfile)
		{
			print("Media full path is " . A_LoopFileFullPath, true)
			return A_LoopFileFullPath
			;media.fullpath := A_LoopFileFullPath
			;media.filename := outfilname
		}
	}
	return "Path conversion Fail"
}


updatepropertytextlv_click(number_row)			; New 2021/7/2   (Update property windows from LV data)
{
	global hcue_in, hcue_out, hmediainfo, hstatus, hpbnumber, media, caspar, lvdata
	lvdata := lv_getall(number_row)
	updatelog("Get Media from LV list index by click = " . number_row)
	GuiControl, text, %hcue_in%, % lvdata.in
	GuiControl, text, %hcue_out%, % lvdata.out
	media.fullpath := ""
	media.fullpath := caspartowinpath_fromlv(lvdata.clip)		; find real path by caspar media name
	media.filename := get_filenameonly(media.fullpath)
	media.audio_format := lvdata.audio_format
	GuiControl,,%hmediainfo%, % "Load Clip --------------`r`n`r`n" . "[" . lvdata.status . "] - " . lvdata.title . "`r`n`r`n" . lvdata.clip . "`r`n`r`n" . lvdata.in . " - " . lvdata.out . "`r`n`r`nDUR [" . lvdata.duration . "]"
	GuiControl,,%hstatus%, % "Update Media Property -- " . media.fullpath
}


caspartowinpath_fromlv(medianame)			; New 2021/7/2			(path conversion  caspar -> windows path)
{
	global caspar					; Need for caspar media path browsing
	tempfile := caspar.mediapath . medianame
	tempfile := StrReplace(tempfile, "/", "\")
	path := caspar.mediapath
	print("Start casparpath scan (Get media name from playlist) = " . path, true)
	Loop, Files, %path%\*.*, R
	{
		SplitPath, A_LoopFileFullPath, outfilename, outdir, outextension, outnamenoext, outdrive
		if (outextension = "srt")				; skip srt extension
			continue
		name = %outdir%\%outnamenoext%
		if (name = tempfile)
		{
			;media.fullpath := A_LoopFileFullPath
			;media.filename := outfilname
			print("Media full path is " . A_LoopFileFullPath, true)
			return A_LoopFileFullPath
		}
	}
	return "Path conversion Fail"
}



get_filenameonly(filename)
{
	SplitPath, filename, outfilename, outdir, outextension, outnamenoext, outdrive
	return outfilename
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
;after       STATUS|TITLE|IN|OUT|DURATION|CLIP LIST|AUDIO_FORMAT

lv_addall(data)
{
	;LV_Add(,data.status, data.clip, data.in, data.out)
	LV_Add(,data.status, data.title, data.in, data.out, data.duration, data.clip, data.audio_format)
}

lv_insertall(row, data)				; New !! 2021/6/14
{
	LV_Insert(row,, data.status, data.title, data.in, data.out, data.duration, data.clip, data.audio_format)
}


lv_modifyall(row, data)
{
	;LV_Modify(row,, data.status, data.clip, data.in, data.out)
	LV_Modify(row,, data.status, data.title,data.in, data.out, data.duration, data.clip, data.audio_format)
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
	LV_GetText(temp, row, 7)
	data.audio_format	:= temp
	return data
}



onAMCP_TCPRecv(this)			; ACMP protocol receiving message, tcp block mode
{
	global hstatus, tcptext, watchdog, tts, hchannel_condition
	static buffer_recv := Object()

	tcptext := this.RecvText(8000)
	print(tcptext)
	if StrLen(tcptext)
		watchdog.tick_amcp := A_TickCount
	;FileAppend, `n--------------------------------------------------------------------------`n, *
	;FileAppend, %tcptext%`n, *
	text_short := SubStr(tcptext,1,40)  			; check  first 40 character
	if (InStr(text_short, "LOADBG OK") or InStr(text_short, "LOAD OK"))
	{
		playtts(tts, "load_ok_kr.mp3")
		GuiControl, +cGreen, %hchannel_condition%
	}

	if (InStr(text_short, "LOADBG FAIL") or InStr(text_short, "LOAD FAIL"))
	{
		playtts(tts, "load_fail_kr.mp3")
		updatelog("Loadbg fail")
		GuiControl, +cRed, %hchannel_condition%
	}
	if !InStr(text_short, "INFO")
		if !InStr(tcptext, "</")						; Discard XML text
		{
			buffer_recv[1] := buffer_recv[2]
			buffer_recv[2] := buffer_recv[3]
			buffer_recv[3] := buffer_recv[4]
			buffer_recv[4] := tcptext

			text_to_show := buffer_recv[1] . buffer_recv[2] . buffer_recv[3] . buffer_recv[4]
			;GuiControl,, %hstatus%, %text_short%
			GuiControl,, %hstatus%, %text_to_show%
			;updatelog(text_short)
			updatelog(SubStr(tcptext,1,200))		; Log only first  some character
		}
}

initcaspar(ByRef cas)
{
	fullpath := cas.fullpath
	title := cas.title
	Process, Exist, casparcg.exe
	if !ErrorLevel
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
		cas.pid := ErrorLevel
		updatelog("There is already running server with pid " . cas.pid)
	}
}


initcaspar_backup(ByRef cas)
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
	FileAppend, % lvdata.status . "|" . lvdata.title . "|" . lvdata.in . "|" . lvdata.out .  "|" . lvdata.duration . "|" .  lvdata.clip  . "|" . lvdata.audio_format . "`r`n", % getfile_plist(plselect)
	temp_plist .= lvdata.status . A_Tab . lvdata.title . A_Tab . lvdata.in . A_Tab . lvdata.out .  A_Tab . lvdata.duration . A_Tab .  lvdata.clip  "`r`n"
	ToolTip, % A_Index . " Line saved ~~"
	;Sleep, 10
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
MsgBox, 0x104, ATTENTION, 정말로 플레이 리스트를 불러 올까요 ?, 5				; added 2020/9/29  ,  add timeout 2021/1/5
IfMsgBox, No
	return
IfMsgBox, Timeout
	return
LV_Delete()
caspar.pbindex := 0			; added 2020/12/25
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
	lvdata.audio_format  := readarray[7]
	if (!StrLen(lvdata.audio_format))
		lvdata.audio_format := "mono-8"				; Set default audio format (old playlist load)
	lv_addall(lvdata)
	temp_plist .= lvdata.status . A_Tab . lvdata.title . A_Tab . lvdata.in . A_Tab . lvdata.out .  A_Tab . lvdata.duration . A_Tab .  lvdata.clip  . A_Tab . lvdata.audio_format . "`r`n"
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

tc := new show_liveTC(media.fullpath)
if tc.extract_tc()
{
	updatelog("Live TC Found... Create srt file....")
	tc.write_srt(mpv.sub_path , media.duration)
}

runpreview(media, mpv)
GuiControl,, %hstatus%, % "Preview MPV Launched with PID " . mpv.pid

SetTimer, mpvchk_once, -300
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
updatelog("[Preview SDI] button pressed")
updatelog("media.fullpath = " . media.fullpath)
updatelog("info_caspar.filepath_foreground = " . info_caspar.filepath_foreground)

if (info_caspar.filepath_foreground)				; There is valid foreground file path
{
	if (media.fullpath != info_caspar.filepath_foreground)			; restore media.fullpath from caspar foreground playback file
	{
		GuiControl,, %hstatus%, There is difference between caspar pb clip and media loaded clip
		updatelog(" There is difference between caspar pb clip and media loaded clip, analysing media - " . info_caspar.filepath_foreground)
		media.fullpath := info_caspar.filepath_foreground
		;media.fullpath := caspar.mediapath . "\" . StrReplace(info_caspar.filename_foreground, "/", "\")		; get full media name from caspar info xml
		analyse_media(media, mi)
		updatepropertytext(hmediainfo, media)
	}
}
else				; added 2020/11/19			(fail to retrieve sdi playback information)
{
	updatelog("Preview SDI failed, Cannot retrieve clip information from caspar engine")
	MsgBox, 0, Caution, Cannot read playback information from sdi channel !!!, 1
	GuiControl, Enable, %hpreviewsdi%					; Enable preview-sdi button
	return
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
SetTimer, mpvchk_once, -300

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
	Run, %runtext%,, Hide, pid_mpv
	mpv.pid := pid_mpv
	updatelog("run command ---- `r`n" . runtext)
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
	;mpvrun := ""			; Disabled 2022/2/14
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

;clear_mpv_console(mpvrun, mpv)			; Disabled 2022/2/14

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
updatelog("[MEDIAFOLDER] button pressed")
try
	run, % caspar.mediapath
catch, err
{
	updatelog(printobjectlist(err))
	GuiControl,, %hstatus%, % "Error Opening Folder / " . err.Extra
}
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

	; -------------------------------------- added 2021/4/1 ----------------------
	GuiControlGet, cue_in
	GuiControlGet, cue_out
	if (tctosecond(cue_in, 29.97) >= tctosecond(cue_out, 29.97))			; Mark out point is prior to Mark in point
	{
		cue_out := secondtotc(media.duration)
		;if caspar.listload					; clip is loaded from playlist,  to get correct media duration we have to analysis media again  ////		Disabled  2021/7/23
		if !flags.from_explorer		; New 2021/7/2
		{
			analyse_media(media, mi)
			cue_out := secondtotc(media.duration)
			updatelog("Clip is loaded from playlist, mark in and mark out is not time order --> analysis media  and get entire duration to correct Mark out")
		}
		GuiControl,,%hcue_out%, %cue_out%
	}
	;--------------------------------------------------------------------------------
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

	caspar.jumpto :=  Round( temp * 29.97 )  * caspar.field_factor 				; for interlaced video, x2 is req.
	casparamcp.sendText("call " .  caspar.channel_layer . " seek " . caspar.jumpto . "`r`n")
	updatelog("call " . caspar.chindex . "-" . caspar.layer_caspar  . " seek " . caspar.jumpto)
	caspar.timeremold := 999999999
	SetTimer, casparpbchk, -600								; added 2019/8/19   prevent unwanted pb_index incresing
}

return



syncplay:
GuiControlGet, chk_autoload
Process, Exist, % mpv.pid
if ErrorLevel and chk_autoload
{
	casparamcp.sendText("play " .  caspar.channel_layer . "`r`n")
	updatelog("Sync play started")
}
return

/*			---------------- Disabled 2022/2/14   Do not use !!!!! -----------------

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


*/


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
{
	caspar.listplay := 0
	GuiControl, Hide, %hlistplayled%				; hide PLAYLIST PLAY LED		added 2020/11/18
}


casparamcp.sendText("CALL " . caspar.chindex . "-1 " . caspar.loop . "`r`n")


updatelog("CALL " . caspar.chindex . "-1 " . caspar.loop)
return


load:				; Improve 2021/3/2  (standby accurate frame at load time with seek command)
						; Always load even numbered frame for good interlaced output
GuiControlGet, cue_in,, %hcue_in%
GuiControlGet, cue_out,, %hcue_out%
GuiControlGet, chk_loop,, %hchk_loop%
updatelog("[LOAD] Button Pressed. current timerem is " . caspar.timerem)
;caspar.loop := looparray[chk_loop]
;ToolTip % chk_loop . "   " . caspar.loop
caspar.loop := (chk_loop = "SINGLE CLIP") ? "LOOP" : ""
; don't use loop 1 or loop 0 with loagbg command (it don't work)  2020/11/19
;if (chk_loop =  "SINGLE CLIP")
;	caspar.loop := "LOOP"
caspar.listplay := 0
caspar.listload := !flags.from_explorer			; New  2021/7/2
caspar.loadbg_try := 0				; added 2020/7/9

caspar.in := tctoframe_drop(cue_in) * caspar.field_factor 	   	; for interlaced video, x2 is req.

caspar.medianame := winpathtocaspar(media.fullpath, caspar.mediapath)

if cue_out			; if there is out point
{
	caspar.out := tctoframe_drop(cue_out) *  caspar.field_factor 	 	; for interlaced video, x2 is req.
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

;--- Disabled 2021/3/29 ---------------------
;casparamcp.sendText("data store mark_in " . tctoframe_drop(cue_in) . "`r`n")				; for Engine version 2.1 and lower // added  2021/3/8
;casparamcp.sendText("data store mark_out " . tctoframe_drop(cue_out) . "`r`n")		; for Engine version 2.1 and lower
;-----------------------------------------------

updatelog("--caspar.medianame-- at load time is = " . caspar.medianame)

if (flags.engine_version = "2.3")						; changed 2021/3/16
{
	casparamcp.sendText("loadbg " .  caspar.channel_layer . " """ . caspar.medianame . """ SEEK " . caspar.in . " " . caspar.duration . " " . caspar.loop  .  "`r`n")

	if (!chk_bgload)
	{
		;casparamcp.sendText("play " .  caspar.channel_layer  . "`r`n")				; changed 2020/6/10			(smooth clip load, show first frame on load)
		;casparamcp.sendText("pause " .  caspar.channel_layer . "`r`n")
		casparamcp.sendText("play " .  caspar.channel_layer  . "`r`n" . "pause " .  caspar.channel_layer  . "`r`n")				; new. 2021/3/29
		/*
		if (caspar.medianame != "/Path conversion Fail")
		{
			if (caspar.out > 10)						; add condition 2021/3/19 (seek with image file loading introduce casparcg exception)
			{
				casparamcp.sendText("call " . caspar.channel_layer . " seek " . caspar.in . "`r`n")							; added 2021/3/2
			}
			else
				updatelog("Very short clip loaded.... skipping [call] command, cue out is  " . caspar.out)			; image file. etc...
		*/
	}
}
else				; casparcg 2.1 or less
{
	if (!chk_bgload)
		casparamcp.sendText("load " .  caspar.channel_layer . " """ . caspar.medianame . """ SEEK " . caspar.in . " " . caspar.duration . " " . caspar.loop . "`r`n")
	else
		casparamcp.sendText("loadbg " .  caspar.channel_layer . " """ . caspar.medianame . """ SEEK " . caspar.in . " " . caspar.duration . " " . caspar.loop . "`r`n")
}
;updatelog(cmd_load . caspar.chindex . "-1 """ . caspar.medianame . """ SEEK " . caspar.in . " " . caspar.duration . " " . caspar.loop )
updatelog("Finish load command execution")

SetTimer, casparpbchk, -1000
ledon(hloadled)

if caspar.listload						; Load from play list
{
	if playlist.selected_row								; added 2022/4/18
		caspar.pbindex := playlist.selected_row			; New 2021/7/2
	lv_color_row(caspar.pbindex)
}
else
	lv_color_row_reset()				; Load from drag drop (explorer)

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


ledon_blue(handle)
{
	global buttonled
	for key, val in buttonled
	GuiControl, Hide, %val%				; hide all LED
	GuiControl, Show, %handle%		; Turn on LED
	GuiControl, +cBlue, %handle%	; Turn on LED with blue color
}


play:
updatelog("[PLAY] Button Pressed. current timerem is " . caspar.timerem)
caspar.listplay := 0

/*
if (caspar.listload)
	if (chk_loop = "PLAYLIST")
		updatelog("Playlist loop and PL clip loaded, Player enter to PL LOOP Mode")
*/

caspar.cmd_play := "PLAY "

;if ((caspar.timerem < caspar.preparenext) and (!chk_bgload))			; changed 2020/7/9
if ((caspar.loadbg_try) and (!chk_bgload))
	caspar.cmd_play := "RESUME "

playtts(tts, tts)

casparamcp.sendText(caspar.cmd_play .  caspar.channel_layer  . "`r`n")

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

playtts(tts, "playlistmode.mp3")


caspar.cmd_play := "PLAY "
;if ((caspar.timerem < caspar.preparenext) and (!chk_bgload))			; changed 2020/7/9
if ((caspar.loadbg_try) and (!chk_bgload))
	caspar.cmd_play := "RESUME "


casparamcp.sendText(caspar.cmd_play  .  caspar.channel_layer . "`r`n")

updatelog("[list play commad] " . caspar.cmd_play  .  caspar.channel_layer)
updatelog("pb index is " . caspar.pbindex)

;SetTimer, casparpbchk, -1000
ledon(hlistplayled)
;GuiControl,, %hpbnumber%,  % caspar.pbindex
return



pause:
caspar.listplay := 0
updatelog("[PAUSE] Button Pressed. current timerem is " . caspar.timerem)

casparamcp.sendText("pause " .  caspar.channel_layer . "`r`n")
updatelog("Pause command " .  caspar.channel_layer)
;SetTimer, casparpbchk, off

ledon(hpauseled)
return


GuiDropFiles:
if !InStr(A_GuiEvent, caspar.mediapath)
{
	GuiControl,, %hmediainfo%, % "경로 확인 !! `r`n`r`nMEDIA 폴더에 있는 클립만 로드 할 수 있습니다.`n`nMEDIA 폴더는 " .  caspar.mediapath . " 입니다"
	return
}

;caspar.listload := 0			; added 2019/10/6			Disabled 2021/7/2
flags.from_explorer := 1

for key, val in buttoncontrol				; Disable some buttons
	GuiControl, Disable, %val%
Sleep, 30		; wait until button disabled

GuiControl,, %hmediainfo%, 파일 분석중~~!!`r`n기다릴것
Sleep, 30		; wait until text gui changed

Loop, parse, A_GuiEvent, "`n", "`r"
{
	media.fullpath := A_LoopField
	analyse_media(media, mi)
	media.filename := get_filenameonly(media.fullpath)			; added 2020/12/27
	updatepropertytext(hmediainfo, media)
	GuiControl, text, %hcue_in%, % auto_markin(media.fullpath)
	GuiControl, text, %hcue_out%, % secondtotc(media.duration)
	if (InStr(A_GuiEvent, "`n") or chk_autoadd)							; multiple files are dropped
	{
		updatelog("[multiple file drop] or [auto add] is detected, add file to playlist  [ " . media.fullpath . " ]")
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

	SplitPath, fullpath, outfilename,  outdir, outextension, outnamenoext
	temp := outdir .  "\" . outnamenoext
	temp := StrReplace(temp, mediapath, "")
	temp := StrReplace(temp, "\", "/")
	FileAppend, % "`r`n-------- Winpath to caspar path -----------`r`nFullpath = " . fullpath . "`r`n" . "Mediapath = " .  mediapath . "`r`n" . "Result = " . temp, *
	return temp
}



pbindex_insert_chk()
{
	global caspar, playlist
	if (caspar.listplay)
	{
		if (playlist.selected_row < caspar.pbindex)
			caspar.pbindex += 1
		lv_color_row(caspar.pbindex)
		print("Increase Playback index by inserting list", true, true)
	}
}



GuiContextMenu:

if (A_GuiControl = "ADD ▶")				; Right Click ADD Button
{
	plist_add_pause(playlist.selected_row + 1)
	duration_plist := get_plist_duration()		; update playlist duration array, added 2019/8/23
	caspar.pbindex_max := LV_GetCount()
	renumber_pl()				; New 2021/6/15
	print("Add playlist pause", true, true)
	pbindex_insert_chk()
}

if (A_GuiControl = "LOAD |◁`r`nPREROLL")				; Right Click LOAD Button
{
	caspar.listplay := 0
	updatelog("[UNLOAD] button pressed")
	ledon_blue(hloadled)
	lv_color_row_reset()

	if (caspar.character_out )
		casparamcp.sendText("clear " . caspar.character_out . "`r`n")			; Unload character output video layer

	casparamcp.sendText("clear " . caspar.chindex . "`r`n")				; Unload main output video layer
	if (flags.engine_version = "2.1")
		Sleep, 210		; Sleep tells  to new python osc reader  that  channel is cleared 2021/3/12 (for caspar 2.1 or less)
	if (caspar.character_out )
	{
		casparamcp.sendText("play  " . caspar.channel_layer  . " empty`r`n")				; Unload main output video layer
		;casparamcp.sendText("clear " . caspar.character_out . "-1`r`n")			; Unload character output video layer
		casparamcp.sendText("play " . caspar.character_out . "-1 route://" . caspar.channel_layer  . "`r`n")			; reload character output channel (from pgm channel)
		casparamcp.sendText("play " . caspar.character_out . "-2 [html] " . caspar.html_tc . "`r`n")				; load html tc
	}
	updatelog("Send command  [clear " .  caspar.channel_layer . "]")
}

return

commercial:
updatelog("ALT CM button is pressed")
cm_start()
SetTimer, play, -1
return




GuiClose:

SetTimer, watchdog_chk, off
Run, taskkill /f /im mpv.com,, Hide
Run, taskkill /f /im mpv.exe,, Hide		; close all mpv player

WinClose, %title_remote%				; close remote proceessor
updatelog("------------------  Application Close -----------------------")

MsgBox, 4, Close Option, Caspar 엔진도 같이 닫을까요 ? (Yes - 송출 종료됨, No - 송출은 유지됨)
IfMsgBox yes			; close app with closing caspar
{
	SetTimer, casparpbchk, off
	WinClose, %osc_reader_title%			; close osc reader. 	Move to here, msgbox yes   2021/3/12
	casparamcp.sendText("clear "  caspar.channel_layer . "`r`n")
	Sleep, 200

	if (get_window_count(title) > 1)	; there is another sendust player
		ExitApp					; exit app immediately
	if caspar.remote_client			; remote client cannot close caspar engine
		ExitApp
	while WinExist(caspar.title)
	{
		casparamcp.sendText("klll`r`n")
		WinClose, Caspar info reader by sendust				; Close python caspar info reader 			added 2020/12/30
		updatelog("There is Engine process, Try to close it ")
		ControlSend,,q{enter}, % caspar.title
		Sleep, 500
		ControlSend,,q{enter}, % caspar.title
		Sleep, 500
		RunWait, taskkill /f /im casparcg.exe,, Hide
		Process, Exist, casparcg.exe
		if !errorlevel
			break
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


playtts(tts, tts_file)
{
	if !tts
		return

	try
		SoundPlay, %A_WorkingDir%\tts\%tts_file%
	catch, err
		printobjectlist(err)
}



plist_add_pause(index := 0)
{
	data := Object()
	data.in := "00:00:00.000"
	data.out := "00:00:00.000"
	data.duration := "00:00:00.000"
	data.clip := "=== PAUSE ==="
	data.title := "=== PAUSE ==="
	data.audio_format := "-----"
	data.status := LV_GetCount() + 1
	if (index = 1)									; Add pause at the last line
		lv_addall(data)
	else
		lv_insertall(index, data)				; Modified 2021/6/15
	LV_ModifyCol(, "AutoHdr")
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
	global mpv_filter, audio_monitor_filter
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

	sub_path := mpv.sub_path		; setup subtitle find path

	runtext = %mpvpath% %lavfilter%  %geometry%  %script%   --pause --keep-open --force-window=yes --window-scale=0.5 --hr-seek=yes --osd-level=3 --osd-fractions  --sub-align-x=right --sub-pos=20  --sub-paths="%sub_path%" "%mediapath%" --title "%title%"		; sub title option  added 2022/1/21
	Run, %runtext% ,,Hide,pid
	mpv.pid := pid

	;WinWait, ahk_pid %pid%,, 5
	;WinSetTitle, ahk_pid %pid%,, MPV Control Console
	;WinMove,  ahk_pid %pid%, ,20000 ,20000			; move away outside visible area

	; mpvrun := new consolerun(runtext,, "CP850")			Disabled 2022/2/14
	; mpv.pid := mpvrun.pid												Disabled 2022/2/14
	;WinWait, %title%,, 3
	;WinSet, Style, -0x20000, %title%					; remove minimize button
	;WinSet, Style, -0x30000, %title%					; remove maximize button
	;WinHide, ahk_pid %pid%
	updatelog("run command ---- `r`n" . runtext)
	updatelog("MPV launched with PID " . mpv.pid . "/ Geometry " . geometry . "  Mediapath = " . mediapath)
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
	timer := Func("tooltip_remove")
	SetTimer, % timer, -500
}


tooltip_remove()
{
	ToolTip
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
	temp := "`r`n--------   Print object list  ---------`r`n"
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
	frames := Abs(frames)
	if (frames < 0)
		sign := "-"
	else
		sign := ""
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

	return  sign . format("{1:.01d}:{2:.02d}:{3:.02d};{4:.02d}", hours, minutes, seconds, frame)
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

keyboardseek(sec)
{
	global casparamcp, caspar, info_caspar
	if (info_caspar.time1_foreground  < 0)
		info_caspar.time1_foreground  := 0
	if (info_caspar.time1_foreground > info_caspar.time2_foreground)
		info_caspar.time1_foreground  := info_caspar.time2_foreground

	position_max_frame := Round(info_caspar.time2_foreground * 59.94) - 1

	position_pb_frame  := info_caspar.time1_foreground  * 59.94
	position_new_frame := Round(position_pb_frame + sec * 59.94)
	if (position_new_frame < 0)
		position_new_frame := 0
	if (position_new_frame >= position_max_frame)
		position_new_frame := position_max_frame

	casparamcp.sendText("call " .  caspar.channel_layer  . "  seek " . position_new_frame .  "`r`n")
}


mklink(lnk)
{
	global hstatus
	FileSelectFolder, folder, ::{20d04fe0-3aea-1069-a2d8-08002b30309d}, 2, 마운트할 폴더를 선택 하세요
	folder := RegExReplace(folder, "\\$")  ; Removes the trailing backslash, if present.
	updatelog("Target folder for mount is " . folder)
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
		updatelog("Mount point is " . mountpoint)
		runstr = %comspec% /c mklink /d "%mountpoint%" "%folder%"
		updatelog("Try to execute command ... " . runstr)
		RunWait, %runstr%,,Hide
		if errorlevel
		{
			GuiControl,, %hstatus%, 마운트 실패
			updatelog("Error mount")
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
	global caspar
	layer_n := caspar.layer_caspar

	result  := xml.find_node_two("//channel/framerate")
	info.fps1_channel := result[1]
	info.fps2_channel := result[2]

	result  := xml.find_node_two("//channel/stage/layer/layer_" . layer_n . "/foreground/file/time")
	info.time1_foreground := result[1]
	info.time2_foreground := result[2]
	result  := xml.find_node_two("//channel/stage/layer/layer_" . layer_n . "/foreground/file/clip")
	info.time1_clip := result[1]
	info.time2_clip := result[2]

	result  := xml.find_node_two("//channel/stage/layer/layer_" . layer_n . "/background/producer")
	info.producer_background := result[1]
	result  := xml.find_node_two("//channel/stage/layer/layer_" . layer_n . "/background/file/name")
	info.filename_background := result[1]
	result  := xml.find_node_two("//channel/stage/layer/layer_" . layer_n . "/background/file/path")
	info.filepath_background := result[1]

	result  := xml.find_node_two("//channel/stage/layer/layer_" . layer_n . "/foreground/file/name")
	info.filename_foreground := result[1]

	if (info.filename_foreground)
	{
		info.filepath_foreground := caspar.mediapath . info.filename_foreground 		; new 2020/11/9 (for remote operation)
		info.filepath_foreground  := StrReplace(info.filepath_foreground, "/", "\")
	}
	else
		info.filepath_foreground  := ""
	/*			filepath_foreground --        below result  is not correct for remote operation
	result  := xml.find_node_two("//channel/stage/layer/layer_" . layer_n . "/foreground/file/path")
	info.filepath_foreground := StrReplace(result[1], "////", "/")						; replace four / to single /			added 2019/7/25
	info.filepath_foreground := StrReplace(info.filepath_foreground, "/", "\")
	info.filepath_foreground := StrReplace(info.filepath_foreground, "\\\", "\")			; replace three \ to single \ added 2020/11/6
	*/
	result  := xml.find_node_two("//channel/stage/layer/layer_" . layer_n . "/foreground/file/streams/file/streams_0/fps")
	info.fps1_stream := result[1]
	info.fps2_stream := result[2]
	result  := xml.find_node_two("//channel/stage/layer/layer_" . layer_n . "/foreground/loop")
	info.loop_foreground := result[1]
	result  := xml.find_node_two("//channel/stage/layer/layer_" . layer_n . "/foreground/paused")
	info.paused_foreground := result[1]
	result  := xml.find_node_two("//channel/stage/layer/layer_" . layer_n . "/foreground/producer")
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


print(text, log := false, status := false)
{
	global hstatus
	FormatTime, ftime, ,yyyy/MM/dd HH:mm:ss
	ftime .= "." A_MSec
	FileAppend, `n%ftime%  %text%, *
	if log
		updatelog(text)
	if status
		GuiControl,, %hstatus%, %text%
	return text
}


decode_python_info(text)
{
	global info_caspar, watchdog

	;watchdog.tick_amcp := A_TickCount				; Disable 2021/1/5
	rdata := Object()
	line := Object()
	Loop, Parse, text, "`r`n"
	{
		line := StrSplit(A_LoopField, "**")
		rdata[line[1]] := line[2]								; Data parser (key, value pair)
	}
	info_caspar.filename_foreground := rdata["name_foreground"]
	info_caspar.filename_background := rdata["name_background"]
	info_caspar.filepath_foreground := rdata["path_foreground"]
	info_caspar.loop_foreground := rdata["loop"]
	info_caspar.paused_foreground := rdata["paused"]
	info_caspar.producer_foreground := rdata["producer_foreground"]
	info_caspar.time1_clip := rdata["clip0"]							; Mark in position in second (clip)
	info_caspar.time2_clip := rdata["clip1"]							; Duration (Mark out - Mark in) in second (clip)
	info_caspar.time1_foreground := rdata["time0"]			; PB head position in second (normally indicate between mark_in and mark_out)
	info_caspar.time2_foreground := rdata["time1"]			; Entire Duration of clip (don't care about mark in, out)
	info_caspar.time_rem := rdata["time_rem"]
	info_caspar.time_run := rdata["time_run"]
	info_caspar.time_tick := rdata["time_tick"]
	info_caspar.smpte_dur := rdata["smpte_dur"]
	info_caspar.smpte_rem := rdata["smpte_rem"]
	info_caspar.smpte_run := rdata["smpte_run"]

	SetTimer, casparpbchk, -1
}





class show_liveTC					; Class for showing real time code while MPV preview  (added 2020/1/21)
{
	__New(path_full)
	{
		SplitPath, path_full, outfilename, outdir, outextension, outnamenoext, outdrive
		this.path_full := path_full
		this.outfilename := outfilename
		this.outnamenoext := outnamenoext
		this.found := False
	}

	extract_tc()
	{
		if RegExMatch(this.outfilename, "20\d\d[01]\d[0123]\d[-_][012]\d[0-5]\d[0-5]\d[.]", string_tc)			; 20220121-140201.mxf  year,month,day-hour,min,second
		{
			this.found := true
			this.start_srt := RegExReplace(string_tc, "[-_.]", "")		; save srt start Tc from file name
		}
		else
		{
			this.found := false
		}
		return this.found
	}


	write_srt(path_out, duration := 3600)			; Create srt file (path to output, duratoin in second)
	{
		new_path := RegExReplace(path_out, "\\$")
		if  (not InStr(FileExist(new_path), "D"))	 ; check if path is exist
			FileCreateDir, %new_path%
		path_full_srt := new_path . "\" . this.outnamenoext . ".srt"

		time_initial := 19990101000000			; Movie always start from TC 0
		time_srt := this.start_srt						; Display TC has a offset time (rec start time)

		hsrtfile := FileOpen(path_full_srt, "w")		; open file with overwrite mode
		Loop, % round(duration)
		{
			FormatTime, display_tc, %time_srt%, yyyy/MM/dd HH:mm:ss
			FormatTime, srt_tc, %time_initial%, HH:mm:ss
			text_srt = %A_Index%`r`n%srt_tc%.000 --> %srt_tc%.999`r`n%display_tc%`r`n
			hsrtfile.Write(text_srt)
			time_initial += 1, second
			time_srt += 1, second
		}
		result := hsrtfile.Close()
		return result
	}
			/*  srt format
		1
		00:00:00.000 --> 00:00:00.999
		2021/07/15 16:44:58
		2
		00:00:01.000 --> 00:00:01.999
		2021/07/15 16:44:59
		3
		00:00:02.000 --> 00:00:02.999
		2021/07/15 16:45:00
		4
		00:00:03.000 --> 00:00:03.999
		2021/07/15 16:45:01
		5
		00:00:04.000 --> 00:00:04.999
		2021/07/15 16:45:02
		6
		00:00:05.000 --> 00:00:05.999
		2021/07/15 16:45:03

		*/
}



class c_tcpsend					; tcpsend class for non block tcp socket by sendust
{
	tcpclient := Object()
	;timer := ObjBindMethod(this, "disconnect")
	tick_send := A_TickCount
	ip := ""
	port := 0

	__New(ip, port)
	{
		this.ip := ip
		this.port := port
	}

	sendText(text)
	{
		address := Object()
		address[1] := this.ip
		address[2] := this.port
		diff := A_TickCount - this.tick_send
		;print("diff is " . diff)
		if (diff < 30)
			Sleep, 30											; insert short delay for non-block socket
		try
			this.tcpclient.disconnect()
		catch, err
			updatelog(printobjectlist(err))

		;print("create socket")
		if (text != "info`r`n")
			updatelog("text to send is ---- " . text)
		try
		{
			this.tcpclient := new SocketTCP()		; Establish tcp connection with Caspar CG Server
			this.tcpclient.Connect(address)
			;this.tcpclient.onRecv := this.tcprecv
			this.tcpclient.onRecv := Func("OnAMCP_TCPRecv")
			this.tcpclient.sendtext(text)
			this.tick_send := A_TickCount
		}
		catch, err
			updatelog(printobjectlist(err))
	}

	tcprecv()
	{
		static count := 0
		text := this.RecvText(8000)
		if (StrLen(text) > 1)
			count += 1
		print("Recv count is " . count)
		print(text)
	}
}




class class_python_info				; created 2020/12/27
{

	info_udp := Object()
	reader_title := "Caspar info reader by sendust"


	__New(host, port)
	{
		global script_python_info
		updatelog("Creating python info reader class....")
		address := Object()
		address.push(host)
		address.push(port)
		this.script_python_info := script_python_info
		try
		{
			this.info_udp := new SocketUDP()
			this.info_udp.Bind(address)
			this.info_udp.onRecv := this.python_info_udp				;  -----> for class internal method reference
		}
		catch, err
			updatelog(printobjectlist(err))
		;this.info_udp.onRecv := Func("onPythonUDPRecv")			';  ----> for external function reference
	}

	python_info_udp()
	{
		recvtext := this.Recvtext()			; Get UDP message
		decode_python_info(recvtext)
		;tooltip, %recvtext%
	}

	run_reader()
	{
		updatelog("Start python caspar info reader")
		binary := "python.exe " . """" . A_WorkingDir . "\" . this.script_python_info  . """"
		if !WinExist(this.reader_title)
		{
			try
				Run, %binary%, %A_WorkingDir%, Minimize, pid
			catch, e
				updatelog(e)
		}
		else
			updatelog("Python caspar info reader is running")
	}

	__Delete()														; Improve Delete method 2020/1/5
	{
		updatelog("Destroying python info reader class....")
		this.info_udp.onRecv := ""					; Release callback function
		this.info_udp.disconnect()					; Disconnect
		this.info_udp := ""									; Release UDP Socket
	}

}


cm_start()
{
	global caspar
	commercial := object()
	Loop, 9
	{
		IniRead, url, % getinifile(A_ScriptFullPath), cm, url%A_Index%, NONE			; get source from ini
		if (url != "NONE")
		{
			commercial[A_Index] := new c_commercial(caspar)
			commercial[A_Index].writejson()
			commercial[A_Index].post(url)
		}
	}
}


objtojson(obj)
{
	result := "{ "
	for key, val in obj
		result .= """" . key . """: """ . val . """ , "
	result .= "}"
	result := StrReplace(result, ", }", "}")
	return result
}


class c_commercial
{
	json := ""
	url := "http://10.110.20.160:7180/front/ch/s01/liveinsert"				; SBS test server
	;url := "https://ptsv2.com/t/ehq5m-1610944418/post"							; post test server
	objParam := { "cmData": "{""duration"":""5000"",""source"":""TS-3"",""bandType"":""POST_CM""}"}				; setup object with any data

	__New(caspar)
	{
		updatelog("Creating commercial object .....   medianame/in/out point is " . caspar.medianame . " / " . caspar.in . " / " . caspar.out)
		ary := Object()
		duration_ms := Round((caspar.out - caspar.in) / 59.94 * 1000)				; get duration from caspar in, out information (unit is milisecond)
		IniRead, source, % getinifile(A_ScriptFullPath), cm, source, TS-10			; get source from ini
		IniRead, margin, % getinifile(A_ScriptFullPath), cm, margin_still, 5000			; get cm still margin from ini
		IniRead, margin2, % getinifile(A_ScriptFullPath), cm, margin_extra, 500			; get cm extra margin from ini
		;source := "TS-3"
		duration_ms := Abs(duration_ms - margin + margin2)													; remove CM postroll margin
		ary["duration"] := duration_ms																	; array data for json file
		ary["source"] := source

		FileRead, outputvar, %A_WorkingDir%\decision_cm.txt					; Read bandtype decision table from text file

		bandtype := ""
		cm_table := Object()											; Create band
		Loop, Parse, outputvar, `n, `r
		{
			table_cm := StrSplit(A_LoopField, "|" , "`r")
			if (A_Index > 1)
				if (StrLen(table_cm[1]) >  1)
				{
					if InStr(caspar.medianame, table_cm[1])
					{
						bandtype := ",""bandType"":""" . table_cm[2] . """"
						ary["bandType"] := table_cm[2]
					}
				}
		}

		this.json := objtojson(ary)
		;this.objParam := { "cmData": "{""duration"":""" . duration_ms . """,""source"":""" .   source . """,""bandType"":""POST_CM""}"}
		this.objParam := { "cmData": "{""duration"":""" . duration_ms . """,""source"":""" .   source . """" .  bandtype . "" . "}"}

		printobjectlist(this.objParam)
		print("Commercial object  --->>  Source is " . source . "   Duration is " . duration_ms  . " bandtype is " .  bandtype , true)
	}

	writejson()
	{
		text := this.json
		FileDelete, %A_WorkingDir%\commercial_json.txt
		FileAppend, %text%, %A_WorkingDir%\commercial_json.txt
		result := ErrorLevel
		print("Write commercial json data , result is " . result , true)
		return result
	}

	showjson()
	{
		print("Stored json is " . this.json, true)
	}

	post(url)
	{
		if !url
			url := this.url
		else
			this.url := url
		objParam := this.objParam
		print("send DATA to URL " . url, true)

		CreateFormData(postData, hdr_ContentType, objParam)

		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		try
		{
			whr.Open("POST", url, true)					; true - async /   false - sync mode  , A call to Send does not return until WinHTTP has completely received the response.
			whr.SetRequestHeader("Content-Type", hdr_ContentType)
			;whr.SetRequestHeader("Referer", "http://postimage.org/")
			whr.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko")
			whr.SetTimeouts(50, 250, 250, 500)				; set timeout (resolve , connect , send, receive timeout)
			whr.Option(6) := False ; No auto redirect
			whr.Send(postData)
			timer := ObjBindMethod(this, "postresult",  whr)
		}
		catch, err
			updatelog(printobjectlist(err))
		;whr.WaitForResponse()
		SetTimer, % timer, -1000				; Read send result after some period of time
	}

	postresult(ByRef whr)
	{
		Result := "No response from server"
		Status := 999
		global hstatus

		try
		{
			Result := whr.ResponseText
			Status := whr.Status
		}
		catch, err
			printobjectlist(err)

		print("HTTP post result ------------ URL : " . this.url , true)
		print("status " . Status , true)
		print("result " . Result, true)
		GuiControl,, %hstatus%, POST result is   [ %result% ]
		this.__Delete()
	}

	__Delete()
	{
		print("Destroy commercial class with url ------> " . this.url)
	}
}



ProcessCreationTime( PID ) {
 hPr := DllCall( "OpenProcess", UInt,1040, Int,0, Int,PID )
 DllCall( "GetProcessTimes", UInt,hPr, Int64P,UTC, Int,0, Int,0, Int,0 )
 DllCall( "CloseHandle", Int,hPr)
 DllCall( "FileTimeToLocalFileTime", Int64P,UTC, Int64P,Local ), AT := 1601
 AT += % Local//10000000, S
 Return AT
}


ProcessRunningTime( PID ) {
	time_c := ProcessCreationTime(PID)
	now := A_Now
	EnvSub, now, %time_c%, s
	return now
}


GetProcessMemoryUsage(ProcessID)
{
	static PMC_EX, size := NumPut(VarSetCapacity(PMC_EX, 8 + A_PtrSize * 9, 0), PMC_EX, "uint")

	if (hProcess := DllCall("OpenProcess", "uint", 0x1000, "int", 0, "uint", ProcessID)) {
		if !(DllCall("GetProcessMemoryInfo", "ptr", hProcess, "ptr", &PMC_EX, "uint", size))
			if !(DllCall("psapi\GetProcessMemoryInfo", "ptr", hProcess, "ptr", &PMC_EX, "uint", size))
				return (ErrorLevel := 2) & 0, DllCall("CloseHandle", "ptr", hProcess)
		DllCall("CloseHandle", "ptr", hProcess)
		return Round(NumGet(PMC_EX, 8 + A_PtrSize * 8, "uptr") / 1024**2, 2)
	}
}


GetProcessTimes( PID=0 )    {
   Static oldKrnlTime, oldUserTime
   Static newKrnlTime, newUserTime

   oldKrnlTime := newKrnlTime
   oldUserTime := newUserTime

   hProc := DllCall("OpenProcess", "Uint", 0x400, "int", 0, "Uint", pid)
   DllCall("GetProcessTimes", "Uint", hProc, "int64P", CreationTime, "int64P"
           , ExitTime, "int64P", newKrnlTime, "int64P", newUserTime)

   DllCall("CloseHandle", "Uint", hProc)
Return (newKrnlTime-oldKrnlTime + newUserTime-oldUserTime)/10000000 * 100
}

CPULoad() { ; By SKAN, CD:22-Apr-2014 / MD:05-May-2014. Thanks to ejor, Codeproject: http://goo.gl/epYnkO
Static PIT, PKT, PUT                           ; http://ahkscript.org/boards/viewtopic.php?p=17166#p17166
  IfEqual, PIT,, Return 0, DllCall( "GetSystemTimes", "Int64P",PIT, "Int64P",PKT, "Int64P",PUT )

  DllCall( "GetSystemTimes", "Int64P",CIT, "Int64P",CKT, "Int64P",CUT )
, IdleTime := PIT - CIT,    KernelTime := PKT - CKT,    UserTime := PUT - CUT
, SystemTime := KernelTime + UserTime

Return ( ( SystemTime - IdleTime ) * 100 ) // SystemTime,    PIT := CIT,    PKT := CKT,    PUT := CUT
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


class c_playlist
{
	__New()
	{
		this.selected_row := 0
	}

	read_config(configfile)
	{
		IniRead, flag_insert, %configfile%, playlist, insertmode, 0
		this.insertmode := flag_insert
	}

}


#IfWinActive, Preview play...				; Creates context-sensitive hotkeys and hotstrings.
~i::
updatelog("[i] button pressed while preview play")
if process_exist(mpv.pid)
	SetTimer, setin, -100				; Wait until mpv finish writing mpvinout.txt
return

~o::
updatelog("[o] button pressed while preview play")
if process_exist(mpv.pid)
	SetTimer, setout, -100				; Wait until mpv finish writing mpvinout.txt
return

~g::
updatelog("[g] button pressed while preview play")
if process_exist(mpv.pid)
	SetTimer, setpbposition, -100				; Wait until mpv finish writing mpvinout.txt
return


~space::
updatelog("[spacebar] button pressed while preview play")
if process_exist(mpv.pid)
	SetTimer, syncplay, -1
return

~enter::
updatelog("[enter] button pressed while preview play")
if process_exist(mpv.pid)
	SetTimer, addlist, -1
return


#If WinActive(title)			;  Creates context-sensitive hotkeys and hotstrings.
PGUP::
updatelog("[PGUP] button pressed with sendust player activated")
if caspar.listplay		; During listplaying, pbindex cannot be modified manually
{
	GuiControl,, %hstatus%, Please release PLAYLIST PLAY MODE !!!
	return
}
/*
if (caspar.pbindex > 1)
	{
		caspar.pbindex -= 1
		playlist.selected_row := caspar.pbindex				; New 2021/7/2
		updatepropertytextlv(caspar, media)
		if chk_autoload
			SetTimer, load, -1
	}
*/
if (playlist.selected_row> 1)
	{
		playlist.selected_row -= 1
		updatepropertytextlv_click(playlist.selected_row)
		if chk_autoload
			SetTimer, load, -1
	}
return

PGDN::
updatelog("[PGDN] button pressed with sendust player activated")
if caspar.listplay   				; During listplaying, pbindex cannot be modified manually
{
	GuiControl,, %hstatus%, Please release PLAYLIST PLAY MODE !!!
	return
}
/*
if (caspar.pbindex < LV_GetCount() )
{
	caspar.pbindex += 1
	playlist.selected_row := caspar.pbindex		; New 2021/7/2
	updatepropertytextlv(caspar, media)
	if chk_autoload
		SetTimer, load, -1
}
*/
if (playlist.selected_row < LV_GetCount() )
{
	playlist.selected_row += 1
	updatepropertytextlv_click(playlist.selected_row)
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


space::
updatelog("Space bar PLAY accepted")
SetTimer, play, -1
return

left::
if flags.keyboard_seek
	keyboardseek(-1 * flags.keyboard_seek_lr)
return

right::
if flags.keyboard_seek
	keyboardseek(flags.keyboard_seek_lr)
return


up::
if flags.keyboard_seek
	keyboardseek(flags.keyboard_seek_ud)
return

down::
if flags.keyboard_seek
	keyboardseek(-1 * flags.keyboard_seek_ud)
return
