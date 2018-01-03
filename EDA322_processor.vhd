LIBRARY std;
LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-------------------------------------------------------------------------------------------
-- PROCESSOR INPUTS AND OUTPUTS
-------------------------------------------------------------------------------------------
entity EDA322_processor is
Port (
	externalIn 		: in  STD_LOGIC_VECTOR (7 downto 0); 	-- ?extIn? in Figure 1
	CLK 			: in  STD_LOGIC; 
	master_load_enable 	: in  STD_LOGIC; 
	ARESETN 		: in  STD_LOGIC; 
	pc2seg 			: out STD_LOGIC_VECTOR (7 downto 0); 	-- PC
	instr2seg 		: out STD_LOGIC_VECTOR (11 downto 0); 	-- Instruction register
	Addr2seg 		: out STD_LOGIC_VECTOR (7 downto 0); 	-- Address register
	dMemOut2seg		: out STD_LOGIC_VECTOR (7 downto 0); 	-- Data memory output
	aluOut2seg 		: out STD_LOGIC_VECTOR (7 downto 0); 	-- ALU output
	acc2seg 		: out STD_LOGIC_VECTOR (7 downto 0); 	-- Accumulator
	flag2seg 		: out STD_LOGIC_VECTOR (3 downto 0); 	-- Flags
	busOut2seg 		: out STD_LOGIC_VECTOR (7 downto 0); 	-- Value on the bus
	disp2seg		: out STD_LOGIC_VECTOR (7 downto 0); 	-- Display register
	errSig2seg 		: out STD_LOGIC; 			-- Bus Error signal
	ovf	 		: out STD_LOGIC; 			-- Overflow
	zero			: out STD_LOGIC); 			-- Zero
end EDA322_processor;

ARCHITECTURE dataflow of EDA322_processor is
-------------------------------------------------------------------------------------------
-- ARITHMETIC LOGIC UNIT COMPONENT
-------------------------------------------------------------------------------------------
COMPONENT alu_wRCA IS
 Port ( ALU_inA 	: in  STD_LOGIC_VECTOR (7 downto 0);
        ALU_inB 	: in  STD_LOGIC_VECTOR (7 downto 0);
        ALU_out 	: out STD_LOGIC_VECTOR (7 downto 0);
        Carry 		: out STD_LOGIC;
        NotEq 		: out STD_LOGIC;
        Eq 		: out STD_LOGIC;
        isOutZero 	: out STD_LOGIC;
        operation 	: in  STD_LOGIC_VECTOR (1 downto 0));
END COMPONENT;
-------------------------------------------------------------------------------------------
-- PROCESSOR BUS COMPONENT
-------------------------------------------------------------------------------------------
COMPONENT procBus is
Port ( 
	INSTRUCTION 	: in STD_LOGIC_VECTOR (7 downto 0);
	DATA 		: in STD_LOGIC_VECTOR (7 downto 0);
	ACC 		: in STD_LOGIC_VECTOR (7 downto 0);
	EXTDATA 	: in STD_LOGIC_VECTOR (7 downto 0);
	OUTPUT 		: out STD_LOGIC_VECTOR (7 downto 0);
	ERR 		: out STD_LOGIC;
	instrSEL 	: in STD_LOGIC;
	dataSEL 	: in STD_LOGIC;
	accSEL 		: in STD_LOGIC;
	extdataSEL 	: in STD_LOGIC);
END COMPONENT;
-------------------------------------------------------------------------------------------
-- MEMORY COMPONENT
-------------------------------------------------------------------------------------------
COMPONENT mem_array is
generic (
	DATA_WIDTH	: integer := 12;
	ADDR_WIDTH	: integer := 8;
	INIT_FILE	: string  := "inst_mem.mif");

Port (
	ADDR 		: in STD_LOGIC_VECTOR (ADDR_WIDTH - 1 downto 0);
      	DATAIN 		: in STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
      	CLK 		: in STD_LOGIC;
      	WE		: in STD_LOGIC;
      	OUTPUT    	: out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0));
END COMPONENT;
-------------------------------------------------------------------------------------------
-- A 2-1 MULTIPLEXER COMPONENT
-------------------------------------------------------------------------------------------
COMPONENT mux2to1 is
    PORT( 
	a, b	     	: IN  STD_LOGIC_VECTOR(7 downto 0);
        s          	: IN  STD_LOGIC;
        f          	: OUT STD_LOGIC_VECTOR(7 downto 0));
END COMPONENT;
-------------------------------------------------------------------------------------------
-- RIPPLE CARRY ADDER COMPONENT
-------------------------------------------------------------------------------------------
COMPONENT RCA is
PORT (
	A,B  		: IN STD_LOGIC_VECTOR(7 downto 0);
      	CIN  		: IN STD_LOGIC;
      	COUT 		: OUT STD_LOGIC;
      	SUM    		: OUT STD_LOGIC_VECTOR(7 downto 0));
END COMPONENT;
-------------------------------------------------------------------------------------------
-- REGISTER COMPONENT
-------------------------------------------------------------------------------------------
COMPONENT reg is
GENERIC ( N : integer := 8);

PORT (
	INPUT 				: IN std_logic_vector(n - 1 downto 0);
      	ARESETN, CLK, loadEnable	: IN STD_LOGIC;
      	res 				: OUT std_logic_vector(n - 1 downto 0));
