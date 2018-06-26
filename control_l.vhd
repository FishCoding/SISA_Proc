LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY control_l IS
	PORT 
	(
		ir            : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		state_word 	  : IN STD_LOGIC_VECTOR(15 downto 0);
		op            : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		ldpc          : OUT STD_LOGIC;
		wrd_gp_int    : OUT STD_LOGIC; --permis escriptura BRint
		wrd_gp_fp     : OUT STD_LOGIC; --permis escriptura BRfp
 
		addr_a        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		addr_b        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		addr_d        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		immed         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		wr_m          : OUT STD_LOGIC; --permis escriptura memoria
		in_d          : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); --indica quina es la dada a escriure en BR (PC, ALU o MEM, IN respectivament)
		immed_x2      : OUT STD_LOGIC;
		word_byte     : OUT STD_LOGIC;
		addr_io       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		rd_in         : OUT STD_LOGIC;
		wr_out        : OUT STD_LOGIC;
		low_ir        : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		
		--SIMD
		wrd_simd		  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); --permis escriptura simdBR
 
		d_sys         : OUT STD_LOGIC; --permis escriptura sysBR
		sel_br        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); --indica d'on agafar el valor a: 00 -> BRint, 01-> BRsys, 10-> BRfp, 11->BRsimd
		b_br			  : OUT STD_LOGIC; --indica d'on agafar el valor b: 0 -> BRint, 1 ->BRfp
		sel_alu_w	  : OUT STD_LOGIC; --indica si hem de seleccionar la w de la ALU INT o FP
		sel_mem_dat	  : OUT STD_LOGIC; --inidica de que BR se escoge el dato a escribir en memoria
		enable_int    : OUT STD_LOGIC;
		disable_int   : OUT STD_LOGIC;
		reti          : OUT STD_LOGIC;
		getiid        : OUT std_logic;
		inta          : OUT STD_LOGIC;
		invalid_instr : OUT STD_LOGIC;
		calls         : OUT STD_LOGIC;
		instr_protected : OUT STD_LOGIC;
		flush          : OUT STD_LOGIC;
		wr_tlb_pi      : OUT STD_LOGIC;
		wr_tlb_pd      : OUT STD_LOGIC;
		wr_tlb_vi      : OUT STD_LOGIC;
		wr_tlb_vd      : OUT STD_LOGIC
	);
END control_l;
ARCHITECTURE Structure OF control_l IS

	CONSTANT OP_COMP_FLOAT 	: STD_LOGIC_VECTOR (3 DOWNTO 0) := "1001";
	CONSTANT LD_FLOAT 		: STD_LOGIC_VECTOR (3 DOWNTO 0) := "1011";
	CONSTANT ST_FLOAT 		: STD_LOGIC_VECTOR (3 DOWNTO 0) := "1100";
	
	SIGNAL operation : std_LOGIC_VECTOR(9 DOWNTO 0);
 
