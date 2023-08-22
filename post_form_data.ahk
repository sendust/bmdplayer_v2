SetWorkingDir %A_ScriptDir%
#Include CreateFormData.ahk
#Include BinArr.ahk ; https://gist.github.com/tmplinshi/a97d9a99b9aa5a65fd20

objParam := { "cmData": "{""duration"":""5000"",""source"":""TS-3"",""bandType"":""POST_CM""}"}
CreateFormData(postData, hdr_ContentType, objParam)

whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
whr.Open("POST", "http://10.110.20.160:7180/front/ch/s01/liveinsert", true)
whr.SetRequestHeader("Content-Type", hdr_ContentType)
;whr.SetRequestHeader("Referer", "http://postimage.org/")
whr.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko")
whr.Option(6) := False ; No auto redirect
whr.Send(postData)
whr.WaitForResponse()
Result := whr.ResponseText
Status := whr.Status
msgbox % "status: " status "`n`nresult: " result
return