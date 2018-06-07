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
		  overflow : OUT STD_LOGIC
		  ); 
END alu_fp; 
 
ARCHITECTURE Structure OF alu_fp IS 
 
--Operaciones logicas y aritmeticas 
signal add_s : std_logic_vector(15 DOWNTO 0); 
signal sub_s : std_logic_vector(15 downto 0); 

--Comparaciones 
signal cmplt_s : std_logic_vector(15 downto 0); 
signal cmple_s : std_logic_vector(15 downto 0); 
signal cmpeq_s : std_logic_vector(15 downto 0); 


--Extension aritmetica 
signal mul_s : std_logic_vector(15 downto 0); 
signal div_s : std_logic_vector(15 downto 0); 

 
signal salida : std_logic_vector(15 downto 0); 
 
BEGIN 
     
   
	 
	 
	 --Decidir la salida
	 with op(2 downto 0) select
		salida <= add_s   when "000",
				  sub_s   when "001",
				  mul_s   when "010",
				  div_s   when "011",
				  cmplt_s when "100",
				  cmple_s when "101",
				  cmpeq_s when others; --when "111";
				  
	invalid_division <= '1' when op(6 downto 0) = "1001011" 
								 and (y = "0000000000000000" or y = "1000000000000000") else
						'0';
					 
	 
END Structure;
