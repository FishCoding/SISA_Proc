library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
	port (
		clk : in STD_LOGIC;
		op : in STD_LOGIC_VECTOR(9 downto 0);
		wrd : in STD_LOGIC;
		d_sys : in STD_LOGIC;
		a_sys : in STD_LOGIC;
		addr_a : in STD_LOGIC_VECTOR(2 downto 0);
		addr_d : in STD_LOGIC_VECTOR(2 downto 0);
		immed : in STD_LOGIC_VECTOR(15 downto 0);
		addr_b : in STD_LOGIC_VECTOR(2 downto 0);
		immed_x2 : in STD_LOGIC;
		datard_m : in STD_LOGIC_VECTOR(15 downto 0);
		ins_dad : in STD_LOGIC;
		pc : in STD_LOGIC_VECTOR(15 downto 0);
		in_d : in STD_LOGIC_VECTOR(1 downto 0);
		data_wr : out STD_LOGIC_VECTOR(15 downto 0);
		addr_m : out STD_LOGIC_VECTOR(15 downto 0);
 
		jump_addr : out STD_LOGIC_VECTOR(15 downto 0);
		tknbr : out STD_LOGIC_VECTOR(1 downto 0);
 
		rd_io : in STD_LOGIC_VECTOR(15 downto 0);
		wr_io : out STD_LOGIC_VECTOR(15 downto 0);
		sys : in STD_LOGIC;
		enable_int : in STD_LOGIC;
		disable_int : in STD_LOGIC;
		reti : in STD_LOGIC;
		boot : in STD_LOGIC;
		state_word : out STD_LOGIC_VECTOR(15 downto 0);
		invalid_division : out STD_LOGIC;
		id_excep : IN STD_LOGIC_VECTOR(3 downto 0);
		value_data 		  : IN STD_LOGIC_VECTOR(15 downto 0);
		a : out std_logic_vector(15 downto 0);
		b : out std_logic_vector(15 downto 0)
	);
end datapath;
architecture Structure of datapath is

	component alu is
		port (
			x : in STD_LOGIC_VECTOR(15 downto 0);
			y : in STD_LOGIC_VECTOR(15 downto 0);
			op : in STD_LOGIC_VECTOR(6 downto 0);
			z : out std_logic;
			w : out STD_LOGIC_VECTOR(15 downto 0);
			invalid_division : out STD_LOGIC
		);
	end component;
 
	component regfile is
		port (
			clk : in STD_LOGIC;
			wrd : in STD_LOGIC;
 
			addr_d : in STD_LOGIC_VECTOR(2 downto 0);
			d : in STD_LOGIC_VECTOR(15 downto 0);
			addr_a : in STD_LOGIC_VECTOR(2 downto 0);
			a : out STD_LOGIC_VECTOR(15 downto 0);
			addr_b : in STD_LOGIC_VECTOR(2 downto 0);
			b : out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;
 
	component system_regfile is
		port (
			clk : in STD_LOGIC;
			wrd : in STD_LOGIC;
			d : in STD_LOGIC_VECTOR(15 downto 0);
			addr_a : in STD_LOGIC_VECTOR(2 downto 0);
			addr_d : in STD_LOGIC_VECTOR(2 downto 0);
			a : out STD_LOGIC_VECTOR(15 downto 0);
			sys : in STD_LOGIC;
			pc : in STD_LOGIC_VECTOR(15 downto 0);
			enable_int : in STD_LOGIC;
			disable_int : in STD_LOGIC;
			reti : in STD_LOGIC;
			boot : in STD_LOGIC;
			state_word : out STD_LOGIC_VECTOR(15 downto 0);
			id_excep : IN STD_LOGIC_VECTOR(3 downto 0);
			value_data : IN STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

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

	signal a_reg  : std_logic_vector(15 downto 0);

begin
	with in_d select
	a_escribir <= salida_alu when "00", 
	              datard_m when "01", 
	              std_logic_vector(unsigned(pc) + 2) when "10", 
	              rd_io when others;
 
	

	process(clk,boot) begin
		if rising_edge(clk) then	
			a_reg <= a_leer;		
		end if;
	end process;

	write_reg <= a_reg when sys= '1' else a_escribir;--a_S when op(9 downto 0) = "1111101100" else
	--a_R when op(9 downto 0) = "1111110000" else
	--a_escribir;
 
	with immed_x2 select
	inmediato <= immed when '0', 
	             immed(14 downto 0) & '0' when others;
 
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
 
	tknbr <= "01" when (op(9 downto 5) = "01100" and z_s = '1') or(op(9 downto 5) = "01101" and z_s = '0') else
	         "10" when (op(9 downto 3) = "1010000" and z_s = '1') or
	         (op(9 downto 3) = "1010001" and z_s = '0') or
	         op(9 downto 3) = "1010011" or
	         op(9 downto 3) = "1010100"  else
	         "00";
	-- mover al control l
	
	a <= a_R;
	b <= reg_b;
	
	regR : regfile
	port map(
		clk => clk, 
		wrd => wrd, 
		d => a_escribir, 
		addr_a => addr_a, 
		addr_d => addr_d, 
		a => a_R, 
		addr_b => addr_b, 
		b => reg_b
	);
 
	regS : system_regfile
	port map(
		clk => clk, 
		wrd => d_sys, 
		d => write_reg, 
		addr_a => addr_a, 
		addr_d => addr_d, 
		a => a_S, 
		sys => sys, 
		pc => pc, 
		enable_int => enable_int, 
		disable_int => disable_int, 
		reti => reti, 
		boot => boot, 
		state_word => state_word,
		id_excep => id_excep,
		value_data => value_data
	);
 
 
	with a_sys select -- wrs rds
	a_leer <= a_S when '1', 
	          a_R when others;
 
	alu0 : alu
	port map(
		x => a_leer, 
		y => Rb_N, 
		op => op(9 downto 3), 
		z => z_s, 
		w => salida_alu, 
		invalid_division => invalid_division
	);
 
 
end Structure;