<#
.Synopsis
   Creates an AD user for VDI
.EXAMPLE
   Create-AdUser [[-csvpath] <String[]>] [[-from] <String@sdl.com[]> [[-cc]<String[]>] [[-html] <String[]>]]
   Usage Example: Create-AdUser -csvpath "C:\TestFolder\Test.csv" -from "no-reply@sdl.com" -cc "testuser2@sdl.com" -html "C:\users\rrahman\Desktop\html\fas.html" 
   Please note this html file has placeholders which should be used as a template for subsequent HTML files.
.AUTHOR
    Rezwan Rahman SDL Plc
#>

#Class Function to Create AD Password
Function New-ADPassword(){
 
        $generatedPassword = $null
        $meetsWinPasswordPolicy = $false
 
        while(!$meetsWinPasswordPolicy)
        {
            $chars = [Char[]]"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!&%*"
            $passwordStr = ($chars | Get-Random -Count 20) -Join ""
 
            if($passwordStr -match "[0-9]" -and $passwordStr -cmatch "[a-z]" -and $passwordStr -cmatch "[A-Z]" -and $passwordStr -cmatch "[!|&|%|\*]")
            {
                $meetsWinPasswordPolicy = $true
            }
         
        }
        Return $passwordStr
}

#Class Function to create new AD User
Function Create-ADUser{
Param(
$csvpath = "C:\Users\rrahman\Documents\Powershell Scripts\users.csv",
$html = "C:\users\rrahman\Desktop\html\fas.html",
[Parameter(Mandatory=$true)]
[string[]]$cc
)
$StatusColourParams = @{
    ForegroundColor = "Yellow"
    BackgroundColor = "Black"
}
try{

$csvout = import-csv $csvpath
foreach($b in $csvout){
$firstName = $b | select -ExpandProperty "First Name"
$lastName = $b | select -ExpandProperty "Last Name"
$emailadd = $b | select -ExpandProperty Email

if(-not ($check =Get-ADUser -Filter {UserPrincipalName -eq $emailadd} -SearchBase "OU=Restricted, OU=VDI, DC=mr, DC=sdlproducts, DC=com")){
#Generate Random Password
$UserPass = New-ADPassword

Write-Host "`r`nCreating the following:`r`n" @StatusColourParams
Write-Output $firstName
Write-Output $(Line-Separator -text $firstName)
Write-Output $lastName
Write-Output $(Line-Separator -text $lastName)
Write-Output $emailadd
Write-Output $(Line-Separator -text $emailadd)
Write-Output $UserPass
Write-Output $(Line-Separator -text $UserPass)

#$password = New-EphemeraSecret -Secret $UserPass

#replace the email domain with the vdi email domain for login
$emailadd -match "@\S+" | Out-Null;
$login = $emailadd.Replace($matches[0],"@mr.sdlproducts.com")  

#Create name alias
$username = $emailadd.Replace("@mr.sdlproducts.com"," ")

#Create new AD User with a secure string password
$PasswordSecureString = ConvertTo-SecureString $UserPass -AsPlainText -Force
New-ADUser -Name "$firstName $lastName" -GivenName $firstName -Surname $lastName -SamAccountName $username -UserPrincipalName $emailadd -AccountPassword $PasswordSecureString -ErrorAction Stop -ChangePasswordAtLogon $false -path "OU=Restricted, OU=VDI, DC=mr, DC=sdlproducts, DC=com" -Enabled $true

$ClientEmail = Create-Email -To $login -FirstName $firstName -LastName $lastName -htmlfile $html #-Password $password

Send-MailMessage -From $ClientEmail.from -To $emailadd -SmtpServer "smtp.sdlproducts.com" -Subject "Munich Re SDL Secure Translation Account setup" -Body $ClientEmail.body -BodyAsHtml -Cc $cc -Priority "High"
        }
    Else{
        Write-Warning "Account already exists! $emailadd`r`n"      
       }
    }
  }
catch{
    Write-Warning "Failed to create user: $($error[0])"
    }
}


#Class Function to Create Line Separator
Function Line-Separator(
$text
)
{

$measureObject = $text | Measure-Object -Character
$count = $measureObject.Characters
$line = $('-'*[int]$count)
return $line

}


#Class Function to Send Email to End User
Function Create-Email{
Param(
$To,
$from = "no-reply@sdlproducts.com",
$FirstName,
$LastName,
$htmlfile
#$Password
)

$html = get-content $htmlfile -Raw | Out-String
$html | Where-Object{$_ -cmatch "#Name"}
$content = $html.Replace("#Name", $FirstName)
$body = $content.Replace("#Username", $To)

return @{
to = $To;
body = $body;
from = $from;
    }
}