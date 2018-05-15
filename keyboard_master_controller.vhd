LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY keyboard_master_controller IS
    PORT (clk : IN  STD_LOGIC;
         -- clear_char : IN  STD_LOGIC;
          inta : IN  STD_LOGIC;
			 reset : IN STD_LOGIC;
			-- data_ready : OUT STD_LOGIC;
          ps2_clk : OUT STD_LOGIC;
			 ps2_data : OUT STD_LOGIC;
          intr: OUT STD_LOGIC;
			 read_char : OUT STD_LOGIC_VECTOR(7 downto 0)
			 );
END keyboard_master_controller;


ARCHITECTURE Structure OF keyboard_master_controller IS
		
signal switches_mem : std_logic_vector(7 downto 0);	
	 Component keyboard_controller is
    Port (clk        : in    STD_LOGIC;
          reset      : in    STD_LOGIC;
          ps2_clk    : inout STD_LOGIC;
          ps2_data   : inout STD_LOGIC;
          read_char  : out   STD_LOGIC_VECTOR (7 downto 0);
          clear_char : in    STD_LOGIC;
          data_ready : out   STD_LOGIC);
end component;


BEGIN

teclado : keyboard_controller
	Port map 
		(clk => clk,
       reset => reset,
       ps2_clk => ps2_clk,
       ps2_data => ps2_data,
       read_char => read_char,
       clear_char => inta,
       data_ready => intr);
		 
		 
		 
 divisor_clk_20 : PROCESS(clk,inta)
	begin
		if rising_edge(inta) then
			intr_s <= '0';
		end if;
		if rising_edge(clk) and intr_s = '0' then
			
			if switches /= switches_mem then 
				switches_mem <= switches;
				intr_s <= '1';
		end if;
		
	end process;
	
	intr <= intr_s;
	read_switch <= switches_mem;

END keyboard_master_controller;