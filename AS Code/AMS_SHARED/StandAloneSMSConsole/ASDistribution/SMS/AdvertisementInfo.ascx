<%@ Register TagPrefix="IETab" Namespace="Microsoft.Web.UI.WebControls" Assembly="Microsoft.Web.UI.WebControls" %>
<%@ control language="c#" autoeventwireup="false" inherits="SMS.AdvertisementInfo, AdminStudio.WebApplication" targetschema="http://schemas.microsoft.com/intellisense/ie5" %>
<script language="javascript">
<!--

function ShowSMSCollBrowser(controlName, formName)
{
	var strUrl = "SMSCollBrowse.aspx?control=" + controlName + "&form=" + formName;
	var strOptions = "width=500px, height=450px, top=150,left=250, toolbar=no, location=no, status=no";
	window.open(strUrl, "selectSMSColl", strOptions, true);
}

function ScheduleTab_chkLstMdtAssigns_SelChanged()
{
	if ((window.document.getElementById('<%=ScheduleTab_chkLstMdtAssigns.ClientID%>_0') != null) &&
		(window.document.getElementById('<%=ScheduleTab_chkLstMdtAssigns.ClientID%>_1') != null) &&
		(window.document.getElementById('<%=ScheduleTab_chkLstMdtAssigns.ClientID%>_2') != null) &&
		(window.document.getElementById('<%=ScheduleTab_chkNotMandatory.ClientID%>') != null) &&
		(window.document.getElementById('<%=ScheduleTab_chkAllowRun.ClientID%>') != null))
	{
		if(	window.document.getElementById('<%=ScheduleTab_chkLstMdtAssigns.ClientID%>_0').checked ||
			window.document.getElementById('<%=ScheduleTab_chkLstMdtAssigns.ClientID%>_1').checked ||
			window.document.getElementById('<%=ScheduleTab_chkLstMdtAssigns.ClientID%>_2').checked )
		{
			window.document.getElementById('<%=ScheduleTab_chkNotMandatory.ClientID%>').disabled = false;
			window.document.getElementById('<%=ScheduleTab_chkAllowRun.ClientID%>').disabled = false;
		}
		else
		{
			window.document.getElementById('<%=ScheduleTab_chkNotMandatory.ClientID%>').disabled = true;
			window.document.getElementById('<%=ScheduleTab_chkAllowRun.ClientID%>').disabled = true;
		}
	}
}

function ScheduleTab_chkAllowExpire_SelChanged()
{
	if (window.document.getElementById('<%=ScheduleTab_chkAllowExpire.ClientID%>') != null)
	{
		if (window.document.getElementById('<%=ScheduleTab_chkAllowExpire.ClientID%>').checked == true)
		{
			window.document.getElementById('<%=ScheduleTab_drpList_Expire_Month.ClientID%>').disabled = false;
			window.document.getElementById('<%=ScheduleTab_drpList_Expire_Year.ClientID%>').disabled = false;
			window.document.getElementById('<%=ScheduleTab_drpList_Expire_Date.ClientID%>').disabled = false;
			window.document.getElementById('<%=ScheduleTab_drpList_Expire_Month.ClientID%>').disabled = false;
			window.document.getElementById('<%=ScheduleTab_drpList_Expire_Hour.ClientID%>').disabled = false;
			window.document.getElementById('<%=ScheduleTab_drpList_Expire_Minute.ClientID%>').disabled = false;
			window.document.getElementById('<%=ScheduleTab_chkExpireGreenwich.ClientID%>').disabled = false;
		}
		else
		{
			window.document.getElementById('<%=ScheduleTab_drpList_Expire_Month.ClientID%>').disabled = true;
			window.document.getElementById('<%=ScheduleTab_drpList_Expire_Year.ClientID%>').disabled = true;
			window.document.getElementById('<%=ScheduleTab_drpList_Expire_Date.ClientID%>').disabled = true;
			window.document.getElementById('<%=ScheduleTab_drpList_Expire_Month.ClientID%>').disabled = true;
			window.document.getElementById('<%=ScheduleTab_drpList_Expire_Hour.ClientID%>').disabled = true;
			window.document.getElementById('<%=ScheduleTab_drpList_Expire_Minute.ClientID%>').disabled = true;
			window.document.getElementById('<%=ScheduleTab_chkExpireGreenwich.ClientID%>').disabled = true;
		}
	}
}


