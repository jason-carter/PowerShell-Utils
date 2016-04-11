$dir = "Z:\<Path>\<Path>"

get-childitem -file $dir\*.* | foreach-object { $_.LastWriteTime = Get-Date}
