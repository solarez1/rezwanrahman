$awsdefaults = @{
        Region = $region
        Credential = $role.Credentials
        ErrorAction = 'Stop'
    }
#Get a list of all alarms in INSUFFICIENT_DATA status for RDS
$rds_alarms = Get-CWAlarm @awsdefaults | ?{$_.StateValue -eq "INSUFFICIENT_DATA" -and $_.namespace -contains "AWS/RDS"}

#Get a list of all RDS instances (stopped and started)
$rds_instances = Get-RDSDBInstance @awsdefaults

#Compare Arrays
$arrayalarms = $rds_alarms.dimensions.value | Where-Object {$rds_instances.DBInstanceIdentifier -notcontains $_ }

#Find all alarms for RDS instances that don't exist, and delete them
    foreach($alarms in $arrayalarms){   
        Remove-CWAlarm @awsdefaults -AlarmName $rds_alarms.AlarmName -Force        
        }       
    
   Write-Output "deleting alarm(s) $($rds_alarms.AlarmName)"

