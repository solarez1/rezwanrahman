<#

.AUTHOR: Rezwan Rahman
.DESCRIPTION: This Module allows the user to create an RDS Instance from an RDS Snapshot, Attaching it to a new EC2 Instance as a gateway server.
.NOTES: You need to set up the default AWS Credentials and MFA Auth prior to executing this module.  

#>

#Retrieve a list of RDS Snapshots based on specific parameters

Function Show-RDSSnapshot{
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
         [ValidateScript({If ($_ -match '^[a-z]{2}\-[a-z]{3,12}\-[1,2]$') {
            $True
        } Else {
            Throw "$_ is not a Valid region!"
        }})]  
        [string]$region,  
        [parameter(Mandatory)]     
        [int32]$items,
        [string]$wildcard,
        [parameter(Mandatory)]
        [ValidateScript({If ($_ -match '^[0-9]{4}\-[0-9]{2}\-[0-9]{2}$') {
            $True
        } Else {
            Throw "$_ is not a Valid date format, use YYYY-MM-DD!"
        }})]
        [string]$date,
        [parameter(Mandatory)]
        $awscredentials

)

    if($wildcard -eq ""){$wildcard="*"}

    $a = Get-RDSDBSnapshot -Region $region -Credential $awscredentials | ? {$_.SnapshotCreateTime -gt (get-date $date -Hour 23 -Minute 0 -Second 00).AddDays(-1) -and $_.SnapshotCreateTime -lt (get-date $date -Hour 0 -Minute 0 -Second 00).AddDays(+1)}|
    select DBInstanceIdentifier, DBSnapshotIdentifier, AvailabilityZone, SnapshotCreateTime

    $a |?{$_.DBInstanceIdentifier -like "$wildcard"}

}

#Create a new RDS Instance from the RDS Snapshot and attach to EC2 Instance

