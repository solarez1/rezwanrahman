<#
.AUTHOR: Rezwan Rahman
.DESCRIPTION: This Module allows the user to create a Service Now ticket for COC to check which AWS Accounts need decommissioning.
#>

Function Get-FlaggedAWSAccounts
{
param(
  $ServiceNowUsername,
  $ServiceNowPassword,
  $EmailFrom,
  $EmailTo
)

#Create directory variables
$sourcefolder = "C:\Billing\Current_Report"
$targetfolder = "C:\Billing\Archived_Reports"
$flaggedpath = "C:\Billing\Remove_Accounts"
$date = $(get-date -Format yyyyMMdd)

#Cleanup old files
Remove-Item -Path $sourcefolder, $targetfolder -Recurse -Force

$newItem = @{
ItemType = 'Directory'
ErrorAction = 'SilentlyContinue'
}

#Test to see if directories exist or not, if not, create them
if(Test-Path $sourcefolder, $targetfolder, $flaggedpath){
New-Item $sourcefolder @newItem | Out-Null
New-Item $targetfolder @newItem | Out-Null
New-Item $flaggedpath @newItem  | Out-Null
}

#Try-Catch block which encapsulates downloading of the report from s3. It will throw a warning if it cannot be downloaded or does not exist
Try{
$webClient = New-Object System.Net.WebClient
Add-Content -path "C:\Billing\Current_Report\$date.csv" -value $webClient.DownloadString("https://s3-eu-west-1.amazonaws.com/eu-awscost-report/$(Get-Date -Format yyMM).csv")
}
Catch{
Write-Warning "$_"
$mail = @{
From = $EmailFrom;
To = $EmailTo;
SmtpServer = 'smtp.sdlproducts.com';
Subject = "AWS billing report could not be found";
Body = "Please check s3 bucket eu-awscost-report in CloudOperationsGlobal for the latest cost report in .csv format";
Priority = "High"
}
Send-MailMessage @mail
BREAK
}

#Try-Catch block to throw a warning if the file does not exist in source location
try{
$importcsv = Import-Csv "$sourcefolder\*.csv"
}
Catch [System.IO.FileNotFoundException] {
Write-Warning "There is no file in the location specified! Please check $sourcefolder"
$mail = @{
From = $EmailFrom;
To = $EmailTo;
SmtpServer = 'smtp.sdlproducts.com';
Subject = "AWS billing report could not be found";
Body = "Please check if $sourcefolder exists on server";
Priority = "High"
}
Send-MailMessage @mail
BREAK
}

foreach($b in $importcsv){
#Get Previous Month's Cost and generate a text file for all AWS Accounts that have incurred less than $50 worth of cost
$month = ((Get-Date).AddMonths(-1)).Month
$abbMonth = (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($month)
[int64]$cost = $b | Select-Object -ExpandProperty $abbMonth
if($cost -lt '50'){
Write-Output "$($b.'AWS Description') needs reviewing"
#$acctid = $($b.'AWS Account #')
#$accountid = [int64]$acctid
$value = "[Account Name: {0}  |   Owner: {1}]  `r`n" -f ($b.'AWS Description'), ($b.Owner) #[Account ID: {0} needs reviewing ($accountid)
Add-Content "$flaggedpath\$date-FlaggedAccounts.txt" -Value $value
    }
else{
Write-Output "$($b.'AWS Description') is in use"
    }
}
$fullcount = (get-content "$flaggedpath\$date-FlaggedAccounts.txt").count
$count = $fullcount/2
Write-Output "`r`nTotal flagged items: $count"
Move-Item "$sourcefolder\*.csv" "$targetfolder\$date.csv" -Force
start-sleep 2

#Only generate a Service Now ticket if the number of flagged AWS accounts is greater than 0
if($count -gt 0){
   try{
   $flaggedpathtxt = (get-content "$flaggedpath\$date-FlaggedAccounts.txt" -Raw)
   New-ServiceNowIncident -flaggedpathtxt $flaggedpathtxt -ServiceNowUsername $ServiceNowUsername -ServiceNowPassword $ServiceNowPassword
   }
   catch{
    $mail = @{
    From = $EmailFrom;
    To = $EmailTo;
    SmtpServer = 'smtp.sdlproducts.com';
    Subject = "Issue with SN creation";
    Body = "Please check if the service now incident to aws cost report has been created, please check jenkins job history for details";
    Priority = "High"
    }
    Send-MailMessage @mail
      }
   }
}
function New-ServiceNowIncident{
	Param(            
		    [Parameter(Mandatory=$true)]
            [object]$flaggedpathtxt,
            $ServiceNowUsername,
            $ServiceNowPassword
         )

    # Build Basic Authentication Header
      $ServiceNowAuthenticationHeader = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($ServiceNowUsername)`:$($ServiceNowPassword)")) #("$($env:ServiceNowUsername)`:$($env:ServiceNowPassword)"))

    # Set Required HTTP Headers For The REST API
    $ServiceNowHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]";
    $ServiceNowHeaders.Add('Authorization',"Basic $ServiceNowAuthenticationHeader");
    $ServiceNowHeaders.Add('Accept','application/json');
    $ServiceNowHeaders.Add('Content-Type','application/json');    

    # Create Incident Request Object
    $SnRequestJSON = $(@{"short_description" = "Flagged AWS Accounts - COC Please follow <Link RRBXX>"
                     "assignment_group" = 'CO - Core Capabilities' #'SD - Cloud Platform'
                     "description" = "$flaggedpathtxt"
                     "priority" = "3"
                     "caller_id" = "Auto Generated"
                     "cmdb_ci" = "AWS Ireland"
                     "category" = "Request"
                     "subcategory" = "Decommission"
                     "u_taskenvironment" = "Test"
                     "impact" = "3"} | ConvertTo-Json);

    # Declare Parameter Object For Web Request
    $ServiceNowUri = 'https://sdluat.service-now.com/api/now/table/incident'
	$SnParametersParameters = @{
		Headers = $ServiceNowHeaders;
		Method = 'POST';
		Uri = $ServiceNowUri;
		Body = $SnRequestJSON;
	}
	
	# Send HTTP request
    $ServiceNowResponse = Invoke-WebRequest @SnParametersParameters;
    
    # Return ServiceNow Result Object
    return $($ServiceNowResponse.Content | ConvertFrom-JSON).result;
}
