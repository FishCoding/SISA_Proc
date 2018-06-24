LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY regfile_simd IS
    PORT (clk    : IN  STD_LOGIC;
          wrd0   : IN  STD_LOGIC;
          wrd1   : IN  STD_LOGIC;
          wrd2   : IN  STD_LOGIC;
          wrd3   : IN  STD_LOGIC;
          d0     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          d1     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          d2     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          d3     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          r0     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          r1     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          r2     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		  r3     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END regfile_simd;

ARCHITECTURE Structure OF regfile_simd IS
	type Banco_Registros is array (3 downto 0) of std_logic_vector(15 downto 0);
	signal BR : Banco_Registros ;

BEGIN

    r0 <= BR(0);
    r1 <= BR(1);
    r2 <= BR(2);
    r3 <= BR(3);
	
	process(clk) begin
		if rising_edge(clk) then
			if wrd0='1' then
				BR(0) <= d0;
            end if;
            if wrd1='1' then
				BR(1) <= d1;
            end if;
            if wrd2='1' then
				BR(2) <= d2;
            end if;
            if wrd0='1' then
				BR(3) <= d3;
            end if;
		end if;
	end process;
	

END Structure;