Function Invoke-RDSEC2{
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [ValidateScript({If ($_ -match '^[0-9]{4}\-[0-9]{2}\-[0-9]{2}$') {
            $True
        } Else {
            Throw "$_ is not a Valid date format, use YYYY-MM-DD!"
        }})]
        [string]$date,        
        [parameter(Mandatory)]
        [ValidateScript({If ($_ -match '^[a-z]{2}\-[a-z]{3,12}\-[1,2]$') {
            $True
        } Else {
            Throw "$_ is not a Valid region!"
        }})]
        [string]$region,        
        [parameter(Mandatory)]       
        [ValidateScript({If ($_ -match '^ami\-[0-9a-z]{7,9}$') {
            $True
        } Else {
            Throw "$_ is not a Valid AMI Id!"
        }})]
        [string]$ImageId,   
        [parameter(Mandatory)]
        [string]$instanceType,
        [parameter(Mandatory)]
        $awscredentials,           
        [ValidateScript({If ($_ -match 'subnet-[0-9a-z]{8}$') {
            $True
        } Else {
            Throw "$_ is not a Valid Subnet Id!"
        }})]
        $subnetId,
        [ValidateScript({If ($_ -match 'sg-[0-9a-z]{8,10}$') {
            $True
        } Else {
            Throw "$_ is not a Valid Security Group Id!"
        }})]
        $securitygrpid,      
        [parameter(Mandatory)]
        $FileName

)
    
    
    $ResultingInfrastructure = @{}
    $BaseParams = @{
        Region = $region
        Credential = $awscredentials 
        ErrorAction = 'Stop'
    }
    
   $WarningColourParams = @{
        ForegroundColor = "Red"
        BackgroundColor = "Black"
   }
   $StatusColourParams = @{
        ForegroundColor = "Yellow"
        BackgroundColor = "Black"
   }
   $LogColourParams = @{
        ForegroundColor = "Green"
        BackgroundColor = "Black"
   }
    
    $VerbosePreference = 'Continue'

    $a = get-content -Path $env:TEMP\$FileName | Out-String | ConvertFrom-Json
    
    $params = $BaseParams + @{KeyName = "myPSKeyPair - $((Get-Date).Ticks)"}
    $ResultingInfrastructure.KeyPair = New-EC2KeyPair @params
    $keyname = ($ResultingInfrastructure.KeyPair).KeyName
    
    $script = 
        {<powershell>
            Install-WindowsFeature -Name NET-Framework-Features

            $webclient = New-Object System.Net.WebClient
            $url = "https://download.microsoft.com/download/8/D/D/8DD7BDBA-CEF7-4D8E-8C16-D9F69527F909/ENU/x64/SQLManagementStudio_x64_ENU.exe"
            $file = "c:\SQLManagementStudio_x64_ENU.exe"
            $webclient.DownloadFile($url,$file)

            Start-Sleep 10

            $cmd = '(c:\SQLManagementStudio_x64_ENU.exe /ACTION=install /Q /INSTANCENAME="MSSQLSERVER" /FEATURES=SSMS /SQLSYSADMINACCOUNTS="Administrators" /IACCEPTSQLSERVERLICENSETERMS)'
            Invoke-Expression $cmd

        </powershell>}
 
    $userData = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($script))

    #Define the volume properties 
    $volume = New-Object Amazon.EC2.Model.EbsBlockDevice
    $volume.VolumeSize = 60
    $volume.VolumeType = 'standard'
    $volume.DeleteOnTermination = $True

    #Define how the volume is going to be attached to the instance and assign the volume properties
    $DeviceMapping = New-Object Amazon.EC2.Model.BlockDeviceMapping
    $DeviceMapping.DeviceName = '/dev/sda1'
    $DeviceMapping.Ebs = $volume

    $ResultingInfrastructure.Instance = New-EC2Instance @BaseParams -ImageId $ImageId -InstanceType $instanceType -SubnetId $a.Subnet1.SubnetId -SecurityGroupId $a.SecurityGroup -KeyName $keyname -BlockDeviceMapping $DeviceMapping -AvailabilityZone $a.AvailabilityZone.ZoneName[0] -UserData $userData

    $cdate = (get-date -format yyyy-MM-dd)

    $filter3 = New-Object Amazon.EC2.Model.Filter
    $filter3.Name="launch-time"
    $filter3.Value="*$cdate*"

    $filter4 = New-Object Amazon.EC2.Model.Filter
    $filter4.Name="instance-state-name"
    $filter4.Value="pending"

    $dummy = Get-EC2Instance -Filter $filter3, $filter4 @BaseParams

    $checkinstance = ($dummy[0].Instances).InstanceId

    Write-Output($dummy | Format-Table -AutoSize)

        Do
        {

            $runninginstance = ((((Get-EC2Instance @BaseParams -Instance $checkinstance | select Instances).instances).state).Name).Value
            Write-Verbose "Please wait while EC2 instance is being started.."
            Start-Sleep 10

        }

        while($runninginstance -ne "running")

     $tag = New-Object Amazon.EC2.Model.Tag
     $tag.Key = "Name"
     $tag.Value = "COC-Test"

     New-EC2Tag @BaseParams -Resource $checkinstance -Tag $tag

     Write-Host "`r`nInstance $checkinstance is now running" @StatusColourParams

     Write-AWSInfrastructureAutoSave -ResultantInfrastructure $ResultingInfrastructure -outputFile $FileName

    #Create DB subnet group
    $DBGroupName = "COC-Test$(Get-Date -Format hhmm)"
    $ResultingInfrastructure.DBGroupName = New-RDSDBSubnetGroup @BaseParams -DBSubnetGroupName $DBGroupName -SubnetId $a.Subnet2.SubnetId,$a.subnet1.subnetid -DBSubnetGroupDescription $DBGroupName

    Write-Output("`r`n" + "DB Instance Identifier`r`n" + "======================`r`n")
    Write-Output($DBGroupName)

    $filter1 = New-Object Amazon.EC2.Model.Filter
    $filter1.Name="tag:Name"
    $filter1.Value="*$instanceid*"

    $snapshots = Get-RDSDBSnapshot @BaseParams | ? {$_.SnapshotCreateTime -gt (get-date $date -Hour 23 -Minute 0 -Second 00).AddDays(-1) -and $_.SnapshotCreateTime -lt (get-date $date -Hour 0 -Minute 0 -Second 00).AddDays(+1)}|
    select DBInstanceIdentifier, DBSnapshotIdentifier, AvailabilityZone, SnapshotCreateTime | sort SnapshotCreateTime

    Write-Output($snapshots)

        foreach($snaps in $snapshots)
            {

                $ResultingInfrastructure.RDSInstance = Restore-RDSDBInstanceFromDBSnapshot @BaseParams -AvailabilityZone $a.AvailabilityZone.ZoneName[1] -DBInstanceIdentifier $DBGroupName -DBSnapshotIdentifier $snaps.DBSnapshotIdentifier -DBSubnetGroupName $DBGroupName

                Start-Sleep 10               

                $tag = New-Object Amazon.EC2.Model.Tag
                $tag.Key = "Name"
                $tag.Value = $snaps.DBInstanceIdentifier
                             
        
            }    

    $RDSSecGroup = (Get-RDSDBInstance @BaseParams -DBInstanceIdentifier $ResultingInfrastructure.RDSInstance.DBInstanceIdentifier).VpcSecurityGroups.vpcsecuritygroupid

    #$PublicGroup = $a.SecurityGroup

    $private:IPPermission = New-Object Amazon.EC2.Model.IpPermission -Property @{
        IpProtocol = "tcp"
        FromPort = 1433
        ToPort = 1433
        IpRanges = @("0.0.0.0/0")
        #UserIdGroupPairs = $PublicGroup
    }
    
    $params = $BaseParams + @{GroupId = $RDSSecGroup; IpPermissions = @($private:IPPermission)}
    Grant-EC2SecurityGroupIngress @params

    Write-AWSInfrastructureAutoSave -ResultantInfrastructure $ResultingInfrastructure -outputFile $FileName

    $publicip = New-EC2Address @BaseParams -Domain "vpc"

    Start-sleep 5

    Register-EC2Address @BaseParams -InstanceId $dummy.Instances.instanceId -PublicIp $publicip.PublicIp | Out-Null

    $ResultingInfrastructure.EIP = Get-EC2Address @BaseParams | ?{$_.InstanceId -eq $dummy.Instances.instanceId}

    Write-Output("`r`n" + "Instance Public/Private IP`r`n" + "==========================`r`n")
    (Get-EC2Instance -Instance $dummy.Instances.instanceId @BaseParams).Instances.PublicIpAddress
    (Get-EC2Instance -Instance $dummy.Instances.instanceId @BaseParams).Instances.PrivateIpAddress
    
    Write-AWSInfrastructureAutoSave -ResultantInfrastructure $ResultingInfrastructure -outputFile $FileName
    
    # create PEM file
    Set-Content "$env:temp\$($ResultingInfrastructure.KeyPair.KeyName)" -Value $ResultingInfrastructure.KeyPair.KeyMaterial
       
}

