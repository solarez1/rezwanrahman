$ErrorActionPreference = "Stop"

Register-PSRepository -Name CloudOps -SourceLocation https://cloudops-nexus.sdlproducts.com/repository/powershell-modules/ -PublishLocation https://cloudops-nexus.sdlproducts.com/repository/powershell-modules/ -PackageManagementProvider nuget -InstallationPolicy Trusted -ErrorAction SilentlyContinue 
Set-AWSCredentials -AccessKey $env:AWS_ACCESS_KEY_ID -SecretKey $env:AWS_SECRET_ACCESS_KEY

function Set-SDLWebRDSCWAlarms
{
    Param(
        [ValidateScript({ $_ -match '^([1-9]|[1-9][0-9]|[1][0][0])$' })]
        [int]$rdsStoragePercentage=15,
        [ValidateScript({ $_ -match '^([1-9]|[1-9][0-9]|[1][0][0])$' })]        
        [int]$rdsCPUUtilPercentage=80,
        [ValidateScript({ $_ -match '^([1-9]|[1-9][0-9]|[1][0][0])$' })]        
        [int]$rdsReadIOPsPercentage=90,
        [ValidateScript({ $_ -match '^([1-9]|[1-9][0-9]|[1][0][0])$' })]        
        [int]$rdsWriteIOPsPercentage=70
    )

    # Create Dimension Object
    $DimensionObj = New-Object Amazon.CloudWatch.Model.Dimension;
    $DimensionObj.set_Name("DBInstanceIdentifier");

    $rdsStorageLimit = $rdsStoragePercentage / 100
    $rdsReadIOPsLimit = $rdsReadIOPsPercentage /100
    $rdsWriteIOPsLimit = $rdsWriteIOPsPercentage /100

    foreach($awsRegion in (Get-AWSRegion).Region)
    {
        $RDSInstances = Get-RDSDBInstance -Region $awsRegion
        foreach($rdsInstance in $rdsInstances)
        {
            $Matches = ""
            $rdsInstanceARN = $RDSInstance.DBInstanceArn
            $rdsInstanceID = $RDSInstance.DBInstanceIdentifier

            $DimensionObj.set_Value($rdsInstanceID);

            $rdsInstanceTags = Get-RDSTagForResource -ResourceName $rdsInstanceARN -Region $awsRegion
            $rdsStackName = $rdsInstanceTags | Where-Object {$_.Key -eq "aws:cloudformation:stack-name"} | Select-Object -ExpandProperty Value

            $rdsInstanceID -match '(\w{0,})\-(\w{0,})\-?(\w{0,})' | Out-Null
            if($rdsStackName)
            {
                $rdsComponent = $Matches[1].ToUpper()
            }
            else
            {
                $rdsStackName = $rdsInstanceID
                $rdsComponent = $Matches[2]
            }

            $rdsMetricAlarmParams =@{
                AlarmName = ""
                AlarmDescription = ""
                MetricName = ""
                Namespace = "AWS/RDS"
                Dimension = $DimensionObj
                Statistic = ""
                Period = 60
                Threshold = ""
                Unit = ""
                ComparisonOperator = ""
                EvaluationPeriods = ""
                Region = $awsRegion
            }

            #Disk Utilization alarm
            #Value for storage is in bytes so scale threshold appropriately
            $rdsStorageThreshold = ($RDSInstance.AllocatedStorage * $rdsStorageLimit) * (1024*1024*1024)
            $rdsMetricAlarmParams.AlarmName = "$rdsStackName : RDS $rdsComponent : DiskUtilization [$rdsInstanceID]"
            $rdsMetricAlarmParams.AlarmDescription = "Alarm when disk space available for $rdsComponent less than $rdsStoragePercentage%"
            $rdsMetricAlarmParams.MetricName = "FreeStorageSpace"
            $rdsMetricAlarmParams.Namespace = "AWS/RDS"
            $rdsMetricAlarmParams.Statistic = "Average"
            $rdsMetricAlarmParams.Period = "60"
            $rdsMetricAlarmParams.Threshold = $rdsStorageThreshold
            $rdsMetricAlarmParams.Unit = "Bytes"
            $rdsMetricAlarmParams.ComparisonOperator = "LessThanThreshold"
            $rdsMetricAlarmParams.EvaluationPeriods = "1"
            Write-CWMetricAlarm @rdsMetricAlarmParams

            #CPU Utilization alarm
            $rdsMetricAlarmParams.AlarmName = "$rdsStackName : RDS $rdsComponent : CPUUtilization [$rdsInstanceID]"
            $rdsMetricAlarmParams.AlarmDescription = "Alarm when CPU utilization for $rdsComponent greater than $rdsCPUUtilPercentage%"
            $rdsMetricAlarmParams.MetricName = "CPUUtilization"
            $rdsMetricAlarmParams.Namespace = "AWS/RDS"
            $rdsMetricAlarmParams.Statistic = "Average"
            $rdsMetricAlarmParams.Period = "60"
            $rdsMetricAlarmParams.Threshold = $rdsCPUUtilPercentage
            $rdsMetricAlarmParams.Unit = "Percent"
            $rdsMetricAlarmParams.ComparisonOperator = "GreaterThanThreshold"
            $rdsMetricAlarmParams.EvaluationPeriods = "5"
            Write-CWMetricAlarm @rdsMetricAlarmParams

            #Read IOPs alarm
            $rdsReadIOPsThreshold = [int]$rdsInstance.Iops * $rdsReadIOPsLimit
            $rdsMetricAlarmParams.AlarmName = "$rdsStackName : RDS $rdsComponent : ReadIOPS [$rdsInstanceID]"
            $rdsMetricAlarmParams.AlarmDescription = "Alarm when Read IOPS exceeds $rdsReadIOPsPercentage% of provisioned"
            $rdsMetricAlarmParams.MetricName = "ReadIOPS"
            $rdsMetricAlarmParams.Namespace = "AWS/RDS"
            $rdsMetricAlarmParams.Statistic = "Maximum"
            $rdsMetricAlarmParams.Period = "60"
            $rdsMetricAlarmParams.Threshold = $rdsReadIOPsThreshold
            $rdsMetricAlarmParams.Unit = "Count/Second"
            $rdsMetricAlarmParams.ComparisonOperator = "GreaterThanThreshold"
            $rdsMetricAlarmParams.EvaluationPeriods = "5"
            Write-CWMetricAlarm @rdsMetricAlarmParams

            #Write IOPs alarm
            $rdsWriteIOPsThreshold = [int]$rdsInstance.Iops * $rdsWriteIOPsLimit
            $rdsMetricAlarmParams.AlarmName = "$rdsStackName : RDS $rdsComponent : WriteIOPS [$rdsInstanceID]"
            $rdsMetricAlarmParams.AlarmDescription = "Alarm when Write IOPS exceeds $rdsWriteIOPsPercentage% of provisioned"
            $rdsMetricAlarmParams.MetricName = "WriteIOPS"
            $rdsMetricAlarmParams.Namespace = "AWS/RDS"
            $rdsMetricAlarmParams.Statistic = "Maximum"
            $rdsMetricAlarmParams.Period = "60"
            $rdsMetricAlarmParams.Threshold = $rdsWriteIOPsThreshold
            $rdsMetricAlarmParams.Unit = "Count/Second"
            $rdsMetricAlarmParams.ComparisonOperator = "GreaterThanThreshold"
            $rdsMetricAlarmParams.EvaluationPeriods = "5"
            Write-CWMetricAlarm @rdsMetricAlarmParams
        }
        
    #Get a list of all alarms in INSUFFICIENT_DATA state
    $rds_alarms = Get-CWAlarm -Region $awsRegion | ?{$_.StateValue -eq "INSUFFICIENT_DATA" -and $_.namespace -contains "AWS/RDS"}

    #Get a list of all RDS instances (stopped and started)
    $rds_instances = Get-RDSDBInstance -Region $awsRegion

    #Find all alarms for RDS instances that don't exist, and delete them
    foreach($rds in $rds_instances.DBInstanceIdentifier){
        foreach($alarms in $rds_alarms.dimensions.value){
        if($alarms -eq $rds){
            Write-Output "No Alarms to Remove"      
            }
        else{
            Remove-CWAlarm -Region $awsRegion -AlarmName $rds_alarms.AlarmName -Force 
            Write-Output "deleting alarm $($rds_alarms.AlarmName)"
                }
            }
        }
    }
}

$SDLWebRDSCWAlarmsParams = @{
rdsStoragePercentage = $env:StoragePercentage
rdsCPUUtilPercentage = $env:CPUUtilPercentage
rdsReadIOPsPercentage = $env:ReadIOPsPercentage
rdsWriteIOPsPercentage = $env:WriteIOPsPercentage
}
Set-SDLWebRDSCWAlarms @SDLWebRDSCWAlarmsParams