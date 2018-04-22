$MFADevice = Get-IAMMFADevice -Username rrahman
$Params = @{
    RoleArn = "arn:aws:iam::529170482687:role/CloudOperationsGlobalCrossAccountAdmin"
    RoleSessionName = "MSTechOps"
    #Region = 'eu-west-1'
    SerialNumber = $MFADevice.SerialNumber
    TokenCode = $(Read-Host "MFA Token")
}
$Role = Use-STSRole @Params

(Get-EC2Instance -Credential $Role.Credentials -Region eu-west-1).instances.instanceid