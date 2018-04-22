<#
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
#>
$instanceid = "i-21dbafad"
$outputFile = "RezVpc.json"
$testPath = "$env:Temp\$outputFile"
$items = "1"
$wildcard = "*"
$date = "2016-04-18"
$vpcid = "vpc-12e4da77"
$AZ = "eu-west-1a"
$Module = "RestoreRDSSnapshot"
$amiid = "ami-7de87d0e"

$CoreParams = @{
    region = "eu-west-1"
    awscredentials = $Role.Credentials
    }
 $BaseParams = @{
        Region = $region
        Credential = $awscredentials 
    }
Remove-Module -name $Module
Import-Module 'C:\Users\rrahman\Documents\SDL Info\Backup\AWS\Scripts\Test Restore\RDSRestore\RestoreRDSSnapshot.psm1'

    Describe "RestoreRDSSnapshot" {
 
    Mock Invoke-VPC{
        $(Get-Content C:\RezTestVPC-RDS.json | Out-String | ConvertFrom-Json)
        return $a
    }
    Mock Invoke-EC2AndAttachVolume{
        $(Get-Content C:\RezTestVPC-RDS.json | Out-String | ConvertFrom-Json)
        return $a
    }
    Mock Restore-RDSDBInstanceFromDBSnapshot{
        $(Get-Content C:\RezTestVPC-RDS.json | Out-String | ConvertFrom-Json)
        return $a
    }

    set-content $testPath -Value RezTest

    It "Tests AWS Credentials"{
        $a = (Get-AWSCredentials)
        $a.GetType().BaseType.Name | Should Be "AWSCredentials"
    }
    It "Gets RDS DB Snapshot"{
        $a = Show-RDSSnapshot @CoreParams -items $items -date $date
        $a.Count | Should Not BeNullOrEmpty
    }
    It "Gets latest AMI ID per region"{
        $a = Get-EC2ImageByName -name Windows_2012_BASE -Region $BaseParams.Region | select name, imageid, @{label="Region"; Expression ={$region}}
        $b = Get-EC2ImageByName -Name Windows_2012_SQL_SERVER_STANDARD_2014 -Region $BaseParams.Region | select name, imageid, @{label="Region"; Expression ={$region}} 
        $c = Get-EC2ImageByName -name Windows_Server-2012-R2_RTM-English-64Bit-Core* -Region $BaseParams.Region | select name, imageid, @{label="Region"; Expression ={$region}} -first 1 

        $a.Name -like "*Base*" | Should Be $true
        $b.Name -like "*SQL*" | Should Be $true
        $c.Name -like "*Core*" | Should Be $true
        $a.ImageId -like "*ami-*" | Should Be $true
        $b.ImageId -like "*ami-*" | Should Be $true
        $c.ImageId -like "*ami-*" | Should Be $true
        $BaseParams.Region | Should Match ([regex]::Escape("eu-west"))    
    }
    It "Checks if JSON file exists or not"{
        $a = Test-Path $testPath                
        $a | Should Be $true      
    }
    It "Gets Availability Zone"{
        $a = get-ec2availabilityzone
        $a.zonename | Should Match '^[a-z]{2}\-[a-z]{1,20}\-[0-9]{1}[a-c]'
    }
    It "Checks if Invoke-VPC executes successfully"{      
        $a = Invoke-VPC @CoreParams -RDPSourceCIDR 0.0.0.0/0 -FileName $outputFile
        $a.vpc.vpcid -match "vpc*" | Should Be $true
    }
    It "Checks if Invoke-Ec2andAttachVolume executes successfully"{
        $a = Invoke-EC2AndAttachVolume @CoreParams -ImageId $amiid -instanceType m3.large -date $date -instanceid $instanceid -FileName $outputFile
        $a.Instance.Instances.instanceid | Should Match ([regex]::Escape("i-")) 
    }
    It "Checks if RDS instance gets created successfully"{
        $a = Restore-RDSDBInstanceFromDBSnapshot @BaseParams -AvailabilityZone $a.AvailabilityZone.ZoneName[1] -DBInstanceIdentifier $DBGroupName -DBSnapshotIdentifier $snaps.DBSnapshotIdentifier -DBSubnetGroupName $DBGroupName
        $a.RDSInstance.DBInstanceIdentifier | Should Match ([regex]::Escape("COC-"))
    }
}