using Microsoft.Web.Administration;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
//using System.Windows.Forms;
using System.Xml;
using System.Net.Sockets;
using System.Management;
using Microsoft.Win32;
//using System.Xml;
using System.Runtime.Remoting;
using System.Net;
using System.IO.Compression;

namespace CMSDataAnalyser1
{
    public partial class powershell1 : System.Web.UI.Page
    {

        public void Page_Load(object sender, EventArgs e)
        {
            MessageBox.Text = (String.Empty);

        }
        public void ExecuteCode_Click(object sender, EventArgs e)
        {
            //clean the result text box
            ResultBox.Text = string.Empty;

            //initialize powershell engine
            var shell = PowerShell.Create();

            //Add script to the powershell object
            shell.Commands.AddScript(Input.Text);
            shell.AddCommand("out-string");

            //Execute the script
            var results = shell.Invoke();

            //Display results with base object converted to string

            if (results.Count > 0)
            {
                // We use a string builder ton create our result text
                var builder = new StringBuilder();

                foreach (var psObject in results)
                {
                    // Convert the Base Object to a string and append it to the string builder.
                    // Add \r\n for line breaks
                    builder.Append(psObject.BaseObject.ToString() + "\r\n");
                }

                // Encode the string in HTML (prevent security issue with 'dangerous' caracters like < >
                ResultBox.Text = Server.HtmlEncode(builder.ToString());
            }
            Input.Text = (String.Empty);
        }
        public void RestartEWS_Click(object sender, EventArgs e)
        {
            //clean the result text box
            ResultBox.Text = string.Empty;

            //initialize powershell engine
            var shell = PowerShell.Create();

            //Add script to the powershell object
            shell.Commands.AddScript("Restart-Service EktronWindowsServices40 | Out-String");

            //Execute the script
            var results = shell.Invoke();

            //Display results

            if (results.Count > 0)
            {
                ResultBox.Text = ("Finished Executing...");
            }
        }
        public void GetEWS_Click(object sender, EventArgs e)
        {
            //clean the result text box
            ResultBox.Text = string.Empty;

            //initialize powershell engine
            var shell = PowerShell.Create();

            //Add script to the powershell object
            shell.Commands.AddScript("Get-Service Ektron* | Out-String");

            //Execute the script
            var results = shell.Invoke();

            //Display results

            if (results.Count > 0)
            {
                ResultBox.Text = results[0].BaseObject.ToString();
            }
        }
        public void GetProcess_Click(object sender, EventArgs e)
        {
            //clean the result text box
            ResultBox.Text = string.Empty;

            //initialize powershell engine
            var shell = PowerShell.Create();

            //Add script to the powershell object
            shell.Commands.AddScript("Get-Process | Out-String");

            //Execute the script
            var results = shell.Invoke();

            //Display results

            if (results.Count > 0)
            {
                // We use a string builder ton create our result text
                var builder = new StringBuilder();

                foreach (var psObject in results)
                {
                    // Convert the Base Object to a string and append it to the string builder.
                    // Add \r\n for line breaks
                    builder.Append(psObject.BaseObject.ToString() + "\r\n");
                }

                // Encode the string in HTML (prevent security issue with 'dangerous' caracters like < >
                ResultBox.Text = Server.HtmlEncode(builder.ToString());
            }
        }
        public void writetext_Click(object sender, EventArgs e)
        {

            //create a folder and text output of the results window
            string file_name = @"C:\Result\Output.txt";

            string folder = @"C:\Result";

            if (folder != null)
            {
                Directory.CreateDirectory("C:\\Result");

            }
            else

                MessageBox.Text = ("Folder already exists!");
            MessageBox.Text = (string.Empty);

            if (file_name != null)
            {

                System.IO.StreamWriter objWriter;

                objWriter = new System.IO.StreamWriter(file_name, true);

                objWriter.Write(ResultBox.Text);

                objWriter.Close();
                MessageBox.Text = ("Written to Text File");

            }
            else

                MessageBox.Text = ("File already exists!");

        }
        public void clearlog_Click(object sender, EventArgs e)
        {
            try
            {
                //delete log file
                File.Delete(@"C:\Result\Output.txt");
                MessageBox.Text = ("File Deleted");
                ResultBox.Text = (String.Empty);
            }
            catch (Exception ex)
            {

                ResultBox.Text = ("Error: " + ex.Message);
                MessageBox.Text = ("Nothing to clear");
            }
        }
        public void getservice_Click(object sender, EventArgs e)
        {
            //clean the result text box
            ResultBox.Text = string.Empty;

            //initialize powershell engine
            var shell = PowerShell.Create();

            //Add script to the powershell object
            shell.Commands.AddScript("Get-Service | Out-String");

            //Execute the script
            var results = shell.Invoke();

            //Display results

            if (results.Count > 0)
            {
                // We use a string builder ton create our result text
                var builder = new StringBuilder();

                foreach (var psObject in results)
                {
                    // Convert the Base Object to a string and append it to the string builder.
                    // Add \r\n for line breaks
                    builder.Append(psObject.BaseObject.ToString() + "\r\n");
                }

                // Encode the string in HTML (prevent security issue with 'dangerous' caracters like < >
                ResultBox.Text = Server.HtmlEncode(builder.ToString());
            }
        }
        public void getfeatures_Click(object sender, EventArgs e)
        {
            //clean the result text box
            ResultBox.Text = string.Empty;

            //initialize powershell engine
            var shell = PowerShell.Create();

            //Add script to the powershell object
            shell.Commands.AddScript("Get-WindowsFeature -Name *web* | Out-String");

            //Execute the script
            var results = shell.Invoke();

            //Display results

            if (results.Count > 0)
            {
                // We use a string builder ton create our result text
                var builder = new StringBuilder();

                foreach (var psObject in results)
                {
                    // Convert the Base Object to a string and append it to the string builder.
                    // Add \r\n for line breaks
                    builder.Append(psObject.BaseObject.ToString() + "\r\n");
                }

                // Encode the string in HTML (prevent security issue with 'dangerous' caracters like < >
                ResultBox.Text = Server.HtmlEncode(builder.ToString());
            }
        }
        public void restartIIS_Click(object sender, EventArgs e)
        {
            //clean the result text box
            ResultBox.Text = string.Empty;

            //initialize powershell engine
            var shell = PowerShell.Create();

            //Add script to the powershell object
            shell.Commands.AddScript("Restart-Service W3SVC,WAS -force | Out-String");

            //Execute the script
            var results = shell.Invoke();

            ResultBox.Text = ("Finished Executing...");

        }
        public void PortTest_Click(object sender, EventArgs e)
        {

            if (Environment.OSVersion.Version.Minor == 1)
            {
                try
                {
                    TcpClient tcp = new TcpClient();
                    tcp.Connect(computer.Text, Convert.ToInt32(port.Text));
                    ResultBox.Text = ("\r\n" + "Port: " + computer.Text + ":" + port.Text + " is open");
                }
                catch (Exception ex)
                {
                    ResultBox.Text = (Environment.NewLine + "Port: " + computer.Text + ":" + port.Text + " is closed" + Environment.NewLine + ex.Message);
                }
                port.Text = (String.Empty);
            }

            else if (Environment.OSVersion.Version.Minor >= 3)
            {
                //clean the result text box
                ResultBox.Text = string.Empty;

                //initialize powershell engine
                var shell = PowerShell.Create();

                shell.AddCommand("test-netconnection");
                shell.AddParameter("computername", computer.Text);
                shell.AddParameter("port", port.Text);
                shell.AddParameter("InformationLevel", "detailed");
                shell.AddCommand("out-string");

                //Execute the script
                var results = shell.Invoke();

                //Display results

                if (results.Count > 0)
                {
                    // We use a string builder ton create our result text
                    var builder = new StringBuilder();

                    foreach (var psObject in results)
                    {
                        // Convert the Base Object to a string and append it to the string builder.
                        // Add \r\n for line breaks
                        builder.Append(psObject.BaseObject.ToString() + "\r\n");
                    }

                    // Encode the string in HTML (prevent security issue with 'dangerous' characters like < >
                    ResultBox.Text = Server.HtmlEncode(builder.ToString());

                }
            }
        }
        public void openlog_Click(object sender, EventArgs e)
        {

            string file_name = @"C:\Result\Output.txt";

            try
            {
                if (file_name != null)
                {

                    System.IO.StreamReader objReader;

                    objReader = new System.IO.StreamReader(file_name);

                    ResultBox.Text = objReader.ReadToEnd();

                    objReader.Close();

                    MessageBox.Text = ("File Opened");
                }
            }
            catch (Exception ex)
            {
                ResultBox.Text = ("Error: " + ex.Message);
                MessageBox.Text = ("File Not Opened");
            }
        }
        public void cmsversion_Click(object sender, EventArgs e)
        {
            string conn =
            ConfigurationManager.ConnectionStrings["Ektron.DbConnection"].ConnectionString;

            string version =
            ConfigurationManager.AppSettings["ek_InstallBuild"];

            string sitepath =
                ConfigurationManager.AppSettings["ek_SitePath"];

            string wspath =
                ConfigurationManager.AppSettings["WSPath"];

            string webencoded =
                ConfigurationManager.AppSettings["encodedValue"];

            bool debugflag =
                HttpContext.Current.IsDebuggingEnabled;

            string defaultlang =
                ConfigurationManager.AppSettings["ek_DefaultContentLanguage"];

            string editor =
                ConfigurationManager.AppSettings["ek_EditControlWin"];

            ExeConfigurationFileMap configMap = new ExeConfigurationFileMap();
            configMap.ExeConfigFilename = @"C:\Program Files (x86)\Ektron\EktronWindowsService40\Ektron.ASM.EktronServices40.exe.config";
            System.Configuration.Configuration config = ConfigurationManager.OpenMappedExeConfiguration(configMap, ConfigurationUserLevel.None);


            string ewsversion =
               config.AppSettings.Settings["InstallVersion"].Value;

            string loadbalanced =
               config.AppSettings.Settings["LoadBalanced"].Value;

            string loadbalancedservercount =
                config.AppSettings.Settings["LoadBalServerCount"].Value;

            //string ewsencoded =
            //    config.AppSettings.Settings["publickCertKeys"].Value;

            ResultBox.Text = ("\r\n" + "Web.Config Settings: " + Environment.NewLine + Environment.NewLine +
                "CMS VERSION: " + version + Environment.NewLine +
                "SITE PATH: " + sitepath + Environment.NewLine +
                "WSPATH: " + wspath + Environment.NewLine +
                "CONNECTION STRINGS: " + conn + Environment.NewLine +
                "WEB ENCODED: " + webencoded + Environment.NewLine +
                "DEFAULT LANG: " + defaultlang + Environment.NewLine +
                "CONTENT EDITOR: " + editor + Environment.NewLine +
                "DEBUG FLAG: " + debugflag + Environment.NewLine +
                "CUSTOM ERRORS: " + RemotingConfiguration.CustomErrorsMode + Environment.NewLine +
                Environment.NewLine +
                "Ektron EWS Configuration: " + Environment.NewLine + Environment.NewLine +
                "EWS VERSION: " + ewsversion + Environment.NewLine +
                "LOAD BALANCED: " + loadbalanced + Environment.NewLine +
                "SERVER COUNT: " + loadbalancedservercount + Environment.NewLine
                //"EWS Encoded: " + ewsencoded
                );
        }
        public void database_Click(object sender, EventArgs e)
        {
            string conn =
            ConfigurationManager.ConnectionStrings["Ektron.DbConnection"].ConnectionString;

            SqlConnection sqlconn = new SqlConnection(conn);
            {
                sqlconn.Open();

                SqlCommand cmd = new SqlCommand("SELECT * FROM assetservertable; SELECT * FROM scheduler", sqlconn);

                {
                    SqlDataReader reader = cmd.ExecuteReader();

                    var builder = new StringBuilder();
                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {
                            {
                                builder.Append("\r\n" + "From AssetServer Table: " + Environment.NewLine + "\r\n" +
                                "ID: " + reader.GetValue(0) + Environment.NewLine +
                                "SITE ADDRESS: " + reader.GetValue(1) + Environment.NewLine +
                                "ACTIVE: " + reader.GetValue(2) + Environment.NewLine +
                                "CALLBACK URL: " + reader.GetValue(3) + Environment.NewLine +
                                "DATE MODIFIED: " + reader.GetValue(4) + Environment.NewLine +
                                "LOADBALANCED: " + reader.GetValue(5) + Environment.NewLine +
                                "LOCK_SID: " + reader.GetValue(6) + Environment.NewLine +
                                "LOCK_TYPE: " + reader.GetValue(7) + Environment.NewLine +
                                "SERVER_STATE: " + reader.GetValue(8) + Environment.NewLine +
                                "CUSTOM_ID: " + reader.GetValue(9) + Environment.NewLine + "\r\n"

                                );

                                if (reader.NextResult())
                                {
                                    while (reader.Read())
                                    {
                                        foreach (var read2 in reader)
                                        {

                                            builder.Append("\r\n" + "From Scheduler Table: " + Environment.NewLine + "\r\n" +
                                           "SCHEDULE ID: " + reader.GetValue(0) + Environment.NewLine +
                                           "PARENTSYNCID: " + reader.GetValue(1) + Environment.NewLine +
                                           "SCHEDULE NAME: " + reader.GetValue(2) + Environment.NewLine +
                                           "SCHEDULE DESC: " + reader.GetValue(3) + Environment.NewLine +
                                           "START TIME: " + reader.GetValue(4) + Environment.NewLine +
                                           "UTC: " + reader.GetValue(5) + Environment.NewLine +
                                           "LAST RUN TIME: " + reader.GetValue(6) + Environment.NewLine +
                                           "NEXT RUN TIME: " + reader.GetValue(7) + Environment.NewLine +
                                           "LAST RUN RESULT: " + reader.GetValue(8) + Environment.NewLine +
                                           "TRIGGER INTERVAL: " + reader.GetValue(9) + Environment.NewLine +
                                           "TRIGGER FREQUENCY: " + reader.GetValue(10) + Environment.NewLine + Environment.NewLine +
                                           "TRIGGER ACTION: " + reader.GetValue(11) + Environment.NewLine + Environment.NewLine +
                                           "STATUS: " + reader.GetValue(12) + Environment.NewLine +
                                           "SERVER TYPE: " + reader.GetValue(13) + Environment.NewLine +
                                           "EXT_ARGS: " + reader.GetValue(14) + Environment.NewLine +
                                           "DATE CREATED: " + reader.GetValue(15) + Environment.NewLine +
                                           "DATE MODIFIED: " + reader.GetValue(16) + Environment.NewLine +
                                           "CMS PACKAGE ID: " + reader.GetValue(17) + Environment.NewLine

                                      );

                                        }


                                    }
                                }
                            }
                        }
                    }
                    ResultBox.Text = Server.HtmlEncode(builder.ToString());
                }

            }
            sqlconn.Close();
        }
        public void hostfile_Click(object sender, EventArgs e)
        {
            string file_name = @"C:\Windows\System32\drivers\etc\hosts";

            if (file_name != null)
            {

                System.IO.StreamReader objReader = new System.IO.StreamReader(file_name);

                ResultBox.Text = ("\r\n" + objReader.ReadToEnd() + Environment.NewLine);

                objReader.Close();

            }

            else

                MessageBox.Text = ("file does not exist!");

        }
        public void sites_Click(object sender, EventArgs e)
        {
            ServerManager serverman = new ServerManager();

            var builder = new StringBuilder();
            {

                foreach (Microsoft.Web.Administration.Site s in serverman.Sites)
                {

                    {
                        foreach (Microsoft.Web.Administration.Application app in s.Applications)
                        {
                            foreach (Microsoft.Web.Administration.Binding bind in s.Bindings)
                            {
                                builder.Append("\r\n" + "SITE: " + s.Id.ToString() + " " + s.Name.ToString() + Environment.NewLine +
                                "APP POOL: " + app.ApplicationPoolName.ToString() + Environment.NewLine +
                                "PROTOCOLS: " + app.EnabledProtocols + Environment.NewLine +
                                "BINDING: " + bind.BindingInformation.ToString() + Environment.NewLine +
                                "HOST: " + bind.Host.ToString() + Environment.NewLine + "Status: " + s.State + Environment.NewLine +
                                "SITE VIRTUAL PATH: " + app.Path + Environment.NewLine +
                                "SITE PHYSICAL PATH: " + s.Applications["/"].VirtualDirectories["/"].PhysicalPath + Environment.NewLine + Environment.NewLine);
                            }
                        }
                    }
                }
                ResultBox.Text = ("IIS Site Settings: " + Environment.NewLine + Environment.NewLine + builder.ToString());
            }
        }
        public void Sysinfo_Click(object sender, EventArgs e)
        {

            foreach (DictionaryEntry userdom in Environment.GetEnvironmentVariables())
            {
                DriveInfo[] hddrives = System.IO.DriveInfo.GetDrives();

                foreach (DriveInfo drives in hddrives)
                {
                    {
                        //clean the result text box
                        ResultBox.Text = string.Empty;

                        //initialize powershell engine
                        var shell = PowerShell.Create();

                        //Add script to the powershell object

                        shell.Commands.AddScript("Get-WmiObject Win32_LogicalDisk");
                        shell.AddParameter("filter");
                        shell.AddParameter("DriveType", "3");
                        shell.AddCommand("out-string");

                        //Execute the script
                        var results = shell.Invoke();

                        //Display results with base object converted to string
                        if (results.Count > 0)
                        {
                            // We use a string builder ton create our result text
                            var builder = new StringBuilder();

                            foreach (var psObject in results)
                            {
                                // Convert the Base Object to a string and append it to the string builder.
                                // Add \r\n for line breaks
                                builder.Append(psObject.BaseObject.ToString());
                            }

                            string tempPath = System.IO.Path.GetTempPath();

                            ResultBox.Text = ("\r\n" + "Machine Details: " + Environment.NewLine + Environment.NewLine
                            + "MACHINE NAME: " + Environment.MachineName + Environment.NewLine
                            + userdom.Key.ToString() + ": " + userdom.Value.ToString() + Environment.NewLine
                            + "OS VERSION: " + Environment.OSVersion + Environment.NewLine
                            + "PROCESSOR: " + Environment.ProcessorCount + Environment.NewLine
                            + "VERSION: " + Environment.Version + Environment.NewLine
                            + "MEMORY: " + Environment.WorkingSet + Environment.NewLine
                            + "TEMP PATH: " + tempPath + Environment.NewLine
                            + "DISK INFORMATION: " + Environment.NewLine + builder.ToString() + "\r\n");
                        }
                    }
                }
            }
        }
        public void ServerInfoXML_Click(object sender, EventArgs e)
        {
            System.Xml.XmlDocument xmldoc = new System.Xml.XmlDocument();
            xmldoc.Load("c:\\sync\\ServerInfo85.xml");
            System.Xml.XmlNodeList nodelist = xmldoc.DocumentElement.SelectNodes("/SyncServerInfoList/SyncServerInfo");

            var builder = new StringBuilder();

            string Serverid;
            string ServerURL;
            string RemoteServerURL;
            string RemoteServerName;
            string ConnectionInfo;
            string SitePath;
            string SiteAddress;
            string RemoteSiteAddress;
            string RemoteConnectionInfo;
            string RelationshipToken;

            foreach (XmlNode node in nodelist)
            {
                Serverid = node.SelectSingleNode("ServerId").InnerText;
                ServerURL = node.SelectSingleNode("ServerUrl").InnerText;
                RemoteServerURL = node.SelectSingleNode("RemoteServerUrl").InnerText;
                RemoteServerName = node.SelectSingleNode("RemoteServerName").InnerText;
                ConnectionInfo = node.SelectSingleNode("ConnectionInfo").InnerText;
                SitePath = node.SelectSingleNode("SitePath").InnerText;
                SiteAddress = node.SelectSingleNode("SiteAddress").InnerText;
                RemoteSiteAddress = node.SelectSingleNode("RemoteSiteAddress").InnerText;
                RelationshipToken = node.SelectSingleNode("RelationshipToken").InnerText;
                RemoteConnectionInfo = node.SelectSingleNode("RemoteConnectionInfo").InnerText;

                {
                    builder.Append(Environment.NewLine +
                           "SERVER ID: " + Serverid + Environment.NewLine +
                           "SERVER URL: " + ServerURL + Environment.NewLine +
                           "REMOTE SERVER URL: " + RemoteServerURL + Environment.NewLine +
                           "REMOTE SERVER NAME: " + RemoteServerName + Environment.NewLine +
                           "CONNECTION  INFO: " + ConnectionInfo + Environment.NewLine +
                           "SITE PATH: " + SitePath + Environment.NewLine +
                           "SITE ADDRESS: " + SiteAddress + Environment.NewLine +
                           "RELATIONSHIP TOKEN: " + RelationshipToken + Environment.NewLine +
                           "REMOTE SITE ADDRESS: " + RemoteSiteAddress + Environment.NewLine +
                           "REMOTE CONNECTION INFO: " + RemoteConnectionInfo + Environment.NewLine
                           );
                }
            }
            ResultBox.Text = ("ServerInfo.XML:" + Environment.NewLine + builder.ToString());
        }
        public void testcallbackurl_Click(object sender, EventArgs e)
        {
            WebClient client = new WebClient();

            string conn =
            ConfigurationManager.ConnectionStrings["Ektron.DbConnection"].ConnectionString;

            SqlConnection sqlconn = new SqlConnection(conn);
            {
                sqlconn.Open();

                SqlCommand cmd = new SqlCommand("SELECT * FROM assetservertable", sqlconn);

                StringBuilder builder = new StringBuilder();

                {
                    SqlDataReader reader = cmd.ExecuteReader();

                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {                      

                            string addstr;                                                    

                            object address = reader.GetValue(3);
                            
                            addstr = Convert.ToString(address);

                            try
                            {

                            builder.Append(Environment.NewLine + addstr + Environment.NewLine 
                                + client.DownloadString(addstr) 
                                + Environment.NewLine);
                         
                            ResultBox.Text = builder.ToString();
                            }

                            catch (Exception ex)
                            {
                                ResultBox.Text = ex.Message;
                            }

                        }
                    }
                }
            }
        }
        public void TempDir_Click(object sender, EventArgs e)
        {
            string tempPathDir = System.IO.Path.GetTempPath();
            string[] files = Directory.GetFiles(tempPathDir);

            var builder = new StringBuilder();

            foreach (string filename in files)
            {
                builder.Append(filename + Environment.NewLine);

                ResultBox.Text = ("Files in the temp directory: " + Environment.NewLine + Environment.NewLine + builder.ToString());

            }

        }
        #region
        //protected void collectfiles_Click(object sender, EventArgs e)
        //{
        //    try
        //    {

        //        string folder = @"C:\RemoteFiles";

        //        if (folder != null)
        //        {
        //            Directory.CreateDirectory(@"C:\RemoteFiles");

        //        }

        //        string fileName = "ServerInfo85.XML";
        //        string sourcePath = @"\\" + sourcetxt1.Text + @"\c$\sync\";

        //        string fileName2 = @"Ektron.ASM.EktronServices40.exe.config";
        //        string sourcePath2 = @"\\" + sourcetxt1.Text + @"\c$\Program Files (x86)\Ektron\EktronWindowsService40";

        //        //string fileName3 = @"Webconfig.zip";
        //        //string sourcePath3 = @"\\" + sourcetxt1.Text + @"\c$\inetpub\wwwroot\cms400\";

        //        string targetPath = @"\\" + desttxt1.Text + @"\c$\RemoteFiles";

        //        //string zipPath = @"\\" + sourcetxt1.Text + @"\c$\inetpub\wwwroot\cms400\Webconfig.zip";

        //        string sourceFile = System.IO.Path.Combine(sourcePath, fileName);
        //        string destFile = System.IO.Path.Combine(targetPath, fileName);

        //        string sourceFile2 = System.IO.Path.Combine(sourcePath2, fileName2);
        //        string destFile2 = System.IO.Path.Combine(targetPath, fileName2);

        //        //string sourceFile3 = System.IO.Path.Combine(sourcePath3, fileName3);
        //        //string destFile3 = System.IO.Path.Combine(targetPath, fileName3);

        //        if (System.IO.Directory.Exists(sourcePath))
        //        {
        //            string[] files = System.IO.Directory.GetFiles(sourcePath);


        //            foreach (string s in files)
        //            {

        //                fileName = System.IO.Path.GetFileName(fileName);
        //                destFile = System.IO.Path.Combine(targetPath, fileName);
        //                System.IO.File.Copy(s, destFile, true);
        //            }
        //        }
        //        if (System.IO.Directory.Exists(targetPath))
        //        {
        //            string[] files2 = System.IO.Directory.GetFiles(sourcePath2);

        //            foreach (string s2 in files2)
        //            {

        //                fileName2 = System.IO.Path.GetFileName(fileName2);
        //                destFile2 = System.IO.Path.Combine(targetPath, fileName2);
        //                System.IO.File.Copy(s2, destFile2, true);
        //            }
        //        }

        //        //ZipFile.CreateFromDirectory(sourcePath3, zipPath);
        //        //ZipFile.ExtractToDirectory(zipPath, targetPath);


        //        //if (System.IO.Directory.Exists(targetPath))
        //        //{

        //        //    string[] files3 = System.IO.Directory.GetFiles(zipPath);

        //        //    foreach (string s3 in files3)
        //        //    {
        //        //        destFile3 = System.IO.Path.GetFileName(fileName3);
        //        //        destFile3 = System.IO.Path.Combine(targetPath, fileName3);
        //        //        System.IO.File.Copy(s3, destFile3, true);
        //        //    }
        //        //}
        //        //if (zipPath != null)
        //        //{
        //        //    System.IO.File.Copy(fileName3, destFile3, true);
        //        //}

        //        ResultBox.Text = ("Copied: " + sourcePath + fileName + " to " + targetPath + Environment.NewLine +
        //             "Copied: " + sourcePath2 + fileName2 + " to " + targetPath + Environment.NewLine
        //            // + "Copied: " + sourcePath3 + 
        //            //zipPath + " to " + targetPath

        //             );
        //        #region
        //        //StringBuilder builder = new StringBuilder();
        //        //StringBuilder builder2 = new StringBuilder();
        //        ////StringBuilder builder3 = new StringBuilder();

        //        ////clean the result text box
        //        //ResultBox.Text = string.Empty;

        //        ////initialize powershell engine
        //        //var shell = PowerShell.Create();

        //        //builder.Append(@"\\" + sourcetxt1.Text + @"\c$\Program Files (x86)\Ektron\EktronWindowsService40\Ektron.ASM.EktronServices40.exe.config");
        //        //builder2.Append(@"\\" + desttxt1.Text + @"\c$\RemoteFiles");
        //        ////builder3.Append(@"\\" + sourcetxt1.Text + @"\c$\sync\ServerInfo85.XML");

        //        //shell.AddCommand("copy-item");
        //        //shell.AddParameter("path", builder);
        //        //shell.AddParameter("destination", builder2);
        //        //shell.AddCommand("out-string");

        //        ////Execute the script
        //        //var results = shell.Invoke();

        //        ////Display results

        //        //if (results.Count > 0)
        //        //{

        //        //    ResultBox.Text = ("Finished copying files from: " + builder + " to " + builder2);
        //        //    MessageBox.Text = ("Files collected");
        //        //}
        //        #endregion
        //    }
        //    catch (Exception ex)
        //    {
        //        ResultBox.Text = ("Exception: " + ex);
        //    }
        //}
        #endregion
        public void ValidateSite_Click(object sender, EventArgs e)
        {

            try
            {
                System.Xml.XmlDocument xmldoc = new System.Xml.XmlDocument();
                System.Xml.XmlDocument xmldoc2 = new System.Xml.XmlDocument();

                xmldoc.Load(@"\\" + desttxt1.Text + @"\c$\SourceFiles\ServerInfo85.xml");
                xmldoc2.Load(@"\\" + desttxt1.Text + @"\c$\RemoteFiles\ServerInfo85.xml");
                System.Xml.XmlNodeList nodelist = xmldoc.DocumentElement.SelectNodes("/SyncServerInfoList/SyncServerInfo");
                System.Xml.XmlNodeList nodelist2 = xmldoc2.DocumentElement.SelectNodes("/SyncServerInfoList/SyncServerInfo");

                string sitedb1 = (@"\\" + desttxt1.Text + @"\c$\RemoteFiles\Ektron.ASM.EktronServices40.exe.config");
                string sitedb2 = (@"\\" + desttxt1.Text + @"\c$\SourceFiles\Ektron.ASM.EktronServices40.exe.config");
                string sitedb3 = (@"\\" + desttxt1.Text + @"\c$\RemoteFiles\web.config");
                string sitedb4 = (@"\\" + desttxt1.Text + @"\c$\SourceFiles\web.config");

                ExeConfigurationFileMap configMap1 = new ExeConfigurationFileMap();
                configMap1.ExeConfigFilename = sitedb1;
                System.Configuration.Configuration config1 = ConfigurationManager.OpenMappedExeConfiguration(configMap1, ConfigurationUserLevel.None);

                ExeConfigurationFileMap configMap2 = new ExeConfigurationFileMap();
                configMap2.ExeConfigFilename = sitedb2;
                System.Configuration.Configuration config2 = ConfigurationManager.OpenMappedExeConfiguration(configMap2, ConfigurationUserLevel.None);

                ExeConfigurationFileMap configMap3 = new ExeConfigurationFileMap();
                configMap3.ExeConfigFilename = sitedb3;
                System.Configuration.Configuration config3 = ConfigurationManager.OpenMappedExeConfiguration(configMap3, ConfigurationUserLevel.None);
                
                ExeConfigurationFileMap configMap4 = new ExeConfigurationFileMap();
                configMap4.ExeConfigFilename = sitedb4;
                System.Configuration.Configuration config4 = ConfigurationManager.OpenMappedExeConfiguration(configMap4, ConfigurationUserLevel.None);

                ServerManager serverman = new ServerManager();

                foreach (XmlNode node in nodelist)
                {
                    StringBuilder builder = new StringBuilder();
                    {
                        foreach (Microsoft.Web.Administration.Site s in serverman.Sites)
                        {
                            foreach (XmlNode node1 in nodelist)
                            {
                                foreach (XmlNode node2 in nodelist2)
                                {

                                    string SiteAddress1 = node1.SelectSingleNode("SiteAddress").InnerText.ToUpper();
                                    string SitePath1 = node1.SelectSingleNode("SitePath").InnerText.ToUpper();
                                    string SiteAddress2 = node2.SelectSingleNode("SiteAddress").InnerText.ToUpper();
                                    string SitePath2 = node2.SelectSingleNode("SitePath").InnerText.ToUpper();
                                    string RemoteServerName1 = node1.SelectSingleNode("RemoteServerName").InnerText.ToUpper();
                                    string RemoteServerName2 = node2.SelectSingleNode("RemoteServerName").InnerText.ToUpper();
                                    string RemoteSiteAddress1 = node1.SelectSingleNode("RemoteSiteAddress").InnerText.ToUpper();
                                    string RemoteSiteAddress2 = node2.SelectSingleNode("RemoteSiteAddress").InnerText.ToUpper();
                                    string RemoteConnectionInfo1 = node1.SelectSingleNode("RemoteConnectionInfo").InnerText.ToUpper();
                                    string RemoteConnectionInfo2 = node2.SelectSingleNode("RemoteConnectionInfo").InnerText.ToUpper();
                                    string EWSVersion1 = config1.AppSettings.Settings["InstallVersion"].Value;
                                    string EWSVersion2 = config2.AppSettings.Settings["InstallVersion"].Value;
                                    string RemoteWebVersion = config3.AppSettings.Settings["ek_InstallBuild"].Value;
                                    string SourceWebVersion = config4.AppSettings.Settings["ek_InstallBuild"].Value;
                                    string SourceWSPath = config4.AppSettings.Settings["WSPath"].Value;
                                    string RemoteWSPath = config3.AppSettings.Settings["WSPath"].Value;
                                    string SourceWebEncoded = config4.AppSettings.Settings["encodedValue"].Value;
                                    string RemoteWebEncoded = config3.AppSettings.Settings["encodedValue"].Value;
                                    string remoteWebConn = config3.ConnectionStrings.ConnectionStrings["Ektron.DbConnection"].ConnectionString.ToUpper();
                                    string sourceWebConn = config4.ConnectionStrings.ConnectionStrings["Ektron.DbConnection"].ConnectionString.ToUpper();
                                    var RemoteEWSEncoded = config1.GetSection("ektron.serviceModel") as Ektron.FileSync.Common.Sync.Section;                                   
                                    if (RemoteEWSEncoded != null && RemoteEWSEncoded.PublicCertificates != null)
                                    {
                                        
                                        for (int i = 0; i < RemoteEWSEncoded.PublicCertificates.Count; i++)
                                        {
                                            builder.Append(Environment.NewLine + RemoteEWSEncoded.PublicCertificates[i].Key + " -- " + RemoteEWSEncoded.PublicCertificates[i].EncodedValue.ToString() + Environment.NewLine);
                                        }
                                    }
                                    
                                    var SourceEWSEncoded = config2.GetSection("ektron.serviceModel") as Ektron.FileSync.Common.Sync.Section;
                                    if (SourceEWSEncoded != null && SourceEWSEncoded.PublicCertificates != null)
                                    {

                                        for (int i = 0; i < RemoteEWSEncoded.PublicCertificates.Count; i++)
                                        {
                                             builder.Append(Environment.NewLine + RemoteEWSEncoded.PublicCertificates[i].Key + " -- " + RemoteEWSEncoded.PublicCertificates[i].EncodedValue.ToString() + Environment.NewLine);
                                        }
                                    }
                                    
                                    #region
                                    //else
                                   

                                    //builder.Append("Sync" + a);

                                   // Response.Write(config4.GetSection("ektron.serviceModel").ToString());
                                    // Response.End();
                                    #endregion
                                    var LocalMachineName = Environment.MachineName;
                                    var RemoteMachineName = sourcetxt1.Text.ToUpper();
                                    var IISSite = s.Applications["/"].VirtualDirectories["/"].PhysicalPath;
                                    #region
                                    //Response.Write(SiteAddress1 + "<br/>" + SitePath1 + "<br/>" +
                                    //     SiteAddress2 + "<br/>" + SitePath2 + "<br/>" + LocalMachineName + "<br/>"
                                    //+ RemoteMachineName + "<br/>" + IISSite + "<br/>" + RemoteServerName1 + "<br/>" + RemoteServerName2
                                    //+ "<br/>" + RemoteSiteAddress1 + "<br/>" + RemoteSiteAddress2 + "<br/>" + RemoteConnectionInfo1 + "<br/>" + RemoteConnectionInfo2);

                                    //Response.End();
                                    #endregion

                                    string s1 = SiteAddress1;
                                    string s2 = LocalMachineName;
                                    string s3 = SitePath1;
                                    string s4 = IISSite;
                                    string s5 = SiteAddress2;
                                    string s6 = SitePath2;
                                    string s7 = RemoteMachineName;
                                    string s8 = RemoteServerName1;
                                    string s9 = RemoteServerName2;
                                    string s10 = RemoteSiteAddress1;
                                    string s11 = RemoteSiteAddress2;
                                    string s12 = RemoteConnectionInfo1;
                                    string s13 = RemoteConnectionInfo2;
                                    string s14 = EWSVersion1;
                                    string s15 = EWSVersion2;
                                    string s16 = RemoteWebVersion;
                                    string s17 = SourceWebVersion;
                                    string s18 = remoteWebConn;
                                    string s19 = sourceWebConn;
                                    string s20 = SourceWSPath;
                                    string s21 = RemoteWSPath;
                                    string s22 = SourceWebEncoded;
                                    string s23 = RemoteWebEncoded;
                                                                       
                                    #region
                                    //string LocalWebVersion =
                                    //ConfigurationManager.AppSettings["ek_InstallBuild"];
                                    #endregion
                                    #region
                                    //                        if (s1 == s2)
                                    //                        {
                                    //                            builder.Append("\r\n" + "Comparing " + s1 + " from ServerInfoXML to " + s2
                                    //                                + " from System Info is the same" + Environment.NewLine);

                                    //                            if (s3 == s4)
                                    //                            {
                                    //                                builder.Append("\r\n" + "Comparing " + s3 + " from ServerInfoXML to " + s4
                                    //                                    + " from IIS site settings is the same" + Environment.NewLine);

                                    //                                if (s14 == s15)
                                    //                                {
                                    //                                    builder.Append("\r\n" + "Matching EWS Versions: " + Environment.NewLine + Environment.NewLine
                                    //                                        + s14 + Environment.NewLine + s15 + "\r\n");

                                    //                                    if (s16 == s15)
                                    //                                    {
                                    //                                        builder.Append("\r\n" + "Matching Install Versions between EWS and Remote Web.config: " + Environment.NewLine + Environment.NewLine
                                    //                                            + s16 + Environment.NewLine + s15 + "\r\n");

                                    //                                        if (s16 == s17)
                                    //                                        {
                                    //                                            builder.Append("\r\n" + "Matching Install Versions between Local and Remote Web.config: " + Environment.NewLine + Environment.NewLine
                                    //                                                + s16 + Environment.NewLine + s17 + "\r\n");

                                    //                                            ResultBox.Text = (builder.ToString());
                                    //                                        }
                                    //                                    }

                                    //                                }


                                    //                            }


                                    //                            else if (s3 != s4)


                                    //                                builder.Append("\r\n" + "Comparing " + s3 + " from ServerInfoXML to " + s4
                                    //                                    + " from IIS site settings is NOT the same" + "\r\n");

                                    //                            if (s1 != s2)

                                    //                                builder.Append("\r\n" + "Comparing " + s1 + " from ServerInfoXML to " + s2
                                    //                                    + " from System Info is the same" + Environment.NewLine + "\r\n");

                                    //                            if (s14 != s15)

                                    //                                builder.Append("\r\n" + "Not Matching EWS Versions: " + Environment.NewLine + Environment.NewLine +
                                    //                        sitedb1 + Environment.NewLine + s14 + Environment.NewLine +
                                    //                      sitedb2 + Environment.NewLine + s15 + "\r\n");

                                    //                            if (s15 != s16)

                                    //                                builder.Append("\r\n" + "Not Matching Install Versions between EWS and Web.config: " + Environment.NewLine + Environment.NewLine
                                    //                                    + s15 + Environment.NewLine + s16 + "\r\n");

                                    //                            if (s16 != s17)

                                    //                                builder.Append("\r\n" + "Not Matching Install Versions between local and Remote Web.config: " + Environment.NewLine + Environment.NewLine
                                    //                                    + s16 + Environment.NewLine + s17 + "\r\n");

                                    //                        }

                                    //                        ResultBox.Text = (builder.ToString());
                                    //                    }

                                    //                }

                                    //            }
                                    //        }
                                    //    }
                                    //}
                                    #endregion
                                    
                                    if (s23 == SourceEWSEncoded)
                                    {

                                    }
                                    if (s1 == s2)
                                    {
                                        builder.Append(Environment.NewLine + "comparing Local Site Address from ServerInfo85.xml to Local Machine " + s1 + " & " + s2 + " is the same" + Environment.NewLine);
                                        ResultBox.Text = builder.ToString();
                                    }
                                    else if (s1 != s2)
                                    {
                                        builder.Append(Environment.NewLine + "comparing Local Site Address from ServerInfo85.xml to Local Machine " + s1 + " & " + s2 + " is NOT the same" + Environment.NewLine);
                                        ResultBox.Text = builder.ToString();
                                    }

                                    if (s5 == s7)
                                    {
                                        builder.Append(Environment.NewLine + "comparing Remote Site Address from ServerInfo85.xml to Remote Machine " + s5 + " & " + s7 + " is the same" + Environment.NewLine);
                                        ResultBox.Text = builder.ToString();
                                    }
                                    else if (s5 != s7)
                                    {
                                        builder.Append(Environment.NewLine + "comparing Remote Site Address from ServerInfo85.xml to Remote Machine " + s5 + " & " + s7 + " is NOT the same" + Environment.NewLine);
                                        ResultBox.Text = builder.ToString();
                                    }

                                    if (s8 == s2)
                                    {
                                        builder.Append(Environment.NewLine + "comparing Remote Connection Info from ServerInfo85.xml to Local Machine ServerInfo85.xml " + s8 + " & " + s2 + " is the same" + Environment.NewLine);
                                        ResultBox.Text = builder.ToString();
                                    }
                                    else if (s8 != s2)
                                    {
                                        builder.Append(Environment.NewLine + "comparing Remote Connection Info from ServerInfo85.xml to Local Machine ServerInfo85.xml " + s8 + " & " + s2 + " is NOT the same" + Environment.NewLine);
                                        ResultBox.Text = builder.ToString();
                                    }
                                    if (s9 == s7)
                                    {
                                        builder.Append(Environment.NewLine + "comparing Remote Connection Info from ServerInfo85.xml to Remote Machine ServerInfo85.xml " + s9 + " & " + s7  + " is the same" + Environment.NewLine);
                                        ResultBox.Text = builder.ToString();
                                    }
                                    else if (s9 != s7)
                                    {
                                        builder.Append(Environment.NewLine + "comparing Remote Connection Info from ServerInfo85.xml to Remote Machine ServerInfo85.xml " + s9 + " & " + s7 + " is NOT the same" + Environment.NewLine);
                                        ResultBox.Text = builder.ToString();
                                    }
                                    if (s16 == s17)
                                    {
                                        builder.Append(Environment.NewLine + "comparing Remote Web Install Version to Local Machine Web Install Version " + s16 + " & " + s17 + " is the same" + Environment.NewLine);
                                        ResultBox.Text = builder.ToString();
                                    }
                                    else if (s16 != s17)
                                    {
                                        builder.Append(Environment.NewLine + "comparing Remote Web Install Version to Local Machine Web Install Version " + s16 + " & " + s17 + " is NOT the same" + Environment.NewLine);
                                        ResultBox.Text = builder.ToString();
                                    }
                                    if (s14 == s15)
                                    {
                                        builder.Append(Environment.NewLine + "comparing Remote EWS Install Version to Local Machine EWS Install Version " + s14 + " & " + s15 + " is the same" + Environment.NewLine);
                                        ResultBox.Text = builder.ToString();
                                    }
                                    else if (s14 != s15)
                                    {
                                        builder.Append(Environment.NewLine + "comparing Remote EWS Install Version to Local Machine EWS Install Version " + s14 + " & " + s15 + " is NOT the same" + Environment.NewLine);
                                        ResultBox.Text = builder.ToString();
                                    }
                                    if (s18 == s13)
                                    {
                                        builder.Append(Environment.NewLine + "comparing Remote Web Config Connection String to Source ServerInfo85.xml: " + Environment.NewLine + s18 + " & " + Environment.NewLine + s13 + " is the same" + Environment.NewLine);
                                        ResultBox.Text = builder.ToString();
                                    }
                                    else if (s18 != s13)
                                    {
                                        builder.Append(Environment.NewLine + "comparing Remote Web Config Connection String to Source ServerInfo85.xml: " + Environment.NewLine + s18 + " & " + Environment.NewLine + s13 + " is NOT the same" + Environment.NewLine);
                                        ResultBox.Text = builder.ToString();
                                    }
                                    if (s19 == s12)
                                    {
                                        builder.Append(Environment.NewLine + "comparing Source Web Config Connection String to Remote ServerInfo85.xml: " + Environment.NewLine + s19 + " & " + Environment.NewLine + s12 + " is the same" + Environment.NewLine);
                                        ResultBox.Text = builder.ToString();
                                    }
                                    else if (s19 != s12)
                                    {
                                        builder.Append(Environment.NewLine + "comparing Source Web Config Connection String to Remote ServerInfo85.xml: " + Environment.NewLine + s19 + " & " + Environment.NewLine + s12 + " is NOT the same" + Environment.NewLine);
                                        ResultBox.Text = builder.ToString();
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ResultBox.Text = ex.Message;

            }
        }
        protected void sitedb_Click(object sender, EventArgs e)
        {
            string file_name = @"C:\Program Files (x86)\Ektron\EktronWindowsService40\sitedb.config";

            if (file_name != null)
            {

                System.IO.StreamReader objReader = new System.IO.StreamReader(file_name);

                ResultBox.Text = ("\r\n" + objReader.ReadToEnd() + Environment.NewLine);

                objReader.Close();

                MessageBox.Text = ("File Opened");

            }

            else

                MessageBox.Text = ("file does not exist!");

        }
        protected void assetman_Click(object sender, EventArgs e)
        {
                        
            string file_name = (AppDomain.CurrentDomain.BaseDirectory + @"\AssetManagement.config");
                                
            if (file_name != null)
            {

                System.IO.StreamReader objReader = new System.IO.StreamReader(file_name);

                ResultBox.Text = ("\r\n" + objReader.ReadToEnd() + Environment.NewLine);

                objReader.Close();

                MessageBox.Text = ("File Opened");

            }

            else

                MessageBox.Text = ("file does not exist!");

        }
        protected void saveclick1_Click(object sender, EventArgs e)
        {
            try
            {
                string folder = @"C:\SourceFiles";

                if (folder != null)
                {
                    Directory.CreateDirectory(@"C:\SourceFiles");

                }

                HttpPostedFile postedFile = sourceupload.PostedFile;
                int fileLength = postedFile.ContentLength;
                byte[] fileData = new byte[fileLength];
                postedFile.InputStream.Read(fileData, 0, fileLength);
                sourceupload.SaveAs(@"\\" + desttxt1.Text + @"\c$\SourceFiles\" + sourceupload.FileName);
                MessageBox.Text = ("File Added");
                ResultBox.Text = ("File " + sourceupload.FileName + " added to folder " + folder);

            }
            catch (Exception Ex)
            {
                ResultBox.Text = (Ex.Message);
            }
        }
        protected void saveclick2_Click(object sender, EventArgs e)
        {
            try
            {
                string folder = @"C:\RemoteFiles";

                if (folder != null)
                {
                    Directory.CreateDirectory(@"C:\RemoteFiles");

                }

                HttpPostedFile postedFile = destinationupload.PostedFile;
                int fileLength = postedFile.ContentLength;
                byte[] fileData = new byte[fileLength];
                postedFile.InputStream.Read(fileData, 0, fileLength);
                destinationupload.SaveAs(@"\\" + desttxt1.Text + @"\c$\RemoteFiles\" + destinationupload.FileName);
                MessageBox.Text = ("File Added");
                ResultBox.Text = ("File " + destinationupload.FileName + " added to folder " + folder);
             
            }
            catch (Exception Ex)
            {
                ResultBox.Text = ("Error: " + Ex.Message);
            }
        }    
}
}
