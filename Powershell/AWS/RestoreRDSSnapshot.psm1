<#

.AUTHOR: Rezwan Rahman
.DESCRIPTION: This Module allows the user to create an RDS Instance from an RDS Snapshot, Attaching it to a new EC2 Instance as a gateway server.
.NOTES: You need to set up the default AWS Credentials and MFA Auth prior to executing this module.  

#>

#Retrieve a list of RDS Snapshots based on specific parameters

Function Show-RDSSnapshot
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

    $a = Get-RDSDBSnapshot -Region $region -Credential $awscredentials | ? {$_.SnapshotCreateTime -gt (get-date $date -Hour 23 -Minute 0 -Second 00).AddDays(-1) -and $_.SnapshotCreateTime -lt (get-date $date -Hour 0 -Minute 0 -Second 00).AddDays(+1)}|
    select DBInstanceIdentifier, DBSnapshotIdentifier, AvailabilityZone, SnapshotCreateTime

    $a |?{$_.DBInstanceIdentifier -like "$wildcard"}

}

#Create a new RDS Instance from the RDS Snapshot and attach to EC2 Instance

Function Invoke-RDSEC2{
    [CmdletBinding()]
    param(
        <#
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
        #>
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
        <#
        [parameter(Mandatory)]
        $DBInstanceId,
        #>
        [parameter(Mandatory)]
        $FileName

)
    
    

    $ResultingInfrastructure = @{}
    $BaseParams = @{
        Region = $region
        Credential = $awscredentials 
        ErrorAction = "Stop"
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

    $a = get-content -Path $env:TEMP\$FileName | Out-String | ConvertFrom-Json
    
    $params = $BaseParams + @{KeyName = "myPSKeyPair - $((Get-Date).Ticks)"}
    $ResultingInfrastructure.KeyPair = New-EC2KeyPair @params
    $keyname = ($ResultingInfrastructure.KeyPair).KeyName
    
    #Write-AWSInfrastructureAutoSave -ResultantInfrastructure $ResultingInfrastructure -outputFile $FileName

    $ResultingInfrastructure.Instance = New-EC2Instance @BaseParams -ImageId $ImageId -InstanceType $instanceType -SubnetId $a.Subnet1.SubnetId -SecurityGroupId $a.SecurityGroup -KeyName $keyname -AvailabilityZone $a.AvailabilityZone.ZoneName[0]
    
    #Write-AWSInfrastructureAutoSave -ResultantInfrastructure $ResultingInfrastructure -outputFile $FileName

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
            Write-Host "Please wait 10 seconds while instance is being started.." @StatusColourParams
            Start-Sleep 10

        }

        while($runninginstance -ne "running")

     $tag = New-Object Amazon.EC2.Model.Tag
     $tag.Key = "Name"
     $tag.Value = "COC-Test"

     New-EC2Tag @BaseParams -Resource $checkinstance -Tag $tag

     Write-Host "`r`nInstance $checkinstance is now running" @StatusColourParams

     Write-AWSInfrastructureAutoSave -ResultantInfrastructure $ResultingInfrastructure -outputFile $FileName
    
     <#$ResultingInfrastructure.RDSSnap = Restore-RDSDBInstanceFromDBSnapshot -Region $region -Credential $Role.Credentials -AvailabilityZone $AZ -DBInstanceIdentifier $DBInstanceId -DBSnapshotIdentifier $DBSnapID -DBSubnetGroupName default-vpc-95342ef0

     Write-AWSInfrastructureAutoSave -ResultantInfrastructure $ResultingInfrastructure -outputFile $FileName#>

    #Create DB subnet group
    $DBGroupName = "COC-Test$(Get-Date -Format hhmm)"
    $ResultingInfrastructure.DBGroupName = New-RDSDBSubnetGroup -Region $region -Credential $Role.Credentials -DBSubnetGroupName $DBGroupName -SubnetId $a.Subnet2.SubnetId,$a.subnet1.subnetid -DBSubnetGroupDescription $DBGroupName

    Write-Output("`r`n" + "DB Instance Identifier`r`n" + "======================`r`n")
    Write-Output($DBGroupName)

    $filter1 = New-Object Amazon.EC2.Model.Filter
    $filter1.Name="tag:Name"
    $filter1.Value="*$instanceid*"

    $snapshots = Get-RDSDBSnapshot -Region $region -Credential $awscredentials | ? {$_.SnapshotCreateTime -gt (get-date $date -Hour 23 -Minute 0 -Second 00).AddDays(-1) -and $_.SnapshotCreateTime -lt (get-date $date -Hour 0 -Minute 0 -Second 00).AddDays(+1)}|
    select DBInstanceIdentifier, DBSnapshotIdentifier, AvailabilityZone, SnapshotCreateTime | sort SnapshotCreateTime

    Write-Output($snapshots)

        foreach($snaps in $snapshots)
            {

                $ResultingInfrastructure.RDSInstance = Restore-RDSDBInstanceFromDBSnapshot -Region $region -Credential $Role.Credentials -AvailabilityZone $a.AvailabilityZone.ZoneName[1] -DBInstanceIdentifier $DBGroupName -DBSnapshotIdentifier $snaps.DBSnapshotIdentifier -DBSubnetGroupName $DBGroupName

                Start-Sleep 10               

                $tag = New-Object Amazon.EC2.Model.Tag
                $tag.Key = "Name"
                $tag.Value = $snaps.DBInstanceIdentifier
                             
        
            }
    
    Write-AWSInfrastructureAutoSave -ResultantInfrastructure $ResultingInfrastructure -outputFile $FileName

    $publicip = New-EC2Address @BaseParams -Domain "standard"

    Start-sleep 5

    Register-EC2Address @BaseParams -InstanceId $dummy.Instances.instanceId -PublicIp $publicip.PublicIp | Out-Null

    $ResultingInfrastructure.EIP = Get-EC2Address @BaseParams | ?{$_.InstanceId -eq $dummy.Instances.instanceId}

    Write-Output("`r`n" + "Instance Public/Private IP`r`n" + "==========================`r`n")
    (Get-EC2Instance -Instance $dummy.Instances.instanceId @BaseParams).Instances.PublicIpAddress
    (Get-EC2Instance -Instance $dummy.Instances.instanceId @BaseParams).Instances.PrivateIpAddress
    
    Write-AWSInfrastructureAutoSave -ResultantInfrastructure $ResultingInfrastructure -outputFile $FileName
    
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
        <#
        [parameter(Mandatory)]
        $AZ1,
        [parameter(Mandatory)]
        $AZ2,
        #>
        [parameter(Mandatory)]
        [string]
        $FileName

)

    $ResultingInfrastructure = @{}
    $BaseParams = @{
        Region = $region
        Credential = $awscredentials 
        ErrorAction = "Stop"
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
        ErrorAction = "Stop"
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
            Write-Host "Please wait while instance is being terminated.." @StatusColourParams
            Start-Sleep 10

        }

        while($terminateinstance -ne "terminated")
