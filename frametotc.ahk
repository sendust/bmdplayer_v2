#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

FileDelete, smptetc.txt

Loop, 4000
{
	adj := frametotc(A_Index)
	;FileAppend, %A_Index% - %adj% `r`n, smptetc.txt
	FileAppend, %A_Index% - %adj% `r`n, *
}

;MsgBox Finish Looping

return





esc::ExitApp




secondtotc_drop(sec)			; changed 2020/3/23
{
	frames := Round(sec * 29.97)
	return frametotc(frames)
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

