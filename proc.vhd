LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY proc IS
    PORT (boot     : IN  STD_LOGIC;
          clk      : IN  STD_LOGIC;
          datard_m : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_m   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 wr_m : OUT STD_LOGIC;
			 word_byte : OUT STD_LOGIC;
			 data_wr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 rd_io : IN STD_LOGIC_VECTOR(15 downto 0);
			 wr_io : OUT STD_LOGIC_VECTOR(15 downto 0);
			 addr_io : OUT STD_LOGIC_VECTOR(7 downto 0);
			 rd_in : OUT STD_LOGIC;
			 wr_out : OUT STD_LOGIC;
			 getiid : OUT std_logic;
			 inta : out std_logic;
			 intr : in std_logic);
END proc;


ARCHITECTURE Structure OF proc IS

signal z_s : STD_LOGIC;
   COMPONENT datapath IS
		PORT (clk    : IN STD_LOGIC;
			    op     : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			    wrd    : IN STD_LOGIC;
				d_sys  : IN STD_LOGIC;
				a_sys  : IN STD_LOGIC;
			    addr_a : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		   		addr_d : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		   		immed  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
				addr_b : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
				immed_x2 : IN STD_LOGIC;
				datard_m : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
				ins_dad : IN STD_LOGIC;
				pc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
				in_d : IN STD_LOGIC_VECTOR(1 downto 0);
				data_wr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				addr_m : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				jump_addr : OUT STD_LOGIC_VECTOR(15 downto 0);
				tknbr : OUT STD_LOGIC_VECTOR(1 downto 0);
				rd_io : IN STD_LOGIC_VECTOR(15 downto 0);
				wr_io : OUT STD_LOGIC_VECTOR(15 downto 0);
				
				sys: IN STD_LOGIC;
				enable_int : IN STD_LOGIC;
				disable_int : IN STD_LOGIC;
				reti : IN STD_LOGIC;
				boot : IN STD_LOGIC;
				state_word : OUT STD_LOGIC_VECTOR(15 downto 0);
				invalid_division : out STD_LOGIC;
				id_excep : IN STD_LOGIC_VECTOR(3 downto 0)
				);
				
	END COMPONENT;
	
	component unidad_control IS
		PORT (boot   : IN STD_LOGIC;
				clk    : IN STD_LOGIC;
				datard_m : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
				op     : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
				wrd    : OUT STD_LOGIC;
				addr_a : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				addr_b : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				addr_d : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				immed  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				pc     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				ins_dad : OUT STD_LOGIC;
				in_d : OUT STD_LOGIC_VECTOR(1 downto 0);
				immed_x2 : OUT STD_LOGIC;
				wr_m : OUT STD_LOGIC;
				word_byte : OUT STD_LOGIC;
				jump_addr : IN STD_LOGIC_VECTOR(15 downto 0);
				tknbr : IN STD_LOGIC_VECTOR(1 downto 0);
				addr_io : OUT STD_LOGIC_VECTOR(7 downto 0);
			   rd_in : OUT STD_LOGIC;
			   wr_out : OUT STD_LOGIC;
				
				d_sys  : OUT STD_LOGIC;
				a_sys  : OUT STD_LOGIC;
				sys : OUT STD_LOGIC;
				enable_int : OUT STD_LOGIC;
				disable_int : OUT STD_LOGIC;
				reti : OUT STD_LOGIC;
				getiid : OUT std_logic;
				inta : out std_logic;
			    intr : in std_logic;
				state_word : IN STD_LOGIC_VECTOR(15 downto 0);
				invalid_instr : OUT STD_LOGIC;
				excepr : IN STD_LOGIC

				
				);
	END component;

	component exception_controller IS
    PORT (
	   op : IN STD_LOGIC_VECTOR(9 downto 0);
		byte_word : IN STD_LOGIC;
		addr : IN STD_LOGIC_VECTOR(15 downto 0);
		exception_value : OUT STD_LOGIC_VECTOR(3 downto 0);
		excepr : OUT STD_LOGIC;
		invalid_division : IN STD_LOGIC;
		intr : IN STD_LOGIC;
		invalid_instr : IN STD_LOGIC
		);
	END component;
	
	signal op_signal : std_logic_vector(9 DOWNTO 0);
	signal wrd_signal : std_logic;
   
	signal ins_dad_signal : std_logic;
	signal addr_a_signal : std_logic_vector(2 downto 0);
	signal addr_d_signal : std_logic_vector(2 downto 0);
	signal imed_signal : std_logic_vector( 15 downto 0);
	signal addr_b_signal : std_logic_vector(2 downto 0);
	signal immed_x2_signal : std_logic;
	signal wr_m_signal : std_logic;
	signal pc_signal : std_logic_vector(15 downto 0);
	signal in_d_signal : std_logic_vector(1 downto 0);
	signal tknbr_s : std_logic_vector(1 downto 0);
	
	signal jump_addr_s : std_logic_vector(15 downto 0);
	
	signal a_sys_s : std_logic;
	signal d_sys_s : std_logic;
	signal sys_s : std_logic;
	
	signal enable_int_s : std_logic;
	signal disable_int_s : std_logic;
	
	signal reti_s : std_logic;
	
	signal state_word_s : std_logic_vector(15 downto 0);

	signal addr_m_s : std_logic_vector(15 downto 0);
	signal exception_value_s : std_logic_vector(3 downto 0);
	signal invalid_division_s : std_logic := '0';
	signal invalid_instr_s : std_logic := '0';

	signal intr_s : std_logic;

	signal except_s : std_logic;

