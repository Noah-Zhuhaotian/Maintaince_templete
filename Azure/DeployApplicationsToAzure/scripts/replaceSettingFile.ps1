Param(
    [string]$sourceFile,
    [string]$targetFile
)

Move-Item -Path $sourceFile -Destination $targetFile -Force