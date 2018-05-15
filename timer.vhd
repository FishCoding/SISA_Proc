LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY timer IS
    PORT (clk    : IN  STD_LOGIC;
          boot    : IN  STD_LOGIC;
          inta      : IN  STD_LOGIC;
          intr: OUT STD_LOGIC
			 );
END timer;


ARCHITECTURE Structure OF timer IS

SIGNAL counter_s 	: STD_LOGIC_VECTOR(23 DOWNTO 0) := x"000000" ;

BEGIN
 
 divisor_clk_20 : PROCESS(clk,inta)
	begin
		
		if rising_edge(clk) then
			if boot='1' then
				intr <= '0';
				counter_s <= x"000000";
			elsif inta='1' then
				intr <= '0';
			else
				counter_s <= counter_s + 1;
				if counter_s = x"2625A0" then 
			--   if counter_s = x"FFFFFF" then 
					counter_s <= x"000000";
					intr <= '1';
				end if;
			end if;
		end if;
		
	end process;

END Structure;