//-->
</script>
<div class="SMSDivUndoDelete" id="Div_Deletion" runat="server">
<br>
	This Item is scheduled for deletion
	<br>
	<br>
	<asp:button id="btnUndoDelete" onclick="btnUndoDelete_Click" Runat="server" Text="Undo" CssClass="SMSButton"></asp:button></div>
<div id="Div_Normal" runat="server">
	<div style="BORDER-RIGHT: thin groove; BORDER-TOP: thin groove; BORDER-LEFT: thin groove; WIDTH: 70%; BORDER-BOTTOM: thin groove; HEIGHT: 80%">
		<?XML:NAMESPACE PREFIX="TSNS" /><?IMPORT NAMESPACE="TSNS" IMPLEMENTATION="/ASDistribution/webctrl_client/1_0/tabstrip.htc" />
	<IETAB:TABSTRIP id="TabCtrl" style="FONT-WEIGHT: bold" runat="server" Width="100%" ForeColor="White"
			SepDefaultStyle="border-bottom:solid 1px #000000;" TabSelectedStyle="border:solid 1px black;border-bottom:none;background:#437CD3;padding-left:5px;padding-right:5px;" TabHoverStyle="color:white;background:#437CD3;" TabDefaultStyle="style=font-weight:normal;font-family:tahoma;font-size:8pt; border:solid 1px black;background:silver ;padding-left:5px;padding-right:5px;"
			TargetID="MultiPageCtrl">
			<ietab:Tab Text="General"></ietab:Tab>
			<ietab:TabSeparator></ietab:TabSeparator>
			<ietab:Tab Text="Schedule"></ietab:Tab>
			<ietab:TabSeparator DefaultStyle="width:100%;"></ietab:TabSeparator>
	</IETAB:TABSTRIP>
		<?XML:NAMESPACE PREFIX="MPNS" /><?IMPORT NAMESPACE="MPNS" IMPLEMENTATION="/ASDistribution/webctrl_client/1_0/multipage.htc" />
	<IETAB:MULTIPAGE id="MultiPageCtrl" runat="server">
			<IETab:PageView id="General">
				<table align="left" cellspacing="10" width="100%" cellpadding="3">
					<tr>
						<td>
							<p>&nbsp;</p>
						</td>
					</tr>
					<tr width="100%">
						<td align="left" width="15%">
							<asp:Label>Name:</asp:Label>
						</td>
						<td align="left" width="100%">
							<asp:TextBox id="GeneralPage_txtName" Width="100%" runat="server" Height="20"></asp:TextBox>
						</td>
					</tr>
					<tr width="100%">
						<td align="left" width="15%">
							<asp:Label>Comment:</asp:Label>
						</td>
						<td align="left" width="100%">
							<asp:TextBox ID="GeneralTab_txtComment" Runat="Server" Width="100%" TextMode="MultiLine" Height="40px"></asp:TextBox>
						</td>
					</tr>
					<tr>
						<td align="left" width="15%">
							<asp:Label>Program:</asp:Label>
						</td>
						<td align="left">
							<asp:DropDownList ID="GeneralTab_drpListProgram" Width="100%" Runat="Server"></asp:DropDownList>
						</td>
					</tr>
					<tr width="100%">
						<td align="left" width="15%">
							<asp:Label>Collection:</asp:Label>
						</td>
						<td align="left" width="85%">
							<asp:TextBox ID="GeneralTab_txtCollection" Width="70%" Runat="Server"></asp:TextBox>
							&nbsp;&nbsp;<input type=button name="btnbrowseColl" value = "Browse..." onclick="ShowSMSCollBrowser('<%=GeneralTab_txtCollection.ClientID%>', 'PackageConfigForm');" />
						</td>
					</tr>
				</table>
				<br />
				<div>&nbsp;</div>
				<div>&nbsp;</div>
				<div>&nbsp;</div>
				<div>&nbsp;</div>
				<div>&nbsp;</div>
				<div>&nbsp;</div>
				<div>&nbsp;</div>
				<div>&nbsp;</div>
				<div>&nbsp;</div>
				<div>&nbsp;</div>
				<div>&nbsp;</div>
				<div>&nbsp;</div>
				<div>&nbsp;</div>
				<div>&nbsp;</div>
				<div>&nbsp;</div>
				<span style="margin-left:10px;">
					<asp:CheckBox ID="GeneralTab_chkSubColl" Text="Include members of subcollections" Runat="Server"></asp:CheckBox>
				</span>
				<p />
			</IETab:PageView>
			<IETab:PageView id="Schedule">
				<table align="left" cellspacing="5" cellpadding="3" width="100%">
					<tr>
						<td>
							<asp:Label>Advertisement start time:</asp:Label>
							<br />
							<span style="MARGIN-LEFT: 20px">
								<asp:DropDownList ID="ScheduleTab_drpList_StartTime_Month" Runat="server">
									<asp:ListItem Value="1">Januaray</asp:ListItem>
									<asp:ListItem Value="2">February</asp:ListItem>
									<asp:ListItem Value="3">March</asp:ListItem>
									<asp:ListItem Value="4">April</asp:ListItem>
									<asp:ListItem Value="5">May</asp:ListItem>
									<asp:ListItem Value="6">June</asp:ListItem>
									<asp:ListItem Value="7">July</asp:ListItem>
									<asp:ListItem Value="8">August</asp:ListItem>
									<asp:ListItem Value="9">September</asp:ListItem>
									<asp:ListItem Value="10">October</asp:ListItem>
									<asp:ListItem Value="11">November</asp:ListItem>
									<asp:ListItem Value="12">December</asp:ListItem>
								</asp:DropDownList></span>
							<asp:DropDownList ID="ScheduleTab_drpList_StartTime_Date" Runat="server"></asp:DropDownList>
							<asp:DropDownList ID="ScheduleTab_drpList_StartTime_Year" Runat="server"></asp:DropDownList>
							<span style="MARGIN-LEFT: 20px">
								<asp:DropDownList ID="ScheduleTab_drpList_StartTime_Hour" Runat="server"></asp:DropDownList>
								hr : </span>
							<asp:DropDownList ID="ScheduleTab_drpList_StartTime_Minute" Runat="server"></asp:DropDownList>
							min
							<asp:CheckBox ID="ScheduleTab_chkAdvtStartTimeGMT" Text="Greenwich Mean Time" Runat="server"></asp:CheckBox>
						</td>
					</tr>
					<tr>
						<td>
							<span style="MARGIN-LEFT: 20px">
								<asp:Label>Mandatory assignments: (Assign immediately after this event)</asp:Label>
							</span>
							<DIV style="BORDER-RIGHT: thin groove; BORDER-TOP: thin groove; MARGIN-TOP: 10px; MARGIN-LEFT: 30px; BORDER-LEFT: thin groove; WIDTH: 60%; BORDER-BOTTOM: thin groove">
								<asp:CheckBoxList ID="ScheduleTab_chkLstMdtAssigns" Runat="server">
									<asp:ListItem Value="5">As soon as possible</asp:ListItem>
									<asp:ListItem Value="9">Logon</asp:ListItem>
									<asp:ListItem Value="10">Logoff</asp:ListItem>
								</asp:CheckBoxList>
							</DIV>
						</td>
					</tr>
					<tr>
						<td>
							<span id="span_man" runat="server" style="MARGIN-LEFT: 20px">
								<asp:CheckBox ID="ScheduleTab_chkNotMandatory" Text="Assignments are not mandatory over slow links"
									Runat="server"></asp:CheckBox></span>
						</td>
					</tr>
					<tr>
						<td>
							<span id="span_allow" runat="server" style="MARGIN-LEFT: 20px">
								<asp:CheckBox ID="ScheduleTab_chkAllowRun" text="Allow users to run the program independently of assignments"
									Runat="server"></asp:CheckBox></span>
						</td>
					</tr>
					<tr>
						<td>
							<asp:CheckBox ID="ScheduleTab_chkAllowExpire" Text="Advertisement will expire:" Runat="server"></asp:CheckBox>
							<br />
							<span style="MARGIN-LEFT: 20px">
								<asp:DropDownList ID="ScheduleTab_drpList_Expire_Month" Runat="server">
									<asp:ListItem Value="1">Januaray</asp:ListItem>
									<asp:ListItem Value="2">February</asp:ListItem>
									<asp:ListItem Value="3">March</asp:ListItem>
									<asp:ListItem Value="4">April</asp:ListItem>
									<asp:ListItem Value="5">May</asp:ListItem>
									<asp:ListItem Value="6">June</asp:ListItem>
									<asp:ListItem Value="7">July</asp:ListItem>
									<asp:ListItem Value="8">August</asp:ListItem>
									<asp:ListItem Value="9">September</asp:ListItem>
									<asp:ListItem Value="10">October</asp:ListItem>
									<asp:ListItem Value="11">November</asp:ListItem>
									<asp:ListItem Value="12">December</asp:ListItem>
								</asp:DropDownList></asp:TextBox></span>
							<asp:DropDownList ID="ScheduleTab_drpList_Expire_Date" Runat="server"></asp:DropDownList>
							<asp:DropDownList ID="ScheduleTab_drpList_Expire_Year" Runat="server"></asp:DropDownList>
							<span style="MARGIN-LEFT: 20px">
								<asp:DropDownList ID="ScheduleTab_drpList_Expire_Hour" Runat="server"></asp:DropDownList>
								hr : </span>
							<asp:DropDownList ID="ScheduleTab_drpList_Expire_Minute" Runat="server"></asp:DropDownList>
							min
							<asp:CheckBox ID="ScheduleTab_chkExpireGreenwich" Text="Greenwich Mean Time" Runat="server"></asp:CheckBox>
						</td>
					</tr>
					<tr>
						<td>
							<asp:Label>Priority:</asp:Label>
							<asp:DropDownList ID="ScheduleTab_drpListPriority" Runat="server">
								<asp:ListItem Value="1">High</asp:ListItem>
								<asp:ListItem Value="2">Medium</asp:ListItem>
								<asp:ListItem Value="3">Low</asp:ListItem>
							</asp:DropDownList>
						</td>
					</tr>
				</table>
			</IETab:PageView>
		</IETAB:MULTIPAGE></div>
	<br>
	<asp:label>Click Update to save changes made</asp:label><br>
	<asp:label id="lblErrorText" Runat="server" ForeColor="#ff3300"></asp:label><br>
	<asp:button id="btnUpdate" onclick="btnUpdate_Click" runat="server" Text="Update" CssClass="SMSButton"></asp:button>
	<asp:button id="btnDelete" onclick="btnDelete_Click" runat="server" Text="Delete" CssClass="SMSButton" CausesValidation="False"></asp:button>
	<br>
	<br>
</div>
<script language="javascript">
<!--
	ScheduleTab_chkLstMdtAssigns_SelChanged();
	ScheduleTab_chkAllowExpire_SelChanged();
	
//-->
</script>
