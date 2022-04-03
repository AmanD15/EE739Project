library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;

entity Inst_Decode is
generic (inst_width : integer := 16);
port (stall : in std_logic;
		pc : in std_logic;
		inst : in std_logic_vector(inst_width-1 downto 0);
		op_code : out std_logic_vector(3 downto 0);
		r_a : out std_logic_vector(2 downto 0);
		r_b : out std_logic_vector(2 downto 0);
		r_c : out std_logic_vector(2 downto 0);
		enable_b : out std_logic;
		enale_c : out std_logic;
		imm : out std_logic_vector(8 downto 0);
		cz : out std_logic_vector(1 downto 0);
		);
end entity Inst_Decode;

architecture Decode of Inst_Decode is
begin
	process(stall,pc,inst)
	begin
		if (not stall)
			op_code <= inst(15 downto 12);
			r_a <= inst(11 downto 9);
			r_b <= inst(8 downto 6);
			r_c <= inst(5 downto 3);
			imm <= inst(8 downto 0);
		end if;
	end process;
end architecture Decode;