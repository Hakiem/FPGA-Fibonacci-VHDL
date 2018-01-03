
LIBRARY std ;
USE std.textio.all;
LIBRARY ieee ;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity mem_array is

generic (DATA_WIDTH: integer := 12;
	 ADDR_WIDTH: integer := 8;
	 INIT_FILE: string := "inst_mem.mif");

Port (ADDR 	: in STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
      DATAIN 	: in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
      CLK 	: in STD_LOGIC;
      WE	: in STD_LOGIC;
      OUTPUT    : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0));
end mem_array;


architecture behaviour of mem_array is

Type MEMORY_ARRAY is ARRAY (0 to (2**ADDR_WIDTH) - 1) of STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

impure function init_memory_wfile(mif_file_name  : in string) return MEMORY_ARRAY is
    file mif_file : text open read_mode is mif_file_name;
    variable mif_line : line;
    variable temp_bv : bit_vector(DATA_WIDTH-1 downto 0);
    variable temp_mem : MEMORY_ARRAY;
begin
    for i in MEMORY_ARRAY'range loop
        readline(mif_file, mif_line);
        read(mif_line, temp_bv);
        temp_mem(i) := to_stdlogicvector(temp_bv);
    end loop;
    return temp_mem;
end function;

signal memory : MEMORY_ARRAY := init_memory_wfile(INIT_FILE);


begin 

   process(CLK)
   begin
      if (WE = '1' and rising_edge(CLK)) then
	   memory(to_integer(unsigned(ADDR))) <= DATAIN;
      end if;
   end process;

   OUTPUT <= memory(to_integer(unsigned(ADDR)));

end behaviour;