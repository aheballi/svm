<%@ page language="C#" masterpagefile="~/AdminStudioBaseMaster.master" autoeventwireup="true" inherits="SMS.SMSMain, AdminStudio.WebApplication" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.Controls" TagPrefix="MVSN_CTRL" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.PageFramework" TagPrefix="MVSN_LAYOUT" %>
<%@ Register TagPrefix="AMS" TagName="ToolTip" Src="~\AMSAdmin\UserControls\UCHelpText.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="masterContent" Runat="Server">
<MVSN_LAYOUT:PageLayout ID="Layout1" Layout="FullPage" runat="server">
        <MVSN_LAYOUT:PageContent ID="PageContent2" runat="server">
            <MVSN_LAYOUT:PageContentLeft id="leftContent" Layout="FullPage" runat="server">                
            </MVSN_LAYOUT:PageContentLeft>
            <MVSN_LAYOUT:PageContentRight ID="RightContent1" runat="server">
				<form id="SMSMainForm" method="post" runat="server">
					<div class="pageContent"><br>
						<br>
						<div style="MARGIN-LEFT:10px">
							<table cellpadding="0" cellspacing="0">
								<tr>
									<td width="110" bgcolor="#ffffff"><asp:label id="lblSiteServerName" Font-Bold="True" runat="server">Site Server:</asp:label></td>
									<td><asp:TextBox id="txtSiteServer" runat="server" Width="208px"></asp:TextBox>
										&nbsp;<asp:RequiredFieldValidator Runat="server" ControlToValidate="txtSiteServer" ErrorMessage="*" ForeColor="Red"
											ID="Requiredfieldvalidator1"></asp:RequiredFieldValidator>
									</td>
								</tr>
								<tr>
									<td width="110" bgcolor="#ffffff"><asp:label Font-Bold="True" id="lblSiteCode" runat="server">Site Code:</asp:label></td>
									<td><asp:TextBox id="txtSiteCode" runat="server" Width="208px"></asp:TextBox>
										&nbsp;<asp:RequiredFieldValidator Runat="server" ControlToValidate="txtSiteCode" ErrorMessage="*" ForeColor="Red"
											ID="Requiredfieldvalidator2"></asp:RequiredFieldValidator>
									</td>
								</tr>
								<tr>
									<td width="110" bgcolor="#ffffff"><asp:label id="lblUserName" Font-Bold="True" runat="server">User Name:</asp:label></td>
									<td><asp:TextBox id="txtUserName" runat="server" Width="208px"></asp:TextBox>
										&nbsp;<asp:RequiredFieldValidator Runat="server" ControlToValidate="txtUserName" ErrorMessage="*" ForeColor="Red"
											ID="Requiredfieldvalidator3"></asp:RequiredFieldValidator></td>
								</tr>
								<tr>
									<td width="110" bgcolor="#ffffff"><asp:label id="lblPassword" Font-Bold="True" runat="server">Password:</asp:label></td>
									<td><asp:TextBox id="txtPassword" runat="server" Width="208px" TextMode="Password"></asp:TextBox>
									</td>
								</tr>
							</table>
						</div>
						<br>
						<br>
						<asp:button id="btnNext" CssClass="SMSButton" runat="server" Text="Next >"></asp:button>&nbsp;&nbsp;
						<asp:Button ID="btnCancel" CssClass="SMSButton" runat="server" Text="Cancel" CausesValidation="False"></asp:Button>
						<br>
						<br>
						<asp:Label ID="lblConnectionMessage" Runat="server" ForeColor="Red" Font-Bold="True"></asp:Label>
					</div>
				</form>
            </MVSN_LAYOUT:PageContentRight>
        </MVSN_LAYOUT:PageContent>
    </MVSN_LAYOUT:PageLayout>
</asp:Content>
