<%@ page language="c#" masterpagefile="~/AdminStudioBaseMaster.master" autoeventwireup="true" inherits="SMS.NewPackage, AdminStudio.WebApplication" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.Controls" TagPrefix="MVSN_CTRL" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.PageFramework" TagPrefix="MVSN_LAYOUT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="masterContent" Runat="Server">
<MVSN_LAYOUT:PageLayout ID="Layout1" Layout="FullPage" runat="server">
        <MVSN_LAYOUT:PageContent ID="PageContent2" runat="server">
            <MVSN_LAYOUT:PageContentLeft id="leftContent" Layout="FullPage" runat="server">                
            </MVSN_LAYOUT:PageContentLeft>
            <MVSN_LAYOUT:PageContentRight ID="RightContent1" Title="Distribute New Package" runat="server">
		    <form id="Form1" method="post" runat="server">
			    <div class="pageContent"><br>
				    <div style="MARGIN-LEFT:10px">
					    <table cellpadding="0" cellspacing="0">
						    <tr>
							    <td width="110" bgcolor="#ffffff"><asp:label id="lblSiteServerName" Font-Bold="True" runat="server">Application Name:</asp:label></td>
							    <td><asp:TextBox id="txtPackageName" runat="server" Width="208px" MaxLength="50"></asp:TextBox>
								    &nbsp;<asp:RequiredFieldValidator Runat="server" ControlToValidate="txtPackageName" ErrorMessage="*" ForeColor="Red"
									    ID="Requiredfieldvalidator1"></asp:RequiredFieldValidator>
							    </td>
						    </tr>
					    </table>
				    </div>
				    <br>
				    <br>
				    <asp:button id="btnDistribute" CssClass="SMSButton" runat="server" Text="Distribute" onclick="btnDistribute_Click"></asp:button>&nbsp;&nbsp;
				    <asp:Button id="btnCancel" CssClass="SMSButton" runat="server" Text="Cancel" CausesValidation="False" onclick="btnCancel_Click"></asp:Button>
				    <br>
				    <br>
			    </div>
		    </form>
            </MVSN_LAYOUT:PageContentRight>
        </MVSN_LAYOUT:PageContent>
    </MVSN_LAYOUT:PageLayout>
</asp:Content>
