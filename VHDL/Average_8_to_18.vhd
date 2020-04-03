LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Average_8_to_18 IS
	PORT( Average_8_to_18_IN : IN SIGNED(7 DOWNTO 0);
			Average_8_to_18_OUT : OUT SIGNED(17 DOWNTO 0)
		  );
END Average_8_to_18;

ARCHITECTURE Behaviour OF Average_8_to_18 IS
BEGIN 
	Average_8_to_18_OUT <= Average_8_to_18_IN(7) &
								  Average_8_to_18_IN(7) &
								  Average_8_to_18_IN(7) &
								  Average_8_to_18_IN(7) &
								  Average_8_to_18_IN(7) &
								  Average_8_to_18_IN(7) &
								  Average_8_to_18_IN(7) &
								  Average_8_to_18_IN(7) &
								  Average_8_to_18_IN(7) &
								  Average_8_to_18_IN(7) &
								  Average_8_to_18_IN(7 DOWNTO 0);
END Behaviour;