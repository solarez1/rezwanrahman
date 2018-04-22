<#

.AUTHOR: Rezwan Rahman
.DESCRIPTION: This Module allows the user to create a Volume from an EBS Snapshot, Attaches it to a new EC2 Instance and starts it.
.NOTES: You need to set up the default AWS Credentials and MFA Auth prior to executing this module.  


#>

#Retrieve a list of EBS Snapshots based on specific parameters and also returns the instances they relate to

Function Show-InstancesbyEBS
{
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

    $filter1 = New-Object Amazon.EC2.Model.Filter
    $filter1.Name = 'start-time'
    $filter1.Value.Add("*$date*")

    $a = Get-EC2Snapshot -filter $filter1 -Credential $awscredentials -Region $region | select -last $items | sort StartTime -Descending | 
    Select @{Name='SnapshotName'; Expression={($_.Tag |%{ $_.Value}) -join ','}}, SnapshotId, StartTime

    $a |?{$_.SnapshotName -like "$wildcard"}| Format-Table -AutoSize

    $instances = $a | ?{$_.SnapshotName -like "$wildcard"} | %{$_.snapshotname -match 'i-[0-9a-z]{6,12}' | Out-Null;$matches[0]}

    Write-Output("Unique Instances`r`n" + "================`r`n")
    Write-Output($instances | sort-object | Get-Unique | Format-Table -AutoSize)

}

#Retrieve a list of EBS Snapshots related to an instance id and date range

Function Show-LatestSnapshots{
    [CmdletBinding()]
    param(  
        [parameter(Mandatory)] 
        [ValidateScript({If ($_ -match '^i\-[0-9a-z]{6,8}$') {
            $True
        } Else {
            Throw "$_ is not a Valid instance!"
        }})]
        [string]$instanceid,
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
        $awscredentials
)

    $filter1 = New-Object Amazon.EC2.Model.Filter
    $filter1.Name="tag:Name"
    $filter1.Value="*$instanceid*"

    $snapshots = Get-EC2Snapshot -filter $filter1 -Credential $awscredentials -Region $region | Select @{Name='SnapshotName'; Expression={($_.Tag |%{ $_.Value}) -join ','}},SnapshotId, StartTime | 
    sort StartTime -Descending | ?{$_.StartTime -gt (get-date $date).AddDays(-1) -and $_.StartTime -lt (get-date $date).AddDays(+1)}| Format-Table -AutoSize

    Write-Output($snapshots)

}

#Create a new Volume from the EBS Snapshot and attach to EC2 Instance

