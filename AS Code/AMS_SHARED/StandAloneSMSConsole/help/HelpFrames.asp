<%@ LANGUAGE="VBScript"%>
<%
Dim strHelpTopic
strHelpTopic = Session("AMS_HELP_ID")
If strHelpTopic = "" Then
	strHelpTopic = "SMSAboutRoot.htm"
Else
	strHelpTopic = Replace(strHelpTopic, " ", "_")
End If
Response.Redirect("sms.htm?href=" & strHelpTopic)
%>
