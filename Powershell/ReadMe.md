
<em>Usage Example</em>
```
#Event Logger Usage example

Import-Module EventLogger
 
$eventlogger = @{
Source = 'Automation'
logname = 'Application'
EventId = '1002'
csv = $true
hipchat = $true
script = & { $myInvocation.ScriptName }
}
 
try
{   #Make sure to specify $a = $(Get-CurrentLine) before a command line to track an approximate line for the code.
    $a = $(Get-CurrentLine)
    #This is my functional code
    $c = get-service a* -ErrorAction Stop
    $c = $c | select -first 1
    #This is an example of how to pass info messages that are not triggered by errors.
    write-log @eventlogger -message "$($c.ToString()) is listed" -line $a -info | out-null
    $a = $(Get-CurrentLine)
    get-process tasf -ErrorAction Stop
     
}
catch [Exception]
    {
      #calling the logging function for a general exception
      write-log @eventlogger -message $_ -line $a -error | Out-Null
    }
 
try{
    $a = $(Get-CurrentLine)
    invoke-item d:\ -ErrorAction Stop
    }
catch [Exception]
    {
        #calling the logging function in a new try/catch block for a general exception
        write-log @eventlogger -message $_ -line $a -warning | Out-Null
    }
```
<em>Output Examples</em>

<strong>Hipchat</strong>

![alt text](https://github.com/solarez1/rezwanrahman/blob/master/Hipchat/image2018-5-24_17-0-17.png)

<strong>CSV</strong>

![alt text](https://github.com/solarez1/rezwanrahman/blob/master/Hipchat/image2018-5-24_17-7-7.png)

<strong>EventViewer</strong>
 
![alt text](https://github.com/solarez1/rezwanrahman/blob/master/Hipchat/image2018-5-24_17-8-2.png)
