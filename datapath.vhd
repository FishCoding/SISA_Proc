library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
	port (
		clk : in STD_LOGIC;
		clk_50 : in STD_LOGIC;
		op : in STD_LOGIC_VECTOR(9 downto 0);
		wrd_gp_int : in STD_LOGIC;
		wrd_gp_fp  : in STD_LOGIC;
		d_sys : in STD_LOGIC;
		wrd_simd		     : IN STD_LOGIC_VECTOR(3 DOWNTO 0); --permis escriptura simdBR
		sel_alu_w : IN STD_LOGIC;
		sel_mem_dat	: IN STD_LOGIC_VECTOR(1 downto 0); --inidica de que BR se escoge el dato a escribir en memoria
		sel_br : in STD_LOGIC_VECTOR(1 downto 0);
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
		a : out std_logic_vector(15 downto 0);
		b : out std_logic_vector(15 downto 0);
		pc_fancy  : IN STD_LOGIC_VECTOR(15 downto 0);
		invalid_division_fp : out STD_LOGIC;
		overflow_fp : out STD_LOGIC
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
	
	component alu_fp is
		port (
			 x  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); 
          y  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); 
          op : IN  STD_LOGIC_VECTOR(6 DOWNTO 0); 
          w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 invalid_division : OUT STD_LOGIC;
			 overflow : OUT STD_LOGIC;
		    clk : IN STD_LOGIC
			 ); 
	end component;
	
	component alu_simd IS 
    PORT (a0 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); 
          a1 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          a2 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); 
          a3 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); --Bit 2 ADD/SUB, Bits 1 i 0: 00 Word, 01 2Bytes, 10 4Bytes 
          w0 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          w1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
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

	component simd_regfile IS
    PORT (clk    : IN  STD_LOGIC;
          wrd0   : IN  STD_LOGIC;
          wrd1   : IN  STD_LOGIC;
          wrd2   : IN  STD_LOGIC;
          wrd3   : IN  STD_LOGIC;
          d0     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          d1     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          d2     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          d3     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          r0     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          r1     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          r2     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		  r3     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	END component;

	signal salida_alu : std_LOGIC_VECTOR(15 downto 0);
	signal salida_alu_fp : STD_LOGIC_VECTOR (15 downto 0);
	signal salida_alu_int : STD_LOGIC_VECTOR (15 downto 0);
	signal a_escribir : std_LOGIC_VECTOR(15 downto 0);
	signal a_leer : std_LOGIC_VECTOR(15 downto 0);
	signal inmediato : std_LOGIC_VECTOR(15 downto 0);
	signal z_s : std_logic;
	signal Rb_N : std_logic_vector(15 downto 0);
	signal b_GP_INT : std_logic_vector (15 downto 0);
	signal b_GP_FP  : std_logic_vector (15 downto 0);
	signal b_GP_SIMD  : std_logic_vector (15 downto 0);
	signal a_S : std_logic_vector(15 downto 0);
	signal a_GP_INT : std_logic_vector(15 downto 0);
	signal a_GP_FP  : std_logic_vector(15 downto 0);
	signal a_GP_SIMD  : std_logic_vector(15 downto 0);

 
	signal write_reg : std_logic_vector(15 downto 0);

	signal a_reg  : std_logic_vector(15 downto 0);
	signal addr_m_s : std_logic_vector(15 downto 0);
	signal addr_m_fancy : std_logic_vector(15 downto 0);

	signal overflow_signal 			 : std_logic;
	signal exc_invalid_division : std_logic;

	--Signals SIMD
	signal r0_simd : std_logic_vector(15 downto 0);
	signal r1_simd : std_logic_vector(15 downto 0);
	signal r2_simd : std_logic_vector(15 downto 0);
	signal r3_simd : std_logic_vector(15 downto 0);
	signal d0_simd : std_logic_vector(15 downto 0);
	signal d1_simd : std_logic_vector(15 downto 0);
	signal d2_simd : std_logic_vector(15 downto 0);
	signal d3_simd : std_logic_vector(15 downto 0);
	signal salida_alu_simd0 : std_logic_vector(15 downto 0);
	signal salida_alu_simd1 : std_logic_vector(15 downto 0);

begin

	with in_d select -- esto va a los br's (puerto d)
	a_escribir <= salida_alu when "00", 
	              datard_m 	 when "01", 	
	              std_logic_vector(unsigned(pc) + 2) when "10", 
	              rd_io      when others;
 
	process(clk,boot) begin
		if rising_edge(clk) then	
			a_reg <= a_leer;		
		end if;
	end process;

	write_reg <= a_reg when sys= '1' else a_escribir; -- Cosas del SYS
 
	with immed_x2 select
	inmediato <= immed when '0', 
	             immed(14 downto 0) & '0' when others;
 
	with ins_dad select
	addr_m_s <= pc when '0', 
	          salida_alu when others;
 
	process (clk) begin
		if rising_edge(clk) then
			addr_m_fancy <= addr_m_s;
		end if;
	end process;
	
	addr_m <= addr_m_s;
	
	with op(9 downto 6) select -- Immediato que va a la ALU
	Rb_N <= inmediato when "0010", 
	        inmediato when "0011", 
	        inmediato when "0100", 
	        inmediato when "1101", 
	        inmediato when "1110", 
	        inmediato when "0101",
			  inmediato when "1011",
			  inmediato when "1100", 
			  b_GP_FP   when "1001",
	        b_GP_INT 	when others;

	jump_addr <= a_leer;
 
	with addr_b(1 downto 0) select
		b_GP_SIMD <= r0_simd when "00",
						 r1_simd when "01",
						 r2_simd when "10",
						 r3_simd when others; --"11"
	
	data_wr <= b_GP_SIMD WHEN sel_mem_dat = "10" ELSE
				  b_GP_INT  WHEN sel_mem_dat = "00" ELSE
				  b_GP_FP; -- En memoria puede ir tanto un float como un INT como un SIMD
 
	wr_io <= b_GP_INT;
 
	tknbr <= "01" when (op(9 downto 5) = "01100" and z_s = '1') or(op(9 downto 5) = "01101" and z_s = '0') else
	         "10" when (op(9 downto 3) = "1010000" and z_s = '1') or
	         (op(9 downto 3) = "1010001" and z_s = '0') or
	         op(9 downto 3) = "1010011" or
	         op(9 downto 3) = "1010100"  else
	         "00";
	
	a <= a_GP_INT; -- SON COSAS DE LA TLB SIEMPRE DEL REG DE ENTEROS
	b <= b_GP_INT;
	
	regGeneralPurposeINT : regfile
	port map(
		clk => clk, 
		wrd => wrd_gp_int, 
		d => a_escribir, 
		addr_a => addr_a, 
		addr_d => addr_d, 
		a => a_GP_INT, 
		addr_b => addr_b, 
		b => b_GP_INT
	);
	
	regGeneralPurposeFP : regfile
	port map (
		clk => clk,
		wrd => wrd_gp_fp,
		d	 => a_escribir,
		addr_a => addr_a,
		addr_d => addr_d,
		a => a_GP_FP,
		addr_b => addr_b,
		b => b_GP_FP
	);

	regGeneralPurposeSIMD : simd_regfile
    PORT map (
		clk    => clk,
        wrd0   => wrd_simd(0),
        wrd1   => wrd_simd(1),
		  wrd2   => wrd_simd(2),
        wrd3   => wrd_simd(3),
        d0     => d0_simd,
        d1     => d1_simd,
        d2     => d2_simd,
        d3     => d3_simd,
        r0     => r0_simd,
        r1     => r1_simd,
        r2     => r2_simd,
		  r3     => r3_simd
	);
	
	d0_simd <= datard_m when op(9 downto 6) = "1111" else salida_alu_simd0;
	d1_simd <= datard_m when op(9 downto 6) = "1111" else salida_alu_simd1;
	d2_simd <= datard_m;
	d3_simd <= datard_m;
	
	regS : system_regfile
	port map(
		clk => clk, 
		wrd => d_sys, 
		d => write_reg, 
		addr_a => addr_a, 
		addr_d => addr_d, 
		a => a_S, 
		sys => sys, 
		pc => pc_fancy, 
		enable_int => enable_int, 
		disable_int => disable_int, 
		reti => reti, 
		boot => boot, 
		state_word => state_word,
		id_excep => id_excep,
		value_data => addr_m_fancy
	);
 
	with sel_br select -- Permite seleccionar el banco de registros del cual se lee el puerto A
	a_leer <= a_GP_INT  	when "00",
				 a_S			when "01",  
	          a_GP_FP 	when others; -- 10, 11 ...
 
	alu0 : alu
	port map(
		x => a_leer, -- Ahora puede ser de INT, FP o SYS
		y => Rb_N, 
		op => op(9 downto 3), 
		z => z_s, 
		w => salida_alu_int, 
		invalid_division => invalid_division
	);
 
   aluFP : alu_fp
	port map(
		x  => a_leer,
		y  => Rb_N,
      op => op(9 downto 3),
      w  => salida_alu_fp,
		invalid_division => exc_invalid_division,
		overflow => overflow_signal,
		clk => clk_50
	); 
	
	aluSIMD : alu_simd 
   port map (
		a0 => r0_simd,
      a1 => r1_simd,
      a2 => r2_simd,
      a3 => r3_simd,
      op => op(5 downto 3),
      w0 => salida_alu_simd0,
      w1 => salida_alu_simd1
	); 
	
	
	overflow_fp <= overflow_signal;
	invalid_division_fp <= exc_invalid_division;
	
	salida_alu <= salida_alu_int WHEN sel_alu_w = '0' ELSE
					  salida_alu_fp; 
   
end Structure;
