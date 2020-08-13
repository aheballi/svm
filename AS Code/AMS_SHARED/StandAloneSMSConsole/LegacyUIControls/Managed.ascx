<%@ control language="c#" inherits="UIFramework.Managed, AdminStudio.WebApplication" targetschema="http://schemas.microsoft.com/intellisense/ie5" %>
<DIV style="WIDTH: 393px; POSITION: relative; HEIGHT: 416px" ms_positioning="GridLayout"><asp:panel id="pnlLogin" style="Z-INDEX: 101; LEFT: 0px; POSITION: absolute; TOP: 0px" Height="384px"
		Width="392px" runat="server">
		<DIV style="WIDTH: 392px; POSITION: relative; HEIGHT: 360px" ms_positioning="GridLayout">
			<asp:Label id="Label1" style="Z-INDEX: 101; LEFT: 16px; POSITION: absolute; TOP: 8px" runat="server"
				Width="368px" Height="24px">Please login to AdminStudio Enterprise Server.</asp:Label>
			<asp:DropDownList id="listAuthentication" style="Z-INDEX: 102; LEFT: 16px; POSITION: absolute; TOP: 96px"
				runat="server" Width="304px">
				<asp:ListItem Value="AdminStudio Enterprise Server User" Selected="True">AdminStudio Enterprise Server User</asp:ListItem>
			</asp:DropDownList>
			<asp:Label id="Label2" style="Z-INDEX: 103; LEFT: 16px; POSITION: absolute; TOP: 72px" runat="server"
				Width="176px" Height="16px">Authentication:</asp:Label>
			<asp:Label id="Label3" style="Z-INDEX: 104; LEFT: 16px; POSITION: absolute; TOP: 128px" runat="server"
				Width="176px" Height="16px">User Name:</asp:Label>
			<asp:Label id="Label4" style="Z-INDEX: 105; LEFT: 16px; POSITION: absolute; TOP: 184px" runat="server"
				Width="176px" Height="16px">Password:</asp:Label>
			<asp:Label id="lblMessage" style="Z-INDEX: 106; LEFT: 16px; POSITION: absolute; TOP: 296px"
				runat="server" Width="368px" Height="56px" ForeColor="Red">lblMessage</asp:Label>
			<asp:TextBox id="editUserName" style="Z-INDEX: 107; LEFT: 16px; POSITION: absolute; TOP: 152px"
				runat="server" Width="304px"></asp:TextBox>
			<asp:TextBox id="editPassword" style="Z-INDEX: 108; LEFT: 16px; POSITION: absolute; TOP: 208px"
				runat="server" Width="304px" TextMode="Password"></asp:TextBox>
			<asp:Button id="buttonLogin" style="Z-INDEX: 109; LEFT: 16px; POSITION: absolute; TOP: 248px"
				runat="server" Width="72px" Height="24px" Text="Login" CausesValidation="False"></asp:Button>
			<asp:HyperLink id="linkAsesUrl" style="Z-INDEX: 110; LEFT: 16px; POSITION: absolute; TOP: 32px"
				runat="server" Width="336px" Height="16px" NavigateUrl="SelectAsesUrl.aspx">HyperLink</asp:HyperLink></DIV>
	</asp:panel>
	<asp:Panel id="pnlSelectManaged" style="Z-INDEX: 102; LEFT: 0px; POSITION: absolute; TOP: 0px"
		Height="384px" Width="392px" runat="server">
		<DIV style="WIDTH: 392px; POSITION: relative; HEIGHT: 360px" ms_positioning="GridLayout">
			<asp:Label id="Label5" style="Z-INDEX: 101; LEFT: 16px; POSITION: absolute; TOP: 8px" runat="server"
				Width="368px" Height="24px">Select the appropriate managed catalog.</asp:Label>
			<asp:ListBox id="listManagedCatalogs" style="Z-INDEX: 102; LEFT: 16px; POSITION: absolute; TOP: 72px"
				runat="server" Width="304px" Height="160px"></asp:ListBox>
			<asp:Button id="buttonSaveManaged" style="Z-INDEX: 103; LEFT: 16px; POSITION: absolute; TOP: 248px"
				runat="server" Width="72px" Height="24px" Text="Save" CausesValidation="False"></asp:Button></DIV>
		<asp:Label id="labelSelectedMessage" style="Z-INDEX: 106; LEFT: 16px; POSITION: absolute; TOP: 312px"
			runat="server" Width="368px" Height="40px" ForeColor="Red">lblMessage</asp:Label>
		<asp:CheckBox id="chkSaveLocal" style="Z-INDEX: 104; LEFT: 16px; POSITION: absolute; TOP: 280px"
			runat="server" Width="352px" Height="16px" Text="Save connection parameters in local machine"
			Visible="False"></asp:CheckBox>
	</asp:Panel></DIV>
