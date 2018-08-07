<#
.Synopsis
   An Generic Logging Tool
.DESCRIPTION
  This logging tool is designed to be used by any Powershell Script or Module to provide verbose logging of any events that may occur during the execution of the PS code. It also specifies the team who should investigate the error.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   When testing a module, make sure you run import-module <module name> before running the code
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>

#write event log
function write-log{
param(
[Parameter(Mandatory=$true)] 
[ValidateNotNullOrEmpty()]
[ValidateSet("Automation", "Database", "Custom", "Platform", "GCT", "EPTP")] 
[string]$source,
[ValidateNotNullOrEmpty()]
[ValidateSet("Application", "System", "Security")]
[string]$logname,
[ValidateNotNullOrEmpty()]
[ValidateScript({If ($_ -match '[a-zA-Z0-9]{5,15}') {
            $True
        } Else {
            Throw "Please make sure the NETBIOS name is no longer than 15 characters!"
        }})] 
[string]$computername=$env:computername,
[string]$jobname = $($env:JOB_NAME),
[ValidateNotNullOrEmpty()]
[ValidateScript({If ($_ -match '[a-zA-Z0-9" "]{5,}') {
            $True
        } Else {
            Throw "Please make sure your message is longer than 5 characters!"
        }})] 
[string]$message,
[ValidateNotNullOrEmpty()]
[string]$eventid=10000,
[Parameter(DontShow)]
[string]$apitoken = '8OaIJuU0ViOvav3SAsE504Q3XkVxpmPG8Zadq70y',
[Parameter(DontShow)]
[string]$room = 'LoggingTest',
[string]$line,
[Parameter(DontShow)]
[string]$script = $($MyInvocation.MyCommand.ModuleName),
[switch]$csv,
[switch]$hipchat,
[switch]$msteams,
[Parameter(ParameterSetName='warning')]
[switch]$warning,
[Parameter(ParameterSetName='error')]
[switch]$error,
[Parameter(ParameterSetName='info')]
[switch]$info
)
if($computername -like "*JEN*"){
$message = $message + "`r`n`r`nScript: $script" + "`r`n`r`nJenkins Job Name: " + $jobname + "`r`n`r`nOn Machine: $env:computername" + "`r`n`r`nOwned By: $source" 
}
else{
$message = $message + "`r`n`r`nScript: $script" + "`r`n`r`nOn Machine: $env:computername" + "`r`n`r`nOwned By: $source" 
}

if($warning){
$color = 'yellow'
$entrytype = 'Warning'
$themecolor = '#A0A000'
}
if($error){
$color = 'red'
$entrytype = 'Error'
$themecolor = '#A00000'
}
if($info){
$color = 'green'
$entrytype = 'Information'
$themecolor = '#00A000'
}
if($source -eq 'Database'){
    $apitoken = 'fJpZMAj5Hobl6QMrVDgnF1wkeuZWAMnDd8mIQO6g'
    $room = 'Database - Logging Test'
    $webhook = 'b6c861dc-59e5-4b07-a7fb-b5c9ac2c46d6@df02c2f8-e418-484f-8bd6-c7f2e154f292'
    $incomingwebhook = '9d5fe92232e244178e464fbe2bc41142/e71f6c21-635a-4639-a6b3-7a2dfe686d3f'
}
if($source -eq 'Automation'){
    $apitoken = '8OaIJuU0ViOvav3SAsE504Q3XkVxpmPG8Zadq70y'
    $room = 'LoggingTest'
    $webhook = 'b6c861dc-59e5-4b07-a7fb-b5c9ac2c46d6@df02c2f8-e418-484f-8bd6-c7f2e154f292'
    $incomingwebhook = '9d5fe92232e244178e464fbe2bc41142/e71f6c21-635a-4639-a6b3-7a2dfe686d3f'
}
if($source -eq 'Platform'){
    $apitoken = '8OaIJuU0ViOvav3SAsE504Q3XkVxpmPG8Zadq70y'
    $room = 'LoggingTest'
    $webhook = 'b6c861dc-59e5-4b07-a7fb-b5c9ac2c46d6@df02c2f8-e418-484f-8bd6-c7f2e154f292'
    $incomingwebhook = '9d5fe92232e244178e464fbe2bc41142/e71f6c21-635a-4639-a6b3-7a2dfe686d3f'
}
if($source -eq 'Custom'){
    $apitoken = '8OaIJuU0ViOvav3SAsE504Q3XkVxpmPG8Zadq70y'
    $room = 'LoggingTest'
    $webhook = 'b6c861dc-59e5-4b07-a7fb-b5c9ac2c46d6@df02c2f8-e418-484f-8bd6-c7f2e154f292'
    $incomingwebhook = '9d5fe92232e244178e464fbe2bc41142/e71f6c21-635a-4639-a6b3-7a2dfe686d3f'
}
if($source -eq 'GCT'){
    $apitoken = '8OaIJuU0ViOvav3SAsE504Q3XkVxpmPG8Zadq70y'
    $room = 'LoggingTest'
    $webhook = 'b6c861dc-59e5-4b07-a7fb-b5c9ac2c46d6@df02c2f8-e418-484f-8bd6-c7f2e154f292'
    $incomingwebhook = '9d5fe92232e244178e464fbe2bc41142/e71f6c21-635a-4639-a6b3-7a2dfe686d3f'
}
if($source -eq 'EPTP'){
    $apitoken = '8OaIJuU0ViOvav3SAsE504Q3XkVxpmPG8Zadq70y'
    $room = 'LoggingTest'
    $webhook = 'b6c861dc-59e5-4b07-a7fb-b5c9ac2c46d6@df02c2f8-e418-484f-8bd6-c7f2e154f292'
    $incomingwebhook = '9d5fe92232e244178e464fbe2bc41142/e71f6c21-635a-4639-a6b3-7a2dfe686d3f'
}

$eventout = @{
LogName = $logname
Message = "Line Number: $line`r`n`r`n" + $message
EventId = $eventid
ComputerName = $computername
Source = $source
EntryType = $entrytype
}

$csvout = @{
eventid = $eventid
computerName = $computername
source = $source
message = "Line Number: $line`r`n`r`n" + $message
logName = $logname
}

$hipchatout = @{
Message = "Line Number: $line " + ' ' +$message
Apitoken = $apitoken
Room = $room
color = $color
}

$msteamsout = @{
Message = "Line Number: $line " + ' ' +$message
webhook = $webhook
incomingwebhook = $incomingwebhook
color = $themecolor
title = $entrytype
}

if(([System.Diagnostics.EventLog]::Exists($logname)) -and ([System.Diagnostics.EventLog]::SourceExists($source)) -eq $true){
        Write-EventLog @eventout
    }
else{
        New-EventLog -LogName $logname -Source $source | out-null
        Write-EventLog @eventout
    }
if($csv){
    try{
    Write-csv @csvout
    Write-Output "Please view logs here: $env:Temp\EventLog-$(get-date -f yyMMdd).csv"
    }
    catch{
    Write-Host $_
        }
    }
    #send to hipchat
    if($hipchat){
    #Register the CloudOps repository for PowerShell modules
    if((get-psrepository -Name CloudOps).name -ne $null){
        if ((Get-Module -Name hipchat).name -ne $null){
            Send-Hipchat @hipchatout
        }
        else{
        Install-Module hipchat -Repository CloudOps -Force
        Send-Hipchat @hipchatout
            }
        }
    else{
    Register-PSRepository -Name CloudOps -SourceLocation https://cloudops-nexus.sdlproducts.com/repository/powershell-modules/ -PublishLocation https://cloudops-nexus.sdlproducts.com/repository/powershell-modules/ -PackageManagementProvider nuget -InstallationPolicy Trusted -ErrorAction SilentlyContinue
    Install-Module hipchat -Repository CloudOps -Force
    Send-Hipchat @hipchatout
        }
    
    }
    if($msteams){
    #Register the CloudOps repository for PowerShell modules
    if((get-psrepository -Name CloudOps).name -ne $null){
        if ((Get-Module -Name MSTeams).name -ne $null){
            Send-MSTeams @msteamsout
        }
        else{
        Install-Module MSTeams -Repository CloudOps -Force
        Send-MSTeams @msteamsout
            }
        }
    else{
    Register-PSRepository -Name CloudOps -SourceLocation https://cloudops-nexus.sdlproducts.com/repository/powershell-modules/ -PublishLocation https://cloudops-nexus.sdlproducts.com/repository/powershell-modules/ -PackageManagementProvider nuget -InstallationPolicy Trusted -ErrorAction SilentlyContinue
    Install-Module MSTeams -Repository CloudOps -Force
    Send-MSTeams @msteamsout
        }
    
    }
}

#write csv file
function Write-csv {
     [CmdletBinding()]
     param(
         [Parameter()]
         [ValidateNotNullOrEmpty()]
         [string]$eventid,
         [Parameter()]
         [ValidateNotNullOrEmpty()]
         [string]$computername,
         [Parameter()]
         [ValidateNotNullOrEmpty()]
         [string]$source,
         [ValidateNotNullOrEmpty()]
         [string]$message,
         [ValidateNotNullOrEmpty()]
         [string]$logname

     )
 
     [pscustomobject]@{
         CreatedTime = (Get-Date -f g)
         Eventid = $eventid
         Computername = $computername
         Source = $source
         Message = $Message
         LogName = $logname
     } | Export-Csv -Path "$env:Temp\EventLog-$(Get-Date -f yyMMdd).csv" -Append -NoTypeInformation -Force
 }

#Line Number
 Function Get-CurrentLine {
    $Myinvocation.ScriptlineNumber
}