#Retrieve the latest Public AMI Id to create a new dummy instance

Function Get-AMIID{
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [ValidateScript({If ($_ -match '^[a-z]{2}\-[a-z]{3,12}\-[1,2]$') {
            $True
        } Else {
            Throw "$_ is not a Valid region!"
        }})]
        [string]$region,
        [parameter(Mandatory)]
        $awscredentials 
)

    $BaseParams = @{
    Region = $region
    Credential = $awscredentials 
    ErrorAction = "Stop"
    }

    $b = Get-EC2ImageByName -name Windows_2012_BASE @BaseParams | select name, imageid, @{label="Region"; Expression ={$region}}
    $c = Get-EC2ImageByName -Name Windows_2012_SQL_SERVER_STANDARD_2014 @BaseParams | select name, imageid, @{label="Region"; Expression ={$region}} 
    $d = Get-EC2ImageByName -name Windows_Server-2012-R2_RTM-English-64Bit-Core* @BaseParams | select name, imageid, @{label="Region"; Expression ={$region}} -first 1 

    Write-Output($b)
    Write-Output($c)
    Write-Output($d)

}

#Create a VPC

Function Invoke-VPC{
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [ValidateScript({If ($_ -match '^[a-z]{2}\-[a-z]{3,12}\-[1,2]$') {
            $True
        } Else {
            Throw "$_ is not a Valid region!"
        }})]
        [string]$region,
        [ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}")]
        $VPCCIDR = '10.0.0.0/16',
        [parameter(Mandatory)]
        $awscredentials,
        [parameter(Mandatory)]
        [ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}")]
        [string[]]$RDPSourceCIDR,
        [ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}")]
        $SubnetCIDR1 = '10.0.1.0/24',
        [ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}")]
        $SubnetCIDR2 = '10.0.2.0/24',
        [parameter(Mandatory)]
        [string]
        $FileName

)

    $ResultingInfrastructure = @{}
    $BaseParams = @{
        Region = $region
        Credential = $awscredentials 
        ErrorAction = 'Stop'
    }
   $WarningColourParams = @{
        ForegroundColor = "Red"
        BackgroundColor = "Black"
   }
   $StatusColourParams = @{
        ForegroundColor = "Yellow"
        BackgroundColor = "Black"
   }
   $LogColourParams = @{
        ForegroundColor = "Green"
        BackgroundColor = "Black"
   }

    # Pick an Availability Zone
    $ResultingInfrastructure.availabilityZone = Get-EC2AvailabilityZone @BaseParams | ?{$_.state -eq 'available'} | Get-Random -Count 3
    Write-Host("`r`nAvailabilityZone`r`n================")
    $ResultingInfrastructure.availabilityZone

    $tag = New-Object Amazon.EC2.Model.Tag
    $tag.Key = "Name"
    $tag.Value = "COC-Test"

    # Create new VPC
    $params = $baseParams + @{CidrBlock = $VPCCIDR};
    $ResultingInfrastructure.vpc = New-EC2Vpc @params

    New-EC2Tag @BaseParams -Resource $ResultingInfrastructure.vpc.VpcId -Tag $tag 

    Write-Host("`r`nVPC Details`r`n===========")
    $ResultingInfrastructure.vpc
    Write-AWSInfrastructureAutoSave -ResultantInfrastructure $ResultingInfrastructure -outputFile $FileName

    $params = $BaseParams + @{VpcId = $ResultingInfrastructure.VPC.VpcId; CidrBlock = $SubnetCIDR1; AvailabilityZone = $ResultingInfrastructure.AvailabilityZone.ZoneName[0]}
    $ResultingInfrastructure.Subnet1 = New-EC2Subnet @params

    New-EC2Tag @BaseParams -Resource $ResultingInfrastructure.Subnet1.SubnetId -Tag $tag

    Write-Host("`r`nSubnet Details Primary`r`n=====================")
    $ResultingInfrastructure.Subnet1
    Write-AWSInfrastructureAutoSave -ResultantInfrastructure $ResultingInfrastructure -outputFile $FileName

    $params = $BaseParams + @{VpcId = $ResultingInfrastructure.VPC.VpcId; CidrBlock = $SubnetCIDR2; AvailabilityZone = $ResultingInfrastructure.AvailabilityZone.ZoneName[1]}
    
    $ResultingInfrastructure.Subnet2 = New-EC2Subnet @params

    New-EC2Tag @BaseParams -Resource $ResultingInfrastructure.Subnet2.SubnetId -Tag $tag

    Write-Host("`r`nSubnet Details Secondary`r`n========================")
    $ResultingInfrastructure.Subnet2
    Write-AWSInfrastructureAutoSave -ResultantInfrastructure $ResultingInfrastructure -outputFile $FileName
         
    # Create Security Group
    $params = $BaseParams + @{VpcId = $ResultingInfrastructure.VPC.VpcId; GroupName = "Backup Restore Security Group - $((Get-Date).Ticks)"; GroupDescription = "Allow 3389 from everywhere for testing purposes"}
    $ResultingInfrastructure.SecurityGroup = New-EC2SecurityGroup @params

    New-EC2Tag @BaseParams -Resource $ResultingInfrastructure.SecurityGroup -Tag $tag

    Write-Host("`r`nSecurityGroup Details`r`n=====================")
    $ResultingInfrastructure.SecurityGroup
    Write-AWSInfrastructureAutoSave -ResultantInfrastructure $ResultingInfrastructure -outputFile $FileName
        
    $private:IPPermission = New-Object Amazon.EC2.Model.IpPermission -Property @{
        IpProtocol = "tcp"
        FromPort = 3389
        ToPort = 3389
        IpRanges = @("$RDPSourceCIDR")
    }
    
    $params = $BaseParams + @{GroupId = $ResultingInfrastructure.SecurityGroup; IpPermissions = @($private:IPPermission)}
    Grant-EC2SecurityGroupIngress @params

    New-EC2Tag @BaseParams -Resource $ResultingInfrastructure.SecurityGroup -Tag $tag
 
    # Setup Internet GateWay
    $ResultingInfrastructure.InternetGateway = New-EC2InternetGateway @BaseParams
    Write-Host("`r`nInternet Gateway Details`r`n=========================")
    $ResultingInfrastructure.InternetGateway
    Write-AWSInfrastructureAutoSave -ResultantInfrastructure $ResultingInfrastructure -outputFile $FileName

    $params = $BaseParams + @{VpcId = $ResultingInfrastructure.VPC.VpcId; InternetGatewayId = $ResultingInfrastructure.InternetGateway.InternetGatewayId}
    Add-EC2InternetGateway @params

    New-EC2Tag @BaseParams -Resource $ResultingInfrastructure.InternetGateway.InternetGatewayId -Tag $tag

    $RouteTableID = (Get-EC2RouteTable @BaseParams | ?{$_.vpcid -eq $ResultingInfrastructure.vpc.vpcid}).RouteTableId
    $params = $BaseParams + @{DestinationCidrBlock = '0.0.0.0/0'; GatewayId = $ResultingInfrastructure.InternetGateway.InternetGatewayId; RouteTableID = $RouteTableID}
    New-EC2Route @params

}

