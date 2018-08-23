#Requires -Version 2.0

<#
    .PARAMETER  message
     Required. The message body. 10,000 characters max.

    .PARAMETER  color
     The background colour of the HipChat message. One of "yellow", "green", "red", "purple", "gray", or "random". (default: gray)

    .PARAMETER  notify
     Set whether or not this message should trigger a notification for people in the room. (default: false)

    .PARAMETER  apitoken
     Required. This must be a HipChat API token created by a Room Admin for the room you are sending notifications to (default: API key for Test room).

    .PARAMETER  room
     Required. The id or URL encoded name of the HipChat room you want to send the message to (default: Test).

    .PARAMETER  retry
     The number of times to retry sending the message (default: 0)

    .PARAMETER  retrysecs
     The number of seconds to wait between tries (default: 30)
#>

#Required only for Powershell 2
if ($PSVersionTable.PSVersion.Major -lt 3 ){
          
    function ConvertTo-Json([object] $item){
        add-type -assembly system.web.extensions
        $ps_js=new-object system.web.script.serialization.javascriptSerializer
        return $ps_js.Serialize($item)
    }

}

function Send-MSTeams {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)][string]$message,
        [ValidateSet('#A00000', '#00A000', '#A0A000')][string]$color = '#A00000',
        [ValidateSet('Error', 'Information', 'Warning')][string]$title = 'Information',
        [switch]$notify,
        [Parameter(Mandatory = $True)][string]$webhook = "b6c86safafasdasfaff1dc-59e5-4b07-a7fb-b5c9ac2c46d6@df02c2f8-e418-484f-8bd6-c7f2e154f292",   
        [Parameter(Mandatory = $True)][string]$incomingwebhook = "9d5fasfsafsafafasfe92232e244178e464fbe2bc41142/e71f6c21-635a-4639-a6b3-7a2dfe686d3f",
        [int]$retry = 0,
        [int]$retrysecs = 30
    )

    $messageObj = @{
        "@type" = "MessageCard";
        "@context" = "http://schema.org/extensions";
        "title"= $title;
        "text" = $message;
        "themecolor" = $color;
        "notify" = [string]$notify
    }
             
    $uri = "https://outlook.office.com/webhook/$webhook/IncomingWebhook/$incomingwebhook"
    $Body = ConvertTo-Json $messageObj
    $Post = [System.Text.Encoding]::UTF8.GetBytes($Body)
        
    $Retrycount = 0
    
    While($RetryCount -le $retry){
	    try {
            if ($PSVersionTable.PSVersion.Major -gt 2 ){
                $Response = Invoke-WebRequest -Method Post -Uri $uri -Body $Body -ContentType "application/json" -ErrorAction SilentlyContinue            
            }else{                                   
                $Request = [System.Net.WebRequest]::Create($uri)
                $Request.ContentType = "application/json"
                $Request.ContentLength = $Post.Length
                $Request.Method = "POST"

                $requestStream = $Request.GetRequestStream()
                $requestStream.Write($Post, 0,$Post.length)
                $requestStream.Close()

                $Response = $Request.GetResponse()

                $stream = New-Object IO.StreamReader($Response.GetResponseStream(), $Response.ContentEncoding)
                $content = $stream.ReadToEnd()
                $stream.Close()
                $Response.Close()
            }
            Write-Verbose "'$message' sent!"
            Return $true

        } catch {
            Write-Error "Could not send message: `r`n $_.Exception.ToString()"

             If ($retrycount -lt $retry){
                Write-Verbose "retrying in $retrysecs seconds..."
                Start-Sleep -Seconds $retrysecs
            }
        }
        $Retrycount++
    }
    
    Write-Verbose "Could not send after $Retrycount tries. I quit."
    Return $false
}
