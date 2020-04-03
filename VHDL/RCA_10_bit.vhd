LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- Sommatore su 8 bit
ENTITY RCA_10_bit IS
	GENERIC (N : integer := 10);
	PORT (
		RCA_10_bit_IN_1, RCA_10_bit_IN_2: IN SIGNED(N-1 DOWNTO 0); -- Ingressi su N bit
		RCA_10_bit_C_IN: IN STD_LOGIC; -- Carry_in da sommare al resto
		RCA_10_bit_OUT: OUT SIGNED(N-1 DOWNTO 0); -- Risultato della somma su N bit
		RCA_10_bit_C_OUT, RCA_10_bit_overflow: BUFFER STD_LOGIC -- Segnali di carry out e overflow (Buffer poich uno serve per l'altro)
	);
END RCA_10_bit;

ARCHITECTURE Structure OF RCA_10_bit IS

	COMPONENT FA
		PORT (
			x, y, c_in : IN STD_LOGIC; -- x e y: bit da sommare, c_in: carry in
			sum, c_out : OUT STD_LOGIC -- sum: somma di x e y, c_out: carry out
		);
	END COMPONENT;
	
	-- Segnale intermedio per il PORT MAP
	SIGNAL RCA_10_bit_c_ripple: SIGNED(N-2 DOWNTO 0); -- 'carry ripple': carry di supporto all'interno del RCA
																  
BEGIN
	
	-- Primo full adder con il carry_in
	FA_0 : FA PORT MAP (
							x => RCA_10_bit_in_1(0),
							y => RCA_10_bit_in_2(0),
							c_in => RCA_10_bit_c_in,
							sum => RCA_10_bit_out(0),
							c_out => RCA_10_bit_c_ripple(0)
				 );
	
	-- Full adder in mezzo
	FA_v : for I in 1 to N-2 generate
				FA_X: FA	PORT MAP (
							x => RCA_10_bit_in_1(I),
							y => RCA_10_bit_in_2(I),
							c_in => RCA_10_bit_c_ripple(I-1),
							sum => RCA_10_bit_out(I),
							c_out => RCA_10_bit_c_ripple(I));
			 end generate FA_v;
	
	-- Ultimo full_adder con il carry_out
	FA_9 : FA PORT MAP (
							x => RCA_10_bit_in_1(N-1),
							y => RCA_10_bit_in_2(N-1),
							c_in => RCA_10_bit_c_ripple(N-2),
							sum => RCA_10_bit_out(N-1),
							c_out => RCA_10_bit_c_out
				 );
	
	-- Si ha overflow se i due carry dell'ultimo full adder sono diversi
	-- Se i due carry dell'ultimo full adder sono uguali non si ha overflow e quindi si ha il carry out
	RCA_10_bit_overflow <= RCA_10_bit_c_ripple(N-2) XOR RCA_10_bit_c_out; 
	
END Structure;
