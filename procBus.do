restart -f -nowave
add wave INSTRUCTION DATA ACC EXTDATA instrSEL accSEL dataSEL extdataSEL OUTPUT ERR

force INSTRUCTION 2#00111000
force DATA 2#00000001
force ACC 2#00000010
force EXTDATA 2#00000011
force instrSEL 0
force accSEL 0
force dataSEL 0
force extdataSEL 0
run 100ns

force instrSEL 1
run 100ns

force instrSEL 0
force dataSEL 1
run 100ns

force dataSEL 0
force accSEL 1
run 100ns

force accSEL 0
force extdataSEL 1
run 100ns

force accSEL 1
run 100ns
