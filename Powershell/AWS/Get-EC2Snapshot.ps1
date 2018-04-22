#Run AWS Initialize-Defaults first.

$MFADevice = Get-IAMMFADevice -UserName rrahman
$Params = @{
    RoleArn = "arn:aws:iam::416938678484:role/CloudOperationsGlobalCrossAccountAdmin"
    RoleSessionName = "MSTechOps"
    Region = 'eu-west-1'
    SerialNumber = $MFADevice.SerialNumber
    TokenCode = $(Read-Host "MFA Token")
}
$Role = Use-STSRole @Params

$a = ((Get-EC2Snapshot -Credential $Role.Credentials -Region eu-west-1).Tag.Value | select -Last 10 | Sort desc)

$b = ((Get-EC2Snapshot -Credential $Role.Credentials -Region eu-west-1).StartTime | select -last 10)


Get-EC2Snapshot -Credential $Role.Credentials -Region eu-west-1 | select -Last 1 | 
select VolumeId,
@{label="Time"; Expression ={((Get-EC2Snapshot -Credential $Role.Credentials -Region eu-west-1).StartTime | select -last 10)}},
@{label="SnapShot"; Expression={((Get-EC2Snapshot -Credential $Role.Credentials -Region eu-west-1).Tag.Value | select -last 10)}} | Format-Table -AutoSize

Get-EC2Snapshot -Credential $Role.Credentials -Region eu-west-1 |
select VolumeId,
@{label="Time"; Expression ={((Get-EC2Snapshot -Credential $Role.Credentials -Region eu-west-1).StartTime | select -last 10)}}

$a = ((Get-EC2Snapshot -Credential $Role.Credentials -Region eu-west-1) |  select -ExpandProperty Tag | Sort-Object ascending)

foreach($test in $a)
{
    
}

#Retrieve a list of Snapshots

(Get-EC2Snapshot -Credential $Role.Credentials -Region eu-west-1).SnapshotId | select -first 1

#Get tags

    $filter1 = New-Object Amazon.EC2.Model.Filter
    $filter1.Name="tag:aws:autoscaling:groupName"
    $filter1.Value="*"

    Get-EC2Tag -Filter $filter1 -Region eu-west-1 -Credential $Role.Credentials