BEGIN
	operation <= ir(15 DOWNTO 12) & ir(8 DOWNTO 6) & "000" WHEN ir(15 DOWNTO 12) = "0101" OR ir(15 DOWNTO 12) = "0110" OR ir(15 DOWNTO 12) = "0111" ELSE
	             ir(15 DOWNTO 12) & ir(2 DOWNTO 0) & "000" WHEN ir(15 DOWNTO 12) = "1010" ELSE
	             ir(15 DOWNTO 12) & ir(5 DOWNTO 0) WHEN (ir(15 DOWNTO 12) = "1111" and ir(5) = '1') OR (ir(15 DOWNTO 12) = "1010" and ir(5) = '1') ELSE --ADD/SUB simd
					 ir(15 DOWNTO 12) & ir(11 DOWNTO 9) & "000" WHEN ir(15 DOWNTO 12) = "1111" and ir(5) = '0' ELSE --simd_LD i simd_ST
	             ir(15 DOWNTO 12) & ir(5 DOWNTO 3) & "000";
	-- "00" when ir(15 downto 12)="0101" and ir(8)='0' else
	-- "01" when ir(15 downto 12)="0101" and ir(8)='1' else
	-- "10"; -- when ir(15 downto 12) es 0011 o 0100 o 1101 o 1110
	low_ir        <= ir (5 DOWNTO 0);
	
	--SIMD
	wrd_simd <= "0001" WHEN (ir(15 DOWNTO 9) = "1111000" AND ir(5) = '0') OR (ir(15 DOWNTO 5) = "10100000001" AND ir(1 DOWNTO 0) = "01") ELSE --simd_LD(rd0)/ SUB/ADD 2 Bytes
					"0010" WHEN  ir(15 DOWNTO 9) = "1111001" AND ir(5) = '0' ELSE --simd_LD(rd1)
					"0100" WHEN  ir(15 DOWNTO 9) = "1111010" AND ir(5) = '0' ELSE --simd_LD(rd2)
					"1000" WHEN  ir(15 DOWNTO 9) = "1111011" AND ir(5) = '0' ELSE --simd_LD(rd3)
					"0011" WHEN  ir(15 DOWNTO 5) = "10100000001" AND (ir(1 DOWNTO 0) = "00" OR ir(1 DOWNTO 0) = "10") ELSE
					"0000"; 
 
	invalid_instr <= '1' WHEN (ir(15 DOWNTO 12) = "1010" AND (ir(5 DOWNTO 3) /= "000" OR ir(2 DOWNTO 0) = "010" OR ir(2 DOWNTO 0) = "101" OR ir(2 DOWNTO 0) = "110") AND ir(5) = '0') OR -- Jumps and ADD/SUB simd
	                 (ir(15 DOWNTO 12) = "0001" AND (ir(5 DOWNTO 3) = "010" OR ir(5 DOWNTO 3) = "110" OR ir(5 DOWNTO 3) = "111")) OR -- Compare Instructions
	                 (ir(15 DOWNTO 12) = "1000" AND (ir(5 DOWNTO 3) = "011" OR ir(5 DOWNTO 3) = "110" OR ir(5 DOWNTO 3) = "111")) OR -- Multiplicacion Division
