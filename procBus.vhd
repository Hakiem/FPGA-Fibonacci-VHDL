LIBRARY std ;
LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY procBus IS

PORT (  INSTRUCTION 	: IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
	DATA        	: IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
	ACC         	: IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
	EXTDATA     	: IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
	OUTPUT      	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
	ERR         	: OUT STD_LOGIC;
	instrSEL    	: IN  STD_LOGIC;
	dataSEL     	: IN  STD_LOGIC;
	accSEL      	: IN  STD_LOGIC;
	extdataSEL  	: IN  STD_LOGIC);
END ENTITY;

ARCHITECTURE behavioural of procBus IS

SIGNAL mux_in : STD_LOGIC_VECTOR (3 DOWNTO 0);

BEGIN 
	--  VHDL provides the ability to associate single bits and vectors together to form array structures. 
	-- This is known as concatenation and uses the ampersand (&) 
	mux_in <= instrSEL & dataSEL & accSEL & extdataSEL;

	WITH mux_in SELECT
		OUTPUT <= EXTDATA 	WHEN "0001",
		  	  ACC 		WHEN "0010",
		  	  DATA 		WHEN "0100",
		  	  INSTRUCTION 	WHEN "1000",
		  	  "00000000" 	WHEN OTHERS;
	-- The signal ERR is set when two or more control signals are set at the sametime
	WITH mux_in SELECT
		ERR <=  '0' WHEN "0000",
			'0' WHEN "0001",
			'0' WHEN "0010",
			'0' WHEN "0100",
			'0' WHEN "1000",
			'1' WHEN OTHERS;

END behavioural;