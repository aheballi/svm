<%@ Register TagPrefix="IETab" Namespace="Microsoft.Web.UI.WebControls" Assembly="Microsoft.Web.UI.WebControls" %>
<%@ control language="c#" autoeventwireup="false" inherits="SMS.ProgramInfo, AdminStudio.WebApplication" targetschema="http://schemas.microsoft.com/intellisense/ie5" %>

<script language="javascript">
function GetSelectFileUrl()
{
<%
    String strUrl = String.Empty;

    string setting = ConfigurationSettings.AppSettings["StandAloneSMSConsole"];

    if (null != setting &&
        0 == String.Compare(setting, "1", true))
    {
        strUrl = "/ASDistribution/ASDistribution/SMS/Selectfile.aspx";
    }
    else
    {
        strUrl = "/ASDistribution/SMS/Selectfile.aspx";
    }
    
    Response.Write("return \"" + strUrl + "\"");
%>
}
function ShowFilesDialog(shareName, controlName, formName)
{
    var selectFileUrl = GetSelectFileUrl();
	var strUrl = selectFileUrl + "?folder=" + shareName + "&control=" + controlName + "&form="+formName;
	var strOptions = "width=400px, height=250px, top=300,left=400, toolbar=no, location=no, status=no";
	window.open(strUrl, "selectFile", strOptions, true);
}

function disableRadioButton(radioControlID)
{
	document.getElementById(radioControlID).setAttribute("disabled", "disabled");
}
function enableRadioButton(radioControlID)
{
	document.getElementById(radioControlID).removeAttribute("disabled");
	document.getElementById(radioControlID).setAttribute("enabled", "enabled");
}
function RequirementsPage_OSOptionChanged()
{
	var obj = document.getElementById('<%=RequirementsPage_rdBtnListPlatform.ClientID%>_0');
	if (obj != null)
	{
		if (obj.checked)
		{
			document.getElementById('<%=RequirementsPage_OSListBox.ClientID%>').setAttribute("disabled", "disabled");
		}
		else
		{
			document.getElementById('<%=RequirementsPage_OSListBox.ClientID%>').removeAttribute("disabled");
			document.getElementById('<%=RequirementsPage_OSListBox.ClientID%>').setAttribute("enabled", "enabled");
		}
	}
}
function AdvancedPage_chkRunAnotherprogram_click()
{
	var obj = document.getElementById('<%=AdvancedPage_chkRunanotherprogram.ClientID%>')
	if (obj != null)
	{
		if (obj.checked == false)
		{
			document.getElementById('<%=AdvancedPage_lblPackage.ClientID%>').setAttribute("disabled", "disabled");
			document.getElementById('<%=AdvancedPage_lblProgram.ClientID%>').setAttribute("disabled", "disabled");
			document.getElementById('<%=AdvancedPage_drpdwnPackageList.ClientID%>').setAttribute("disabled", "disabled");
			document.getElementById('<%=AdvancedPage_drpdwnProgramList.ClientID%>').setAttribute("disabled", "disabled");
		}
		else
		{
			document.getElementById('<%=AdvancedPage_lblPackage.ClientID%>').removeAttribute("disabled");
			document.getElementById('<%=AdvancedPage_lblProgram.ClientID%>').removeAttribute("disabled");
			document.getElementById('<%=AdvancedPage_drpdwnPackageList.ClientID%>').removeAttribute("disabled");
			document.getElementById('<%=AdvancedPage_drpdwnProgramList.ClientID%>').removeAttribute("disabled");

			document.getElementById('<%=AdvancedPage_lblPackage.ClientID%>').setAttribute("enabled", "enabled");
			document.getElementById('<%=AdvancedPage_lblProgram.ClientID%>').setAttribute("enabled", "enabled");
			document.getElementById('<%=AdvancedPage_drpdwnPackageList.ClientID%>').setAttribute("enabled", "enabled");
			document.getElementById('<%=AdvancedPage_drpdwnProgramList.ClientID%>').setAttribute("enabled", "enabled");
		}
	}
}

