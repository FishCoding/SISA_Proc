LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY sisa IS
    PORT (CLOCK_50  : IN    STD_LOGIC;
          SRAM_ADDR : out   std_logic_vector(17 downto 0);
          SRAM_DQ   : inout std_logic_vector(15 downto 0);
          SRAM_UB_N : out   std_logic;
          SRAM_LB_N : out   std_logic;
          SRAM_CE_N : out   std_logic := '1';
          SRAM_OE_N : out   std_logic := '1';
          SRAM_WE_N : out   std_logic := '1';
			 LEDG		  : out 	 std_logic_vector(7 downto 0);
			 LEDR		  : out 	 std_logic_vector(9 downto 0);
          SW        : in std_logic_vector(9 downto 0);
			 HEX0 	  : out std_logic_vector(6 downto 0);
			 HEX1 	  : out std_logic_vector(6 downto 0);
			 HEX2 	  : out std_logic_vector(6 downto 0);
			 HEX3 	  : out std_logic_vector(6 downto 0);
			 KEY		  : in std_logic_vector(3 downto 0);
			 PS2_CLK   : inout std_logic;
			 PS2_DAT   : inout std_logic;
			 VGA_R        : out std_logic_vector(3 downto 0); -- vga red pixel value
          VGA_G      : out std_logic_vector(3 downto 0); -- vga green pixel value
          VGA_B       : out std_logic_vector(3 downto 0); -- vga blue pixel value
          VGA_HS : out std_logic; -- vga control signal
          VGA_VS  : out std_logic);
END sisa;

ARCHITECTURE Structure OF sisa IS

signal clk_sig : std_logic ;
signal datard_signal : std_logic_vector( 15 downto 0);
signal addr_m_s : std_logic_vector(15 downto 0);
signal word_byte_s : std_logic; 
signal data_wr_s : std_logic_vector(15 downto 0);
signal wr_m_s : std_logic;
signal rd_io_s : std_logic_vector(15 downto 0);
signal wr_io_s : std_logic_vector(15 downto 0);
signal addr_io_s : std_logic_vector(7 downto 0);
signal rd_in_s : std_logic;
signal wr_out_s : std_logic;

signal display_s : std_logic_vector(15 downto 0);

signal vga_addr_s : std_logic_vector(12 downto 0);
signal vga_rd_data_s : std_logic_vector(15 downto 0);
signal vga_wr_data_s : std_logic_vector(15 downto 0);
signal vga_byte_m_s : std_logic; 
signal vga_we_s : std_logic;

signal aux_VGA_R : std_logic_vector(7 downto 0);
signal aux_VGA_G : std_logic_vector(7 downto 0);
signal aux_VGA_B : std_logic_vector(7 downto 0);


SIGNAL counter_div_clk 	: STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
SIGNAL clk_3125 			: STD_LOGIC := '0';

signal inta_s : std_logic; 
signal intr_s : std_logic;


component MemoryController is
    port (CLOCK_50  : in  std_logic;
	       addr      : in  std_logic_vector(15 downto 0);
          wr_data   : in  std_logic_vector(15 downto 0);
          rd_data   : out std_logic_vector(15 downto 0);
          we        : in  std_logic;
          byte_m    : in  std_logic;
          -- senales para la placa de desarrollo
          SRAM_ADDR : out   std_logic_vector(17 downto 0);
          SRAM_DQ   : inout std_logic_vector(15 downto 0);
          SRAM_UB_N : out   std_logic;
          SRAM_LB_N : out   std_logic;
          SRAM_CE_N : out   std_logic := '1';
          SRAM_OE_N : out   std_logic := '1';
          SRAM_WE_N : out   std_logic := '1';
			 --------
			 vga_addr : out std_logic_vector(12 downto 0);
			 vga_we : out std_logic;
          vga_wr_data : out std_logic_vector(15 downto 0);
          vga_rd_data : in std_logic_vector(15 downto 0);
          vga_byte_m : out std_logic);
end component;

component proc IS
    PORT (boot     : IN  STD_LOGIC;
          clk      : IN  STD_LOGIC;
          datard_m : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_m   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 wr_m : OUT STD_LOGIC;
			 word_byte : OUT STD_LOGIC;
			 data_wr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 rd_io : IN STD_LOGIC_VECTOR(15 downto 0);
			 wr_io : OUT STD_LOGIC_VECTOR(15 downto 0);
			 addr_io : OUT STD_LOGIC_VECTOR(7 downto 0);
			 rd_in : OUT STD_LOGIC;
			 wr_out : OUT STD_LOGIC;
			 getiid : OUT std_logic;
			 inta : out std_logic;
			 intr : in std_logic);
END component;

component controladores_IO IS
	 PORT (boot : IN STD_LOGIC;
			CLOCK_50 : IN std_logic;
			addr_io : IN std_logic_vector(7 downto 0);
			wr_io : in std_logic_vector(15 downto 0);
			rd_io : out std_logic_vector(15 downto 0);
			wr_out : in std_logic;
			rd_in : in std_logic;
			led_verdes : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			led_rojos : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			ps2_clk  : inout std_logic; 
			ps2_data : inout std_logic;
			display 	: out   STD_LOGIC_VECTOR(15 downto 0);
			SW : in STD_LOGIC_VECTOR(7 downto 0);
			KEY : in STD_LOGIC_VECTOR(3 downto 0);
			getiid : in std_logic;
			inta : in std_logic;
		   intr : out std_logic);
END component;

