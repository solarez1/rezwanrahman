
$hash = @{}

$bucket = (Get-CTTrail -Name RezTrail -Credential $Role.Credentials -Region eu-west-1).S3BucketName

$date = '2016/06/10'
    $filter1 = New-Object Amazon.EC2.Model.Filter
    $filter1.Name = 'start-time'
    $filter1.Value.Add("*$date*")

new-item $env:TEMP\RezTrailLogs -ItemType directory -Force

#$a = Get-S3Bucket -BucketName $bucket -Region eu-west-1 -Credential $Role.Credentials
$b = Get-S3Object -BucketName $bucket -Region eu-west-1 -Credential $Role.Credentials | ? {$_.LastModified -gt (get-date $date).AddDays(-1)} | Sort-Object LastModified -Descending | select -first 20
foreach($n in $b)
{
$hash = Read-S3Object -BucketName $bucket -Region eu-west-1 -Credential $Role.Credentials -Key $n.Key -File $env:TEMP\reztrail$((get-date).Ticks).zip
Move-item -Path $hash.FullName -Destination "$env:TEMP\RezTrailLogs" -Force
write-output $hash
}

Remove-Item $env:TEMP\RezTrailLogs -Force -Recurse