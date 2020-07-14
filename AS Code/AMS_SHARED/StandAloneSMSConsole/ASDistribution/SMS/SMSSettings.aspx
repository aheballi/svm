<%@ page language="C#" masterpagefile="~/AdminStudioBaseMaster.master" autoeventwireup="true" inherits="SMS.SMSSettings, AdminStudio.WebApplication" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.Controls" TagPrefix="MVSN_CTRL" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.PageFramework" TagPrefix="MVSN_LAYOUT" %>
<%@ Register TagPrefix="AMS" TagName="ToolTip" Src="~\AMSAdmin\UserControls\UCHelpText.ascx" %>
<%@ Register TagPrefix="iewc" Namespace="Microsoft.Web.UI.WebControls" Assembly="Microsoft.Web.UI.WebControls" %>
<asp:Content ID="Content1" ContentPlaceHolderID="masterContent" Runat="Server">
<MVSN_LAYOUT:PageLayout ID="Layout1" Layout="FullPage" runat="server">
        <MVSN_LAYOUT:PageContent ID="PageContent2" runat="server">
            <MVSN_LAYOUT:PageContentLeft id="leftContent" Layout="FullPage" runat="server">                
            </MVSN_LAYOUT:PageContentLeft>
            <MVSN_LAYOUT:PageContentRight ID="RightContent1" Title="_Package Selection Title_" runat="server">
				<form id="frmSMSServerSettings" method="post" runat="server">
					<div class="pageContent">
						<div class="sectionTitle"><asp:label id="lbl_Header" Runat="server">
						SMS Settings
						</asp:label></div>
						<br>
						<table cellSpacing="0" cellPadding="0">
							<tr>
								<td width="110" bgColor="#ffffff"><asp:label id="lblSiteServerName" runat="server" Font-Bold="True">Site Server Name:</asp:label></td>
								<td><asp:textbox id="txtServerName" runat="server" Width="208px"></asp:textbox>&nbsp;<asp:requiredfieldvalidator id="Requiredfieldvalidator1" Runat="server" ForeColor="Red" ErrorMessage="*" ControlToValidate="txtServerName"></asp:requiredfieldvalidator>
								</td>
							</tr>
							<tr>
								<td width="110" bgColor="#ffffff"><asp:label id="lblSiteCode" runat="server" Font-Bold="True">Site Code:</asp:label></td>
								<td><asp:textbox id="txtSiteCode" runat="server" Width="208px"></asp:textbox>&nbsp;<asp:requiredfieldvalidator id="Requiredfieldvalidator2" Runat="server" ForeColor="Red" ErrorMessage="*" ControlToValidate="txtSiteCode"></asp:requiredfieldvalidator>
								</td>
							</tr>
							<tr>
								<td width="110" bgColor="#ffffff"><asp:label id="lblUserName" runat="server" Font-Bold="True">User Name:</asp:label></td>
								<td><asp:textbox id="txtUserName" runat="server" Width="208px"></asp:textbox>&nbsp;<asp:requiredfieldvalidator id="Requiredfieldvalidator3" Runat="server" ForeColor="Red" ErrorMessage="*" ControlToValidate="txtUserName"></asp:requiredfieldvalidator>
								</td>
							</tr>
						</table>
						<br>
						<br>
						<asp:button id="btnUpdate" Runat="server" Text="Update" CssClass="SMSButton"></asp:button>&nbsp;&nbsp;
						<asp:button id="btnCancel" Runat="server" Text="Cancel" CssClass="SMSButton" CausesValidation="False"></asp:button></div>
					<DIV class="pageContent">
						<asp:Label id="lblErr" runat="server" ForeColor="Red" Visible="False">Label</asp:Label></DIV>
				</form>
            </MVSN_LAYOUT:PageContentRight>
        </MVSN_LAYOUT:PageContent>
    </MVSN_LAYOUT:PageLayout>
</asp:Content>
