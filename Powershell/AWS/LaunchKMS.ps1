Import-Module awspowershell
# set your credentials to access AWS, key you want to encrypt with, and the region the key is stored
$AccessKey = 'AKIAJBK5MY6F2MFC4IWA'
$SecretKey = '9fPfmrO4ICxSN4c1KWp+9Fm3k+gzYGyTHCSpPjuh'
$Region = 'eu-west-1'
$keyID = 'daa1a81b-70f2-4434-8cfd-5795a1e40ff0'
$plainText = 'Swx1@w74k8nc'

# Encrypt some plain text and write to host
$cipherText = Invoke-KMSEncryptText -plainText $plainText -keyID $keyID -Region $Region -AccessKey $AccessKey -SecretKey $SecretKey
Write-host $cipherText

# Decrypt the cipher text and write to host
$plainText = Invoke-KMSDecryptText -cipherText $cipherText -Region $Region -AccessKey $AccessKey -SecretKey $SecretKey
Write-host $plainText