<#
.Synopsis
   Creates a query list based on user selection for test restores
.EXAMPLE
   Write responses to queries and save to a text file
        Write-IncidentLog -filename Response.txt
#>

Function Write-IncidentLog
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [string]$filename,
        [ValidateScript({If ($_ -match '^[a-zA-Z0-9" ,.!"]{10,}$') {
            $True
        } Else {
            Throw "Please enter at least 10 characters!"
        }})]
        [string]$b          

)
 $WarningColourParams = @{
        ForegroundColor = "Red"
        BackgroundColor = "Black"
   }
 $StatusColourParams = @{
        ForegroundColor = "Yellow"
        BackgroundColor = "Black"
   }

try
{

#Dynamically load json query list based on selection
[int]$select = 0
while ($select -lt 1 -or $select -gt 3)
    {

        Write-Host "1. RDS"
        Write-Host "2. EBS"
        Write-Host "3. VCenter"

        [int]$select = Read-Host "Please select a question list using 1 to 3"
    }
switch($select)
    {
        1{$qlist = "RDS"}
        2{$qlist = "EBS"}
        3{$qlist = "VCenter"}
    }

if($select)
    {
        $q = gc "C:\Users\rrahman\Dropbox\Knowledge_Base\Ektron_Troubleshooting\Powershell\Query\$($qlist)querylist.json" | Out-String | ConvertFrom-Json
    }

foreach($n in $q.psobject.properties.value)
    {
        #Questions from the json file are written to the console
        $measureObject = $n | Measure-Object -Character
        $count = $measureObject.Characters  

        $a = Write-Output ("`r`n$($n.ToUpper())`r`n$('='*[int]$count)`r`n")
        Write-AutoSave -ResultantInfrastructure $a -outputFile $filename
        $b = read-host $n
        Write-AutoSave -ResultantInfrastructure $b -outputFile $filename
    }

    #Text file containing questions and answers are displayed to the user to copy/paste into incident
    Write-Host "`r`nPlease copy and paste the text into your incident" @StatusColourParams
    invoke-item $env:temp\$filename
    start-sleep 3
    Remove-Item $env:temp\$filename -Confirm

}
catch
    {

        Write-Host $_ @WarningColourParams
        Remove-Item $env:temp\$filename
    
    }
}
#This function is called when saving the user responses
Function Write-AutoSave{
    param(
        [parameter(Mandatory)]
        $ResultantInfrastructure,
        [String]      
        $outputFile
    )

             
        Add-Content $env:Temp\$outputFile -Value $ResultantInfrastructure -Force -ErrorAction "Stop"

}