component driver7segmentos IS  
  PORT( codigoCaracter   :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0); 
		  bitsCaracter :  OUT STD_LOGIC_VECTOR(6 DOWNTO 0)); 
END component; 

--component generador_reloj IS  
--  PORT( clk50   :  IN  STD_LOGIC; 
--		  clk1 :  OUT std_LOGIC); 
--END component;


	component vga_controller is
    port(clk_50mhz      : in  std_logic; -- system clock signal
         reset          : in  std_logic; -- system reset
         blank_out      : out std_logic; -- vga control signal
         csync_out      : out std_logic; -- vga control signal
         red_out        : out std_logic_vector(7 downto 0); -- vga red pixel value
         green_out      : out std_logic_vector(7 downto 0); -- vga green pixel value
         blue_out       : out std_logic_vector(7 downto 0); -- vga blue pixel value
         horiz_sync_out : out std_logic; -- vga control signal
         vert_sync_out  : out std_logic; -- vga control signal
         --
         addr_vga          : in std_logic_vector(12 downto 0);
         we                : in std_logic;
         wr_data           : in std_logic_vector(15 downto 0);
         rd_data           : out std_logic_vector(15 downto 0);
         byte_m            : in std_logic;
         vga_cursor        : in std_logic_vector(15 downto 0);  -- simplemente lo ignoramos, este controlador no lo tiene implementado
         vga_cursor_enable : in std_logic);                     -- simplemente lo ignoramos, este controlador no lo tiene implementado
end component;

signal boot_s : std_logic;
signal getiid_s : std_logic;

BEGIN
--gen_reloj : generador_reloj
--port map( clk50 => CLOCK_50,
--				clk1 => clk_sig);

divisor_clk_3125 : PROCESS(CLOCK_50)
	begin
		if rising_edge(CLOCK_50) then
			counter_div_clk <= counter_div_clk + 1;
		end if;
	end process;
	clk_3125 <= counter_div_clk(2); -- toma el bit 1 del contador o sea la frecuencia dividida por 4


proc0: proc
port map(boot => boot_s,
			clk => clk_3125,
			datard_m => datard_signal,
			addr_m => addr_m_s,
			wr_m => wr_m_s,
			word_byte => word_byte_s,
			data_wr => data_wr_s,
			rd_io => rd_io_s,
			wr_io => wr_io_s,
			addr_io => addr_io_s,
			rd_in => rd_in_s,
			wr_out => wr_out_s,
			getiid => getiid_s,
			inta => inta_s,
			intr => intr_s);
			
MemController : MemoryController
port map(CLOCK_50 => CLOCK_50,
			byte_m => word_byte_s,
			we => wr_m_s,
			addr => addr_m_s,
			wr_data => data_wr_s,
			SRAM_CE_N => SRAM_CE_N,
			SRAM_LB_N => SRAM_LB_N,
			SRAM_OE_N => SRAM_OE_N,
			SRAM_UB_N => SRAM_UB_N,
			SRAM_WE_N => SRAM_WE_N,
			SRAM_ADDR => SRAM_ADDR,
			SRAM_DQ => SRAM_DQ,
			rd_data => datard_signal,
			vga_addr => vga_addr_s,
			vga_we =>  vga_we_s,
         vga_wr_data => vga_wr_data_s,
         vga_rd_data => vga_rd_data_s,
         vga_byte_m => vga_byte_m_s );

IOController: Controladores_IO
port map (boot => boot_s,
	CLOCK_50 => CLOCK_50,
	addr_io => addr_io_s,
	wr_io => wr_io_s,
	rd_io => rd_io_s,
	wr_out => wr_out_s,
	rd_in => rd_in_s,
	led_verdes => LEDG,
	led_rojos => LEDR,
	ps2_clk => PS2_CLK,
	ps2_data => PS2_DAT,
	display => display_s,
	SW => SW(7 downto 0),
	KEY => KEY,
	getiid => getiid_s,
	intr => intr_s,
	inta => inta_s);
	
	
	VGACONT: vga_controller
		port map(clk_50mhz => CLOCK_50,    
               reset => boot_s,
				-- blank_out => No se usan en la DE1
				-- csync_out => 
					red_out =>  aux_VGA_R,      
					green_out => aux_VGA_G,
					blue_out =>   aux_VGA_B, 
					horiz_sync_out =>VGA_HS,
					vert_sync_out => VGA_VS,
					--
					addr_vga => vga_addr_s,          
					we => vga_we_s,            
					wr_data => vga_wr_data_s,           
					rd_data  => vga_rd_data_s,   
					byte_m  => vga_byte_m_s,
					vga_cursor => x"0000",
					vga_cursor_enable => '0');            
        
VGA_R <= aux_VGA_R(3 downto 0);
VGA_G <= aux_VGA_G(3 downto 0);
VGA_B <= aux_VGA_B(3 downto 0);
		  
		  
 driver7_1 : driver7segmentos 
PORT map ( codigoCaracter  => display_s(3 downto 0),  
		  bitsCaracter => HEX0 ); 

driver7_2 : driver7segmentos 
PORT map ( codigoCaracter  => display_s(7 downto 4),   
		  bitsCaracter => HEX1 ); 
		  
driver7_3 : driver7segmentos 
PORT map ( codigoCaracter  => display_s(11 downto 8),  
		  bitsCaracter => HEX2 ); 
		  
driver7_4 : driver7segmentos 
PORT map ( codigoCaracter  => display_s(15 downto 12),   
		  bitsCaracter => HEX3 ); 

boot_s <= SW(9);
END Structure;