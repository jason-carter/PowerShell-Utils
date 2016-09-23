# Almost exactly like net use
Get-WmiObject Win32_NetworkConnection

# Powershell version - have to name it but can give it a logical name rather than a drive letter
Get-PSDrive
New-PSDrive -Name J123-TMP -Root \\<server>\<share>$ -PSProvider FileSystem
Remove-PSDrive -Name J123-TMP


# Untested suggestion from the internet
#$net = new-object -comobject Wscript.Network
#$net.mapnetworkdrive("Q:","\\path\to\share",0,"domain\user","password")

#$net.removenetworkdrive("Q:")
