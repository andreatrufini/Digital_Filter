LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Valid_address IS
	PORT ( Valid_address_in : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			 Valid_address_2, Valid_address_3 : OUT STD_LOGIC;
			 Valid_address_counter_LSB : OUT STD_LOGIC
			);
END Valid_address;

ARCHITECTURE Behaviour OF Valid_address IS

BEGIN
	--- l'indirizzo del primo contatore, ossia il secondo da utilizzare  valido se il contatore  diverso da 0
	--- quindi lo  se non ho tutti i bit a 0, ossia dev'esserci almeno un bit a 1 perch sia valido
	Valid_address_2 <= Valid_address_in(0) OR
							 Valid_address_in(1) OR
							 Valid_address_in(2) OR
							 Valid_address_in(3) OR
							 Valid_address_in(4) OR
							 Valid_address_in(5) OR
							 Valid_address_in(6) OR
							 Valid_address_in(7) OR
							 Valid_address_in(8) OR
							 Valid_address_in(9);
							 
	--- l'indirizzo 3  valido se il contatore  maggiore di 3 ossia se 
	--- almeno uno dei bit 9-2  a 1  oppure   tutti i bit 9-2 sono a 0 ma l'1 E il 2 sono a 1
	Valid_address_3 <= (Valid_address_in(0) AND Valid_address_in(1) ) OR
							 Valid_address_in(2) OR
							 Valid_address_in(3) OR
							 Valid_address_in(4) OR
							 Valid_address_in(5) OR
							 Valid_address_in(6) OR
							 Valid_address_in(7) OR
							 Valid_address_in(8) OR
							 Valid_address_in(9);
	Valid_address_counter_LSB <= Valid_address_in(0); 
END Behaviour;