#Logging Function

Function Write-AWSInfrastructureAutoSave{
    param(
        [parameter(Mandatory)]
        $ResultantInfrastructure,
        [String]      
        $outputFile
    )

   $WarningColourParams = @{
        ForegroundColor = "Red"
        BackgroundColor = "Black"
   }
   $StatusColourParams = @{
        ForegroundColor = "Yellow"
        BackgroundColor = "Black"
   }
   $LogColourParams = @{
        ForegroundColor = "Green"
        BackgroundColor = "Black"
   }

    if(Test-Path $env:Temp\$outputFile){
            $myJson = gc $env:Temp\$outputFile | Out-String | ConvertFrom-Json
            $myJson | Add-Member -NotePropertyMembers $ResultingInfrastructure -Force -ErrorAction "Stop"
            $myJson | ConvertTo-Json -Depth 9 | Set-Content $env:Temp\$outputFile -Force -ErrorAction "Stop"
        Write-Host "`r`nAdded Content to Log File in $env:Temp\$outputFile" @LogColourParams

    }
    else{
            $ResultingInfrastructure | ConvertTo-Json -Depth 9 | Set-Content "$env:Temp\$outputFile" -Force -ErrorAction "Stop"
        Write-Host "`r`nCreated Log file in $env:Temp\$outputFile" @LogColourParams
    }

}

