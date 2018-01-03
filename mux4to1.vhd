library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux4to1 is
    PORT( a, b, c, d : IN  STD_LOGIC_VECTOR(7 downto 0);
          s          : IN  STD_LOGIC_VECTOR(1 downto 0);
          f          : OUT STD_LOGIC_VECTOR(7 downto 0));
end mux4to1;

architecture dataflow of mux4to1 is
begin

 with S select
 f <=  a when "00",
       b when "01",
       c when "10",
       d when others;

end dataflow;