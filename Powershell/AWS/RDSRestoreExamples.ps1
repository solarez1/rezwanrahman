get-ec2instance -Region eu-west-1 -Credential $Role.Credentials | ? {$_.Instances -eq "{RezTestRDSKey}"} | select Instances

((get-ec2instance -Region eu-west-1 -Credential $Role.Credentials) | ? {$_.Instances.Keyname -like "RezTestRDSKey"}).Instances.instanceid

$date = "03-04-2016"
Get-RDSDBSnapshot -Region eu-west-1 -Credential $Role.Credentials | ? {$_.SnapshotCreateTime -gt (get-date $date -Hour 23 -Minute 0 -Second 00).AddDays(-1) -and $_.SnapshotCreateTime -lt (get-date $date -Hour 0 -Minute 0 -Second 00).AddDays(+1)}

Restore-RDSDBInstanceFromDBSnapshot -Region eu-west-1 -Credential $Role.Credentials -AvailabilityZone eu-west-1a -DBInstanceIdentifier rez-testrds -DBSnapshotIdentifier rds:dba-2eff71-2016-04-03-00-16 -DBSubnetGroupName default-vpc-95342ef0