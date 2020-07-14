<%@ control language="c#" autoeventwireup="false" inherits="SMS.ProgramsInfo, AdminStudio.WebApplication" targetschema="http://schemas.microsoft.com/intellisense/ie5" %>
<asp:datagrid id=DataGridCtrl runat="server" 
		AutoGenerateColumns="False" DataMember="AMS_SMSPrograms" DataSource="<%# sqlProgramsDataSet %>" 
		DataKeyField="ProgramInternalID" CellPadding="2" AllowPaging="True" PageSize="6" Width="80%"
		OnPageIndexChanged="PageIndex_Changed" BorderStyle="Solid" BorderColor="Gray">
	<AlternatingItemStyle ForeColor="Black" BackColor="Gainsboro"></AlternatingItemStyle>
	<ItemStyle ForeColor="Black" BackColor="White"></ItemStyle>
	<Columns>
		<asp:ButtonColumn DataTextField="ProgramName" HeaderText="Name">
			<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
			<ItemStyle HorizontalAlign="Left"></ItemStyle>
		</asp:ButtonColumn>
		<asp:TemplateColumn SortExpression="Duration" HeaderText="Run Time (hh:mm)">
			<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
			<ItemTemplate>
				<%# Convert.ToInt32(DataBinder.Eval(Container.DataItem, "Duration"))/60 %>
				:<%# Convert.ToInt32(DataBinder.Eval(Container.DataItem, "Duration"))% 60 %>
			</ItemTemplate>
		</asp:TemplateColumn>
		<asp:BoundColumn DataField="DiskSpaceReq" SortExpression="DiskSpaceReq" HeaderText="Disk Space">
			<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
		</asp:BoundColumn>
		<asp:BoundColumn DataField="Comment" SortExpression="Comment" HeaderText="Comment">
			<HeaderStyle Font-Bold="True" ForeColor="White" BackColor="#437CD3"></HeaderStyle>
		</asp:BoundColumn>
	</Columns>
	<PagerStyle Mode="NumericPages"></PagerStyle>
</asp:datagrid>
<div style="POSITION:relative; TOP:10%">
	<asp:label id="lblCreateNew" runat="server" Font-Bold="True">Create New Program:</asp:label>
	<br>
	<br>
	<div style="MARGIN-LEFT:10px">
		<asp:label id="lblProgramName" runat="server" Height="16px" Width="40px">Name:
		</asp:label>
		<asp:textbox id="txtProgramName" runat="server" Height="22px" Width="88px"></asp:textbox>
		<br>
		<br>
		<asp:button id="btnCreate" CssClass="SMSButton" runat="server" Text="Create"></asp:button>
		<br>
		<br>
		<asp:Label ID="lblErrorText" Runat="server" ForeColor="#ff3300"></asp:Label>
	</div>
</div>
