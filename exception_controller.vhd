LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; --Esta libreria sera necesaria si usais conversiones TO_INTEGER
USE ieee.std_logic_unsigned.ALL; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY exception_controller IS
	PORT 
	(
		clk : IN STD_LOGIC;
		--addr and byte_word
		op               : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		byte_word        : IN STD_LOGIC;
		addr             : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		exception_value  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		excepr           : OUT STD_LOGIC; -- Change to system INTR EXCEP CALLS
		invalid_division : IN STD_LOGIC;
		invalid_instr    : IN STD_LOGIC;
		intr             : IN STD_LOGIC;
		calls            : IN STD_LOGIC;
		state_word 		 : IN STD_LOGIC_VECTOR(15 downto 0);
		instr_protected  : IN STD_LOGIC;
		value_data 		 : OUT STD_LOGIC_VECTOR(15 downto 0);
		system           : IN STD_LOGIC
	);
END exception_controller;
ARCHITECTURE Structure OF exception_controller IS
 
	SIGNAL illegal_addr_s : std_logic := '0';
	SIGNAL illegal_mem_access_s : std_logic := '0';
	SIGNAL addr_illegal : std_logic_vector(15 downto 0);
	SIGNAL exception_value_s : std_logic_vector(3 downto 0);
 
BEGIN
	illegal_addr_s  <= '1' WHEN addr(0) = '1' AND byte_word = '1' AND (op(9 DOWNTO 6) = x"3" OR op(9 DOWNTO 6) = x"4") ELSE '0';

	illegal_mem_access_s <= '1' WHEN system = '0' and state_word(0) = '0' AND addr > x"C000"  AND (op(9 DOWNTO 6) = x"3" OR op(9 DOWNTO 6) = x"4" or op(9 DOWNTO 6) = x"B" or op(9 DOWNTO 6) = x"C") ELSE '0'; -- region s.o
	
	value_data <= addr when addr(0) = '1' AND byte_word = '1' AND (op(9 DOWNTO 6) = x"3" OR op(9 DOWNTO 6) = x"4");

	excepr  <= not(system) and (calls or illegal_mem_access_s OR instr_protected OR illegal_addr_s OR invalid_instr OR invalid_division);-- calls_s or

	exception_value_s <= x"0" WHEN invalid_instr = '1'  ELSE
	                   x"1" WHEN illegal_addr_s = '1'  ELSE
	                   x"4" WHEN invalid_division = '1'   ELSE
					   x"B" when illegal_mem_access_s = '1'   ELSE
					   x"D" when instr_protected = '1'  ELSE
	                   x"E" WHEN calls = '1'  ELSE
	                   x"F" WHEN intr = '1';

	process (clk) BEGIN
		if rising_edge(clk) then
			exception_value <= exception_value_s;
		end if;
	end process;
 END Structure;