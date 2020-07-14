<%@ Register TagPrefix="IETab" Namespace="Microsoft.Web.UI.WebControls" Assembly="Microsoft.Web.UI.WebControls" %>
<%@ control language="c#" autoeventwireup="false" inherits="SMS.PackageRootInfo, AdminStudio.WebApplication" targetschema="http://schemas.microsoft.com/intellisense/ie5" %>
<script language="javascript">
function ReportingPage_rdbtnListStatus_SelChanged()
{
	if (document.getElementById('<%=ReportingPage_rdbtnListStatus.ClientID%>_0').checked == true)
	{
		document.getElementById('<%=ReportingPage_lblMIFFileName.ClientID%>').setAttribute("disabled", "disabled");
		document.getElementById('<%=ReportingPage_txtMIFFileName.ClientID%>').setAttribute("disabled", "disabled");
		document.getElementById('<%=ReportingPage_lblName.ClientID%>').setAttribute("disabled", "disabled");
		document.getElementById('<%=ReportingPage_txtName.ClientID%>').setAttribute("disabled", "disabled");
		document.getElementById('<%=ReportingPage_lblVersion.ClientID%>').setAttribute("disabled", "disabled");
		document.getElementById('<%=ReportingPage_txtVersion.ClientID%>').setAttribute("disabled", "disabled");
		document.getElementById('<%=ReportingPage_lblPublisher.ClientID%>').setAttribute("disabled", "disabled");
		document.getElementById('<%=ReportingPage_txtPublisher.ClientID%>').setAttribute("disabled", "disabled");
	}
	else
	{
		document.getElementById('<%=ReportingPage_lblMIFFileName.ClientID%>').removeAttribute("disabled");
		document.getElementById('<%=ReportingPage_txtMIFFileName.ClientID%>').removeAttribute("disabled");
		document.getElementById('<%=ReportingPage_lblName.ClientID%>').removeAttribute("disabled");
		document.getElementById('<%=ReportingPage_txtName.ClientID%>').removeAttribute("disabled");
		document.getElementById('<%=ReportingPage_lblVersion.ClientID%>').removeAttribute("disabled");
		document.getElementById('<%=ReportingPage_txtVersion.ClientID%>').removeAttribute("disabled");
		document.getElementById('<%=ReportingPage_lblPublisher.ClientID%>').removeAttribute("disabled");
		document.getElementById('<%=ReportingPage_txtPublisher.ClientID%>').removeAttribute("disabled");
	
		document.getElementById('<%=ReportingPage_lblMIFFileName.ClientID%>').setAttribute("enabled", "enabled");
		document.getElementById('<%=ReportingPage_txtMIFFileName.ClientID%>').setAttribute("enabled", "enabled");
		document.getElementById('<%=ReportingPage_lblName.ClientID%>').setAttribute("enabled", "enabled");
		document.getElementById('<%=ReportingPage_txtName.ClientID%>').setAttribute("enabled", "enabled");
		document.getElementById('<%=ReportingPage_lblVersion.ClientID%>').setAttribute("enabled", "enabled");
		document.getElementById('<%=ReportingPage_txtVersion.ClientID%>').setAttribute("enabled", "enabled");
		document.getElementById('<%=ReportingPage_lblPublisher.ClientID%>').setAttribute("enabled", "enabled");
		document.getElementById('<%=ReportingPage_txtPublisher.ClientID%>').setAttribute("enabled", "enabled");
	}
}

function DataAccessPage_rdbtnDistFolder_SelChanged()
{
	if (document.getElementById('<%=DataAccessPage_rdbtnDistFolder.ClientID%>_0').checked == true)
	{
		document.getElementById('<%=DataAccessPage_lblShareName.ClientID%>').setAttribute("disabled", "disabled");
		document.getElementById('<%=DataAccessPage_txtShareName.ClientID%>').setAttribute("disabled", "disabled");
	}
	else
	{
		document.getElementById('<%=DataAccessPage_lblShareName.ClientID%>').removeAttribute("disabled");
		document.getElementById('<%=DataAccessPage_txtShareName.ClientID%>').removeAttribute("disabled");
		document.getElementById('<%=DataAccessPage_lblShareName.ClientID%>').setAttribute("enabled", "enabled");
		document.getElementById('<%=DataAccessPage_txtShareName.ClientID%>').setAttribute("enabled", "enabled");
	}
}

