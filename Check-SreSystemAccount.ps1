
cls
""

$userName = '<username>'

"Checking $($userName)..."

$AdUser = (New-Object System.DirectoryServices.DirectorySearcher("(&(objectCategory=User)(samAccountName=$($userName)))")).FindOne()
if ($AdUser -eq $null)
{
    "No AD Account for $($userName)"
}
else
{
    #$AdUser.Properties

    $AdUser
    #$AdUser.GetDirectoryEntry().memberOf

""
    $AdGroups = (New-Object System.DirectoryServices.DirectorySearcher("(&(objectCategory=User)(samAccountName=$($userName)))")).FindOne().GetDirectoryEntry().memberOf

    $AdGroups | 
        select-string -Pattern "<groupname>"


#    ""
#
#    ((New-Object System.DirectoryServices.DirectorySearcher("(&(objectCategory=User)(samAccountName=$($userName)))")).FindOne().GetDirectoryEntry().memberOf | 
#        select-string -Pattern "SingleRiskEngine" | 
#            measure).Count
}

