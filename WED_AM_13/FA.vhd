LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY rca is
    PORT ( a 	: IN  STD_LOGIC_VECTOR (7 downto 0);
           b 	: IN  STD_LOGIC_VECTOR (7 downto 0);
           cin 	: IN  STD_LOGIC;
           sum 	: OUT  STD_LOGIC_VECTOR (7 downto 0);
           cout : OUT  STD_LOGIC);
END rca;

ARCHITECTURE Behavioral OF rca IS

COMPONENT fullAdder IS
    PORT ( a 	: IN  STD_LOGIC;
           b 	: IN  STD_LOGIC;
           cin 	: IN  STD_LOGIC;
           sum 	: OUT  STD_LOGIC;
           cout : OUT  STD_LOGIC);
END COMPONENT;

SIGNAL c: std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');

BEGIN

	C1: fulladder PORT MAP( a => a(0), b => b(0), cin => cin, sum => sum(0), cout => c(1) );
	C2: fulladder PORT MAP( a => a(1), b => b(1), cin => c(1), sum => sum(1), cout => c(2) );
	C3: fulladder PORT MAP( a => a(2), b => b(2), cin => c(2), sum => sum(2), cout => c(3) );
	C4: fulladder PORT MAP( a => a(3), b => b(3), cin => c(3), sum => sum(3), cout => c(4) );
	C5: fulladder PORT MAP( a => a(4), b => b(4), cin => c(4), sum => sum(4), cout => c(5) );
	C6: fulladder PORT MAP( a => a(5), b => b(5), cin => c(5), sum => sum(5), cout => c(6) );
	C7: fulladder PORT MAP( a => a(6), b => b(6), cin => c(6), sum => sum(6), cout => c(7) );
	C8: fulladder PORT MAP( a => a(7), b => b(7), cin => c(7), sum => sum(7), cout => cout );

END Behavioral;