Function Copy-RDSDB{
param(
$restoreregion,
$originregion
)

$a = Get-RDSDBSnapshot -Region $originregion -Credential $Role.Credentials | Sort-Object SnapshotCreateTime | select -first 1

Copy-RDSDBSnapshot -Credential $Role.Credentials -Region $restoreregion -SourceDBSnapshotIdentifier $a.DBSnapshotArn -TargetDBSnapshotIdentifier $("RDSTestRestore-$($a.DBSnapshotIdentifier)-$((get-date).ticks)")

}
