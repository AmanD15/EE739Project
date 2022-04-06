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
signal address : std_logic_vector(addr_width-1 downto 0);
signal readWrite_I : std_logic := '0';
signal inst_f : std_logic_vector(data_width-1 downto 0);
signal pc , pc_fet, pc_dec_out, pc_ra, pc_alu: std_logic_vector(addr_width-1 downto 0);
signal op_dec, op_ra : std_logic_vector(3 downto 0);
signal r_a_dec, r_b_dec, r_c_dec, r_co, addr_5, wb_out_alu, nI_ma, ma_sa : std_logic_vector(2 downto 0);
signal cz_dec, cz_ra : std_logic_vector(1 downto 0);
signal en_b,en_c, enable_5, wb_enable, w_en_ma: std_logic;
signal imm_dec: std_logic_vector(8 downto 0);
signal data_a_ra, data_b_ra, data_c_ra, data_5, data_out_alu : std_logic_vector(15 downto 0);
signal ma_data_in, ma_data_out : std_logic_vector(127 downto 0);

begin
address <= addr when (write_flag = '1') else pc_fet; 
Inst_Mem : memory port map (clk , address , data , readWrite_I , inst_f);

stage1 : Inst_Fetch port map (stall => stall,clk => clk,pc => pc,pc_out => pc_fet);

stage2 : Inst_Decode port map (stall => stall,pc => pc_fet,clk => clk,inst => inst_f, 
							op_code => op_dec,
							r_a => r_a_dec,r_b => r_b_dec,r_c => r_c_dec , 
							enable_b => en_b,enable_c => en_c,imm => imm_dec,
							cz => cz_dec,pc_out => pc_dec_out);
							
stage3 : register_read port map (stall => stall,clk=>clk,pc => pc_dec_out,
							r_a => r_a_dec,r_b => r_b_dec,
							r_c => r_c_dec,imm => imm_dec,
							op_code => op_dec,cz=> cz_dec,
							data_a => data_a_ra, data_b => data_b_ra,data_c => data_c_ra,
							cz_out => cz_ra,r_co => r_co,op_out => op_ra,pc_out => pc_ra
							);
		
stage4 : Execute port map (stall=> stall,clk=> clk,
							pc=>pc_ra,op_code=> op_ra,cz=> cz_ra,wb_in=>r_co,
							data_a => data_a_ra, data_b => data_b_ra,data_c => data_c_ra,
							data_out=> data_out_alu,wb_out=> wb_out_alu,wb_enable=> wb_enable,
							pc_next=>pc_alu);
							
stage5 : Mem_Access port map (stall => stall, clk => clk,
		readWrite => w_en_ma,
		start_address => data_out_alu,
		num_inputs => nI_ma,
		data_in => ma_data_in,
		data_out => ma_data_out,
		wb_in => wb_out_alu,
		wb_enable => wb_enable,
		pc_in => pc_alu,
		pc_next => pc);
end architecture arch;
