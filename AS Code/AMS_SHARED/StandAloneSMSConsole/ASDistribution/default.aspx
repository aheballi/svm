<%--<%@ Reference Page="SetDbInfo.aspx" %>--%>
<%@ page language="C#" masterpagefile="~/AdminStudioBaseMaster.master" autoeventwireup="true" inherits="ASDistribution.MainPageViewClass, AdminStudio.WebApplication" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.Controls" TagPrefix="MVSN_CTRL" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.PageFramework" TagPrefix="MVSN_LAYOUT" %>
<%@ Register TagPrefix="AMS" TagName="ToolTip" Src="~\AMSAdmin\UserControls\UCHelpText.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="masterContent" Runat="Server">
<MVSN_LAYOUT:PageLayout ID="Layout1" Layout="FullPage" runat="server">
        <MVSN_LAYOUT:PageContent ID="PageContent2" runat="server">
            <MVSN_LAYOUT:PageContentLeft id="leftContent" Layout="FullPage" runat="server">                
            </MVSN_LAYOUT:PageContentLeft>
            <MVSN_LAYOUT:PageContentRight ID="RightContent1" runat="server">
            <MVSN_LAYOUT:BreadCrumb Title="" Link="" ID="BreadCrumb1" runat="server" />
					<form id="Form1" method="post" runat="server">
						<div align=center><br>
						<asp:HyperLink id=hypLinkHome runat="server" Font-Bold="True" ForeColor="#0000C0" Visible="False">This Session has Expired, Click here to restart the session.</asp:HyperLink></div>
						<table id=tbl_default class="distareaTable" border="0" runat=server>
							<tr>
								<td>
									<asp:HyperLink id="PackageSelection1" NavigateUrl="SMS/PackageSelection.aspx?op=new" runat="server"><img src="../images/DistributePackage.gif" align="middle" class="areaIcon"</asp:HyperLink>
									<asp:HyperLink id="PackageSelection2"  NavigateUrl="SMS/PackageSelection.aspx?op=new" CssClass="areaTitle" runat="server">Distribute a New Package</asp:HyperLink>
									<ul class="areaInstructions">
										<li>
										Distribute a package using Distribution Providers
										</li>
									</ul>
								</td>
								<td>
									<asp:HyperLink id="SMSSettings1" NavigateUrl="SMS/SMSSettings.aspx"  runat="server"><img src="../images/DistributionSettings.gif" align="middle" class="areaIcon"</asp:HyperLink>
									<asp:HyperLink id="SMSSettings2"  NavigateUrl="SMS/SMSSettings.aspx" CssClass="areaTitle" runat="server">Distribution Settings</asp:HyperLink>
									<ul class="areaInstructions">
										<li>
										Configure Distribution Providers settings
										</li>
									</ul>
								</td>
							</tr>
							<tr>
								<td>
									<asp:HyperLink id="PackageAdmin1" NavigateUrl="SMS/PackageSelection.aspx?op=existing"  runat="server"><img src="../images/ViewPackages.gif" align="middle" class="areaIcon"></asp:HyperLink>
									<asp:HyperLink id="PackageAdmin2" NavigateUrl="SMS/PackageSelection.aspx?op=existing" CssClass="areaTitle" runat="server">Package Administration</asp:HyperLink>
									<ul class="areaInstructions">
										<li>
										Modify package settings
										<li>
										View package distribution status
										<li>
											Delete an existing package</li>
									</ul>
								</td>
							</tr>
						</table>
					</form>
            </MVSN_LAYOUT:PageContentRight>
        </MVSN_LAYOUT:PageContent>
    </MVSN_LAYOUT:PageLayout>
</asp:Content>
