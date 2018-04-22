Get-S3Object -BucketName ektinstall | Out-File C:\AWS\AWS_Test_Scripts\s3.txt

$Response = (Use-STSRole -Region us-west-2 -RoleArn arn:aws:iam::436437695588:role/CloudOperationsGlobalCrossAccountMSTechOps -RoleSessionName 'CMDB').Credentials
$Credentials = New-AWSCredentials -AccessKey $Response.AccessKeyId -SecretKey $Response.SecretAccessKey -SessionToken $Response.SessionToken

$s3 = Read-Host "Enter a Bucket Name"
$reg = Read-Host "Enter region"

New-S3Bucket -BucketName $s3 -Region $reg

$file = Read-Host "Specify full file path and file name"
$s3key = Read-Host "Provide a unique Key Value"
$Region = Read-Host "Specify Region"

Write-S3Object -BucketName $s3 -Key $s3key -File $file -Region $reg


Get-S3Bucket | ?{$_.BucketName -like "*rez*"}  