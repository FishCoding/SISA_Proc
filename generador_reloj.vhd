LIBRARY ieee; 
USE ieee.std_logic_1164.all; 
USE IEEE.std_logic_arith.all; 
USE ieee.std_logic_unsigned.all;
ENTITY generador_reloj IS  
  PORT( clk50   :  IN  STD_LOGIC; 
		  clk1 :  OUT std_LOGIC); 
END generador_reloj; 

ARCHITECTURE Structure OF generador_reloj IS 
	signal contador : std_LOGIC_VECTOR(2 downto 0) := "100";
	signal dep : std_LOGIC := '1';
BEGIN
	process(clk50) begin
		if rising_edge(clk50) then 
			contador <= contador - 1;
			if contador = "0" then 
				contador <= "100";
				dep <= not(dep);
			end if;
		end if;		
	end process;
	
	clk1 <= dep;
	
END Structure;