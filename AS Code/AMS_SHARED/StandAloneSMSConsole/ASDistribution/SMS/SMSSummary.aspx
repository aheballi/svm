<%@ page language="C#" masterpagefile="~/AdminStudioBaseMaster.master" autoeventwireup="true" inherits="SMS.SMSSummary, AdminStudio.WebApplication" %>
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
					<form id="frmPackageSummary" method="post" runat="server">
						<div class="pageContent"><asp:label id="lblSaveMessage" Runat="server" Font-Bold="True"></asp:label>
							<div id="statusDIV"><b>
									<asp:Label ID="lblHeader" Runat="server">
							Summary for package 
							</asp:Label>
									<font size="+1">
										<asp:Label ID="lbl_PckName" Runat="server"></asp:Label>
									</font></b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<asp:image id="pkgImage" runat="server" ImageAlign="AbsMiddle"></asp:image><br>
								<br>
								<div class="SMSSpan20"><asp:datagrid id="datagridPkgDetails" runat="server" Width="88%" AutoGenerateColumns="False" ForeColor="White"
										GridLines="Vertical" CellPadding="4" BackColor="Gray" BorderWidth="1px" BorderStyle="Solid" BorderColor="Gray">
										<SelectedItemStyle Font-Bold="True" ForeColor="White" BackColor="#CE5D5A"></SelectedItemStyle>
										<AlternatingItemStyle BackColor="#F7F7DE"></AlternatingItemStyle>
										<ItemStyle BackColor="White"></ItemStyle>
										<FooterStyle BackColor="#437CD3"></FooterStyle>
										<Columns>
											<asp:BoundColumn DataField="Name" HeaderText="Package Name">
												<ItemStyle Wrap="False"></ItemStyle>
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
											<asp:BoundColumn DataField="SMSPackageID" HeaderText="SMS Package ID">
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
												<ItemStyle Wrap="False"></ItemStyle>
											</asp:BoundColumn>
											<asp:BoundColumn DataField="SMSServerLocation" HeaderText="Server">
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
											<asp:BoundColumn DataField="SMSSiteCode" HeaderText="Site Code">
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
											<asp:BoundColumn DataField="Description" HeaderText="Comments">
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
											<asp:BoundColumn DataField="Version" HeaderText="Version">
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
											<asp:BoundColumn DataField="Language" HeaderText="Language">
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
											<asp:BoundColumn DataField="Manufacturer" HeaderText="Manufacturer">
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
										</Columns>
										<PagerStyle HorizontalAlign="Right" ForeColor="White" BackColor="#437CD3" Mode="NumericPages"></PagerStyle>
									</asp:datagrid><br>
									<asp:label id="lblPkg" Runat="server" ForeColor="Red">Error while accessing information for this package.</asp:label></div>
								<br>
								<br>
								<b>
									<asp:Label ID="lblProg" Runat="server">		
								
								Programs
								</asp:Label>
								</b>
								<br>
								<br>
								<div class="SMSSpan20"><asp:datagrid id="datagridPrograms" runat="server" Width="88%" AutoGenerateColumns="False" ForeColor="Black"
										GridLines="Vertical" CellPadding="4" BackColor="White" BorderWidth="1px" BorderStyle="Solid" BorderColor="Gray">
										<SelectedItemStyle Font-Bold="True" ForeColor="White" BackColor="#CE5D5A"></SelectedItemStyle>
										<AlternatingItemStyle BackColor="Gainsboro"></AlternatingItemStyle>
										<ItemStyle BackColor="White"></ItemStyle>
										<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="Silver"></HeaderStyle>
										<FooterStyle BackColor="#CCCC99"></FooterStyle>
										<Columns>
											<asp:BoundColumn DataField="ProgramName" HeaderText="Name">
												<ItemStyle Wrap="False"></ItemStyle>
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
											<asp:BoundColumn DataField="Comment" HeaderText="Comment">
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
											<asp:BoundColumn DataField="CommandLine" HeaderText="Command Line">
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
										</Columns>
										<PagerStyle HorizontalAlign="Right" ForeColor="Black" BackColor="#F7F7DE" Mode="NumericPages"></PagerStyle>
									</asp:datagrid><br>
									<asp:label id="lblPrograms" Runat="server" ForeColor="Gray">No programs found.</asp:label></div>
								<br>
								<br>
								<b>
									<asp:Label ID="lblAdv" Runat="server">									
								Advertisements
								</asp:Label>
								</b>
								<br>
								<br>
								<div class="SMSSpan20"><asp:datagrid id="datagridAdvertisements" runat="server" Width="88%" AutoGenerateColumns="False"
										ForeColor="Black" GridLines="Vertical" CellPadding="4" BackColor="White" BorderWidth="1px" BorderStyle="Solid"
										BorderColor="Gray" OnItemDataBound="AdvtGrid_ItemBound">
										<SelectedItemStyle Font-Bold="True" ForeColor="White" BackColor="#CE5D5A"></SelectedItemStyle>
										<AlternatingItemStyle BackColor="Gainsboro"></AlternatingItemStyle>
										<ItemStyle BackColor="White"></ItemStyle>
										<FooterStyle BackColor="#CCCC99"></FooterStyle>
										<Columns>
											<asp:BoundColumn DataField="AdvertisementName" HeaderText="Name">
												<ItemStyle Wrap="False"></ItemStyle>
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
											<asp:BoundColumn DataField="SMSAdvtID" HeaderText="SMS Advertisement ID">
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
											<asp:BoundColumn DataField="Comment" HeaderText="Comment">
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
											<asp:BoundColumn DataField="ProgramName" HeaderText="Program">
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
											<asp:BoundColumn DataField="PresentTime" HeaderText="Available After">
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
											<asp:TemplateColumn>
												<HeaderTemplate>
													<asp:Label ID="lblExpires" Runat="server">
													Expires After
													</asp:Label>
												</HeaderTemplate>
												<ItemTemplate>
													<asp:Label ID="lblAdvtExpireID" Runat="server"></asp:Label>
												</ItemTemplate>
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:TemplateColumn>
										</Columns>
										<PagerStyle HorizontalAlign="Right" ForeColor="Black" BackColor="#F7F7DE" Mode="NumericPages"></PagerStyle>
									</asp:datagrid><br>
									<asp:label id="lblAdvt" Runat="server" ForeColor="Gray">No advertisements found.</asp:label></div>
								<br>
								<br>
								<b>
									<asp:Label ID="lblDistPoint" Runat="server">
								Distribution Points
								</asp:Label>
								</b>
								<br>
								<br>
								<asp:label id="lblRefreshPkgSource" Runat="server">Update all sites and distribution points with the latest version of the package. <br><br></asp:label>
								<div class="SMSSpan20"><asp:datagrid id="datagridDistPoints" runat="server" Width="88%" AutoGenerateColumns="False" ForeColor="Black"
										GridLines="Vertical" CellPadding="4" BackColor="White" BorderWidth="1px" BorderStyle="Solid" BorderColor="Gray">
										<SelectedItemStyle Font-Bold="True" ForeColor="White" BackColor="#CE5D5A"></SelectedItemStyle>
										<AlternatingItemStyle ForeColor="Black" BackColor="Gainsboro"></AlternatingItemStyle>
										<FooterStyle BackColor="#CCCC99"></FooterStyle>
										<Columns>
											<asp:BoundColumn DataField="Name" HeaderText="Name">
												<ItemStyle Wrap="False"></ItemStyle>
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
											<asp:BoundColumn DataField="Site" HeaderText="Site">
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
										</Columns>
										<PagerStyle HorizontalAlign="Right" ForeColor="Black" BackColor="#F7F7DE" Mode="NumericPages"></PagerStyle>
									</asp:datagrid><br>
									<asp:label id="lblDistPoints" Runat="server" ForeColor="Gray">No distribution points found.</asp:label></div>
								<br>
								<br>
								<b>
									<asp:Label ID="lblAccAcounts" Runat="server">
								Access Accounts
								</asp:Label>
								</b>
								<br>
								<br>
								<div class="SMSSpan20"><asp:datagrid id="datagridAccessAccounts" runat="server" Width="88%" AutoGenerateColumns="False"
										ForeColor="Black" GridLines="Vertical" CellPadding="4" BackColor="White" BorderWidth="1px" BorderStyle="Solid"
										BorderColor="Gray">
										<SelectedItemStyle Font-Bold="True" ForeColor="White" BackColor="#CE5D5A"></SelectedItemStyle>
										<AlternatingItemStyle BackColor="Gainsboro"></AlternatingItemStyle>
										<ItemStyle BackColor="White"></ItemStyle>
										<FooterStyle BackColor="#CCCC99"></FooterStyle>
										<Columns>
											<asp:BoundColumn DataField="Name" HeaderText="Name">
												<ItemStyle Wrap="False"></ItemStyle>
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
											<asp:BoundColumn DataField="Type" HeaderText="Type">
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
											<asp:BoundColumn DataField="Permissions" HeaderText="Permissions">
												<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
											</asp:BoundColumn>
										</Columns>
										<PagerStyle HorizontalAlign="Right" ForeColor="Black" BackColor="#F7F7DE" Mode="NumericPages"></PagerStyle>
									</asp:datagrid><br>
									<asp:label id="lblAccounts" Runat="server" ForeColor="Gray">No access accounts found.</asp:label></div>
								<br>
								<br>
								<input id="btnBack" class="SMSButton" onclick="window.top.location = 'SMSPackageConfig.aspx';"
									type="button" value=" < Back  " runat="server"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<asp:button id="btnCommitChanges" runat="server" Text="  Commit Changes to SMS  "></asp:button>&nbsp;&nbsp;
								<asp:button id="btnReturn" runat="server" Text="Return to SMS Web Console Home" Width="208px"></asp:button><br>
							</div>
						</div>
						<asp:placeholder id="placeholderHideGrids" Runat="server"></asp:placeholder>
					</form>
            </MVSN_LAYOUT:PageContentRight>
        </MVSN_LAYOUT:PageContent>
    </MVSN_LAYOUT:PageLayout>
</asp:Content>
