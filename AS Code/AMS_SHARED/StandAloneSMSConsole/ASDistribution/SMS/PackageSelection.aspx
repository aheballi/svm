<%@ page language="C#" masterpagefile="~/AdminStudioBaseMaster.master" autoeventwireup="true" inherits="SMS.PackageSelection, AdminStudio.WebApplication" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.Controls" TagPrefix="MVSN_CTRL" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.PageFramework" TagPrefix="MVSN_LAYOUT" %>
<%@ Register TagPrefix="AMS" TagName="ToolTip" Src="~\AMSAdmin\UserControls\UCHelpText.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="masterContent" Runat="Server">
<MVSN_LAYOUT:PageLayout ID="Layout1" Layout="FullPage" runat="server">
        <MVSN_LAYOUT:PageContent ID="PageContent2" runat="server">
            <MVSN_LAYOUT:PageContentLeft id="leftContent" Layout="FullPage" runat="server">                
            </MVSN_LAYOUT:PageContentLeft>
            <MVSN_LAYOUT:PageContentRight ID="RightContent1" Title="_Package Selection Title_" runat="server">
				<form id="Form1" method="post" runat="server">
					<DIV class="pageContent">
						<asp:Label id="lblPkgSelection" runat="server" Width="90%"></asp:Label>
					</DIV>
					<table width = "95%">
					<tr><td>
					<asp:datagrid id="PackageGrid" runat="server" OnItemDataBound="PackageGrid_ItemBound" BorderWidth="1px"
							BorderColor="gray" BorderStyle="Solid" OnSortCommand="PackageGrid_Sort" OnPageIndexChanged="PackageGrid_PageChanged"
							AutoGenerateColumns="False" AllowSorting="True" AllowPaging="True" AllowCustomPaging="True" Width="100%" DataKeyField="AppID"
							CellPadding="2">
							<AlternatingItemStyle ForeColor="Black" BackColor="Gainsboro"></AlternatingItemStyle>
							<ItemStyle ForeColor="Black" BackColor="White"></ItemStyle>
							<Columns>
								<asp:TemplateColumn>
									<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									<ItemStyle HorizontalAlign="Center"></ItemStyle>
									<ItemTemplate>
										<asp:RadioButton OnCheckedChanged="packagegridrdButton_Changed" id="packagegridrdButton" AutoPostBack="True"
											Runat="server"></asp:RadioButton>
									</ItemTemplate>
								</asp:TemplateColumn>
								<asp:BoundColumn DataField="SMSPackageID" SortExpression="SMSPackageID" HeaderText="SMS Package ID">
									<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
								</asp:BoundColumn>
								<asp:BoundColumn DataField="Name" SortExpression="Name" HeaderText="Package Name">
									<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
								</asp:BoundColumn>
								<asp:BoundColumn DataField="Version" SortExpression="Version" HeaderText="Version">
									<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
								</asp:BoundColumn>
								<asp:BoundColumn DataField="Language" SortExpression="Language" HeaderText="Language">
									<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
								</asp:BoundColumn>
								<asp:BoundColumn DataField="Description" SortExpression="Description" HeaderText="Description">
									<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
								</asp:BoundColumn>
								<asp:TemplateColumn SortExpression="SMSPackageID" HeaderText="Status">
									<HeaderStyle Font-Underline="True" Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									<ItemTemplate>
										<asp:Label ID="lblStatus" Runat="server"></asp:Label>
									</ItemTemplate>
								</asp:TemplateColumn>
								<asp:BoundColumn DataField="ApplicationName" SortExpression="ApplicationName" HeaderText="Application Name">
									<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
								</asp:BoundColumn>
								<asp:BoundColumn DataField="CompanyName" SortExpression="CompanyName" HeaderText="Company Name">
									<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
								</asp:BoundColumn>
							</Columns>
							<PagerStyle Mode="NumericPages"></PagerStyle>
						</asp:datagrid>
						</td></tr>
					</table>
						<asp:Label id="lbl_noPackage" runat="server" Width="848px" ForeColor="Red" Font-Bold="True"
							Height="2px" Visible="False">This Application Catalog does not contain any distributable packages.  Import package(s) to distribute into Application Catalog.</asp:Label><br>
						<br>
						<asp:button id="buttonModify" onclick="buttonModify_Click" runat="server" Text="Modify Settings"></asp:button><asp:button id="buttonDistribute" onclick="buttonDistribute_Click" runat="server" Text="Distribute"
							CssClass="SMSButton"></asp:button><asp:button id="buttonViewStatus" onclick="buttonViewStatus_Click" runat="server" Text="View Status"></asp:button><asp:button id="buttonDelete" onclick="buttonDelete_Click" runat="server" Text="Delete Distributon"></asp:button>&nbsp;
				</form>
            </MVSN_LAYOUT:PageContentRight>
        </MVSN_LAYOUT:PageContent>
    </MVSN_LAYOUT:PageLayout>
</asp:Content>
