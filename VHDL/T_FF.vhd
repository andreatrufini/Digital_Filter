LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY T_FF IS
	PORT
	(
		T : IN std_logic; -- Segnale di Toggle
		T_clock: IN std_logic; -- Segnale di Clock
		T_reset : IN std_logic; -- Segnale di Reset
		T_Q: BUFFER std_logic -- Uscita Q del FF, è buffer perché la uso anche come ingresso
	);
END T_FF;


ARCHITECTURE Structure OF T_FF IS
	
	COMPONENT FF_D -- FLIP FLOP
		PORT 
		(
			D, Clock, Reset: IN std_logic; -- Reset asincrono
			Q : OUT std_logic
		);
	END COMPONENT;
	
	SIGNAL T_inside: std_logic;
	
BEGIN

	T_inside <= T_Q XOR T; -- Al posto del multiplexer, l'ingresso D è dato da XOR tra uscita Q e segnale toggle T
	
	FF_1 : FF_D PORT MAP
	(
		D => T_inside, -- All'ingresso del T flip flop ci va l'uscita in XOR con l'ingresso.
		Clock => T_clock,
		Reset => T_reset,
		Q => T_Q
	);

END Structure;