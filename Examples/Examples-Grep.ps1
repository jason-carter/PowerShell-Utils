
#select-string  -Pattern "DataMart" *.sql

#select-string -Pattern "<ss1>" *.sql | select-string -Pattern "<ss2>"

Get-ChildItem -Recurse *.sql | select-string  -Pattern "DataMart"