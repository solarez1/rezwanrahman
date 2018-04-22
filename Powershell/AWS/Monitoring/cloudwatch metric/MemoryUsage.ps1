$regionoutput = (Invoke-WebRequest http://169.254.169.254/latest/meta-data/placement/availability-zone).content | where {$_ -match '[a-u]{0,2}-[a-z]{4,9}-[1,2]'} | Out-Null
$region = $Matches[0]
$memoryInfo = gwmi -Query "SELECT TotalVisibleMemorySize, FreePhysicalMemory FROM Win32_OperatingSystem"
$totalVisibleMemorySize = $memoryInfo.TotalVisibleMemorySize
$freePhysicalMemory = $memoryInfo.FreePhysicalMemory
$used = (($totalVisibleMemorySize - $freePhysicalMemory) / 1024/2014)
$now = get-date -Format U
$d = get-date $now -uformat %Y-%m-%dT%H:%M:00
$instance = (Invoke-WebRequest http://169.254.169.254/latest/meta-data/instance-id).content

echo "$d $instance $used" | Out-File c:/chef/cache/usedmemory.out

aws.exe cloudwatch put-metric-data --metric-name MemoryUsedGB --namespace "System/Windows" --dimensions "Installation=MemoryUsage" --value $used --unit "Gigabytes" --timestamp $d --region $region