function DataAccessPage_chkDisconnect_SelChanged()
{
	if(document.getElementById('<%=DataAccessPage_chkDisconnect.ClientID%>').checked == false)
	{
		document.getElementById('<%=DataAccessPage_txtNumberofRetries.ClientID%>').setAttribute("disabled", "disabled");
		document.getElementById('<%=DataAccessPage_txtBoxgraceMinutes.ClientID%>').setAttribute("disabled", "disabled");
		document.getElementById('<%=DataAccessPage_lblNumberofRetries.ClientID%>').setAttribute("disabled", "disabled");
		document.getElementById('<%=DataAccessPage_lblUserGracePeriod.ClientID%>').setAttribute("disabled", "disabled");
		document.getElementById('<%=DataAccessPage_lblGraceminutes.ClientID%>').setAttribute("disabled", "disabled");
	}
	else
	{
		document.getElementById('<%=DataAccessPage_txtNumberofRetries.ClientID%>').removeAttribute("disabled");
		document.getElementById('<%=DataAccessPage_txtBoxgraceMinutes.ClientID%>').removeAttribute("disabled");
		document.getElementById('<%=DataAccessPage_lblNumberofRetries.ClientID%>').removeAttribute("disabled");
		document.getElementById('<%=DataAccessPage_lblUserGracePeriod.ClientID%>').removeAttribute("disabled");
		document.getElementById('<%=DataAccessPage_lblGraceminutes.ClientID%>').removeAttribute("disabled");
		
		document.getElementById('<%=DataAccessPage_txtNumberofRetries.ClientID%>').setAttribute("enabled", "enabled");
		document.getElementById('<%=DataAccessPage_txtBoxgraceMinutes.ClientID%>').setAttribute("enabled", "enabled");
		document.getElementById('<%=DataAccessPage_lblNumberofRetries.ClientID%>').setAttribute("enabled", "enabled");
		document.getElementById('<%=DataAccessPage_lblUserGracePeriod.ClientID%>').setAttribute("enabled", "enabled");
		document.getElementById('<%=DataAccessPage_lblGraceminutes.ClientID%>').setAttribute("enabled", "enabled");
	}
}
function DataSrcPage_chkSrcFiles_SelChanged()
{
	if (document.getElementById('<%=DataSrcPage_chkSrcFiles.ClientID%>').checked == false)
	{
		document.getElementById('<%=DatasrcPage_lblSrcDirectory.ClientID%>').setAttribute("disabled", "disabled");
		document.getElementById('<%=DatasrcPage_txtSrcDirectory.ClientID%>').setAttribute("disabled", "disabled");
		document.getElementById('<%=DataScrPage_rdbtnListSrcType.ClientID%>').setAttribute("disabled", "disabled");
		document.getElementById('<%=DataScrPage_rdbtnListSrcType.ClientID%>_0').setAttribute("disabled", "disabled");
		document.getElementById('<%=DataScrPage_rdbtnListSrcType.ClientID%>_1').setAttribute("disabled", "disabled");
	}
	else
	{
		document.getElementById('<%=DatasrcPage_lblSrcDirectory.ClientID%>').removeAttribute("disabled");
		document.getElementById('<%=DatasrcPage_txtSrcDirectory.ClientID%>').removeAttribute("disabled");
		document.getElementById('<%=DataScrPage_rdbtnListSrcType.ClientID%>').removeAttribute("disabled");
		document.getElementById('<%=DataScrPage_rdbtnListSrcType.ClientID%>_0').removeAttribute("disabled");
		document.getElementById('<%=DataScrPage_rdbtnListSrcType.ClientID%>_1').removeAttribute("disabled");
		
		document.getElementById('<%=DatasrcPage_lblSrcDirectory.ClientID%>').setAttribute("enabled", "enabled");
		document.getElementById('<%=DatasrcPage_txtSrcDirectory.ClientID%>').setAttribute("enabled", "enabled");
		document.getElementById('<%=DataScrPage_rdbtnListSrcType.ClientID%>').setAttribute("enabled", "enabled");
		document.getElementById('<%=DataScrPage_rdbtnListSrcType.ClientID%>_0').setAttribute("enabled", "enabled");
		document.getElementById('<%=DataScrPage_rdbtnListSrcType.ClientID%>_1').setAttribute("enabled", "enabled");
	}
}
</script>
<DIV style="BORDER-RIGHT: thin groove; BORDER-TOP: thin groove; BORDER-LEFT: thin groove; WIDTH: 70%; BORDER-BOTTOM: thin groove; HEIGHT: 70%">
		<?XML:NAMESPACE PREFIX="TSNS" /><?IMPORT NAMESPACE="TSNS" IMPLEMENTATION="/ASDistribution/webctrl_client/1_0/tabstrip.htc" />
	<IETAB:TABSTRIP id="TabCtrl" style="FONT-WEIGHT: bold" AutoPostBack="False" runat="server" TargetID="MultiPageCtrl"
		TabSelectedStyle="border:solid 1px black;border-bottom:none;background:#437CD3;padding-left:5px;padding-right:5px;" 
		TabHoverStyle="color:white;background:#437CD3;" 
		TabDefaultStyle="style=font-weight:normal;font-family:tahoma;font-size:8pt; border:solid 1px black;background:silver ;padding-left:5px;padding-right:5px;"		
		SepDefaultStyle="border-bottom:solid 1px #000000;" ForeColor="White">
		<ietab:Tab Text="General"></ietab:Tab>
		<ietab:TabSeparator></ietab:TabSeparator>
		<ietab:Tab Text="Data Source"></ietab:Tab>
		<ietab:TabSeparator></ietab:TabSeparator>
		<ietab:Tab Text="Data Access"></ietab:Tab>
		<ietab:TabSeparator></ietab:TabSeparator>
		<ietab:Tab Text="Distribution Settings"></ietab:Tab>
		<ietab:TabSeparator></ietab:TabSeparator>
		<ietab:Tab Text="Reporting"></ietab:Tab>
		<ietab:TabSeparator DefaultStyle="width:100%;"></ietab:TabSeparator>
		<ietab:TabSeparator></ietab:TabSeparator>
	</IETAB:TABSTRIP>
	
	<?XML:NAMESPACE PREFIX="MPNS" /><?IMPORT NAMESPACE="MPNS" IMPLEMENTATION="/ASDistribution/webctrl_client/1_0/multipage.htc" />

	<IETAB:MULTIPAGE id="MultiPageCtrl" runat="server">
		<IETab:PageView id="General">
			<TABLE cellSpacing="5" cellPadding="3" width="100%" align="left">
				<TR>
					<TD>&nbsp;</TD>
				</TR>
				<TR>
					<TD>
						<asp:Label>Icon:</asp:Label></TD>
					<TD>
						<asp:Image id="iconImage" Runat="server"></asp:Image><SPAN style="MARGIN-LEFT: 30px">
							<asp:DropDownList id="iconFiles" AutoPostBack="True" Runat="server"></asp:DropDownList></SPAN></TD>
				</TR>
				<TR>
					<TD>
						<asp:Label id="GeneralPage_lblName">Name:</asp:Label></TD>
					<TD align="left" width="100%">
						<asp:TextBox id="GeneralPage_txtName" runat="server" Height="20" Width="100%"></asp:TextBox>&nbsp;
					</TD>
				</TR>
				<TR>
					<TD>
						<asp:Label id="GeneralPage_lblVersion">Version:</asp:Label></TD>
					<TD>
						<asp:TextBox id="GeneralPage_txtVersion" runat="server" Height="20" Width="100%"></asp:TextBox></TD>
				</TR>
				<TR>
					<TD>
						<asp:Label id="GeneralPage_lblPublisher">Publisher:</asp:Label></TD>
					<TD>
						<asp:TextBox id="GeneralPage_txtPublisher" runat="server" Height="20" Width="100%"></asp:TextBox></TD>
				</TR>
				<TR>
					<TD>
						<asp:Label id="GeneralPage_lblLang">Language:</asp:Label></TD>
					<TD>
						<asp:TextBox id="GeneralPage_txtLang" runat="server" Height="20" Width="100%"></asp:TextBox></TD>
				</TR>
				<TR>
					<TD>
						<asp:Label id="GeneralPage_lblComment">Comment:</asp:Label></TD>
					<TD>
						<asp:TextBox id="GeneralPage_txtComment" runat="server" Height="40" Width="100%" TextMode="MultiLine"></asp:TextBox></TD>
				</TR>
				<TR vAlign="bottom">
					<TD vAlign="bottom"></TD>
				</TR>
			</TABLE>
		</IETab:PageView>
		<IETab:PageView id="DataSource">
			<TABLE cellSpacing="5" cellPadding="3" width="100%" align="left">
				<TR>
					<TD>
						<P>&nbsp;</P>
					</TD>
				</TR>
				<TR>
					<TD>
						<asp:CheckBox id="DataSrcPage_chkSrcFiles" Runat="server" Text="This Package contains source files"></asp:CheckBox></TD>
				</TR>
				<TR>
					<TD width="100%"><SPAN style="MARGIN-LEFT: 30px">
							<asp:Label id="DatasrcPage_lblSrcDirectory" Runat="server">Source Directory:</asp:Label>
							<asp:TextBox id="DatasrcPage_txtSrcDirectory" runat="server" Width="300px"></asp:TextBox></SPAN></TD>
				</TR>
				<TR>
					<TD><SPAN style="MARGIN-LEFT: 30px">
							<asp:RadioButtonList id="DataScrPage_rdbtnListSrcType" Runat="server">
								<asp:ListItem Value="3">Use a compressed copy of the source directory</asp:ListItem>
								<asp:ListItem Value="2">Always obtain files from source directory</asp:ListItem>
							</asp:RadioButtonList></SPAN></TD>
				</TR>
			</TABLE>
		</IETab:PageView>
		<IETab:PageView id="DataAccess">
			<TABLE cellSpacing="5" cellPadding="3" width="100%" align="left">
				<TR>
					<TD>
						<P align="left">
							<asp:Label ID="lblFeatureDisableMessDa" Visible="False" Runat="server" ForeColor="Red" Font-Bold="True">This feature is 
