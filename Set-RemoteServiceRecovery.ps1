function Set-RemoteServiceRecovery
{
    [alias('Set-Recovery')]
    param
    (
        [string] [Parameter(Mandatory=$true)] $ServiceDisplayName,
        [string] [Parameter(Mandatory=$true)] $Server,
        [string] $action1 = "restart",
        [int] $time1 =  120000, # in miliseconds
        [string] $action2 = "restart",
        [int] $time2 =  120000, # in miliseconds
        [string] $actionLast = "", # empty string is 'Take No Action'
        [int] $timeLast = 30000, # in miliseconds
        [int] $resetCounter = 86400 # in seconds (86400 = 1 Day)
    )
    $serverPath = "\\" + $server
    $services = Get-CimInstance -ClassName 'Win32_Service' -ComputerName $Server| Where-Object {$_.DisplayName -imatch $ServiceDisplayName}
    $action = $action1+"/"+$time1+"/"+$action2+"/"+$time2+"/"+$actionLast+"/"+$timeLast
    foreach ($service in $services){
        # https://technet.microsoft.com/en-us/library/cc742019.aspx
        $output = sc.exe $serverPath failure $($service.Name) actions= $action reset= $resetCounter
    }
}

Set-ServiceRecovery -ServiceDisplayName "<servicename>" -Server "<servername>"
