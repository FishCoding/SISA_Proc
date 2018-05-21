LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY TLB_datos IS
    PORT (clk    : IN STD_LOGIC;
          boot   : IN STD_LOGIC;
          
          vtag   : IN STD_LOGIC_VECTOR(3 downto 0);  -- Tag de la direccion
          wr_v   : IN STD_LOGIC;
          wr_f   : IN STD_LOGIC;
          flush  : IN STD_LOGIC;
          dir    : IN STD_LOGIC_VECTOR(5 downto 0);
          pos    : IN STD_LOGIC_VECTOR(2 downto 0);
          ptag   : OUT STD_LOGIC_VECTOR(3 downto 0);
          v      : OUT STD_LOGIC;
          r      : OUT STD_LOGIC;
          miss   : OUT STD_LOGIC);
END TLB_datos;


ARCHITECTURE Structure OF TLB_datos IS
    type Tabla_TLB_VIRT is array (7 downto 0) of std_logic_vector(3 downto 0);
    type Tabla_TLB_FISICO is array (7 downto 0) of std_logic_vector(5 downto 0);
	
   
    
    signal virtual : Tabla_TLB_VIRT ;
    signal fisico : Tabla_TLB_FISICO ;
    
    signal n_vir : std_logic_vector(7 downto 0);
    signal codificador : std_logic_vector(3 downto 0);
    signal dir_f : std_logic_vector(5 downto 0);
    signal miss_signal : STD_LOGIC;

  
BEGIN
    
    n_vir(0) <= '1' when virtual(0) = vtag else '0';
    n_vir(1) <= '1' when virtual(1) = vtag else '0'; 
    n_vir(2) <= '1' when virtual(2) = vtag else '0';
    n_vir(3) <= '1' when virtual(3) = vtag else '0';
    n_vir(4) <= '1' when virtual(4) = vtag else '0';
    n_vir(5) <= '1' when virtual(5) = vtag else '0';
    n_vir(6) <= '1' when virtual(6) = vtag else '0';
    n_vir(7) <= '1' when virtual(7) = vtag else '0';

    miss_signal <= '1' when n_vir = "00000000" else '0';
    miss <= miss_signal;

    with n_vir select
        codificador <= x"0" when "00000001",
                       x"1" when "00000010",
                       x"2" when "00000100",
                       x"3" when "00001000",
                       x"4" when "00010000",
                       x"5" when "00100000",
                       x"6" when "01000000",
                       x"7" when others;--when "10000000",

  --  with codificador select 
  --      dir_f <= fisico(0) when x"0",
  --               fisico(1) when x"1",
  --               fisico(2) when x"2",
  --               fisico(3) when x"3",
  --               fisico(4) when x"4",
  --               fisico(5) when x"5",
  --               fisico(6) when x"6",
  --               fisico(7) when others;--x"7";

    dir_f <= fisico(0) when n_vir(0) = '1' else
             fisico(1) when n_vir(1) = '1' else
             fisico(2) when n_vir(2) = '1' else
             fisico(3) when n_vir(3) = '1' else
             fisico(4) when n_vir(4) = '1' else
             fisico(5) when n_vir(5) = '1' else
             fisico(6) when n_vir(6) = '1' else
             fisico(7) ;--x"7";

    v <= not dir_f(5);
    r <= not dir_f(4);
    ptag <= dir_f(3 downto 0);


	process(clk, boot)
     begin
       
        if boot = '1' then
            virtual(0) <= "0000"; 
            virtual(1) <= "0000";
            virtual(2) <= "0000";
            virtual(3) <= "0000";
            virtual(4) <= "0000";
            virtual(5) <= "0000";
            virtual(6) <= "0000";
            virtual(7) <= "0000";
            
            fisico(0) <= "000000"; 
            fisico(1) <= "000000"; 
            fisico(2) <= "000000"; 
            fisico(3) <= "000000"; 
            fisico(4) <= "000000"; 
            fisico(5) <= "000000"; 
            fisico(6) <= "000000"; 
            fisico(7) <= "000000"; 
        elsif rising_edge(clk) then
            if flush = '1' then
                fisico(0)(5) <= '0'; 
                fisico(1)(5) <= '0'; 
                fisico(2)(5) <= '0'; 
                fisico(3)(5) <= '0'; 
                fisico(4)(5) <= '0'; 
                fisico(5)(5) <= '0'; 
                fisico(6)(5) <= '0'; 
                fisico(7)(5) <= '0';
            elsif wr_v = '1' then
                virtual(conv_integer(pos)) <= dir(3 downto 0);
            elsif wr_f = '1' then
                fisico(conv_integer(pos)) <= dir;          
            end if;
		end if;
	end process;
	

END Structure;