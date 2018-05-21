LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY system_regfile IS
    PORT (clk    : IN  STD_LOGIC;
         wrd    : IN  STD_LOGIC;
         d      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
         addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
         addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
         a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 sys 	  : IN STD_LOGIC;
		 pc 	  : IN STD_LOGIC_VECTOR(15 downto 0);
		 enable_int : IN STD_LOGIC;
		 disable_int : IN STD_LOGIC;
		 reti : IN STD_LOGIC;
		 boot : IN STD_LOGIC;
		 state_word : OUT STD_LOGIC_VECTOR(15 downto 0);
		 id_excep : IN STD_LOGIC_VECTOR(3 downto 0);
		 value_data : IN STD_LOGIC_VECTOR(15 downto 0));
END system_regfile;


ARCHITECTURE Structure OF system_regfile IS
	type Banco_Registros is array (7 downto 0) of std_logic_vector(15 downto 0);
	
	signal BR : Banco_Registros ;
	
BEGIN

   a <= BR(5) when sys='1' else 
		  BR(1) when reti='1' else  
		  BR(conv_integer(addr_a));
	
	state_word <= BR(7);
	
	process(clk,boot) begin
		if rising_edge(clk) then	
			if boot='1' then
				BR(7) <= x"0001";
			elsif sys='1' then --
				BR(0) <= BR(7);
				BR(1) <= pc ;-- ??????????????????
				BR(2) <= x"000" & id_excep;
				BR(7)(1) <= '0';
				BR(7)(0) <= '1';
				if id_excep = x"E" then 
					BR(3) <= d;
				elsif id_excep = x"1" then
					BR(3) <= value_data;
				elsif id_excep = x"6" or id_excep = x"7" then
					BR(3) <= value_data;
				end if;
			elsif enable_int = '1' then
				BR(7)(1) <= '1';
			elsif disable_int = '1' then
				BR(7)(1) <= '0';
			elsif reti = '1' then
				BR(7) <= BR(0);
			elsif wrd='1' then
				BR(conv_integer(addr_d)) <= d;
			end if;
		
		end if;
	end process;
	

END Structure;