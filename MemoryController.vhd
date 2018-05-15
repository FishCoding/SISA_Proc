library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity MemoryController is
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
			 vga_addr : out std_logic_vector(12 downto 0);
			 vga_we : out std_logic;
          vga_wr_data : out std_logic_vector(15 downto 0);
          vga_rd_data : in std_logic_vector(15 downto 0);
          vga_byte_m : out std_logic );
end MemoryController;

architecture comportament of MemoryController is
signal WR_SIGNAL : std_logic;
signal vga_addr_s : std_logic_vector(15 downto 0);
signal vga_we_s : std_logic;
signal dataReaded_s : std_logic_vector(15 downto 0);
	component SRAMController is
   port (clk         : in    std_logic;
          -- senales para la placa de desarrollo
          SRAM_ADDR   : out   std_logic_vector(17 downto 0);
          SRAM_DQ     : inout std_logic_vector(15 downto 0); -- Dades
          SRAM_UB_N   : out   std_logic; -- Upper Byte Control
          SRAM_LB_N   : out   std_logic; -- Lower Byte Control
          SRAM_CE_N   : out   std_logic := '1'; -- Chip Enable
          SRAM_OE_N   : out   std_logic := '1'; -- Output Enable
          SRAM_WE_N   : out   std_logic := '1'; -- Write Enable
          -- senales internas del procesador
          address     : in    std_logic_vector(15 downto 0) := "0000000000000000";
          dataReaded  : out   std_logic_vector(15 downto 0);
          dataToWrite : in    std_logic_vector(15 downto 0);
          WR          : in    std_logic; -- Write
          byte_m      : in    std_logic := '0');		 
	end component;
	


begin
	SRAM : SRAMController
	port map(SRAM_ADDR => SRAM_ADDR,
				 SRAM_DQ => SRAM_DQ,
				 SRAM_UB_N => SRAM_UB_N,
				 SRAM_LB_N => SRAM_LB_N,
				 SRAM_CE_N => SRAM_CE_N,
				 SRAM_OE_N => SRAM_OE_N,
				 SRAM_WE_N => SRAM_WE_N,
				 dataReaded => dataReaded_s,
				 byte_m => byte_m,
				 dataToWrite => wr_data,
				 address => addr,
				 clk => CLOCK_50,
				 WR => WR_SIGNAL);
				 
	
				 
			WR_SIGNAL <= we;-- when addr < x"C000" else '0';
			
		--	vga_addr_s <= addr - x"A000" ;--  when addr >= x"A000";
			--vga_addr <= vga_addr(12 downto 0);
			vga_addr <= addr(12 downto 0);
			vga_we_s <= we when addr >= x"A000" and addr <= x"BFFF" else
						 '0';
			vga_we <= vga_we_s;
			vga_wr_data <= wr_data;
			vga_byte_m <= byte_m;

			rd_data <= dataReaded_s;
			
--			rd_data <= vga_rd_data when addr >= x"A000" and addr <= x"BFFF" else
--						  dataReaded_s;
			
end comportament;
