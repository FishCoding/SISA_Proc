LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY multi IS
	PORT 
	(
		clk       : IN STD_LOGIC;
		boot      : IN STD_LOGIC;
		ldpc_l    : IN STD_LOGIC;
		wrd_gp_int_l : IN STD_LOGIC;
		wrd_gp_fp_l : IN STD_LOGIC;
		sel_br_l   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		d_sys_l   : IN STD_LOGIC;
		wr_m_l    : IN STD_LOGIC;
		w_b       : IN STD_LOGIC;
		ldpc      : OUT STD_LOGIC;
		wrd_gp_int : OUT STD_LOGIC;
		wrd_gp_fp : OUT STD_LOGIC;
		wr_m      : OUT STD_LOGIC;
		ldir      : OUT STD_LOGIC;
		ins_dad   : OUT STD_LOGIC;
		word_byte : OUT STD_LOGIC;
		--Interrupciones
		sel_br      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		d_sys      : OUT STD_LOGIC;
 
		sys        : OUT STD_LOGIC;
		inta_l     : IN std_logic;
		inta       : OUT std_logic;
		intr       : IN std_logic;
		state_word : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		excepr     : IN STD_LOGIC;
		calls 	   : IN STD_LOGIC;
		estado_cpu : OUT std_logic_vector(1 downto 0)
	);
END multi;

ARCHITECTURE Structure OF multi IS
	TYPE state_type IS (FETCH, DEMBOW, SYSTEM);
	SIGNAL estado_actual : state_type;
BEGIN
	PROCESS (boot, clk)
	BEGIN
		IF boot = '1' THEN
			estado_actual <= FETCH;
		ELSIF rising_edge(clk) THEN
 
			CASE estado_actual IS
				WHEN FETCH => estado_actual <= DEMBOW;
				WHEN DEMBOW => 
					IF (intr = '1' OR excepr = '1') AND state_word(1) = '1' THEN
						estado_actual <= SYSTEM;
					ELSE
						estado_actual <= FETCH;
					END IF;
				WHEN SYSTEM => estado_actual <= FETCH;
			END CASE;
		END IF;
	END PROCESS;
	
	-- Cuando se detecta una excepcion mirar senales de escritura
	estado_cpu <= "00" when estado_actual = FETCH else
				  "01" when estado_actual = DEMBOW else
				  "10" when estado_actual = SYSTEM else
				  "11";

	inta <= inta_l WHEN estado_actual = DEMBOW ELSE '0';
	wr_m <= wr_m_l WHEN estado_actual = DEMBOW and excepr='0' ELSE '0';

	ldpc <= ldpc_l WHEN estado_actual = DEMBOW ELSE
	        '1' WHEN estado_actual = SYSTEM ELSE
	        '0'; -- Load PC
	wrd_gp_int <= wrd_gp_int_l WHEN estado_actual = DEMBOW and excepr='0' ELSE '0';
	wrd_gp_fp  <= wrd_gp_fp_l WHEN estado_actual = DEMBOW and excepr='0' ELSE '0';
	word_byte <= w_b WHEN estado_actual = DEMBOW ELSE '0';
	ins_dad   <= '1' WHEN estado_actual = DEMBOW ELSE '0';
	ldir      <= '1' WHEN estado_actual = FETCH ELSE '0';

	sys       <= '1' WHEN estado_actual = SYSTEM ELSE '0';

	d_sys     <= d_sys_l WHEN estado_actual = DEMBOW and excepr='0' ELSE '0';

--	a_sys     <= a_sys_l WHEN estado_actual = DEMBOW ELSE
--					 '1' WHEN estado_actual = SYSTEM ELSE
--					 '0';
					 
	sel_br    <= sel_br_l 	WHEN estado_actual = DEMBOW ELSE
					 "01" 		WHEN estado_actual = SYSTEM ELSE
					 "00";

END Structure;