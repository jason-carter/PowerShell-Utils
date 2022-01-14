
if (Get-Service -Name '$(Service.Name)' -ErrorAction SilentlyContinue) {
	Write-Host "WARNING: Windows service '$(Service.Name)' already exists!"
	return
}

$UserName = '$(Service.User)'
$PWord = ConvertTo-SecureString -String '$(Service.User.Password)' -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName, $PWord

$params = @{
	Name = '$(Service.Name)'
	BinaryPathName = '$(Service.InstallPath)'
	DisplayName = '$(Service.DisplayName)'
	Description = '$(Service.Description)'
	StartupType = '$(Service.StartupType)'
	Credential = $Credential
}
New-Service @params
