LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE std.env.all;
USE std.Textio.all;

ENTITY TestBench IS
END TestBench;


ARCHITECTURE behaviour OF TestBench IS

	-- definisco il componente
	COMPONENT Digital_Filter 
		PORT(
				Digital_Filter_START: IN STD_LOGIC;
				Digital_Filter_CLOCK: IN STD_LOGIC;
				Digital_filter_RST: IN STD_LOGIC;
				Digital_Filter_Data_IN: IN SIGNED (7 DOWNTO 0);
				Digital_Filter_Data_OUT: OUT SIGNED (7 DOWNTO 0);
				Digital_Filter_Mem_B_Address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
				Digital_Filter_Average_OUT: OUT SIGNED (7 DOWNTO 0);
				Digital_Filter_DONE: OUT STD_LOGIC
			);
	END COMPONENT;
	
	-- segnali di INGRESSO
	SIGNAL Digital_Filter_START_s ,Digital_Filter_CLOCK_s, Digital_filter_RST_s: STD_LOGIC;
	SIGNAL Digital_Filter_Data_IN_s : SIGNED (7 DOWNTO 0);
	SIGNAL Digital_Filter_Mem_B_Address_s : STD_LOGIC_VECTOR(9 DOWNTO 0);
	
	-- segnali di USCITA
	SIGNAL Digital_Filter_DONE_s : STD_LOGIC;
	SIGNAL Digital_Filter_Data_OUT_s, Digital_Filter_Average_OUT_s: SIGNED (7 DOWNTO 0);
	
	-- dafinizione dei file usati come input e output e del file con i dati di uscita giusti
	CONSTANT name_file_data_in : STRING := "MEM_A_BIN.txt";
	CONSTANT name_file_data_out : STRING := "MEM_B_BIN.txt";
	CONSTANT name_file_data_out_dec : STRING := "MEM_B_DEC.txt";
	
	-- TEMPI COSTANTI PER LA SIMULAZIONE
	CONSTANT CLK_PERIOD : TIME := 20 ps;
	CONSTANT N_CICLE : INTEGER := 500000 ;
	CONSTANT SIM_TIME : TIME := N_CICLE*20 ps;
	
	-- segnali per i tempi di simulazione
	SIGNAL END_SIM : BOOLEAN := FALSE; 
		
	
BEGIN
	
	--	istanzio il DUT 
	Filtro_Digitale : Digital_Filter 
		PORT map
		(
			Digital_Filter_START => Digital_Filter_START_s,
			Digital_Filter_CLOCK => Digital_Filter_CLOCK_s,
			Digital_filter_RST => Digital_filter_RST_s,
			Digital_Filter_Data_IN => Digital_Filter_Data_IN_s,
			Digital_Filter_Data_OUT => Digital_Filter_Data_OUT_s ,
			Digital_Filter_Mem_B_Address =>Digital_Filter_Mem_B_Address_s ,
			Digital_Filter_Average_OUT => Digital_Filter_Average_OUT_s ,
			Digital_Filter_DONE => Digital_Filter_DONE_s
		);
	
	-- PROCESSO CHE ESEGUE le seguenti istruzioni:
	-- 		- legge il file input E LI d i dati in ingresso al DUT (ciclo)
	--			- alla fine preleva i dati dalla memoria b e li scrive sul file di uscita
	
	file_and_checker : 
	PROCESS 
	
		-- dichiaro i file utilizzati come testo
		FILE file_data_in , file_data_out, file_data_out_dec : text ;
			
		-- variabili per i file
		VARIABLE line_va, line_dec: LINE;
		VARIABLE number_va : SIGNED(7 DOWNTO 0);
		--VARIABLE good_v : BOOLEAN;
		
	BEGIN
		
		-- files di input
		file_open(file_data_in, name_file_data_in, read_mode);
		file_open(file_data_out_dec, name_file_data_out_dec, write_mode);
		-- file di output
		file_open(file_data_out, name_file_data_out, write_mode);
		
		WAIT FOR 6*CLK_PERIOD+CLK_PERIOD;
			
			-- in questo ciclo vengonon presi i valori dal file file_data_in e salvati nella Mem_A
			Mem_A_write_loop:
				FOR i IN 0 TO 1023 LOOP
					readline(file_data_in, line_va);
					-- scrivo a terminale la riga per verificarne il contenuto
					-- per poter scrivere il contatore i a terminale devo convertirlo in una stringa
					report "WRITE IN A " & integer'image(i) & " : " & line_va.all;
					read(line_va, number_va);
					Digital_Filter_Data_IN_s <= number_va;
					WAIT FOR CLK_PERIOD;
				END LOOP Mem_B_write_loop;
			-- chiudo il file di input
			file_close(file_data_in);
			
			-- aspetto che il DUT ABBIA FINITO
			Waiting_dut_done_loop:
				WHILE Digital_Filter_DONE_s = '0' LOOP
					WAIT FOR CLK_PERIOD;
				END LOOP Waiting_dut_done_loop;
			
					
			-- leggo i valori dalla memoria b e li salvo sul file file_data_out
			Saving_data_in_mem_B_loop:
				FOR i IN 0 TO 1023 LOOP
					-- trasformo il contatore da intero ad uno std_logic_vector di 10 bit
					-- per puntare progressivamente l'indirizzo della memoria b da salvare nel file
					Digital_Filter_Mem_B_Address_s <= STD_LOGIC_VECTOR(TO_UNSIGNED(i,10)) ;
					WAIT FOR CLK_PERIOD;
					-- scrivo la prima riga in line_va
					write(line_va, Digital_Filter_Data_OUT_s);
					write(line_dec, to_integer(Digital_Filter_Data_OUT_s));
					-- scrivo a terminale la riga per verificarne il contenuto
					-- per poter scrivere il contatore i a terminale devo convertirlo in una stringa
					report "READ IN B " & integer'image(i) & " : " & line_va.all;
					-- salvo line_va nel file
					writeline(file_data_out, line_va);
					writeline(file_data_out_dec, line_dec);
					
				END LOOP Saving_data_in_mem_B_loop;
			
			-- chiudo il file di output
			file_close(file_data_out);
		finish(0);
	END PROCESS file_and_checker;
	
	-- PROCESSO DI CLOCK
	CLK:
	PROCESS
	BEGIN
		CLK_CICLE:
		FOR i IN 0 TO N_CICLE LOOP
			Digital_Filter_CLOCK_s <= '0' , '1' AFTER CLK_PERIOD/2;
			WAIT FOR CLK_PERIOD;
		END LOOP CLK_CICLE;
		--- ferma la simulazione dopo N_CICLE cicli di clock
		finish(0);
	END PROCESS CLK;

	-- PROCESSO DI RESET
	RST:
	PROCESS
	BEGIN
		Digital_filter_RST_s <= '1';
		WAIT FOR CLK_PERIOD*2;
		Digital_filter_RST_s <= '0';
		WAIT FOR  SIM_TIME;
	END PROCESS;

	-- PROCESSO DI START
	START:
	PROCESS
	BEGIN
		WAIT FOR CLK_PERIOD*6;
		Digital_filter_START_s <= '1';
		WAIT FOR CLK_PERIOD*100;
		Digital_filter_START_s <= '0';
		WAIT FOR  SIM_TIME;
	END PROCESS;
	--- questa parte serve per arrestare la simulazione al SIM_TIME settato
	stop_simulation :
	PROCESS
	BEGIN
		WAIT FOR SIM_TIME; --run the simulation for this duration
		END_SIM <= true;
	END PROCESS;
	
END behaviour;