function Invoke-KMSEncryptText
(
    [Parameter(Mandatory=$true,Position=1,HelpMessage='PlainText to Encrypt')]
    [string]$plainText,
    [Parameter(Mandatory=$true,Position=2,HelpMessage='GUID of Encryption Key in KMS')]
    [string]$keyID,
    [Parameter(Mandatory=$true,Position=3)]
    [string]$region,
    [Parameter(Position=4)]
    [string]$AccessKey,
    [Parameter(Position=5)]
    [string]$SecretKey
)
{
    # memory stream
    [byte[]]$byteArray = [System.Text.Encoding]::UTF8.GetBytes($plainText)
    $memoryStream = New-Object System.IO.MemoryStream($byteArray,0,$byteArray.Length)
    # splat
    $splat = @{Plaintext=$memoryStream; KeyId=$keyID; Region=$Region;}
    if(![string]::IsNullOrEmpty($AccessKey)){$splat += @{AccessKey=$AccessKey;}}
    if(![string]::IsNullOrEmpty($SecretKey)){$splat += @{SecretKey=$SecretKey;}}
    # encrypt
    $encryptedMemoryStream = Invoke-KMSEncrypt @splat
    $base64encrypted = [System.Convert]::ToBase64String($encryptedMemoryStream.CiphertextBlob.ToArray())
    return $base64encrypted
}