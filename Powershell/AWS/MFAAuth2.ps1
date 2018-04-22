$MFADevice = Get-IAMMFADevice -Username AWSEBSSnap
$Params = @{
    RoleArn = "arn:aws:iam::016790287891:role/AWSEBSSnap"
    RoleSessionName = "MSTechOps"
    #Region = 'eu-west-1'
    SerialNumber = $MFADevice.SerialNumber
    TokenCode = $(Read-Host "MFA Token")
}
$Role = Use-STSRole @Params  


Get-EC2Instance -Credential $Role.Credentials -Region eu-west-1
