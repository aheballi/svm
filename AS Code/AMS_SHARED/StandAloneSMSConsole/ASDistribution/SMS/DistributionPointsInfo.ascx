<%@ control language="c#" autoeventwireup="false" inherits="SMS.DistributionPointsInfo, AdminStudio.WebApplication" targetschema="http://schemas.microsoft.com/intellisense/ie5" %>
<script language="javascript">
<!--

	function OnSelectAll()
	{
		var chkListClientID = window.document.getElementById('<%= chkListDistPoints.ClientID%>').id;
		if (chkListClientID)
		{
			
			var nItems = window.document.getElementById('<%= chkListDistPoints.ClientID%>').rows.length;
			var nItemID;
			for(i = 0; i<nItems; i++)
			{
				nItemID = chkListClientID + '_' + i;
				window.document.getElementById(nItemID).checked = true;
			}
		}
	}
	
	function OnClearAll()
	{
		var chkListClientID = window.document.getElementById('<%= chkListDistPoints.ClientID%>').id;
		if (chkListClientID)
		{
			
			var nItems = window.document.getElementById('<%= chkListDistPoints.ClientID%>').rows.length;
			var nItemID;
			for(i = 0; i<nItems; i++)
			{
				nItemID = chkListClientID + '_' + i;
				window.document.getElementById(nItemID).checked = false;
			}
		}
	}

//-->
</script>
<asp:datagrid id=DataGridCtrl runat="server" Width="80%" PageSize="6" AllowPaging="True" CellPadding="2" 
			DataKeyField="DistPointInternalID" DataSource="<%# sqlDistPointsDataSet %>" DataMember="AMS_SMSDistributionPoints" AutoGenerateColumns="False"
			OnPageIndexChanged="PageIndex_Changed" BorderStyle="Solid" BorderColor="Gray">
	<AlternatingItemStyle ForeColor="Black" BackColor="Gainsboro"></AlternatingItemStyle>
	<ItemStyle ForeColor="Black" BackColor="White"></ItemStyle>
	<Columns>
		<asp:TemplateColumn HeaderText="Name">
			<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
			<ItemTemplate>
				<asp:LinkButton runat="server" Text='<%# GetDistributionProperties(DataBinder.Eval(Container.DataItem, "ServerNALPath"), "Name") %>' CommandName="" CausesValidation="false">
				</asp:LinkButton>
			</ItemTemplate>
		</asp:TemplateColumn>
		<asp:TemplateColumn HeaderText="Site">
			<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
			<ItemTemplate>
				<asp:Label Runat=server Text='<%# GetDistributionProperties(DataBinder.Eval(Container.DataItem, "ServerNALPath"), "Site") %>'>
				</asp:Label>
			</ItemTemplate>
		</asp:TemplateColumn>
		<asp:TemplateColumn HeaderText="Type">
			<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
			<ItemTemplate>
				<asp:Label Runat=server Text='<%# GetDistributionProperties(DataBinder.Eval(Container.DataItem, "ServerNALPath"), "Type") %>'>
				</asp:Label>
			</ItemTemplate>
		</asp:TemplateColumn>
	</Columns>
	<PagerStyle Mode="NumericPages"></PagerStyle>
</asp:datagrid><br>
<br>
<asp:CheckBox Runat="server" ID="chkRefreshPackageSource" Text="Update distribution points with the latest version of the package"
	AutoPostBack="True"></asp:CheckBox>
<br>
<br>
<div style="WIDTH: 60%; POSITION: relative; TOP: 10%">
	<asp:label id="lblCreateNew" runat="server" Font-Bold="True">Select New Distribution Point:</asp:label><br>
	<br>
	<DIV style="BORDER-RIGHT: gray 1px solid; BORDER-TOP: gray 1px solid; OVERFLOW-Y: scroll; MARGIN-LEFT: 10px; BORDER-LEFT: gray 1px solid; BORDER-BOTTOM: gray 1px solid; POSITION: relative; HEIGHT: 15%">
		<asp:CheckBoxList id="chkListDistPoints" runat="server"></asp:CheckBoxList>
	</DIV>
	<br>
	<div style="MARGIN-LEFT: 10px">
		<input type="button" id="btnSelectAll" class="SMSButton" onclick="OnSelectAll();" runat="server"
			value="Select All"> <input type="button" id="btnClearAll" class="SMSButton" onclick="OnClearAll();" runat="server"
			value="Clear All">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
		&nbsp;
		<asp:button id="btnCreate" Width="65px" runat="server" Text="OK" CssClass="SMSButton"></asp:button>
	</div>
	<br>
	<asp:Label ID="lblErrorText" Runat="server" ForeColor="#ff3300"></asp:Label>
</div>
