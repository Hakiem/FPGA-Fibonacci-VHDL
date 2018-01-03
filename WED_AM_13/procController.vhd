library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity procController is 
    Port ( 		master_load_enable: in STD_LOGIC;
	opcode 	: in  STD_LOGIC_VECTOR (3 downto 0);
	neq 	: in STD_LOGIC;
	eq 	: in STD_LOGIC; 
	CLK 	: in STD_LOGIC;
	ARESETN : in STD_LOGIC;
	pcSel 	: out  STD_LOGIC;	-- select if source should come from the Bus or ALU counter
	pcLd 	: out  STD_LOGIC;	-- load enable signal of PC counter
	instrLd : out  STD_LOGIC;	-- load enable signal of the register, keeps the instruction read.
	addrMd 	: out  STD_LOGIC;	-- controls the data memory's index that can be input by two different sources
	dmWr 	: out  STD_LOGIC;	-- enables the write function of the data memory, when set
	dataLd 	: out  STD_LOGIC;	-- load enable signal for DE/EX that saves the read memory value
	flagLd 	: out  STD_LOGIC;	-- load enable signal of FReg that saves the flags
	accSel 	: out  STD_LOGIC;	-- controls the input source for the accumulator
	accLd 	: out  STD_LOGIC;	-- load enable signal of the accumulator
	im2bus 	: out  STD_LOGIC;	-- Control signal to the Bus
	dmRd 	: out  STD_LOGIC;	-- Enables the read function of the data memory, when set / -- Control signal to the Bus
	acc2bus : out  STD_LOGIC;	-- Control signal to the Bus
	ext2bus : out  STD_LOGIC;	-- Control signal to the Bus
	dispLd	: out STD_LOGIC;	-- load enable of the display register
	aluMd 	: out STD_LOGIC_VECTOR(1 downto 0));	-- Determines the ALU operation
end procController;

architecture Behavioral of procController is

-- Our ChAcc has the following realised states
TYPE STATE IS (FETCH, DECODE, DECODE2, EXECUTE, MEMORY);
SIGNAL CONTROLLER_FLAGS			: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL CURRENT_STATE, NEXT_STATE 	: STATE;

