expect -c '
spawn telnet 0.0.0.0 40001
expect "password:" 
send "pwd123456\r"
interact
'