Remove-RDSDBInstance @BaseParams -DBInstanceIdentifier $a.RDSInstance.DBInstanceIdentifier -SkipFinalSnapshot 1
    Do
        {

            $RDSInstance = ((Get-RDSDBInstance -Region $region -Credential $Role.Credentials -DBInstanceIdentifier $a.RDSInstance.DBInstanceIdentifier).DBInstanceStatus)
            Write-Host "Please wait while RDS Instance has been deleted.." @StatusColourParams
            Start-Sleep 30

        }

        while($RDSInstance -eq "deleting")

Start-Sleep 2
Remove-RDSDBSubnetGroup @BaseParams -DBSubnetGroupName $a.RDSInstance.DBSubnetGroup.DBSubnetGroupName
Start-Sleep 2
Remove-EC2Subnet @BaseParams -SubnetId $a.Subnet1.SubnetId -Force
Start-Sleep 2
Remove-EC2Subnet @BaseParams -SubnetId $a.Subnet2.SubnetId -Force
Start-Sleep 2
Write-Host "Removed Subnets $($a.Subnet.SubnetId)" @StatusColourParams
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
             Write-Host "`r`nOperation to delete aborted!" @WarningColourParams
     }

}

Function Show-RDSEndpoint{
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
        ErrorAction = "Stop"
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

    

    $a = get-content -Path $env:TEMP\$FileName | Out-String | ConvertFrom-Json

    Do
        {

            $RDSInstance = ((Get-RDSDBInstance -Region $region -Credential $Role.Credentials -DBInstanceIdentifier $a.RDSInstance.DBInstanceIdentifier).DBInstanceStatus)
            Write-Host "Please wait while RDS Instance is available.." @StatusColourParams
            Start-Sleep 10

        }

     While($RDSInstance -ne "available")
   
   Write-Output((Get-RDSDBInstance -Region $region -Credential $Role.Credentials -DBInstanceIdentifier $a.RDSInstance.DBInstanceIdentifier).Endpoint)

    }

Function Copy-RDSDBSnap{
param(
$restoreregion,
$rdsoriginregion
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


$a = Get-RDSDBSnapshot -Region $rdsoriginregion -Credential $Role.Credentials | Sort-Object SnapshotCreateTime | select -first 1

$c = $a.SourceDBSnapshotIdentifier | %{$_ -match 'arn:aws:rds:[a-z]{2}-[a-z]{3,10}-[0-2]:[0-9]{0,13}:snapshot:' | Out-Null;($Matches[0] -creplace '\D{0,2}-\D{1,10}-\d{1}', $rdsoriginregion) + $a.DBSnapshotIdentifier}

Copy-RDSDBSnapshot -Credential $Role.Credentials -Region $restoreregion -SourceDBSnapshotIdentifier $c -TargetDBSnapshotIdentifier $("RDSTestRestore-$($a.DBSnapshotIdentifier)-$((get-date).ticks)")

start-sleep 3

#check status of RDS snapshot creation

    Do
        {

            $RDSInstance = (Get-RDSDBSnapshot -Credential $Role.Credentials -Region $restoreregion).Status
            Write-Host "Please wait while RDS Snapshot is available.." @StatusColourParams
            Start-Sleep 10

        }

        while($RDSInstance -ne "available")

    write-host "Snapshot is ready.." @WarningColourParams

}
