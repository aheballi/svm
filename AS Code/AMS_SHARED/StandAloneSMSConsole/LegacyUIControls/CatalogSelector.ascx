<%@ control language="c#" inherits="UIFramework.CatalogSelector, AdminStudio.WebApplication" targetschema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="MSFT" Namespace="Microsoft.Web.UI.WebControls" Assembly="Microsoft.Web.UI.WebControls"%>
<%@ Register TagPrefix="MVSN" TagName="Standalone" Src="Standalone.ascx" %>
<%@ Register TagPrefix="MVSN" TagName="Managed" Src="Managed.ascx" %>
<?XML:NAMESPACE PREFIX="TSNS" /><?IMPORT NAMESPACE="TSNS" IMPLEMENTATION="webctrl_client/1_0/tabstrip.htc" />
<?XML:NAMESPACE PREFIX="MPNS" /><?IMPORT NAMESPACE="MPNS" IMPLEMENTATION="webctrl_client/1_0/multipage.htc" />
<DIV style="WIDTH: 200px; POSITION: relative; HEIGHT: 524px" ms_positioning="GridLayout">
	<MSFT:TabStrip id="tabStrip1" style="FONT-WEIGHT: bold" SepDefaultStyle="border-bottom:solid 1px #000000;"
			TabSelectedStyle="border:solid 1px black;border-bottom:none;background:#7690B1;padding-left:5px;padding-right:5px;"
			TabHoverStyle="color:white;background:#7690B1;" TabDefaultStyle="style=font-weight:normal;font-family:tahoma;font-size:8pt; border:solid 1px black;background:#153063;padding-left:5px;padding-right:5px;"
			TargetID="thePages" runat="server" ForeColor="White" Width="100%">
		<MSFT:Tab Text="Enterprise Server"></MSFT:Tab>
		<MSFT:TabSeparator></MSFT:TabSeparator>
		<MSFT:Tab Text="Standalone"></MSFT:Tab>
	</MSFT:TabStrip>
	<MSFT:MultiPage Height="475px" id="thePages" runat="server" Style="BORDER-LEFT:#000000 1px solid;BORDER-RIGHT:#000000 1px solid; PADDING-RIGHT:5px; BORDER-TOP:#000000 1px solid; PADDING-LEFT:5px; PADDING-BOTTOM:5px; PADDING-TOP:0px; BORDER-BOTTOM:#000000 1px solid">
		<MSFT:PageView>
			<MVSN:Managed id="pageManaged" runat="server" />
		</MSFT:PageView>
		<MSFT:PageView>
			<MVSN:Standalone id="pageStandalone" runat="server" />
		</MSFT:PageView>
	</MSFT:MultiPage>
</DIV>
