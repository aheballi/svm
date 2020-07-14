<%@ page language="C#" masterpagefile="~/AdminStudioBaseMaster.master" autoeventwireup="true" inherits="SMS.PDFSelector, AdminStudio.WebApplication" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.Controls" TagPrefix="MVSN_CTRL" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.PageFramework" TagPrefix="MVSN_LAYOUT" %>
<%@ Register TagPrefix="AMS" TagName="ToolTip" Src="~\AMSAdmin\UserControls\UCHelpText.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="masterContent" Runat="Server">
<MVSN_LAYOUT:PageLayout ID="Layout1" Layout="FullPage" runat="server">
        <MVSN_LAYOUT:PageContent ID="PageContent2" runat="server">
            <MVSN_LAYOUT:PageContentLeft id="leftContent" Layout="FullPage" runat="server">                
            </MVSN_LAYOUT:PageContentLeft>
            <MVSN_LAYOUT:PageContentRight ID="RightContent1" runat="server">
				<form id="frmPDFSelector" method="post" runat="server">
					<div class="pageContent">
						<asp:checkbox id="chkUsePDF" runat="server" Text="Distribute using Package Definition" AutoPostBack="true"
							OnCheckedChanged="chkUsePDF_CheckedChanged"></asp:checkbox>
						<br>
						<br>
						<div style="MARGIN-LEFT:16px">
							<asp:radiobutton id="rbbtnExistingPDF" runat="server" Text="Use Existing Package Definition" AutoPostBack="true"
								OnCheckedChanged="rbbtnExistingPDF_CheckedChanged"></asp:radiobutton>
							<div style="MARGIN-LEFT:20px">
							<asp:datagrid id="pdfGrid" runat="server"  DataKeyField="PDFID" AllowPaging="True"
								AllowSorting="True" AutoGenerateColumns="False" Width="90%" PageSize="6"
								OnPageIndexChanged="PageIndex_Changed" BorderStyle="Solid" BorderColor="gray">
								<AlternatingItemStyle ForeColor="Black" BackColor="Gainsboro"></AlternatingItemStyle>
								<ItemStyle ForeColor="Black" BackColor="White"></ItemStyle>
								<Columns>
									<asp:TemplateColumn>
										<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
										<ItemStyle HorizontalAlign="Center"></ItemStyle>
										<ItemTemplate>
											<asp:RadioButton OnCheckedChanged="pdfgridrdButton_Changed" id="packagegridrdButton" AutoPostBack="True"
												Runat="server"></asp:RadioButton>
										</ItemTemplate>
									</asp:TemplateColumn>
									<asp:BoundColumn DataField="Publisher" HeaderText="Publisher">
										<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="Name" HeaderText="Name">
										<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="Version" HeaderText="Version">
										<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
									<asp:BoundColumn DataField="Language" HeaderText="Language">
										<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
									</asp:BoundColumn>
								</Columns>
								<PagerStyle Mode="NumericPages"></PagerStyle>
							</asp:datagrid>
							</div>
							<br>
							<br>
							<asp:radiobutton id="rdbtnNewPDF" runat="server" Text="Use Package Definition from the following file:"
								AutoPostBack="true" OnCheckedChanged="rdbtnNewPDF_CheckedChanged"></asp:radiobutton>
							<br>
							<div style="MARGIN-LEFT:20px"><br>
								<asp:DropDownList Runat="server" ID="pdfFileList" AutoPostBack="False" EnableViewState="True"></asp:DropDownList>
								<br>
								<asp:Label id="lblPDFNote" Runat="server"></asp:Label>
							</div>
						</div>
						<br>
						<br>
						<asp:button id="btnNext"  CssClass="SMSButton" runat="server" Text="Next >"></asp:button>
						<asp:button id="btnCancel" CssClass="SMSButton" runat="server" Text="Cancel"></asp:button><br>
						<br>
						<asp:Label id="lblErrorMsg" runat="server" ForeColor="Red"></asp:Label>
					</div>
				</form>
            </MVSN_LAYOUT:PageContentRight>
        </MVSN_LAYOUT:PageContent>
    </MVSN_LAYOUT:PageLayout>
</asp:Content>
