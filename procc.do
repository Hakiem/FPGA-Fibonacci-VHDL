restart -f -nowave
add wave -noupdate -divider -height 32 Inputs
add wave -noupdate master_load_enable clk opcode neq eq ARESETN
add wave -noupdate -divider -height 32 Internal_Signals
add wave -noupdate CONTROLLER_FLAGS 
add wave -noupdate CURRENT_STATE 
add wave -noupdate NEXT_STATE 
add wave -noupdate -divider -height 32 Outputs 
add wave -noupdate pcSel pcLd instrLd addrMd dmWr dataLd flagLd accSel accLd im2bus dmRd acc2bus ext2bus dispLd aluMd

force clk 0 0, 1 50ns -repeat 100ns
force ARESETN 0
force master_load_enable 1
force opcode 2#0000
force neq 0 
force eq 0
run 50ns

force ARESETN 1
force opcode 2#1000
run 300ns

force opcode 2#1010
run 300ns

force opcode 2#0011
run 300ns

