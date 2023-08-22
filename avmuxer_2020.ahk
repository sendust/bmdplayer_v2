/*		Alpha channel extractor by sendust
		SBS Moving CG
		Last edit : 2020/11/18
		2020/11/5 	Improve Target file name (get from the first file name of sequence)
							Set window title for FFMPEG console (key, fill)
		2020/11/6	ffmpeg binary in bin folder
							Move to bmd_player_v2 project
		2020/11/10	Read video stream parameter
		2020/11/18 Bug fix (clist.txt)
*/

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Event
#SingleInstance Ignore
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

title = AVMuxer by sendust 20201110
binary_ffmpeg = %A_WorkingDir%\bin\ffmpeg2018.exe
listfile = %A_WorkingDir%\clist.txt
;IniRead, framerate, mcg.ini, avmux, framerate, 29.97
;IniRead, mfolder, mcg.ini, path, mfolder, c:\temp

framerate = 29.97
IniRead, mfolder, sendust_player1.ini, caspar, caspar_mediapath, c:\temp


Gui, new,, %title%
Gui, margin, 10, 10
Gui, Font, s14
Gui, add, text, xm ym  w500 h20, TGA 시퀀스 또는 동영상을 아래로 드래그 드롭하세요~
Gui, add, Edit, xm yp+30 w500 h400 ve_image_file hwndhe_image_file ReadOnly Multi -Wrap HScroll, Drop & Drop Files Here
Gui, add, Button, xp+520 yp w100 h80 gmux hwndhmux, Convert !
Gui, add, Button, xp yp+100 w100 h60 gseltarget, Select`r`nOUTPUT
Gui, add, StatusBar, hwndhstatus, Status bar
Gui, show

GuiControl,, %hstatus%, OUTPUT folder is %mfolder%

Gui, Font, s10
GuiControl, Font, %hstatus%
GuiControl, Font, %he_image_file%

Gui, Font, s14 bold
GuiControl, Font, %hmux%


return


seltarget:
old_mfolder = %mfolder%
FileSelectFolder, mfolder, *%mfolder%, 3, Select Output Folder
if mfolder =
	mfolder = %old_mfolder%
else
	mfolder := RegExReplace(mfolder, "\\$")
GuiControl,, %hstatus%, OUTPUT folder is %mfolder%
return


GuiDropFiles:
/*
A_GuiControl ; dropped position
A_GuiEvent   ; dropped file list
*/

imagein := ""
e_image_file := ""			; list for ffmpeg concat input
e_image_file2 := ""		; list for first file detection from sequence

loop, parse, A_GuiEvent, `n
{
	e_image_file .= "file " . "'" . A_LoopField . "'`n"
	e_image_file2 .=  A_LoopField . "`n"
}

Sort, e_image_file
Sort, e_image_file2
array_list := StrSplit(e_image_file2, "`n")
imagein := array_list[1]				; output file name is the first file of sequence

;FileAppend, % get_pixelformat(imagein), *
GuiControl,, %hstatus%, % get_pixelformat(imagein)
GuiControl,, %he_image_file%, %e_image_file%
FileAppend, `r`n --- target_file base name is -- `r`n%imagein%, *
FileDelete, %listfile%
FileAppend, %e_image_file%, %listfile%

return


get_pixelformat(inputfile)
{
	global binary_ffmpeg
	
	EnvSet, FFREPORT, file=ffmpegoutput.txt:level=32
	runstring = %binary_ffmpeg%  -i "%inputfile%"
	RunWait, %runstring%, %A_Temp%, Hide, pid_ffmpeg
	FileRead, outputvar, %A_Temp%\ffmpegoutput.txt
	FileAppend, %outputvar%, *
	Loop, Parse, outputvar, `n
	{
		if InStr(A_LoopField, "Video:")
			return A_LoopField
	}
	return "Cannot find Video Parameter"
}

mux:
Gui, Submit, NoHide

if !FileExist(imagein)
{
	GuiControl,, %hstatus%, Source File is not exist !!!
	return
}

SplitPath, imagein,,,,OutNameNoExt

outfilename := mfolder . "\" . OutNameNoExt . ".mov"
outfilename_a := mfolder . "\" . OutNameNoExt . "_a.mov"

;digit := getdigitcount(imagein)
;SplitPath, imagein,,OutDir,OutExtension
;startnumber := SubStr(OutNameNoExt, StrLen(OutNameNoExt) - digit + 1, digit)
;prefix := SubStr(OutNameNoExt, 1, StrLen(OutNameNoext) - digit)
;prefix .= "%0" . digit . "d"
runstring = %binary_ffmpeg%  -r %framerate% -f concat -safe 0  -i "%listfile%" -c:v mpeg2video -qscale:v 2 -flags +ilme+ildct -y "%outfilename%"
runstring_a = %binary_ffmpeg%  -r %framerate% -f concat -safe 0  -i "%listfile%"  -vf alphaextract -c:v mpeg2video -qscale:v 2 -flags +ilme+ildct -y "%outfilename_a%"

;Clipboard := runstring
FileAppend, `r`n%runstring%, *
FileAppend, `r`n%runstring_a%, *

EnvSet, FFREPORT, file=converter1.txt:level=32
Run, %runstring%, %A_WorkingDir%,, pid_ffmpeg
WinWait, ahk_pid %pid_ffmpeg%,, 2
WinSetTitle, ahk_pid %pid_ffmpeg%,, Transcoding In Progress... Please wait until close- Fill Video  %OutNameNoExt%
EnvSet, FFREPORT, file=converter2.txt:level=32
Run, %runstring_a%, %A_WorkingDir%,, pid_ffmpeg
WinWait, ahk_pid %pid_ffmpeg%,, 2
WinSetTitle, ahk_pid %pid_ffmpeg%,, Transcoding  In Progress... Please wait until close- Key Video  %OutNameNoExt%
return

/*
example >>>>>>>>>>>>>>>>
ffmpeg_string =  ffmpeg -f dshow -r 29.97 -video_size 1920x1080 -rtbufsize 1400M -framerate 29.97 -top 1 -pixel_format uyvy422 -sample_rate 48000 -sample_size 16 -channels %audio_rec_channel% -i "%inputdevicestring%" -pix_fmt %mycspace% -c:v mpeg2video -profile:v 0 -level:v 2 -b:v %mybitrate% -maxrate %mybitrate% -minrate %mybitrate% -bufsize 20000k -flags +ildct+ilme -field_order tt -top 1 -g 15 -bf 2 -color_primaries 1 -color_trc 1 -colorspace 1 -filter_complex "[0:0]setfield=tff;[0:1]aresample=async=1000[are];[are]channelsplit=channel_layout=%alayout%" -drop_frame_timecode 1 -acodec pcm_s24le -y

*/


getdigitcount(inputname)
{
	
	SplitPath, inputname,,,,OutNameNoExt
	count := 0
	length := StrLen(OutNameNoExt)
	Loop, %length%
	{
		temp := SubStr(OutNameNoExt, length + 1 - A_Index, 1)
		if temp is number
			count += 1
		else
			break
	}
	return count
}

esc::
GuiClose:
ExitApp



