library ieee;
use ieee.std_logic_1164.all;

Entity reg is
    generic(n : integer := 8);
    port(input : in std_logic_vector(n - 1 downto 0);
         ARESETN, CLK, loadEnable: in std_logic;
	 res: out std_logic_vector(n - 1 downto 0)
);
End Entity;

Architecture Behave of reg is 
Begin
  Process(clk, aresetn)
    Begin
    if(aresetn = '0') then
       res <= (others => '0');
    elsif rising_Edge(clk) And loadEnable = '1' then
       res <= input;
    end if;
  End process;
End Architecture Behave;