#Clean Up Environment

Function Remove-Environment{
   [CmdletBinding(SupportsShouldProcess)] 
    param(
        [Parameter(Mandatory)]
        $FileName,
        [Parameter(Mandatory)]
        $region,
        [Parameter(Mandatory)]
        $awscredentials
    )

   $BaseParams = @{
        Region = $region
        Credential = $awscredentials 
        ErrorAction = 'Stop'
    }
   
   $WarningColourParams = @{
        ForegroundColor = "Red"
        BackgroundColor = "Black"
   }
   $StatusColourParams = @{
        ForegroundColor = "Yellow"
        BackgroundColor = "Black"
   }
   $LogColourParams = @{
        ForegroundColor = "Green"
        BackgroundColor = "Black"
   }

   $VerbosePreference = 'Continue'

   $ConfirmPreference = "Low"
   If ($PSCmdlet.ShouldContinue("Would you like to delete the VPC and any associated EC2Instances?","Delete with -Force parameter!")) {  
     
    Write-Host "`r`nContinue with Deletion.." @WarningColourParams
     
    $a = get-content -Path $env:TEMP\$FileName | Out-String | ConvertFrom-Json

    Unregister-EC2Address @BaseParams -AssociationId $a.EIP.AssociationId -Force
    Start-sleep 5
    Remove-EC2Address @BaseParams -AllocationId $a.EIP.AllocationId -Force
    Start-Sleep 2
    Write-Host "`r`nRemoved Elastic IP $($a.EIP.PublicIp)" @StatusColourParams
    Stop-EC2Instance @BaseParams -Instance $a.Instance.Instances.InstanceId -Terminate -Force | Out-Null
    
    Do
        {

            $terminateinstance = ((Get-EC2Instance @BaseParams -Instance $a.Instance.Instances.Instanceid) | select Instances).Instances.state.Name.value
            Write-Verbose "Please wait while instance is being terminated.."
            Start-Sleep 10

        }

    while($terminateinstance -ne "terminated")
   
   
    Remove-RDSDBInstance @BaseParams -DBInstanceIdentifier $a.RDSInstance.DBInstanceIdentifier -SkipFinalSnapshot 1 -Force
   try{
    Do
        {

            $RDSInstance = ((Get-RDSDBInstance -Region $region -Credential $Role.Credentials -DBInstanceIdentifier $a.RDSInstance.DBInstanceIdentifier).DBInstanceStatus)
            Write-Verbose "Please wait while RDS Instance is deleted.."
            Start-Sleep 30

        }

    while($RDSInstance -eq "deleting")
    }
    catch{
    $msg = $_
    Write-Host "$msg" @WarningColourParams
    }
    Start-Sleep 2
    Remove-RDSDBSubnetGroup @BaseParams -DBSubnetGroupName $a.RDSInstance.DBSubnetGroup.DBSubnetGroupName -Force
    Start-Sleep 2
    Remove-EC2Subnet @BaseParams -SubnetId $a.Subnet1.SubnetId -Force
    Start-Sleep 2
    Remove-EC2Subnet @BaseParams -SubnetId $a.Subnet2.SubnetId -Force
    Start-Sleep 2
    Write-Host "Removed Subnets $($a.Subnet1.SubnetId) and $($a.Subnet2.SubnetId)" @StatusColourParams
    Remove-EC2SecurityGroup @BaseParams -GroupId $a.SecurityGroup -Force
    Start-Sleep 2
    Write-Host "Removed Security Group $($a.SecurityGroup) and $($a.RDSInstance.VpcSecurityGroups.vpcsecuritygroupid)" @StatusColourParams
    Dismount-EC2InternetGateway @BaseParams -InternetGatewayId $a.InternetGateway.InternetGatewayId -VpcId $a.vpc.VpcId -Force
    Start-Sleep 2
    Remove-EC2InternetGateway @BaseParams -InternetGatewayId $a.InternetGateway.InternetGatewayId -Force
    Start-Sleep 2
    Write-Host "Removed Internet Gateway $($a.InternetGateway.InternetGatewayId)" @StatusColourParams
    Remove-Ec2vpc @BaseParams -VpcId $a.vpc.VpcId -Force
    Write-Host "Removed VPC $($a.vpc.VpcId)" @StatusColourParams
    Start-Sleep 2
    Remove-EC2KeyPair @BaseParams $a.KeyPair.KeyName -Force
    Write-Host "Removed KeyPair $($a.KeyPair.KeyName)" @StatusColourParams
    Remove-Item $env:TEMP\$FileName -Force
    Write-Host "`r`nClean up Operation Complete!" @LogColourParams
             } 
   
   Else {  
             Write-Host "`r`nOperation to delete aborted!" @WarningColourParams
     }

# Remove inbound rules for SG before deleting
}

