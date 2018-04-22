#
# Cookbook Name:: install-sepm
# Recipe:: sep-management
#
# Copyright 2016, SDL Plc
#
# All rights reserved - Do Not Redistribute
#
# Rezwan Rahman (rrahman@sdl.com) : November 2016
#
# Installs managed SEP Management Server on Windows or Linux from MSI bundle

# Download The ZIP File 
sepZipCacheFilePath = File.join(Chef::Config[:file_cache_path], 'sepm.zip')
remote_file sepZipCacheFilePath do
  source 'https://s3-eu-west-1.amazonaws.com/symantec-ep-management/sepm.zip'
  action :create
  not_if {File.exist?('C:\chef\cache\sepm\setup.ini')}
end

# Extract The ZIP File
sepExtractCacheFilePath = File.join(Chef::Config[:file_cache_path], 'sepm')
windows_zipfile sepExtractCacheFilePath do
  source sepZipCacheFilePath
  action :unzip
  overwrite true
  not_if {File.exist?('C:\chef\cache\sepm\setup.ini')}
end

#remote free disk monitoring file
remote_file '/chef/MonScripts/FreeDiskSpace.ps1' do
  source 'https://stash.sdl.com/projects/CS/repos/aws-infrastructure/raw/CloudFormation/AWS%20SEPM%20Infrastructure/Monitoring/FreeDiskSpace.ps1?raw'
  action :nothing
end

http_request 'HEAD https://stash.sdl.com/projects/CS/repos/aws-infrastructure/raw/CloudFormation/AWS%20SEPM%20Infrastructure/Monitoring/FreeDiskSpace.ps1?raw' do
  message ''
  url 'https://stash.sdl.com/projects/CS/repos/aws-infrastructure/raw/CloudFormation/AWS%20SEPM%20Infrastructure/Monitoring/FreeDiskSpace.ps1?raw'
  action :head
  if File.exist?('/chef/MonScripts/FreeDiskSpace.ps1')
    headers 'If-Modified-Since' => File.mtime('/chef/MonScripts/FreeDiskSpace.ps1').httpdate
  end
  notifies :create, 'remote_file[/chef/MonScripts/FreeDiskSpace.ps1]', :immediately
end

#remote low memory monitoring file
remote_file '/chef/MonScripts/LowMemoryUsage.ps1' do
  source 'https://stash.sdl.com/projects/CS/repos/aws-infrastructure/raw/CloudFormation/AWS%20SEPM%20Infrastructure/Monitoring/LowMemoryUsage.ps1?raw'
  action :nothing
end

http_request 'HEAD https://stash.sdl.com/projects/CS/repos/aws-infrastructure/raw/CloudFormation/AWS%20SEPM%20Infrastructure/Monitoring/LowMemoryUsage.ps1?raw' do
  message ''
  url 'https://stash.sdl.com/projects/CS/repos/aws-infrastructure/raw/CloudFormation/AWS%20SEPM%20Infrastructure/Monitoring/LowMemoryUsage.ps1?raw'
  action :head
  if File.exist?('/chef/MonScripts/LowMemoryUsage.ps1')
    headers 'If-Modified-Since' => File.mtime('/chef/MonScripts/LowMemoryUsage.ps1').httpdate
  end
  notifies :create, 'remote_file[/chef/MonScripts/LowMemoryUsage.ps1]', :immediately
end

#remote memory monitoring file
remote_file '/chef/MonScripts/MemoryUsage.ps1' do
  source 'https://stash.sdl.com/projects/CS/repos/aws-infrastructure/raw/CloudFormation/AWS%20SEPM%20Infrastructure/Monitoring/MemoryUsage.ps1?raw'
  action :nothing
end

http_request 'HEAD https://stash.sdl.com/projects/CS/repos/aws-infrastructure/raw/CloudFormation/AWS%20SEPM%20Infrastructure/Monitoring/MemoryUsage.ps1?raw' do
  message ''
  url 'https://stash.sdl.com/projects/CS/repos/aws-infrastructure/raw/CloudFormation/AWS%20SEPM%20Infrastructure/Monitoring/MemoryUsage.ps1?raw'
  action :head
  if File.exist?('/chef/MonScripts/MemoryUsage.ps1')
    headers 'If-Modified-Since' => File.mtime('/chef/MonScripts/MemoryUsage.ps1').httpdate
  end
  notifies :create, 'remote_file[/chef/MonScripts/MemoryUsage.ps1]', :immediately
end

