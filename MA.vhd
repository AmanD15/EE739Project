library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;

entity Inst_Decode is
generic (inst_width : integer := 16);
port (stall : in std_logic;
		clk : in std_logic;
		pc : in std_logic;
		inst : in std_logic_vector(inst_width-1 downto 0);
		op_code : out std_logic_vector(3 downto 0)
		);
end entity Inst_Decode;

architecture Decode of Inst_Decode is
begin
	process(clk)
	begin
		if (not stall)
			op_code <= inst(inst_width-1 downto inst_width -4);
		end if;
	end process;
end architecture Decode;