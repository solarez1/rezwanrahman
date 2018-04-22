#Get Instance by ID (with an expanded list)

$a = Get-EC2Instance
$a.Instances

#Get AMI based on Windows platform without SQL

Get-EC2Image -Region us-west-2 | where {$_.Name -like "Windows_Server-2012-R2_RTM-English-64Bit-Core*"}| select imageid, name | Format-Table -AutoSize

#number of filtered images

(Get-EC2Image | where {$_.Platform -like "wind*" -and $_.Architecture -eq "x86_64" -and $_.Name -like "Windows_Server-2012-R2_RTM-English*" -and $_.Name -like "*core*"} ).count

#Select the latest AMI image which is usually the first in the list

$a = (Get-EC2Image | where {$_.Platform -like "wind*" -and $_.Architecture -eq "x86_64" -and $_.Name -like "Windows_Server-2012-R2_RTM-English*" -and $_.Name -like "*base*"} )
$b = $a[0]
$c = $b | select imageid
$c

#get all regions

$a = Get-AWSRegion


#foreach region get image by name

foreach($region in $a.region)
{

$b = Get-EC2ImageByName -name Windows_2012_BASE -Region $region | select name, imageid, @{label="Region"; Expression ={$region}}  | ConvertTo-Json
$c = Get-EC2ImageByName -Name Windows_2012_SQL_SERVER_STANDARD_2014 -Region $region| select name, imageid, @{label="Region"; Expression ={$region}} |  ConvertTo-Json
$d = Get-EC2ImageByName -name Windows_Server-2012-R2_RTM-English-64Bit-Core* -Region $region | select name, imageid, @{label="Region"; Expression ={$region}} -first 1 | ConvertTo-Json

$b | Add-Content C:\aws\WindowsBase.json -Force
$c | Add-Content C:\aws\SQLImages.json -Force
$d | Add-Content C:\aws\WindowsCore.json -Force
}


#Alternative

$d = Get-EC2ImageByName Windows_2012_BASE | select name, imageid | Out-file C:\aws\BaseImageID.txt
$e = Get-EC2ImageByName -Name Windows_2012_SQL_SERVER_STANDARD_2014 | select name, imageid | out-file C:\aws\SQLImageID.txt

#convert to JSON

$e = Get-EC2ImageByName Windows_2012_BASE | select name, imageid | convertto-json | out-file C:\aws\BaseImageID.txt
$f = Get-EC2ImageByName -Name Windows_2012_SQL_SERVER_STANDARD_2014 | select name, imageid | ConvertTo-Json | out-file C:\aws\SQLImageID.txt

#New-Instance

New-EC2Instance -ImageId $c -MinCount 1 -MaxCount 1 -KeyName sdl-web-rez -SecurityGroups sdl-web-rez-cm-db-CMDBServerSecurityGroup-BJ5VZEMEHOAP -InstanceType t1.micro

<#Result
Architecture        : x86_64
BlockDeviceMappings : {/dev/sda1, xvdca, xvdcb, xvdcc...}
CreationDate        : 2015-10-23T00:28:23.000Z
Description         : Microsoft Windows Server 2012 R2 RTM 64-bit Locale English AMI provided by Amazon
Hypervisor          : xen
ImageId             : ami-2fcbf458
ImageLocation       : amazon/Windows_Server-2012-R2_RTM-English-64Bit-Base-2015.10.26
ImageOwnerAlias     : amazon
ImageType           : machine
KernelId            : 
Name                : Windows_Server-2012-R2_RTM-English-64Bit-Base-2015.10.26
OwnerId             : 801119661308
Platform            : Windows
ProductCodes        : {}
Public              : True
RamdiskId           : 
RootDeviceName      : /dev/sda1
RootDeviceType      : ebs
SriovNetSupport     : simple
State               : available
StateReason         : 
Tags                : {}
VirtualizationType  : hvm #>




 PS C:\>(Get-EC2Instance -Filter @{ Name="tag:Name"; Value="*DEV"}).Instances | Start-EC2Instance

 Get-EC2Instance -Filter @{Name="key"; Value="$a[7]"}
 
 
 $a = new-object Amazon.EC2.Model.Filter
 $a.Name = "KeyName"
 $a.value = "sdl-web-rez"

 Get-EC2Instance -Filter @($filter1).instances | where {$_.Instances -like "*rez*"}
