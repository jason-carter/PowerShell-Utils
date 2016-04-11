
function Expand-ZIPFile($file, $destination)
{
    $shell = new-object -com shell.application
    $zip = $shell.NameSpace($file)
    
    #$unzip = $shell.Namespace($destination)
    #$unzip.CopyHere($zip.items())

    foreach($item in $zip.items())
    {
        $shell.Namespace($destination).copyhere($item)
    }
}

Function DeGZip-File{
    Param(
        $infile,
        $outfile = ($infile -replace '\.gz$','')
        )

    $input = New-Object System.IO.FileStream $inFile, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read)
    $output = New-Object System.IO.FileStream $outFile, ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None)
    $gzipStream = New-Object System.IO.Compression.GzipStream $input, ([IO.Compression.CompressionMode]::Decompress)

    $buffer = New-Object byte[](1024)
    while($true){
        $read = $gzipstream.Read($buffer, 0, 1024)
        if ($read -le 0){break}
        $output.Write($buffer, 0, $read)
        }

    $gzipStream.Close()
    $output.Close()
    $input.Close()
}

# This returns all filenames containing an ampersand
#dir \\<Server>\<Share>$\DataExport\sent | Where-Object { $_.Name.Contains("&") }

# In theory we can then rename them (not tested this)
#dir \\<Server>\<Share>$\DataExport\sent | Where-Object { $_.Name.Contains("&") } | Rename-Item -NewName { $_.Name -replace "&", "and" }

#$SrcDir = "\\<Server>\<Share>$\DataExport\sent"
$SrcDir       = "C:\Temp\sent"
$WorkingDir   = "C:\Temp\ResendingWorkingDir"
$DestDir      = "C:\Temp"
$BusinessDate = "20150626" # Use empty string for all business dates
$InvalidChar  = "&"
$ReplacementChar = "and"

#Get-ChildItem $SrcDir | Where-Object { $_.Name.Contains($BusinessDate) } | Copy-Item $_ , $DestDir\$_
#Copy-Item $SrcDir\* $DestDir
#Get-ChildItem $SrcDir | Where-Object { $_.Name.Contains($BusinessDate) }

#Copy all files for a given business date to the working dir
#Get-ChildItem $SrcDir | Where-Object { $_.Name.Contains($BusinessDate) } | ForEach-Object { Copy-Item $_.FullName $WorkingDir }

#Unzip all gz files
#Get-ChildItem $SrcDir | Where-Object { $_.Name.Contains($BusinessDate) } | ForEach-Object {  Expand-ZIPFile -file $_.FullName -destination $WorkingDir }

#Expand-ZIPFile -file "C:\Temp\Test.gz" -destination $WorkingDir
#DeGZip-File -infile "C:\Temp\Test.gz" -outfile "C:\Temp\Test.csv"

#Rename any files that contain the invalid char
#Get-ChildItem $WorkingDir | Where-Object { $_.Name.Contains($InvalidChar) } | Rename-Item -NewName { $_.Name -replace $InvalidChar,$ReplacementChar }

#Unzip files