LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY pulsadores IS
    PORT (clk    : IN  STD_LOGIC;
          boot    : IN  STD_LOGIC;
          inta      : IN  STD_LOGIC;
          keys   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
          intr: OUT STD_LOGIC;
			 read_key : OUT STD_LOGIC_VECTOR(3 downto 0)
			 );
END pulsadores;


ARCHITECTURE Structure OF pulsadores IS
		signal intr_s : STD_LOGIC := '0';
		signal pulse : std_logic := '0';
		signal keys_mem : std_logic_vector(3 downto 0) := "1111";
BEGIN

	process (clk, boot, keys, inta) begin
		if boot = '1' then
			intr_s <= '0';
			pulse <= '0';
			keys_mem <= "1111";
		elsif rising_edge(clk) then
			if inta = '1' then
				intr_s <= '0';
			elsif keys /= "1111" and pulse = '0' then
				pulse <= '1';
				intr_s <= '1';
				keys_mem <= keys;
			elsif keys = "1111" then
				pulse <= '0';
			end if;
		end if;
	end process;
  
  --divisor_clk_20 : PROCESS(clk,inta,keys)
--	begin
--		
--		if rising_edge(clk) then
--			
--			if inta = '1' then
--				intr_s <= '0';
--			
--			elsif intr_s = '0' and keys /= "0000" and pulse = '0' then 
--				keys_mem <= keys;
--				intr_s <= '1';
--				pulse <= '1';
--			elsif keys = "0000"  then
--				pulse <= '0';
--			
--			end if;
--		end if;
		
--	end process;
	
	intr <= intr_s;
	read_key <= keys_mem;

END Structure;