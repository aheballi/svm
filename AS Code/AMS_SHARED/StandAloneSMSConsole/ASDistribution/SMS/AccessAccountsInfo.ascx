<%@ control language="C#" autoeventwireup="false" inherits="SMS.AccessAccountsInfo, AdminStudio.WebApplication" targetschema="http://schemas.microsoft.com/intellisense/ie5" %>
<script language="javascript">
<!--
function rdBtnList_MainActType_SelChanged()
{
	if (document.getElementById('<%= rdBtnList_MainActType.ClientID%>_0').checked == true)
		{
			document.getElementById('divWindows').style.display = 'block';  
			document.getElementById('divGeneric').style.display = 'none';  
		}
		else
		{
			document.getElementById('divWindows').style.display = 'none';  
			document.getElementById('divGeneric').style.display = 'block';  
		}
}


//-->
</script>
<DIV style="WIDTH: 80%; POSITION: relative; HEIGHT: 100%">
	<asp:datagrid id=DataGridCtrl style="POSITION: relative" Width="100%" runat="server" 
		AutoGenerateColumns="False" DataMember="AMS_SMSAccessAccounts" DataSource="<%# sqlAccessAccountsDataSet %>" 
		DataKeyField="AccessAccountInternalID" CellPadding="2" AllowPaging="True" PageSize="6"
		OnPageIndexChanged="PageIndex_Changed" BorderStyle="Solid" BorderColor="gray">
		<AlternatingItemStyle ForeColor="Black" BackColor="Gainsboro"></AlternatingItemStyle>
		<ItemStyle ForeColor="Black" BackColor="White"></ItemStyle>
		<Columns>
			<asp:ButtonColumn DataTextField="Name" HeaderText="Name">
				<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
				<ItemStyle HorizontalAlign="Left"></ItemStyle>
			</asp:ButtonColumn>
			<asp:BoundColumn DataField="Type" SortExpression="Type" HeaderText="Type">
				<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
			</asp:BoundColumn>
			<asp:BoundColumn DataField="Permission" SortExpression="Permission" HeaderText="Permissions">
				<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
			</asp:BoundColumn>
		</Columns>
		<PagerStyle Mode="NumericPages"></PagerStyle>
	</asp:datagrid>
	<br>
	<br>
	<asp:Label ID="AcessAccount_lblFeatureDisableMess" Visible="False" Runat="server" ForeColor="Red"
		Font-Bold="True" Width="576px"> This feature is included with AdminStudio Professional Edition</asp:Label>
	<div align="left" style="BORDER-RIGHT: thin groove; BORDER-TOP: thin groove; DISPLAY: block; BORDER-LEFT: thin groove; WIDTH: 100%; BORDER-BOTTOM: thin groove; POSITION: relative; TOP: 10%; HEIGHT: 40%">
		<table cellspacing="5" width="100%">
			<tr>
				<td valign="top" width="50%">
					<asp:label id="lblCreateNew" runat="server" Font-Bold="True">Create New Access Account:
					</asp:label>
					<br>
					<br>
					<asp:RadioButtonList Runat="server" id="rdBtnList_MainActType">
						<asp:ListItem selected="True" Value="Windows">Windows User Access Account</asp:ListItem>
						<asp:ListItem Value="Generic">Generic Access Account</asp:ListItem>
					</asp:RadioButtonList>
					<br>
					<asp:Label Runat="server" id="lblPermissions">Permissions:</asp:Label>
					<asp:DropDownList ID="drpList_Permissions" Runat="server">
						<asp:ListItem Value="Read">Read</asp:ListItem>
						<asp:ListItem Value="Change">Change</asp:ListItem>
						<asp:ListItem Value="Full">Full Control</asp:ListItem>
						<asp:ListItem Value="NoAccess">No Access</asp:ListItem>
					</asp:DropDownList>
					<br>
					<br>
					<asp:button CssClass="SMSButton" id="btnCreate" runat="server" Text="Create" onclick="btnCreate_Click"></asp:button>
				</td>
				<td height="100%"><div style="MARGIN-TOP:1em;WIDTH:1px;MARGIN-RIGHT:3em;HEIGHT:100%;BACKGROUND-COLOR:black"></div>
				</td>
				<td width="50%" style="MARGIN-LEFT: 20%">
					<div id="divWindows" style="DISPLAY:block">
						<asp:Label Width="50%" Runat="server" id="lblUserName">User Name:</asp:Label>
						<asp:textbox id="txtAccessAccountName" width="70%" runat="server" Height="22px"></asp:textbox>
						<asp:Label width="70%" Runat="server" id="lblSyntax">Syntax: Domain\Username</asp:Label>
						<br>
						<br>
						<asp:Label Runat="server" id="lblAcctType">Account Type:</asp:Label>
						<asp:RadioButtonList id="rdBtnList_WindowsActType" runat="server">
							<asp:ListItem Selected="True" Value="User">User</asp:ListItem>
							<asp:ListItem Value="Group">Group</asp:ListItem>
						</asp:RadioButtonList>
					</div>
					<div id="divGeneric" style="DISPLAY:none">
						<asp:Label Runat="server" id="lblGenericAcctType">Account type:</asp:Label>
						<asp:RadioButtonList id="rdBtnList_GenericType" runat="server">
							<asp:ListItem Selected="True" Value="Users">Users</asp:ListItem>
							<asp:ListItem Value="Guests">Guests</asp:ListItem>
							<asp:ListItem Value="Administrators">Administrators</asp:ListItem>
						</asp:RadioButtonList>
					</div>
				</td>
			</tr>
			<tr width="100%">
				<td>
					<br>
					<asp:Label ID="lblErrorText" Runat="server" ForeColor="#ff3300"></asp:Label>
				</td>
			</tr>
		</table>
	</div>
</DIV>
<asp:PlaceHolder id="divHideShowPlaceHolder" Runat="server"></asp:PlaceHolder>
<script language="javascript">
<!--
rdBtnList_MainActType_SelChanged();

//-->
</script>
