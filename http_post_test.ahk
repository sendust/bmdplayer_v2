#NoEnv
#SingleInstance, Force
#Include CreateFormData.ahk
#Include BinArr.ahk ; https://gist.github.com/tmplinshi/a97d9a99b9aa5a65fd20


caspar := object()
caspar.out := 60000
caspar.in := 30044

URL := "http://10.110.20.160:7180/front/ch/s01/liveinsert"
commercial := new c_commercial(caspar)
commercial.post(URL)




SetTimer, RECV, -1000
return

esc::ExitApp



RECV:

return



print(text, iflog)
{
	FormatTime, ftime, ,yyyy/MM/dd HH:mm:ss
	ftime .= "." A_MSec
	FileAppend, `n%ftime%  %text%, *
	return text
}


printobjectlist(obj)
{
	list := "`n"
	for k, v in obj
		list .= k . " --> " . v . "`n"
	print(list, false)
	return list
}


class c_commercial
{
	json := ""
	url := "http://10.110.20.160:7180/front/ch/s01/liveinsert"				; SBS test server
	;url := "https://ptsv2.com/t/ehq5m-1610944418/post"
	objParam := { "cmData": "{""duration"":""5000"",""source"":""TS-3"",""bandType"":""POST_CM""}"}				; setup object with any data
	
	
	__New(caspar)
	{
		ary := Object()
		duration_ms := Round((caspar.out - caspar.in) / 59.94 * 1000)
		;IniRead, source, % getinifile(A_ScriptFullPath), cm, source, TS-10
		source := "TS-3"
		ary["duration"] := duration_ms
		ary["source"] := source
		;this.json := objtojson(ary)
		;this.objParam := { "cmData": "{""duration"":""" . duration_ms . """,""source"":""" .   source . """,""bandType"":""POST_CM""}"}
		this.objParam := { "cmData": "{""duration"":""" . duration_ms . """,""source"":""" .   source . """}"}
		
		printobjectlist(this.objParam)
		print("Create commercial object  --->>  " . source . "   Duration is " . duration_ms , true)
	}

	writejson()
	{
		text := this.json
		FileDelete, %A_WorkingDir%\commercial.txt
		FileAppend, %text%, %A_WorkingDir%\commercial.txt
		result := ErrorLevel
		print("Write commercial json data , result is " . result , true)
		return result
	}
	
	showjson()
	{
		print("Stored json is " . this.json, grue)
	}
	
	post(url)
	{
		if !url
			url := this.url
		objParam := this.objParam
		print("send json to URL " . url, true)

		CreateFormData(postData, hdr_ContentType, objParam)

		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		whr.Open("POST", url, true)
		whr.SetRequestHeader("Content-Type", hdr_ContentType)
		;whr.SetRequestHeader("Referer", "http://postimage.org/")
		whr.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko")
		whr.Option(6) := False ; No auto redirect
		whr.Send(postData)
		;whr.WaitForResponse()
		timer := ObjBindMethod(this, "postresult",  whr)
		SetTimer, % timer, -1000				; Read send result after some period of time
	}

	postresult(ByRef whr)
	{
		Result := "No response from server"
		Status := 999
		
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
	}

}