Function Invoke-EC2AndAttachVolume{
    [CmdletBinding()]
    param(
        [ValidateScript({If ($_ -match '^[a-z]{2}\-[a-z]{1,20}\-[]0-9]{1}[a-c]$') {
            $True
        } Else {
            Throw "$_ is not a Valid availability zone, remember to specify zone a to c!"
        }})]
        [string]$AZ,
        [parameter(Mandatory)]
        [ValidateScript({If ($_ -match '^i\-[0-9a-z]{6,8}$') {
            $True
        } Else {
            Throw "$_ is not a Valid instance!"
        }})]
        [string]$instanceid,
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
        $SubnetId,
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

    try{
    $a = get-content -Path $env:TEMP\$FileName | Out-String | ConvertFrom-Json

    $params = $BaseParams + @{KeyName = "myPSKeyPair - $((Get-Date).Ticks)"}
    $ResultingInfrastructure.KeyPair = New-EC2KeyPair @params
    $keyname = ($ResultingInfrastructure.KeyPair).KeyName

    $ResultingInfrastructure.Instance = New-EC2Instance @BaseParams -ImageId $ImageId -InstanceType $instanceType -SubnetId $a.Subnet.SubnetId -SecurityGroupId $a.SecurityGroup -KeyName $keyname

    $cdate = (get-date -format yyyy-MM-dd)

    $filter3 = New-Object Amazon.EC2.Model.Filter
    $filter3.Name="launch-time"
    $filter3.Value="*$cdate*"

    $filter4 = New-Object Amazon.EC2.Model.Filter
    $filter4.Name="instance-state-name"
    $filter4.Value="pending"

    $dummy = Get-EC2Instance -Filter $filter3, $filter4 @BaseParams

    $tag = New-Object Amazon.EC2.Model.Tag
           $tag.Key = "Dummy"
           $tag.Value = "COC-Test"

    New-EC2Tag @BaseParams -Resource $dummy.Instances.InstanceId -Tag $tag
    
    $filter1 = New-Object Amazon.EC2.Model.Filter
    $filter1.Name = "attachment.instance-id"
    $filter1.Values = ($dummy[0].Instances).InstanceId

    $dummyvol = (Get-EC2Volume @BaseParams -Filter $filter1).VolumeId

    New-EC2Tag @BaseParams -Tag $tag -Resource $dummyvol

    Start-Sleep 15

    $stopinstance = ($dummy[0].Instances).InstanceId

    Write-Output($dummy | Format-Table -AutoSize)

        Do
        {

            $runninginstance = (Get-EC2Instance @BaseParams -Instance $stopinstance | select Instances).instances.state.Name.Value
            Write-Verbose "Please wait 10 seconds while instance is being started.."

            Start-Sleep 10

        }

        while($runninginstance -ne "running")

        Do
        {
            $stopping = (Stop-EC2Instance -Instance $stopinstance @BaseParams).CurrentState.Name
            Write-Verbose "Please wait 10 seconds while instance is being stopped.."

            Start-Sleep 10
        }

        while($stopping -ne "stopped")

    Write-Host "Please wait another 10 seconds to detach the dummy volume..`r`n" @StatusColourParams
    
    Start-Sleep 10

    Dismount-EC2Volume -VolumeId $dummyvol @BaseParams | Out-Null

    Start-Sleep 10

    Remove-EC2Volume -VolumeId $dummyvol @BaseParams -Force

    Write-Host "Dummy volume $dummyvol dismounted and removed..`r`n" @StatusColourParams

    $filter1 = New-Object Amazon.EC2.Model.Filter
    $filter1.Name="tag:Name"
    $filter1.Value="*$instanceid*"

    $snapshots = (Get-EC2Snapshot -filter $filter1 @BaseParams | 
    Select @{Name='SnapshotName'; Expression={($_.Tag |%{ $_.Value}) -join ','}},SnapshotId, StartTime | 
    sort StartTime -Descending | ?{$_.StartTime -gt (get-date $date -Hour 23 -Minute 56 -Second 00).AddDays(-1) -and $_.StartTime -lt (get-date $date -Hour 0 -Minute 0 -Second 00).AddDays(+1)})

    Write-Output($snapshots)

        foreach($snaps in $snapshots)
            {

                $ResultingInfrastructure.EC2Volume = New-EC2Volume @BaseParams -AvailabilityZone $a.Subnet.AvailabilityZone -SnapshotId $snaps.SnapshotId

                Start-Sleep 10
                
                $b = Get-EC2Volume @BaseParams | where{$_.SnapshotId -eq $snaps.SnapshotId}

                $tag2 = New-Object Amazon.EC2.Model.Tag
                $tag2.Key = "Name"
                $tag2.Value = $snaps.SnapshotName

                $tag = New-Object Amazon.EC2.Model.Tag
                $tag.Key = "Dummy"
                $tag.Value = 'COC-Test'

                New-EC2Tag @BaseParams -Resource $b.volumeid -Tag $tag2
                New-EC2Tag @BaseParams -Resource $b.volumeid -Tag $tag
                Write-Output($b) | Format-Table -AutoSize
                  
                Start-Sleep 30

                Write-Output("Device Type`r`n" + "===========`r`n")
        
                Get-EC2Volume @BaseParams | Select @{Name='SnapshotName'; Expression={($_.Tag |%{ $_.Value}) -join ','}} | 
                %{$_.snapshotname -match '\/dev\/sd[a-z][0-9]' -or $_.snapshotname -match '\/dev\/sd[a-z]' -or $_.snapshotname -match 'xvd[a-z]'} | Out-Null;$matches[0]
        
                Start-Sleep 20               
               
                Add-EC2Volume -InstanceId $dummy.Instances.instanceId -Device $matches[0] -VolumeId $b.volumeid @BaseParams -Force                                      
                
                Start-Sleep 40
        
            }
    Start-Sleep 5

    $publicip = New-EC2Address @BaseParams -Domain "vpc"

    Start-sleep 5

    Register-EC2Address @BaseParams -InstanceId $dummy.Instances.instanceId -AllocationId $publicip.AllocationId

    $ResultingInfrastructure.EIP = Get-EC2Address @BaseParams | ?{$_.InstanceId -eq $dummy.Instances.instanceId}

    Start-sleep 2

    Start-EC2Instance -InstanceId $dummy.Instances.instanceId @BaseParams

        foreach($snap2 in $snapshots)
            {

                $b = Get-EC2Volume @BaseParams | ?{$_.SnapshotId -eq $snap2.SnapshotId} | select volumeid
                    Write-Output($b) | Format-Table -AutoSize 
            }

    Write-Output("Instance Public/Private IP`r`n" + "==========================`r`n")
    (Get-EC2Instance -Instance $dummy.Instances.instanceId @BaseParams).Instances.PublicIpAddress
    (Get-EC2Instance -Instance $dummy.Instances.instanceId @BaseParams).Instances.PrivateIpAddress

    $filterIntGate = New-Object Amazon.EC2.Model.Filter
    $filterIntGate.Name = "VPC"
    $filter1.Values = "$stopinstance"

    $ResultingInfrastructure.EC2Volume = (Get-EC2Volume @BaseParams |?{$_.Attachment.Instanceid -eq (($dummy.Instances).instanceId)}).VolumeId

    Write-AWSInfrastructureAutoSave -ResultantInfrastructure $ResultingInfrastructure -outputFile $FileName
    }
    catch
    {
    $msg = $_
    Write-Host "$msg" @WarningColourParams
    }
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
    ErrorAction = 'Stop'
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
        $SubnetCIDR = '10.0.1.0/24',
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

   try{
    # Pick an Availability Zone
    $ResultingInfrastructure.availabilityZone = Get-EC2AvailabilityZone @BaseParams | ?{$_.state -eq 'available'} | Get-Random
    Write-Host("`r`nAvailabilityZone`r`n================")
    $ResultingInfrastructure.availabilityZone

    # Create new VPC
    $params = $BaseParams + @{CidrBlock = $VPCCIDR};
    $ResultingInfrastructure.vpc = New-EC2Vpc @params
    
    
    $tag = New-Object Amazon.EC2.Model.Tag
    $tag.Key = "Dummy"
    $tag.Value = "COC-Test"

    New-EC2Tag @BaseParams -Resource $ResultingInfrastructure.vpc.VpcId -Tag $tag 

    Write-Host("`r`nVPC Details`r`n===========")
    $ResultingInfrastructure.vpc
    Write-AWSInfrastructureAutoSave -ResultantInfrastructure $ResultingInfrastructure -outputFile $FileName

    $params = $BaseParams + @{VpcId = $ResultingInfrastructure.VPC.VpcId; CidrBlock = $SubnetCIDR; AvailabilityZone = $ResultingInfrastructure.AvailabilityZone.ZoneName}
    $ResultingInfrastructure.Subnet = New-EC2Subnet @params
    
    New-EC2Tag @BaseParams -Resource $ResultingInfrastructure.Subnet.SubnetId -Tag $tag

    Write-Host("`r`nSubnet Details`r`n==============")
    $ResultingInfrastructure.Subnet
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
   catch
    {
    $msg = $_
    Write-Host "$msg" @WarningColourParams
    }
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
            $myJson = Get-Content $env:Temp\$outputFile | Out-String | ConvertFrom-Json
            $myJson | Add-Member -NotePropertyMembers $ResultingInfrastructure -Force
            $myJson | ConvertTo-Json -Depth 9 | Set-Content $env:Temp\$outputFile -Force
        Write-Host "`r`nAdded Content to Log File in $env:Temp\$outputFile" @LogColourParams

    }
    else{
            $ResultingInfrastructure | ConvertTo-Json -Depth 9 | Set-Content "$env:Temp\$outputFile" -Force
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
      if($a.Instance.Instances.Instanceid -ne $null)
       {
    Stop-EC2Instance @BaseParams -Instance $a.Instance.Instances.InstanceId -Terminate -Force | Out-Null
      
        Do
            {
                
                $terminateinstance = ((Get-EC2Instance @BaseParams -Instance $a.Instance.Instances.Instanceid) | select Instances).Instances.state.Name.value
                Write-Verbose "Please wait while instance is being terminated.."
                Start-Sleep 10

            }

        while($terminateinstance -ne "terminated")
       
   
    
        foreach($b in $a.EC2Volume)

            {
                Remove-EC2Volume @BaseParams $b -Force
                Start-Sleep 2
                Write-Host "Removed Volume $b" @StatusColourParams
            }
        }
    
     
    Remove-EC2Subnet @BaseParams -SubnetId $a.Subnet.SubnetId -Force
    Start-Sleep 2
    Write-Host "Removed Subnet $($a.Subnet.SubnetId)" @StatusColourParams
    Remove-EC2SecurityGroup @BaseParams -GroupId $a.SecurityGroup -Force
    Start-Sleep 2
    Write-Host "Removed Security Group $($a.SecurityGroup)" @StatusColourParams
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
             Write-Warning "`r`nOperation to delete aborted!"
        }

}