included with AdminStudio Professional Edition</asp:Label>
						</P>
					</TD>
				</TR>
				<TR>
					<TD>
						<asp:RadioButtonList id="DataAccessPage_rdbtnDistFolder" Runat="server">
							<asp:ListItem Value="1">Access distribution folder through common SMS package share</asp:ListItem>
							<asp:ListItem Value="2">Share Distribution folder</asp:ListItem>
						</asp:RadioButtonList>
						<SPAN style="MARGIN-LEFT: 30px">
							<asp:Label id="DataAccessPage_lblShareName" Runat="server">Share name:</asp:Label>
							<asp:TextBox id="DataAccessPage_txtShareName" Runat="server"></asp:TextBox>
						</SPAN>
					</TD>
				</TR>
				<TR>
					<TD>
						<P>
							<HR>
					</TD>
				</TR>
				<TR>
					<TD><SPAN style="FONT-WEIGHT: bold">
							<asp:Label id="DataAccessPage_lblPackUpdtSetting" Runat="server">Package update settings:</asp:Label></SPAN></TD>
				</TR>
				<TR>
					<TD>
						<asp:CheckBox id="DataAccessPage_chkDisconnect" AutoPostBack="false" Runat="server" Text="Disconnect users from distribution points"></asp:CheckBox></TD>
				</TR>
				<TR>
					<TD><SPAN style="MARGIN-LEFT: 30px">
							<asp:Label id="DataAccessPage_lblNumberofRetries" Runat="server">Number of retries before disconnecting users:</asp:Label></SPAN>
						<asp:TextBox id="DataAccessPage_txtNumberofRetries" Runat="server" Width="30px"></asp:TextBox></TD>
				</TR>
				<TR>
					<TD><SPAN style="MARGIN-LEFT: 30px">
							<asp:Label id="DataAccessPage_lblUserGracePeriod" Runat="server">User grace period:</asp:Label>
							<asp:TextBox id="DataAccessPage_txtBoxgraceMinutes" Runat="server" Width="30px"></asp:TextBox></SPAN>
						<asp:Label id="DataAccessPage_lblGraceminutes" Runat="server">minutes</asp:Label></TD>
				</TR>
			</TABLE>
		</IETab:PageView>
		<IETab:PageView id="DistributionSettings">
		<table align="left" cellspacing="5" cellpadding="3" width="100%">
				<tr>
					<td colspan="2">
						<p align="left">
							<asp:Label ID="DistSettingPage_lblFeatureDisableMessDS" Visible="False" Runat="server" ForeColor="Red" Font-Bold="True">This feature is 
