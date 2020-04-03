LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Mux_3_to_1_10bit IS
	PORT( Mux_3_to_1_10bit_IN_0, Mux_3_to_1_10bit_IN_1, Mux_3_to_1_10bit_IN_2 : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			Mux_3_to_1_10bit_SEL : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			Mux_3_to_1_10bit_OUT : OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
		);
END Mux_3_to_1_10bit;

ARCHITECTURE Behavior OF Mux_3_to_1_10bit IS

BEGIN
	Mux_3_to_1_10bit_OUT <= Mux_3_to_1_10bit_IN_0 WHEN Mux_3_to_1_10bit_SEL = "00" else
				  Mux_3_to_1_10bit_IN_1 WHEN Mux_3_to_1_10bit_SEL = "01" else
				  Mux_3_to_1_10bit_IN_2;

END Behavior;
		
	