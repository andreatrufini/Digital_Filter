LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Counter_1024 IS
	PORT
	(
		Counter_1024_EN : IN std_logic; -- Segnale di Enable
		Counter_1024_RST : IN std_logic; -- Segnale di Reset
		Counter_1024_CLK : IN std_logic; -- Segnale di Clock
		Counter_1024_TC : OUT std_logic; -- Segnale di fine conta 
		Counter_1024_OUT : BUFFER STD_LOGIC_VECTOR (9 DOWNTO 0)
	);
END Counter_1024;

ARCHITECTURE Structural OF Counter_1024 IS

	COMPONENT sync_4_bit_counter
		PORT
		(
			count_4_enable : IN std_logic; -- Segnale di Enable
			count_4_reset: IN std_logic; -- Segnale di Reset
			count_4_clock : IN std_logic; -- Segnale di Clock
			count_4_out: BUFFER std_logic_vector(3 DOWNTO 0); -- Uscita del contatore
			count_4_carry: OUT std_logic -- Vale uno quando ha finito di contare
		);
	END COMPONENT;
	
	COMPONENT sync_2_bit_counter
		PORT
		(
			count_2_enable : IN std_logic; -- Segnale di Enable
			count_2_reset: IN std_logic; -- Segnale di Reset
			count_2_clock : IN std_logic; -- Segnale di Clock
			count_2_out: BUFFER std_logic_vector(1 DOWNTO 0); -- Uscita del contatore
			count_2_carry: OUT std_logic -- Vale uno quando ha finito di contare
		);
	END COMPONENT;
	
	SIGNAL carry_to_enable : std_logic_vector (2 DOWNTO 0); 
	-- Segnale per il mapping che collega all'enable del FF successivo il 'carry' del precedente
	
BEGIN
		
		-- FF bit meno significativi
		count_4_0 : sync_4_bit_counter PORT MAP
		(	
			count_4_enable => Counter_1024_EN,
			count_4_reset => Counter_1024_RST,
			count_4_clock => Counter_1024_CLK,
			count_4_out => Counter_1024_OUT(3 DOWNTO 0),
			count_4_carry => carry_to_enable(0)
		);
		
		count_4_1 : sync_4_bit_counter PORT MAP
		(	
			count_4_enable => carry_to_enable(0),
			count_4_reset => Counter_1024_RST,
			count_4_clock => Counter_1024_CLK,
			count_4_out => Counter_1024_OUT(7 DOWNTO 4),
			count_4_carry => carry_to_enable(1)
		);
		
		count_2_0 : sync_2_bit_counter PORT MAP
		(	
			count_2_enable => carry_to_enable(1),
			count_2_reset => Counter_1024_RST,
			count_2_clock => Counter_1024_CLK,
			count_2_out => Counter_1024_OUT(9 DOWNTO 8),
			count_2_carry => carry_to_enable(2)
		);
		
		Counter_1024_TC <= Counter_1024_OUT(0) AND
								 Counter_1024_OUT(1) AND
								 Counter_1024_OUT(2) AND
								 Counter_1024_OUT(3) AND
								 Counter_1024_OUT(4) AND
								 Counter_1024_OUT(5) AND
								 Counter_1024_OUT(6) AND
								 Counter_1024_OUT(7) AND
								 Counter_1024_OUT(8) AND
								 Counter_1024_OUT(9);

END Structural;