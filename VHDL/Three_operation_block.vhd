LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Three_operation_block IS 
	PORT ( Three_operation_block_IN : IN SIGNED(7 DOWNTO 0);
			 Three_operation_block_DIV4, 
			 Three_operation_block_MULT2, 
			 Three_operation_block_transparent : OUT SIGNED(9 DOWNTO 0)
			);
END Three_operation_block;

ARCHITECTURE Structural OF Three_operation_block IS
BEGIN

	Three_operation_block_DIV4 <= (Three_operation_block_IN(7) &
											 Three_operation_block_IN(7) &
											 Three_operation_block_IN(7) &
											 Three_operation_block_IN(7) &
											 Three_operation_block_IN(7 DOWNTO 2));
											 
	Three_operation_block_MULT2 <= Three_operation_block_IN(7) & Three_operation_block_IN & '0';
	
	Three_operation_block_transparent <= Three_operation_block_IN(7) & 
													 Three_operation_block_IN(7) & 
													 Three_operation_block_IN;

END Structural;
			 