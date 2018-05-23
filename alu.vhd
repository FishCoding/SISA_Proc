LiBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 
USE ieee.std_logic_unsigned.all; 
 
ENTITY alu IS 
    PORT (x  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); 
          y  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); 
          op : IN  STD_LOGIC_VECTOR(6 DOWNTO 0); 
          z  : out std_logic; 
          w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 invalid_division : OUT STD_LOGIC
			 ); 
END alu; 
 
ARCHITECTURE Structure OF alu IS 
 
--Operaciones logicas y aritmeticas 
signal add_s : std_logic_vector(15 DOWNTO 0); 
signal and_s : std_logic_vector(15 downto 0); 
signal or_s : std_logic_vector(15 downto 0); 
signal xor_s : std_logic_vector(15 downto 0); 
signal not_s : std_logic_vector(15 downto 0); 
signal sub_s : std_logic_vector(15 downto 0); 
signal sha_s : std_logic_vector(15 downto 0); 
signal shl_s : std_logic_vector(15 downto 0); 
signal salida_la : std_logic_vector(15 downto 0);
 
signal sh_int : integer; 
--Comparaciones 
signal cmplt_s : std_logic_vector(15 downto 0); 
signal cmple_s : std_logic_vector(15 downto 0); 
signal cmpeq_s : std_logic_vector(15 downto 0); 
signal cmpltu_s : std_logic_vector(15 downto 0); 
signal cmpleu_s : std_logic_vector(15 downto 0); 
signal salida_cmp : std_logic_vector(15 downto 0);

--Extension aritmetica 
signal mul_s : std_logic_vector(15 downto 0); 
signal mulh_s : std_logic_vector(15 downto 0); 
signal mulhu_s : std_logic_vector(15 downto 0); 
signal div_s : std_logic_vector(15 downto 0); 
signal divu_s : std_logic_vector(15 downto 0); 
signal mul_int : std_logic_vector(31 downto 0);
signal mul_uint : std_logic_vector(31 downto 0);
signal salida_ea : std_logic_vector(15 downto 0);
--Movimiento
signal movi_s : std_logic_vector(15 downto 0);
signal movhi_s : std_logic_vector(15 downto 0);
signal salida_mov : std_logic_vector(15 downto 0);

signal reg_reg : std_logic_vector(15 downto 0);

--Saltos

signal bz_s : std_logic_vector(15 downto 0);
signal bnz_s : std_logic_vector(15 downto 0);
signal salida_branch : std_logic_vector(15 downto 0);

signal jz_s : std_logic_vector(15 downto 0);
signal jnz_s : std_logic_vector(15 downto 0);
signal jmp_s : std_logic_vector(15 downto 0);
signal jal_s : std_logic_vector(15 downto 0);
signal calls_s : std_logic_vector(15 downto 0); 
signal salida_jump : std_logic_vector(15 downto 0);
 
signal salida : std_logic_vector(15 downto 0); 
 
BEGIN 
     
    --Bloque Ops 
    add_s <= x + y; 
    sub_s <= x - y; 
    and_s <= x AND y; 
    or_s <= x OR y; 
    xor_s <= x XOR y; 
    not_s <= NOT x; 
     
    sh_int <= to_integer(signed(y(4 downto 0))); 
    
	 with y(4) select 
    sha_s <= to_stdlogicvector(to_bitvector(x) sll sh_int) when '0', 
             to_stdlogicvector(to_bitvector(x) sra -sh_int) when others; 
     
    with y(4) select 
    shl_s <= to_stdlogicvector(to_bitvector(x) sll sh_int) when '0', 
             to_stdlogicvector(to_bitvector(x) srl -sh_int) when others; 
				  
	 
	 --Bloque Comparaciones
	 cmplt_s <= x"0001" when signed(x)<signed(y) else
					x"0000";
     
    cmpeq_s <= x"0001" when sub_s = x"0000" else
					x"0000";
	 
	 cmple_s <= cmpeq_s or cmplt_s;
	 
    cmpltu_s <= x"0001" when unsigned(x)<unsigned(y) else
					 x"0000";
	 
    cmpleu_s <= cmpeq_s or cmpltu_s; 
    
	 --Bloque extension aritmetica
	 mul_int <= std_logic_vector(signed(x)*signed(y));
	 mul_uint <= std_logic_vector(unsigned(x)*unsigned(y));
	 mul_s <= mul_int(15 downto 0); 
	 mulh_s <= mul_int(31 downto 16); 
    mulhu_s <= mul_uint(31 downto 16); 
    div_s <= "XXXXXXXXXXXXXXXX" when (x(15 downto 0) = x"8000" and y(15 downto 0) = x"FFFF") or y(15 downto 0) = x"0000" else
				 std_logic_vector(signed(x)/signed(y)) ; 
    divu_s <= "XXXXXXXXXXXXXXXX" when y(15 downto 0) = x"0000" else std_logic_vector(unsigned(x)/unsigned(y)); 
	 
	 invalid_division <= '1' when (op(6 downto 0) = "1000100" or op(6 downto 0) = "1000101") and y = x"0000" else
								'0'; -- DIV OR DIVU
   
	 --Bloque Movimiento
	 movi_s <= y;
	 movhi_s <= y(7 downto 0) & x(7 downto 0);
	 
	 with op(2 downto 0) select
		salida_ea <= mul_s when "000",
						 mulh_s when "001",
						 mulhu_s when "010",
						 div_s when "100",
						 divu_s when others; --101
	 
	 with op(2 downto 0) select
		salida_cmp <= cmplt_s when "000",
						  cmple_s when "001",
						  cmpeq_s when "011",
						  cmpltu_s when "100",
						  cmpleu_s when others; --101
	 
	 with op(2 downto 0) select
		salida_la <= and_s when "000",
						  or_s when "001",
						  xor_s when "010",
						  not_s when "011",
						  add_s when "100",
						  sub_s when "101",
						  sha_s when "110",
						  shl_s when others; --111
	 
	 with op(2) select
		salida_mov <= movi_s when '0',
					  movhi_s when others; --1
			
	 salida_branch <= y;
	 
	 reg_reg <= x;
	 
	
	 salida_jump <=  y when op(6 downto 1) = "101000" else 
					 x + 2;-- when op(6 downto 2) = "10101";

	 salida <= salida_mov when op(6 downto 3) = "0101" else
				  salida_cmp when op(6 downto 3) = "0001" else
				  salida_la when op(6 downto 3) = "0000" else
				  salida_ea when op(6 downto 3) = "1000" else
				--  add_s when op(6 downto 3) = "0010" or op(6 downto 3) = "0011" or op(6 downto 3) = "0100" or op(6 downto 3) = "1110" or op(6 downto 3) = "1101" else
				  salida_branch when op(6 downto 3) = "0110" else 
				  salida_jump when op(6 downto 3)= "1010" else	
				  reg_reg when op(6 downto 2) = "11111" else--when op(9 downto 0) = "1111100100" or op(9 downto 0) = "1111101100" or op(9 downto 0) = "1111110000" else
				  add_s;
   
    z <= '1' when salida = x"0000" else
	      '0';
			
    w <= salida;    
 
END Structure;
