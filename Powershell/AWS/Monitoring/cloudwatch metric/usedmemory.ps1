$memoryInfo = gwmi -Query "SELECT TotalVisibleMemorySize, FreePhysicalMemory FROM Win32_OperatingSystem"
$totalVisibleMemorySize = $memoryInfo.TotalVisibleMemorySize
$freePhysicalMemory = $memoryInfo.FreePhysicalMemory
$used = ($totalVisibleMemorySize - $freePhysicalMemory) / 1024
$now = get-date -Format U
$d = get-date $now -uformat %Y-%m-%dT%H:%M:00
$instance = (Invoke-WebRequest http://169.254.169.254/latest/meta-data/instance-id).content

echo "$d $instance $used" | Out-File c:/service/usedmemory.out

aws cloudwatch put-metric-data --metric-name MemoryUsedMB --namespace "System/Windows" --dimensions "InstanceId=$instance" --value $used --unit "Megabytes" --timestamp $d --region eu-central-1