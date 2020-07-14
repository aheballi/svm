<%@ control language="c#" autoeventwireup="false" inherits="SMS.AccessAccountInfo, AdminStudio.WebApplication" targetschema="http://schemas.microsoft.com/intellisense/ie5" %>
<div id="Div_Deletion" runat="server" class="SMSDivUndoDelete">
	<br>
	This Item is scheduled for deletion
	<br>
	<br>
	<asp:Button id="btnUndoDelete" CssClass="SMSButton" OnClick="btnUndoDelete_Click" Text="Undo"
		Runat="server"></asp:Button>
</div>
<div runat="server" id="Div_Normal">
	<DIV style="BORDER-RIGHT: thin groove; BORDER-TOP: thin groove; BORDER-LEFT: thin groove; WIDTH: 50%; BORDER-BOTTOM: thin groove; HEIGHT: 20%">
		<table cellpadding="5" width="100%" cellspacing="5">
			<tr>
				<td>&nbsp;</td>
				<td></td>
			</tr>
			<tr>
				<td width="25%">
					<asp:Label Runat="server" id="lblAccountType" runat="server">Account type:</asp:Label>
				</td>
				<td>
					<asp:Label Runat="server" id="lblActTypeValue"></asp:Label>
				</td>
			</tr>
			<tr>
				<td align="left" valign="top">
					<asp:Label id="lblPermissions" runat="server">Permissions:</asp:Label>
				</td>
				<td align="left" valign="top">
					<asp:Label ID="lblPermissionValue" Runat="server"></asp:Label>
				</td>
			</tr>
		</table>
		<br>
		<br>
		<br>
	</DIV>
	<br>
	<br>
	<asp:button id="btnDelete" CssClass="SMSButton" onclick="btnDelete_Click" runat="server" Text="Delete"></asp:button>
</div>
