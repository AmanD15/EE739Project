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
		num_inputs : in std_logic_vector(3 downto 0);
		data_in : in std_logic_vector(16*8-1 downto 0);
		data_out : out std_logic_vector(16*8-1 downto 0);
		); 
end entity Mem_Access;

architecture Mem_Arch of Mem_Access is

begin
	process
	variable num_acc : integer := integer(unsigned(num_inputs)+1);
	begin
		if (readWrite = '1') then
			data_out(127 downto ((8-num_acc)*16)) <= (others => '0');
		end if;
	end process;
end architecture Mem_Arch;
		
