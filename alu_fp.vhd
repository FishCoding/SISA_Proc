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
 
--Operaciones logicas y aritmeticas 
signal addsub : std_logic_vector(15 DOWNTO 0); 

--Comparaciones 
signal cmplt_s : std_logic_vector(15 downto 0); 
signal cmple_s : std_logic_vector(15 downto 0); 
signal cmpeq_s : std_logic_vector(15 downto 0); 

--Extension aritmetica 
signal mul_s : std_logic_vector(15 downto 0); 
signal div_s : std_logic_vector(15 downto 0); 

signal a_mantissa_input : std_logic_vector(22 downto 0);
signal a_exponent_input : std_logic_vector(7 downto 0);
signal b_mantissa_input : std_logic_vector(22 downto 0);
signal b_exponent_input : std_logic_vector(7 downto 0);
signal mantissa_output : std_logic_vector(22 downto 0);
signal exponent_output : std_logic_vector(7 downto 0);
signal overflow_sig : std_logic;
signal add_sub_s : std_logic_vector(31 downto 0);
signal a : std_logic_vector (15 downto 0);
signal b : std_logic_vector (15 downto 0);
--signal mult : std_logic_vector(31 downto 0);
--signal div : std_logic_vector(31 downto 0);
 
signal salida : std_logic_vector(15 downto 0); 
 
BEGIN 
   
	a <= x; 
	b <= y; -- Es esto lo que se quiere?
	
	--Convertimos a FP 32 bits
	a_mantissa_input <= a(8 downto 0) & "00000000000000";
	b_mantissa_input <= b(8 downto 0) & "00000000000000";
	a_exponent_input <= std_logic_vector(unsigned(a(14 downto 9)) - 31 + 127); 
	b_exponent_input <= std_logic_vector(unsigned(b(14 downto 9)) - 31 + 127); 
	
	--Convertimos a FP 16 bits
	exponent_output <= std_logic_vector(unsigned(add_sub_s(30 downto 23)) - 127 + 31);
	mantissa_output <= add_sub_s(22 downto 14);
		
   
	 
	 addsub <= add_sub_s(31) & exponent_output & mantissa_output;
	 
	 --Decidir la salida
	 with op(2 downto 0) select
		salida <= addsub   when "000",
				    addsub   when "001",
				    mul_s   when "010",
				    div_s   when "011",
				    cmplt_s when "100",
				    cmple_s when "101",
				    cmpeq_s when others; --when "111";
				  
	invalid_division <= '1' when op(6 downto 0) = "1001011" 
								 and (y = "0000000000000000" or y = "1000000000000000") else
						'0';
	add_sub_fp_inst : add_sub_fp 
	PORT MAP (
		add_sub	 => op(0),
		clock	 => clk,
		dataa	 => a(15) & a_exponent_input & a_mantissa_input,
		datab	 => b(15) & b_exponent_input & b_mantissa_input,
		overflow	 => overflow_sig,
		result	 => add_sub_s
	);

	mult_inst : mult PORT MAP (
		clock	 => clk,
		dataa	 => a(15) & a_exponent_input & a_mantissa_input,
		datab	 => b(15) & b_exponent_input & b_mantissa_input,
		result	 => mul_s
	);
	
	div_inst : div PORT MAP (
		clock	 => clk,
		dataa	 => a(15) & a_exponent_input & a_mantissa_input,
		datab	 => b(15) & b_exponent_input & b_mantissa_input,
		result	 => div_s
	);
	
	w <= salida;
	 
END Structure;
