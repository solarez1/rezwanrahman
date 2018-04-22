$regionoutput = (Invoke-WebRequest http://169.254.169.254/latest/meta-data/placement/availability-zone).content | where {$_ -match '[a-u]{0,2}-[a-z]{4,9}-[1,2]'} | Out-Null
$region = $Matches[0]
[int64]$a=(Get-WmiObject win32_logicaldisk | select -first 1).freespace / 1024 / 1024 / 1024
[int64]$b=(Get-WmiObject win32_logicaldisk | select -first 1).size /1024 /1024 / 1024
[int32]$c = $b * 0.05
if ($a -lt $c)
{
$value = Write-Output "$c"
}
else
{
$value = Write-Output "$a"
}
$value
$now = get-date -Format U
$d = get-date $now -uformat %Y-%m-%dT%H:%M:00

aws.exe cloudwatch put-metric-data --metric-name FreeDiskSpace --namespace "System/Windows" --dimensions "Installation=FreeDiskSpace" --value $value --timestamp $d --region $region
start-sleep 2
aws.exe cloudwatch put-metric-alarm --alarm-name FreeDiskSpace --metric-name FreeDiskSpace --dimensions "Name=Installation,Value=FreeDiskSpace" --namespace "System/Windows" --statistic Maximum --period 300 --threshold 5 --comparison-operator LessThanThreshold --evaluation-periods 1 --unit None --region $region
