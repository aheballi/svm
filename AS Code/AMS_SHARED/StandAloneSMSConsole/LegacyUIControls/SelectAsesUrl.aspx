<%@ page language="c#" inherits="UIFramework.SelectAsesUrl, AdminStudio.WebApplication" targetschema="http://schemas.microsoft.com/intellisense/ie5" %>
<HTML>
	<HEAD>
		<title>Select AdminStudio Enterprise Server Url</title>
		<meta content="Microsoft Visual Studio .NET 7.1" name="GENERATOR">
		<meta content="C#" name="CODE_LANGUAGE">
		<meta content="JavaScript" name="vs_defaultClientScript">
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
		<LINK href="UIFramework.css" type="text/css" rel="STYLESHEET">
	</HEAD>
	<body MS_POSITIONING="GridLayout">
		<form id="Form1" method="post" runat="server">
			<DIV style="WIDTH: 656px; POSITION: relative; HEIGHT: 440px" ms_positioning="GridLayout">
				<asp:Label id="Label1" style="Z-INDEX: 100; LEFT: 48px; POSITION: absolute; TOP: 24px" runat="server"
					Width="585px" Height="16px">Specify the URL for a running instance of AdminStudio Enterprise Server</asp:Label>
				<asp:TextBox id="editAsesUrl" style="Z-INDEX: 101; LEFT: 48px; POSITION: absolute; TOP: 56px"
					runat="server" Width="569px" Height="24px"></asp:TextBox>
				<asp:Button id="buttonSave" style="Z-INDEX: 102; LEFT: 128px; POSITION: absolute; TOP: 96px"
					runat="server" Width="72px" Height="24px" Text="Save"></asp:Button>
				<asp:Label id="labelMessage" style="Z-INDEX: 104; LEFT: 48px; POSITION: absolute; TOP: 136px"
					runat="server" Width="593px" Height="48px" ForeColor="Red">Label</asp:Label>
				<asp:Button id="buttonBack" style="Z-INDEX: 105; LEFT: 48px; POSITION: absolute; TOP: 96px"
					runat="server" Height="24px" Width="72px" Text="Back"></asp:Button></DIV>
		</form>
	</body>
</HTML>
