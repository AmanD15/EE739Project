library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;

package ID_Stage is
component Inst_Decode is
port (stall : in std_logic;
		pc : in std_logic_vector(15 downto 0);
		clk : in std_logic;
		inst : in std_logic_vector(15 downto 0);
		op_code : out std_logic_vector(3 downto 0);
		r_a : out std_logic_vector(2 downto 0);
		r_b : out std_logic_vector(2 downto 0);
		r_c : out std_logic_vector(2 downto 0);
		enable_b : out std_logic;
		enable_c : out std_logic;
		imm : out std_logic_vector(8 downto 0);
		cz : out std_logic_vector(1 downto 0);
		pc_out : out std_logic_vector(15 downto 0)
		);
end component Inst_Decode;
end package ID_Stage;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;

entity Inst_Decode is
port (stall : in std_logic;
		pc : in std_logic_vector(15 downto 0);
		clk : in std_logic;
		inst : in std_logic_vector(15 downto 0);
		op_code : out std_logic_vector(3 downto 0);
		r_a : out std_logic_vector(2 downto 0);
		r_b : out std_logic_vector(2 downto 0);
		r_c : out std_logic_vector(2 downto 0);
		imm : out std_logic_vector(8 downto 0);
		cz : out std_logic_vector(1 downto 0);
		pc_out : out std_logic_vector(15 downto 0);
		jmp : out std_logic
		);
end entity Inst_Decode;

architecture Decode of Inst_Decode is
begin
	process(clk)
	variable op : std_logic_vector(3 downto 0);
	begin
		if (rising_edge(clk)) then
			if (stall='0') then
				op_code <= inst(15 downto 12);
				r_a <= inst(11 downto 9);
				r_b <= inst(8 downto 6);
				r_c <= inst(5 downto 3);
				imm <= inst(8 downto 0);
				op := inst(15 downto 12);
				cz <= inst(1 downto 0);
				pc_out <= pc;
			end if;
		end if;
	end process;
end architecture Decode;