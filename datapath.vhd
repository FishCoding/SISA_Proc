LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY datapath IS
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
			 sys : IN STD_LOGIC;
			 enable_int : IN STD_LOGIC;
			 disable_int : IN STD_LOGIC;
			 reti : IN STD_LOGIC;
			 boot : IN STD_LOGIC;
			 state_word : OUT STD_LOGIC_VECTOR(15 downto 0));
END datapath;


ARCHITECTURE Structure OF datapath IS

    Component alu IS
    PORT (x  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          y  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op : IN  STD_LOGIC_VECTOR(6 DOWNTO 0);
			 z  : OUT std_logic; 
          w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	 END Component;
	 
	 Component regfile IS
    PORT (clk    : IN  STD_LOGIC;
          wrd    : IN  STD_LOGIC;
         
			 addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 d      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 addr_b : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          b      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	 END Component;
	 
	 component system_regfile IS
    PORT (clk    : IN  STD_LOGIC;
          wrd    : IN  STD_LOGIC;
          d      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 sys 	  : IN STD_LOGIC;
			 pc 	  : IN STD_LOGIC_VECTOR(15 downto 0);
			 enable_int : IN STD_LOGIC;
			 disable_int : IN STD_LOGIC;
			 reti : IN STD_LOGIC;
			 boot : IN STD_LOGIC;
			 state_word : OUT STD_LOGIC_VECTOR(15 downto 0));
	 END component;

	 signal salida_alu : std_LOGIC_VECTOR(15 downto 0);
	 signal a_escribir : std_LOGIC_VECTOR(15 downto 0);
	 signal a_leer : std_LOGIC_VECTOR(15 downto 0);
	 signal inmediato : std_LOGIC_VECTOR(15 downto 0);
	 signal z_s : std_logic;
	 signal Rb_N : std_logic_vector(15 downto 0);
	 signal reg_b : std_logic_vector (15 downto 0);
	 signal a_S : std_logic_vector(15 downto 0);
 	 signal a_R : std_logic_vector(15 downto 0);
	 
	 signal write_reg : std_logic_vector(15 downto 0);


BEGIN

	with in_d select
		a_escribir <= salida_alu when "00",
						  datard_m when "01",
							std_logic_vector(unsigned(pc) + 2) when "10",
							rd_io when others;
							
	
	
	write_reg <= a_escribir;--a_S when op(9 downto 0) = "1111101100" else
					 --a_R when op(9 downto 0) = "1111110000" else 
					 --a_escribir;
	
	with immed_x2 select
		inmediato <= immed when '0',
						 immed(14 downto 0)&'0' when others;
	
	with ins_dad select
		addr_m <= pc when '0',
					 salida_alu when others;
	
	with op(9 downto 6) select
		Rb_N <= inmediato when "0010",
				  inmediato when "0011",
				  inmediato when "0100",
				  inmediato when "1101",
				  inmediato when "1110",
				  inmediato when "0101",
				  reg_b when others;
				  
	
		
	jump_addr <= a_leer;
	
	data_wr <= reg_b;
	
	wr_io <= reg_b;
	
	tknbr <= "01" when (op(9 downto 5) = "01100" and z_s='1') or(op(9 downto 5) = "01101" and z_s='0') else 
				"10" when (op(9 downto 3) = "1010000" and z_s='1') or
							 (op(9 downto 3) = "1010001" and z_s='0') or
							  op(9 downto 3) = "1010011" or
							  op(9 downto 3) = "1010100" or 
							  op(9 downto 3) = "1010111" else 
				"00";
	-- mover al control l
   regR : regfile
	Port Map ( clk => clk,
				  wrd => wrd,
				  d => a_escribir,
				  addr_a => addr_a,
				  addr_d => addr_d,
				  a => a_R,
				  addr_b => addr_b,
				  b => reg_b);
				  
	regS : system_regfile
	Port Map ( clk => clk,
				  wrd => d_sys,
				  d => a_escribir,
				  addr_a => addr_a,
				  addr_d => addr_d,
				  a => a_S,
				  sys => sys,
				  pc => pc,
				  enable_int => enable_int,
				  disable_int => disable_int,
				  reti => reti,
				  boot => boot,
				  state_word => state_word);
	
	
	with a_sys select
		a_leer <= a_S when '1',
					 a_R when others;
					 
	alu0 : alu
	Port Map ( x => a_leer,
				  y => Rb_N,
				  op => op(9 downto 3),
				  z => z_s,
				  w => salida_alu);
				 
	 
END Structure;