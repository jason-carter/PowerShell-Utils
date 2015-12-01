
#
# Parmaters - change these as necessary
#
$DbServer   = "<DBServer>"
$DbName     = "<DbName>"

$DbConnectionString = "Data Source=$($DbServer);Initial Catalog=$($DbName);Integrated Security=True"


#
# Load a list of users taken from database
#

$SqlCmdText = "select		name
from		<tablename>
where		deleted = 0
order by	name"

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = $DbConnectionString

$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $SqlCmdText
$SqlCmd.Connection = $SqlConnection

$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)

$SqlConnection.Close()

$SqlResult = $DataSet.Tables[0]


# Set up an AD Domain searcher object
$objDomain = New-Object System.DirectoryServices.DirectoryEntry

$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = $objDomain
$objSearcher.PageSize = 1000
$objSearcher.SearchScope = "Subtree"
$objSearcher.PropertiesToLoad.Add("name")

cls

""
"============================================="
"$(get-date -Format yyyyMMdd) USER RECONCILIATION REPORT"
"============================================="
""
"Found $(($SqlResult | measure).Count) active RABONETEU users"
""

#"Users with no AD Account"
#"---------------------------------------------"
#""
#
#$deletedUserCount = 0
#
#$SqlResult | 
#    ForEach-Object {
#        $userName = $_
#        $objSearcher.Filter = "(&(objectCategory=User)(Name=$($userName.name)))"
#        $adUser = $objSearcher.FindAll()
#
#        if ($adUser.Count -eq 0)
#        {
#            $deletedUserCount++
#            "$($userName.name)"
#        }
#    }
#
#""
#"$($deletedUserCount) user(s) require investigation"
#""
#""

"Users Requiring Investigation"
"---------------------------------------------"
""

$noADGroupCount   = 0
$deletedUserCount = 0

$SqlResult | 
    ForEach-Object {
        $userName = $_

        $adUser = (New-Object System.DirectoryServices.DirectorySearcher("(&(objectCategory=User)(Name=$($userName.name)))")).FindOne()

        if ($adUser -eq $null)
        {
            $deletedUserCount++
            "No AD Account: $($userName.name)"
        }
        else
        {
            if (($adUser.GetDirectoryEntry().memberOf | 
                    select-string -Pattern "SingleRiskEngine" | 
                        measure).Count -eq 0)
            {
                $noADGroupCount++
                "Not a member of a SingleRiskEngine AD group: $($userName.name)"
            }
        }
    }

""
"$($deletedUserCount) user$(if ($deletedUserCount -eq 1) {' has'} else {'s have'}) no AD Account"
"$($noADGroupCount) user$(if ($noADGroupCount -eq 1) {' has'} else {'s have'}) no AD group"
""


#
# To Dos
# ======
#

# Need an exceptions list to ignore SRE UAT System User, or should this be removed?
#   - No, this is a report for us to manually action


#$userName = "Song, Q (Qingting)"
#$objSearcher.Filter = "(&(objectCategory=User)(Name=$userName))"
#$adUser = $objSearcher.FindAll()
#$adUser.name
#$adUser.Count
