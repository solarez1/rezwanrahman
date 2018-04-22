function Invoke-KMSDecryptText
(
    [Parameter(Mandatory=$true,Position=1,HelpMessage='CipherText base64 string to decrypt')]
    [string]$cipherText,
    [Parameter(Mandatory=$true,Position=2)]
    [string]$region,
    [Parameter(Position=3)]
    [string]$AccessKey,
    [Parameter(Position=4)]
    [string]$SecretKey
)
{
    # memory stream
    $encryptedBytes = [System.Convert]::FromBase64String($cipherText)
    $encryptedMemoryStreamToDecrypt = New-Object System.IO.MemoryStream($encryptedBytes,0,$encryptedBytes.Length)
    # splat
    $splat = @{CiphertextBlob=$encryptedMemoryStreamToDecrypt; Region=$Region;}
    if(![string]::IsNullOrEmpty($AccessKey)){$splat += @{AccessKey=$AccessKey;}}
    if(![string]::IsNullOrEmpty($SecretKey)){$splat += @{SecretKey=$SecretKey;}}
    # decrypt
    $decryptedMemoryStream = Invoke-KMSDecrypt @splat
    $plainText = [System.Text.Encoding]::UTF8.GetString($decryptedMemoryStream.Plaintext.ToArray())
    return $plainText
}