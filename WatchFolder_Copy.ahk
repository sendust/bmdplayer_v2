/*		
	SBS Watch Folder
	Code by sendust
	Last Modified 2020/8/10

*/

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


title = SBS watch folder by sendust 2020/8/10
loger := new cLOG
updatelog("Application start -----------------------------------------")

folder := new cFolders
updatelog("Source folder is " . folder.source)
updatelog("Target folder is " . folder.target)


Gui, Margin, 10, 10
Gui, Add, Text, xm ym, Source Folder
Gui, Add, Edit, xm+100 yp hwndhfolder_source ReadOnly w400 h20
Gui, Add, Text, xm yp+30, Target Folder
Gui, Add, Edit, xm+100 yp hwndhfolder_target ReadOnly w400 h20
Gui, Add, Button, xm+100 yp+30 gselect_folder hwndhselectsource, Select Source
Gui, Add, Checkbox, xp+200 yp gswatch vstartwatch, Start Watch
Gui, Add, Progress, xm yp+30 cBlue hwndhprogress w500 h10, 100
Gui, Add, StatusBar, hwndhstatus, Application Start
Gui, show,, %title%


GuiControl,, %hfolder_source%, % folder.source
GuiControl,, %hfolder_target%, % folder.target

GuiControl, Hide, %hprogress%

return



updatelog(text)
{
	global loger, hstatus
	GuiControl,, %hstatus%, %text%
	loger.update(text)
}



scan_initial:

folder.scan_initial("*.*")
folder.printlist()

SetTimer, watch_folder, -5000
return


GuiClose:
updatelog("Close application -----------------------------------------")

ExitApp


select_folder:
updatelog("Select new Source Folder ////")
SetTimer, watch_folder, Off

folder.source := selectfolder(folder.source)
GuiControl,, %hfolder_source%, % folder.source
IniWrite, % folder.source, watchfolder.ini, folder, source
updatelog("New source folder is " . folder.source)

return


swatch:
GuiControlGet, startwatch
if startwatch
{
	GuiControl, Disable, %hselectsource%
	GuiControl, Show, %hprogress%
	SetTimer, scan_initial, -1
}
else
{
	GuiControl, Enable, %hselectsource%
	GuiControl, Hide, %hprogress%
	SetTimer, watch_folder, Off
}

return


watch_folder:


folder.scan("*.*")
GuiControl, +cRed, %hprogress%
Sleep, 10
folder.copy()
Sleep, 10
GuiControl, +cBlue, %hprogress%
folder.printlist()

SetTimer, watch_folder, -5000
return



selectfolder(folder)
{
	folder_old := folder
	FileSelectFolder, OutputVar, *%folder%, 3, Select Target Folder          ; option 3 = create new folder, paste text path is possible  2018/1/15

	if OutputVar =                       ; Select cancel
		return folder_old
	else
	{
		path_dst :=RegExReplace(OutputVar, "\\$")  ; Removes the trailing backslash, if present.
		path_dst =%path_dst%\ 
		return path_dst
	}
}


class cFolders
{

	source := ""
	target := ""
	
	file_fullpath := Object()
	file_datem := Object()
	file_size := Object()
	file_size_old := Object()
	flag_growing := Object()

	
	__New()
	{
		IniRead, temp, watchfolder.ini, folder, source
		temp := RegExReplace(temp, "\\$") 			  ; Removes the trailing backslash, if present.
		this.source := temp . "\"
		IniRead, temp, watchfolder.ini, folder, target
		temp := RegExReplace(temp, "\\$")			    ; Removes the trailing backslash, if present.
		this.target := temp . "\"
	}
	
	scan_initial(mask)					; scan folder and put file informations to variable
	{
		this.file_fullpath := Object()
		this.file_datem := Object()
		this.file_size := Object()
		this.file_size_old := Object()
		this.flag_growing := Object()				; clear object (reset)
		
		
		Loop, Files, % this.source . mask
		{
			this.file_fullpath[A_LoopFileName] := A_LoopFileLongPath
			FileGetTime, outputvar, %A_LoopFileFullPath%
			this.file_datem[A_LoopFileName] := outputvar
			FileGetSize, outputvar,  %A_LoopFileFullPath%
			this.file_size[A_LoopFileName] := outputvar
			this.file_size_old[A_LoopFileName] := outputvar
			this.flag_growing[A_LoopFileName] := 1
		}
	}
	
	scan(mask)					; scan folder and put file informations to variable
	{
		Loop, Files, % this.source . mask
		{
			this.file_fullpath[A_LoopFileName] := A_LoopFileLongPath				; get file full path
			FileGetTime, outputvar, %A_LoopFileFullPath%
			this.file_datem[A_LoopFileName] := outputvar									; get file modified time
			FileGetSize, outputvar,  %A_LoopFileFullPath%
			this.file_size[A_LoopFileName] := outputvar										; get file size
			
			if (this.file_size_old[A_LoopFileName] = this.file_size[A_LoopFileName])			; Check if file is growing
				this.flag_growing[A_LoopFileName] := 0
			else
				this.flag_growing[A_LoopFileName] := 1
			this.file_size_old[A_LoopFileName] := this.file_size[A_LoopFileName]
			
		}
	}
	
	
	copy()
	{
		for key, val in this.file_fullpath
		{
			if !FileExist(val)			; Delete unused file list
			{
				this.file_fullpath.Delete(key)
				this.file_datem.Delete(key)
				this.file_size.Delete(key)
				this.file_size_old.Delete(key)
				this.flag_growing.Delete(key)
			}
			
			file_fullpath_dst := this.target . "\" . key
			FileGetTime, outputvar, %file_fullpath_dst%
			
			
			if !FileExist(file_fullpath_dst)					; new source file
				if !this.flag_growing[key]
				{ 
					FileAppend, Copy File %key% `r`n, *
					updatelog("Copy new source file [" . key . "]")
					FileCopy, % this.file_fullpath[key] , % file_fullpath_dst , 1
					updatelog("Error level is " . ErrorLevel)
				}
			if FileExist(file_fullpath_dst)					; modified source file
				if !this.flag_growing[key]
					if FileExist(this.file_fullpath[key])
						if (outputvar !=this.file_datem[key] )
						{
						updatelog("Copy modified source file [" . key . "]")
						FileCopy, % this.file_fullpath[key] , % file_fullpath_dst , 1
						updatelog("Error level is " . ErrorLevel)
						}
		}
	}

	printlist()
	{
		FileAppend, % this.filelist_source . "`r`n[" . A_TickCount . "]--------------------------------------------------------------`r`n", *
		for key, val in % this.file_fullpath
			FileAppend, % key . "`r`nFullpath = " .    this.file_fullpath[key] . " // Modified Date =  "  . this.file_datem[key] . " // File size =  " . this.file_size[key] .  " // Growing flag : " . this.flag_growing[key]  "`r`n", *
	}

	
}




class cLOG
{
	logfile := this.getlogfile(A_ScriptFullPath)
	update(text)
	{
		logfile := this.logfile
		FormatTime, time_log,, yyyy/MM/dd HH:mm.ss
		if this.checklogfile(logfile)
			FileAppend, [%time_log%_%A_MSec%]  - Backup old log file .................`r`n, %logfile%
		FileAppend, [%time_log%_%A_MSec%]  - %text%`r`n, %logfile%
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
	
}