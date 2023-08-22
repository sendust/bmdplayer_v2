xmldata =
(
	<?xml version="1.0"?>
	<compactdiscs>
	<compactdisc>
	<artist type="individual">Frank Sinatra</artist>
	<title numberoftracks="4">In The Wee Small Hours</title>
	<tracks>
	<track>In The Wee Small Hours</track>
	<track>Mood Indigo</track>
	<track>Glad To Be Unhappy</track>
	<track>I Get Along Without You Very Well</track>
	</tracks>
	<price>$12.99</price>
	</compactdisc>
	<compactdisc>
	<artist type="band">The Offspring</artist>
	<title numberoftracks="5">Americana</title>
	<tracks>
	<track>Welcome</track>
	<track>Have You Ever</track>
	<track>Staring At The Sun</track>
	<track>Pretty Fly (For A White Guy)</track>
	</tracks>
	<price>$12.99</price>
	</compactdisc>
	</compactdiscs>
)

doc :=	loadXML(xmldata)

; XPath
msgbox %	doc.selectSingleNode("/compactdiscs/compactdisc[artist=""Frank Sinatra""]/title").text

; Manually retrieving nodes and values
msgbox %	DisplayNode(doc.childNodes)

DisplayNode(nodes, indent=0)
{
	for node in nodes
	{
		if	node.nodeName != "#text"
			text .=	spaces(indent) node.nodeName ": " node.nodeValue "`n"
		else	text .=	spaces(indent) node.nodeValue "`n"
		if	node.hasChildNodes
			text .=	DisplayNode(node.childNodes, indent+2)
	}
	return	text
}

spaces(n)
{
	Loop, %n%
		t .=	" "
	return	t
}

loadXML(ByRef data)
{
	o :=	ComObjCreate("MSXML2.DOMDocument.6.0")
	o.async :=	false
	o.loadXML(data)
	return	o
}