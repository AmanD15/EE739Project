library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;

entity Inst_Fetch is
generic (inst_width : integer := 16);
port (stall : in std_logic;
		clk : in std_logic;
		pc : in std_logic;
		inst : out std_logic_vector(inst_width-1 downto 0)
		);
end entity Inst_Fetch;

architecture Fetch of Inst_Fetch is
begin
	process(clk)
	begin
		if (rising_edge(clk))
			if (not stall)
				inst <= MEMORY(pc);
			end if;
		end if;
	end process;
end architecture Fetch;