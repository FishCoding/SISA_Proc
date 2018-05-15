LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY unidad_control IS 
	PORT 
	(
		boot   : IN STD_LOGIC;
		clk    : IN STD_LOGIC;
		datard_m : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		op     : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		wrd    : OUT STD_LOGIC;
		addr_a : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		addr_b : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		addr_d : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		immed  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		pc     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		ins_dad: OUT STD_LOGIC;
		in_d : OUT STD_LOGIC_VECTOR(1 downto 0);
		immed_x2 : OUT STD_LOGIC;
		wr_m : OUT STD_LOGIC;
		word_byte : OUT STD_LOGIC;
	   jump_addr : IN STD_LOGIC_VECTOR(15 downto 0);
		tknbr: IN STD_LOGIC_VECTOR(1 downto 0);
		addr_io : OUT STD_LOGIC_VECTOR(7 downto 0);
		rd_in : OUT STD_LOGIC;
		wr_out : OUT STD_LOGIC;
		
		a_sys  : OUT STD_LOGIC;
		d_sys  : OUT STD_LOGIC;
		sys : OUT STD_LOGIC;
		enable_int : OUT STD_LOGIC;
		disable_int : OUT STD_LOGIC;
		reti : OUT STD_LOGIC;
		getiid : OUT std_logic;
		inta : out std_logic;
		intr : in std_logic;
		state_word : IN STD_LOGIC_VECTOR(15 downto 0)
		);
END unidad_control;

ARCHITECTURE Structure OF unidad_control IS

	signal load_pc : std_logic;
	signal immed_s : std_logic_vector(15 downto 0);
	signal inta_l_s : std_logic;
	
	COMPONENT control_l IS
		PORT 
		(
			ir     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op     : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
          ldpc   : OUT STD_LOGIC;
          wrd    : OUT STD_LOGIC;
			
          addr_a : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 wr_m   : OUT STD_LOGIC;
			 in_d   : OUT STD_LOGIC_VECTOR(1 downto 0);
			 immed_x2 : OUT STD_LOGIC;
			 word_byte : OUT STD_LOGIC;
			 addr_io : OUT STD_LOGIC_VECTOR(7 downto 0);
			 rd_in : OUT STD_LOGIC;
			 wr_out : OUT STD_LOGIC;
			 low_ir : OUT STD_LOGIC_VECTOR(5 downto 0);
			 
			 d_sys  : OUT STD_LOGIC;
			 a_sys  : OUT STD_LOGIC;
			 enable_int : OUT STD_LOGIC;
			 disable_int : OUT STD_LOGIC;
			 reti : OUT STD_LOGIC;
			 inta : out std_logic;
			 getiid : OUT std_logic
			
		);
	END COMPONENT;
	
	COMPONENT multi IS
	PORT( 
			clk : IN STD_LOGIC;
			boot : IN STD_LOGIC;
			ldpc_l : IN STD_LOGIC;
			wrd_l : IN STD_LOGIC;
			a_sys_l : IN STD_LOGIC;
			d_sys_l : IN STD_LOGIC;
			wr_m_l : IN STD_LOGIC;
			w_b : IN STD_LOGIC;
			ldpc : OUT STD_LOGIC;
			wrd : OUT STD_LOGIC;
			wr_m : OUT STD_LOGIC;
			ldir : OUT STD_LOGIC;
			ins_dad : OUT STD_LOGIC;
			word_byte : OUT STD_LOGIC;
			--Interrupciones
			a_sys : OUT STD_LOGIC;
			d_sys : OUT STD_LOGIC;
			
			sys: OUT STD_LOGIC;
			inta_l : IN std_logic;
			inta : out std_logic;
			intr : in std_logic;
			state_word : IN STD_LOGIC_VECTOR(15 downto 0));
END COMPONENT;

signal ir_signal : std_logic_vector(15 DOWNTO 0);
signal pc_signal : std_logic_vector(15 downto 0) := X"C000";
signal word_byte_signal : std_logic; 
signal wr_m_signal : std_logic;
signal wrd_signal : std_logic;
signal ldpc_signal : std_logic;
signal ldir_signal : std_logic;

signal a_sys_s : std_logic;
signal d_sys_s : std_logic;

signal op_s : std_logic_vector(9 downto 0);
signal sys_s : std_logic;


BEGIN
	logicacontrol : control_l
	PORT MAP(
		ir => ir_signal,
		op => op_s,
		ldpc => ldpc_signal,
		wrd => wrd_signal,
		a_sys => a_sys_s,
		d_sys => d_sys_s,
		addr_a => addr_a,
		addr_b => addr_b,
		addr_d => addr_d,
		immed => immed_s,
		wr_m => wr_m_signal ,
		in_d => in_d,
		immed_x2 => immed_x2,
		word_byte => word_byte_signal,
		addr_io => addr_io ,
		rd_in => rd_in,
		wr_out => wr_out,
		enable_int => enable_int,
		disable_int => disable_int,
		reti => reti,
		getiid => getiid,
		inta => inta_l_s);
		
	logicamulticiclo : multi
	PORT MAP( 
			clk => clk,
			boot => boot,
			ldpc_l => ldpc_signal,
			wrd_l => wrd_signal,
			a_sys_l => a_sys_s,
			d_sys_l => d_sys_s,
			wr_m_l => wr_m_signal,
			w_b => word_byte_signal,
			ldpc => load_pc,
			wrd => wrd,
			wr_m => wr_m, --Cambiado
			ldir => ldir_signal,
			ins_dad => ins_dad,
			word_byte => word_byte,
			-- Interrupciones
			a_sys => a_sys,
			d_sys => d_sys,
			sys => sys_s,
			intr => intr,
			inta => inta,
			state_word => state_word,
			inta_l => inta_l_s
		
			);


	PROCESS (clk,boot,ldpc_signal,load_pc) BEGIN
		IF boot = '1' THEN
			pc_signal <= X"C000";
			ir_signal <= X"0000";
		ELSIF rising_edge(clk) then
			if ldir_signal = '1' then 
				ir_signal <= datard_m;
			end if;
			if load_pc = '1' then 
				if sys_s = '1' or op_s(9 downto 0) = "1111100100" then 
					pc_signal <= jump_addr;
				elsif tknbr(1 downto 0) = "00" then
					pc_signal <= pc_signal + 2;
				elsif tknbr(1 downto 0) = "01" then
					pc_signal <= pc_signal + (immed_s(14 downto 0)&'0') + 2;
			   elsif tknbr(1 downto 0) = "10" then
					pc_signal <= jump_addr;			
				
			end if;
			
			
			end if;
		END IF;
	END PROCESS;
	immed <= immed_s; 
	pc <=	pc_signal ;
	
	op <= op_s;
	sys <= sys_s;
	
END Structure;