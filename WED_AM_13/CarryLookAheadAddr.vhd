LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY CarryLookAheadAddr IS
    GENERIC(width : integer := 8);
    PORT
        (
         x_in      :  IN   STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
         y_in      :  IN   STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
         carry_in  :  IN   STD_LOGIC;
         sum       :  OUT  STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
         carry_out :  OUT  STD_LOGIC
        );
END CarryLookAheadAddr;

ARCHITECTURE behavioral OF CarryLookAheadAddr IS

SIGNAL    temp_sum, carry_g, carry_p	:    STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
SIGNAL    temp_carry_in  		:    STD_LOGIC_VECTOR(width - 1 DOWNTO 1);

BEGIN

    temp_sum 	<= x_in XOR y_in;
    carry_g 	<= x_in AND y_in;
    carry_p 	<= x_in OR y_in;

    PROCESS (carry_g, carry_p, temp_carry_in)
    BEGIN
    	temp_carry_in(1) <= carry_g(0) OR (carry_p(0) AND carry_in);

        ForLoop: FOR k IN 1 TO width - 2 LOOP
              	temp_carry_in(k + 1) <= carry_g(k) OR (carry_p(k) AND temp_carry_in(k));
              END LOOP;

    	carry_out <= carry_g(width - 1) OR (carry_p(width - 1) AND temp_carry_in(width - 1));
    END PROCESS;

    sum(0) 			<= temp_sum(0) XOR carry_in;
    sum(width - 1 DOWNTO 1) 	<= temp_sum(width - 1 DOWNTO 1) XOR temp_carry_in(width - 1 DOWNTO 1);

END behavioral;