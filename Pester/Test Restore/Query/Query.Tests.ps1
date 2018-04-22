<#
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
#>
$qlist =  @{
qlist1 = "RDS" 
qlist2 = "EBS"
qlist3 = "VCenter"}
$testPath = @{
testpath1 = "C:\Users\rrahman\Documents\SDL Info\Backup\AWS\Scripts\Test Restore\Query\$($qlist.qlist1)querylist.json"
testpath2 = "C:\Users\rrahman\Documents\SDL Info\Backup\AWS\Scripts\Test Restore\Query\$($qlist.qlist2)querylist.json"
testpath3 = "C:\Users\rrahman\Documents\SDL Info\Backup\AWS\Scripts\Test Restore\Query\$($qlist.qlist3)querylist.json"
}
$ResultantInfrastructure = "This is a test"
$outputfile = "reztest.json"
$Module = "Query"

Remove-Module -name $Module
Import-Module "C:\Users\rrahman\Documents\SDL Info\Backup\AWS\Scripts\Test Restore\Query\query.psm1"

Describe "Query" {

    Mock Write-AutoSave{
        Add-Content "$env:Temp\$outputfile" -value $ResultantInfrastructure
        return Get-Item "$env:Temp\$outputfile"
    }

    It "Grabs the correct JSON files for the question list" {
        foreach($n in $qlist.Values)
        {
        gc "C:\Users\rrahman\Documents\SDL Info\Backup\AWS\Scripts\Test Restore\Query\$($n)querylist.json" | Should Be $true
        }
    }
    It "Checks if JSON files exist on disk"{
    
        foreach($n in $testPath.Values){            
        gc $n | Should Be $true
         
        }  
    }
    It "Makes sure the JSON files are not empty and is of type Array"{
        foreach($n in $testPath.Values){
        $a = gc $n | select Length      
        $a.Length -ge 5 | should be $true
        $a.GetType().basetype.name -eq "array" | should be $true

       }
    }
    It "Makes sure we can write to the TEMP directory"{

        Write-AutoSave -ResultantInfrastructure $ResultantInfrastructure -outputFile $outputfile | Should Be $true
    }
    It "Makes sure we can remove the file from the TEMP directory"{
        Remove-Item $env:temp\$outputfile
    }
 
}