END COMPONENT;
-------------------------------------------------------------------------------------------
-- PROCESSOR STATE CONTROLLER COMPONENT
-------------------------------------------------------------------------------------------
COMPONENT procController is
    Port ( 
	   master_load_enable	: in   STD_LOGIC;
	   opcode 		: in   STD_LOGIC_VECTOR (3 downto 0);
	   neq 			: in   STD_LOGIC;
	   eq 			: in   STD_LOGIC; 
	   CLK 			: in   STD_LOGIC;
	   ARESETN 		: in   STD_LOGIC;
	   pcSel 		: out  STD_LOGIC;
	   pcLd 		: out  STD_LOGIC;
	   instrLd 		: out  STD_LOGIC;
	   addrMd 		: out  STD_LOGIC;
	   dmWr 		: out  STD_LOGIC;
	   dataLd 		: out  STD_LOGIC;
	   flagLd 		: out  STD_LOGIC;
	   accSel 		: out  STD_LOGIC;
	   accLd 		: out  STD_LOGIC;
	   im2bus 		: out  STD_LOGIC;
	   dmRd 		: out  STD_LOGIC;
	   acc2bus 		: out  STD_LOGIC;
	   ext2bus 		: out  STD_LOGIC;
	   dispLd		: out  STD_LOGIC;
	   aluMd 		: out  STD_LOGIC_VECTOR(1 downto 0));
END COMPONENT;

COMPONENT CarryLookAheadAddr IS
    GENERIC(width : integer := 8);
    PORT
        (
         x_in      :  IN   STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
         y_in      :  IN   STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
         carry_in  :  IN   STD_LOGIC;
         sum       :  OUT  STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
         carry_out :  OUT  STD_LOGIC
        );
END COMPONENT;
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCAL VARIABLES/SIGNALS USED TEMPORARILY
----------------------------------------------------------------------------------------------------------------------------------------------------------
signal nxtpc, pc, PCIncrOut, addrFromInstruction, MemDataOutReged, Addr, BusOut, MemDataOut, OutFromAcc, aluOut, IntoAcc : STD_LOGIC_VECTOR (7 downto 0);
signal InstrMemOut, Instruction : STD_LOGIC_VECTOR (11 downto 0);
signal FlagInp, FRegOut, opcode : STD_LOGIC_VECTOR (3 downto 0);
signal aluMd 			: STD_LOGIC_VECTOR (1 downto 0);
signal NEQ, EQ, pcSel, pcLd, instrLd, addrMd, dmWr, dataLd, accLd, dispLd, flagLd, im2bus, dmRd, acc2bus, ext2bus, accSel : STD_LOGIC;

begin

-- FE  : Fetch ->   The  instruction  is  fetched  from  the  instruction  memory  using  the  program counter (PC) as an address.
----------------------------------------------------------------------------------------------------------------------------------------------------------
M1     : mux2to1 	port map (PCIncrOut, BusOut, pcSel, nxtpc);
FE     : reg 		port map (nxtpc, ARESETN, CLK, pcLd, pc);
--R1     : RCA 		port map (pc, "00000000", '1', OPEN, PCIncrOut);
R1     : CarryLookAheadAddr 		port map (pc, "00000000", '1', PCIncrOut, OPEN);
IM     : mem_array 	port map (pc, "000000000000", CLK, '0', InstrMemOut);
FE_DE  : reg 		generic map (12)
	    		port map (InstrMemOut,ARESETN,CLK,instrLd,Instruction);

-- DE  : Decode (DE)  : The instruction is decoded and the data memory is read.
-- DE* : Decode* (DE*): The data memory is read for a second time.
----------------------------------------------------------------------------------------------------------------------------------------------------------
M2     : mux2to1 	port map (addrFromInstruction, MemDataOutReged, addrMd,Addr);
DM     : mem_array 	generic map(8, 8 ,"data_mem.mif")
	     		port map (Addr, BusOut, CLK, dmWr, MemDataOut);
DE_EX  : reg 		port map (MemDataOut, ARESETN, CLK, dataLd, MemDataOutReged);

-- EX  : Execute (EX): The ALU operation takes place and the result is written to ACC.
----------------------------------------------------------------------------------------------------------------------------------------------------------
A1     : alu_wRCA 	port map (OutFromAcc, BusOut, aluOut,FlagInp(3), FlagInp(2), FlagInp(1), FlagInp(0), aluMd);
M3     : mux2to1 	port map (aluOut, BusOut, accSel, IntoAcc);
ACC    : reg 		port map (IntoAcc, ARESETN, CLK, accLd,OutFromAcc);

-- ME  : A previously calculated result(already saved in ACC)is written back to the data memory. 
---------------------------------------------------------------------------------------------------------------------------------------------------------
DISP   : reg 		port map (OutFromAcc, ARESETN, CLK, dispLd, disp2seg);
FReg   : reg 		generic map (4)
			port map (FlagInp, ARESETN,CLK,flagLd,FRegOut);

B      : procBus port map (addrFromInstruction, MemDataOutReged, OutFromAcc, externalIn, BusOut, errSig2seg, im2bus, dmRd, acc2bus, ext2bus);

C      : procController port map (master_load_enable, opcode, NEQ, EQ, CLK, ARESETN,pcSel, pcLd, 
			instrLd, addrMd, dmWr, dataLd, flagLd, accSel, accLd, im2bus, 
			dmRd, acc2bus, ext2bus, dispLd, aluMd);
--------------------------------------------------------------------------------------------------------------------------------------------------------

	busOut2seg 		<= BusOut;
	ovf 			<= FRegOut(3);
	zero 			<= FRegOut(0);
	flag2seg 		<= FRegOut;
	acc2seg 		<= OutFromAcc;
	aluOut2seg 		<= aluOut;
	dMemOut2seg 		<= MemDataOutReged;
	Addr2seg 		<= Addr;
	addrFromInstruction 	<= Instruction (7 downto 0);
	opcode 			<= Instruction (11 downto 8);
	instr2seg 		<= Instruction;
	pc2seg 			<= pc;
	NEQ 			<= FRegOut(2);
	EQ 			<= FRegOut(1);

end dataflow;
