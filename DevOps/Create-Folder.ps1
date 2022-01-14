$Path="$(Folder.Name)"

if (!(Test-Path $Path))
{
	Write-Host "Creating folder $Path..."
	New-Item -itemType Directory $Path
}
else
{
	Write-Host "Folder $Path already exists"
}