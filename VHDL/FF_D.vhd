LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY FF_D IS
	PORT (
		D, Clock, Reset: IN std_logic; -- Reset asincrono
		Q : OUT std_logic
	);
END FF_D;
	
ARCHITECTURE Behavior OF FF_D IS
BEGIN
		PROCESS(Clock, Reset)
		BEGIN
			IF (Reset = '1') THEN
				Q <= '0';
			ELSIF (Clock'EVENT AND Clock = '1') THEN
				Q <= D;
			END IF;
		END PROCESS;
END Behavior;