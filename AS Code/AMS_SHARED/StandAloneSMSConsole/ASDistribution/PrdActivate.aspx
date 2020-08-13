<%@ page language="c#" masterpagefile="~/AdminStudioBaseMaster.master" inherits="ASDistribution.PrdActivate, AdminStudio.WebApplication" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.Controls" TagPrefix="MVSN_CTRL" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.PageFramework" TagPrefix="MVSN_LAYOUT" %>
<%@ Register TagPrefix="MVSN" TagName="Activate" Src="~\LegacyUIControls\Activate.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="masterContent" Runat="Server">
<MVSN_LAYOUT:PageLayout ID="Layout1" Layout="FullPage" runat="server">
        <MVSN_LAYOUT:PageContent ID="PageContent2" runat="server">
            <MVSN_LAYOUT:PageContentLeft id="leftContent" Layout="FullPage" runat="server">                
            </MVSN_LAYOUT:PageContentLeft>
            <MVSN_LAYOUT:PageContentRight ID="RightContent1" Title="Activation" runat="server">
		        <form id="Form1" method="post" runat="server">
			        <asp:Panel id="Panel2" style="Z-INDEX: 101; LEFT: 48px; POSITION: absolute; TOP: 150px" runat="server"
				        Width="752px" Height="352px">
				        <MVSN:Activate id="Activate" runat="server"></MVSN:Activate>
			        </asp:Panel>
		        </form>
            </MVSN_LAYOUT:PageContentRight>
        </MVSN_LAYOUT:PageContent>
    </MVSN_LAYOUT:PageLayout>
</asp:Content>
