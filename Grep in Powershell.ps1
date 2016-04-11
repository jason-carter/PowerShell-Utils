select-string -Pattern "adminaddportfolio" *.sql

select-string -Pattern "FXRate" *.sql | select-string -Pattern "Insert"
