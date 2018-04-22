#set execution policy
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
#import-module
Import-Module 'C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1'
#alt

#Load the AWS Module

$AWSModulePath = "C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1"

If (Test-Path $AWSModulePath)
{
    try {
	    Import-Module $AWSModulePath -ErrorAction STOP
    }
    catch
    {
	    Write-Warning $_.Exception.Message
    }
}
else
{
    Write-Warning "The AWS PowerShell module was not found on this computer."
}

#get-aws-creds
$config = get-content C:\AWS\Creds\AWSCreds.conf
$SuppressSetting = $config[0].Split("=")[1]
$Access = $config[1].Split("=")[1]
$Secret = $config[2].Split("=")[1]
$Region = $config[3].Split("=")[1]

if ($suppressSetting -eq "1")
{

Write-Host "Unauthorised Execution"

}
else
{

$setCreds = Set-AWSCredentials -AccessKey $Access -SecretKey $Secret

}

$DefaultRegion = Set-DefaultAWSRegion -Region $Region

Write-Host "AWS credentials Specified and Default Region is" $Region