function UpdateDriveLetterEditbox()
{
	if (((document.getElementById('<%=EnvironmentPage_rdbtnlistDrivemode.ClientID%>_0') != null) &&	(document.getElementById('<%=EnvironmentPage_rdbtnlistDrivemode.ClientID%>_0').checked == true)) ||  //20 is for ProgramFlags.USEUNCPATH:
		((document.getElementById('<%=EnvironmentPage_rdbtnlistDrivemode.ClientID%>_1') != null) && (document.getElementById('<%=EnvironmentPage_rdbtnlistDrivemode.ClientID%>_1').checked == true)))
	{
		document.getElementById('<%=Environmentpage_txtdriveletter.ClientID%>').removeAttribute("enabled");
		document.getElementById('<%=Environmentpage_txtdriveletter.ClientID%>').setAttribute("disabled", "disabled");
	}
	else if ((document.getElementById('<%=EnvironmentPage_rdbtnlistDrivemode.ClientID%>_2') != null) && (document.getElementById('<%=EnvironmentPage_rdbtnlistDrivemode.ClientID%>_2').checked == true))//ProgramFlags.PERSISTCONNECTION:
	{
		document.getElementById('<%=Environmentpage_txtdriveletter.ClientID%>').removeAttribute("disabled");
		document.getElementById('<%=Environmentpage_txtdriveletter.ClientID%>').setAttribute("enabled", "enabled");
	}
}

function Environmentpage_drpdwnListcanrun_SelChanged()
{
	if (document.getElementById('<%=Environmentpage_drpdwnListcanrun.ClientID%>') != null)
	{
		var optionsColl = document.getElementById('<%=Environmentpage_drpdwnListcanrun.ClientID%>').options; 
		var optionsLen = optionsColl.length;
		var nValue = -1;
		
		for (i = 0; i < optionsLen; i++)
		{
			if (optionsColl[i].selected == true)
			{
				nValue = optionsColl[i].value;
			}
		}
		
		if (nValue == -1)
			return;
		
		if (nValue == 14)//USERCONTEXT
		{
				document.getElementById('<%=Environmentpage_chkUserinput.ClientID%>').removeAttribute("disabled");
				document.getElementById('<%=Environmentpage_chkUserinput.ClientID%>').setAttribute("enabled", "enabled");
				
				document.getElementById('<%=EnvironmentPage_chkSoftInstAcct.ClientID%>').checked = false;
				document.getElementById('<%=EnvironmentPage_chkSoftInstAcct.ClientID%>').setAttribute("disabled", "disabled");
				enableRadioButton('<%=EnvironmentPage_rdbtnlistrunmode.ClientID%>_0');
		}
		else if(nValue == 0)
		{
				document.getElementById('<%=Environmentpage_chkUserinput.ClientID%>').checked = false;
				document.getElementById('<%=Environmentpage_chkUserinput.ClientID%>').removeAttribute("enabled");
				document.getElementById('<%=Environmentpage_chkUserinput.ClientID%>').setAttribute("disabled", "disabled");

				document.getElementById('<%=EnvironmentPage_chkSoftInstAcct.ClientID%>').removeAttribute("disabled");
				document.getElementById('<%=EnvironmentPage_chkSoftInstAcct.ClientID%>').setAttribute("enabled", "enabled");
				
				document.getElementById('<%=EnvironmentPage_rdbtnlistrunmode.ClientID%>').selected = 15;
				disableRadioButton('<%=EnvironmentPage_rdbtnlistrunmode.ClientID%>_0');
				document.getElementById('<%=EnvironmentPage_rdbtnlistrunmode.ClientID%>_1').checked = true;
		}
		else if(nValue == 17)//NOUSERLOGGEDIN
		{
				document.getElementById('<%=Environmentpage_chkUserinput.ClientID%>').checked = false;
				document.getElementById('<%=Environmentpage_chkUserinput.ClientID%>').setAttribute("disabled", "disabled");
				
				document.getElementById('<%=EnvironmentPage_chkSoftInstAcct.ClientID%>').removeAttribute("disabled");
				document.getElementById('<%=EnvironmentPage_chkSoftInstAcct.ClientID%>').setAttribute("enabled", "enabled");
				
				document.getElementById('<%=EnvironmentPage_rdbtnlistrunmode.ClientID%>').selected = 15;
				disableRadioButton('<%=EnvironmentPage_rdbtnlistrunmode.ClientID%>_0');
				document.getElementById('<%=EnvironmentPage_rdbtnlistrunmode.ClientID%>_1').checked = true;
		}
		
		UpdateReconnectCheckBox();
		UpdateAdvancedPage_RunListCombo();
	}
}

