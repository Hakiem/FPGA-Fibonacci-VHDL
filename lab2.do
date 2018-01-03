#restart -f -nowave
#add wave ALU_inA ALU_inB ALU_out Carry NotEq Eq isOutZero Operation



force ALU_inA   b"00000110"
force ALU_inB   b"00010011"
force Operation b"00"
run 300ns
force ALU_inA   b"00000110"
force ALU_inB   b"00000011"
force Operation b"10"
run 300ns
