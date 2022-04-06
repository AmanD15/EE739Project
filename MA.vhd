library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;

package MA_stage is
component Mem_Access is
port (stall : in std_logic;
		clk : in std_logic;
		-- 1 denotes write
		readWrite : in std_logic;
		start_address : in std_logic_vector(15 downto 0);
		data_in : in std_logic_vector(127 downto 0);
		data_out : out std_logic_vector(127 downto 0);
		wb_in : in std_logic_vector(2 downto 0);
		wb_enable : in std_logic;
		reg_bits : in std_logic_vector(0 to 7)
		); 
end component Mem_Access;
end package MA_stage;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;

entity Mem_Access is
port (stall : in std_logic;
		clk : in std_logic;
		-- 1 denotes write
		readWrite : in std_logic;
		start_address : in std_logic_vector(15 downto 0);
		data_in : in std_logic_vector(127 downto 0);
		data_out : out std_logic_vector(127 downto 0);
		wb_in : in std_logic_vector(2 downto 0);
		wb_enable : in std_logic;
		reg_bits : in std_logic_vector(0 to 7)
		); 
end entity Mem_Access;

architecture Mem_Arch of Mem_Access is
type my_mem is array(0 to 1023) of std_logic_vector(15 downto 0);
signal data_memory : my_mem;
begin
	process(clk)
	variable start : integer;
	variable J : integer;
	begin
		start := to_integer(unsigned(start_address));
		J := 0;
		if (rising_edge(clk)) then
			if (stall = '0') then
				for I in 0 to 7 loop
					if (reg_bits(I) = '1') then
						if (readWrite = '1') then
							data_out((J*16+15) downto (J*16)) <= data_memory(start+J);
						else
							data_memory(start+J) <= data_in((J*16+15) downto (J*16));
						end if;
						J := J + 1;
					end if;
				end loop;
			end if;
		end if;
	end process;
end architecture Mem_Arch;
		
