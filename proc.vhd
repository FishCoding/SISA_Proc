LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY proc IS
	PORT 
	(
		boot      : IN STD_LOGIC;
		clk       : IN STD_LOGIC;
		datard_m  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		addr_m    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		wr_m      : OUT STD_LOGIC;
		word_byte : OUT STD_LOGIC;
		data_wr   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		rd_io     : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		wr_io     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		addr_io   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		rd_in     : OUT STD_LOGIC;
		wr_out    : OUT STD_LOGIC;
		getiid    : OUT std_logic;
		inta      : OUT std_logic;
		intr      : IN std_logic
	);
END proc;
ARCHITECTURE Structure OF proc IS

	SIGNAL z_s : STD_LOGIC;
	
	COMPONENT TLB_instr is
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
	END COMPONENT;

	COMPONENT TLB_datos IS
    PORT (clk    : IN STD_LOGIC;
          boot   : IN STD_LOGIC;
          vtag   : IN STD_LOGIC_VECTOR(3 downto 0);
          wr_v   : IN STD_LOGIC;
          wr_f   : IN STD_LOGIC;
		  flush  : IN STD_LOGIC;
		  dir    : IN STD_LOGIC_VECTOR(5 downto 0);
          pos    : IN STD_LOGIC_VECTOR(2 downto 0);
          ptag   : OUT STD_LOGIC_VECTOR(3 downto 0);
          v      : OUT STD_LOGIC;
          r      : OUT STD_LOGIC;
          miss   : OUT STD_LOGIC);
	END COMPONENT;
	
	COMPONENT datapath IS
		PORT 
		(
			clk              : IN STD_LOGIC;
			op               : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			wrd              : IN STD_LOGIC;
			d_sys            : IN STD_LOGIC;
			a_sys            : IN STD_LOGIC;
			addr_a           : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			addr_d           : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			immed            : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			addr_b           : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			immed_x2         : IN STD_LOGIC;
			datard_m         : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			ins_dad          : IN STD_LOGIC;
			pc               : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			in_d             : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			data_wr          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			addr_m           : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			jump_addr        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			tknbr            : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			rd_io            : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			wr_io            : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			sys              : IN STD_LOGIC;
			enable_int       : IN STD_LOGIC;
			disable_int      : IN STD_LOGIC;
			reti             : IN STD_LOGIC;
			boot             : IN STD_LOGIC;
			state_word       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			invalid_division : OUT STD_LOGIC;
			id_excep         : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			value_data 	     : IN STD_LOGIC_VECTOR(15 downto 0);
			a                : OUT STD_LOGIC_VECTOR(15 downto 0);
			b                : OUT STD_LOGIC_VECTOR(15 downto 0)
		);
 
	END COMPONENT;
 
	COMPONENT unidad_control IS
		PORT 
		(
			boot            : IN STD_LOGIC;
			clk             : IN STD_LOGIC;
			datard_m        : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			op              : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			wrd             : OUT STD_LOGIC;
			addr_a          : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			addr_b          : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			addr_d          : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			immed           : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			pc              : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			ins_dad         : OUT STD_LOGIC;
			in_d            : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			immed_x2        : OUT STD_LOGIC;
			wr_m            : OUT STD_LOGIC;
			word_byte       : OUT STD_LOGIC;
			jump_addr       : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			tknbr           : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			addr_io         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			rd_in           : OUT STD_LOGIC;
			wr_out          : OUT STD_LOGIC;
			d_sys           : OUT STD_LOGIC;
			a_sys           : OUT STD_LOGIC;
			sys             : OUT STD_LOGIC;
			enable_int      : OUT STD_LOGIC;
			disable_int     : OUT STD_LOGIC;
			reti            : OUT STD_LOGIC;
			getiid          : OUT std_logic;
			inta            : OUT std_logic;
			intr            : IN std_logic;
			state_word      : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			invalid_instr   : OUT STD_LOGIC;
			excepr          : IN STD_LOGIC;
			calls           : OUT STD_LOGIC;
			instr_protected : OUT STD_LOGIC;
			flush           : OUT STD_LOGIC;
			wr_tlb_pi       : OUT STD_LOGIC;
			wr_tlb_pd       : OUT STD_LOGIC;
			wr_tlb_vi       : OUT STD_LOGIC;
			wr_tlb_vd       : OUT STD_LOGIC;
			estado_cpu      : OUT std_logic_vector(1 downto 0)
		);
	END COMPONENT;

	COMPONENT exception_controller IS
		PORT 
		(
			clk : IN STD_LOGIC;
			op                : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			byte_word         : IN STD_LOGIC;
			addr              : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			exception_value   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			excepr            : OUT STD_LOGIC;
			invalid_division  : IN STD_LOGIC;
			intr              : IN STD_LOGIC;
			invalid_instr     : IN STD_LOGIC;
			calls             : IN STD_LOGIC;
			state_word 		  : IN STD_LOGIC_VECTOR(15 downto 0);
			instr_protected   : IN STD_LOGIC;
			value_data 		  : OUT STD_LOGIC_VECTOR(15 downto 0);
			system            : IN STD_LOGIC;
			tlb_miss_inst     : IN STD_LOGIC;
			tlb_miss_datos    : IN STD_LOGIC;
			tlb_invalid_inst  : IN STD_LOGIC;
			tlb_invalid_datos : IN STD_LOGIC;
			tlb_lectura_datos : IN STD_LOGIC;
			estado_cpu        : IN STD_LOGIC_VECTOR(1 downto 0)
		);
	END COMPONENT;
 
	signal flush_tlb_datos    : std_logic;
	signal flush_tlb_inst     : std_logic;
	signal flush              : std_logic;
	signal wr_tlb_pd          : std_logic;
	signal wr_tlb_pi          : std_logic;
	signal wr_tlb_vd          : std_logic;
	signal wr_tlb_vi          : std_logic;
	signal miss_tlb_inst      : std_logic;
	signal miss_tlb_datos     : std_logic;
	signal v_inst             : std_logic;
	signal v_datos            : std_logic;
	signal r_inst             : std_logic;
	signal r_datos            : std_logic;
	signal tag_fisico_d       : std_logic_vector (3 downto 0);
	signal tag_fisico_i       : std_logic_vector (3 downto 0);
	signal addr_m_postlb      : std_logic_vector (15 downto 0);

	SIGNAL estado_cpu_s       : std_logic_vector(1 downto 0);

	signal reg_A              : std_logic_vector(15 downto 0);
	signal reg_B              : std_logic_vector(15 downto 0);
	
	SIGNAL op_signal          : std_logic_vector(9 DOWNTO 0);
	SIGNAL wrd_signal         : std_logic;
 
	SIGNAL ins_dad_signal     : std_logic;
	SIGNAL addr_a_signal      : std_logic_vector(2 DOWNTO 0);
	SIGNAL addr_d_signal      : std_logic_vector(2 DOWNTO 0);
	SIGNAL imed_signal        : std_logic_vector(15 DOWNTO 0);
	SIGNAL addr_b_signal      : std_logic_vector(2 DOWNTO 0);
	SIGNAL immed_x2_signal    : std_logic;
	SIGNAL wr_m_signal        : std_logic;
	SIGNAL pc_signal          : std_logic_vector(15 DOWNTO 0);
	SIGNAL pc_signal_fancy    : std_logic_vector(15 downto 0);
	SIGNAL in_d_signal        : std_logic_vector(1 DOWNTO 0);
	SIGNAL tknbr_s            : std_logic_vector(1 DOWNTO 0);
 
	SIGNAL jump_addr_s        : std_logic_vector(15 DOWNTO 0);
 
	SIGNAL a_sys_s            : std_logic;
	SIGNAL d_sys_s            : std_logic;
	SIGNAL sys_s              : std_logic;
 
	SIGNAL enable_int_s       : std_logic;
	SIGNAL disable_int_s      : std_logic;
 
	SIGNAL reti_s             : std_logic;
 
	SIGNAL state_word_s       : std_logic_vector(15 DOWNTO 0);

	SIGNAL addr_m_s           : std_logic_vector(15 DOWNTO 0);
	SIGNAL exception_value_s  : std_logic_vector(3 DOWNTO 0);
	SIGNAL invalid_division_s : std_logic := '0';
	SIGNAL invalid_instr_s    : std_logic := '0';

	SIGNAL intr_s             : std_logic;

	SIGNAL except_s           : std_logic;

	SIGNAL calls_s            : std_logic;

	SIGNAL 	instr_protected_s  : std_logic;
	
	SIGNAL value_data_s : std_logic_vector(15 downto 0);
	
	SIGNAL wr_tlb_pd_s : std_logic;
	SIGNAL wr_tlb_pi_s : std_logic;
	SIGNAL wr_tlb_vd_s : std_logic;
	SIGNAL wr_tlb_vi_s : std_logic;
