if ( (Get-PSSnapin -Name SqlServerCmdletSnapin100 -ErrorAction SilentlyContinue) -eq $null )
{
    Add-PSSnapin SqlServerCmdletSnapin100
    Add-PSSnapin SqlServerProviderSnapin100
}

Invoke-Sqlcmd -ServerInstance <DBServer> -Database <DBName> -InputFile  $sqlfile | export-csv -delimiter "`t" -notypeinformation -path $report


#Get-PSSnapin -Name SqlServerCmdletSnapin100
