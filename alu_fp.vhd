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

component add
	PORT
	(
		clock		: IN STD_LOGIC ;
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

component sub
	PORT
	(
		clock		: IN STD_LOGIC ;
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
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
 
--Suma
signal add_s : std_logic_vector(31 DOWNTO 0); 
signal mantissa_suma : std_logic_vector(8 downto 0);
signal exp_suma : std_logic_vector(5 downto 0);
signal add_def : std_logic_vector(15 downto 0);
signal aux_add : std_logic_vector(7 downto 0);
signal overflow_add : std_logic;

--Resta
signal sub_s : std_logic_vector(31 DOWNTO 0); 
signal mantissa_resta : std_logic_vector(8 downto 0);
signal exp_resta : std_logic_vector(5 downto 0);
signal sub_def : std_logic_vector(15 downto 0);
signal aux_sub : std_logic_vector(7 downto 0);
signal overflow_sub : std_logic;

--Comparacions 
signal cmplt_s : std_logic; 
signal cmple_s : std_logic; 
signal cmpeq_s : std_logic; 

--Multiplicacio 
signal mult_s : std_logic_vector(31 downto 0); 
signal mantissa_mult : std_logic_vector(8 downto 0);
signal exp_mult : std_logic_vector(5 downto 0);
signal mult_def : std_logic_vector(15 downto 0);
signal aux_mult : std_logic_vector(7 downto 0);
signal overflow_mult : std_logic;

--Divisio
signal div_s : std_logic_vector(31 downto 0); 
signal mantissa_div : std_logic_vector(8 downto 0);
signal exp_div : std_logic_vector(5 downto 0);
signal div_def : std_logic_vector(15 downto 0);
signal aux_div : std_logic_vector(7 downto 0);
signal overflow_div : std_logic;

--Inputs
signal a_mantissa_input : std_logic_vector(22 downto 0);
signal a_exponent_input : std_logic_vector(7 downto 0);
signal b_mantissa_input : std_logic_vector(22 downto 0);
signal b_exponent_input : std_logic_vector(7 downto 0);
signal a : std_logic_vector (15 downto 0);
signal b : std_logic_vector (15 downto 0);

 
signal salida : std_logic_vector(15 downto 0); 
 
BEGIN 
   
	a <= x; 
	b <= y; 
	
	--Convertimos a FP 32 bits
	a_mantissa_input <= a(8 downto 0) & "00000000000000";
	b_mantissa_input <= b(8 downto 0) & "00000000000000";
	
	a_exponent_input <= x"00" when a(14 downto 9) = "000000" else
							  std_logic_vector(unsigned("00" & std_logic_vector(unsigned(a(14 downto 9)) - 31)) + 127); 
	b_exponent_input <= x"00" when b(14 downto 9) = "000000" else
							  std_logic_vector(unsigned("00" & std_logic_vector(unsigned(b(14 downto 9)) - 31)) + 127); 
	
	
	--Nomes es detecta overflow, si el valor queda per sota del representable en 16 bits s'ignora, el programador es l'encarregat de comprobar aixo
	--El valor d'exponent 0 es tracta per separat
	--Convertimos a FP 16 bits | SUMA
	aux_add <= std_logic_vector(unsigned(add_s(30 downto 23)) - 127);
	exp_suma <= "000000" when add_s(30 downto 23) = "00000000" else
					std_logic_vector(unsigned(aux_add(5 downto 0)) + 31);
	mantissa_suma <= add_s(22 downto 14);
	
	add_def <= add_s(31) & exp_suma & mantissa_suma;

	--Convertimos a FP 16 bits | RESTA
	aux_sub <= std_logic_vector(unsigned(sub_s(30 downto 23)) - 127);
	exp_resta <= "000000" when sub_s(30 downto 23) = "00000000" else
					 std_logic_vector(unsigned(aux_sub(5 downto 0)) + 31);
	mantissa_resta <= sub_s(22 downto 14);
	
	sub_def <= sub_s(31) & exp_resta & mantissa_resta;
	
	--Convertimos a FP 16 bits | MULT
	aux_mult <= std_logic_vector(unsigned(mult_s(30 downto 23)) - 127);
	exp_mult <= "000000" when mult_s(30 downto 23) = "00000000" else
					std_logic_vector(unsigned(aux_mult(5 downto 0)) + 31);
	mantissa_mult <= mult_s(22 downto 14);
	
	mult_def <= mult_s(31) & exp_mult & mantissa_mult;	
	
	--Convertimos a FP 16 bits | DIV
	aux_div <= std_logic_vector(unsigned(div_s(30 downto 23)) - 127);
	exp_div <= "000000" when div_s(30 downto 23) = "00000000" else
				  std_logic_vector(unsigned(aux_div(5 downto 0)) + 31);
	mantissa_div <= div_s(22 downto 14);
	
	div_def <= div_s(31) & exp_div & mantissa_div;	

	cmpeq_s <= '1' when (a = x"8000" and b = x"0000") or (a = x"0000" and b = x"8000") else --controlem la excepcio del 0
				  '1' when a = b else
				  '0';
	
	cmple_s <= cmplt_s or cmpeq_s;
	
	 --Decidir la salida
	 with op(2 downto 0) select
		salida <= add_def 								when "000",
				    sub_def 								when "001",
				    mult_def    							when "010",
				    div_def     							when "011",
				    "000000000000000" & cmplt_s     when "100",
				    "000000000000000" & cmple_s     when "101",
				    "000000000000000" & cmpeq_s     when others; --when "111";
				  
	--Tractar l'overflow. Com els moduls son de 32 bits, mai tindran un overflow. El que hem de comprobar es que l'exponent que retorna esta
	--en el rang de valors representables per el floating point de SISA, es a dir, que l'exponent no superi el +31 (0x9E)
	overflow_add <= '1' when add_s(30 downto 23) > x"9E" and op(6 downto 0) = "1001000" else
						 '0';
						 
	overflow_sub <= '1' when sub_s(30 downto 23) > x"9E" and op(6 downto 0) = "1001001" else
						 '0';
	
	overflow_mult <= '1' when mult_s(30 downto 23) > x"9E" and op(6 downto 0) = "1001010" else
						 '0';
	
	overflow_div <= '1' when div_s(30 downto 23) > x"9E" and op(6 downto 0) = "1001011" else
						 '0';
						 
	with op(2 downto 0) select
		overflow <= overflow_add  when "000",
						overflow_sub  when "001",
						overflow_mult when "010",
						overflow_div  when "011",
						'0'           when others;
							  
	add_inst : add 
	PORT MAP (
		clock	 => clk,
		dataa	 => a(15) & a_exponent_input & a_mantissa_input,
		datab	 => b(15) & b_exponent_input & b_mantissa_input,
		result	 => add_s
	);
	
	sub_inst : sub 
	PORT MAP (
		clock	 => clk,
		dataa	 => a(15) & a_exponent_input & a_mantissa_input,
		datab	 => b(15) & b_exponent_input & b_mantissa_input,
		result	 => sub_s
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
	
	
	w <= salida;
	 
END Structure;