function UpdateReconnectCheckBox()
{
	if (document.getElementById('<%=Environmentpage_drpdwnListcanrun.ClientID%>') != null)
	{
		var optionsColl = document.getElementById('<%=Environmentpage_drpdwnListcanrun.ClientID%>').options; 
		var optionsLen = optionsColl.length;
		var nValue = -1;
		
		for (i = 0; i < optionsLen; i++)
		{
			if (optionsColl[i].selected == true)
			{
				nValue = optionsColl[i].value;
			}
		}
		if (nValue == -1)
			return;
			
		if (nValue == 14)//USERCONTEXT
		{
			if (document.getElementById('<%=EnvironmentPage_rdbtnlistrunmode.ClientID%>_0').checked == true)
			{
				document.getElementById('<%=EnvironmentPage_chkReconnect.ClientID%>').removeAttribute("disabled");
				document.getElementById('<%=EnvironmentPage_chkReconnect.ClientID%>').setAttribute("enabled", "enabled");
				return;
			}
		}
		
		document.getElementById('<%=EnvironmentPage_chkReconnect.ClientID%>').removeAttribute("enabled");
		document.getElementById('<%=EnvironmentPage_chkReconnect.ClientID%>').setAttribute("disabled", "disabled");
	}
}

function UpdateAdvancedPage_RunListCombo()
{
	if (document.getElementById('<%=Environmentpage_drpdwnListcanrun.ClientID%>') != null)
	{
		var optionsColl = document.getElementById('<%=Environmentpage_drpdwnListcanrun.ClientID%>').options; 
		var optionsLen = optionsColl.length;
		var nValue = -1;
		var sEdition = '<%=Session["Edition"] %>';
		
		for (i = 0; i < optionsLen; i++)
		{
			if (optionsColl[i].selected == true)
			{
				nValue = optionsColl[i].value;
			}
		}
		if (nValue == -1)
			return;
			
		//Enable this combobox only if "Program can run" in environment tab is set to:
			//"only when a user is logged in"
		
		if(!(sEdition == 'LTD' && sEdition != null))
		{
			if (nValue == 14)
			{
				document.getElementById('<%=AdvancedPage_drpdwnRunList.ClientID%>').removeAttribute("disabled");
				document.getElementById('<%=AdvancedPage_drpdwnRunList.ClientID%>').setAttribute("enabled", "enabled");
			}
			else
			{
				document.getElementById('<%=AdvancedPage_drpdwnRunList.ClientID%>').removeAttribute("enabled");
				document.getElementById('<%=AdvancedPage_drpdwnRunList.ClientID%>').setAttribute("disabled", "disabled");
			}
		}
		else
		{
			document.getElementById('<%=AdvancedPage_drpdwnRunList.ClientID%>').removeAttribute("enabled");
			document.getElementById('<%=AdvancedPage_drpdwnRunList.ClientID%>').setAttribute("disabled", "disabled");
		}
	}
}

function EnvironmentPage_rdbtnlistrunmode_SelChanged()
{
	UpdateReconnectCheckBox();
}

function EnvironmentPage_rdbtnlistDrivemode_SelChanged()
{
	UpdateReconnectCheckBox();
	UpdateDriveLetterEditbox();
}

function RequirementsPage_EstimateRunTimeChanged()
{
	if (document.getElementById('<%=RequirementsPage_txtMinutes.ClientID%>') != null)
	{
		val = document.getElementById('<%=RequirementsPage_txtMinutes.ClientID%>').value;
		
		if (val > 0)
		{
			document.getElementById('<%=Requirements_chkNotify.ClientID%>').removeAttribute("disabled");
			document.getElementById('<%=Requirements_chkNotify.ClientID%>').setAttribute("enabled", "enabled");
		}
		else
		{
			document.getElementById('<%=Requirements_chkNotify.ClientID%>').checked = false;
			document.getElementById('<%=Requirements_chkNotify.ClientID%>').setAttribute("disabled", "disabled");
		}
	}
}