#Display RDS Endpoint and Windows Password

Function Show-RDSEndpoint{
   [CmdletBinding(SupportsShouldProcess)] 
    param(
        [Parameter(Mandatory)]
        $FileName,      
        $DBPassword,
        [Parameter(Mandatory)]
        $region,
        [Parameter(Mandatory)]
        $awscredentials
    )

   $BaseParams = @{
        Region = $region
        Credential = $awscredentials 
        ErrorAction = 'Stop'
    }
   
   $WarningColourParams = @{
        ForegroundColor = "Red"
        BackgroundColor = "Black"
   }
   $StatusColourParams = @{
        ForegroundColor = "Yellow"
        BackgroundColor = "Black"
   }
   $LogColourParams = @{
        ForegroundColor = "Green"
        BackgroundColor = "Black"
   }

   $VerbosePreference = 'Continue'
    

    $a = get-content -Path $env:TEMP\$FileName | Out-String | ConvertFrom-Json

    Do
        {

            $RDSInstance = ((Get-RDSDBInstance @BaseParams -DBInstanceIdentifier $a.RDSInstance.DBInstanceIdentifier).DBInstanceStatus)
            Write-Verbose "Please wait while RDS Instance is available.."
            Start-Sleep 10

        }

     While($RDSInstance -ne "available")
   
   Write-Output((Get-RDSDBInstance @BaseParams -DBInstanceIdentifier $a.RDSInstance.DBInstanceIdentifier).Endpoint | select Address)

   if($DBPassword -eq ""){
   $DBPassword = Out-Null
   }
   else{
   Edit-RDSDBInstance @BaseParams -DBInstanceIdentifier $a.RDSInstance.DBInstanceIdentifier -MasterUserPassword $DBPassword -ApplyImmediately 1
   }

   Write-Output("`r`n" + "Instance Public IP`r`n" + "==================`r`n")
   $a.EIP.PublicIp    

   # Display windows password
   Write-Output("`r`nWindows Password" + "`r`n================`r`n")
   Get-EC2PasswordData @BaseParams -InstanceId $a.Instance.Instances.instanceid -PemFile $env:TEMP\$($a.KeyPair.KeyName)

    }
