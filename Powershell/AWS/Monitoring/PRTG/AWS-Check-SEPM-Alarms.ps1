[CmdletBinding()]
Param(
   [parameter(Mandatory=$true)]
   [string]$AwsAccessKey,
   
   [parameter(Mandatory=$true)]
   [string]$AwsSecretKey,
   
   [parameter(Mandatory=$true)]
   [string]$CfnStackName,
   
   [parameter(Mandatory=$false)]
   [ValidateSet("EUWest1")]
   [string]$AwsRegion = "EUWest1"
)

$ErrorActionPreference = "Stop"

[System.Reflection.Assembly]::LoadFile($(Join-Path -Path $(Split-Path -Path $MyInvocation.MyCommand.Definition -Parent) -ChildPath "AWSSDK.dll")) | Out-Null;

# Set the AWS Access Key and Secret Key for authentication using the .NET SDK
[System.Configuration.ConfigurationManager]::AppSettings["AWSAccessKey"] = $AwsAccessKey;
[System.Configuration.ConfigurationManager]::AppSettings["AWSSecretKey"] = $AwsSecretKey;

# Create CloudWatchClient Object
$CloudWatchClient = New-Object -TypeName Amazon.CloudWatch.AmazonCloudWatchClient -ArgumentList @([Amazon.RegionEndpoint]::$AwsRegion);

# Create DescribeAlarmsRequest Object
$DescribeAlarmsRequest = New-Object Amazon.CloudWatch.Model.DescribeAlarmsRequest;
$DescribeAlarmsRequest.AlarmNamePrefix = $($CfnStackName);

# Determine How Many Alarms Are In An 'ALARM' or 'INSUFFICIENT' State
$StackAlarmsObj = $CloudWatchClient.DescribeAlarms($DescribeAlarmsRequest).MetricAlarms;
[int]$AlarmsALARM = $($StackAlarmsObj | ?{$_.StateValue -Eq 'ALARM'}).Count;
[int]$AlarmsINSUFFICIENT = $($StackAlarmsObj | ?{$_.StateValue -Eq 'INSUFFICIENT_DATA'}).Count;
[int]$AlarmsOK = $($StackAlarmsObj | ?{$_.StateValue -Eq 'OK'}).Count;
[int]$AlarmsTotal = $StackAlarmsObj.Count;

# Handle The Data & Determine What Status & Message To Return To PRTG
if($AlarmsALARM -Gt 0 -And $AlarmsINSUFFICIENT -Eq 0){
    $PrtgReturnText = "There are $AlarmsALARM Alarms For $CfnStackName in an ALARM State in $AwsRegion - Please check & resolve via the AWS CloudWatch Dashboard!";
}elseif ($AlarmsALARM -Gt 0 -And $AlarmsINSUFFICIENT -Gt 0 -And $TotalOutOfServiceCount -Gt 0){
    $PrtgReturnText = "There are $AlarmsINSUFFICIENT Alarms For $CfnStackName in an INSUFFICIENT_DATA State and $AlarmsALARM Alarms in an ALARM State and $TotalOutOfServiceCount marked as OutOfService in $AwsRegion - Please check & resolve via the AWS CloudWatch Dashboard!";
}elseif ($AlarmsALARM -Eq 0 -And $AlarmsINSUFFICIENT -Gt 0 -And $TotalOutOfServiceCount -Eq 0){
    $PrtgReturnText = "There are $AlarmsINSUFFICIENT Alarms For $CfnStackName in an INSUFFICIENT_DATA State in $AwsRegion - Please check & resolve via the AWS CloudWatch Dashboard!";
}elseif ($AlarmsALARM -Eq 0 -And $AlarmsINSUFFICIENT -Gt 0 -And $TotalOutOfServiceCount -Gt 0){
    $PrtgReturnText = "There are $AlarmsINSUFFICIENT Alarms For $CfnStackName in an INSUFFICIENT_DATA State and $TotalOutOfServiceCount marked as OutOfService in $AwsRegion - Please check & resolve via the AWS CloudWatch Dashboard!";
}elseif ($AlarmsOK -Eq $AlarmsTotal -And $AlarmsTotal -Gt 0 -And $TotalOutOfServiceCount -Gt 0){
    $PrtgReturnText = "All Alarms For $CfnStackName OK but $TotalOutOfServiceCount marked as OutOfService in $AwsRegion ";
}elseif ($AlarmsOK -Eq $AlarmsTotal -And $AlarmsTotal -Gt 0 -And $TotalOutOfServiceCount -Eq 0){
    $PrtgReturnText = "All Alarms For $CfnStackName OK & all Instances marked as InService in $AwsRegion ";
}else{
    $PrtgReturnText = "No Alarms were found in CloudWatch For $CfnStackName in $AwsRegion - Please check & resolve via the AWS CloudWatch Dashboard!";
}

# Return Channels To PRTG As JSON
$Result = @{
    prtg = @{
        result = @(
            @{channel = 'ALARM';`
                value = $AlarmsALARM;
            },
            @{channel = 'INSUFFICIENT_DATA';`
                value = $AlarmsINSUFFICIENT
            },
            @{channel = 'OK';`
                value = $AlarmsOK;
            },
            @{channel = 'Total Alarms';`
                value = $AlarmsTotal;
            }			
        );
        text = $PrtgReturnText;
    }
}
Write-Output $($Result | ConvertTo-Json -Depth 50);