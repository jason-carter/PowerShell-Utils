
#
# Show ACL permissions
#

(get-acl c:\tmp).access


#
# Set ACL permissions
#
$folder = 'c:\tmp'
$acl = get-acl $folder
$fsar= New-Object System.Security.AccessControl.FileSystemAccessRule("Authenticated Users", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$Acl.SetAccessRule($fsar)
Set-Acl $folder $Acl


#
# Remove ACL Permissions
#
$folder = 'c:\tmp'
$acl = (Get-Item $folder).GetAccessControl('Access')
$acesToRemove = $acl.Access | ?{ $_.IsInherited -eq $false -and $_.IdentityReference -eq 'Everyone' }
$acl.RemoveAccessRuleAll($acesToRemove)
Set-Acl -AclObject $acl $folder
