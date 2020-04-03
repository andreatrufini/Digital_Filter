LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ASM_chart_Datapath IS
	PORT( --- ingressi datapath
			CLK : IN STD_LOGIC;
			MEM_B_ADDRESS_IN : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			Data_IN : IN SIGNED(7 DOWNTO 0);
			
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
	END ASM_chart_Datapath;

ARCHITECTURE Structural OF ASM_chart_Datapath IS

	COMPONENT Counter_1024
		PORT
		(  Counter_1024_EN : IN std_logic; -- Segnale di Enable
			Counter_1024_RST : IN std_logic; -- Segnale di Reset
			Counter_1024_CLK : IN std_logic; -- Segnale di Clock
			Counter_1024_TC : OUT std_logic; -- Segnale di fine conta 
			Counter_1024_OUT : OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT Valid_address
		PORT ( Valid_address_in : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
				 Valid_address_2, Valid_address_3 : OUT STD_LOGIC;
				 Valid_address_counter_LSB : OUT STD_LOGIC
				);
	END COMPONENT;
	
	
		
	COMPONENT Three_operation_block
		PORT ( Three_operation_block_IN : IN SIGNED(7 DOWNTO 0);
				 Three_operation_block_DIV4, 
				 Three_operation_block_MULT2, 
				 Three_operation_block_transparent : OUT SIGNED(9 DOWNTO 0)
				);
	END COMPONENT;

	COMPONENT Register_n
		GENERIC (N : integer := 8);
		PORT (
			Register_D : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0); -- Segnale che viene riportato in uscita al colpo di clock successivo
			Register_Clock, Register_Reset, Register_LOAD : IN std_logic;
			Register_Q : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0) -- Segnale di uscita
		);
	END COMPONENT;

	COMPONENT Register_n_signed
		GENERIC (N : integer := 8);
		PORT (
			Register_D : IN SIGNED(N-1 DOWNTO 0); -- Segnale che viene riportato in uscita al colpo di clock successivo
			Register_Clock, Register_Reset, Register_LOAD : IN std_logic;
			Register_Q : OUT SIGNED(N-1 DOWNTO 0) -- Segnale di uscita
		);
	END COMPONENT;

	
	COMPONENT RCA_18_bit
	GENERIC (N : integer := 18);
		PORT ( RCA_18_bit_in_1, RCA_18_bit_in_2: IN SIGNED(N-1 DOWNTO 0); -- Ingressi su N bit
				 RCA_18_bit_c_in: IN STD_LOGIC; -- Carry_in da sommare al resto
				 RCA_18_bit_out: OUT SIGNED(N-1 DOWNTO 0); -- Risultato della somma su N bit
				 RCA_18_bit_c_out, RCA_18_bit_overflow: BUFFER STD_LOGIC -- Segnali di carry out e overflow (Buffer poich uno serve per l'altro)
		);
	END COMPONENT;

	COMPONENT RCA_10_bit IS
	GENERIC (N : integer := 10);
		PORT ( RCA_10_bit_in_1, RCA_10_bit_in_2: IN SIGNED(N-1 DOWNTO 0); -- Ingressi su N bit
				 RCA_10_bit_c_in: IN STD_LOGIC; -- Carry_in da sommare al resto
				 RCA_10_bit_out: OUT SIGNED(N-1 DOWNTO 0); -- Risultato della somma su N bit
				 RCA_10_bit_c_out, RCA_10_bit_overflow: BUFFER STD_LOGIC -- Segnali di carry out e overflow (Buffer poich uno serve per l'altro)
		);
	END COMPONENT;

	COMPONENT Mux_3_to_1_10bit
		PORT( Mux_3_to_1_10bit_IN_0, Mux_3_to_1_10bit_IN_1, Mux_3_to_1_10bit_IN_2 : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
				Mux_3_to_1_10bit_SEL : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
				Mux_3_to_1_10bit_OUT : OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
			);
	END COMPONENT;
	
	COMPONENT Mux_3_to_1_10bit_signed
		PORT( Mux_3_to_1_10bit_IN_0, Mux_3_to_1_10bit_IN_1, Mux_3_to_1_10bit_IN_2 : IN SIGNED (9 DOWNTO 0);
				Mux_3_to_1_10bit_SEL : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
				Mux_3_to_1_10bit_OUT : OUT SIGNED (9 DOWNTO 0)
			);
	END COMPONENT;

	COMPONENT Ovf_Sign_10_to_8_filter
		PORT ( Ovf_Sign_10_to_8_filter_IN : IN SIGNED(9 DOWNTO 0);
				 Ovf_Sign_10_to_8_filter_OVF, Ovf_Sign_10_to_8_filter_SIGN : OUT STD_LOGIC
				);
	END COMPONENT;

	COMPONENT Cut_10_to_8_filter
		PORT( Cut_10_to_8_filter_IN : IN SIGNED(9 DOWNTO 0);
				Cut_10_to_8_filter_OUT : OUT SIGNED(7 DOWNTO 0)
			  );
	END COMPONENT;

	COMPONENT Average_8_to_18
		PORT( Average_8_to_18_IN : IN SIGNED(7 DOWNTO 0);
				Average_8_to_18_OUT : OUT SIGNED(17 DOWNTO 0)
			  );
	END COMPONENT;

	COMPONENT Sync_RAM
		GENERIC( M : NATURAL  := 3;
					N : NATURAL := 1024
				  );
		PORT( Sync_RAM_Address : IN STD_LOGIC_VECTOR (M-1 DOWNTO 0);
				Sync_RAM_Data : IN SIGNED (N-1 DOWNTO 0);
				Sync_RAM_WR_n, Sync_RAM_Clk, Sync_RAM_RD, Sync_RAM_CS: IN STD_LOGIC;
				Sync_RAM_Q_out : OUT SIGNED (N-1 DOWNTO 0)
			  );
	END COMPONENT;
	
	COMPONENT  Mux_2_to_1_10bit IS
		PORT( Mux_2_to_1_10bit_IN_0, Mux_2_to_1_10bit_IN_1: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
				Mux_2_to_1_10bit_SEL : IN STD_LOGIC;
				Mux_2_to_1_10bit_OUT : OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
			);
	END COMPONENT;

SIGNAL Counter_1024_OUT_s, 
		 Reg_Counter_1_OUT_s, 
		 Reg_Counter_2_OUT_s, 
		 Reg_Counter_3_OUT_s, 
		 Mux_MEM_B_OUT_s,
		 Mux_Address_OUT_s: STD_LOGIC_VECTOR(9 DOWNTO 0); 
		 
SIGNAL Mem_A_Data_OUT_s, 
		 Reg_Samples_OUT_s,
		 Average_s: SIGNED(7 DOWNTO 0);

SIGNAL Three_Operation_Block_DIV4_s, 
		 Three_Operation_Block_MULT2_s, 
		 Three_Operation_Block_Transparent_s,
		 Mux_Operation_OUT_s,
		 Sample_CA1_OUT_s,
		 Block_Sample_n_OUT_s,
		 Sum_Filter_OUT_s,
		 Reg_Filter_OUT_s,
		 Sum_CA1_OUT_s,
		 Mux_Saturation_OUT_s : SIGNED(9 DOWNTO 0);
		 
SIGNAL Cut_10_to_8_Filter_OUT_s : SIGNED(7 DOWNTO 0);

SIGNAL Average_8_to_18_OUT_s,
		 Sum_Average_OUT_s,
		 Reg_Sum_Average_OUT_s: SIGNED(17 DOWNTO 0);
	
BEGIN
	
	Counter : Counter_1024 PORT MAP ( Counter_1024_EN => Counter_1024_EN,
												 Counter_1024_RST => Counter_1024_RST,
												 Counter_1024_CLK => CLK,
												 Counter_1024_TC => Counter_1024_TC,
												 Counter_1024_OUT => Counter_1024_OUT_s
												);
												
	Reg_Counter_1 : Register_n GENERIC MAP ( N => 10 )
										PORT MAP ( Register_D => Counter_1024_OUT_s,
													  Register_Clock => CLK,
													  Register_Reset => Reg_Counter_1_RST,
													  Register_LOAD => Reg_Counter_1_LOAD,
													  Register_Q => Reg_Counter_1_OUT_s
													 );
													 
	Reg_Counter_2 : Register_n GENERIC MAP ( N => 10 )
										PORT MAP ( Register_D => Reg_Counter_1_OUT_s,
													  Register_Clock => CLK,
													  Register_Reset => Reg_Counter_2_RST,
													  Register_LOAD => Reg_Counter_2_LOAD,
													  Register_Q => Reg_Counter_2_OUT_s
													 );
													 
	Reg_Counter_3 : Register_n GENERIC MAP ( N => 10 )
										PORT MAP ( Register_D => Reg_Counter_2_OUT_s,
													  Register_Clock => CLK,
													  Register_Reset => Reg_Counter_3_RST,
													  Register_LOAD => Reg_Counter_3_LOAD,
													  Register_Q => Reg_Counter_3_OUT_s
													 );			
		
	Mux_Address : Mux_3_to_1_10bit PORT MAP ( Mux_3_to_1_10bit_IN_0 => Counter_1024_OUT_s,
											Mux_3_to_1_10bit_IN_1 => Reg_Counter_1_OUT_s,
											Mux_3_to_1_10bit_IN_2 => Reg_Counter_3_OUT_s,
											Mux_3_to_1_10bit_SEL => Mux_Address_SEL,
											Mux_3_to_1_10bit_OUT =>	Mux_Address_OUT_s						
										  );
											
	Valid_Add : Valid_Address PORT MAP ( Valid_address_in => Counter_1024_OUT_s,
										 Valid_address_2 => Valid_Address_2,
										 Valid_address_3 => Valid_Address_3,
										 Valid_address_counter_LSB => Counter_LSB
							   );					

	Mem_A : Sync_RAM GENERIC MAP ( M => 10, N => 8 )
						  PORT MAP ( Sync_RAM_Address  => Mux_Address_OUT_s,
										 Sync_RAM_Data => Data_IN,
									    Sync_RAM_WR_n => Mem_A_WR_n,
										 Sync_RAM_Clk => CLK,
										 Sync_RAM_RD => Mem_A_RD,
										 Sync_RAM_CS => Mem_A_CS,
										 Sync_RAM_Q_out => Mem_A_Data_OUT_s						  
										);
										
	Reg_sample : Register_n_signed GENERIC MAP ( N => 8 )
									PORT MAP ( Register_D => Mem_A_Data_OUT_s,
												  Register_Clock => CLK,
												  Register_Reset => Reg_Samples_RST,
												  Register_LOAD => Reg_Samples_LOAD,
												  Register_Q => Reg_Samples_OUT_s
												 );
												 
	Three_Operations_block : Three_Operation_block 
	   PORT MAP ( Three_operation_block_IN => Reg_samples_OUT_s,
				  Three_operation_block_DIV4 => Three_Operation_Block_DIV4_s,
				  Three_operation_block_MULT2 => Three_Operation_Block_MULT2_s,
				  Three_operation_block_transparent  => Three_Operation_Block_Transparent_s
				 );

	Mux_operation : Mux_3_to_1_10bit_signed 
	        PORT MAP( Mux_3_to_1_10bit_IN_0 => Three_Operation_Block_DIV4_s,
					  Mux_3_to_1_10bit_IN_1 => Three_Operation_Block_Transparent_s,
					  Mux_3_to_1_10bit_IN_2 => Three_Operation_Block_MULT2_s,
					  Mux_3_to_1_10bit_SEL => Mux_Operation_SEL,
					  Mux_3_to_1_10bit_OUT =>	Mux_Operation_OUT_s						
				    );
						
	--sample CA1
	Sample_CA1_OUT_s <= (Mux_Operation_OUT_s(9) XOR Sample_CA_1) &
							  (Mux_Operation_OUT_s(8) XOR Sample_CA_1) &
							  (Mux_Operation_OUT_s(7) XOR Sample_CA_1) &
							  (Mux_Operation_OUT_s(6) XOR Sample_CA_1) &
							  (Mux_Operation_OUT_s(5) XOR Sample_CA_1) &
							  (Mux_Operation_OUT_s(4) XOR Sample_CA_1) &
							  (Mux_Operation_OUT_s(3) XOR Sample_CA_1) &
							  (Mux_Operation_OUT_s(2) XOR Sample_CA_1) &
							  (Mux_Operation_OUT_s(1) XOR Sample_CA_1) &
							  (Mux_Operation_OUT_s(0) XOR Sample_CA_1);
	
	--block sample
	Block_Sample_n_OUT_s <= (Sample_CA1_OUT_s(9) AND Block_Sample_n) &
									(Sample_CA1_OUT_s(8) AND Block_Sample_n) &
									(Sample_CA1_OUT_s(7) AND Block_Sample_n) &
									(Sample_CA1_OUT_s(6) AND Block_Sample_n) &
									(Sample_CA1_OUT_s(5) AND Block_Sample_n) &
									(Sample_CA1_OUT_s(4) AND Block_Sample_n) &
									(Sample_CA1_OUT_s(3) AND Block_Sample_n) &
									(Sample_CA1_OUT_s(2) AND Block_Sample_n) &
									(Sample_CA1_OUT_s(1) AND Block_Sample_n) &
									(Sample_CA1_OUT_s(0) AND Block_Sample_n);
	
	Sum_Filter : RCA_10_bit PORT MAP ( RCA_10_bit_in_1 => Block_Sample_n_OUT_s,
												  RCA_10_bit_in_2 => Sum_CA1_OUT_s,
												  RCA_10_bit_c_in => Sum_Filter_C_IN,
											  	  RCA_10_bit_out => Sum_Filter_OUT_s
												 );
												 
	Reg_Filter : Register_n_signed GENERIC MAP ( N => 10 )
									PORT MAP ( Register_D => Sum_Filter_OUT_s,
												  Register_Clock => CLK,
												  Register_Reset => Reg_Filter_RST,
												  Register_LOAD => Reg_Filter_LOAD,
												  Register_Q => Reg_Filter_OUT_s
												 );
												
	Ovf_sign : Ovf_Sign_10_to_8_Filter
	                PORT MAP(Ovf_Sign_10_to_8_Filter_IN => Sum_Filter_OUT_s,
						     Ovf_Sign_10_to_8_Filter_OVF => Ovf_Sign_10_to_8_filter_OVF,
						     Ovf_Sign_10_to_8_Filter_SIGN => Ovf_Sign_10_to_8_filter_SIGN
					       );
												
	Sum_CA1_OUT_s <= (Reg_Filter_OUT_s(9) XOR Sum_CA_1) &
						  (Reg_Filter_OUT_s(8) XOR Sum_CA_1) &
						  (Reg_Filter_OUT_s(7) XOR Sum_CA_1) &
						  (Reg_Filter_OUT_s(6) XOR Sum_CA_1) &
						  (Reg_Filter_OUT_s(5) XOR Sum_CA_1) &
						  (Reg_Filter_OUT_s(4) XOR Sum_CA_1) &
						  (Reg_Filter_OUT_s(3) XOR Sum_CA_1) &
						  (Reg_Filter_OUT_s(2) XOR Sum_CA_1) &
						  (Reg_Filter_OUT_s(1) XOR Sum_CA_1) &
						  (Reg_Filter_OUT_s(0) XOR Sum_CA_1);
												
	Mux_Saturation : Mux_3_to_1_10bit_signed
	                   PORT MAP ( Mux_3_to_1_10bit_IN_0 => Reg_Filter_OUT_s,
								 Mux_3_to_1_10bit_IN_1 => "1110000000", -- -128
								 Mux_3_to_1_10bit_IN_2 => "0001111111", -- 127
								 Mux_3_to_1_10bit_SEL => Mux_Saturation_SEL,
								 Mux_3_to_1_10bit_OUT => Mux_Saturation_OUT_s						
							   );
															
	Cut_10_to_8 : Cut_10_to_8_Filter PORT MAP ( Cut_10_to_8_filter_IN => Mux_Saturation_OUT_s,
											  Cut_10_to_8_filter_OUT => Cut_10_to_8_filter_OUT_s
											 );
											 
	Mem_B : Sync_RAM GENERIC MAP ( M => 10, N => 8 )
						  PORT MAP ( Sync_RAM_Address => Mux_MEM_B_OUT_s,
										 Sync_RAM_Data => Cut_10_to_8_filter_OUT_s,
									    Sync_RAM_WR_n => Mem_B_WR_n,
										 Sync_RAM_Clk => CLK,
										 Sync_RAM_RD => Mem_B_RD,
										 Sync_RAM_CS => Mem_B_CS,
										 Sync_RAM_Q_out => Data_OUT						  
										);
										
	Mux_MEM_B : Mux_2_to_1_10bit PORT MAP( Mux_2_to_1_10bit_IN_0 => Counter_1024_OUT_s,
										Mux_2_to_1_10bit_IN_1 => MEM_B_ADDRESS_IN,
										Mux_2_to_1_10bit_SEL => Mux_MEM_B_sel,
										Mux_2_to_1_10bit_OUT => Mux_MEM_B_OUT_s
									);
										
	Average_8_to_18_block : Average_8_to_18 
	                        PORT MAP ( Average_8_to_18_IN => Reg_Samples_OUT_s,
									    Average_8_to_18_OUT => Average_8_to_18_OUT_s
								      );
																	  
	Sum_Average : RCA_18_bit PORT MAP ( RCA_18_bit_in_1 => Average_8_to_18_OUT_s,
												   RCA_18_bit_in_2 => Reg_Sum_Average_OUT_s,
												   RCA_18_bit_c_in => '0',
											  	   RCA_18_bit_out => Sum_Average_OUT_s
												 );	
												 
	Reg_Sum_Average : Register_n_signed GENERIC MAP ( N => 18 )
										PORT MAP ( Register_D => Sum_Average_OUT_s,
													  Register_Clock => CLK,
												     Register_Reset => Reg_Sum_Average_RST,
													  Register_LOAD => Reg_Sum_Average_LOAD,
													  Register_Q => Reg_Sum_Average_OUT_s
													 );
	
	Average_s <= Reg_Sum_Average_OUT_s(17 DOWNTO 10);
	Average <= Average_s;
END Structural;
