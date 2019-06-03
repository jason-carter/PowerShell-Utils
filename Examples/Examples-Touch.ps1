$dir = "<drive>:\<Path>\<Path>"

get-childitem -file $dir\*.* | foreach-object { $_.LastWriteTime = Get-Date}
