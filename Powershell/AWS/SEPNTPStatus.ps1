#require --version 4.0
<#
 ___ ___ _____ ___
| _ \ _ \_   _/ __|
|  _/   / | || (_ |
|_| |_|_\ |_| \___|
 RegCheckSensor 1.12

 Author:    Stephan Linke
 
 Version History
 ----------------------------
 1.12       [Improved] Removed documentation referenes to RemoteRegistry, which is no longer necessary
 1.1        [Added]    Sensor will now evaluate numerical results
            [Added]    x64 parameter for x64 registry.
            [Improved] documentation
            [Fixed]    Bug where some values couldn't be retrieved
 1.0        Initial Release

#>

<#
.SYNOPSIS
    This sensor will allow you to retrieve registry values from the PRTG server and remote hosts. 
.DESCRIPTION 
    [INSTALLATION]
    Copy the script into your <PRTG Application Directory>/Custom Sensors/EXE directory, as <preferred-script-name>.ps1

    [SENSOR SETUP]
    1. Create a new EXE/Script sensor on the target device
    2. Copy the path of the registry by right clicking the key -> Copy Key Path
    3. Make sure the device has administrative Windows credentials configured
    4. Enter the parameters like this: 
    -ComputerName <Host> -Path "<Path-Of-The-Key>" -ValueName "<Name-Of-The-Value>"
    5. Set the security context to "Use Windows credentials of parent device".

    [SENSOR PARAMETERS]
    -ComputerName: The host you want to query
    -Path: The path where the key is stored 
    -ValueName: The name of the value you want to check
    -MustContain: The result must contain this string, otherwise it will error
    -MustNotContain: The result must not contain this string, otherwise it will error
    -x64: Use this switch if you want to query a x64 registry. 

.EXAMPLE
    PRTG-RegistryKey.ps1 -ComputerName %host -Path "SOFTWARE\Wow6432Node\Paessler\PRTG Network Monitor\Server\Webserver\testkey" -ValueName template
    Description: A very basic example that simply reads a value from the registry. 
    Output: Registry key 'template' holds 'paessler'
.EXAMPLE
    PRTG-RegistryKey.ps1 -ComputerName %host -Path "SOFTWARE\Wow6432Node\Paessler\PRTG Network Monitor\Server\Webserver\testkey" -ValueName template -MustContain "paessler" -MustNotContain "text"
    [Description] Now, just as in the old registry sensor, you can add MustContain and MustNotContain fields:
    [Output] Registry key 'template' holds 'paessler' and matches the 'paessler' pattern.
.EXAMPLE
    PRTG-RegistryKey.ps1 -ComputerName %host -Path "SOFTWARE\Wow6432Node\Paessler\PRTG Network Monitor\Server\Webserver\testkey" -ValueName template -MustContain "paessler" -MustNotContain "text"
    [Description] Lets see what happens when a key holds a value that contains  the mustnotcontain text:
    [Output] System Error: Registry key 'template' holds 'paessler-text', which matches the pattern 'text.'
.EXAMPLE
    PRTG-RegistryKey.ps1 -ComputerName %host -Path "SOFTWARE\Wow6432Node\Paessler\PRTG Network Monitor\Server\Webserver\testkey" -ValueName template -MustContain '\d{2}.\d{2}.\d{4}.'
    [Description] Of course, you can use regular expressions for both mustcontain and mustnotcontain:
    [Output] System Error: Registry key 'template' holds '08.02.2014', which matches the pattern '\d{2}.\d{2}.\d{4}.'
.LINK
   - Paessler KB Thread: https://kb.paessler.com/en/topic/68254  
.NOTES
    - Execute Set-ExecutionPolicy RemoteSigned in a elevated 32bit PowerShell if 
      you don't have any custom script sensors yet.
    - Make sure the device has administrative Windows credentials configured
#>

param(
    [string]$ComputerName         = "$Env:Computername",
    [string]$Path                 = "HKEY_LOCAL_MACHINE\SOFTWARE\Symantec\Symantec Endpoint Protection\SMC",
    [string]$ValueName            = "smc_engine_status",
    [string]$MustContain          = "0",
    [string]$MustNotContain       = "1",
    [switch]$AllowEmptyResults    = $FALSE,
    [switch]$x64                  = $TRUE
)

[switch]$verbose = $False;

#region function library

## show messages, nicely formatted.
function This-ShowMessage([string]$type,$message){
    if($verbose){
        Write-Host ("[{0}] [" -f (Get-Date)) -NoNewline;
        switch ($type){
            "success" { Write-Host "success" -ForegroundColor Green -NoNewline;}
            "info"    { Write-Host "info"    -ForegroundColor DarkCyan -NoNewline; }
            "warning" { Write-Host "warning" -ForegroundColor DarkYellow -NoNewline; }
            "error"   { Write-Host "error"   -ForegroundColor Red -NoNewline; }
            default   { Write-Host $type -NoNewline; }
        }
        Write-Host ("]`t{0}" -f $message)
    }
}

## this will  connect to the registry and retrieve the values
function This-GetRegistryValue(){

    $Result = (This-PrepareRegObject -Path $Path)
    This-ShowMessage -type info -message "Checking Host $($ComputerName)"
    This-ShowMessage -type info -message "Root: $($Result.Root)";
	This-ShowMessage -type info -message "Registry path: $($Result.Path)";

    $HostDetails = ([System.Net.Dns]::GetHostByName(($env:computerName)))

    if($x64)
    { $arch = [Microsoft.Win32.RegistryView]::Registry64 }
    else 
    { $arch = [Microsoft.Win32.RegistryView]::Registry32 }

    ## try to establish the remote registry connection.
    try
    {
        if(($HostDetails.AddressList -contains $ComputerName) -or ($HostDetails.HostName -match $ComputerName) -or $ComputerName -eq "127.0.0.1")
        { $Reg = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine , $arch ) }
        else
        { $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Result.Root,$ComputerName, $arch) }

        This-ShowMessage "info" "Registry connection established."
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        This-ShowMessage "error" "Couldn't connect to remote registry. The error was: $($ErrorMessage)"
        Write-Host "0:Couldn't connect to remote registry. The error was: $($ErrorMessage)";
        This-Quit 2;
    }

    $RegSubKey = $Reg.OpenSubKey($Result.Path)
    $Result.Add("Value", $RegSubKey.GetValue($Result.ValueName))

    if($Result.Value -eq -1){
      This-ShowMessage "error" "Can't find the defined registry key $($Result.ValueName) in the path $($Result.Path)"
      Write-Host ([string]::Format("0:Can't find the defined registry key {0} in the path {1}",$Result.ValueName,$Result.Path)); This-Quit 2;
    }

    return $Result;

}

