restart -f -nowave
add wave a b c d s f

force a 2#00000001
force b 2#00000011
force c 2#00000101
force d 2#00001001
force s 2#00
run 100ns

force a 2#01000001
force b 2#00000111
force c 2#00100101
force d 2#01001001
force s 2#10
run 100ns
