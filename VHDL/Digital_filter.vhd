LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Digital_Filter IS
	PORT
	(
		Digital_Filter_START: IN STD_LOGIC;
		Digital_Filter_CLOCK: IN STD_LOGIC;
		Digital_filter_RST: IN STD_LOGIC;
		Digital_Filter_Data_IN: IN SIGNED (7 DOWNTO 0);
		Digital_Filter_Mem_B_Address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		Digital_Filter_Data_OUT: OUT SIGNED (7 DOWNTO 0);
		Digital_Filter_Average_OUT: OUT SIGNED (7 DOWNTO 0);
		Digital_Filter_DONE: OUT STD_LOGIC
	);
END Digital_Filter;

ARCHITECTURE Structural OF Digital_Filter IS

	COMPONENT ASM_chart_Datapath
		PORT
		( --- ingressi datapath
				CLK : IN STD_LOGIC;
				Data_IN : IN SIGNED(7 DOWNTO 0);
				MEM_B_ADDRESS_IN : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
				
				-- uscite datapath
				Data_OUT : OUT SIGNED(7 DOWNTO 0);
				Average : OUT SIGNED(7 DOWNTO 0);
				
				--- ingressi di controllo
				Counter_1024_EN, Counter_1024_RST : IN STD_LOGIC;
				Reg_counter_1_LOAD, Reg_counter_1_RST : IN STD_LOGIC;
				Reg_counter_2_LOAD, Reg_counter_2_RST : IN STD_LOGIC;
				Reg_counter_3_LOAD, Reg_counter_3_RST : IN STD_LOGIC;
				Mux_Address_SEL : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
				Mem_A_CS, Mem_A_WR_n, Mem_A_RD: IN STD_LOGIC;
				Reg_samples_Load, Reg_samples_RST : IN STD_LOGIC;
				Mux_operation_SEL : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
				Sample_CA_1 : IN STD_LOGIC;
				Block_Sample_n : IN STD_LOGIC;
				Sum_Filter_C_IN : IN STD_LOGIC;
				Reg_Filter_LOAD, Reg_Filter_RST : IN STD_LOGIC;
				Sum_CA_1 : IN STD_LOGIC;
				Mux_Saturation_SEL : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
				Mem_B_CS, Mem_B_WR_n, Mem_B_RD: IN STD_LOGIC; 
				Reg_Sum_Average_LOAD, Reg_Sum_Average_RST : IN STD_LOGIC;
				Mux_MEM_B_sel : IN STD_LOGIC;
			
				--- uscite di stato
				Counter_1024_TC : OUT STD_LOGIC;
				Valid_Address_2, Valid_Address_3, Counter_LSB : OUT STD_LOGIC;
				Ovf_Sign_10_to_8_filter_OVF, Ovf_Sign_10_to_8_filter_SIGN: OUT STD_LOGIC
		);
	END COMPONENT;

	-- Segnali per il portmap
		SIGNAL		Counter_1024_EN_s, Counter_1024_RST_s: STD_LOGIC;
		SIGNAL	   Reg_counter_1_LOAD_s, Reg_counter_1_RST_s : STD_LOGIC;
		SIGNAL		Reg_counter_2_LOAD_s, Reg_counter_2_RST_s : STD_LOGIC;
		SIGNAL		Reg_counter_3_LOAD_s, Reg_counter_3_RST_s : STD_LOGIC;
		SIGNAL		Mux_Address_SEL_s : STD_LOGIC_VECTOR (1 DOWNTO 0);
		SIGNAL		Mem_A_CS_s, Mem_A_WR_n_s, Mem_A_RD_s: STD_LOGIC;
		SIGNAL		Reg_samples_Load_s, Reg_samples_RST_s : STD_LOGIC;
		SIGNAL		Mux_operation_SEL_s : STD_LOGIC_VECTOR (1 DOWNTO 0);
		SIGNAL		Sample_CA_1_s : STD_LOGIC;
		SIGNAL		Block_Sample_n_s : STD_LOGIC;
		SIGNAL		Sum_Filter_C_IN_s : STD_LOGIC;
		SIGNAL		Reg_Filter_LOAD_s, Reg_Filter_RST_s : STD_LOGIC;
		SIGNAL		Sum_CA_1_s : STD_LOGIC;
		SIGNAL		Mux_Saturation_SEL_s : STD_LOGIC_VECTOR (1 DOWNTO 0);
		SIGNAL		Mem_B_CS_s, Mem_B_WR_n_s, Mem_B_RD_s: STD_LOGIC; 
		SIGNAL		Reg_Sum_Average_LOAD_s, Reg_Sum_Average_RST_s: STD_LOGIC;
		SIGNAL 		Mux_MEM_B_sel_s : STD_LOGIC;
		
		-- Uscite di stato
		SIGNAL 		Counter_1024_TC_s : STD_LOGIC;
		SIGNAL		Valid_Address_2_s, Valid_Address_3_s, Counter_LSB_s : STD_LOGIC;
		SIGNAL		Ovf_Sign_10_to_8_filter_OVF_s, Ovf_Sign_10_to_8_filter_SIGN_s: STD_LOGIC;
	
	type states IS (RST, S0_LOAD_MEM_A, S1_LOAD_DATA_1, S2_EXECUTE_DATA_1, S3_EXECUTE_DATA_2, 
						 S2_INVALID_2, S3_INVALID_3, S4_EXECUTE_DATA_3, S5_INVERT, S6_WRITE_SUM,
						 S6_WRITE_127, S6_WRITE_128, S7_DONE);
	
	SIGNAL present_state: states;
	SIGNAL next_state: states;

	
