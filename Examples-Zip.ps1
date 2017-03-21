#
# Old style zipping, but needs .net 4.5
#

add-type -a system.io.compression.filesystem

$basedir2zip = "\\<server>\<share>$\<parent-dir>"
$childdir2zip = "<child-dir"

#Get-ChildItem -Directory "$($basedir2zip)\$($childdir2zip)" #\$($childdir2zip)'

""
"Archiving folder $($basedir2zip)\$($childdir2zip)"
[io.compression.zipfile]::CreateFromDirectory("$($basedir2zip)\$($childdir2zip)", "$($basedir2zip)\$($childdir2zip).zip")

