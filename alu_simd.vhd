LiBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 
USE ieee.std_logic_unsigned.all; 
 
ENTITY alu_simd IS 
    PORT (a0 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); 
          a1 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          a2 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); 
          a3 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); --Bit 2 ADD/SUB, Bits 1 i 0: 00 Word, 01 2Bytes, 10 4Bytes 
          w0  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          w1  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		  ); 
END alu_simd; 
 
ARCHITECTURE Structure OF alu_simd IS 
 
--Operacions ADD
signal add_word_0 : std_logic_vector(15 DOWNTO 0);
signal add_word_1 : std_logic_vector(15 DOWNTO 0);

signal add_byte_mode0_0 : std_logic_vector(7 downto 0);
signal add_byte_mode0_1 : std_logic_vector(7 downto 0);

signal add_byte_mode1_0 : std_logic_vector(7 downto 0);
signal add_byte_mode1_1 : std_logic_vector(7 downto 0);
signal add_byte_mode1_2 : std_logic_vector(7 downto 0);
signal add_byte_mode1_3 : std_logic_vector(7 downto 0);

signal w0_add : std_logic_vector(15 downto 0);
signal w1_add : std_logic_vector(15 downto 0);

--Operacions SUB
signal sub_word_0 : std_logic_vector(15 DOWNTO 0);
signal sub_word_1 : std_logic_vector(15 DOWNTO 0); 

signal sub_byte_mode0_0 : std_logic_vector(7 downto 0);
signal sub_byte_mode0_1 : std_logic_vector(7 downto 0);

signal sub_byte_mode1_0 : std_logic_vector(7 downto 0);
signal sub_byte_mode1_1 : std_logic_vector(7 downto 0);
signal sub_byte_mode1_2 : std_logic_vector(7 downto 0);
signal sub_byte_mode1_3 : std_logic_vector(7 downto 0);

signal w0_sub : std_logic_vector(15 downto 0);
signal w1_sub : std_logic_vector(15 downto 0);

BEGIN 

--Operacions ADD 00
    add_word_0 <= a0 + a2;
    add_word_1 <= a1 + a3;

--Operacions SUB 00
    sub_word_0 <= a0 - a2;
    sub_word_1 <= a1 - a3;

--Operacions ADD 01
    add_byte_mode0_0 <= a0(7 downto 0) + a1(7 downto 0);
    add_byte_mode0_1 <= a0(15 downto 8) + a1(15 downto 8);

--Operacions SUB 01
    sub_byte_mode0_0 <= a0(7 downto 0) - a1(7 downto 0);
    sub_byte_mode0_1 <= a0(15 downto 8) - a1(15 downto 8);

--Operacions ADD 10
    add_byte_mode1_0 <= a0(7 downto 0) + a2(7 downto 0);
    add_byte_mode1_1 <= a0(15 downto 8) + a2(15 downto 8);
    add_byte_mode1_2 <= a1(7 downto 0) + a3(7 downto 0);
    add_byte_mode1_3 <= a1(15 downto 8) + a3(15 downto 8);

--Operacions SUB 10
    sub_byte_mode1_0 <= a0(7 downto 0) - a2(7 downto 0);
    sub_byte_mode1_1 <= a0(15 downto 8) - a2(15 downto 8);
    sub_byte_mode1_2 <= a1(7 downto 0) - a3(7 downto 0);
    sub_byte_mode1_3 <= a1(15 downto 8) - a3(15 downto 8);

--Escollir sortides
    with op(1 downto 0) select
        w0_add <= add_word_0 when "00",
                  add_byte_mode0_1 & add_byte_mode0_0 when "01",
                  add_byte_mode1_1 & add_byte_mode1_0 when others; -- "10"

    with op(1 downto 0) select
        w1_add <= add_word_1 when "00",
                  add_byte_mode1_3 & add_byte_mode1_2 when others; -- "10"

    with op(1 downto 0) select
        w0_sub <= sub_word_0 when "00",
                  sub_byte_mode0_1 & sub_byte_mode0_0 when "01",
                  sub_byte_mode1_1 & sub_byte_mode1_0 when others; -- "10"

    with op(1 downto 0) select
        w1_sub <= sub_word_1 when "00",
                  sub_byte_mode1_3 & sub_byte_mode1_2 when others; -- "10"

    w0 <= w0_add when op(2) = '0' else
          w0_sub;
    
    w1 <= w1_add when op(2) = '0' else
          w0_sub;

END Structure;
