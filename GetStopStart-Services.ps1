#Log on to admin permissioned powershell:
#
#    runas /user:<domain>\<AdminAccount> "powershell"


get-service "<ServiceName>" -ComputerName <ServerName>
stop-service $(get-service "<ServiceName>" -ComputerName <ServerName>)
start-service $(get-service "<ServiceName>" -ComputerName <ServerName>)