included with AdminStudio Professional Edition</asp:Label>
						</p>
					</td>
				</tr>
				<tr>
					<td align="left" width="25%">
						<asp:Label ID="DistSettingPage_lblSendingPriority" Runat="server">Sending priority:  </asp:Label></td>
					<td align="left">
						<asp:DropDownList width="40%" ID="DistSettingPage_drpListSendPriority" runat="server">
							<asp:ListItem Value="3">Low</asp:ListItem>
							<asp:ListItem Value="2">Medium</asp:ListItem>
							<asp:ListItem Value="1">High</asp:ListItem>
						</asp:DropDownList>
					</td>
				</tr>
				<tr>
					<td align="left" width="25%">
						<asp:Label Runat="server" ID="Label1">Preferred sender:</asp:Label></td>
					<td align="left">
						<asp:DropDownList id="DistSettingPage_drpListPrefSender" width="40%" Runat="server">
							<asp:ListItem Value="">&lt;No Preference&gt;</asp:ListItem>
							<asp:ListItem Value="SMS_LAN_SENDER">Standard Sender</asp:ListItem>
							<asp:ListItem Value="SMS_COURIER_SENDER">Courier Sender</asp:ListItem>
							<asp:ListItem Value="SMS_ASYNC_RAS_SENDER">Asynchronous RAS Sender</asp:ListItem>
							<asp:ListItem Value="SMS_ISDN_RAS_SENDER">ISDN RAS Sender</asp:ListItem>
							<asp:ListItem Value="SMS_X25_RAS_SENDER">X25 RAS Sender</asp:ListItem>
							<asp:ListItem Value="SMS_SNA_RAS_SENDER">SNA RAS Sender</asp:ListItem>
						</asp:DropDownList></td>
				</tr>
			</table>
		</IETab:PageView>
		<IETab:PageView id="Reporting">
			<TABLE cellSpacing="5" cellPadding="3" align="left">
				<TR>
					<TD>
						<p align="left">
							<asp:Label ID="DistSettingPage_lblFeatureDisableMessRep" Visible="False" Runat="server" ForeColor="Red" Font-Bold="True">This feature is 
