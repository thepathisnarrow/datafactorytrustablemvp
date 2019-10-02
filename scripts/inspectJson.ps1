param(
    [string] $dir = '..\pipeline'
)

# Make parameters readable in the code
$pipelinesDirectory = $dir
$trustable = $true

# static variables
$tab = '     '

$dirExists = Test-Path -Path $pipelinesDirectory -PathType Container
if($dirExists -eq $false){
    Write-Host "Expected path [$($pipelinesDirectory)] not found. Please check your repo setup and change the [dir] parameter accordingly."

    #Get-ChildItem -Recurse |Where-Object {$_.PSIsContainer}

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
    Write-Host "$($tab)File path: $($_.FullName)"
    $pipelineName = $_.Name

    $json = Get-Content $_.FullName | Out-String | ConvertFrom-Json

    # Printing status
    Write-Host "$($tab)Activities in pipeline: $($json.properties.activities.Count)"
    Write-Host "$($tab)Beginning activities loop..."

    $json.properties.activities |
    ForEach-Object{
        Write-Host "$($tab)$($tab)Activity name: $($_.name)"
        $activityName = $_.name

        if($_.typeProperties.enableStaging -eq $true){
            Write-Host "$($tab)$($tab)The activity [$($activityName)] in the pipeline [$($pipelineName)] is NOT trustable!!!"
            $trustable = $false
        }
    }
}

Write-Host ''
if($trustable -eq $true){
    Write-Host 'Your pipelines have passed the specified checks necessary to be considered "trustable".'
    exit 0
}
else{
    Write-Host 'Pipeline(s) found to be not trustable. Please fix the pipelines mentioned and try checking in again.'
    exit 1
}