function AdvancedPage_chkRemoveChanged()
{
	if (document.getElementById('<%=AdvancedPage_chkRemove.ClientID%>') != null)
	{
		if (document.getElementById('<%=AdvancedPage_chkRemove.ClientID%>').checked == true)
		{
			document.getElementById('<%=AdvancedPage_lblUninstall.ClientID%>').removeAttribute("disabled");
			document.getElementById('<%=AdvancedPage_txtUninstallKey.ClientID%>').removeAttribute("disabled");
			
			document.getElementById('<%=AdvancedPage_lblUninstall.ClientID%>').setAttribute("enabled", "enabled");
			document.getElementById('<%=AdvancedPage_txtUninstallKey.ClientID%>').setAttribute("enabled", "enabled");
		}
		else
		{
			document.getElementById('<%=AdvancedPage_lblUninstall.ClientID%>').setAttribute("disabled", "disabled");
			document.getElementById('<%=AdvancedPage_txtUninstallKey.ClientID%>').setAttribute("disabled", "disabled");
		}
	}
}
</script>
<div id="Div_Deletion" runat=server class="SMSDivUndoDelete">
	<br>
	This  Item is scheduled for deletion
	<br>
	<br>
	<asp:Button id="btnUndoDelete"  CssClass="SMSButton" OnClick="btnUndoDelete_Click" Text="Undo" Runat=server></asp:Button>
</div>
<div runat=server id="Div_Normal">
<DIV style="WIDTH: 62%; POSITION: relative; HEIGHT: 100%" >
	<div style="BORDER-RIGHT: thin groove; BORDER-TOP: thin groove; BORDER-LEFT: thin groove; BORDER-BOTTOM: thin groove; HEIGHT: 82%">
			<?XML:NAMESPACE PREFIX="TSNS" /><?IMPORT NAMESPACE="TSNS" IMPLEMENTATION="/ASDistribution/webctrl_client/1_0/tabstrip.htc" />
		<IETab:TabStrip id="TabCtrl" style="FONT-WEIGHT: bold" SepDefaultStyle="border-bottom:solid 1px #000000;"
			TabSelectedStyle="border:solid 1px black;border-bottom:none;background:#437CD3;padding-left:5px;padding-right:5px;" 
			TabHoverStyle="color:white;background:#437CD3;" 
			TabDefaultStyle="style=font-weight:normal;font-family:tahoma;font-size:8pt; border:solid 1px black;background:silver ;padding-left:5px;padding-right:5px;"		
			TargetID="MultiPageCtrl" runat="server" ForeColor="White" Width="100%">
			<ietab:Tab Text="General"></ietab:Tab>
			<ietab:TabSeparator></ietab:TabSeparator>
			<ietab:Tab Text="Requirements"></ietab:Tab>
			<ietab:TabSeparator></ietab:TabSeparator>
			<ietab:Tab Text="Environment"></ietab:Tab>
			<ietab:TabSeparator></ietab:TabSeparator>
			<ietab:Tab Text="Advanced"></ietab:Tab>
			<ietab:TabSeparator></ietab:TabSeparator>
		</IETab:TabStrip>
				<?XML:NAMESPACE PREFIX="MPNS" /><?IMPORT NAMESPACE="MPNS" IMPLEMENTATION="/ASDistribution/webctrl_client/1_0/multipage.htc" />

		<IETab:MultiPage id="MultiPageCtrl" runat="server">
			<IETab:PageView id="General">
				<table align="left" cellspacing="5" cellpadding="3" width="100%">
					<tr>
					<td><br></td>
					</tr>
					<tr>
						<td>
							<asp:Label>Icon:</asp:Label></td>
						<td>
							<asp:Image Runat="server" ID="iconImage"></asp:Image>
							<span style="MARGIN-LEFT: 30px"><asp:DropDownList AutoPostBack="True" Runat="server" ID="iconFiles" ></asp:DropDownList>
							</span>
						</td>
					</tr>
					<tr>
						<td>
							<p>&nbsp;</p>
						</td>
					</tr>
					<tr>
						<td>
							<asp:Label ID="GeneralPage_lblComment">Comment:</asp:Label>
						</td>
						<td align="left" width="100%">
							<asp:TextBox id="GeneralPage_txtComment" Width="100%" runat="server" Height="40" TextMode="MultiLine"></asp:TextBox>
						</td>
					</tr>
					<tr>
						<td>
							<asp:Label ID="GeneralPage_lblCmdLine">Command Line:</asp:Label>
						</td>
						<td align="left" width="80%">
							<asp:TextBox id="GeneralPage_txtCmdLine" Width="75%" runat="server" Height="20"></asp:TextBox>
							&nbsp;
							<input type=button name="btnbrowse" value = "Browse..." onclick="ShowFilesDialog('<%=sourceFilePath.Replace(@"\", @"\\")%>', '<%=GeneralPage_txtCmdLine.ClientID%>', 'PackageConfigForm');" />
						</td>
					</tr>
					<tr>
						<td>
							<p>&nbsp;</p>
						</td>
					</tr>
					<tr>
						<td>
							<asp:Label ID="GeneralPage_lblStartin">Start in:</asp:Label>
						</td>
						<td align="left" width="100%">
							<asp:TextBox id="GeneralPage_txtStartin" Width="100%" Runat="Server" Height="20"></asp:TextBox>
						</td>
					</tr>
					<tr>
						<td colspan=2>
							<asp:Label ID="GeneralPage_lblFeatureDisableMess" Visible="false" Runat="server" ForeColor="Red" Font-Bold="True">This feature is 
