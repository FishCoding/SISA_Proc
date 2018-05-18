LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY control_l IS
    PORT (ir     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
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
			 getiid : OUT std_logic;
			 inta : OUT STD_LOGIC;
			 invalid_instr : OUT STD_LOGIC);
END control_l;


ARCHITECTURE Structure OF control_l IS

	signal operation : std_LOGIC_VECTOR(9 downto 0);
	
BEGIN
	
	operation <= ir(15 downto 12) & ir(8 downto 6) & "000" when ir(15 downto 12) = "0101" or ir(15 downto 12) = "0110" or ir(15 downto 12) = "0111" else
					 ir(15 downto 12) & ir(2 downto 0) & "000" when ir(15 downto 12) = "1010" else
					 ir(15 downto 12) & ir(5 downto 0) when ir(15 downto 12 ) = "1111" else
					 ir(15 downto 12) & ir(5 downto 3) & "000";
				--	 "00" when ir(15 downto 12)="0101" and ir(8)='0' else
			   --  "01" when ir(15 downto 12)="0101" and ir(8)='1' else
			   --  "10"; -- when ir(15 downto 12) es 0011 o 0100 o 1101 o 1110
	low_ir <= ir (5 downto 0);
	
	invalid_instr <= '1' when (ir(15 downto 12) = "1010" and (ir(5 downto 3) /= "000" or ir(2 downto 0) = "010" or ir(2 downto 0) = "101" or ir(2 downto 0) ="110" )) or  -- Jumps
							  (ir(15 downto 12) = "0001" and (ir(5 downto 3)  = "010" or ir(5 downto 3) = "110" or ir(5 downto 3) = "111")) or -- Compare Instructions
							  (ir(15 downto 12) = "1000" and (ir(5 downto 3)  = "011" or ir(5 downto 3) = "110" or ir(5 downto 3) = "111")) or -- Multiplicacion Division
							  (ir(15 downto 12) = "1001") or -- Floats
							   ir(15 downto 12) = "1011" or ir(15 downto 12) = "1100" or -- Load Store Floats
							  (ir(15 downto 12) = "1111" and (ir(5) = '0' or (ir(4 downto 0) /= "00000" and ir(4 downto 0) /= "00001" and ir(4 downto 0) /= "00100" and ir(4 downto 0) /= "01000" and  ir(4 downto 0) /= "01100" and ir(4 downto 0) /= "10000" and ir(4 downto 0) /= "11111"))) else
								'0';

	with ir(15 downto 0) select
			ldpc <= '0' when x"FFFF",
					  '1' when others;
					  
	wr_out <= '1' when ir(15 downto 12) = "0111" and ir(8) = '1' else
				 '0';
	
	rd_in <= '1' when ir(15 downto 12) = "0111" and ir(8) = '0' else
				'0';
	
	addr_io <= ir(7 downto 0);
	
	wrd <= '0' when (ir(15 downto 12)="1111" and ir(4 downto 0) /= "01100" and ir(4 downto 0) /= "01000")or ir(15 downto 12)="0100" or ir(15 downto 12)="1110" or ir(15 downto 12)="0110" or operation(9 downto 5) = "10100" or operation(9 downto 5) = "01111" else
			 '1';
	d_sys <= '1' when ir(15 downto 12)="1111" and ir(5 downto 0) = "110000" else 
				'0';

	a_sys <= '1' when  ir(15 downto 12)="1111" and ( ir(5 downto 0) = "101100" or ir(5 downto 0)= "100100" ) else
				'0';
				
	reti <= '1' when ir(15 downto 0) = x"F024" else '0';
	
	getiid <= '1' when ir(15 downto 12) = x"F" and ir(5 downto 0) = "101000" else '0';
	
	inta <= '1' when ir(15 downto 12) = x"F" and ir(5 downto 0) = "101000" else '0';
	
	enable_int <= '1' when ir(15 downto 12)="1111" and ir(5 downto 0)= "100000" else '0';
	
	disable_int <= '1' when ir(15 downto 12)="1111" and ir(5 downto 0)= "100001" else '0';
	
	
	addr_b <= ir(11 downto 9) when ir(15 downto 12)="0100" or ir(15 downto 12)="0110" or ir(15 downto 12)="0111" or ir(15 downto 12)="1010" or ir(15 downto 12)="1110" or ir(15 downto 12) = "0111" else
				 ir(2 downto 0);
					 
	addr_d <= ir(11 downto 9);
	
	with ir(15 downto 12) select
		addr_a <= ir(11 downto 9) when "0101",
					 ir(8 downto 6) when others;
	
	with ir(15 downto 12) select
		immed <= std_logic_vector(resize(signed(ir(5 downto 0)), immed'length)) when "0010",
					std_logic_vector(resize(signed(ir(5 downto 0)), immed'length)) when "1011",
					std_logic_vector(resize(signed(ir(5 downto 0)), immed'length)) when "1100",
					std_logic_vector(resize(signed(ir(5 downto 0)), immed'length)) when "1101",
					std_logic_vector(resize(signed(ir(5 downto 0)), immed'length)) when "1110",
					std_logic_vector(resize(signed(ir(5 downto 0)), immed'length)) when "0011",
					std_logic_vector(resize(signed(ir(5 downto 0)), immed'length)) when "0100",
					std_logic_vector(resize(signed(ir(7 downto 0)), immed'length)) when others;
					
	
	with ir(15 downto 12) select
		wr_m <= '1' when "0100",
					'1' when "1110",
					'0' when others;
	--wr_m <= '1' when ir(15 downto 12)="0100" or ir(15 downto 12)="1110" else
	--		  '0';
			  
	in_d <= "11" when ir(15 downto 12) = "0111" or (ir(15 downto 12) = x"F" and ir(5 downto 0) = "101000") else 
			  "10" when ir(15 downto 12)= "1010" and ir(2) = '1' else
			  "01" when ir(15 downto 12)= "0011" or ir(15 downto 12)="1101" else 
			  "00";
	
	immed_x2 <= '1' when ir(15 downto 12)="0011" or ir(15 downto 12)="0100" else
					'0';
					
	with ir(15 downto 12) select
		word_byte <= '1' when "1101",
						 '1' when "1110",
						 '0' when others;
	--word_byte <= '1' when ir(15 downto 12)="1101" or ir(15 downto 12)="1110" else
	--				 '0';
	
	op <= operation;
END Structure;