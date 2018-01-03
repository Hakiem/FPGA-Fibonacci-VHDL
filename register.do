restart -f -nowave
add wave input loadEnable ARESETN clk res

force clk 0 0, 1 50ns -repeat 100ns
force aresetn 0
force loadenable 0
force input 2#00001111
run 100ns

force aresetn 1
run 100ns

force loadenable 1
run 100ns

force loadenable 0
force input 2#11110000
run 100ns

force loadenable 1
run 100ns

force aresetn 0
run 100ns