included with AdminStudio Professional Edition</asp:Label>
						</td>
					</tr>
					<tr>
						<td>
							<asp:Label ID="GeneralPage_Run" Runat="server">Run:</asp:Label>
						</td>
						<td align="left" width="100%">
							<asp:DropDownList id="GeneralPage_RunList" Width="100%" Runat="Server" Height="20">
								<asp:ListItem Value="0">Normal</asp:ListItem>
								<asp:ListItem Value="22">Minimized</asp:ListItem>
								<asp:ListItem Value="23">Maximized</asp:ListItem>
								<asp:ListItem Value="24">Hidden</asp:ListItem>
							</asp:DropDownList>
						</td>
					</tr>
					<tr>
						<td>
							<asp:Label ID="GeneralPage_AfterRunning" Runat="server">After Running:</asp:Label>
						</td>
						<td align="left" width="100%">
							<asp:DropDownList id="GeneralPage_AfterRunningList" Width="100%" runat="Server" Height="20">
								<asp:ListItem Value="0">No action required</asp:ListItem>
								<asp:ListItem Value="19">SMS restarts computer</asp:ListItem>
								<asp:ListItem Value="18">Program restarts computer</asp:ListItem>
								<asp:ListItem Value="25">SMS logs user off</asp:ListItem>
							</asp:DropDownList>
						</td>
					</tr>
					
				</table>
			</IETab:PageView>
			<IETab:PageView id="Requirements">
				<div style="width=100%">
					<table align="left" cellspacing="5" cellpadding="3" width="100%">
						<tr>
							<td width="18%">
								<asp:Label ID="RequirementsPage_lblDiskSpace">Estimated disk space:</asp:Label>
							</td>
							<td align="left" width="40%">
								<asp:TextBox id="RequirementsPage_txtDiskSpace" MaxLength=8 Width="15%" Runat="Server" ></asp:TextBox>
								<asp:DropDownList id="RequirementsPage_drpdownDiskSpace" Width="20%" Runat="Server" >
									<asp:ListItem Value="KB">KB</asp:ListItem>
									<asp:ListItem Value="MB">MB</asp:ListItem>
									<asp:ListItem Value="GB">GB</asp:ListItem>
								</asp:DropDownList>
							</td>
						</tr>
						<tr>
							<td width="18%">
								<asp:Label ID="RequirementsPage_lblRuntime">Maximum allowed run time:</asp:Label>
							</td>
							<td align="left" width="40%">
								<asp:TextBox id="RequirementsPage_txtMinutes" MaxLength=8 Width="20%" Runat="Server" ></asp:TextBox>
								<asp:Label ID="RequirementsPage_lblminutes">minutes</asp:Label>
							</td>
						</tr>
					</table>
				</div>
				
				<hr>
				<div>
					<table align="left" cellspacing="5" cellpadding="3" runat="Server" Width="100%">
						<tr>
							<td>
							<asp:CheckBox ID="Requirements_chkNotify" Text="Notify user if the program runs 15 minutes longer than estimated" Runat="server" ></asp:CheckBox>
							</td>
						</tr>
						<tr>
							<td width="100%">
								<asp:RadioButtonList ID="RequirementsPage_rdBtnListPlatform" 
									Runat="Server" >
									<asp:ListItem Value="Any">This program can run on any platform</asp:ListItem>
									<asp:ListItem Value="NotAll">This program can run only on specified client platforms:</asp:ListItem>
								</asp:RadioButtonList>
								<DIV style= "BORDER-RIGHT: gray 1px solid; BORDER-TOP: gray 1px solid; OVERFLOW-Y: scroll; MARGIN-LEFT: 30px; BORDER-LEFT: gray 1px solid; WIDTH: 80%; BORDER-BOTTOM: gray 1px solid; HEIGHT: 80px">
									<asp:CheckBoxList Runat="Server" ID="RequirementsPage_OSListBox" Font-Size="X-Small" Font-Names="Tahoma"></asp:CheckBoxList>
								</DIV>
							</td>
						</tr>
						<tr>
							<td>
								<asp:Label ID="RequirementsPage_lblAddtReqt" Runat="Server">Additional Requirements:</asp:Label>
							</td>
						</tr>
						<tr>
							<td>
								<asp:TextBox ID="RequirementsPage_txtAdditionalReqt" width="100%" runat="Server" TextMode="MultiLine"
									Height="40px"></asp:TextBox>
							</td>
						</tr>
					</table>
				</div>
			</IETab:PageView>
			<IETab:PageView id="Environment">
				<table align="left" cellspacing="5" cellpadding="3" width="100%">
					<tr>
						<td>
							<asp:Label ID="Envoirnment_lblFeatureDisableMess" Visible="false" Runat="server" ForeColor="Red" Font-Bold="True">This feature is 
