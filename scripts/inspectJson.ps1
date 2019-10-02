param(
    [string] $dir = '..\pipelines'
)

# Make parameters readable in the code
$pipelinesDirectory = $dir
$trustable = $true

# static variables
$tab = '     '

if(!(Test-Path -Path $pipelinesDirectory -PathType Container)){
    Write-Host "Expected path [$($pipelinesDirectory)] not found. Please check your repo setup and change the [dir] parameter accordingly."
    exit 1
}

# Printing status
Write-Host "Directory exists!"

$jsonFiles = Get-ChildItem $pipelinesDirectory -Filter *.json

# Printing status
Write-Host "Files to check: $($jsonFiles.Count)"
Write-Host 'Beginning files loop...'

$jsonFiles |
ForEach-Object{
    # Context
    Write-Host "$($tab)File name: $($_.Name)"
    $pipelineName = $_.Name

    $json = Get-Content $_ | Out-String | ConvertFrom-Json

    # Printing status
    Write-Host "$($tab)Activities in pipeline: $($json.properties.activities.Count)"
    Write-Host "$($tab)Beginning activities loop..."

    $json.properties.activities |
    ForEach-Object{
        Write-Host "$($tab)$($tab)Activity name: $($_.name)"
        $activityName = $_.name

        if($_.typeProperties.enableStaging -eq $true){
            Write-Host "$($tab)$($tab)The pipeline [$($activityName)] in the pipeline [$($pipelineName)] is NOT trustable!!!"
            $trustable = $false
        }
    }
}

Write-Host ''
if($trustable -eq $true){
    Write-Host 'You are not a moron, David, good job.'
    exit 0
}
else{
    Write-Host 'Pipeline(s) found to be not trustable. Please fix the pipelines mentioned and try checking in again.'
    exit 1
}