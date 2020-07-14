<%@ page language="c#" autoeventwireup="false" inherits="ASDistribution.AMSError, AdminStudio.WebApplication" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<TITLE>Application Management System</TITLE>
		<link rel="STYLESHEET" type="text/css" href="<%=styleSheetURL %>">
		<meta content="Microsoft Visual Studio .NET 7.1" name="GENERATOR">
		<meta content="C#" name="CODE_LANGUAGE">
		<meta content="JavaScript" name="vs_defaultClientScript">
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
		<script language="javascript">
		    function showHideError_OnClick()
		    {
			    var showHideDetailsButton;
			    var detailsDiv;
			    var showError = "View";
			    var hideErrorValue = "Hide";
    			
			    showHideErrorButton = document.getElementById("hypShowErrors");
			    detailsDiv = document.getElementById("details");
    			
			    if(detailsDiv.style.visibility == "hidden")
			    {
				    detailsDiv.style.visibility = "visible";
				    showHideErrorButton.innerText = hideErrorValue;
			    }
			    else
			    {
				    detailsDiv.style.visibility = "hidden";
				    showHideErrorButton.innerText = showError;
			    }
		    }
		    
		    function LoadInTopLevel(){
				if(parent.frames.length>0){
					parent.location.href= document.location.toString() + "&frame=true";
				}
		    }
		    
		    function GoBack(){
				var source= window.location.search.split("&") ;
				var oFrame = source[1];
				if(oFrame=="frame=true"){
					history.go(-2);
				}else{
					history.go(-1);
				}
		    }
		</script>
	</HEAD>
	<body onload="LoadInTopLevel()">
		<form id="AMSError_frm" method="post" runat="server">
			<div class="pageContent">
				<div>
					<TABLE id="Table1" cellSpacing="3" cellPadding="0" width="40%" border="0">
						<TR>
							<TD><IMG src="/ASDistribution/images/MessageError32.gif" align="absMiddle"></TD>
							<TD vAlign="bottom" align="left"><font size="2"><b>&nbsp; The page experienced a problem</b></font><BR>
							</TD>
						</TR>
						<TR>
							<TD></TD>
							<TD><br>
								The page experienced a problem that it could not recover from. Please report 
								this error to support personnel so they can diagnose the problem.<br>
							</TD>
						</TR>
						<TR>
							<TD></TD>
							<TD>
								<UL>
									<LI>
										<A href="javascript:GoBack();"><b>Go back</b></A>
									to the previous page
									<LI>
										<A href="/ASDistribution/Help/HelpFrames.aspx" target="_blank"><b>Get help</b></A> on using 
										SMS Web Console
									</LI>
								</UL>
								<br>
							</TD>
						</TR>
					</TABLE>
				</div>
				<DIV>&nbsp;</DIV>
				<DIV><asp:label id="lblErrorText" runat="server" CssClass="label"></asp:label></DIV>
				<br>
				<asp:hyperlink id="hypShowErrors" runat="server" ForeColor="Black" NavigateUrl="javascript:showHideError_OnClick()"
					Font-Bold="True">View</asp:hyperlink>&nbsp;the details of this error&nbsp;
			</div>
			<div id="details" style="VISIBILITY: hidden" class="pageContent"><br>
				Exception Trace
				<pre class="frameControl">
                    <%=CustomError != null ? CustomError.ToString() : "Error information not found."%>
			        </pre>
			</div>
			<DIV></DIV>
		</form>
	</body>
</HTML>
