
function Gateway-Download {
    param (
        [string]$TargetURL,
        [string]$TargetFile
    )

    $Count = 1
    while($True){
        $response = Invoke-WebRequest -Uri $TargetURL -Proxy $ProxyURL -ProxyUseDefaultCredentials

        if($response.StatusCode -eq 302){
            $TargetURL = $response.Headers.Location
        }

        if($response.Content -match '<b><a href="(.*?)">here</a></b>') {
            $DownloadUrl = $matches[1]
            break
        }

        Start-Sleep -s $SleepTime
        $Count++
    }

    Remove-Target-File -TargetFile $TargetFile
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TargetFile -Proxy $ProxyURL -ProxyUseDefaultCredentials | Out-Null
}

function Remove-Target-File {
    param (
        [string]$TargetFile
    )

    if(Test-Path $TargetFile) {
        Remove-Item -Path $TargetFile -Force
    }
}

Gateway-Download -TargetURL $args[0] -TargetFile $args[1]
