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
   General notes
.FUNCTIONALITY
   The functionality that best describes this cmdlet
.AUTHOR
   Rezwan Rahman - Automation Team Lead
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
[ValidateNotNullOrEmpty()]
[ValidateScript({If ($_ -match '[a-zA-Z0-9" "]{10,}') {
            $True
        } Else {
            Throw "Please make sure your message is longer than 10 characters!"
        }})] 
[string]$message,
[ValidateNotNullOrEmpty()]
[string]$eventid=10000,
[string]$apitoken = 'default',
[string]$room = 'LoggingTest',
[switch]$csv,
[switch]$hipchat,
[Parameter(ParameterSetName='warning')]
[switch]$warning,
[Parameter(ParameterSetName='error')]
[switch]$error
)

$message = $message + "`r`n`r`nScript: $($MyInvocation.MyCommand.ModuleName)" + "`r`n`r`nOn Machine: $env:computername" + "`r`n`r`nOwned By: $source"

if($warning){
$color = 'yellow'
}
if($error){
$color = 'red'
}

if($source -eq 'Database'){
    $apitoken = 'secret'
    $room = 'Zabbix Project'
}
if($source -eq 'Automation'){
    $apitoken = 'secret'
    $room = 'LoggingTest'
}

$eventout = @{
LogName = $logname
Message = $message
EventId = $eventid
ComputerName = $computername
Source = $source
EntryType = 'Error'
}

$csvout = @{
eventid = $eventid
computerName = $computername
source = $source
message = $message
logName = $logname
}

$hipchatout = @{
Message = $message
Apitoken = $apitoken
Room = $room
color = $color
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
    Register-PSRepository -Name CloudOps -SourceLocation secreturl -PublishLocation secreturl -PackageManagementProvider nuget -InstallationPolicy Trusted -ErrorAction SilentlyContinue
    Install-Module hipchat -Repository CloudOps -Force
    Send-Hipchat @hipchatout
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
         ScriptName = $MyInvocation.MyCommand.Name
     } | Export-Csv -Path "$env:Temp\EventLog-$(Get-Date -f yyMMdd).csv" -Append -NoTypeInformation -Force
 }
