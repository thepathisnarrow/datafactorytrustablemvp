get-ChildItem '..\pipeline\*.json' |
ForEach-Object{
    $json = Get-Content $_ | Out-String | ConvertFrom-Json

    Get-ChildItem $json.properties.activities |
    ForEach-Object{
        if($_.typeProperties.enableStaging -eq $true){
            Write-Host 'This is NOT trustable!!!'
            exit 1
        }
    }
}

Write-Host 'You are not a moron, David, good job.'