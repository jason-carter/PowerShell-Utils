
#
# To be able to run this script without highlighting it, you need to run the following command:
#
#     Set-ExecutionPolicy -Scope CurrentUser  Unrestricted
#


#### Modules

$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

if (Get-Module -Name HelperFunctions-SSRSReports) {Remove-Module HelperFunctions-SSRSReports}

Import-Module $ScriptPath\HelperFunctions-SSRSReports


#### PARAMS to change to suit requirements

$BaselineServer                 = "<server-name>"
$BaselineInstance               = "<server-instance>"
$BaselineReportingArea          = "<reporting-area>"

$ReleaseCandidateServer         = "<server-name>"
$ReleaseCandidateInstance       = "<server-instance>"
$ReleaseCandidateReportingArea  = "<reporting-area>"


$BusinessDate           = "31/07/2017"
$BusinessDateMinus1y    = "29/07/2016"    # To Do: should be a business date so not so easy to calc
$BusinessDateMinus1m    = "29/06/2017"    # To Do: should be a business date so not so easy to calc
$BusinessDateMinus1d    = "30/07/2017"    # To Do: should be a business date so not so easy to calc
$ReportFormat           = "CSV"         # Can be PDF, CSV, EXCEL, WORD, IMAGE
$OutputFolder           = "C:\Temp"

# An array of reports where each report is an array of parameters
#
#    ReportName1, Param1=Value1, Param2=Value2
#    ReportName2, Param1=Value1
#    ReportName3, Param1=Value1, Param2=Value2, Param3=Value3, Param4=Value4
#
#
# Note: Needs more than one report as Powershell can't figure out the correct type if it's a single array rather than an array of arrays
#
$Reports    =  @("ReportNameWithOneParam", "BusDate=$($BusinessDate)"),
                ("ReportNameWithTwoParams", "startDate=$($BusinessDate)", "endDate=$($BusinessDate)"),
                ("ReportNameWithDiffParamTypes", "BusinessDate=$($BusinessDate)", "NumberOfDays=7"),
                ("ReportNameWithMultipleParams", "StartDate=$($BusinessDateMinus1y)", "EndDate=$($BusinessDate)", "ParentLevel=2", "ChildLevel=5", "ParentPortfolio=<All>", "ReportType=Short Term")


$Credential = Get-Credential
$BaselineRS         = GetRSConnection -server $BaselineServer         -instance $BaselineInstance         -credential $Credential
$ReleaseCandidateRS = GetRSConnection -server $ReleaseCandidateServer -instance $ReleaseCandidateInstance -credential $Credential

Write-Host ""

$Reports |
    ForEach-Object {
        $Report = $_

        $ReportName = $Report[0]
        Write-Host "Report $($ReportName)"

        $params = @()

        for($i = 1; $i -lt $Report.Length; $i++) {
            # $i=0 is the Report Name, everything after are the parameters in the format Param=Value
            $paramKeyValue = $Report[$i].split('=')
            Write-Host "    Param$($i): $($paramKeyValue[0]); Value: $($paramKeyValue[1])"

            $params = AddParameter -params $params -name $paramKeyValue[0] -val $paramKeyValue[1]
        }

        Write-Host ""

        $BaselineFileName = "Baseline-$($ReportName)"

        Write-Host "    Extracting $($BaselineFileName)..."
        $BaselineReport        = GetReport -RS $BaselineRS -reportPath "$BaselineReportingArea/$ReportName"
        GetReportInFormat -RS $BaselineRS -report $BaselineReport -params $params -outputpath $OutputFolder -outputfilename $BaselineFileName -format $ReportFormat

        $ReleaseCandidateFileName = "ReleaseCandidate-$($ReportName)"

        Write-Host "    Extracting $($ReleaseCandidateFileName)..."
        $ReleaseCandidateReport = GetReport -RS $ReleaseCandidateRS -reportPath "$ReleaseCandidateReportingArea/$ReportName"
        GetReportInFormat -RS $BaselineRS -report $ReleaseCandidateReport -params $params -outputpath $OutputFolder -outputfilename $ReleaseCandidateFileName -format $ReportFormat

        Write-Host ""

        Write-Host "    Comparing reports $($BaselineFileName) and $($ReleaseCandidateFileName)"
        $BaselineReport         = Get-Content "$($OutputFolder)\$($BaselineFileName).$ReportFormat"
        $ReleaseCandidateReport = Get-Content "$($OutputFolder)\$($ReleaseCandidateFileName).$ReportFormat"

        Compare-Object $BaselineReport $ReleaseCandidateReport > "$($OutputFolder)\diff_report_$($ReportName).txt"

        Write-Host ""
    }

Write-Host "DONE!"
