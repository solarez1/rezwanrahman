$a = Get-EC2Instance -Region eu-west-1 -Credential $Role.Credentials
$a[0]
$write = $a[0].Instances[0].GetType().ToString()
$write | New-Item -Path $env:TEMP\reztesttest.json -ItemType file

#add element to json
$Result = @{}
$Result.Name = "Rez"
$Result.Age = "31"
$Result.Company = "SDL"

$Result | ConvertTo-Json | Set-Content $env:Temp\test.json

$myJson = gc $env:Temp\test.json | Out-string | ConvertFrom-Json 

$myJson | Add-Member -Type NoteProperty -Name "NewElement" -Value "Test"

$myJson | ConvertTo-Json | Add-Content $env:Temp\test.json

$myJson | gm

#Add elements to JSON using functions

function New-User{
    param(
        [parameter(Mandatory)]
        $FileName,
        [String]      
        $FirstName,
        [String]      
        $Address
    )

    $Result=@{}

    $Result.FirstName = $FirstName
    $Result.Address = $Address

    Write-AWSInfrastructureAutoSave -ResultantInfrastructure $Result -outputFile $FileName

}
function New-User2{
    param(
        [parameter(Mandatory)]
        $FileName,
        [String]      
        $LastName,
        [String]      
        $Age
    )

    $Result=@{}

    $Result.LastName = $LastName
    $Result.Age = $Age

    Write-AWSInfrastructureAutoSave -ResultantInfrastructure $Result -outputFile $FileName

}

function Write-AWSInfrastructureAutoSave{
    param(
        [parameter(Mandatory)]
        $ResultantInfrastructure,
        [String]      
        $outputFile
    )
   
    if(Test-Path $env:Temp\$outputFile){
            $myJson = gc $env:Temp\$outputFile | Out-String | ConvertFrom-Json
            $myJson | Add-Member -NotePropertyMembers $Result -Force
            $myJson | ConvertTo-Json | Set-Content $env:Temp\$outputFile -Force
           #$Result | ConvertTo-Json -Depth 2 | Add-Content "$env:Temp\$outputFile"
        Write-Host "Add Content"

    }
    else{
            $Result | ConvertTo-Json -Depth 2 | Set-Content "$env:Temp\$outputFile"
        Write-Host "Set Content"
    }

}

#AWS EC2 with filter
((get-ec2instance -Region eu-west-1 -Credential $Role.Credentials) | ? {$_.Instances.Keyname -like "RezTestRDSKey"}).Instances.instanceid

#Download file
$webclient = New-Object System.Net.WebClient
$url = "http://www.personal.psu.edu/jul229/mini.jpg"
$file = "c:\myNewFilename.jpg"
$webclient.DownloadFile($url,$file)

#get random from an array

$digits = 1,2,3,4,5
$random = Get-Random $digits -Count 4 | Get-Unique
$rdm1 = $random[0]
$rdm2 = $random[1]
$rdm2 = $random[2]