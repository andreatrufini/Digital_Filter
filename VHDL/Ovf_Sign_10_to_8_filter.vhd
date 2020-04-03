LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Ovf_Sign_10_to_8_filter IS
	PORT ( Ovf_Sign_10_to_8_filter_IN : IN SIGNED(9 DOWNTO 0);
			 Ovf_Sign_10_to_8_filter_OVF, Ovf_Sign_10_to_8_filter_SIGN : OUT STD_LOGIC
			);
END Ovf_Sign_10_to_8_filter;

ARCHITECTURE Behaviour OF Ovf_Sign_10_to_8_filter IS
BEGIN
	--- questo segnale ci dice quando il numero non  rappresentabile su 8 bit, ci si verifica se 
	--- i tre bit pi significativi non sono uguali, ossia i due bit pi significativi devono
	--- essere uguali all'ottavo bit che viene considerato come bit di segno. TROVO LA F LOGICA
	--- NOT((a*b*c) + NOT(a*b*c))=  ->  UNO SE I BIT NON SONO TUTTI UGLUALI
	--- = NOT(a*b*c)*(a+b+c) = (not a + not b + not c)*(a+b+c) = (a xor b)+ (a xor c) + (b xor c)
	
	Ovf_Sign_10_to_8_filter_OVF <= 
			(
			( Ovf_Sign_10_to_8_filter_IN(9) XOR Ovf_Sign_10_to_8_filter_IN(8) )OR 
			( Ovf_Sign_10_to_8_filter_IN(9) XOR Ovf_Sign_10_to_8_filter_IN(7) )OR
			( Ovf_Sign_10_to_8_filter_IN(9) XOR Ovf_Sign_10_to_8_filter_IN(7) ) 
			);
								
				
				
	Ovf_Sign_10_to_8_filter_SIGN <= Ovf_Sign_10_to_8_filter_IN(9);
	
END Behaviour;