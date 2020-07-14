<%@ page language="c#" inherits="ASDistribution.Failed_Registration, AdminStudio.WebApplication" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<title>Registration Page</title>
		<link rel="STYLESHEET" type="text/css" href="<%=styleSheetURL %>">
		<meta name="GENERATOR" Content="Microsoft Visual Studio .NET 7.1">
		<meta name="CODE_LANGUAGE" Content="C#">
		<meta name="vs_defaultClientScript" content="JavaScript">
		<meta name="vs_targetSchema" content="http://schemas.microsoft.com/intellisense/ie5">
		<script language="javascript">
			function funcJumpfirst()
			{
				var count=0;
				count = document.getElementById('<%=txt_RegKey1.ClientID%>').value.length;
				if(count == 6)
				{
					document.getElementById('<%=txt_RegKey2.ClientID%>').focus();
				}	
			}
			function funcJumpsecond()
			{
				var count=0;
				count = document.getElementById('<%=txt_RegKey2.ClientID%>').value.length;
				if(count == 4)
				{
					document.getElementById('<%=txt_RegKey3.ClientID%>').focus();
				}	
			}
			
		
		</script>
	</HEAD>
	<body>
		<form id="Form1" method="post" runat="server">
			<asp:Label id="lbl_ProdNotReg" style="Z-INDEX: 101; LEFT: 192px; POSITION: absolute; TOP: 120px"
				runat="server" Width="384px" Height="8px" ForeColor="Red" Font-Bold="True"> Product Not Registered : Register the product below</asp:Label>
			<asp:Label id="lbl_RegistrationMess" style="Z-INDEX: 104; LEFT: 192px; POSITION: absolute; TOP: 296px"
				runat="server" Font-Bold="True" Visible="False"></asp:Label>
			<TABLE id="Table1" style="Z-INDEX: 102; LEFT: 192px; WIDTH: 256px; POSITION: absolute; TOP: 184px; HEIGHT: 104px"
				cellSpacing="3" cellPadding="5" width="256" border="2" borderColor="#cccccc">
				<TR>
					<TD style="WIDTH: 63px; HEIGHT: 18px">
						<asp:RequiredFieldValidator id="RequiredFieldValidator1" runat="server" ErrorMessage="*" Display="Dynamic" ControlToValidate="txt_RegKey1">*</asp:RequiredFieldValidator>
						<asp:TextBox id="txt_RegKey1" runat="server" MaxLength="6" Columns="6" tabIndex="1"></asp:TextBox>
						&nbsp;&nbsp;&nbsp;</TD>
					<TD style="WIDTH: 53px; HEIGHT: 19px" borderColor="#cccccc">
						<asp:RequiredFieldValidator id="RequiredFieldValidator2" runat="server" ErrorMessage="*" Display="Dynamic" ControlToValidate="txt_RegKey2">*</asp:RequiredFieldValidator>
						<asp:TextBox id="txt_RegKey2" runat="server" MaxLength="4" Columns="4" tabIndex="2"></asp:TextBox>
						&nbsp;&nbsp;&nbsp;&nbsp;</TD>
					<TD style="HEIGHT: 19px" vAlign="top" borderColor="#cccccc">
						<asp:RequiredFieldValidator id="RequiredFieldValidator3" runat="server" ControlToValidate="txt_RegKey3" ErrorMessage="*">*</asp:RequiredFieldValidator>
						<asp:TextBox id="txt_RegKey3" runat="server" Columns="10" MaxLength="10" tabIndex="3"></asp:TextBox></TD>
				</TR>
				<TR>
					<TD borderColor="#ffffff">
						<asp:Button id="Register" tabIndex="4" runat="server" Text="Register" onclick="Register_Click"></asp:Button></TD>
					<TD borderColor="#ffffff" colSpan="3">
						<asp:HyperLink id="HyperLink1" runat="server" NavigateUrl="http://shop.installshield.com/home/default.asp"
							Target="_blank">Buy Now</asp:HyperLink></TD>
				</TR>
			</TABLE>
			<asp:Label id="Label2" style="Z-INDEX: 103; LEFT: 192px; POSITION: absolute; TOP: 152px" runat="server"
				Font-Bold="True" Width="280px">Provide with the right serial number . If you need a serial number click the "Buy Now" link</asp:Label>
			<asp:HyperLink id="linkHome" style="Z-INDEX: 105; LEFT: 192px; POSITION: absolute; TOP: 312px"
				runat="server" Font-Bold="True" Visible="False" NavigateUrl="default.aspx">Click here to go to SMS Web Console Home</asp:HyperLink>
		</form>
	</body>
</HTML>
