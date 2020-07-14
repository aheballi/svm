<%@ page language="c#" autoeventwireup="false" inherits="SMS.SMSCollBrowse, AdminStudio.WebApplication" %>
<%@ Register TagPrefix="iewc" Namespace="Microsoft.Web.UI.WebControls" Assembly="Microsoft.Web.UI.WebControls" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<title>Select an SMS Collection</title>
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
		<link rel="STYLESHEET" type="text/css" href="<%=styleSheetURL %>">
	</HEAD>
	<body bottomMargin="0" leftMargin="0" topMargin="0" rightMargin="0">
		<div class="pageHeader">
			<div class="headerTop">
			<asp:Label ID="lbl_Header" Runat=server>
			Select an SMS Collection
			</asp:Label>
			</div>
		</div>
<%--		<div class="pageContent">
--%>			<form id="frmSMSCollSelector" name="frmSMSCollSelector" method="post" runat="server">
				<table align="left" height="100%">
					<tr style="BORDER-RIGHT: #330099 thick solid; BORDER-TOP: #330099 thick solid; BORDER-LEFT: #330099 thick solid; BORDER-BOTTOM: #330099 thick solid">
						<td valign="top" align="left" style="WIDTH: 308px; HEIGHT: 100px">
							<?XML:NAMESPACE PREFIX=TVNS />
<?IMPORT NAMESPACE=TVNS IMPLEMENTATION="/ASDistribution/webctrl_client/1_0/treeview.htc" />
							<iewc:TreeView Font-Size="7.5pt" Font-Name="Verdana" runat="server" AutoPostBack="True" ID="smsCollTreeView"
								OnSelectedIndexChange="smsCollTreeView_SelectionChanged" DefaultStyle="font-family:verdana;"
								Height="250px" Width="400px"></iewc:TreeView>
						</td>
					</tr>
					<tr>
						<td>
							<br>
							<asp:Label Runat="server" id="Label1">Collection:  </asp:Label>
							<asp:TextBox ID="txtCollName" Width="400px" ReadOnly="True" Runat="server"></asp:TextBox>
							<br>
							<br>
							<input type="button" id="btnOK" runat="server" onserverclick="OnServerClick" name="btnOK"
								OnClick="onOKBtnClick();" class="SMSButton" Value="OK">&nbsp; 
								
								<input type="button" id="btnCancel" runat=server value="Cancel" class="SMSButton" onclick="self.close();">
								
						</td>
					</tr>
				</table>
				<input type="hidden" runat="server" name="hidElement" id="hidElement">
			</form>
	<%--	</div>
	--%>	<script language="javascript">
		<!--
		function onOKBtnClick()
		{
			document.forms[0].hidElement.value = "close";
		}
		//-->
		</script>
	</body>
</HTML>
