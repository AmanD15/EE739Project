library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;
use work.IF_Stage.all;
use work.ID_Stage.all;
use work.RA_stage.all;
use work.EX_stage.all;
use work.MA_stage.all;

entity VSCPU is
	generic( addr_width : natural := 16;
				data_width : natural := 16;
				pc_start : natural := 1
			);
	port( clk : in std_logic;
			reset : in std_logic;
			start : in std_logic;
			write_flag : in std_logic;
			addr : in std_logic_vector(addr_width-1 downto 0);
			data : in std_logic_vector(data_width-1 downto 0)
			);
end entity VSCPU;

architecture arch of VSCPU is

signal stall : std_logic := '0';
signal address, add_5 : std_logic_vector(15 downto 0);
signal readWrite_I : std_logic := '0';
signal inst_f : std_logic_vector(15 downto 0);
signal pc , pc_fet, pc_dec_out, pc_ra, pc_alu: std_logic_vector(15 downto 0);
signal op_dec, op_ra : std_logic_vector(3 downto 0);
signal r_a_dec, r_b_dec, r_c_dec, r_co, addr_5, wb_out_alu: std_logic_vector(2 downto 0);
signal cz_dec, cz_ra : std_logic_vector(1 downto 0);
signal en_b,en_c, enable_5, wb_enable, w_en_ma: std_logic;
signal imm_dec: std_logic_vector(8 downto 0);
signal reg_upd_ra, reg_upd_alu, mem_upd_ra, mem_upd_alu: std_logic_vector(7 downto 0);
signal data_5, mem_add_in_alu, mem_add_out_alu : std_logic_vector(15 downto 0);
signal ma_data_out, data_ra, data_out_alu: std_logic_vector(127 downto 0);
signal ms_ra, ms_alu : std_logic;

begin

address <= addr when (write_flag = '1') else pc_fet; 
Inst_Mem : memory port map (clk => clk, addr => address, data => data,
							readWrite => readWrite_I ,output => inst_f
							);

stage1 : Inst_Fetch port map (stall => stall,
							clk => clk,
							pc => pc,
							pc_out => pc_fet
							);

stage2 : Inst_Decode port map (stall => stall,
							pc => pc_fet,
							clk => clk,
							inst => inst_f, 
							op_code => op_dec,
							r_a => r_a_dec,
							r_b => r_b_dec,
							r_c => r_c_dec , 
							imm => imm_dec,
							cz => cz_dec,
							pc_out => pc_dec_out
							);
							
stage3 : register_read port map (stall_r => stall,
							stall_w => stall,
							clk=>clk,
							pc => pc_dec_out,
							r_a => r_a_dec,
							r_b => r_b_dec,
							r_c => r_c_dec,
							imm => imm_dec,
							op_code => op_dec,
							cz=> cz_dec,
							enable_5 => enable_5,
							data_5 => data_5,
							addr_5 => add_5,
							data_out => data_ra,
							cz_out => cz_ra,
							r_co => r_co,
							op_out => op_ra,
							pc_out => pc_ra,
							mem_address_out => mem_add_in_alu,
							data_in_alu => data_out_alu(15 downto 0),
							wb_in_alu => wb_out_alu,
							reg_updates => reg_upd_ra,
							mem_updates => mem_upd_ra,
							data_mem => ma_data_out,
							mem_sr => ms_ra
							);
		
stage4 : Execute port map (stall=> stall,
							clk=> clk,
							pc=>pc_ra,
							op_code=> op_ra,
							cz=> cz_ra,
							wb_in =>r_co,
							data_in => data_ra,
							mem_address => mem_add_in_alu,
							reg_bits => reg_upd_ra,
							reg_bits_out => reg_upd_alu,
							mem_bits => mem_upd_ra,
							mem_bits_out => mem_upd_alu,
							data_out => data_out_alu,
							wb_out => wb_out_alu,
							wb_enable => wb_enable,
							pc_next =>pc_alu,
							mem_add_out => mem_add_out_alu,
							mem_sr => ms_ra,
							mem_sr_out => ms_alu
							);
							
stage5 : Mem_Access port map (stall => stall,
							clk => clk,
							readWrite => w_en_ma,
							start_address => mem_add_out_alu,
							data_in => data_out_alu,
							data_out => ma_data_out,
							wb_in => wb_out_alu,
							wb_enable => wb_enable,
							reg_bits => reg_upd_alu,
							mem_bits => mem_upd_alu,
							mem_sr => ms_alu
							);
end architecture arch;
