$MFADevice = Get-IAMMFADevice -Username rrahman
$Params = @{
    RoleArn = "arn:aws:iam::016790287891:role/CloudOperationsGlobalCrossAccountAdmin"
    RoleSessionName = "MSTechOps"
    #Region = 'eu-west-1'
    SerialNumber = $MFADevice.SerialNumber
    TokenCode = $(Read-Host "MFA Token")
}
$Role = Use-STSRole @Params

((Get-EC2Instance -Credential $Role.Credentials -Region eu-west-1).instances.instanceid)

try{
get-EC2Instance -Region eu-west-1 -Instance i-5301b1dc -ErrorAction Stop
}
catch{

write-host "Error"
$msg = $_
Write-Host "$msg" -BackgroundColor Red
}