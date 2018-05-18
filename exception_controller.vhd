LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY exception_controller IS
    PORT (
	 --op
	 --addr and byte_word
	 op : IN STD_LOGIC_VECTOR(9 downto 0);
	 byte_word : IN STD_LOGIC;
	 addr : IN STD_LOGIC_VECTOR(15 downto 0);


	 exception_value : OUT STD_LOGIC_VECTOR(3 downto 0);
	 excepr : OUT STD_LOGIC;
	 invalid_division : IN STD_LOGIC;
	 invalid_instr : IN STD_LOGIC;
	 intr : IN STD_LOGIC
	 );
END exception_controller;


ARCHITECTURE Structure OF exception_controller IS
	
	signal illegal_addr_s : std_logic := '0';
	
BEGIN
 
 --illegal_addr_s <= '0';
 illegal_addr_s <= '1' when addr(0) = '1' and byte_word = '1' and (op(9 downto 6) = x"3" or op(9 downto 6) = x"4") else '0';
 
 --calls_s <= '1' when op(9 downto 3)= "1010111" else '0';
 
  excepr <= illegal_addr_s or invalid_instr or invalid_division;--  calls_s or

 

 exception_value <= x"0" when invalid_instr ='1' else
					x"1" when illegal_addr_s ='1' else
					x"4" when invalid_division='1' else
				--	x"E" when calls_s ='1' else
					x"F" when intr='1';
 
 

END Structure;