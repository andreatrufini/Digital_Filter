LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Cut_10_to_8_filter IS
	PORT( Cut_10_to_8_filter_IN : IN SIGNED(9 DOWNTO 0);
			Cut_10_to_8_filter_OUT : OUT SIGNED(7 DOWNTO 0)
		  );
END Cut_10_to_8_filter;

ARCHITECTURE Behaviour OF Cut_10_to_8_filter IS
BEGIN 
	Cut_10_to_8_filter_OUT <= Cut_10_to_8_filter_IN(7 DOWNTO 0);
END Behaviour;