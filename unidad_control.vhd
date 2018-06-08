LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY unidad_control IS
	PORT 
	(
		boot          : IN STD_LOGIC;
		clk           : IN STD_LOGIC;
		datard_m      : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		op            : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		wrd_gp_int    : OUT STD_LOGIC; --permis escriptura BRint
		wrd_gp_fp     : OUT STD_LOGIC; --permis escriptura BRfp
		addr_a        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		addr_b        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		addr_d        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		immed         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		pc            : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		ins_dad       : OUT STD_LOGIC;
		in_d          : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); --indica quina es la dada a escriure en BR (PC, ALU o MEM, IN respectivament)
		immed_x2      : OUT STD_LOGIC;
		wr_m          : OUT STD_LOGIC; --permis escriptura memoria
		word_byte     : OUT STD_LOGIC;
		jump_addr     : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		tknbr         : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		addr_io       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		rd_in         : OUT STD_LOGIC;
		wr_out        : OUT STD_LOGIC;
 
		sel_br        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); --indica d'on agafar el valor a: 00 -> BRint, 01-> BRsys, others-> BRfp
		d_sys         : OUT STD_LOGIC; --permis escriptura sysBR
		b_br			  : OUT STD_LOGIC; --indica d'on agafar el valor b: 0 -> BRint, 1 ->BRfp
		sel_alu_w	  : OUT STD_LOGIC; --indica si hem de seleccionar la w de la ALU INT o FP
		sys           : OUT STD_LOGIC;
		enable_int    : OUT STD_LOGIC;
		disable_int   : OUT STD_LOGIC;
		reti          : OUT STD_LOGIC;
		getiid        : OUT std_logic;
		inta          : OUT std_logic;
		intr          : IN std_logic;
		state_word    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		invalid_instr : OUT STD_LOGIC;
		excepr        : IN STD_LOGIC;
		calls         : OUT STD_LOGIC;
		instr_protected : OUT STD_LOGIC;
		flush         : OUT STD_LOGIC;
		wr_tlb_pi      : OUT STD_LOGIC;
		wr_tlb_pd      : OUT STD_LOGIC;
		wr_tlb_vi      : OUT STD_LOGIC;
		wr_tlb_vd      : OUT STD_LOGIC;
		estado_cpu : OUT std_logic_vector(1 downto 0)
	);
END unidad_control;

ARCHITECTURE Structure OF unidad_control IS

	SIGNAL load_pc  : std_logic;
	SIGNAL immed_s  : std_logic_vector(15 DOWNTO 0);
	SIGNAL inta_l_s : std_logic;

	SIGNAL calls_s  : std_logic;
 
	COMPONENT control_l IS
		PORT 
		(
			ir            : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			state_word 	  : IN STD_LOGIC_VECTOR(15 downto 0);
			op            : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			ldpc          : OUT STD_LOGIC;
			wrd_gp_int    : OUT STD_LOGIC; --permis escriptura BRint
			wrd_gp_fp     : OUT STD_LOGIC; --permis escriptura BRfp
			
			addr_a        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			addr_b        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			addr_d        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			immed         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			wr_m          : OUT STD_LOGIC;
			in_d          : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			immed_x2      : OUT STD_LOGIC;
			word_byte     : OUT STD_LOGIC;
			addr_io       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			rd_in         : OUT STD_LOGIC;
			wr_out        : OUT STD_LOGIC;
			low_ir        : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);

			d_sys         : OUT STD_LOGIC; --permis escriptura sysBR
			sel_br        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); --indica d'on agafar el valor a: 00 -> BRint, 01-> BRsys, others-> BRfp
			b_br			  : OUT STD_LOGIC; --indica d'on agafar el valor b: 0 -> BRint, 1 ->BRfp
			sel_alu_w	  : OUT STD_LOGIC; --indica si hem de seleccionar la w de la ALU INT o FP
			sel_mem_dat	  : OUT STD_LOGIC; --inidica de que BR se escoge el dato a escribir en memoria
			enable_int    : OUT STD_LOGIC;
			disable_int   : OUT STD_LOGIC;
			reti          : OUT STD_LOGIC;
			inta          : OUT std_logic;
			getiid        : OUT std_logic;
			invalid_instr : OUT std_logic;
			calls         : OUT STD_LOGIC;
			instr_protected : OUT STD_LOGIC;
			flush         : OUT STD_LOGIC;
			wr_tlb_pi      : OUT STD_LOGIC;
			wr_tlb_pd      : OUT STD_LOGIC;
			wr_tlb_vi      : OUT STD_LOGIC;
			wr_tlb_vd      : OUT STD_LOGIC
		);
	END COMPONENT;
 
	COMPONENT multi IS
		PORT 
		(
			clk       : IN STD_LOGIC;
			boot      : IN STD_LOGIC;
			ldpc_l    : IN STD_LOGIC;
			wrd_gp_int_l : IN STD_LOGIC;
			wrd_gp_fp_l : IN STD_LOGIC;
			sel_br_l   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			d_sys_l   : IN STD_LOGIC;
			wr_m_l    : IN STD_LOGIC;
			w_b       : IN STD_LOGIC;
			ldpc      : OUT STD_LOGIC;
			wrd_gp_int : OUT STD_LOGIC;
			wrd_gp_fp : OUT STD_LOGIC;
			wr_m      : OUT STD_LOGIC;
			ldir      : OUT STD_LOGIC;
			ins_dad   : OUT STD_LOGIC;
			word_byte : OUT STD_LOGIC;
			--Interrupciones
			sel_br     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			d_sys      : OUT STD_LOGIC;
 
			sys        : OUT STD_LOGIC;
			inta_l     : IN std_logic;
			inta       : OUT std_logic;
			intr       : IN std_logic;
			state_word : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			excepr     : IN STD_LOGIC;
			calls 	   : IN STD_LOGIC;
			estado_cpu : OUT std_logic_vector(1 downto 0)
		);
	END COMPONENT;

	SIGNAL ir_signal        : std_logic_vector(15 DOWNTO 0);
	SIGNAL pc_signal        : std_logic_vector(15 DOWNTO 0) := X"C000";
	SIGNAL word_byte_signal : std_logic;
	SIGNAL wr_m_signal      : std_logic;
	SIGNAL wrd_gp_int_signal : std_logic;
	SIGNAL wrd_gp_fp_signal : std_logic;
	SIGNAL ldpc_signal      : std_logic;
	SIGNAL ldir_signal      : std_logic;

	SIGNAL sel_br_s          : std_logic_vector(1 DOWNTO 0);
	SIGNAL d_sys_s          : std_logic;

	SIGNAL op_s             : std_logic_vector(9 DOWNTO 0);
	SIGNAL sys_s            : std_logic;

