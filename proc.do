restart -f -nowave
add wave master_load_enable opcode neq eq CLK ARESETN pcSel pcLd instrLd addrMd dmWr dataLd flagLd accSel accLd im2bus dmRd acc2bus ext2bus dispLd aluMd


force clk 0 0, 1 50ns -repeat 100ns
force ARESETN 0
force master_load_enable 1
force opcode 0111
force neq 0 
force eq 0
run 100ns

force opcode 0100
run 100ns

force opcode 0010
run 100ns

force opcode 0011
run 100ns
