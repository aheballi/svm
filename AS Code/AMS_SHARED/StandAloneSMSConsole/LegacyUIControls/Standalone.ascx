<%@ control language="c#" inherits="UIFramework.Standalone, AdminStudio.WebApplication" targetschema="http://schemas.microsoft.com/intellisense/ie5" %>
<script language="javascript">
<!--
//	0: SQL; 1:NT
var connMethod = 0;
function rbl_NtAuthentication_SelChanged()
{
	
	if(window.document.getElementById('<%=providerList.ClientID%>').selectedIndex == 0 ||
	window.document.getElementById('<%=providerList.ClientID%>').selectedIndex == 1)
	{
		if(window.document.getElementById('<%=rbl_NtAuthentication.ClientID%>_1').checked)
		{
			window.document.getElementById('<%=txt_UserName.ClientID%>').disabled = false;
			window.document.getElementById('<%=txt_Password.ClientID%>').disabled = false;
			window.document.getElementById('<%=lbl_UserName.ClientID%>').disabled = false;
			window.document.getElementById('<%=lbl_Password.ClientID%>').disabled = false;
		}
		else
		{
			window.document.getElementById('<%=txt_UserName.ClientID%>').disabled = true;
			window.document.getElementById('<%=txt_Password.ClientID%>').disabled = true;
			window.document.getElementById('<%=lbl_UserName.ClientID%>').disabled = true;
			window.document.getElementById('<%=lbl_Password.ClientID%>').disabled = true;
		}
	}
}


//-->
</script>
<DIV style="WIDTH: 392px; POSITION: relative; HEIGHT: 416px" ms_positioning="GridLayout">
	<TABLE id="Table1" style="Z-INDEX: 104; LEFT: 0px; WIDTH: 336px; POSITION: absolute; TOP: 0px; HEIGHT: 41px"
		borderColor="#cccccc" cellSpacing="5" cellPadding="3" width="336" border="0">
		<TR>
			<TD style="WIDTH: 109px; HEIGHT: 39px">
				<asp:label id="Label1" runat="server" Font-Bold="True">Select Provider</asp:label></TD>
			<TD style="HEIGHT: 39px">
				<asp:dropdownlist id="providerList" runat="server" AutoPostBack="True"></asp:dropdownlist></TD>
		</TR>
	</TABLE>
	<TABLE id="Table2" style="Z-INDEX: 105; LEFT: 0px; WIDTH: 363px; POSITION: absolute; TOP: 56px; HEIGHT: 264px"
		borderColor="#cccccc" cellSpacing="5" cellPadding="3" width="363" border="2">
		<TR>
			<TD style="WIDTH: 138px; HEIGHT: 32px" borderColor="#ffffff" colSpan="2">
				<asp:label id="lbl_DbProviderName" runat="server" Font-Bold="True" Width="312px"></asp:label></TD>
		</TR>
		<TR>
			<TD style="WIDTH: 113px; HEIGHT: 32px" borderColor="#ffffff">
				<asp:label id="lbl_DataSource" runat="server" Font-Bold="True"></asp:label></TD>
			<TD style="HEIGHT: 32px" borderColor="#ffffff">
				<asp:textbox id="txt_DataSource" runat="server" Width="208px"></asp:textbox></TD>
		</TR>
		<TR>
			<TD style="HEIGHT: 4px" borderColor="#ffffff" colSpan="2" height="0">
				<asp:label id="lbl_NtAuthentication" runat="server" Font-Bold="True"></asp:label></TD>
		</TR>
		<TR>
			<TD style="HEIGHT: 7px" borderColor="#ffffff" colSpan="2">
				<asp:placeholder id="placeHolder_DbControl" runat="server"></asp:placeholder></TD>
		</TR>
		<TR>
			<TD style="WIDTH: 113px; HEIGHT: 33px" borderColor="#ffffff">
				<asp:label id="lbl_UserName" runat="server" Font-Bold="True">Login Id:</asp:label></TD>
			<TD style="HEIGHT: 33px" borderColor="#ffffff">
				<asp:textbox id="txt_UserName" runat="server"></asp:textbox></TD>
		</TR>
		<TR>
			<TD style="WIDTH: 113px; HEIGHT: 30px" borderColor="#ffffff">
				<asp:label id="lbl_Password" runat="server" Font-Bold="True">Password:</asp:label></TD>
			<TD style="HEIGHT: 30px" borderColor="#ffffff">
				<asp:textbox id="txt_Password" runat="server" TextMode="Password"></asp:textbox></TD>
		</TR>
		<TR>
			<asp:placeholder id="placeHolder_Catalog" runat="server"></asp:placeholder></TR>
		<TR>
			<TD style="WIDTH: 109px; HEIGHT: 19px" borderColor="#ffffff" colSpan="2">
				<asp:CheckBox id="chkSaveLocal" runat="server" Width="352px" Height="16px" Text="Save connection parameters in local machine"
					Visible="False"></asp:CheckBox>
			</TD>
		</TR>
		<TR>
			<TD style="WIDTH: 109px; HEIGHT: 19px" vAlign="middle" borderColor="#ffffff" align="center"></TD>
			<TD style="WIDTH: 109px; HEIGHT: 19px" vAlign="middle" borderColor="#ffffff" align="left"
				colSpan="2">
				<asp:button id="btn_Connect" runat="server" Font-Bold="True" Width="56px" Text="Save"></asp:button>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<TR>
			<TD style="WIDTH: 109px" borderColor="#ffffff" align="center" colSpan="2">
				<asp:label id="lbl_ConnectionResult" runat="server" Font-Bold="True" Width="328px" Height="16px"
					ForeColor="Red" Visible="False"></asp:label></TD>
		</TR>
	</TABLE>
	<asp:RequiredFieldValidator id="RequiredFieldValidator1" style="Z-INDEX: 106; LEFT: 344px; POSITION: absolute; TOP: 112px"
		runat="server" ControlToValidate="txt_DataSource">*</asp:RequiredFieldValidator>
</DIV>
