<%@ page language="C#" masterpagefile="~/AdminStudioBaseMaster.master" autoeventwireup="true" inherits="SMS.SMSPackageConfig, AdminStudio.WebApplication" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.Controls" TagPrefix="MVSN_CTRL" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.PageFramework" TagPrefix="MVSN_LAYOUT" %>
<%@ Register TagPrefix="AMS" TagName="ToolTip" Src="~\AMSAdmin\UserControls\UCHelpText.ascx" %>
<%@ Register TagPrefix="iewc" Namespace="Microsoft.Web.UI.WebControls" Assembly="Microsoft.Web.UI.WebControls" %>
<%@ Reference Control= "AccessAccountsInfo.ascx" %>
<%@ Reference Control= "AdvertisementsInfo.ascx" %>
<%@ Reference Control= "DistributionPointsInfo.ascx" %>
<%@ Reference Control= "ProgramsInfo.ascx" %>
<%@ Reference Control= "PackageRootInfo.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="masterContent" Runat="Server">
<MVSN_LAYOUT:PageLayout ID="Layout1" Layout="FullPage" runat="server">
        <MVSN_LAYOUT:PageContent ID="PageContent2" runat="server">
            <MVSN_LAYOUT:PageContentLeft id="leftContent" Layout="FullPage" runat="server">                
            </MVSN_LAYOUT:PageContentLeft>
            <MVSN_LAYOUT:PageContentRight ID="RightContent1" runat="server">
					<form id="PackageConfigForm" method="post" runat="server">
						<table style="WIDTH: 100%; HEIGHT: 80%">
							<tr style="BORDER-BOTTOM: 1px groove; HEIGHT: 90%">
								<td style="BORDER-BOTTOM: 1px groove; BORDER-LEFT: 1px groove;BORDER-TOP: 1px groove; BORDER-RIGHT: 2px groove; WIDTH: 25%" vAlign="top" align="left">
									<?XML:NAMESPACE PREFIX=TVNS />
									<?IMPORT NAMESPACE=TVNS IMPLEMENTATION="/ASDistribution/webctrl_client/1_0/treeview.htc" />
									<iewc:treeview id="packageTreeView" runat="server" DefaultStyle="font-family:verdana;font-size:7.5pt"
										Width="100%" Height="100%" OnSelectedIndexChange="packageTreeView_SelectionChanged" AutoPostBack="True"
										Font-Name="Verdana" Font-Size="7.5pt"></iewc:treeview></td>
								<td vAlign="top" width="10">&nbsp;</td>
								<td vAlign="top">
									<DIV style="OVERFLOW-Y:visible; WIDTH: 100%; HEIGHT: 100%"><asp:placeholder id="RightSideItem" runat="server"></asp:placeholder></DIV>
								</td>
							</tr>
							<tr>
								<td colSpan="3">
									<hr>
								</td>
							</tr>
							<tr>
								<td colSpan="3"><asp:label id="validationMessage" ForeColor="Red" Font-Bold="True" Runat="server"></asp:label></td>
							</tr>
							<TR>
								<TD colSpan="3"><asp:button id="btnNext" runat="server" Text=" Next >  " Cssclass="SMSButton"></asp:button>&nbsp;
									
									<asp:button id="btnReturn" Width="162px" Runat="server" Text="Return to Distribution Home" CssClass="SMSButton"></asp:button></TD>
									
							</TR>
						</table>
					</form>
            </MVSN_LAYOUT:PageContentRight>
        </MVSN_LAYOUT:PageContent>
    </MVSN_LAYOUT:PageLayout>
</asp:Content>
