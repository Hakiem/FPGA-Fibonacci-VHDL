LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_misc.all;


ENTITY alu_wRCA is
	PORT (
	  ALU_inA 	: IN   STD_LOGIC_VECTOR (7 DOWNTO 0);
          ALU_inB 	: IN   STD_LOGIC_VECTOR (7 DOWNTO 0);
          ALU_out 	: OUT  STD_LOGIC_VECTOR (7 DOWNTO 0);
          Carry 	: OUT  STD_LOGIC;
          NotEq	 	: OUT  STD_LOGIC;
          Eq 		: OUT  STD_LOGIC;
          isOutZero  	: OUT  STD_LOGIC;
	  Operation  	: IN   STD_LOGIC_VECTOR (1 DOWNTO 0)
	);
END alu_wRCA;

ARCHITECTURE Behavioral OF alu_wRCA IS

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

-- COMPONENT rca
--    PORT ( 
--	     a 	: IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
--           b 	: IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
--           cin 	: IN  STD_LOGIC;
--           sum 	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
--           cout : OUT STD_LOGIC
--	);
-- END COMPONENT;

COMPONENT cmp
   PORT (
	 A, B	: IN   STD_LOGIC_VECTOR (7 DOWNTO 0);
	 AeqB	: OUT  STD_LOGIC;
	 AneqB	: OUT  STD_LOGIC
	);
END COMPONENT;

SIGNAL notOut 			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL andOut 			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL twoComp			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL totalSum			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL localAlu_out 		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL andAllLocalAlu_out 	: STD_LOGIC := '0';
SIGNAL rcaCIN 			: STD_LOGIC;

BEGIN

	notOut <= NOT ALU_inA;
	andOut <= ALU_inA AND ALU_inB;

	twoComp <= (NOT ALU_inB) WHEN operation = "01" ELSE ALU_inB;
	rcaCIN  <= '1' WHEN operation = "01" ELSE '0';

	Comp: cmp PORT MAP(a => ALU_inA, b => ALU_inB, AeqB => Eq, AneqB => NotEq); 

	-- AddandSub : rca PORT MAP (a => ALU_inA, b => twoComp, cin => rcaCIN, sum => totalSum, cout => Carry);
	AddandSub : CarryLookAheadAddr PORT MAP (x_in => ALU_inA, y_in => twoComp, carry_in => rcaCIN, sum => totalSum, carry_out => Carry);
 
	localAlu_out <= notOut   WHEN operation = "11" ELSE
		 	andOut   WHEN operation = "10" ELSE
		 	totalSum;
   
	isOutZero <= NOT or_reduce(localAlu_out);
	ALU_out <= localAlu_out;

END Behavioral;

