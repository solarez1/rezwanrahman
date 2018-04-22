if ($getfile = Get-WmiObject win32_product | ?{$_.name -like "*adobe*"})
{
$value = Write-Output 1
}
else
{
$value = Write-Output 0
}
$value
$now = get-date -Format U
$d = get-date $now -uformat %Y-%m-%dT%H:%M:00
$filename = ($getfile.name)

echo "$d $filename $value" | Out-File c:/delete/SEPMState.out

aws cloudwatch put-metric-data --metric-name InstallState --namespace "System/Windows" --dimensions "Installation=SEPM" --value $value --timestamp $d --region eu-central-1