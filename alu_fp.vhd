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

signal salida_la : std_logic_vector(15 downto 0);

--Comparaciones 
signal cmplt_s : std_logic_vector(15 downto 0); 
signal cmple_s : std_logic_vector(15 downto 0); 
signal cmpeq_s : std_logic_vector(15 downto 0); 

signal salida_cmp : std_logic_vector(15 downto 0);

--Extension aritmetica 
signal mul_s : std_logic_vector(15 downto 0); 
signal div_s : std_logic_vector(15 downto 0); 

signal salida_ea : std_logic_vector(15 downto 0);

 
signal salida : std_logic_vector(15 downto 0); 
 
BEGIN 
     
    --Bloque Ops 
    				  
	 
	 --Bloque Comparaciones
	 
    
	 --Bloque extension aritmetica
	 
   
	 --Bloque Movimiento
	 
 
END Structure;