BEGIN

	Datapath_1 : ASM_chart_Datapath PORT MAP
	(
		CLK => Digital_Filter_CLOCK,
		Data_IN => Digital_Filter_Data_IN,
		MEM_B_ADDRESS_IN => Digital_Filter_Mem_B_Address,
				
		-- uscite datapath
		Data_OUT => Digital_Filter_Data_OUT,
		Average => Digital_Filter_Average_OUT,
				
		--- ingressi di controllo
		Counter_1024_EN => Counter_1024_EN_s,
		Counter_1024_RST => Counter_1024_RST_s,
		Reg_counter_1_LOAD => Reg_counter_1_LOAD_s,
		Reg_counter_1_RST => Reg_counter_1_RST_s,
		Reg_counter_2_LOAD => Reg_counter_2_LOAD_s,
		Reg_counter_2_RST => Reg_counter_2_RST_s,
		Reg_counter_3_LOAD => Reg_counter_3_LOAD_s,
		Reg_counter_3_RST => Reg_counter_3_RST_s,
		Mux_Address_SEL => Mux_Address_SEL_s,
		Mem_A_CS => Mem_A_CS_s,
		Mem_A_WR_n => Mem_A_WR_n_s,
		Mem_A_RD => Mem_A_RD_s,
		Reg_samples_Load => Reg_samples_Load_s,
		Reg_samples_RST => Reg_samples_RST_s,
		Mux_operation_SEL => Mux_operation_SEL_s,
		Sample_CA_1 => Sample_CA_1_s,
		Block_Sample_n => Block_Sample_n_s,
		Sum_Filter_C_IN => Sum_Filter_C_IN_s,
		Reg_Filter_LOAD => Reg_Filter_LOAD_s,
		Reg_Filter_RST => Reg_Filter_RST_s,
		Sum_CA_1 => Sum_CA_1_s,
		Mux_Saturation_SEL => Mux_Saturation_SEL_s,
		Mem_B_CS => Mem_B_CS_s,
		Mem_B_WR_n => Mem_B_WR_n_s,
		Mem_B_RD => Mem_B_RD_s,
		Reg_Sum_Average_LOAD => Reg_Sum_Average_LOAD_s,
		Reg_Sum_Average_RST => Reg_Sum_Average_RST_s,
		Mux_MEM_B_sel => Mux_MEM_B_sel_s,
			
		
		--- uscite di stato
		Counter_1024_TC => Counter_1024_TC_s,
		Valid_Address_2 => Valid_Address_2_s,
		Valid_Address_3 => Valid_Address_3_s,
		Counter_LSB => Counter_LSB_s,
		Ovf_Sign_10_to_8_filter_OVF => Ovf_Sign_10_to_8_filter_OVF_s,
		Ovf_Sign_10_to_8_filter_SIGN => Ovf_Sign_10_to_8_filter_SIGN_s
	);
	
	
		State_registers:
		PROCESS(Digital_Filter_Clock)
			BEGIN
				if Digital_Filter_Clock'event and Digital_Filter_Clock = '1' then -- Le operazioni vengono fatte solo sul fronte alto di salita del clock
						IF Digital_Filter_RST = '1' THEN
							present_state <= RST;
						ELSE						
							present_state <= next_state;
						END IF;
				end if;
		END PROCESS;
		
		
		State_transitions: 
		PROCESS( present_state, 
					Digital_Filter_START, 	
					Counter_1024_TC_s,	 
					Valid_Address_2_s,	
					Valid_Address_3_s,
					Counter_LSB_s,
					Ovf_Sign_10_to_8_filter_OVF_s,
					Ovf_Sign_10_to_8_filter_SIGN_s
					)
		BEGIN
			next_state <= RST;
			CASE present_state IS
				
				WHEN RST => 
					IF (Digital_Filter_START = '1') THEN 
						next_state <= S0_LOAD_MEM_A; 
					END IF;
				
				WHEN S0_LOAD_MEM_A => 
					IF (Counter_1024_TC_s = '1') THEN 
						next_state <= S1_LOAD_DATA_1;
					ELSE
						next_state <= S0_LOAD_MEM_A;
					END IF;
					
				WHEN S1_LOAD_DATA_1 => 
					IF (Valid_Address_2_s = '1') THEN 
						next_state <= S2_EXECUTE_DATA_1;
					ELSE
						next_state <= S2_INVALID_2;
					END IF;
					
				WHEN S2_EXECUTE_DATA_1 => 
					IF (Valid_Address_3_s = '1') THEN 
						next_state <= S3_EXECUTE_DATA_2;
					ELSE
						next_state <= S3_INVALID_3;
					END IF;
					
				WHEN S3_EXECUTE_DATA_2 => 
						next_state <= S4_EXECUTE_DATA_3;
			
				WHEN S4_EXECUTE_DATA_3 | S2_INVALID_2 | S3_INVALID_3=> 
					IF (Counter_LSB_s = '1') THEN 
						next_state <= S5_INVERT;
					ELSE
						IF (Ovf_Sign_10_to_8_filter_OVF_s = '1') THEN 
							IF (Ovf_Sign_10_to_8_filter_SIGN_s = '1') THEN -- Il segno  uno se negativo
								next_state <= S6_WRITE_128;
							ELSE
								next_state <= S6_WRITE_127;
							END IF;
						ELSE
							next_state <= S6_WRITE_SUM;
						END IF;
					END IF;
					
				WHEN S5_INVERT =>
					IF (Ovf_Sign_10_to_8_filter_OVF_s = '1') THEN 
						IF (Ovf_Sign_10_to_8_filter_SIGN_s = '1') THEN -- Il segno  uno se negativo
							next_state <= S6_WRITE_128;
						ELSE
							next_state <= S6_WRITE_127;
						END IF;
					ELSE
						next_state <= S6_WRITE_SUM;
					END IF;
				
				WHEN S6_WRITE_SUM | S6_WRITE_127 | S6_WRITE_128 => 
					IF (Counter_1024_TC_s = '1') THEN 
						next_state <= S7_DONE;	
					ELSE
						next_state <= S1_LOAD_DATA_1;
					END IF;
					
				WHEN S7_DONE => 
					IF (Digital_Filter_START = '0') THEN -- Altrimenti RESET
						next_state <= S7_DONE;
					ELSE
						next_state <= RST;
					END IF;
				WHEN OTHERS => next_state <= RST;
					
			END CASE;
		END PROCESS;
		
		Output_decode : 
		PROCESS(present_state)
		BEGIN 
		-- Valori di default
					Counter_1024_EN_s <= '0';
					Counter_1024_RST_s <= '0';
					Reg_counter_1_LOAD_s <= '0';
					Reg_counter_2_LOAD_s <= '0';
					Reg_counter_3_LOAD_s <= '0';
					Reg_counter_1_RST_s <= '0';
					Reg_counter_2_RST_s <= '0';
					Reg_Counter_3_RST_s <= '0';
					Mux_Address_SEL_s <= "00";
					Mem_A_CS_s <= '1';
					Mem_A_WR_n_s <= '1';
					Mem_A_RD_s <= '1';
					Reg_Samples_Load_s <= '1';
					Reg_Samples_RST_s <= '0';
					Mux_Operation_SEL_s <= "00";
					Sample_CA_1_s <= '0';
					Block_Sample_n_s <= '1';
					Sum_Filter_C_IN_s <= '0';
					Reg_Filter_LOAD_s <= '1';
					Reg_Filter_RST_s <= '0';
					Sum_CA_1_s <= '0';
					Mux_Saturation_SEL_s <= "00";
					Mem_B_CS_s <= '1';
					Mem_B_WR_n_s <= '1';
					Mem_B_RD_s <= '0';
					Reg_Sum_Average_LOAD_s <= '0';
					Reg_Sum_Average_RST_s	<= '0';
					DIGITAL_FILTER_DONE <= '0';
					Mux_MEM_B_sel_s <= '0';
	   	
			CASE present_state IS
				WHEN RST => 
					Counter_1024_RST_s <= '1';
					Reg_counter_1_RST_s <= '1';
					Reg_counter_2_RST_s <= '1';
					Reg_counter_3_RST_s <= '1';
					Reg_samples_RST_s <= '1';
					Reg_Filter_RST_s <= '1';
					Reg_Sum_Average_RST_s	<= '1';
					
				WHEN S0_LOAD_MEM_A => Counter_1024_EN_s <= '1';
											 Mem_A_WR_n_s <= '0';
											 Mem_A_RD_s <= '0';
					
				WHEN S1_LOAD_DATA_1 => Reg_Filter_RST_s <= '1';
				
				WHEN S2_EXECUTE_DATA_1 => Mux_Address_SEL_s <= "01";
												  Reg_Sum_Average_LOAD_s <= '1';
				
				WHEN S3_EXECUTE_DATA_2 => Mux_Operation_SEL_s <= "01";
												  Mux_Address_SEL_s <= "10";
				
				WHEN S2_INVALID_2 => Reg_Sum_Average_LOAD_s <= '1';
				
				WHEN S3_INVALID_3 => Mux_Operation_SEL_s <= "01";
				
				WHEN S4_EXECUTE_DATA_3 => Reg_Samples_LOAD_s <= '0';
												  Mux_Operation_SEL_s <= "10";
												  Sample_CA_1_s <= '1';
												  Sum_Filter_C_IN_s <= '1';
												  
				WHEN S5_INVERT => Block_Sample_n_s <= '0';
										Sum_CA_1_s <= '1';
										Sum_Filter_C_IN_s <= '1';
				
				WHEN S6_WRITE_SUM => Mem_B_CS_s <= '1';
											Mem_B_WR_n_s <= '0';
											Counter_1024_EN_s <= '1';
											Reg_counter_1_LOAD_s <= '1';
											Reg_counter_2_LOAD_s <= '1';
											Reg_counter_3_LOAD_s <= '1';
											
				WHEN S6_WRITE_127 => Mem_B_CS_s <= '1';
											Mem_B_WR_n_s <= '0';
											Counter_1024_EN_s <= '1';
											Reg_counter_1_LOAD_s <= '1';
											Reg_counter_2_LOAD_s <= '1';
											Reg_counter_3_LOAD_s <= '1';
											Mux_Saturation_SEL_s <= "10";
				
				WHEN S6_WRITE_128 => Mem_B_CS_s <= '1';
											Mem_B_WR_n_s <= '0';
											Counter_1024_EN_s <= '1';
											Reg_counter_1_LOAD_s <= '1';
											Reg_counter_2_LOAD_s <= '1';
											Reg_counter_3_LOAD_s <= '1';
											Mux_Saturation_SEL_s <= "01";
											
				WHEN S7_DONE => DIGITAL_FILTER_DONE <= '1';
									 Mux_MEM_B_sel_s <= '1';
									 Mem_B_RD_s <= '1';
									 Mem_B_CS_s <= '1';
									 
				
			END CASE;
		END PROCESS;

END Structural;