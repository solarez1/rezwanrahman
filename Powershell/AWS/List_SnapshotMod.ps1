Function List-LatestSnapshots{
    [CmdletBinding()]
    param(   
        [string]$region,
        [int32]$items,
        [parameter(Mandatory)]$year
)

$filter1 = New-Object Amazon.EC2.Model.Filter
$filter1.Name = 'start-time'
$filter1.Value.Add("*$year*")

<#

$filter2 = New-Object Amazon.EC2.Model.Tag
$filter2.Key = 'Name'
$filter2.Value = 'value'

#>
Get-EC2Snapshot -filter $filter1 -Credential $Role.Credentials -Region $region | select -last $items | sort StartTime -Descending| Select Description, SnapshotId, StartTime | Format-Table -AutoSize

}

#get-help Get-EC2Snapshot -Parameter filter

