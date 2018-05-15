LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY interruptores IS
    PORT (clk    : IN  STD_LOGIC;
          boot    : IN  STD_LOGIC;
          inta      : IN  STD_LOGIC;
          switches   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
          intr: OUT STD_LOGIC;
			 read_switch : OUT STD_LOGIC_VECTOR(7 downto 0)
			 );
END interruptores;


ARCHITECTURE Structure OF interruptores IS
		
		signal switches_mem : std_logic_vector(7 downto 0) := "00000000";
		signal intr_s : std_logic := '0';
BEGIN

 divisor_clk_20 : PROCESS(clk,inta, boot)
	begin
		
		if boot = '1' then
			intr_s <= '0';
			switches_mem <= x"00";
		elsif rising_edge(clk) then
			if inta = '1' then
				intr_s <= '0';
			
			elsif intr_s = '0' and switches /= switches_mem then 
				switches_mem <= switches;
				intr_s <= '1';
			end if;
		end if;
		
	end process;
	
	intr <= intr_s;
	read_switch <= switches_mem;

END Structure;