#get-aws-creds
$config = get-content C:\AWS\Creds\AWSCreds.conf
$SuppressSetting = $config[0].Split("=")[1]
$Access = $config[1].Split("=")[1]
$Secret = $config[2].Split("=")[1]
$Region = $config[3].Split("=")[1]
$Arn = $config[4].Split("=")[1]
$MFADevice = Get-IAMMFADevice
$TokenCode = $(Read-Host "MFA Token")

if ($suppressSetting -eq "1")
{

Write-Host "Unauthorised Execution"

}
else
{

$creds = New-AWSCredentials -AccessKey $Access -SecretKey $Secret

}

$DefaultRegion = Set-DefaultAWSRegion -Region $Region

$role = Use-STSRole -RoleArn $Arn -DurationSeconds 3600 -RoleSessionName MSTechOps -Credential $creds -TokenCode $TokenCode -SerialNumber $MFADevice.SerialNumber
 
$newcreds = New-AWSCredentials -AccessKey $role.Credentials.AccessKeyId -SecretKey $role.Credentials.SecretAccessKey -SessionToken $role.Credentials.SessionToken

Write-Host "AWS credentials Specified and Default Region is" $Region "using Token" $TokenCode