Function Register-Watcher
{
    param ($folder)
    $filter = "*.*" #all files
    $watcher = New-Object IO.FileSystemWatcher $folder, $filter -Property @{ 
        IncludeSubdirectories = $false
        EnableRaisingEvents = $true
    }

    $changeAction = [scriptblock]::Create('
        # This is the code which will be executed every time a file change is detected
        $path = $Event.SourceEventArgs.FullPath
        $name = $Event.SourceEventArgs.Name
        $changeType = $Event.SourceEventArgs.ChangeType
        $timeStamp = $Event.TimeGenerated
        Write-Host "The file $name was $changeType at $timeStamp"
    ')
    
    # Watcher: "Changed", "Created", "Deleted" and "Renamed".
    Register-ObjectEvent $Watcher "Created" -Action $changeAction
}

 Register-Watcher "C:\temp"

 #Get-EventSubscriber
 #Unregister-Event -SubscriptionId 2 -Verbose
