
#
# Using random things
#
get-random -Minimum 1 -maximum 100

$users = 'rod','jane','freddy'
get-random $users

get-service | get-random

get-command | get-random

get-service | Out-GridView # passes output to a grid window

#
# Version information
#
Get-Host

#
# Pinging
#
Test-Connection -ComputerName <Server>
ping <Server>

#
# Running programs
#
Start-Process notepad


#
# Web Service usages - need to get this working!
#
$weather = New-WebServiceProxy -URI "http://www.webservicex.net/globalweather.asmx?wsdl"
$weather.GetWeather('London', 'United Kingdom')

$postcode = New-WebserviceProxy -URI "http://www.webservicex.net/uklocation.asmx?wsdl"
$postcode.GetUKLocationByPostcode('SW1A')

#
# Using .Net Classes/Methods
#
[DateTime]::UtcNow
Get-Date

#
# Get events from event viewer
#
$StartDate = get-date 2012-12-18
Get-EventLog -after $StartDate -ComputerName <Server> -logname "App Log" -entrytype Error -instanceId 0 -message "*FAILED TO COMPLETE JOB*" | Out-GridView

Get-EventLog -LogName System -Newest 5 | select-object Time,EntryType,Source,Message | Out-GridView -Title 'System Log'
Get-EventLog -LogName System -Newest 5 | Out-GridView -Title 'System Log'

#
# Logging to file example
#
$log_file = "<drive>:\<Path>\file-monitor.log"
add-content -path $log_file -value ""
add-content -path $log_file -value "$(get-date -format "yyyy-MM-dd HH:mm:ss") File Monitor Started"

#
# Equivalent of Unix WC (Word Count)
#
$dir = "\\<Server>\<Share>$\<Path>\<Path>\<Path>\<FileName>*"
Get-ChildItem $dir | Measure-Object -Line

