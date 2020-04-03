LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Sync_RAM IS 
	GENERIC( M : NATURAL  := 10;
				N : NATURAL := 8
			  );
	PORT( Sync_RAM_Address : IN STD_LOGIC_VECTOR (M-1 DOWNTO 0);
			Sync_RAM_Data : IN SIGNED (N-1 DOWNTO 0);
			Sync_RAM_WR_n, Sync_RAM_Clk, Sync_RAM_RD, Sync_RAM_CS: IN STD_LOGIC;
			Sync_RAM_Q_out : OUT SIGNED (N-1 DOWNTO 0)
		  );
END Sync_RAM;

ARCHITECTURE RTL OF Sync_RAM IS

	TYPE RAM_Array IS ARRAY (0 TO (2**M - 1)) OF SIGNED(N-1 DOWNTO 0);
	SIGNAL Mem : RAM_Array; 

BEGIN

	P0 : PROCESS(Sync_RAM_clk) IS
		BEGIN
			IF Sync_RAM_clk = '1' AND Sync_RAM_clk'event THEN 
				IF Sync_RAM_CS = '1' THEN 
					IF Sync_RAM_WR_n = '0' THEN
						Mem(to_integer(unsigned(Sync_RAM_Address))) <= Sync_RAM_Data;
					END IF;
				END IF;
			END IF;
		IF Sync_RAM_RD = '1' THEN
			Sync_RAM_Q_out <= Mem(to_integer(unsigned(Sync_RAM_Address)));
		ELSE
			Sync_RAM_Q_out <= (OTHERS => '0');
		END IF;
	END PROCESS;

END RTL;