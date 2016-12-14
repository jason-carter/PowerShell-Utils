#
# Examples for creating and permissioning folders
#


# Folders to create/permission - using parent\child structure to test inheritance
$BasePath="C:\temp\temp"
$ParentPath="$($BasePath)\temp"
$ChildPath = "$($ParentPath)\PermissionTest"

# List of users to add to the folder with Modify permissions
#$UserNames = ("BUILTIN\IIS_IUSRS",
#              "BUILTIN\Administrators",
#              "NT AUTHORITY\SYSTEM",
#              "BUILTIN\Users",
#              "NT AUTHORITY\Authenticated Users")
$UserNames = ("IIS_IUSRS",
              "Administrators",
              "SYSTEM",
              "Users",
              "Authenticated Users")


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
$Acl = get-item $Folder2Permission | get-acl

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

# Remove inheritance
#
# SetAccessRuleProtection(isProtected, preserveInheritance) params:
#
#   isProtected
#     True  – Protect rules from being changed by inheritance
#     False – Allow inheritance to change the rules
#
#   preserveInheritance
#     True  – Preserve inheritance
#     False – Remove inherited rules
#
#$Acl.SetAccessRuleProtection($true,$false)

# List file rights for each user before modification
$Acl.Access | %{"$($_.IdentityReference) : $($_.FileSystemRights)"}


#$Acl.Access |where {$_.IdentityReference.ToString().Contains($User)} | %{$Acl.RemoveAccessRule($_)}

""

foreach ($User in $UserNames)
{
    $Ar2Remove = New-Object System.Security.AccessControl.FileSystemAccessRule($User, $ARRightModify, $ARInheritanceSettings, $ARPropagationSettings, $ARType)
    $Ar2Add    = New-Object System.Security.AccessControl.FileSystemAccessRule($User, $ARRightReadAndExecute, $ARInheritanceSettings, $ARPropagationSettings, $ARType)

    foreach ($Ar in $Acl.Access)
    {
        if ($Ar.FileSystemRights -eq $Ar2Remove.FileSystemRights -and
            $Ar.IdentityReference.ToString().Contains($User))
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
$Acl.Access | %{"$($_.IdentityReference) : $($_.FileSystemRights)"}

""

