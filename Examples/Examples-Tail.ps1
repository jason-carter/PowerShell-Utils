
#
# Ensure you connect to the server first using your admin account
#

Get-Content -Path \\<server>\<share>$\<LogFile>.log -Tail 50 -Wait