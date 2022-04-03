library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;

entity Execute is
generic (inst_width : integer := 16);
port (stall : in std_logic;
		clk : in std_logic;
		pc : in std_logic_vector(15 downto 0);
		op_code : in std_logic_vector(3 downto 0);
		cz : in std_logic_vector(1 downto 0);
		data_a : in std_logic_vector(7 downto 0);
		data_b : in std_logic_vector(7 downto 0);
		data_out : out std_logic_vector(7 downto 0);
		pc_out : out std_logic_vector(15 downto 0)
		);
end entity Execute;

architecture Exec of Execute is
begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (stall='1') then
				pc_out <= pc;
				case op_code is
					when 0000 => data_out <= std_logic_vector(signed(pc)+signed(imm));
					when others => null;
				end case;
			end if;
		end if;
	end process;
end architecture Exec;