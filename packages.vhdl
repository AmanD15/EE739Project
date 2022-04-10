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

component memory_8_port is 
	generic (addr_width : natural := 16;
				data_width : natural := 16);
	port (clk : in std_logic; 
			addr : in std_logic_vector(addr_width-1 downto 0);
			data : in std_logic_vector(8*data_width-1 downto 0);
			readWrite : in std_logic_vector(7 downto 0);
			loadStore : in std_logic;
			output : out std_logic_vector(8*data_width-1 downto 0));
end component memory_8_port;

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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory_8_port is 
	generic (addr_width : natural := 16;
				data_width : natural := 16);
	port (clk : in std_logic; 
			addr : in std_logic_vector(addr_width-1 downto 0);
			data : in std_logic_vector(8*data_width-1 downto 0);
			readWrite : in std_logic_vector(7 downto 0);
			loadStore : in std_logic;
			output : out std_logic_vector(8*data_width-1 downto 0));
end entity memory_8_port;

architecture arch of memory_8_port is
type RAM is array(natural range <> ) of std_logic_vector(data_width-1 downto 0);
signal storage : RAM(1023 downto 0) := (others => (others => '0'));
begin
	process(clk)
	variable a : RAM(7 downto 0);
	begin
		a(0) := data(15 downto 0);
		a(1) := data(31 downto 16);
		a(2) := data(47 downto 32);
		a(3) := data(63 downto 48);
		a(4) := data(79 downto 64);
		a(5) := data(95 downto 80);
		a(6) := data(111 downto 96);
		a(7) := data(127 downto 112);
		if (falling_edge(clk)) then
			if (readWrite /= "00000000") then
				if (loadStore = '1') then
					if (readWrite(0) = '1') then storage(to_integer(unsigned(addr))) <= a(0);
						if (readWrite(1) = '1') then storage(to_integer(unsigned(addr)+1)) <= a(1);
							if (readWrite(2) = '1') then storage(to_integer(unsigned(addr)+2)) <= a(2);
								if (readWrite(3) = '1') then storage(to_integer(unsigned(addr)+3)) <= a(3);
									if (readWrite(4) = '1') then storage(to_integer(unsigned(addr)+4)) <= a(4);
										if (readWrite(5) = '1') then storage(to_integer(unsigned(addr)+5)) <= a(5);
											if (readWrite(6) = '1') then storage(to_integer(unsigned(addr)+6)) <= a(6);
												if (readWrite(7) = '1') then storage(to_integer(unsigned(addr)+7)) <= a(7);
												end if;
											end if;
										end if;
									end if;
								end if;
							end if;
						end if;
					end if;
				else
					output(15 downto 0) <= storage(to_integer(unsigned(addr)));
					output(31 downto 16) <= storage(to_integer(unsigned(addr)+1));
					output(47 downto 32) <= storage(to_integer(unsigned(addr)+2));
					output(63 downto 48) <= storage(to_integer(unsigned(addr)+3));
					output(79 downto 64) <= storage(to_integer(unsigned(addr)+4));
					output(95 downto 80) <= storage(to_integer(unsigned(addr)+5));
					output(111 downto 96) <= storage(to_integer(unsigned(addr)+6));
					output(127 downto 112) <= storage(to_integer(unsigned(addr)+7));
				end if;
			end if;
		end if;
	end process;
end architecture arch;