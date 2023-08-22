#Include socket_nonblock.ahk				; Non block 2021/1/8
caspar := Object()


caspar.fullpath := "C:\CasparCG.Server-2.1.12NRK\CasparCG Server\server\casparcg.exe"
caspar.title := "CasparCG Server"

start_cas(byref cas)
{

	fullpath := cas.fullpath
	title := cas.title

	if !WinExist(title)
	{
		SplitPath, fullpath, outfilename, outdir, outextension, outnamenoext, outdrive
		run, "%fullpath%", %outdir%, Minimize UseErrorLevel, pid
		;updatelog("run engine with parameter " . fullpath . " `r`n      working dir is " . outdir . "`r`n     Error Level is " . ErrorLevel)
		WinWait, ahk_pid %pid%,, 3
		;updatelog("Engine pid is " . pid)
		IfWinNotExist, ahk_pid %pid%
			MsgBox "Fail to launch Caspar"
		cas.pid := pid
	} else
	{
		WinGet, pid, pid, %title%
		cas.pid := pid
	}
}

start_cas(caspar)
Sleep, 1000

casparamcp := Object()
casparamcp := new c_tcpsend("127.0.0.1", 5250)


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
		;print("diff is " . diff)		if (diff < 30)			Sleep, 30											; insert short delay for non-block socket
		try
			this.tcpclient.disconnect()
		catch, err
			FileAppend, There is error`r`n, *
			;updatelog(printobjectlist(err))
		FileAppend, %text%, *
		this.tcpclient := new SocketTCP()		; Establish tcp connection with Caspar CG Server
		this.tcpclient.Connect(address)
		;this.tcpclient.onRecv := this.tcprecv
		;this.tcpclient.onRecv := Func("OnAMCP_TCPRecv")
		this.tcpclient.sendtext(text)
		this.tick_send := A_TickCount

		;	updatelog(printobjectlist(err))
	}

	tcprecv()
	{
		static count := 0
		text := this.RecvText(8000)
		if (StrLen(text) > 1)
			count += 1
		;print("Recv count is " . count)
		;print(text)
	}
}

ListVars

2::
FileAppend, send command`r`n , *
casparamcp.sendText("play 1-1 1 seek 400 length 2000  `r`n")
return


esc::ExitApp
