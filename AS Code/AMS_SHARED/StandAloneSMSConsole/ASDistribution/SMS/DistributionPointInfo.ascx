<%@ control language="c#" autoeventwireup="false" inherits="SMS.DistributionPointInfo, AdminStudio.WebApplication" targetschema="http://schemas.microsoft.com/intellisense/ie5" %>
</SCRIPT>
<div id="Div_Deletion" runat="server" class="SMSDivUndoDelete">
	<br>
	This Item is scheduled for deletion
	<br>
	<br>
	<asp:Button id="btnUndoDelete" CssClass="SMSButton" OnClick="btnUndoDelete_Click" Text="Undo" Runat="server"></asp:Button>
</div>
<div runat="server" id="Div_Normal">
	<DIV style="BORDER-RIGHT: thin groove; BORDER-TOP: thin groove; BORDER-LEFT: thin groove; WIDTH: 40%; BORDER-BOTTOM: thin groove; POSITION: relative; HEIGHT: 40%">
		<table  cellpadding=10 width="100%">
			<tr><td><p></p></td></tr>
			<tr><td><p></p></td></tr>
			<tr><td><p></p></td></tr>
			<tr><td><p></p></td></tr>
			<tr><td><p></p></td></tr>
			<tr height="60%"  style="MARGIN-LEFT:20%;">
				<td width="15%">
					<asp:Label id="lblName" runat="server">Name:</asp:Label>
				</td>
				<td  align=left width="80%">
					<asp:TextBox id="txtName" Width="100%" runat="server" ReadOnly="True"></asp:TextBox>
				</td>
			</tr>
			<tr height="60%">
				<td>
					<asp:Label id="lblSiteName" runat="server" >Site:</asp:Label>
				</td>
				<td>
					<asp:TextBox id="txtSiteName"  Width="100%"  runat="server"  ReadOnly="True"></asp:TextBox>
				</td>
			</tr>
			<tr height="60%">
				<td>
					<asp:Label id="lblSysType" runat="server" >Type:</asp:Label>
				</td>
				<td>
					<asp:TextBox id="txtSysType" Width="100%"  runat="server"  ReadOnly="True"></asp:TextBox>
				</td>
			</tr>
			
		</table>
	</DIV>
	<br>
	<asp:Button id="btnDelete"  CausesValidation=False  onclick="btnDelete_Click"
		Text="Delete" runat="server" CssClass="SMSButton"></asp:Button>
</div>
