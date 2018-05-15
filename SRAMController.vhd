library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;


entity SRAMController is
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
			 
			 
end SRAMController;

architecture comportament of SRAMController is

type state_type is (e0, e1, e2, e3);
signal estado_actual : state_type := e0;

SIGNAL dataReadHigh : STD_LOGIC_VECTOR (7 downto 0);
SIGNAL dataReadLow : STD_LOGIC_VECTOR (7 downto 0);
SIGNAL contador : STD_LOGIC_VECTOR (2 downto 0):="000";


begin

	process (clk,WR)
	begin 	
		if rising_edge(clk) then
			if WR='1' then
				contador <= contador + 1;
			end if;
			case estado_actual is
				when e0 => 
					if WR='1' then 
						estado_actual <= e1;
					end if;
				when e1 =>
						estado_actual <= e0; 
				when e2 => estado_actual <= e0;
				
				when e3 => estado_actual <=e0;
			end case;
		end if;
	end process;
	
	
		SRAM_UB_N <= '1' when byte_m = '1' and address(0) = '0' else
		             '0';
	
		SRAM_LB_N <= '1' when byte_m =  '1' and address(0) = '1' else
		             '0';
	
--		SRAM_WE_N <= '1' when estado_actual = e0 else '0';
		SRAM_WE_N <= '0' when contador="100" or contador="101" else '1';
	
		SRAM_CE_N <= '0';
	
		SRAM_OE_N <= '0'; --when estado_actual = e0 else '1';
	
		SRAM_DQ <= "ZZZZZZZZZZZZZZZZ" when WR='0' else 
		           dataToWrite(7 downto 0) & "ZZZZZZZZ" when byte_m='1' and address(0) = '1' else
		           "ZZZZZZZZ" & dataToWrite(7 downto 0) when byte_m='1' and address(0) = '0' else
		           dataToWrite;
		
		--SRAM_DQ <= "ZZZZZZZZZZZZZZZZ" when estado_actual = e0 else 
		--           dataToWrite(7 downto 0) & x"00" when estado_actual = e1 and address(0) = '1' else
		--            dataToWrite;
	
	  dataReaded <=	dataReadHigh & dataReadLow;

    dataReadLow <= SRAM_DQ(15 downto 8) when byte_m =  '1' and address(0) = '1' else
                   SRAM_DQ(7 downto 0);

    dataReadHigh <= SRAM_DQ(15 downto 8) when byte_m =  '0' else
                   (others => dataReadLow(7));
    
--		dataReaded <= SRAM_DQ when estado_actual = e0 and  byte_m =  '0' else
--							std_logic_vector(resize(signed(SRAM_DQ(7 downto 0)), dataReaded'length)) when estado_actual = e0 and byte_m = '1' and address(0) = '0' else 
--							std_logic_vector(resize(signed(SRAM_DQ(15 downto 8)), dataReaded'length)) ; 
		
		
		SRAM_ADDR <= "000" & address(15 downto 1) ;
		
	
end comportament;
