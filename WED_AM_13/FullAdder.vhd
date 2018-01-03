LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY fulladder IS
   PORT (
	a, b, cin : IN  STD_LOGIC ;
	sum, cout : OUT STD_LOGIC ) ;
END fulladder;

ARCHITECTURE adder OF fulladder IS
BEGIN
	sum <= a XOR b XOR cin ;
	cout <= (a AND b) OR (cin AND a) OR (cin AND b) ;
END adder ;