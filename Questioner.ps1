function Test-Out{

#Question 1

Write-Host

"===========================`r`n
Welcome to the Powershell 
-------------------------
Training Day 2 Questions `r`n
============================`r`n"

$ErrorActionPreference = "Stop"
Install-module -Repository CloudOps -Name EventLogger -force
 
$eventlogger = @{
Source = 'Automation'
logname = 'Application'
EventId = '1002'
csv = $true
hipchat = $true
msteams = $true
script = & { $myInvocation.ScriptName }
}

   $WrongColourParams = @{
        ForegroundColor = "Red"
        BackgroundColor = "Black"
   }

   $RightColourParams = @{
        ForegroundColor = "Green"
        BackgroundColor = "Black"
   }
   $QColourParams = @{
        ForegroundColor = "Yellow"
        BackgroundColor = "Black"
   }

[int]$answer = 0
while ($answer -lt 1 -or $answer -gt 3)
{

Write-Host @QColourParams "`r`nWhat is a Powershell module?`r`n"
$a = "1. A collection of cmdlets"
$b = "2. A unit testing terminology"
$c = "3. A built in command"
Write-Host $a
Write-Host $b
Write-Host $c

[int]$answer = Read-Host "Please select the answer using 1 to 3"
}
switch($answer)
{
1{$select = "Correct"}
2{$select = "Incorrect"} 
3{$select = "Incorrect"}
}
if($select -eq "Correct")
{
   Write-Host "`r`n"$select @RightColourParams
}
else
{
   Write-Host "`r`n"$select @WrongColourParams "`r`n"
   $msg = "Answer is $a"
   Write-Host "Answer is $a"
   $line = $(Get-CurrentLine)
   write-log @eventlogger -message $msg -line $line -warning | Out-Null
}

#Question 2

[int]$answer = 0
while ($answer -lt 1 -or $answer -gt 3)
{

Write-Host @QColourParams "`r`nWhat is cmdlet binding?`r`n"
$a = "1. A requirement to write a function in powershell"
$b = "2. A way to provide common parameters to your functions"
$c = "3. A type of cmdlet"
Write-Host $a
Write-Host $b
Write-Host $c

[int]$answer = Read-Host "Please select the answer using 1 to 3"
}
switch($answer)
{
1{$select = "Incorrect"}
2{$select = "Correct"} 
3{$select = "Incorrect"}
}
if($select -eq "Correct")
{
   Write-Host "`r`n"$select @RightColourParams
}
else
{
   Write-Host "`r`n"$select @WrongColourParams "`r`n"
   Write-Host "Answer is $b"
}

#Question 3

[int]$answer = 0
while ($answer -lt 1 -or $answer -gt 3)
{

Write-Host @QColourParams "`r`nWhich of the of the following is NOT a common parameter?`r`n"
 $a = "1. Verbose"
 $b = "2. WhatIf"
 $c = "3. Log"
Write-Host $a
Write-Host $b
Write-Host $c

[int]$answer = Read-Host "Please select the answer using 1 to 3"
}
switch($answer)
{
1{$select = "Incorrect"}
2{$select = "Incorrect"} 
3{$select = "Correct"}
}
if($select -eq "Correct")
{
   Write-Host "`r`n"$select @RightColourParams
}
else
{
   Write-Host "`r`n"$select @WrongColourParams "`r`n"
   Write-Host "Answer is $c"
}

#Question 4

[int]$answer = 0
while ($answer -lt 1 -or $answer -gt 3)
{

Write-Host @QColourParams "`r`nWhat does (Get-module -Name AWSEBSSnap).ExportedCommands do?`r`n"
$a = "1. Shows a list of commands available to the module"
$b = "2. Displays all cmdlets executed within each function"
$c = "3. Invalid Command"
Write-Host $a
Write-Host $b
Write-Host $c

[int]$answer = Read-Host "Please select the answer using 1 to 3"
}
switch($answer)
{
1{$select = "Correct"}
2{$select = "Incorrect"} 
3{$select = "Incorrect"}
}
if($select -eq "correct")
{
   Write-Host "`r`n"$select @RightColourParams
}
else
{
   Write-Host "`r`n"$select @WrongColourParams "`r`n"
   Write-Host "Answer is $a"
}

#Question 5

[int]$answer = 0
while ($answer -lt 1 -or $answer -gt 3)
{

Write-Host @QColourParams "`r`nTrue or False:"'$env:PSModulePath'"shows your module directory? `r`n"
$a = "1. True"
$b = "2. False"
Write-Host $a
Write-Host $b

[int]$answer = Read-Host "Please select the answer using 1 or 2"
}
switch($answer)
{
1{$select = "Correct"}
2{$select = "Incorrect"} 
}
if($select -eq "correct")
{
   Write-Host "`r`n"$select @RightColourParams
}
else
{
   Write-Host "`r`n"$select @WrongColourParams "`r`n"
   Write-Host "Answer is $b"
}


#Question 6

[int]$answer = 0
while ($answer -lt 1 -or $answer -gt 3)
{

Write-Host @QColourParams "`r`nWhat is the difference between a script and a module?`r`n"
$a = "1. A module contains specific functions that is reusable whereas a script performs a single task"
$b = "2. A script contains specific functions that is reusable whereas a module performs a single task"
$c = "3. A script and Module are interchangeable terminologies"
Write-Host $a
Write-Host $b
Write-Host $c

[int]$answer = Read-Host "Please select the answer using 1 to 3"
}
switch($answer)
{
1{$select = "Correct"}
2{$select = "Incorrect"}
3{$select = "Incorrect"} 
}
if($select -eq "Correct")
{
   Write-Host "`r`n"$select @RightColourParams
}
else
{
   Write-Host "`r`n"$select @WrongColourParams "`r`n"
   Write-Host "Answer is $a"
    }
}