BEGIN
	
	flush_tlb_datos <= flush and reg_A(1);
	flush_tlb_inst <= flush and reg_A(3);
	wr_tlb_pd <= wr_tlb_pd_s when estado_cpu_s = "01" else '0';
	wr_tlb_pi <= wr_tlb_pi_s when estado_cpu_s = "00" else '0';
	wr_tlb_vd <= wr_tlb_vd_s when estado_cpu_s = "01" else '0';
	wr_tlb_vi <= wr_tlb_vi_s when estado_cpu_s = "00" else '0';

	tlb_dat : TLB_datos
	PORT MAP
	(
		boot => boot,
		clk => clk,
		vtag => addr_m_s(15 downto 12),
        wr_v => wr_tlb_vd,
        wr_f => wr_tlb_pd,
		flush => flush_tlb_datos,
		dir => reg_B(5 downto 0),
        pos => reg_A(2 downto 0),
        ptag => tag_fisico_d,
        v => v_datos,
        r => r_datos,
		miss => miss_tlb_datos
	);

	TLB_inst : TLB_instr
	PORT MAP
	(
		boot => boot,
		clk => clk,
		vtag => addr_m_s(15 downto 12),
        wr_v => wr_tlb_vi,
        wr_f => wr_tlb_pi,
		flush => flush_tlb_inst,
		dir => reg_B(5 downto 0),
        pos => reg_A(2 downto 0),
        ptag => tag_fisico_i,
        v => v_inst,
        r => r_inst,
		miss => miss_tlb_inst
	);

	addr_m_postlb <= tag_fisico_i & addr_m_s(11 downto 0) when estado_cpu_s = "00" else --FETCH
					 tag_fisico_d & addr_m_s(11 downto 0); --Others
	
	addr_m <= addr_m_postlb;

	intr_s <= intr;

	pc_signal_fancy <= pc_signal - 2 when miss_tlb_inst = '1' or miss_tlb_datos = '1' else 
					   pc_signal;

	unidadcontrol0 : unidad_control
	PORT MAP
	(
		boot          => boot, 
		clk           => clk, 
		datard_m      => datard_m, 
		op            => op_signal, 
		wrd           => wrd_signal, 
		a_sys         => a_sys_s, 
		d_sys         => d_sys_s, 
		addr_a        => addr_a_signal, 
		addr_d        => addr_d_signal, 
		addr_b        => addr_b_signal, 
		immed         => imed_signal, 
		pc            => pc_signal, 
		ins_dad       => ins_dad_signal, 
		in_d          => in_d_signal, 
		immed_x2      => immed_x2_signal, 
		wr_m          => wr_m, 
		word_byte     => word_byte, 
		tknbr         => tknbr_s, 
		jump_addr     => jump_addr_s, 
		addr_io       => addr_io, 
		rd_in         => rd_in, 
		wr_out        => wr_out, 
		sys           => sys_s, 
		enable_int    => enable_int_s, 
		disable_int   => disable_int_s, 
		reti          => reti_s, 
		getiid        => getiid, 
		inta          => inta, 
		intr          => intr_s, 
		state_word    => state_word_s, 
		invalid_instr => invalid_instr_s, 
		excepr        => except_s, 
		calls         => calls_s,
		instr_protected => instr_protected_s,
		flush         => flush,
		wr_tlb_pd     => wr_tlb_pd_s,
		wr_tlb_pi     => wr_tlb_pi_s,
		wr_tlb_vd     => wr_tlb_vd_s,
		wr_tlb_vi     => wr_tlb_vi_s,
		estado_cpu    => estado_cpu_s
	);
 
	datapath0 : datapath
	PORT MAP
	(
		clk              => clk, 
		op               => op_signal, 
		wrd              => wrd_signal, 
		a_sys            => a_sys_s, 
		d_sys            => d_sys_s, 
		addr_a           => addr_a_signal, 
		addr_d           => addr_d_signal, 
		immed            => imed_signal, -- holy
		addr_b           => addr_b_signal, 
		immed_x2         => immed_x2_signal, 
		datard_m         => datard_m, 
		ins_dad          => ins_dad_signal, 
		pc               => pc_signal_fancy, 
		in_d             => in_d_signal, 
		data_wr          => data_wr, 
		addr_m           => addr_m_s, 
		tknbr            => tknbr_s, 
		jump_addr        => jump_addr_s, 
		rd_io            => rd_io, 
		wr_io            => wr_io, 
		sys              => sys_s, 
		enable_int       => enable_int_s, 
		disable_int      => disable_int_s, 
		reti             => reti_s, 
		boot             => boot, 
		state_word       => state_word_s, 
		invalid_division => invalid_division_s, 
		id_excep         => exception_value_s,
		value_data 		 => value_data_s,
		a                => reg_A,
		b                => reg_B
	);
	
	excep_controller : exception_controller
	PORT MAP
	(
		clk => clk,
		op                => op_signal, 
		byte_word         => wrd_signal, 
		addr              => addr_m_postlb, 
		exception_value   => exception_value_s, 
		excepr            => except_s, 
		invalid_division  => invalid_division_s, 
		invalid_instr     => invalid_instr_s, 
		intr              => intr_s, 
		calls             => calls_s,
		state_word 		  => state_word_s,
		instr_protected   => instr_protected_s,
		value_data 		  => value_data_s,
		system            => sys_s,
		tlb_miss_inst     => miss_tlb_inst,
		tlb_miss_datos    => miss_tlb_datos,
		tlb_invalid_inst  => v_inst,
		tlb_invalid_datos => v_datos,
		tlb_lectura_datos => r_datos,
		estado_cpu        => estado_cpu_s
	);
 

END Structure;