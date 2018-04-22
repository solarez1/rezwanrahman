$here = Split-Path -Parent $MyInvocation.MyCommand.Path
<#
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
#>
$instanceid = "i-9f161f4"
$outputFile = "RezVpc.json"
$testPath = "$env:Temp\$outputFile"
$items = "1"
$wildcard = "*"
$date = "2016-06-13"
$vpcid = "vpc-12e4da77"
$AZ = "eu-west-1a"
$Module = "AWSEBSSnap"
$Volumeid = "vol-a035a362"
$awscredentials = $Role.Credentials
$region = "eu-west-1"
$VPCCIDR = '10.0.0.0/16'

$CoreParams = @{
    region = "eu-west-1"
    awscredentials = $Role.Credentials
    }
 $BaseParams = @{
        Region = $region
        Credential = $awscredentials 
    }
Remove-Module -name $Module
Import-Module 'C:\Users\rrahman\Dropbox\Knowledge_Base\Ektron_Troubleshooting\AWS_Test_Scripts\AWSEBSSnap.psm1'
#'C:\users\rrahman\Documents\SDL Info\Backup\AWS\Scripts\AWSEBSSnap.psm1'

Describe "AWSEBSSnap" {

#Function New-EC2VPC{}
    
    Mock New-EC2VPC -ModuleName $Module{
        return $vpcid    
    }

    Mock Get-EC2AvailabilityZone -ModuleName $Module{
        return $AZ    
    }   
    Mock Write-AWSInfrastructureAutoSave -ModuleName $Module{
        return $null
    }
 
    set-content $testPath -Value RezTest

    It "Tests AWS Credentials"{
        $a = (Get-AWSCredentials)
        $a.GetType().BaseType.Name | Should Be "AWSCredentials"
    }
    It "Shows Snapshots" {
        $a = Show-InstancesbyEBS @CoreParams -items $items -wildcard $wildcard -date $date 

        $items -ge "1" | should Be $true
        $a | Should Not BeNullOrEmpty
    }
    It "Shows Latest Snapshots by Instance Id"{
        $a = Show-LatestSnapshots @CoreParams  -instanceid $instanceid -date $date
        $a | Should Be $true
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
    It "Gets Instance"{
        $a = Get-EC2Instance @BaseParams
        $a.Instances.Instanceid -like "i-*" | Should Be $true
    }
    It "Gets Availability Zone"{
        $a = get-ec2availabilityzone
        $a | Should Match '^[a-z]{2}\-[a-z]{1,20}\-[0-9]{1}[a-c]'
    }
    It "Confirms that we can create a VPC"{
        $a = New-EC2Vpc @BaseParams -CidrBlock $VPCCIDR
        $a -like 'vpc*' | Should Be $true
    }

}
