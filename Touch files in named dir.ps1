$dir = "Z:\<Path>\<Path>"

get-childitem -file $dir\*.* | foreach-object { $_.LastWriteTime = Get-Date}

#
# Touching folders...
#

$Folder2Archive = "U:\<Path>\<Path>"

ls $Folder2Archive

$folder = get-childitem "U:\<Path>\<Path>"

$folder

$folder | foreach-object {
    $_.LastWriteTime = get-date -Year $_.Name.Substring(0,4) -Month $_.Name.Substring(4,2) -Day $_.Name.Substring(6,2)
}

$folder

$folder.Item(0).LastWriteTime 

get-date -year 2015 -Month 11 -Day 17

