<%@ page language="C#" masterpagefile="~/AdminStudioBaseMaster.master" autoeventwireup="true" inherits="SMS.DistributionSettings, AdminStudio.WebApplication" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.Controls" TagPrefix="MVSN_CTRL" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.PageFramework" TagPrefix="MVSN_LAYOUT" %>
<%@ Register TagPrefix="AMS" TagName="ToolTip" Src="~\AMSAdmin\UserControls\UCHelpText.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="masterContent" Runat="Server">
<MVSN_LAYOUT:PageLayout ID="Layout1" Layout="FullPage" runat="server">
        <MVSN_LAYOUT:PageContent ID="PageContent2" runat="server">
            <MVSN_LAYOUT:PageContentLeft id="leftContent" Layout="FullPage" runat="server">                
            </MVSN_LAYOUT:PageContentLeft>
            <MVSN_LAYOUT:PageContentRight ID="RightContent1" runat="server">
				<form id="frmDistSystemSelection" method="post" runat="server">
					<div class="pageContent"><br>
						<div class="sectionTitle">Choose Default Distribution System:</div>
						<div style="MARGIN-LEFT:10px">
							<asp:radiobuttonlist id="RdBtnProvList" runat="server" AutoPostBack="True" RepeatLayout="Flow" OnSelectedIndexChanged="RdBtnProvList_SelectedIndexChanged"></asp:radiobuttonlist>
						</div>
						<br>
						<asp:button id="btnUpdate" onclick="btnUpdate_Click" runat="server" Text="Update"></asp:button>&nbsp;&nbsp;
						<asp:button id="btnCancel" onclick="btnCancel_Click" runat="server" Text="Cancel"></asp:button>
					</div>
				</form>
            </MVSN_LAYOUT:PageContentRight>
        </MVSN_LAYOUT:PageContent>
    </MVSN_LAYOUT:PageLayout>
</asp:Content>
