<%@ control language="c#" autoeventwireup="false" inherits="SMS.AdvertisementsInfo, AdminStudio.WebApplication" targetschema="http://schemas.microsoft.com/intellisense/ie5" %>
<asp:datagrid id=DataGridCtrl runat="server" Width="80%" DataMember="AMS_SMSAdvertisements" DataSource="<%# sqlAdvtsDataSet %>" 
			DataKeyField="AdvtInternalID" CellPadding="2" AllowPaging="True" PageSize="6" AutoGenerateColumns="False"
			OnPageIndexChanged="PageIndex_Changed" BorderStyle="Solid" BorderColor="Gray"
			 OnItemDataBound="DataGridCtrl_ItemBound">
	<AlternatingItemStyle ForeColor="Black" BackColor="Gainsboro"></AlternatingItemStyle>
	<ItemStyle ForeColor="Black" BackColor="White"></ItemStyle>
	<Columns>
		<asp:ButtonColumn DataTextField="AdvertisementName" HeaderText="Name">
			<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
			<ItemStyle HorizontalAlign="Left"></ItemStyle>
		</asp:ButtonColumn>
		<asp:TemplateColumn>
			<HeaderTemplate>
				Program
			</HeaderTemplate>
			<ItemTemplate>
				<asp:Label ID="lblProgramName" Runat="server"></asp:Label>
			</ItemTemplate>
			<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
		</asp:TemplateColumn>
		<asp:TemplateColumn>
			<HeaderTemplate>
				Collection
			</HeaderTemplate>
			<ItemTemplate>
				<asp:Label ID="lblCollectionID" Runat="server"></asp:Label>
			</ItemTemplate>
			<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
		</asp:TemplateColumn>
		<asp:TemplateColumn>
			<HeaderTemplate>
				Available After
			</HeaderTemplate>
			<ItemTemplate>
				<asp:Label ID="lblAdvtPresentTimeID" Runat="server"></asp:Label>
			</ItemTemplate>
			<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
		</asp:TemplateColumn>
		<asp:TemplateColumn>
			<HeaderTemplate>
				Expires After
			</HeaderTemplate>
			<ItemTemplate>
				<asp:Label ID="lblAdvtExpireID" Runat="server"></asp:Label>
			</ItemTemplate>
			<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
		</asp:TemplateColumn>
		<asp:TemplateColumn>
			<HeaderTemplate>
				Advertisement ID
			</HeaderTemplate>
			<ItemTemplate>
				<asp:Label ID="lblSMSAdvtID" Runat="server"></asp:Label>
			</ItemTemplate>
			<HeaderStyle Font-Bold="True" Wrap="False" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
		</asp:TemplateColumn>
		<asp:TemplateColumn SortExpression="Status" HeaderText="Status">
			<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
			<ItemTemplate>
				<asp:Label ID="lblStatus" Runat="server"></asp:Label>
			</ItemTemplate>
		</asp:TemplateColumn>
	</Columns>
	<PagerStyle Mode="NumericPages"></PagerStyle>
</asp:datagrid>
<br>
<asp:Label ID="Adversitement_lblFeatureDisableMess" Visible="False" Runat="server" ForeColor="Red"
	Font-Bold="True" Width="584px"> This feature is included with AdminStudio Professional Edition</asp:Label>
<div style="POSITION:relative; TOP:10%">
	<asp:label id="lblCreateNew" runat="server" Font-Bold="True">Create New Advertisement:</asp:label>
	<br>
	<br>
	<div style="MARGIN-LEFT: 10px">
		<asp:label id="lblAdvtName" runat="server">Name:</asp:label>
		<asp:textbox id="txtAdvtName" runat="server"></asp:textbox>
		<br>
		<br>
		<asp:button id="btnCreate" CssClass="SMSButton" runat="server" Text="Create"></asp:button>
		<br>
		<br>
		<asp:Label ID="lblErrorText" Runat="server" ForeColor="#ff3300"></asp:Label>
	</div>
</div>
