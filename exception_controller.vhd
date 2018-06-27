LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; --Esta libreria sera necesaria si usais conversiones TO_INTEGER
USE ieee.std_logic_unsigned.ALL; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY exception_controller IS
	PORT 
	(
		clk : IN STD_LOGIC;
		--addr and byte_word
		op                  : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		byte_word           : IN STD_LOGIC;
		addr                : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		exception_value     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		excepr              : OUT STD_LOGIC; -- Change to system INTR EXCEP CALLS
		invalid_division    : IN STD_LOGIC;
		invalid_division_fp : IN STD_LOGIC;
		overflow_fp         : IN STD_LOGIC;
		invalid_instr       : IN STD_LOGIC;
		intr                : IN STD_LOGIC;
		calls               : IN STD_LOGIC;
		state_word          : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		instr_protected     : IN STD_LOGIC;
--		value_data          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		system              : IN STD_LOGIC;
		tlb_miss_inst       : IN STD_LOGIC;
		tlb_miss_datos      : IN STD_LOGIC;
		tlb_invalid_inst    : IN STD_LOGIC;
		tlb_invalid_datos   : IN STD_LOGIC;
		tlb_lectura_datos   : IN STD_LOGIC;
		estado_cpu          : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END exception_controller;
ARCHITECTURE Structure OF exception_controller IS

	SIGNAL illegal_addr_s       : std_logic := '0';
	SIGNAL illegal_mem_access_s : std_logic := '0';
	SIGNAL addr_illegal         : std_logic_vector(15 DOWNTO 0);
	SIGNAL exception_value_s    : std_logic_vector(3 DOWNTO 0);
	
	SIGNAL instr_protected_s    : std_logic;
	SIGNAL tlb_miss_inst_s      : std_logic;
	SIGNAL tlb_miss_datos_s     : std_logic;
	SIGNAL tlb_invalid_inst_s   : std_logic;
	SIGNAL tlb_invalid_datos_s  : std_logic;
	SIGNAL tlb_prot_inst_s      : std_logic;
	SIGNAL tlb_prot_datos_s     : std_logic;
	SIGNAL tlb_lectura_datos_s  : std_logic;

BEGIN
	illegal_addr_s <= '1' WHEN addr(0) = '1' AND byte_word = '1' AND (op(9 DOWNTO 6) = x"3" OR op(9 DOWNTO 6) = x"4") ELSE '0';

	-- illegal_mem_access_s <= '1' WHEN system = '0' and state_word(0) = '0' AND addr > x"C000" AND (op(9 DOWNTO 6) = x"3" OR op(9 DOWNTO 6) = x"4" or op(9 DOWNTO 6) = x"B" or op(9 DOWNTO 6) = x"C") ELSE '0'; -- region s.o
 
--	value_data          <= addr WHEN addr(1) = '1' AND byte_word = '1' AND (op(9 DOWNTO 6) = x"3" OR op(9 DOWNTO 6) = x"4") ELSE
--								  "XXXXXXXXXXXXXXXX";
--					 ir(15 DOWNTO 11) & "00000" WHEN ir(15 DOWNTO 12) = "1111" and ir(5) = '0' ELSE --simd_LD i simd_ST

	instr_protected_s <= instr_protected WHEN estado_cpu = "01" ELSE '0';
	tlb_miss_inst_s     <= '1' WHEN tlb_miss_inst = '1' AND estado_cpu = "00" ELSE '0';
	tlb_miss_datos_s    <= '1' WHEN tlb_miss_datos = '1' AND estado_cpu = "01" AND 
												(op(9 DOWNTO 6)= "0011" OR op(9 DOWNTO 6) = "0100" OR op(9 DOWNTO 6) = "1101" OR op(9 DOWNTO 6) = "1110"
												 OR op(9 DOWNTO 6) = "1011" OR op(9 DOWNTO 6) = "1100" OR op(9 DOWNTO 5) = "11110") ELSE '0'; --LDF, STF i LD/ST SIMD
	tlb_invalid_inst_s  <= '1' WHEN tlb_invalid_inst = '1' AND estado_cpu = "00" ELSE '0';
	tlb_invalid_datos_s <= '1' WHEN tlb_invalid_datos = '1' AND estado_cpu = "01" AND 
												(op(9 DOWNTO 6)= "0011" OR op(9 DOWNTO 6) = "0100" OR op(9 DOWNTO 6) = "1101" OR op(9 DOWNTO 6) = "1110"
												 OR op(9 DOWNTO 6) = "1011" OR op(9 DOWNTO 6) = "1100" OR op(9 DOWNTO 5) = "11110") ELSE '0'; --LDF, STF i LD/ST SIMD
	tlb_prot_inst_s     <= '1' WHEN estado_cpu = "00" AND state_word(0) = '0' AND addr > x"BFFF" ELSE '0';
	tlb_prot_datos_s    <= '1' WHEN estado_cpu = "01" AND state_word(0) = '0' AND addr > x"BFFF" AND 
												(op(9 DOWNTO 6)= "0011" OR op(9 DOWNTO 6) = "0100" OR op(9 DOWNTO 6) = "1101" OR op(9 DOWNTO 6) = "1110"
												 OR op(9 DOWNTO 6) = "1011" OR op(9 DOWNTO 6) = "1100" OR op(9 DOWNTO 5) = "11110") ELSE '0'; --LDF, STF i LD/ST SIMD
	tlb_lectura_datos_s <= '1' WHEN tlb_lectura_datos_s = '1' AND estado_cpu = "01" AND  
												(op(9 DOWNTO 6) = "0100" OR  op(9 DOWNTO 6) = "1110"
												 OR op(9 DOWNTO 6) = "1100" OR op(9 DOWNTO 4) = "111101") ELSE '0'; --STF i ST SIMD
 
	excepr <= NOT(system) AND (calls OR illegal_mem_access_s OR instr_protected_s OR illegal_addr_s OR invalid_instr OR invalid_division OR 
								tlb_miss_inst_s OR tlb_miss_datos_s OR tlb_invalid_inst_s OR tlb_invalid_datos_s OR tlb_prot_inst_s OR
								tlb_prot_datos_s OR tlb_lectura_datos_s OR invalid_division_fp OR overflow_fp);-- calls_s or

	exception_value_s   <= x"0" WHEN invalid_instr = '1' ELSE
	                       x"1" WHEN illegal_addr_s = '1' ELSE
								  x"2" WHEN overflow_fp = '1' ELSE
								  x"3" WHEN invalid_division_fp = '1' ELSE
	                       x"4" WHEN invalid_division = '1' ELSE
	                       x"6" WHEN tlb_miss_inst_s = '1' ELSE
	                       x"7" WHEN tlb_miss_datos_s = '1' ELSE
	                       x"8" WHEN tlb_invalid_inst_s = '1' ELSE
	                       x"9" WHEN tlb_invalid_datos_s = '1' ELSE
	                       x"A" WHEN tlb_prot_inst_s = '1' ELSE
	                       x"B" WHEN tlb_prot_datos_s = '1' ELSE
	                       x"C" WHEN tlb_lectura_datos_s = '1' ELSE
	                       x"D" WHEN instr_protected_s = '1' ELSE
	                       x"E" WHEN calls = '1' ELSE
	                       x"F" WHEN intr = '1';

	PROCESS (clk) BEGIN
	IF rising_edge(clk) THEN
		exception_value <= exception_value_s;
	END IF;
END PROCESS;
END Structure;