library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package my_pkg is

function int2slv ( int : integer; size : integer) return std_logic_vector;

component memory is 
	generic (addr_width : natural := 16;
				data_width : natural := 16);
	port (clk : in std_logic; 
			addr : in std_logic_vector(addr_width-1 downto 0);
			data : in std_logic_vector(data_width-1 downto 0);
			readWrite : in std_logic;
			output : out std_logic_vector(data_width-1 downto 0));
end component memory;
end package my_pkg;


package body my_pkg is

function int2slv ( int : integer; size : integer)
return std_logic_vector is
begin
return std_logic_vector(to_unsigned(int,size));
end function;
end package body my_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is 
	generic (addr_width : natural := 16;
				data_width : natural := 16);
	port (clk : in std_logic;
			addr : in std_logic_vector(addr_width-1 downto 0);
			data : in std_logic_vector(data_width-1 downto 0);
			readWrite : in std_logic;
			output : out std_logic_vector(data_width-1 downto 0));
end entity memory;

architecture arch of memory is
type RAM is array(0 to 2**addr_width-1 ) of std_logic_vector(data_width-1 downto 0);
signal storage : RAM := (others => (others => '0'));
begin
	process(clk)
	begin
		if (falling_edge(clk)) then
			if (readWrite = '1') then
				storage(to_integer(unsigned(addr))) <= data;
			else
				output <= storage(to_integer(unsigned(addr)));
			end if;
		end if;
	end process;
end architecture arch;