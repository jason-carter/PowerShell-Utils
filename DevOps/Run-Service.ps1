$Name = '$(Service.Name)'

if (Get-Service -Name $Name -ErrorAction SilentlyContinue) {
	Write-Host "Starting windows service '$Name'..."
	Start-Service -Name $Name
}
else {
	Write-Host "Windows Service '$Name' does not exist, skipping."
}