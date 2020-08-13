<%@ page language="C#" masterpagefile="~/AdminStudioBaseMaster.master" autoeventwireup="true" inherits="SMS.PackageDelete, AdminStudio.WebApplication" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.Controls" TagPrefix="MVSN_CTRL" %>
<%@ Register Assembly="AdminStudioControls" Namespace="AdminStudio.Web.PageFramework" TagPrefix="MVSN_LAYOUT" %>
<%@ Register TagPrefix="AMS" TagName="ToolTip" Src="~\AMSAdmin\UserControls\UCHelpText.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="masterContent" Runat="Server">
<MVSN_LAYOUT:PageLayout ID="Layout1" Layout="FullPage" runat="server">
        <MVSN_LAYOUT:PageContent ID="PageContent2" runat="server">
            <MVSN_LAYOUT:PageContentLeft id="leftContent" Layout="FullPage" runat="server">                
            </MVSN_LAYOUT:PageContentLeft>
            <MVSN_LAYOUT:PageContentRight ID="RightContent1" Title="_Package Selection Title_" runat="server">
				<script language="javascript">
				<!--
					function HideOrShowDivTag(divID, hideOrShowFlag)
					{
						if(hideOrShowFlag == 0)
						{
							document.getElementById(divID).style.display = "none";
						}
						else
						{
							document.getElementById(divID).style.display = "block";
						}
					}
				//-->
				</script>
				<form id="frmPackageDelete" method="post" runat="server">
					<div class="pageContent">
						<asp:Label Visible="False" Runat="server" ID="lblPackageIsDeleted" Font-Bold="True" ForeColor="Red">This package appears to be deleted from SMS.</asp:Label>
						<div id="divDBDelete">
							<asp:label ID="lbl_DelMess" Runat="server">Do you want to delete this package entry from <b>
									Application Catalog</b>? 
							&nbsp;&nbsp;&nbsp;</asp:label>
							<input type="radio" CHECKED value="1" name="radioDBDelete">Yes&nbsp; <input type="radio" value="0" name="radioDBDelete">No
							<br>
							<br>
						</div>
						<div id="divSMSDelete">
							<asp:label ID="lbl_DelMess1" Runat="server">
							Are you sure you want to delete this package entry from <b>SMS</b>? 
							&nbsp;&nbsp;&nbsp;
							</asp:label>
							<input onclick="smsMessage.style.display = 'block';" type="radio" CHECKED value="1" name="radioSMSDelete">Yes&nbsp;
							<input onclick="smsMessage.style.display = 'none';" type="radio" value="0" name="radioSMSDelete">No
							<div id="smsMessage" style="MARGIN-LEFT:18px">
								<asp:label ID="lbl_DelMess2" Runat="server">
								Deleting the package from SMS will also delete its programs and any 
								advertisements of the programs. If the package has source files, they will be 
								removed from distribution points. If there are access accounts for this 
								package, they will be deleted. Also, SMS Administrators' security rights to the 
								package will be deleted.
								</asp:label>
							</div>
							<br>
						</div>
						<asp:TextBox Visible="False" ID="packageExistsInSMS" Runat="server"></asp:TextBox>
						<input type="submit" class="SMSButton" value="OK">&nbsp;&nbsp; <input type="button" class="SMSButton" value="Cancel" onclick="window.location = '<%=strRelativeHomeLocation%>';">
					</div>
					<asp:PlaceHolder ID="scriptCode" Runat="server"></asp:PlaceHolder>
				</form>
            </MVSN_LAYOUT:PageContentRight>
        </MVSN_LAYOUT:PageContent>
    </MVSN_LAYOUT:PageLayout>
</asp:Content>
