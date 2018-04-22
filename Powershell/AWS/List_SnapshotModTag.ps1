<#Retrieve a list of EBS Snapshots based on specific parameters and also returns the instances they relate to#>
Function List-InstancesbyEBS{
    [CmdletBinding()]
    param(   
        [string]$region,
        [int32]$items,
        [parameter(Mandatory)]
        [string]$wildcard,
        [parameter(Mandatory)]
        [string]$date
)

$filter1 = New-Object Amazon.EC2.Model.Filter
$filter1.Name = 'start-time'
$filter1.Value.Add("*$date*")

$a = Get-EC2Snapshot -filter $filter1 -Credential $Role.Credentials -Region $region | select -last $items | sort StartTime -Descending | 
Select @{Name='SnapshotName'; Expression={($_.Tag |%{ $_.Value}) -join ','}}, SnapshotId, StartTime

$a |?{$_.SnapshotName -like "$wildcard"}| Format-Table -AutoSize

$instances = $a | ?{$_.SnapshotName -like "$wildcard"} | %{$_.snapshotname -match 'i-[0-9a-z]{6,12}' | Out-Null;$matches[0]}

$instances | sort-object | Get-Unique | Format-Table -AutoSize

}

<#Retrieve a list of EBS Snapshots related to an instance id selected earlier and date range#>
Function List-LatestSnapshots{
    [CmdletBinding()]
    param(  
        [parameter(Mandatory)] 
        [string]$instanceid,
        [parameter(Mandatory)]
        [string]$date,
        [parameter(Mandatory)]
        [string]$region
)

$filter1 = New-Object Amazon.EC2.Model.Filter
$filter1.Name="tag:Name"
$filter1.Value="*$instanceid*"

$filter2 = New-Object Amazon.EC2.Model.Filter
$filter2.Name = 'start-time'
$filter2.Value.Add("*$date*")

$a = Get-EC2Snapshot -filter $filter1, $filter2 -Credential $Role.Credentials -Region $region | Select @{Name='SnapshotName'; Expression={($_.Tag |%{ $_.Value}) -join ','}},SnapshotId, StartTime | 
sort StartTime -Descending | Format-Table -AutoSize

$a
}

<#Create a New Volume from the EBS Snapshot#>
Function Create-VolumeFromEBS{
param(
    [parameter(Mandatory)]
    [string]$snapshotid,
    [parameter(Mandatory)]
    [string]$AZ
)

New-EC2Volume -AvailabilityZone $AZ -SnapshotId $snapshotid -Credential $Role.Credentials
}


<#OLD = $a = Get-EC2Snapshot -filter $filter1 -Credential $Role.Credentials -Region $region | Select @{Name='SnapshotName'; Expression={($_.Tag |%{ $_.Value}) -join ','}},SnapshotId, StartTime | 
sort StartTime -Descending | ?{$_.StartTime -gt "$date"}| Format-Table -AutoSize
#>

#get-help Get-EC2Snapshot -Parameter filter

