
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY controladores_IO IS
 PORT(boot : IN STD_LOGIC;
		CLOCK_50 : IN std_logic;
		addr_io : IN std_logic_vector(7 downto 0);
		wr_io : in std_logic_vector(15 downto 0);
		rd_io : out std_logic_vector(15 downto 0);
		wr_out : in std_logic;
		rd_in : in std_logic;
		led_verdes : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		led_rojos : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		ps2_clk  : inout std_logic; 
		ps2_data : inout std_logic;
		display 	: out   STD_LOGIC_VECTOR(15 downto 0);
		SW : in STD_LOGIC_VECTOR(7 downto 0);
		KEY : in STD_LOGIC_VECTOR(3 downto 0);
		getiid : in std_logic;
		inta : in std_logic;
		intr : out std_logic);
END controladores_IO;

ARCHITECTURE Structure OF controladores_IO IS

Component keyboard_controller is
    Port (clk        : in    STD_LOGIC;
          reset      : in    STD_LOGIC;
          ps2_clk    : inout STD_LOGIC;
          ps2_data   : inout STD_LOGIC;
          read_char  : out   STD_LOGIC_VECTOR (7 downto 0);
          clear_char : in    STD_LOGIC;
          data_ready : out   STD_LOGIC);
end component;

COMPONENT timer IS
    PORT (clk    : IN  STD_LOGIC;
          boot    : IN  STD_LOGIC;
          inta      : IN  STD_LOGIC;
          intr: OUT STD_LOGIC
		  );
END COMPONENT;

COMPONENT pulsadores IS
    PORT (clk    : IN  STD_LOGIC;
          boot    : IN  STD_LOGIC;
          inta      : IN  STD_LOGIC;
          keys   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
          intr: OUT STD_LOGIC;
		  read_key : OUT STD_LOGIC_VECTOR(3 downto 0)
		  );
END COMPONENT;

COMPONENT interruptores IS
    PORT (clk    : IN  STD_LOGIC;
          boot    : IN  STD_LOGIC;
          inta      : IN  STD_LOGIC;
          switches   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
          intr: OUT STD_LOGIC;
		  read_switch : OUT STD_LOGIC_VECTOR(7 downto 0)
		  );
END COMPONENT;

COMPONENT interrupt_controller IS
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
end COMPONENT;

type Banco_IO is array (255 downto 0) of std_logic_vector(15 downto 0);-- ENTREGA!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--type Banco_IO is array (25 downto 0) of std_logic_vector(15 downto 0);
signal B_IO : Banco_IO ;
signal contador_ciclos : std_logic_vector(15 downto 0) := x"0000";
signal contador_milisegundos : std_logic_vector(15 downto 0) := x"0000";

signal data_ready_s : std_logic;
signal read_char_s  : std_logic_vector(7 downto 0);
signal to_write : std_logic_vector(15 downto 0);
signal clear_char_s : std_logic;

signal intr_vec : std_logic_vector(3 downto 0) := "0000";
signal inta_vec : std_logic_vector(3 downto 0) := "0000";

signal iid_s : std_logic_vector(7 downto 0);

signal read_key_s : std_logic_vector(3 downto 0);
signal read_switch_s : std_logic_vector(7 downto 0);


BEGIN

	led_verdes <= B_IO(5)(7 downto 0);
	led_rojos  <= B_IO(6)(7 downto 0);
	display <= B_IO(10)(15 downto 0);
	
	to_write <= "00000000" & read_char_s when addr_io = x"F" else
					 "0000000000000000" when addr_io = x"10" else wr_io;
														 

	process(CLOCK_50) begin
		if rising_edge(CLOCK_50) then
			if contador_ciclos=0 then
				contador_ciclos<=x"C350";	--tiempo de ciclo=20ns (50MHz) 1ms=50000ciclos
				if contador_milisegundos > 0 then
					contador_milisegundos <= contador_milisegundos-1;
				--else
				--	contador_milisegundos <= B_IO(21);
				end if;
				
			else
				contador_ciclos <= contador_ciclos-1;
			end if;
			if addr_io = x"15" and wr_out = '1' then
				contador_milisegundos <= to_write;
			end if;
			
			B_IO(7) <= x"000" & read_key_s;
			B_IO(8) <= x"00" & read_switch_s;
			B_IO(15)(7 downto 0)<= read_char_s;
			B_IO(20) <= contador_ciclos;
			if clear_char_s = '1' then 
				clear_char_s <= '0';
			elsif addr_io = x"10" and wr_out = '1' then 
				clear_char_s <= '1';
			elsif wr_out = '1' then
					B_IO(conv_integer(addr_io)) <= to_write;
			end if;
		end if;
	end process;
	
	rd_io <= x"00" & iid_s when getiid = '1' else
			   contador_milisegundos when addr_io = x"15" else
				B_IO(conv_integer(addr_io)) when addr_io /= x"10"  else 
				"000000000000000" & data_ready_s;
	
	
	teclado : keyboard_controller
	Port map 
		(clk => CLOCK_50,
       reset => boot,
       ps2_clk => ps2_clk,
       ps2_data => ps2_data,
       read_char => read_char_s,
       clear_char => inta_vec(3),
       data_ready => intr_vec(3));

	
timer_int : timer
PORT MAP(
	clk => CLOCK_50,
	boot => boot,
	inta => inta_vec(0),
	intr => intr_vec(0)
	);
	
pulsadores_int : pulsadores
PORT MAP(
	clk => CLOCK_50,
	boot => boot,
	inta => inta_vec(1),
	keys => KEY,
	intr => intr_vec(1),
	read_key => read_key_s
	);
 
interruptores_int : interruptores
PORT MAP(
	clk => CLOCK_50,
	boot => boot,
	inta => inta_vec(2),
	switches => SW,
	intr => intr_vec(2),
	read_switch => read_switch_s
	);

control_int : interrupt_controller
PORT MAP(
	clk => CLOCK_50,
	boot => boot,
	inta => inta,
	key_intr => intr_vec(1),
	ps2_intr => intr_vec(3),
	switch_intr => intr_vec(2),
	timer_intr => intr_vec(0),
	intr => intr,
	key_inta => inta_vec(1),
	ps2_inta => inta_vec(3),
	switch_inta => inta_vec(2),
	timer_inta => inta_vec(0),
	iid => iid_s
	);
	
	
END Structure; 
