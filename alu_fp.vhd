LiBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 
USE ieee.std_logic_unsigned.all; 
 
ENTITY alu_fp IS 
    PORT (x  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); 
          y  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); 
          op : IN  STD_LOGIC_VECTOR(6 DOWNTO 0); 
          w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		    invalid_division : OUT STD_LOGIC;
		    overflow : OUT STD_LOGIC;
		    clk : IN STD_LOGIC
		    ); 
END alu_fp; 

--1 bit signo 6 bits exponente 9 bits mantisa

ARCHITECTURE Structure OF alu_fp IS 

component add_sub_fp
	PORT
	(
		add_sub		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		overflow		: OUT STD_LOGIC ;
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

component mult
	PORT
	(
		clock		: IN STD_LOGIC ;
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		result	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

component div
	PORT
	(
		clock		: IN STD_LOGIC ;
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

component cmp
	PORT
	(
		clock		: IN STD_LOGIC ;
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		alb		: OUT STD_LOGIC 
	);
end component;
 
--Operaciones logicas y aritmeticas 
signal add_sub_s : std_logic_vector(31 DOWNTO 0); 
signal mantissa_suma : std_logic_vector(8 downto 0);
signal exp_suma : std_logic_vector(5 downto 0);
signal add_sub_def : std_logic_vector(15 downto 0);
signal aux_sum : std_logic_vector(7 downto 0);

--Comparaciones 
signal cmplt_s : std_logic; 
signal cmple_s : std_logic; 
signal cmpeq_s : std_logic; 

--Extension aritmetica 
signal mult_s : std_logic_vector(31 downto 0); 
signal mantissa_mult : std_logic_vector(8 downto 0);
signal exp_mult : std_logic_vector(5 downto 0);
signal mult_def : std_logic_vector(15 downto 0);
signal aux_mult : std_logic_vector(7 downto 0);

signal div_s : std_logic_vector(31 downto 0); 
signal mantissa_div : std_logic_vector(8 downto 0);
signal exp_div : std_logic_vector(5 downto 0);
signal div_def : std_logic_vector(15 downto 0);
signal aux_div : std_logic_vector(7 downto 0);

--Inputs
signal a_mantissa_input : std_logic_vector(22 downto 0);
signal a_exponent_input : std_logic_vector(7 downto 0);
signal b_mantissa_input : std_logic_vector(22 downto 0);
signal b_exponent_input : std_logic_vector(7 downto 0);
signal a : std_logic_vector (15 downto 0);
signal b : std_logic_vector (15 downto 0);



signal overflow_sig : std_logic;

--signal mult : std_logic_vector(31 downto 0);
--signal div : std_logic_vector(31 downto 0);
 
signal salida : std_logic_vector(15 downto 0); 
 
BEGIN 
   
	a <= x; 
	b <= y; 
	
	--Convertimos a FP 32 bits
	a_mantissa_input <= a(8 downto 0) & "00000000000000";
	b_mantissa_input <= b(8 downto 0) & "00000000000000";
	
	a_exponent_input <= std_logic_vector(unsigned("00" & std_logic_vector(unsigned(a(14 downto 9)) - 31)) + 127); 
--	a_exponent_input <= std_logic_vector(unsigned(a(14 downto 9)) - 31 + 127); 
	b_exponent_input <= std_logic_vector(unsigned("00" & std_logic_vector(unsigned(b(14 downto 9)) - 31)) + 127); 
	
	
	--Convertimos a FP 16 bits | SUMA Y RESTA
	aux_sum <= std_logic_vector(unsigned(add_sub_s(30 downto 23)) - 127);
	exp_suma <= std_logic_vector(unsigned(aux_sum(5 downto 0)) + 31);
	mantissa_suma <= add_sub_s(22 downto 14);
	
	add_sub_def <= add_sub_s(31) & exp_suma & mantissa_suma;	
	
	--Convertimos a FP 16 bits | MULT
	aux_mult <= std_logic_vector(unsigned(mult_s(30 downto 23)) - 127);
	exp_mult <= std_logic_vector(unsigned(aux_mult(5 downto 0)) + 31);
	mantissa_mult <= mult_s(22 downto 14);
	
	mult_def <= mult_s(31) & exp_mult & mantissa_mult;	
	
	--Convertimos a FP 16 bits | DIV
	aux_div <= std_logic_vector(unsigned(div_s(30 downto 23)) - 127);
	exp_div <= 	std_logic_vector(unsigned(aux_div(5 downto 0)) + 31);
	mantissa_div <= div_s(22 downto 14);
	
	div_def <= div_s(31) & exp_div & mantissa_div;	

	
	cmple_s <= cmplt_s or cmpeq_s;
	
	 --Decidir la salida
	 with op(2 downto 0) select
		salida <= add_sub_def 							when "000",
				    add_sub_def 							when "001",
				    mult_def    							when "010",
				    div_def     							when "011",
				    "000000000000000" & cmplt_s     when "100",
				    "000000000000000" & cmple_s     when "101",
				    "000000000000000" & cmpeq_s     when others; --when "111";
				  
	
							  
							  
	add_sub_fp_inst : add_sub_fp 
	PORT MAP (
		add_sub	 => NOT(op(0)),
		clock	 => clk,
		dataa	 => a(15) & a_exponent_input & a_mantissa_input,
		datab	 => b(15) & b_exponent_input & b_mantissa_input,
		overflow	 => overflow_sig,
		result	 => add_sub_s
	);

	mult_inst : mult 
	PORT MAP (
		clock	 => clk,
		dataa	 => a(15) & a_exponent_input & a_mantissa_input,
		datab	 => b(15) & b_exponent_input & b_mantissa_input,
		result	 => mult_s
	);
	
	div_inst : div 
	PORT MAP (
		clock	 => clk,
		dataa	 => a(15) & a_exponent_input & a_mantissa_input,
		datab	 => b(15) & b_exponent_input & b_mantissa_input,
		result	 => div_s
	);
	
	cmp_inst : cmp 
	PORT MAP (
		clock	 => clk,
		dataa	 => a(15) & a_exponent_input & a_mantissa_input,
		datab	 => b(15) & b_exponent_input & b_mantissa_input,
		alb	 => cmplt_s
	);
	
	invalid_division <= '1' when op(6 downto 0) = "1001011" and (y = "0000000000000000" or y = "1000000000000000") else
						     '0';
	overflow <= overflow_sig when op(6 downto 0) = "1001000" or op(6 downto 0) = "1001001" else --ADDF y SUBF
					'0';
	w <= salida;
	 
END Structure;
