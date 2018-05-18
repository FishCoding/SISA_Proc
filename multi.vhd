LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY multi IS
	PORT( clk : IN STD_LOGIC;
			boot : IN STD_LOGIC;
			ldpc_l : IN STD_LOGIC;
			wrd_l : IN STD_LOGIC;
			a_sys_l : IN STD_LOGIC;
			d_sys_l : IN STD_LOGIC;
			wr_m_l : IN STD_LOGIC;
			w_b : IN STD_LOGIC;
			ldpc : OUT STD_LOGIC;
			wrd : OUT STD_LOGIC;
			wr_m : OUT STD_LOGIC;
			ldir : OUT STD_LOGIC;
			ins_dad : OUT STD_LOGIC;
			word_byte : OUT STD_LOGIC;
			-- Interrupciones
			a_sys : OUT STD_LOGIC;
			d_sys : OUT STD_LOGIC;
			sys: OUT STD_LOGIC;
			inta_l : IN STD_LOGIC;
			inta : out std_logic;
			intr : IN STD_LOGIC;
			state_word : IN STD_LOGIC_VECTOR(15 downto 0);
			excepr : IN STD_LOGIC
			
			);
END multi;

ARCHITECTURE Structure OF multi IS
type state_type is (FETCH, DEMW, SYSTEM);
signal estado_actual : state_type;
BEGIN

process (boot,clk)
begin 
	if boot = '1' then
		estado_actual <= FETCH;
	elsif rising_edge(clk) then
		
		case estado_actual is
			when FETCH => estado_actual <= DEMW;
			when DEMW => 
				if ( intr ='1' or excepr='1' )  and state_word(1) = '1' then
					estado_actual <= SYSTEM;
				else
					estado_actual <=FETCH;
				end if;
			when SYSTEM => estado_actual <= FETCH;
		end case;
	end if;
end process;

inta <= inta_l when estado_actual=DEMW else '0';
wr_m <= wr_m_l when estado_actual=DEMW else '0';

ldpc <= ldpc_l when estado_actual=DEMW else 
		  '1' when estado_actual=SYSTEM else
		  '0'; -- Load PC
wrd <= wrd_l when estado_actual=DEMW else '0';
word_byte <= w_b when estado_actual=DEMW else '0';
ins_dad <= '1' when estado_actual=DEMW else '0';
ldir <= '0' when estado_actual=DEMW else '1';

sys <= '1' when estado_actual=SYSTEM else '0';

d_sys <= d_sys_l when estado_actual=DEMW else '0';

a_sys <= a_sys_l when estado_actual=DEMW else 
			'1' when estado_actual =SYSTEM else
			'0';

END Structure;