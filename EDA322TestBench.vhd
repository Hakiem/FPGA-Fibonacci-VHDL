library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity testbenchlab5 is
end testbenchlab5;

architecture Behavioral of testbenchlab5 is

	Type FILES_SIZE_ARRAY is ARRAY (0 to 100) of STD_LOGIC_VECTOR(7 downto 0);

	component EDA322_processor is
    		Port ( 
			externalIn 			: in  STD_LOGIC_VECTOR (7 downto 0);
	   		CLK 				: in STD_LOGIC;
	   		master_load_enable		: in STD_LOGIC;
	   		ARESETN 			: in STD_LOGIC;
           		pc2seg 				: out  STD_LOGIC_VECTOR (7 downto 0);
           		instr2seg 			: out  STD_LOGIC_VECTOR (11 downto 0);
           		Addr2seg 			: out  STD_LOGIC_VECTOR (7 downto 0);
           		dMemOut2seg 			: out  STD_LOGIC_VECTOR (7 downto 0);
           		aluOut2seg 			: out  STD_LOGIC_VECTOR (7 downto 0);
           		acc2seg 			: out  STD_LOGIC_VECTOR (7 downto 0);
           		flag2seg 			: out  STD_LOGIC_VECTOR (3 downto 0);
           		busOut2seg 			: out  STD_LOGIC_VECTOR (7 downto 0);
	   		disp2seg			: out STD_LOGIC_VECTOR(7 downto 0);
	   		errSig2seg 			: out STD_LOGIC;
	   		ovf 				: out STD_LOGIC;
	   		zero 				: out STD_LOGIC);
	end component;

	impure function init_memory_wfile(mif_file_name  : in string) return FILES_SIZE_ARRAY is
		
    		file mif_file : text open read_mode is mif_file_name;
		variable mif_line : line;
    		variable temp_bv : bit_vector(7 downto 0);
    		variable temp_mem : FILES_SIZE_ARRAY;
		variable temp : integer := 0;

		begin
			while not endfile(mif_file) loop
        		readline(mif_file, mif_line);
        		read(mif_line, temp_bv);
        		temp_mem(temp) := to_stdlogicvector(temp_bv);
				temp := temp + 1;
    		end loop;
    		return temp_mem;
	end function;
	
	constant clkperiod: time := 10 ns;
	
	signal test_time_step, accCounter, dispCounter, dMemOutCounter, flagsCounter, pcCounter : integer := 0;

	signal CLK:  std_logic := '0';
	signal ARESETN:  std_logic := '0';
	signal master_load_enable:  std_logic := '0';


	signal pc2seg, addr2seg, dMemOut2seg, aluOut2seg, acc2seg, busOut2seg, disp2seg: std_logic_vector(7 downto 0);
	signal instr2seg  : std_logic_vector(11 downto 0);
	signal flag2seg   : std_logic_vector(3 downto 0);
	signal errSig2seg, ovf, zero: std_logic;
	
	signal acc2seg_trace     : FILES_SIZE_ARRAY := init_memory_wfile("acctrace.txt");
	signal disp2seg_trace    : FILES_SIZE_ARRAY := init_memory_wfile("disptrace.txt");
	signal dMemOut2seg_trace : FILES_SIZE_ARRAY := init_memory_wfile("dMemOuttrace.txt");
	signal flag2seg_trace    : FILES_SIZE_ARRAY := init_memory_wfile("flagtrace.txt");
	signal pc2seg_trace      : FILES_SIZE_ARRAY := init_memory_wfile("pctrace.txt");

begin

	-- Design Under Test (DUT) instantiation
	EDA322_dut : EDA322_processor port map (
		externalIn 	=> "00000000",
	   	CLK 		=> CLK,
	   	master_load_enable => master_load_enable, -- flipflop load enables for single step mode
		ARESETN 	=> ARESETN,
        	pc2seg 		=> pc2seg, -- 8 bit
        	instr2seg 	=> OPEN, -- 12 bit
        	Addr2seg 	=> addr2seg, --8 bit
        	dMemOut2seg     => dMemOut2seg, -- 8 bit
        	aluOut2seg 	=> aluOut2seg, -- 8 bit
        	acc2seg 	=> acc2seg, --8 bit
        	flag2seg 	=> flag2seg, -- 4bit
        	busOut2seg 	=> OPEN, -- 8 bit
	   	disp2seg 	=> disp2seg, -- 8 bit
	   	errSig2seg 	=> OPEN, -- 1 bit -- to LED
	   	ovf 		=> OPEN, --1 bit -- to LED
	   	zero 		=> OPEN -- 1 bit -- to LED
	  );

	CLK <= not CLK after clkperiod/2 ; -- CLK with period of 10ns

	----------------------------------------------------------------------------------------
	-- Clock Process
	----------------------------------------------------------------------------------------
	clockProcess:process (CLK)
	begin
		if rising_edge(CLK) then
			test_time_step <= test_time_step + 1;
			master_load_enable <= not master_load_enable;
		else
			master_load_enable <= not master_load_enable;
		end if;
		if test_time_step = 2 then
			ARESETN <= '1'; 
		end if;
	end process;

	----------------------------------------------------------------------------------------
	-- Acc2seg Process
	----------------------------------------------------------------------------------------
	check_Acc: process(acc2seg)
	begin
		if(ARESETN = '1') then
			ASSERT acc2seg_trace(accCounter) = acc2seg
			REPORT "Incorrect Output: acc2seg"
			SEVERITY ERROR;
			accCounter <= accCounter + 1;
		end if;
	end process;

	----------------------------------------------------------------------------------------
	-- disp2seg Process
	----------------------------------------------------------------------------------------
	check_Disp: process(disp2seg)
	begin
		if(ARESETN = '1') then
			ASSERT disp2seg = "10010000"
			REPORT "disp2seg : Value of 144 reached"
			SEVERITY NOTE;

			ASSERT disp2seg_trace(dispCounter) = disp2seg
			REPORT "Incorrect Output: disp2seg"
			SEVERITY ERROR;
			dispCounter <= dispCounter + 1;
		end if;
	end process;

	----------------------------------------------------------------------------------------
	-- dMemOut2seg Process
	----------------------------------------------------------------------------------------
	check_dMemOut2seg: process(dMemOut2seg)
	begin
		-- and CLK'event and clk = '0'
		if(ARESETN = '1') then
			ASSERT dMemOut2seg_trace(dMemOutCounter) = dMemOut2seg
			REPORT "Incorrect Output: dMemOut2seg"
			SEVERITY ERROR;
			dMemOutCounter <= dMemOutCounter + 1;
		end if;
	end process;

	----------------------------------------------------------------------------------------
	-- flag2seg Process
	----------------------------------------------------------------------------------------
	check_flag2seg: process(flag2seg)
	begin
		if(ARESETN = '1') then
			ASSERT flag2seg_trace(flagsCounter) = ("0000" & flag2seg)
			REPORT "Incorrect Output: flag2seg"
			SEVERITY ERROR;
			flagsCounter <= flagsCounter + 1;
		end if;
	end process;

	----------------------------------------------------------------------------------------
	-- pc2seg Process
	----------------------------------------------------------------------------------------
	check_pc2seg: process(pc2seg)
	begin
		if(ARESETN = '1') then
			ASSERT pc2seg_trace(pcCounter) = pc2seg
			REPORT "Incorrect Output: pc2seg"
			SEVERITY ERROR;
			pcCounter <= pcCounter + 1;
		end if;
	end process;
end Behavioral;