BEGIN
	logicacontrol : control_l
	PORT MAP
	(
		ir            => ir_signal, 
		state_word 	  => state_word,
		op            => op_s, 
		ldpc          => ldpc_signal, 
		wrd_gp_int    => wrd_gp_int_signal,
		wrd_gp_fp     => wrd_gp_fp_signal,
		sel_br        => sel_br_s, 
		d_sys         => d_sys_s, 
		b_br 			  => b_br,
		sel_alu_w	  => sel_alu_w,
		sel_mem_dat	  => sel_mem_dat,
		addr_a        => addr_a, 
		addr_b        => addr_b, 
		addr_d        => addr_d, 
		immed         => immed_s, 
		wr_m          => wr_m_signal, 
		in_d          => in_d, 
		immed_x2      => immed_x2, 
		word_byte     => word_byte_signal, 
		addr_io       => addr_io, 
		rd_in         => rd_in, 
		wr_out        => wr_out, 
		enable_int    => enable_int, 
		disable_int   => disable_int, 
		reti          => reti, 
		getiid        => getiid, 
		inta          => inta_l_s, 
		invalid_instr => invalid_instr, 
		calls         => calls_s,
		instr_protected => instr_protected,
		flush         => flush,
		wr_tlb_pi      => wr_tlb_pi,
		wr_tlb_pd      => wr_tlb_pd,
		wr_tlb_vi      => wr_tlb_vi,
		wr_tlb_vd      => wr_tlb_vd
	);
 
	logicamulticiclo : multi
	PORT MAP
	(
		clk       => clk, 
		boot      => boot, 
		ldpc_l    => ldpc_signal, 
		wrd_gp_int_l => wrd_gp_int_signal,
		wrd_gp_fp_l  => wrd_gp_fp_signal,	
		sel_br_l   => sel_br_s, 
		d_sys_l   => d_sys_s, 
		wr_m_l    => wr_m_signal, 
		w_b       => word_byte_signal, 
		ldpc      => load_pc, 
		wrd_gp_int => wrd_gp_int,
		wrd_gp_fp  => wrd_gp_fp, 
		wr_m      => wr_m, --Cambiado
		ldir      => ldir_signal, 
		ins_dad   => ins_dad, 
		word_byte => word_byte, 
		-- Interrupciones
		sel_br     => sel_br, 
		d_sys      => d_sys, 
		sys        => sys_s, 
		intr       => intr, 
		inta       => inta, 
		state_word => state_word, 
		inta_l     => inta_l_s, 
		excepr     => excepr,
		calls	   => calls_s,
		estado_cpu => estado_cpu
	);
	PROCESS (clk, boot, ldpc_signal, load_pc) BEGIN
	IF boot = '1' THEN
		pc_signal <= X"C000";
		ir_signal <= X"0001";
	ELSIF rising_edge(clk) THEN
		IF ldir_signal = '1' THEN
			ir_signal <= datard_m;
		END IF;
		IF load_pc = '1' THEN
			IF sys_s = '1' OR op_s(9 DOWNTO 0) = "1111100100" THEN
				pc_signal <= jump_addr;
			ELSIF tknbr(1 DOWNTO 0) = "00" THEN
				pc_signal <= pc_signal + 2;
			ELSIF tknbr(1 DOWNTO 0) = "01" THEN
				pc_signal <= pc_signal + (immed_s(14 DOWNTO 0) & '0') + 2;
			ELSIF tknbr(1 DOWNTO 0) = "10" THEN
				pc_signal <= jump_addr; 
			END IF;
		END IF;
	END IF;
END PROCESS;

immed <= immed_s;
pc    <= pc_signal;
 
op    <= op_s;
sys   <= sys_s;

calls <= calls_s;
 
END Structure;