begin

	pcsel    <= CONTROLLER_FLAGS(0);
    	pcld     <= CONTROLLER_FLAGS(1);
    	instrld  <= CONTROLLER_FLAGS(2);
    	addrmd   <= CONTROLLER_FLAGS(3);
    	dmwr     <= CONTROLLER_FLAGS(4);
    	datald   <= CONTROLLER_FLAGS(5);
    	flagld   <= CONTROLLER_FLAGS(6);
    	accsel   <= CONTROLLER_FLAGS(7);
    	accld    <= CONTROLLER_FLAGS(8);
    	im2bus   <= CONTROLLER_FLAGS(9);
    	dmrd     <= CONTROLLER_FLAGS(10);
    	acc2bus  <= CONTROLLER_FLAGS(11);
    	ext2bus  <= CONTROLLER_FLAGS(12);
    	displd   <= CONTROLLER_FLAGS(13);
    	alumd(1) <= CONTROLLER_FLAGS(14);
    	alumd(0) <= CONTROLLER_FLAGS(15);

	phases_transitions : process(CLK, ARESETN)
	begin
		if ARESETN = '0' then
			CURRENT_STATE <= FETCH;
		elsif rising_edge(clk) then
   	 		if master_load_enable = '1' then
				CURRENT_STATE <= NEXT_STATE;
  			end if;
		end if;
	end process phases_transitions;

	STATE_CHANGES : process(CURRENT_STATE, opcode)
	begin    
    		case CURRENT_STATE is
			-- According to the documentation, Decode phase will always follow after the Fetch phase.
        		when FETCH  => NEXT_STATE <= DECODE;
        		when DECODE =>
            			case opcode is
					-- Check Table 2 in Processor.pdf : Page 11
					---------------------------------------
            				when "0000" => NEXT_STATE <= EXECUTE;	-- NOOP : Same as adding a zero to ACC
            				when "0001" => NEXT_STATE <= EXECUTE;	-- ACC, DM[Addr]
            				when "0010" => NEXT_STATE <= EXECUTE;	-- ADD
            				when "0011" => NEXT_STATE <= EXECUTE;	-- NT  ACC
            				when "0100" => NEXT_STATE <= EXECUTE;	-- AND ACC, DM[Addr]
            				when "0101" => NEXT_STATE <= EXECUTE;	-- CMA ACC, DM[Addr]
            				when "0110" => NEXT_STATE <= EXECUTE;	-- LB  ACC, DM[Addr]
					---------------------------------------
            				when "0111" => NEXT_STATE <= MEMORY;	-- SB DM[Addr], ACC
					---------------------------------------
            				when "1000" => NEXT_STATE <= DECODE2;	-- ADX ACC, DM[DM[Addr]]
            				when "1001" => NEXT_STATE <= DECODE2;	-- LBX ACC, DM[DM[Addr]]
            				when "1010" => NEXT_STATE <= DECODE2;	-- SBX DM[DM[Addr]], ACC 
					---------------------------------------
            				when "1011" => NEXT_STATE <= FETCH;	-- IN DM[Addr], IO_BU
            				when "1100" => NEXT_STATE <= FETCH;	-- J Addr   -> JUMP 
            				when "1101" => NEXT_STATE <= FETCH;	-- JNE Addr -> JUMP 
            				when "1110" => NEXT_STATE <= FETCH;	-- JEQ Addr -> JUMP 
					---------------------------------------
            				when "1111" => NEXT_STATE <= EXECUTE;	-- DS -> DISPLAY
					---------------------------------------
            				when others => NEXT_STATE <= FETCH;
            			end case;
			-- Three of the given Opcodes will need to double decode. 
        		when DECODE2 =>
            			case opcode is
            				when "1000" => NEXT_STATE <= EXECUTE;	-- ADX ACC, DM[DM[Addr]]
            				when "1001" => NEXT_STATE <= EXECUTE;	-- LBX ACC, DM[DM[Addr]]
            				when "1010" => NEXT_STATE <= MEMORY;	-- SBX DM[DM[Addr]], ACC
            				when others => NEXT_STATE <= FETCH;
            			end case;
			-- When we reach the Execute, Fetch will normally follow as the next phase
        		when EXECUTE => NEXT_STATE <= FETCH;
			-- When we reach the Memory phase, its almost always followed by the Fetch Stage
        		when MEMORY  => NEXT_STATE <= FETCH;
			when others  => NEXT_STATE <= FETCH;
    		end case;
	end process;

	Activate_Resulting_Flags_Per_Opcode : process(CURRENT_STATE, opcode, neq, eq)
	begin
		CONTROLLER_FLAGS <= (others => '0');
    		case opcode is
			-- Check Table 3 in Processor.pdf : Page 13
			---------------------------------------------------------------------------------------------------------------------
			-- 0: NOOP -> No Operation : Do nothng
        		when "0000" =>
            			case CURRENT_STATE is
                			when FETCH   => CONTROLLER_FLAGS <= (2 => '1', others => '0');
                			when DECODE  => CONTROLLER_FLAGS <= (2 | 5 => '1', others => '0');
                			when EXECUTE => CONTROLLER_FLAGS <= (1 | 2 | 6 | 8 | 10 => '1', others => '0');
                			when others  =>
            			end case;
			---------------------------------------------------------------------------------------------------------------------
			-- 1: SU ACC, DM[Addr] -> SUBTRACT : ACC = ACC - DATAMEM[Addr]
        		when "0001" =>
            			case CURRENT_STATE is
                			when FETCH   => CONTROLLER_FLAGS <= (2 | 15 => '1', others => '0');
                			when DECODE  => CONTROLLER_FLAGS <= (2 | 5 | 15 => '1', others => '0');
                			when EXECUTE => CONTROLLER_FLAGS <= (1 | 2 | 6 | 8 | 10 | 15 => '1', others => '0');
                			when others  =>
            			end case;
			---------------------------------------------------------------------------------------------------------------------
			-- 2: ADD ACC, DM[Addr] -> ADD : ACC = ACC + DATAMEM[Addr]
       			when "0010" =>
            			case CURRENT_STATE is
                			when FETCH    => CONTROLLER_FLAGS <= (2 | 15 => '1', others => '0');
                			when DECODE   => CONTROLLER_FLAGS <= (2 | 5 | 15 => '1', others => '0');
                			when EXECUTE  => CONTROLLER_FLAGS <= (1 | 2 | 6 | 8 | 10 => '1', others => '0');
                			when others   =>
            			end case;
			---------------------------------------------------------------------------------------------------------------------
			-- 3: NT ACC -> NOT : ACC = ACC'
       			when "0011" =>
            			case CURRENT_STATE is
                			when FETCH    => CONTROLLER_FLAGS <= (2 | 14 | 15=> '1', others => '0');
                			when DECODE   => CONTROLLER_FLAGS <= (2 | 5 | 14 | 15=> '1', others => '0');
                			when EXECUTE  => CONTROLLER_FLAGS <= (1 | 2 | 6 | 8 | 10 | 14 | 15 => '1', others => '0');
                			when others   =>
            			end case;
			---------------------------------------------------------------------------------------------------------------------
			-- 4: AND ACC, DM[Addr] -> LOGICAL AND : ACC = ACC AND DATAMEM[Addr]
       			when "0100" =>
            			case CURRENT_STATE is
                			when FETCH   => CONTROLLER_FLAGS <= (2 | 14 => '1', others => '0');
                			when DECODE  => CONTROLLER_FLAGS <= (2 | 5 | 14 => '1', others => '0');
                			when EXECUTE => CONTROLLER_FLAGS <= (1 | 2 | 6 | 8 | 10 | 14 => '1', others => '0');
                			when others  =>
            			end case;
			---------------------------------------------------------------------------------------------------------------------
			-- 5: CMA ACC, DM[Addr] -> COMPARE : COMPARE ACC vs DATAMEM[Addr] -> SETS EQ and NEQ
       			when "0101" =>
            			case CURRENT_STATE is
                			when FETCH   => CONTROLLER_FLAGS <= (2 => '1', others => '0');
                			when DECODE  => CONTROLLER_FLAGS <= (2 | 5 => '1', others => '0');
                			when EXECUTE => CONTROLLER_FLAGS <= (1 | 2 | 6 | 10 => '1', others => '0');
                			when others  =>
            			end case;
			---------------------------------------------------------------------------------------------------------------------
			-- 6: LB ACC, DM[Addr] -> LOAD BYTE : LOAD 8-BYTE VALUE FROM LOCATION DATAMEM[Addr] INTO ACC 
       			when "0110" =>
            			case CURRENT_STATE is
                			when FETCH   => CONTROLLER_FLAGS <= (2 => '1', others => '0');
                			when DECODE  => CONTROLLER_FLAGS <= (2 | 5 => '1', others => '0');
                			when EXECUTE => CONTROLLER_FLAGS <= (1 | 2 | 7 | 8 | 10 => '1', others => '0');
                			when others  =>
            			end case;
			---------------------------------------------------------------------------------------------------------------------
			-- 7: SB DM[Addr], ACC -> STORE BYTE : STORE CONTENTS OF ACC INTO LOCATION DATAMEM[Addr]
       			when "0111" =>
            			case CURRENT_STATE is
					when FETCH    => CONTROLLER_FLAGS <= (2 | 11 => '1', others => '0');
                			when DECODE   => CONTROLLER_FLAGS <= (2 | 11 => '1', others => '0');
                			when MEMORY   => CONTROLLER_FLAGS <= (1 | 2 | 4 | 11 => '1', others => '0');
                			when others   =>
            			end case;
			---------------------------------------------------------------------------------------------------------------------
			-- 8: ADX ACC, DM[DM[Addr]] -> ADD INDEX : ACC = ACC + DATAMEM[DATAMEM[Addr]]
       			when "1000" =>
            			case CURRENT_STATE is
                			when FETCH    => CONTROLLER_FLAGS <= (2 => '1', others => '0');
                			when DECODE   => CONTROLLER_FLAGS <= (2 | 5 => '1', others => '0');
                			when DECODE2  => CONTROLLER_FLAGS <= (2 | 3 | 5 => '1', others => '0');
                			when EXECUTE  => CONTROLLER_FLAGS <= (1 | 2 | 6 | 8 | 10 => '1', others => '0');
                			when others   =>
            			end case;
			---------------------------------------------------------------------------------------------------------------------
			-- 9: LBX ACC, DM[DM[Addr]] -> LOAD BYTE INDEX : ACC = DATAMEM[DATAMEM[Addr]]
       			when "1001" =>
            			case CURRENT_STATE is
                			when FETCH   => CONTROLLER_FLAGS <= (2 => '1', others => '0');
                			when DECODE  => CONTROLLER_FLAGS <= (2 | 5 => '1', others => '0');
                			when DECODE2 => CONTROLLER_FLAGS <= (2 | 3 | 5 => '1', others => '0');
                			when EXECUTE => CONTROLLER_FLAGS <= (1 | 2 | 7 | 8 | 10 => '1', others => '0');
                			when others  =>
            			end case;
			---------------------------------------------------------------------------------------------------------------------
			-- 10: SBX DM[DM[Addr]], ACC -> STORE BYTE INDEX : DATAMEM[DATAMEM[Addr]] = ACC
       			when "1010" =>
            			case CURRENT_STATE is
                			when FETCH   => CONTROLLER_FLAGS <= (2 | 11 => '1', others => '0');
                			when DECODE  => CONTROLLER_FLAGS <= (2 | 5 | 11 => '1', others => '0');
                			when MEMORY  => CONTROLLER_FLAGS <= (1 | 2 | 3 | 4 | 11 => '1', others => '0');
                			when others  =>
            			end case;
			---------------------------------------------------------------------------------------------------------------------
			-- 11: IN DM[Addr], IO_BUS -> INPUT : DATAMEM[Addr] = VALUE OUT ON THE IO_BUS
       			when "1011" =>
            			case CURRENT_STATE is
                			when FETCH  => CONTROLLER_FLAGS <= (2 | 12 => '1', others => '0');
                			when DECODE => CONTROLLER_FLAGS <= (1 | 2 | 4 | 12 => '1', others => '0');
                			when others =>
            			end case;
			---------------------------------------------------------------------------------------------------------------------
			-- 12: J Addr -> JUMP : EXECUTE NEXT INSTRUCTION AT PC = Addr
       			when "1100" =>
            			case CURRENT_STATE is
                			when FETCH  => CONTROLLER_FLAGS <= (2 | 9 => '1', others => '0');
                			when DECODE => CONTROLLER_FLAGS <= (0 | 1 | 2 | 9 => '1', others => '0');
                			when others =>
            			end case;
			---------------------------------------------------------------------------------------------------------------------
			-- 13: JNE Addr -> JUMP NOT EQUAL : JUMP IF CORRESPONDING FLAG (NEQ) IS SET
       			when "1101" =>
            			case CURRENT_STATE is
                			when FETCH  => CONTROLLER_FLAGS <= (2 | 9 => '1', others => '0');
                			when DECODE => CONTROLLER_FLAGS <= (0 => neq, 1 | 2 | 9 => '1', others => '0');
                			when others =>
            			end case;
			---------------------------------------------------------------------------------------------------------------------
			-- 14: JEQ Addr -> JUMP IF EQUAL : JUMP IF THE CORRESPONDING FLAG (EQ) IS SET
       			when "1110" =>
            			case CURRENT_STATE is
                			when FETCH  => CONTROLLER_FLAGS <= (2 | 9 => '1', others => '0');
                			when DECODE => CONTROLLER_FLAGS <= (0 => eq, 1 | 2 | 9 => '1', others => '0');
                			when others =>
            			end case;
			---------------------------------------------------------------------------------------------------------------------
			-- 15: DS -> DISPLAY : MOVE ACC TO DISPLAY REG. (USED FOR DEBUGGING)
       			when "1111" =>
            			case CURRENT_STATE is
                			when FETCH   => CONTROLLER_FLAGS <= (2 => '1', others => '0');
                			when DECODE  => CONTROLLER_FLAGS <= (2 => '1', others => '0');
                			when EXECUTE => CONTROLLER_FLAGS <= (1 | 2 | 13 => '1', others => '0');
                			when others  =>
            			end case;
        		when others =>
			---------------------------------------------------------------------------------------------------------------------
            			null;
    		end case; 
	end process Activate_Resulting_Flags_Per_Opcode;

end Behavioral;


