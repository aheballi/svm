<%@ control language="c#" autoeventwireup="false" inherits="ASShare.Activate, AdminStudio.WebApplication" targetschema="http://schemas.microsoft.com/intellisense/ie5" %>
<P>
	<TABLE id="Table1" style="Z-INDEX: 101; LEFT: 8px; WIDTH: 434px; POSITION: absolute; TOP: 8px; HEIGHT: 65px"
		cellSpacing="1" cellPadding="1" width="434" align="center" border="0">
		<TR>
			<TD vAlign="top" style="HEIGHT: 53px"><asp:label id="lblMessage" runat="server"></asp:label></TD>
		</TR>
		<TR>
			<TD style="HEIGHT: 8px" vAlign="top">
				<P><asp:label id="lblEvalMessage" runat="server"></asp:label></P>
				<P><asp:button id="btnActivate" runat="server" Text="Evaluate" Width="73px"></asp:button><asp:checkbox id="cbEvaluate" runat="server" Text="Evaluate" Visible="False" Checked="True"></asp:checkbox></P>
			</TD>
		</TR>
		<TR>
			<TD align="left" style="HEIGHT: 3px"><asp:label id="lblFeedback" runat="server" Width="412px" ForeColor="Red"></asp:label></TD>
		</TR>
		<TR>
			<TD><asp:textbox id="txtS3" runat="server" Visible="False" Columns="10" MaxLength="10"></asp:textbox><asp:textbox id="txtS2" runat="server" Visible="False" Columns="3" MaxLength="3"></asp:textbox><asp:textbox id="txtS1" runat="server" Visible="False" Columns="7" MaxLength="7"></asp:textbox></TD>
		</TR>
	</TABLE>
</P>
