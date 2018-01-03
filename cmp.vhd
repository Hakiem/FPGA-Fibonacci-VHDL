LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;

ENTITY cmp IS
	
	PORT (
		A, B	: IN	STD_LOGIC_VECTOR (7 DOWNTO 0);
	     	AeqB	: OUT 	STD_LOGIC;
	     	AneqB	: OUT	STD_LOGIC);
END cmp;

ARCHITECTURE Behavioral OF cmp IS

SIGNAL result 		: STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
	result 	<= A XOR B;
	AneqB 	<= or_reduce(result);
	AeqB 	<= NOT or_reduce(result);

END Behavioral;

