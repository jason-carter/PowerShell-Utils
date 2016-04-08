
#
# Parameters - change these as necessary
#
$DbServer = "<DbServer>"
$DbName = "<DbName>"

$DbConnectionString = "Data Source=$($DbServer);Initial Catalog=$($DbName);Integrated Security=True"

$PortfolioFileName = "<FileName>.csv"

#
# Load the latest GBS Hierarchy
#

$SqlCmdText = "select		PortfolioName
from		PortfolioTable
order by	PortfolioName"

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

#
# Load the Spider File
#
$PortfoliosInfile = @()
$GBSPortfolios = @()

Import-Csv $PortfolioFileName |
    ForEach-Object {
        if ($PortfoliosInFile -notcontains $_.DeskCode)
        {
            $PortfoliosInFile += $_.DeskCode
        }
    }


$SqlResult | Where-Object {$_.IsActive -eq "YES" -and $_.SourceSystemInstance -ne "Sophis"} |
    ForEach-Object {
        if ($GBSPortfolios -notcontains $_.name)
        {
            $GBSPortfolios += $_.name
        }
    }

cls

""
"Number of Portfolios in File that are loaded into Spider (according to the GBS Hieararchy):"
""
($PortfoliosInFile | Where-Object {$GBSPortfolios -contains $_} | Sort-Object | measure).Count
""
"Portfolios in File that are loaded into Spider (according to the GBS Hieararchy):"
""
$PortfoliosInFile | Where-Object {$GBSPortfolios -contains $_} | Sort-Object
""
"Comma Seperated for RfB Status:"
""
($PortfoliosInFile | Where-Object {$GBSPortfolios -contains $_} | Sort-Object) -join ", "