BEGIN
	
	unidadcontrol0 : unidad_control
	PORT map (boot  => boot,
				 clk   => clk,
				 datard_m    => datard_m,
				 op    => op_signal,
				 wrd   => wrd_signal,
				 a_sys => a_sys_s,
				 d_sys => d_sys_s,
				 addr_a => addr_a_signal,
				 addr_d => addr_d_signal,
				 addr_b => addr_b_signal,
				 immed  => imed_signal,
				 pc     => pc_signal,
				 ins_dad => ins_dad_signal,
				 in_d  => in_d_signal,
				 immed_x2 => immed_x2_signal,
				 wr_m  => wr_m,
				 word_byte => word_byte,
				 tknbr => tknbr_s,
				 jump_addr => jump_addr_s,
				 addr_io => addr_io,
				 rd_in => rd_in,
				 wr_out => wr_out,
				 sys => sys_s,
				 enable_int => enable_int_s,
				 disable_int => disable_int_s,
				 reti => reti_s,
				 getiid => getiid,
				 inta => inta,
				 intr => intr_s,
				 state_word => state_word_s,
				 invalid_instr => invalid_instr_s,
				 excepr => except_s);
				 
	datapath0 : datapath
	PORT MAP( clk => clk, 
				 op  => op_signal, 
				 wrd => wrd_signal,
				 a_sys => a_sys_s,
				 d_sys => d_sys_s, 
				 addr_a => addr_a_signal, 
				 addr_d => addr_d_signal, 
				 immed  => imed_signal,-- holy
				 addr_b => addr_b_signal,
				 immed_x2 =>  immed_x2_signal,
				 datard_m => datard_m,
				 ins_dad => ins_dad_signal,
				 pc => pc_signal,
				 in_d => in_d_signal,
				 data_wr =>  data_wr,
				 addr_m => addr_m_s,
				 tknbr => tknbr_s,
				 jump_addr => jump_addr_s,
				 rd_io => rd_io,
				 wr_io => wr_io,
				 sys => sys_s,
				 enable_int => enable_int_s,
				 disable_int => disable_int_s,
				 reti => reti_s,
				 boot => boot,
				 state_word => state_word_s,
				 invalid_division => invalid_division_s,
				 id_excep =>exception_value_s

		);
		excep_controller : exception_controller
		PORT MAP(
			op => op_signal,
			byte_word => wrd_signal,
			addr => addr_m_s,
			exception_value => exception_value_s,
			excepr => except_s,
			invalid_division => invalid_division_s,
			invalid_instr => invalid_instr_s,
			intr => intr_s
		);
		
		addr_m <= addr_m_s;
		
		intr_s <= intr;

END Structure;