included with AdminStudio Professional Edition</asp:Label>
						</td>
					</tr>
					<tr>
						<td width="40%" style="MARGIN-TOP: 40px">
							<asp:Label width="30%" ID="Environmentpage_lblcanrun" Runat="server">Program can run:</asp:Label>
							<span style="margin-left:30px">
								<asp:DropDownList ID="Environmentpage_drpdwnListcanrun"
									Runat="Server" AutoPostBack="False">
									<asp:ListItem Value="14">Only when a user is logged on</asp:ListItem>
									<asp:ListItem Value="0">Whether or not a user is logged on</asp:ListItem>
									<asp:ListItem Value="17">Only when no user is logged on</asp:ListItem>
								</asp:DropDownList>
							</span>
						</td>
					</tr>
					<tr style="MARGIN-TOP: 10px">
						<td>
							<asp:CheckBox ID="Environmentpage_chkUserinput" Text="User input required" Runat="Server"></asp:CheckBox></td>
					</tr>
					<tr>
						<td>
							<hr>
							<span style="FONT-WEIGHT: bold;>
								<asp:Label ID="Environmentpage_lblRunMode" Font-Bold="true" Runat="server">Run mode:</asp:Label>
							</span>
							<asp:RadioButtonList ID="EnvironmentPage_rdbtnlistrunmode" 
								Runat="Server" >
								<asp:ListItem Value="0">Run with user's rights</asp:ListItem>
								<asp:ListItem Value="15">Run with administrative rights</asp:ListItem>
							</asp:RadioButtonList>
							<span style="margin-left:30px">
								<asp:CheckBox ID="EnvironmentPage_chkSoftInstAcct" Runat="server" Text="Use Software Installation Account"></asp:CheckBox>
							</span>
						</td>
					</tr>
					<tr>
						<td>
							<hr>
							<span style="FONT-WEIGHT: bold;>
								<asp:Label ID="Environmentpage_lblDriveMode" Font-Bold="true" Runat="server">Drive mode:</asp:Label>
							</span>
							<asp:RadioButtonList ID="EnvironmentPage_rdbtnlistDrivemode"
								Runat="Server" AutoPostBack="false">
								<asp:ListItem Value="20">Runs with UNC name</asp:ListItem>
								<asp:ListItem Value="0">Requires drive letter</asp:ListItem>
								<asp:ListItem Value="21">Requires specific drive letter</asp:ListItem>
							</asp:RadioButtonList>
							<asp:textbox id="Environmentpage_txtdriveletter" style="MARGIN-left: 30px" width="20px" runat="Server"></asp:textbox>
							<br />
							<asp:CheckBox ID="EnvironmentPage_chkReconnect" Runat="server" Text="Reconnect to Distribution point at logon"></asp:CheckBox>
						</td>
					</tr>
				</table>
			</IETab:PageView>
			<IETab:PageView id="Advanced">
				<table align="left" cellspacing="10" cellpadding="3" width="100%">
					<tr>
						<td>
							<asp:Label ID="Advanced_lblFeatureDisableMess" Visible="false" Runat="server" ForeColor="Red" Font-Bold="True">This feature is 
