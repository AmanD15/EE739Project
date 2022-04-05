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
		num_inputs : in std_logic_vector(2 downto 0);
		data_in : in std_logic_vector(16*8-1 downto 0);
		data_out : out std_logic_vector(16*8-1 downto 0)
		); 
end entity Mem_Access;

architecture Mem_Arch of Mem_Access is
type my_mem is array(0 to 1023) of std_logic_vector(15 downto 0);
signal memory : my_mem;
begin
	process(clk)
	variable num_acc : integer := integer(unsigned(num_inputs)+1);
	variable start : integer := integer(unsigned(start_address));
	variable last : integer := start + num_acc;
	begin
		if (rising_edge(clk)) then
			if (readWrite = '1') then
				data_out(127 downto ((8-num_acc)*16)) <= memory(start to last);
			else
				memory(start to last) <= data_in(127 downto ((8-num_acc)*16));
			end if;
		end if;
	end process;
end architecture Mem_Arch;
		
