$Name = '$(Service.Name)'

if (Get-Service -Name $Name -ErrorAction SilentlyContinue) {
	Write-Host "Stopping windows service '$Name'..."
	Stop-Service -Name $Name
}
else {
	Write-Host "Windows Service '$Name' does not exist, skipping."
}