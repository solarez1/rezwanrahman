$regionoutput = (Invoke-WebRequest http://169.254.169.254/latest/meta-data/placement/availability-zone).content | where {$_ -match '[a-u]{0,2}-[a-z]{4,9}-[1,2]'} | Out-Null
$region = $Matches[0]
$os = Get-CimInstance win32_operatingsystem
$now = get-date -Format U
$d = get-date $now -uformat %Y-%m-%dT%H:%M:00
$totalavailmemory = (($os | Measure-Object -Sum FreePhysicalMemory | Select-Object -ExpandProperty Sum)/1024/1024)
"Total Available Memory" + $totalavailmemory
$totalsysmemory = (($os | Measure-Object -Sum TotalVisibleMemorySize | Select-Object -ExpandProperty Sum)/1024/1024)
"Total System Memory" + $totalsysmemory
$15pc = $totalsysmemory * 0.15
if ($totalavailmemory -le $15pc)
{
$value = Write-Output $totalavailmemory
}
else
{
$value = Write-Output $totalavailmemory
}

echo "$d $totalavailmemory $totalsysmemory $15pc" | Out-File c:/chef/cache/lowmemory.out

aws.exe cloudwatch put-metric-data --metric-name LowMemoryGB --namespace "System/Windows" --dimensions "Installation=LowMemory" --value $value --unit "Gigabytes" --timestamp $d --region $region

aws.exe cloudwatch put-metric-alarm --alarm-name LowMemoryGB --metric-name LowMemoryGB --dimensions "Name=Installation,Value=LowMemory" --namespace "System/Windows" --statistic Maximum --period 300 --threshold 0.6 --comparison-operator LessThanThreshold --evaluation-periods 1 --unit "Gigabytes" --region $region