included with AdminStudio Professional Edition</asp:Label>
						</p>
					</TD>
				</TR>
				<TR>
					<TD>
						<asp:RadioButtonList id="ReportingPage_rdbtnListStatus" Runat="server">
							<asp:ListItem Value="0">Use package properties for status MIF matching</asp:ListItem>
							<asp:ListItem Value="29">Use these fields for status MIF matching:</asp:ListItem>
						</asp:RadioButtonList></TD>
				</TR>
			</TABLE>
			<BR>
			<DIV>&nbsp;</DIV>
			<DIV>&nbsp;</DIV>
			<DIV>&nbsp;</DIV>
			<DIV>&nbsp;</DIV>
			<DIV>&nbsp;</DIV>
			<DIV>&nbsp;</DIV>
			<TABLE style="MARGIN-LEFT: 30px" align="left">
				<TR>
					<TD align="left" width="25%">
						<asp:Label id="ReportingPage_lblMIFFileName" Runat="server">MIF file name:</asp:Label></TD>
					<TD>
						<asp:TextBox id="ReportingPage_txtMIFFileName" Runat="server"></asp:TextBox></TD>
				</TR>
				<TR>
					<TD>
						<asp:Label id="ReportingPage_lblName" Runat="server">Name:</asp:Label></TD>
					<TD>
						<asp:TextBox id="ReportingPage_txtName" Runat="server"></asp:TextBox></TD>
					</TD></TR>
				<TR>
					<TD>
						<asp:Label id="ReportingPage_lblVersion" Runat="server">Version</asp:Label></TD>
					<TD></GD>
						<asp:TextBox id="ReportingPage_txtVersion" Runat="server"></asp:TextBox></TD>
				</TR>
				<TR>
					<TD>
						<asp:Label id="ReportingPage_lblPublisher" Runat="server">Publisher:</asp:Label></TD>
					<TD>
						<asp:TextBox id="ReportingPage_txtPublisher" Runat="server"></asp:TextBox></TD>
				</TR>
			</TABLE>
		</IETab:PageView>
	</IETAB:MULTIPAGE>
</DIV>
<div class="BUTTON" style="POSITION: relative; TOP: 2%">
	<asp:Label>Click Update to save changes made</asp:Label>
	<br>
	<asp:Label ID="lblErrorText" Runat="server" ForeColor="#ff3300"></asp:Label>
	<br>
	<asp:Button CssClass="SMSButton" ID="btnUpdate" OnClick="btnUpdate_Click" runat="server" Text="Update"></asp:Button>
</div>
<script language="javascript">
<!--
	ReportingPage_rdbtnListStatus_SelChanged();
	DataAccessPage_rdbtnDistFolder_SelChanged();
	DataAccessPage_chkDisconnect_SelChanged();
	DataSrcPage_chkSrcFiles_SelChanged();
//-->
</script>
