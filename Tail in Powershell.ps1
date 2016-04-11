
#
# Ensure you connect to the server first using your admin account
#

Get-Content -Path \\<server>\<share>$\Service.log -Tail 50 -Wait

Get-Content -Path \\<server>\<share>$\<LogFile>.log -Tail 50 -Wait