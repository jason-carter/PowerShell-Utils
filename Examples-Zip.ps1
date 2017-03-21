add-type -a system.io.compression.filesystem

$basedir2zip = "\\spiderapp\spiderdata$\Reports"
$childdir2zip = "201701"

#Get-ChildItem -Directory "$($basedir2zip)\$($childdir2zip)" #\$($childdir2zip)'

""
"Archiving folder $($basedir2zip)\$($childdir2zip)"
[io.compression.zipfile]::CreateFromDirectory("$($basedir2zip)\$($childdir2zip)", "$($basedir2zip)\$($childdir2zip).zip")

