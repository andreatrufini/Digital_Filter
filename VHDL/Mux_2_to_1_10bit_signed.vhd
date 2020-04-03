LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Mux_2_to_1_10bit_signed IS
	PORT( Mux_2_to_1_10bit_IN_0, Mux_2_to_1_10bit_IN_1: IN SIGNED (9 DOWNTO 0);
			Mux_2_to_1_10bit_SEL : IN STD_LOGIC;
			Mux_2_to_1_10bit_OUT : OUT SIGNED (9 DOWNTO 0)
		);
END Mux_2_to_1_10bit_signed;

ARCHITECTURE Behavior OF Mux_2_to_1_10bit_signed IS

BEGIN
	Mux_2_to_1_10bit_OUT <= Mux_2_to_1_10bit_IN_0 WHEN Mux_2_to_1_10bit_SEL = '0' ELSE
									Mux_2_to_1_10bit_IN_1;
END Behavior;
		
	