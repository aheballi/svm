<%@ page language="c#" autoeventwireup="false" inherits="SMS.SelectFile, AdminStudio.WebApplication" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
	<HEAD>
		<title>Select a File</title>
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
		<link rel="STYLESHEET" type="text/css" href="<%=styleSheetURL %>">
	</HEAD>
	<body bottomMargin="0" leftMargin="0" topMargin="0" rightMargin="0">
		<div class="pageHeader">
			<div class="headerTop">Select a File</div>
		</div>
		<div class="pageContent">
			<form id="selectFileForm" name="selectFileForm" runat="server">
				<asp:listbox id="lbFileList" runat="server" Rows="8"></asp:listbox><br>
				<asp:button id="btnOK" runat="server" Text="    OK    " Enabled="True"></asp:button>&nbsp;&nbsp; 
				&nbsp;<input type="button" value="Cancel" onclick="self.close();">
			</form>
		</div>
	</body>
</HTML>
