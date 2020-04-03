LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY FA IS
	PORT (
		x, y, c_in : IN std_logic; -- x e y: bit da sommare, c_in: carry in
		sum, c_out : OUT std_logic -- sum: somma di x e y, c_out: carry out
	);
END FA;

ARCHITECTURE Behavior OF FA IS 

	SIGNAL P,G: std_logic; -- P: propagate, G: generate
	
BEGIN

	P <= x XOR y; -- Se P=1, il propagate propaga in uscita il carry_in
	G <= x AND y; -- Se G=1, il generate forza il carry out a 1
	sum <= c_in XOR P;
	c_out <= G OR (P AND c_in);
	
END Behavior;
			
	