$c = (Get-EC2Snapshot -Region us-west-2 -Credential $Role.Credentials -OwnerId 416938678484 | ?{$_.StartTime -lt "$(((Get-Date).Date).AddDays(-60))"})

$d = $c.SnapshotId

foreach($b in $d)
{
    Remove-EC2Snapshot -Region us-west-2 -Credential $Role.Credentials -SnapshotId $b -Force
}