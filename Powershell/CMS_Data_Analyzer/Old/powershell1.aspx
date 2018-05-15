<%@ Page Language="C#" AutoEventWireup="true" CodeFile="powershell1.aspx.cs" Inherits="CMSDataAnalyser1.powershell1" ValidateRequest="false" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
<title>CMS Data Analyser</title>

    <style type="text/css">
      p { 
        font-size:35px; 
        color:#768294; 
        font-weight:bold; 
        font-style:italic;
      }
      .title {
        color: #768294;
        font-size:40px;
        font-weight:400;
        font-style:normal;
        font-family:Aharoni;
                       
      }
      
      @keyframes slidein {
        from {
        margin-left: 20%;
        width: 100%;
       
        }
       to {
        margin-left: 0%;
        width: 100%;

       }
      }

        .label {
            color:crimson;
            font-size: 18px;
            font-weight: 400;
            font-style: normal;
            font-family: Aharoni;
        }

        .msgbox {
            color: grey;
            font-size: 16px;
            font-family: Aharoni;
            font-style:normal;
            animation: slidein;
            animation-duration: 3s;
        }

        .auto-style1 {
            height: 30px;
        }
        .button {
        background-color: darkgray;
        -moz-border-radius: 5px;
        -webkit-border-radius: 5px;
        border-radius:10px;
        color: #fff;
        font-family: 'Oswald';
        font-size: 20px;
        text-decoration: none;
        cursor: pointer;
        border:none;
        padding:2px;
        }
        .button:hover{
            border:none;
            background-color:darkblue;
            box-shadow: 0px 0px 2px #777;
        }


        </style>

   
</head>
<body>
<form id="form1" runat="server">
    <div>
             <table>      
            <tr><td>&nbsp;</td><td><span class="title">CMS Data Analyser</span></td></tr>
        
            <tr><td>&nbsp;</td><td>&nbsp;</td></tr>
            <tr><td>&nbsp;</td><td><span class="label">Powershell Commands</span></td></tr>
            <tr><td>
                <br />
                </td><td>
                <asp:TextBox ID="Input" runat="server" TextMode="MultiLine" Font-Bold="true" BackColor="Beige" ForeColor="black" Font-Size="18px" Width="600px" Height="80px" ></asp:TextBox>
            </td></tr>
            <tr><td class="auto-style1">
                </td><td class="auto-style1">
                <asp:Button ID="ExecuteCode" runat="server" CssClass="button" Text="Execute Powershell Command" Height="50px" Width="600px" onclick="ExecuteCode_Click" />
                
                </td></tr>
            <tr><td>&nbsp;</td><td>

                <asp:Button ID="RestartEWS" runat="server" CssClass="button" Text="Restart-EWS" Width="200px" OnClick="RestartEWS_Click" /> 
                <asp:Button ID="GetEWS" runat="server" CssClass="button" Text="Get-EWS-Status" width="200px" OnClick="GetEWS_Click" />
                <asp:Button ID="restartIIS" runat="server" CssClass="button" Text="Restart-IIS" Width="200px" OnClick="restartIIS_Click" />
                                <br />
                <asp:Button ID="getservice" runat="server" CssClass="button" Text="Get-Service" Width="200px" OnClick="getservice_Click" />
                <asp:Button ID="getfeatures" runat="server" CssClass="button" Text="Get-Features" Width="200px"  OnClick="getfeatures_Click" style="height: 26px" />
                <asp:Button ID="GetProcess" runat="server" CssClass="button" Text="Get-Process" Width="200px" OnClick="GetProcess_Click" />
                                <br />
                <asp:Button ID="cmsversion" runat="server" Text="CMS-Settings" CssClass="button" Width="200px" OnClick="cmsversion_Click" />
             
                <asp:Button ID="database" runat="server" Text="Database-Settings" CssClass="button" Width="200px" OnClick="database_Click" />
             
                <asp:Button ID="ServerInfoXML" runat="server" Text="ServerInfo-XML" Width="200px" CssClass="button" OnClick="ServerInfoXML_Click" />
             
                                <br />
             
                <asp:Button ID="sites" runat="server" Text="List-Sites" CssClass="button" Width="200px" OnClick="sites_Click" />
             
                <asp:Button ID="hostfile" runat="server" Text="Read-HostFile" Width="200px" CssClass="button" OnClick="hostfile_Click" />
             
                <asp:Button ID="Sysinfo" runat="server" Text="System-Info" Width="200px" CssClass="button" OnClick="Sysinfo_Click" />
             
                <br />
             
                <asp:Button ID="testcallbackurl" runat="server" Text="Test-CallBackURL" Width="200px" CssClass="button" OnClick="testcallbackurl_Click" />
             
                <asp:Button ID="TempDir" runat="server" Text="Temp-Directory" Width="200px" CssClass="button" OnClick="TempDir_Click" />
             
                <br />
             
                <br />
                <asp:Label ID="source" CssClass="label" runat="server" Text="Source Machine "></asp:Label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <asp:TextBox ID="sourcetxt1" runat="server" Width="410px" Font-Bold="true"></asp:TextBox>
             
                <br />
             
                <br />
             
                <asp:Label ID="destination" CssClass="label" runat="server" Text="Destination Machine "></asp:Label>
                <asp:TextBox ID="desttxt1" runat="server" Width="410px" Font-Bold="true"></asp:TextBox>
             
                <br />
                <br />
             
                <asp:Button ID="ValidateSite" runat="server" Text="Validate-Site" Width="600px" CssClass="button" OnClick="ValidateSite_Click" />
             
                <br />
             
                <br />
                <br />
                <asp:Label ID="MachineName" CssClass="label" runat="server" Text="Machine Name "></asp:Label>
                <asp:TextBox ID="computer" runat="server" Width="293px" Font-Bold="true"></asp:TextBox>
                                <br />
                <br />
                <asp:Label ID="PortNum" runat="server" CssClass="label" Text="Port Number "></asp:Label>
                <asp:TextBox ID="port" runat="server" Width="100px" style="margin-left: 18px" Font-Bold="true"></asp:TextBox>
                <asp:Button ID="PortTest" runat="server" Text="Port-Test" CssClass="button" Width="196px" OnClick="PortTest_Click" />
                                                                                          
                <br />
                                                              
                <br />
                                                              
                <asp:Button ID="writetext" runat="server" Text="Write-To-Text" Width="200px" CssClass="button" OnClick="writetext_Click" />
                          
                <asp:Button ID="clearlog" runat="server" CssClass="button" Text="Clear-Log" Width="200px" onClick="clearlog_Click"/>
                

                <asp:Button ID="openlog" runat="server" Text="Open-Log" CssClass="button" Width="200px" onClick="openlog_Click"/>
             
                <br />
             
                <br />
             
                <asp:Label ID="statusmsg" CssClass="label" runat="server" Text="Status Message "></asp:Label><asp:Label ID="MessageBox" runat="server" CssClass="msgbox"></asp:Label>

                </td></tr>
           
                <tr><td>&nbsp;</td><td><span class="label">Result</span></td></tr>
            
                <tr><td>
                    &nbsp;</td><td>
                    <asp:TextBox ID="ResultBox" TextMode="MultiLine" Width="1400" Height="390" Font-Size="Large" ForeColor="#4DC34B" BackColor="Black" runat="server"></asp:TextBox>
                </td></tr>
        </table>
    </div>
</form>
</body>
</html>
