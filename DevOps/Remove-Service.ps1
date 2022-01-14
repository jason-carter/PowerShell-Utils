$Name = '$(Service.Name)'

# This is the PowerShell >= 6.0 version - nicer than using WMI objects
#  if (Get-Service -Name $Name -ErrorAction SilentlyContinue) {
#   Write-Host "Removing windows service '$Name'..."
#   Get-Service -Name $Name | Remove-Service
#  }
#  else {
#   Write-Host "Windows Service '$Name' does not exist, skipping."
#  }

# This is the PowerShell < 6.0 version - have to use WMI objects
$MRService = (Get-WmiObject win32_service -Filter "name='$Name'")

if ($MRService) {
	Write-Host "Removing windows service '$Name'..."
	$MRService.delete()
}
else {
	Write-Host "Windows Service '$Name' does not exist, skipping"
}