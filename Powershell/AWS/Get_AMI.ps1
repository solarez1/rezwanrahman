$a = Get-AWSRegion

#Create directory if it does not exist

$testpath = Test-Path C:\AWS\AMI

if($testpath -ne "true")
{
new-Item -ItemType directory -Path C:\AWS\AMI
}
Else 
{
Write-Host "Folder already Exists!"
}

#foreach region get image by name and save it in the directory created earlier

foreach($region in $a.region)
{

$b = Get-EC2ImageByName -name Windows_2012_BASE -Region $region | select name, imageid, @{label="Region"; Expression ={$region}}  | ConvertTo-Json
$c = Get-EC2ImageByName -Name Windows_2012_SQL_SERVER_STANDARD_2014 -Region $region| select name, imageid, @{label="Region"; Expression ={$region}} |  ConvertTo-Json
$d = Get-EC2ImageByName -name Windows_Server-2012-R2_RTM-English-64Bit-Core* -Region $region | select name, imageid, @{label="Region"; Expression ={$region}} -first 1 | ConvertTo-Json

$b | Add-Content C:\AWS\AMI\WindowsBase.json -Force
$c | Add-Content C:\AWS\AMI\SQLImages.json -Force
$d | Add-Content C:\AWS\AMI\WindowsCore.json -Force
}
Write-Host "Files have been written here c:\AWS\AMI" -BackgroundColor Green