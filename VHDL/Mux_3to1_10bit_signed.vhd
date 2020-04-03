LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Mux_3_to_1_10bit_signed IS
	PORT( Mux_3_to_1_10bit_IN_0, Mux_3_to_1_10bit_IN_1, Mux_3_to_1_10bit_IN_2 : IN SIGNED (9 DOWNTO 0);
			Mux_3_to_1_10bit_SEL : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			Mux_3_to_1_10bit_OUT : OUT SIGNED (9 DOWNTO 0)
		);
END Mux_3_to_1_10bit_signed;

ARCHITECTURE Behavior OF Mux_3_to_1_10bit_signed IS

BEGIN
	Mux_3_to_1_10bit_OUT <= Mux_3_to_1_10bit_IN_0 WHEN Mux_3_to_1_10bit_SEL = "00" else
				  Mux_3_to_1_10bit_IN_1 WHEN Mux_3_to_1_10bit_SEL = "01" else
				  Mux_3_to_1_10bit_IN_2;

END Behavior;
		
	