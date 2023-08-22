#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, ignore

info_caspar := Object()

FileRead, text, caspar_info_v22_bg.xml
info_caspar := read_caspar_info(text)

test := ""
for key, val in info_caspar
	test .= key . "  -  " . val . "`r`n"

MsgBox %test%
return

esc::
ExitApp




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

/*
	docxml.loadXML(xmlfile)
	doctext := docxml.selectSingleNode("//layer/frames-left")
	caspar.framerem := doctext.text
	doctext := docxml.selectSingleNode("//foreground/producer/filename")
	caspar.foregroundfile := StrReplace(doctext.text, "/", "\")
	doctext := docxml.selectSingleNode("//background/producer/filename")												; caspar 2.1.x
	;doctext := docxml.selectSingleNode("//background/producer/destination/producer/filename")		; caspar 2.0.x
	caspar.backgroundfile := doctext.text
	
	doctext :=docxml.selectSingleNode("//layer/nb_frames")				; added 2019/4/5
	caspar.nb_frames := doctext.text
	doctext :=docxml.selectSingleNode("//foreground/producer/file-nb-frames")
	caspar.file_nb_frames := doctext.text
*/

/*
XMLdata=
(join`r`n
<?xml version="1.0" encoding="UTF-8"?>
<Contacts>
  <Info>
    <FirstName>John</FirstName>
    <LastName>Doe</LastName>
    <Email>john@doe.com</Email>
  </Info>
  <Info>
    <FirstName>Mary</FirstName>
    <LastName>Johnson</LastName>
    <Email>mary@johnson.net</Email>
  </Info>
  <Info>
    <FirstName>Bill</FirstName>
    <LastName>Smith</LastName>
    <Email>bill@smith.org</Email>
  </Info>
</Contacts>
)


Contacts:=ComObjCreate("MSXML2.DOMDocument.6.0")
Contacts.async:=false
Contacts.loadXML(XMLdata)
Element:="//Contacts/Info/Email"
XMLnode:=Contacts.selectNodes(Element)
If (XMLnode="")
{
  MsgBox,4112,Error,Node %Element% not found
  ExitApp
}
node := XMLnode.item(0) ; first item
while node {
   Email:=node.text
   MsgBox,4096,Success,Email=%Email%
   node := XMLnode.nextNode
}
ExitApp

*/
