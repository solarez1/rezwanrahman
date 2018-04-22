#Run AWS Initialize-Defaults first.

$MFADevice = Get-IAMMFADevice -UserName rrahman
$Params = @{
    RoleArn = "arn:aws:iam::016790287891:role/CloudOperationsGlobalCrossAccountAdmin"
    RoleSessionName = "MSTechOps"
    Region = 'eu-west-1'
    SerialNumber = $MFADevice.SerialNumber
    TokenCode = $(Read-Host "MFA Token")
}
$Role = Use-STSRole @Params

$a = ((Get-EC2Snapshot -Credential $Role.Credentials -Region eu-west-1).Tag.Value | select -Last 10)

$b = ((Get-EC2Snapshot -Credential $Role.Credentials -Region eu-west-1).StartTime | select -last 10)


Get-EC2Snapshot -Credential $Role.Credentials -Region eu-west-1 | select @{label="Time"; Expression ={((Get-EC2Snapshot -Credential $Role.Credentials -Region eu-west-1).StartTime | select -last 1)}}