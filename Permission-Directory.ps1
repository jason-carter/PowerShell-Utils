#
# Examples for creating and permissioning folders
#


# Folders to create/permission
$BasePath='C:\temp'
$Folder2Permission = "$($BasePath)\PermissionTest"

# List of users to add to the folder with Modify permissions
$UserNames = ("IIS_IUSRS") # using IIS_IUSRS as an example!


#
# Create a folder (delete if already exists)
#
if ((Test-Path -Path $Folder2Permission))
{
    Remove-Item $Folder2Permission
}

New-Item -ItemType directory $Folder2Permission


#
# Permission that folder with Modify rights for user IIS_IUSRS
#

# Access Rule Parameters
$ARRightModify = "Modify"
$ARRightReadAndExecute = "ReadAndExecute"
$ARInheritanceSettings = "ContainerInherit,ObjectInherit"
$ARPropagationSettings = "None"
$ARType = "Allow"

# Get the ACL
$Acl = ((get-item $Folder2Permission).GetAccessControl('Access'))

foreach ($User in $UserNames)
{
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($User, $ARRightModify, $ARInheritanceSettings, $ARPropagationSettings, $ARType)
    $Acl.SetAccessRule($Ar)
}

Set-Acl -Path $Folder2Permission -AclObject $Acl

$Acl | Format-List


#
# Remove modify rights for user IIS_IUSRS
#

# List file rights for each user before modification
foreach ($Ar in $Acl.Access)
{
    "$($Ar.IdentityReference) : $($Ar.FileSystemRights)"
}

""

foreach ($User in $UserNames)
{
    $Ar2Remove = New-Object System.Security.AccessControl.FileSystemAccessRule($User, $ARRightModify, $ARInheritanceSettings, $ARPropagationSettings, $ARType)
    $Ar2Add    = New-Object System.Security.AccessControl.FileSystemAccessRule($User, $ARRightReadAndExecute, $ARInheritanceSettings, $ARPropagationSettings, $ARType)

    foreach ($Ar in $Acl.Access)
    {
        if ($Ar.FileSystemRights -eq $Ar2Remove.FileSystemRights -and
            $Ar.IdentityReference.ToString().Contains("IIS_IUSRS"))
        {
            "Changing Modify to ReadAndExecute permissions for : $($Ar.IdentityReference)"
            $Acl.RemoveAccessRule($Ar2Remove)
            $Acl.AddAccessRule($Ar2Add)
        }
    }

}
Set-Acl -Path $Folder2Permission -AclObject $Acl

""

# List file rights for each user after modification
foreach ($Ar in $Acl.Access)
{
    "$($Ar.IdentityReference) : $($Ar.FileSystemRights)"
}

""

