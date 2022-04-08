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
		reg_bits : in std_logic_vector(7 downto 0);
		mem_bits : in std_logic_vector(7 downto 0)
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
		reg_bits : in std_logic_vector(7 downto 0);
		mem_bits : in std_logic_vector(7 downto 0)
		); 
end entity Mem_Access;

architecture Mem_Arch of Mem_Access is
begin
	Data_Mem : memory_8_port port map (clk => clk, addr => start_address,
							data => data_in,
							readWrite => mem_bits,
							output => data_out,
							loadStore => '1'
							);
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (stall = '0') then
			end if;
		end if;
	end process;
end architecture Mem_Arch;
		