#Powershell for custom CW metrics and alarms
region = (node['ec2']['placement_availability_zone']).sub(/(.$)/,'')
powershell_script 'SEPM-InstallState' do
guard_interpreter :powershell_script
code 'if ($getfile = Get-WmiObject win32_product | ?{$_.name -like "*Symantec*"})
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
$regionoutput = (Invoke-WebRequest http://169.254.169.254/latest/meta-data/placement/availability-zone -Usebasicparsing).content | where {$_ -match "[a-u]{0,2}-[a-z]{4,9}-[1,2]"} | Out-Null
$region = $Matches[0]

echo "$d $filename $value" | Out-File c:/chef/cache/SEPMState.out

$command = @\'
cmd.exe /C "C:\\Program Files\\Amazon\\AWSCLI\\aws.exe" cloudwatch put-metric-data --metric-name SEPMState --namespace "System/Windows" --dimensions "Installation=SEPManage" --value $value --timestamp $d --region $region
\'@

$command2 = @\'
cmd.exe /C "C:\\Program Files\\Amazon\\AWSCLI\\aws.exe" cloudwatch put-metric-alarm --alarm-name SEPMState --metric-name SEPMState --dimensions "Name=Installation,Value=SEPManage" --namespace "System/Windows" --statistic Maximum --period 300 --threshold 1 --comparison-operator LessThanThreshold --evaluation-periods 1 --unit None --region $region
\'@

Invoke-Expression -Command:$command
start-sleep 2
Invoke-Expression -Command:$command2'
end

powershell_script 'SEPM-LowDiskSpace' do
guard_interpreter :powershell_script
code "c:/chef/MonScripts/FreeDiskSpace.ps1"
end

powershell_script 'SEPM-MemoryUsage' do
guard_interpreter :powershell_script
code "c:/chef/MonScripts/MemoryUsage.ps1"
end

powershell_script 'SEPM-LowMemory' do
guard_interpreter :powershell_script
code "c:/chef/MonScripts/LowMemoryUsage.ps1"
end

powershell_script 'SEPM-CPUAlarm' do
guard_interpreter :powershell_script
code '$instance = (Invoke-WebRequest http://169.254.169.254/latest/meta-data/instance-id -Usebasicparsing).content
$regionoutput = (Invoke-WebRequest http://169.254.169.254/latest/meta-data/placement/availability-zone -Usebasicparsing).content | where {$_ -match "[a-u]{0,2}-[a-z]{4,9}-[1,2]"} | Out-Null
$region = $Matches[0]
$asgroupname = (Get-ASAutoScalingGroup | ?{$_.AutoScalingGroupName -like "*SEPMGroup*"}).AutoScalingGroupName
$command = @\'
cmd.exe /C "C:\\Program Files\\Amazon\\AWSCLI\\aws.exe" cloudwatch put-metric-alarm --alarm-name HighCPU --metric-name CPUUtilization --dimensions "Name=AutoScalingGroupName,Value=$asgroupname" --namespace "AWS/EC2" --statistic Average --period 300 --threshold 70 --comparison-operator GreaterThanThreshold --evaluation-periods 2 --unit "Percent" --region $region
\'@
Invoke-Expression -Command:$command'
end

#Powershell for custom CW metrics and alarms
region = (node['ec2']['placement_availability_zone']).sub(/(.$)/,'')
powershell_script 'SEPM-InstallServices' do
guard_interpreter :powershell_script
code '$a = (gsv | ?{$_.Name -like "*sem*"})
$value = ($a.status -eq "running").count
Write-Output $value
$regionoutput = (Invoke-WebRequest http://169.254.169.254/latest/meta-data/placement/availability-zone -Usebasicparsing).content | where {$_ -match "[a-u]{0,2}-[a-z]{4,9}-[1,2]"} | Out-Null
$region = $Matches[0]
$now = get-date -Format U
$d = get-date $now -uformat %Y-%m-%dT%H:%M:00
$command = @\'
cmd.exe /C "C:\\Program Files\\Amazon\\AWSCLI\\aws.exe" cloudwatch put-metric-data --metric-name SEPMServices --namespace "System/Windows" --dimensions "Installation=SEPMServices" --value $value --timestamp $d --region $region
\'@

$command2 = @\'
cmd.exe /C "C:\\Program Files\\Amazon\\AWSCLI\\aws.exe" cloudwatch put-metric-alarm --alarm-name SEPMServices --metric-name SEPMServices --dimensions "Name=Installation,Value=SEPMServices" --namespace "System/Windows" --statistic Maximum --period 300 --threshold 4 --comparison-operator LessThanThreshold --evaluation-periods 1 --unit None --region $region
\'@

Invoke-Expression -Command:$command
start-sleep 2
Invoke-Expression -Command:$command2'
end

# Install The MSI package
package 'Install SEP Manager' do
  source File.join(sepExtractCacheFilePath, 'Symantec Endpoint Protection Manager.msi')
  options '/qn /log C:\\chef\\sepm-install.log'
  not_if {File.exist?('C:\Program Files (x86)\Symantec\Symantec Endpoint Protection Manager\startup.bat')}
    action :install
end

# Ensure That Install Files Are Removed
file sepZipCacheFilePath do
  action :delete
end

#start sepm services
service 'semlaunchsrv' do
 action :start
end
service 'semsrv' do
 action :start
end
service 'semwebsrv' do
 action :start
end
service 'SQLANYs_sem5' do
 action :start
end

#remote file
remote_file '/chef/serverprops.xml' do
  source 'https://stash.sdl.com/projects/CS/repos/tools/browse/SEPM_Silent_Installer/sep/San%20Jose_SNJMGMT01_server_properties.xml?raw'
  action :nothing
end

http_request 'HEAD https://stash.sdl.com/projects/CS/repos/tools/browse/SEPM_Silent_Installer/sep/San%20Jose_SNJMGMT01_server_properties.xml?raw' do
  message ''
  url 'https://stash.sdl.com/projects/CS/repos/tools/browse/SEPM_Silent_Installer/sep/San%20Jose_SNJMGMT01_server_properties.xml?raw'
  action :head
  if File.exist?('/chef/serverprops.xml')
    headers 'If-Modified-Since' => File.mtime('/chef/serverprops.xml').httpdate
  end
  notifies :create, 'remote_file[/chef/serverprops.xml]', :immediately
end
