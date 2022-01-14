$name = "$(App.Name)%%"
Write-Host "Searching for an installed application like $name..."

$app= Get-WmiObject -Class Win32_Product -Filter "Name like '$name'"

if ($null -ne $app) {
    Write-Host "Found the installed application $app.Name, uninstalling..."

    $app.Uninstall()
    Write-Host "Uninstalled."
}
else {
    Write-Host "No application installed with a name like $name, skipping."
}
