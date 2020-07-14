<%@ page language="C#" masterpagefile="~/AdminStudioBaseMaster.master" autoeventwireup="true" inherits="ASDistribution_SelectApplicationCatalog, AdminStudio.WebApplication" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.Controls" TagPrefix="MVSN_CTRL" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.PageFramework" TagPrefix="MVSN_LAYOUT" %>
<%@ Register TagPrefix="AMS" TagName="ToolTip" Src="~\AMSAdmin\UserControls\UCHelpText.ascx" %>
<%@ Register TagPrefix="MVSN" TagName="SelCat" Src="~\LegacyUIControls\CatalogSelector.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="masterContent" Runat="Server">
<MVSN_LAYOUT:PageLayout ID="Layout1" Layout="FullPage" runat="server">
        <MVSN_LAYOUT:PageContent ID="PageContent2" runat="server">
            <MVSN_LAYOUT:PageContentLeft id="leftContent" Layout="FullPage" runat="server">                
            </MVSN_LAYOUT:PageContentLeft>
            <MVSN_LAYOUT:PageContentRight ID="RightContent1" Title="Select Application Catalog" runat="server">
            <MVSN_LAYOUT:BreadCrumb Title="Distribution Home" Link="/ASDistribution/ASDistribution/Default.aspx" ID="BreadCrumb1" runat="server" />
            <div class="pageContent">
		        <form id="Form1" method="post" runat="server">				
                    <MVSN:SelCat id="custom1" runat="server"></MVSN:SelCat>
		        </form>
            </div>
            </MVSN_LAYOUT:PageContentRight>
        </MVSN_LAYOUT:PageContent>
    </MVSN_LAYOUT:PageLayout>
</asp:Content>