<%@ page language="C#" masterpagefile="~/AdminStudioBaseMaster.master" autoeventwireup="true" inherits="SMS.SMSPackageStatus, AdminStudio.WebApplication" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.Controls" TagPrefix="MVSN_CTRL" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.PageFramework" TagPrefix="MVSN_LAYOUT" %>
<%@ Register TagPrefix="AMS" TagName="ToolTip" Src="~\AMSAdmin\UserControls\UCHelpText.ascx" %>
<%@ Register TagPrefix="iewc" Namespace="Microsoft.Web.UI.WebControls" Assembly="Microsoft.Web.UI.WebControls" %>
<asp:Content ID="Content1" ContentPlaceHolderID="masterContent" Runat="Server">
<MVSN_LAYOUT:PageLayout ID="Layout1" Layout="FullPage" runat="server">
        <MVSN_LAYOUT:PageContent ID="PageContent2" runat="server">
            <MVSN_LAYOUT:PageContentLeft id="leftContent" Layout="FullPage" runat="server">                
            </MVSN_LAYOUT:PageContentLeft>
            <MVSN_LAYOUT:PageContentRight ID="RightContent1" runat="server">
				<form id="frmPackageStatus" method="post" runat="server">
					<div class="pageContent">
						<asp:Label id="lblPkgNotInSMSMsg" runat="server" Visible="False">Package status cannot be displayed as this package is still not available in SMS.</asp:Label>
						<br>
						<div id="statusGrids">
							<span class="sectionTitle">
								<asp:Label ID=lbl_PckStatus Runat=server>Package Status for </asp:Label><b>&nbsp;<asp:Label ID=lblPckName Runat=server></asp:Label></b>
							</span>
							<br>
							<asp:datagrid id="datagridPkgStatus" runat="server" Width="95%" AutoGenerateColumns="False" ForeColor="Black"
								GridLines="Vertical" CellPadding="4" BackColor="White" BorderWidth="1px" BorderStyle="None"
								BorderColor="#DDDDDD" Font-Bold="False" Font-Italic="False" Font-Overline="False" Font-Strikeout="False" Font-Underline="False">
								<SelectedItemStyle Font-Bold="True" ForeColor="White" BackColor="#CE5D5A"></SelectedItemStyle>
								<AlternatingItemStyle BackColor="AliceBlue"></AlternatingItemStyle>
								<ItemStyle BackColor="White"></ItemStyle>
								<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3" Font-Italic="False" Font-Overline="False" Font-Strikeout="False" Font-Underline="False"></HeaderStyle>
								<FooterStyle BackColor="#CCCC99"></FooterStyle>
								<Columns>
									<asp:BoundColumn DataField="Site" HeaderText="Site">
										<ItemStyle Wrap="False"></ItemStyle>
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="DistPoint" HeaderText="Distribution Point">
										<ItemStyle Wrap="False"></ItemStyle>
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="State" HeaderText="State">
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="LastCopied" HeaderText="Last Copied">
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="SrcVersion" HeaderText="Source Version">
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="Targeted" HeaderText="Targeted">
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="Installed" HeaderText="Installed">
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="Retrying" HeaderText="Retrying">
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="Failed" HeaderText="Failed">
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="SummaryDate" HeaderText="Summary Date">
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="Path" HeaderText="Path">
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
								</Columns>
								<PagerStyle HorizontalAlign="Right" ForeColor="Black" BackColor="#F7F7DE" Mode="NumericPages"></PagerStyle>
							</asp:datagrid><br>
							<br>
							<span class="sectionTitle">
								<asp:Label ID="lbl_AdvStatus" Runat=server>Advertisement Status for </asp:Label><b>&nbsp;<asp:Label ID="lblPckName1" Runat=server></asp:Label></b>
							</span>
							<br>
							<asp:datagrid id="datagridAdvStatus" runat="server" Width="95%" AutoGenerateColumns="False" ForeColor="Black"
								GridLines="Vertical" CellPadding="4" BackColor="White" BorderWidth="1px" BorderStyle="None"
								BorderColor="#DDDDDD">
								<SelectedItemStyle Font-Bold="True" ForeColor="White" BackColor="#CE5D5A"></SelectedItemStyle>
								<AlternatingItemStyle BackColor="AliceBlue"></AlternatingItemStyle>
								<ItemStyle BackColor="White"></ItemStyle>
								<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
								<FooterStyle BackColor="#CCCC99"></FooterStyle>
								<Columns>
									<asp:BoundColumn DataField="AdvName" HeaderText="Advertisement Name">
										<ItemStyle Wrap="False"></ItemStyle>
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="Site" HeaderText="Site">
										<ItemStyle Wrap="False"></ItemStyle>
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="TargetCollection" HeaderText="Target Collection">
										<ItemStyle Wrap="False"></ItemStyle>
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="Program" HeaderText="Program">
										<ItemStyle Wrap="False"></ItemStyle>
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="AvailableAfter" HeaderText="Available After">
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="ExpiresAfter" HeaderText="Expires After">
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="Received" HeaderText="Received">
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="Failures" HeaderText="Failures">
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="ProgramsStarted" HeaderText="Programs Started">
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="ProgramErrors" HeaderText="Program Errors">
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="ProgramSuccess" HeaderText="Program Success">
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="AdvID" HeaderText="Advertisement ID">
										<ItemStyle Wrap="False"></ItemStyle>
										<HeaderStyle ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
								</Columns>
								<PagerStyle HorizontalAlign="Right" ForeColor="Black" BackColor="#F7F7DE" Mode="NumericPages"></PagerStyle>
							</asp:datagrid>
						</div>
						<br>
						<asp:Button ID="btnRefresh" runat="server" Visible="True" Text="   Refresh Status  " />
						<asp:PlaceHolder Runat="server" ID="hideShowGrids"></asp:PlaceHolder>
					</div>
				</form>
            </MVSN_LAYOUT:PageContentRight>
        </MVSN_LAYOUT:PageContent>
    </MVSN_LAYOUT:PageLayout>
</asp:Content>
