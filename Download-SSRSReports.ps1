function GetRSConnection($server, $instance)
{
    #   Create a proxy to the SSRS server and give it the namespace of 'RS' to use for
    #   instantiating objects later.  This class will also be used to create a report
    #   object.

    # Insecure - ask the user for their credentials!
    #$User = "DOMAIN\Username"
    #$PWord = ConvertTo-SecureString -String "Pa$$w0rd" -AsPlainText -Force
    #$c = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $User, $PWord

    $c = Get-Credential

    $reportServerURI = "http://" + $server + "/" + $instance + "/ReportExecution2005.asmx?WSDL"
    
    $RS = New-WebServiceProxy -Class 'RS' -NameSpace 'RS' -Uri $reportServerURI -Credential $c
    $RS.Url = $reportServerURI
    return $RS
}

function GetReport($RS, $reportPath)
{
    #   Next we need to load the report. Since Powershell cannot pass a null string
    #   (it instead just passses ""), we have to use GetMethod / Invoke to call the
    #   function that returns the report object.  This will load the report in the
    #   report server object, as well as create a report object that can be used to
    #   discover information about the report.  It's not used in this code, but it can
    #   be used to discover information about what parameters are needed to execute
    #   the report.
    $reportPath = "/" + $reportPath
    $Report = $RS.GetType().GetMethod("LoadReport").Invoke($RS, @($reportPath, $null))

    # initialise empty parameter holder
    $parameters = @()
    $RS.SetExecutionParameters($parameters, "en-GB") > $null
    return $report
}

function AddParameter($params, $name, $val)
{
    $par = New-Object RS.ParameterValue
    $par.Name = $name
    $par.Value = $val
    $params += $par
    return ,$params
}

function GetReportInFormat($RS, $report, $params, $outputpath, $format)
{
    #   Set up some variables to hold referenced results from Render
    $deviceInfo = "<DeviceInfo><NoHeader>True</NoHeader></DeviceInfo>"
    $extension = ""
    $mimeType = ""
    $encoding = ""
    $warnings = $null
    $streamIDs = $null

    #   Report parameters are handled by creating an array of ParameterValue objects.
    #   Add the parameter array to the service.  Note that this returns some
    #   information about the report that is about to be executed.
    #   $RS.SetExecutionParameters($parameters, "en-us") > $null
    $RS.SetExecutionParameters($params, "en-GB") > $null

    #    Render the report to a byte array.  The first argument is the report format.
    #    The formats I've tested are: PDF, XML, CSV, WORD (.doc), EXCEL (.xls),
    #    IMAGE (.tif), MHTML (.mhtml).
    $RenderOutput = $RS.Render($format,
        $deviceInfo,
        [ref] $extension,
        [ref] $mimeType,
        [ref] $encoding,
        [ref] $warnings,
        [ref] $streamIDs
    )

    #   Determine file name
    $parts = $report.ReportPath.Split("/")
    $filename = $parts[-1] + "."

    switch($format)
    {
        "EXCEL" { $filename = $filename + "xls" } 
        "WORD"  { $filename = $filename + "doc" }
        "IMAGE" { $filename = $filename + "tif" }
        default { $filename = $filename + $format }
    }

    if($outputpath.EndsWith("\\"))
    {
        $filename = $outputpath + $filename
    } else
    {
        $filename = $outputpath + "\" + $filename
    }

    $filename

    # Convert array bytes to file and write
    $Stream = New-Object System.IO.FileStream($filename), Create, Write
    $Stream.Write($RenderOutput, 0, $RenderOutput.Length)
    $Stream.Close()
}

##############################

# PARAMS to change to suit requirements
$Server                 = "<server-name>"
$Instance               = "<server-instance>"
$ReportingArea          = "<reporting-area>"
$BusinessDate           = "01/01/2018"
$BusinessDateMinus1y    = "01/01/2017"
$ReportFormat           = "PDF" # Can be PDF, CSV, EXCEL, WORD, IMAGE
$OutputFolder           = "C:\Tmp"

# ConsolidatedLimitPeriod, CLGraph1GFMSTP, BudgetToVatRReport, CapitalFiguresReport
$Reports    =  @("ReportNameWithOneParam", "BusDate=$($BusinessDate)"),
                ("ReportNameWithTwoParams", "startDate=$($BusinessDate)", "endDate=$($BusinessDate)"),
                ("ReportNameWithDiffParamTypes", "BusinessDate=$($BusinessDate)", "NumberOfDays=7"),
                ("ReportNameWithMultipleParams", "StartDate=$($BusinessDateMinus1y)", "EndDate=$($BusinessDate)", "ParentLevel=2", "ChildLevel=5", "ParentPortfolio=<All>", "ReportType=Short Term")

$RS = GetRSConnection -server $Server -instance $Instance

$Reports |
    ForEach-Object {
        $Report = $_

        $ReportName = $Report[0]
        Write-Host "Extracting Report $($ReportName)"

        $params = @()

        for($i = 1; $i -lt $Report.Length; $i++) {
            # $i=0 is the Report Name, everything after are the parameters in the format Param=Value
            $paramKeyValue = $Report[$i].split('=')
            Write-Host "    Param$($i): $($paramKeyValue[0]); Value: $($paramKeyValue[1])"

            $params = AddParameter -params $params -name $paramKeyValue[0] -val $paramKeyValue[1]
        }

        $report = GetReport -RS $RS -reportPath "$ReportingArea/$ReportName"

        GetReportInFormat -RS $RS -report $report -params $params -outputpath $OutputFolder -format $ReportFormat
    }

Write-Host "DONE!"