--	                 (ir(15 DOWNTO 12) = "1001") OR -- Floats
--	                 ir(15 DOWNTO 12) = "1011" OR ir(15 DOWNTO 12) = "1100" OR -- Load Store Floats
					      (ir(15 DOWNTO 12) = "1111" AND ((ir(4 DOWNTO 0) /= "00000" AND ir(4 DOWNTO 0) /= "00001" -- ir(5) -> simd_LD i simd_ST
							 AND ir(4 DOWNTO 0) /= "00100" AND ir(4 DOWNTO 0) /= "01000" AND ir(4 DOWNTO 0) /= "01100" 
							 AND ir(4 DOWNTO 0) /= "10000"  AND ir(4 DOWNTO 0) /= "10100" AND ir(4 DOWNTO 0) /= "10101" 
							 AND ir(4 DOWNTO 0) /= "10110" AND ir(4 DOWNTO 0) /= "10111" AND ir(4 DOWNTO 0) /= "11000"
							 AND ir(4 DOWNTO 0) /= "11111"))) ELSE
	                 '0';

	
	instr_protected <= '1' when (ir(15 DOWNTO 12) = "1111" AND ((ir(4 DOWNTO 0) = "00000" OR ir(4 DOWNTO 0) = "00001" 
									OR ir(4 DOWNTO 0) = "00100" OR ir(4 DOWNTO 0) = "01000" OR ir(4 DOWNTO 0) = "01100" 
									OR ir(4 DOWNTO 0) = "10000" OR ir(4 DOWNTO 0) = "10100" OR ir(4 DOWNTO 0) = "10101" 
									OR ir(4 DOWNTO 0) = "10110" OR ir(4 DOWNTO 0) = "10111" OR ir(4 DOWNTO 0) = "11000"))) 
									and state_word(0) = '0'  else 
					   '0'; --Añadir IN, OUT y HALT (?)


	flush <= '1' when ir(15 downto 12) = "1111" and ir(5 downto 0) = "111000" and state_word(0) = '1' else '0';
	wr_tlb_pi    <= '1' when ir(15 downto 12) = "1111" and ir(5 downto 0) = "110100" and state_word(0) = '1' else '0';
	wr_tlb_pd    <= '1' when ir(15 downto 12) = "1111" and ir(5 downto 0) = "110110" and state_word(0) = '1' else '0';
	wr_tlb_vi    <= '1' when ir(15 downto 12) = "1111" and ir(5 downto 0) = "110101" and state_word(0) = '1' else '0';
	wr_tlb_vd    <= '1' when ir(15 downto 12) = "1111" and ir(5 downto 0) = "110111" and state_word(0) = '1' else '0';

	WITH ir(15 DOWNTO 0) SELECT
	ldpc <= '0' WHEN x"FFFF", 
	        '1' WHEN OTHERS;
 
	wr_out <= '1' WHEN ir(15 DOWNTO 12) = "0111" AND ir(8) = '1' ELSE
	          '0';
 
	rd_in <= '1' WHEN ir(15 DOWNTO 12) = "0111" AND ir(8) = '0' ELSE
	         '0';

	calls   <= '1' WHEN ir(15 DOWNTO 12) = "1010" AND ir(2 DOWNTO 0) = "111" ELSE '0';
 
	addr_io <= ir(7 DOWNTO 0);
 
	wrd_gp_int <= '0' WHEN (ir(15 DOWNTO 12) = "1111" AND ir(4 DOWNTO 0) /= "01100" AND ir(4 DOWNTO 0) /= "01000") OR ir(15 DOWNTO 12) = "0100" 
						OR ir(15 DOWNTO 12) = "1110" OR ir(15 DOWNTO 12) = "0110" OR operation(9 DOWNTO 5) = "10100" OR operation(9 DOWNTO 5) = "01111"  
						OR (ir(15 DOWNTO 12) = "1001" AND ir(5 DOWNTO 3) = "000") OR (ir(15 DOWNTO 12) = "1001" AND ir(5 DOWNTO 3) = "001")
					   OR (ir(15 DOWNTO 12) = "1001" AND ir(5 DOWNTO 3) = "010") OR (ir(15 DOWNTO 12) = "1001" AND ir(5 DOWNTO 3) = "011")	
						OR ir(15 DOWNTO 12) = "1011" OR ir(15 DOWNTO 12) = "1100" 
						OR (ir(15 DOWNTO 12) = "1111" AND ir(5) = '0') --simd_LD i simd_ST 
						OR (ir(15 DOWNTO 12) = "1010" AND ir(5) = '1') ELSE --ADD/SUB simd
					  '1';
				
	wrd_gp_fp <= '1' WHEN (ir(15 DOWNTO 12) = OP_COMP_FLOAT AND ir(5 DOWNTO 3) = "000") OR --ADDF
								 (ir(15 DOWNTO 12) = OP_COMP_FLOAT AND ir(5 DOWNTO 3) = "001") OR --SUBF
								 (ir(15 DOWNTO 12) = OP_COMP_FLOAT AND ir(5 DOWNTO 3) = "010") OR --MULF
								 (ir(15 DOWNTO 12) = OP_COMP_FLOAT AND ir(5 DOWNTO 3) = "011") OR --DIVF
								  ir(15 DOWNTO 12) = LD_FLOAT ELSE --LDF
					 '0';
	
	d_sys <= '1' WHEN ir(15 DOWNTO 12) = "1111" AND ir(5 DOWNTO 0) = "110000" ELSE
	         '0';
	
	sel_br <= "11" WHEN ir(15 DOWNTO 12) = "1111" AND ir(5) = '0' ELSE --simd_LD i simd_ST --BRsimd
				 "10" WHEN ir(15 DOWNTO 12) = OP_COMP_FLOAT ELSE --OR ir(15 DOWNTO 12) = ST_FLOAT ELSE --BRfp
				 "01" WHEN ir(15 DOWNTO 12) = "1111" AND (ir(5 DOWNTO 0) = "101100" OR ir(5 DOWNTO 0) = "100100") ELSE --BRsys
				 "00"; --BRint
				 
	b_br <= '1' WHEN ir(15 DOWNTO 12) = OP_COMP_FLOAT OR ir(15 DOWNTO 12) = ST_FLOAT ELSE --OP/CMP FP or STF
			  '0';
 
	reti        <= '1' WHEN ir(15 DOWNTO 0) = x"F024" ELSE '0';
 
	getiid      <= '1' WHEN ir(15 DOWNTO 12) = x"F" AND ir(5 DOWNTO 0) = "101000" ELSE '0';
 
	inta        <= '1' WHEN ir(15 DOWNTO 12) = x"F" AND ir(5 DOWNTO 0) = "101000" ELSE '0';
 
	enable_int  <= '1' WHEN ir(15 DOWNTO 12) = "1111" AND ir(5 DOWNTO 0) = "100000" ELSE '0';
 
	disable_int <= '1' WHEN ir(15 DOWNTO 12) = "1111" AND ir(5 DOWNTO 0) = "100001" ELSE '0';
 
 
	addr_b <= ir(11 DOWNTO 9) WHEN ir(15 DOWNTO 12) = "0100" OR ir(15 DOWNTO 12) = "0110" OR ir(15 DOWNTO 12) = "0111" 
						OR ir(15 DOWNTO 12) = "1010" OR ir(15 DOWNTO 12) = "1110"
						OR ir(15 DOWNTO 12) = "1111" OR ir(15 DOWNTO 12) = ST_FLOAT ELSE
				 std_logic_vector(resize(signed(ir(10 DOWNTO 9)), addr_b'length)) WHEN ir(15 DOWNTO 12) = "1111" AND ir(5) = '0' ELSE --simd_LD i simd_ST
				 ir(2 DOWNTO 0);
 
	addr_d <= std_logic_vector(resize(signed(ir(10 DOWNTO 9)), addr_b'length)) WHEN ir(15 DOWNTO 12) = "1111" AND ir(5) = '0' ELSE --simd_LD i simd_ST
				 ir(11 DOWNTO 9);
 
	WITH ir(15 DOWNTO 12) SELECT
	addr_a <= ir(11 DOWNTO 9) WHEN "0101", 
	          ir(8 DOWNTO 6) WHEN OTHERS;
 
	WITH ir(15 DOWNTO 12) SELECT
	immed <= std_logic_vector(resize(signed(ir(5 DOWNTO 0)), immed'length)) WHEN "0010", 
	         std_logic_vector(resize(signed(ir(5 DOWNTO 0)), immed'length)) WHEN "1101", 
	         std_logic_vector(resize(signed(ir(5 DOWNTO 0)), immed'length)) WHEN "1110", 
	         std_logic_vector(resize(signed(ir(5 DOWNTO 0)), immed'length)) WHEN "0011", 
	         std_logic_vector(resize(signed(ir(5 DOWNTO 0)), immed'length)) WHEN "0100",
			   std_logic_vector(resize(signed(ir(5 DOWNTO 0)), immed'length)) WHEN "1011", --LDF
			   std_logic_vector(resize(signed(ir(5 DOWNTO 0)), immed'length)) WHEN "1100", --STF
				std_logic_vector(resize(signed(ir(4 DOWNTO 0)), immed'length)) WHEN "1111", --pel simd_LD i simd_ST
	         std_logic_vector(resize(signed(ir(7 DOWNTO 0)), immed'length)) WHEN OTHERS;
 
 
--	WITH ir(15 DOWNTO 12) SELECT
--	wr_m <= '1' WHEN "0100", --ST
--	        '1' WHEN "1110", --STB
--			  '1' WHEN "1100", --STF
--			  '1' WHEN 
--	        '0' WHEN OTHERS;

   wr_m <= '1' WHEN ir(15 DOWNTO 12) = "0100" OR ir(15 DOWNTO 12) = "1110" OR ir(15 DOWNTO 12) = "1110" OR --ST/STB/STF
						  (ir(15 DOWNTO 11) = "11111" AND ir(5) = '0')  ELSE --simd_ST
			  '0';
 
	in_d <= "11" WHEN ir(15 DOWNTO 12) = "0111" OR (ir(15 DOWNTO 12) = "1111" AND ir(5 DOWNTO 0) = "101000") ELSE --IN or GETTID
	        "10" WHEN ir(15 DOWNTO 12) = "1010" AND ir(2 downto 0) = "100" 		ELSE --PC
	        "01" WHEN ir(15 DOWNTO 12) = "0011" OR ir(15 DOWNTO 12) = "1101" OR ir(15 downto 12) = LD_FLOAT OR (ir(15 downto 11) = "11110" AND ir(5) = '0') ELSE --MEM
	        "00"; --ALU
 
	immed_x2 <= '1' WHEN ir(15 DOWNTO 12) = "0011" OR ir(15 DOWNTO 12) = "0100" OR ir(15 DOWNTO 12) = "1011" OR ir(15 DOWNTO 12) = "1100" ELSE
	            '0';
 
	WITH ir(15 DOWNTO 12) SELECT
	word_byte <= '1' WHEN "1101", --LDB
	             '1' WHEN "1110", --STB
	             '0' WHEN OTHERS;
 
	op <= operation;
	
	sel_alu_w <= '1' WHEN ir(15 DOWNTO 12) = OP_COMP_FLOAT ELSE
					 '0'; -- Solo cuando utilizas la ALU FP 
	
	sel_mem_dat <= '1' WHEN ir(15 DOWNTO 12) = ST_FLOAT ELSE
						'0';
	
END Structure;