LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY interrupt_controller IS
    PORT (clk  : IN  STD_LOGIC;
          boot : IN  STD_LOGIC;
          inta : IN  STD_LOGIC;
          key_intr : IN  STD_LOGIC;
          ps2_intr : IN  STD_LOGIC;
          switch_intr : IN  STD_LOGIC;
          timer_intr : IN  STD_LOGIC;
          intr : OUT STD_LOGIC;
          key_inta : OUT STD_LOGIC;
          ps2_inta : OUT STD_LOGIC;
          switch_inta : OUT STD_LOGIC;
          timer_inta : OUT STD_LOGIC;
          iid : OUT STD_LOGIC_VECTOR(7 downto 0)
          );
END interrupt_controller;


ARCHITECTURE Structure OF interrupt_controller IS

BEGIN

	interupt : process(inta, clk, boot) begin
		if boot = '1' then
			timer_inta <= '0';
			key_inta <= '0';
			switch_inta <= '0';
			ps2_inta <= '0';
			iid <= x"DE";
		elsif rising_edge(clk) then
			if inta='1' then
			
				if timer_intr = '1' then
					timer_inta <= '1';
					key_inta <= '0';
					switch_inta <= '0';
					ps2_inta <= '0';
					
				elsif key_intr = '1' then
					timer_inta<= '0';
					key_inta<= '1';
					switch_inta<= '0';
					ps2_inta<= '0';
					
				elsif switch_intr = '1' then
					timer_inta<= '0';
					key_inta<= '0';
					switch_inta<= '1';
					ps2_inta<= '0';
					
				elsif ps2_intr = '1' then 
					timer_inta<= '0';
					key_inta<= '0';
					switch_inta<= '0';
					ps2_inta<= '1';
				end if;
			
			elsif timer_intr ='1' then
					iid <= x"00";
			elsif key_intr ='1' then
					iid <= x"01";
			elsif switch_intr ='1' then
					iid <= x"02";
			elsif ps2_intr ='1' then
					iid <= x"03";	
			elsif inta = '0' then
				timer_inta<= '0';
				key_inta<= '0';
				switch_inta<= '0';
				ps2_inta<= '0';
			end if;
		end if;
	end process;
	
	intr <= ps2_intr or switch_intr or key_intr or timer_intr;
	
	
	
END Structure;