included with AdminStudio Professional Edition</asp:Label>
						</td>
					</tr>
					<tr>
						<td>
							<asp:CheckBox ID="AdvancedPage_chkRunanotherprogram" 
								runat="server" Text="Run another program first" ></asp:CheckBox>
						</td>
					</tr>
					<tr>
						<td>
							<span style="margin-left:30px">
								<asp:Label Runat="server" ID="AdvancedPage_lblPackage">Package:</asp:Label>
								<asp:DropDownList ID="AdvancedPage_drpdwnPackageList" OnSelectedIndexChanged="AdvancedPage_drpdwnPackageList_SelChanged"
									width="300px" runat="Server" AutoPostBack="true"></asp:DropDownList>
							</span>
						</td>
					</tr>
					<tr>
						<td>
							<span style="margin-left:30px">
								<asp:Label Runat="server" ID="AdvancedPage_lblProgram">Program:   </asp:Label>
								<asp:DropDownList width="300px" ID="AdvancedPage_drpdwnProgramList" runat="Server"></asp:DropDownList>
							</span>
						</td>
					</tr>
					<tr>
						<td height="15"><hr></td>
					</tr>
					<tr>
						<td>
							<asp:Label ID="lblProgAssigned" Runat="server">When this program is assigned to a computer:</asp:Label></td>
					</tr>
					<tr>
						<td>
							<span style="margin-left:30px">
								<asp:DropDownList ID="AdvancedPage_drpdwnRunList" Runat="server">
									<asp:ListItem Value="0">Run once for the computer</asp:ListItem>
									<asp:ListItem Value="16">Run once for every user who logs on</asp:ListItem>
								</asp:DropDownList>
							</span>
						</td>
					</tr>
					<tr>
						<td>
							<hr>
							<br>
							<asp:CheckBox ID="AdvancedPage_chkRemove" Text="Remove software when it is no longer advertised" Runat=server></asp:CheckBox>
							<br>
							<span style="margin-left:30px">
							<asp:label ID="AdvancedPage_lblUninstall" Runat=server>Uninstall Registry key:</asp:label>&nbsp;&nbsp;
							<asp:TextBox ID="AdvancedPage_txtUninstallKey" width="60%" Runat=server></asp:TextBox>
							</span>
						</td>
					</tr>
					
					<tr>
						<td>
							<asp:CheckBox ID="AdvancedPage_chkdisableprogram" Text="Disable this program on computers where it is advertised"
								Runat="server"></asp:CheckBox>
						</td>
					</tr>
				</table>
			</IETab:PageView>
		</IETab:MultiPage>
	</div>
	<br>
	<asp:Label>Click Update to save changes made</asp:Label>
	<br>
	<asp:Label ID="lblErrorText" Runat=server ForeColor="#ff3300"></asp:Label>
	<br>
	<asp:Button id="btnUpdate" CssClass="SMSButton" onclick="btnUpdate_Click"   runat="server"  Text="Update"></asp:Button>
	<asp:Button id="btnDelete" CssClass="SMSButton" CausesValidation=False  onclick="btnDelete_Click"  runat="server" Text="Delete"></asp:Button>
	<br><br>
	
	<asp:Literal runat="server" id="scriptCode"></asp:Literal>
</DIV>
</div>
<script language="JavaScript">
<!--
	RequirementsPage_OSOptionChanged();
	AdvancedPage_chkRunAnotherprogram_click();
	Environmentpage_drpdwnListcanrun_SelChanged();
	UpdateAdvancedPage_RunListCombo();
	UpdateReconnectCheckBox();
	EnvironmentPage_rdbtnlistrunmode_SelChanged();
	EnvironmentPage_rdbtnlistDrivemode_SelChanged();
	UpdateDriveLetterEditbox();
	RequirementsPage_EstimateRunTimeChanged();
	AdvancedPage_chkRemoveChanged();
	
//-->
</script>

