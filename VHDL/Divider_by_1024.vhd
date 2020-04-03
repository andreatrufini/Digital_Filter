LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Divider_by_1024 IS
PORT( Divider_by_1024_IN : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
		Divider_by_1024_OUT : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	 );
END Divider_by_1024;

ARCHITECTURE Behaviour OF Divider_by_1024 IS
BEGIN
	Divider_by_1024_OUT <= Divider_by_1024_IN(19 DOWNTO 10); 
END Behaviour;