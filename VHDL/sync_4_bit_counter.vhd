LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY sync_4_bit_counter IS
	PORT
	(
		count_4_enable : IN std_logic; -- Segnale di Enable
		count_4_reset: IN std_logic; -- Segnale di Reset
		count_4_clock : IN std_logic; -- Segnale di Clock
		count_4_out: BUFFER std_logic_vector(3 DOWNTO 0); -- Uscita del contatore
		count_4_carry: OUT std_logic -- Vale uno quando ha finito di contare
	);
END sync_4_bit_counter;

ARCHITECTURE Structural OF sync_4_bit_counter IS

	COMPONENT T_FF
		PORT
		(
			T : IN std_logic; -- Segnale di Toggle
			T_clock: IN std_logic; -- Segnale di Clock
			T_reset : IN std_logic; -- Segnale di Reset
			T_Q: BUFFER std_logic -- Uscita Q del FF, è buffer perché la uso anche come ingresso
		);
	END COMPONENT;
	
	SIGNAL Q_inside: std_logic_vector (3 DOWNTO 0); -- Segnale interno che contiene le uscite iesime
	SIGNAL T_inside: std_logic_vector (3 DOWNTO 0); -- Segnale interno che contiene gli ingressi T iesimi

BEGIN

	-- T_inside è il segnale T dell'iesimo T_Flip_Flop
	-- Q_inside è il segnale Q dell'iesimo T_Flip_Flop
	
	T_inside(0) <= count_4_enable; -- Il toggle del primo flip flop è l'enable.
	T_inside(1) <= T_inside(0) AND Q_inside(0); -- Il toggle del secondo flip flop è l'AND tra l'uscita precedente e il toggle precedente.
	T_inside(2) <= T_inside(1) AND Q_inside(1); -- E così via
	T_inside(3) <= T_inside(2) AND Q_inside(2);
	
	-- PORT MAP dei vari T_FF
	
	
	create_t_flip_flops : FOR i IN 0 TO 3 GENERATE
		T_i : T_FF PORT MAP
		(	
			T => T_inside(i),
			T_clock => count_4_clock,
			T_reset => count_4_reset,
			T_Q => Q_inside(i)
		);
	END GENERATE;
	
	-- Prelevo l'uscita dal segnale Q interno
	count_4_out <= Q_inside;
	
	-- Segnale di Carry out per usare contatori in parallelo
	count_4_carry <= T_inside(3) AND Q_inside(3);
	
END Structural;