## this will change the path so that we can check it with PowerShell
function This-PrepareRegObject($Path){

    $Result = @{}
    $root = ($path -split "\\")

    switch($root[0]){

        "HKEY_CLASSES_ROOT"   { $Result.Add("Root",[Microsoft.Win32.RegistryHive]::ClassesRoot)   }
        "HKEY_CURRENT_USER"   { $Result.Add("Root",[Microsoft.Win32.RegistryHive]::CurrentUser)   }
        "HKEY_LOCAL_MACHINE"  { $Result.Add("Root",[Microsoft.Win32.RegistryHive]::LocalMachine)  }
        "HKEY_USERS"          { $Result.Add("Root",[Microsoft.Win32.RegistryHive]::Users)         }
        "HKEY_CURRENT_CONFIG" { $Result.Add("Root",[Microsoft.Win32.RegistryHive]::CurrentConfig) }
    }

    $Result.Add("Path",$root[1..($root.Length-1)] -join "\")
    $Result.Add("ValueName",$ValueName)

    return $Result;
}

## this function will evaluate the registry value
function This-CheckRegistryValue(){

    $Result = This-GetRegistryValue;

    #region result evaluation

    # this will be the default value, if the sensor simply checks the registry key.
    $Result.Add("PRTGResultMessage", [string]::Format("Registry key '{0}' holds '{1}'",$Result.ValueName,$Result.Value));

    # if the pattern matches, the sensor will be up
    If(($MustContain) -and (($Result.Value | Select-String -Pattern $MustContain)))
    { $Result.PRTGResultMessage = [string]::Format("Registry key '{0}' holds '{1}' and matches the pattern '{2}.'",$Result.ValueName,$Result.Value,$MustContain); $exitCode = 0; }

    # if the mustcontain variable is set, but nothing is found, the sensor will go down
    elseif(($MustContain) -and (!($Result.Value | Select-String -Pattern $MustContain)))
    { $Result.PRTGResultMessage = [string]::Format("Registry key '{0}' holds '{1}', but the search string '{2}' wasn't found.",$Result.ValueName,$Result.Value,$MustContain); $exitCode = 2; }

    ## if the mustnotcontain variable is set and matches, the sensor will go down
    If(($MustNotContain) -and ($Result.Value | Select-String -Pattern $MustNotContain))
    { $Result.PRTGResultMessage = [string]::Format("Registry key '{0}' holds '{1}', which matches the pattern '{2}.'",$Result.ValueName,$Result.Value,$MustNotContain); $exitCode = 2}

    # if the EmptyAllowed switch is set, this will allow empty values and not let the sensor error
    if($Result.Value.Length -eq 0 -and $AllowEmptyResults)
    { $Result.PRTGResultMessage = [string]::Format("Registry key {0} not set.",$Result.ValueName); $Result.Value = 0; $exitCode = 0}
    elseif($Result.Value.Length -eq 0 -and (!($AllowEmptyResults)))
    { $Result.PRTGResultMessage = [string]::Format("Registry key not set. If it's set in registry, please add -x64 to the parameters.",$Result.ValueName); $Result.Value = 0; $exitCode = 1} 


    try
    { if([int]$Result.Value -is [int]){  Write-Host ([string]::Format("{0}:{1}",$Result.Value, $Result.PRTGResultMessage)); } }
    catch
    { Write-Host ([string]::Format("0:{0}",$Result.PRTGResultMessage)); }


    This-Quit $exitCode;

    #endregion

    This-Quit $exitCode;

}

function This-Quit([int]$exitCode){
    if(!($verbose)){ exit $exitCode }
}

#endregion

This-CheckRegistryValue;