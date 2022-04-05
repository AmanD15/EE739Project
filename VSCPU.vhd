library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;
use work.IF_Stage.all;

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
signal readWrite_I : std_logic;
signal inst_fetch : std_logic_vector(data_width-1 downto 0);
signal pc , pc_out, pc_dec_out:std_logic_vector(addr_width-1 downto 0);
signal op_dec : std_logic_vector(3 downto 0);
signal r_a_dec, r_b_dec, r_c_dec, cz_dec : std_logic_vector(2 downto 0);
signal en_b,en_c : std_logic;
signal imm : std_logic_vector(8 downto 0);

begin
Inst_Mem : memory port map (clk , address , data , readWrite_I , inst_fetch);
fetch_stage : Inst_Fetch port map (stall, clk, pc, pc_out);
decode_stage : Inst_Decode port map (stall, pc_out, clk, inst_fetch,
		op_dec,r_a_dec ,r_b_dec, r_c_dec , en_b ,en_c ,imm, cz, pc_dec_out);

end architecture arch;
