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
		data_out : out std_logic_vector(16*8-1 downto 0);
		wb_in : in std_logic_vector(2 downto 0);
		wb_enable : in std_logic;
		pc_in : in std_logic_vector(15 downto 0);
		pc_next : out std_logic_vector(15 downto 0)
		); 
end entity Mem_Access;

architecture Mem_Arch of Mem_Access is
type my_mem is array(0 to 1023) of std_logic_vector(15 downto 0);
signal data_memory : my_mem;
begin
	process(clk)
	variable num_acc : integer := to_integer(unsigned(num_inputs));
	variable start : integer := to_integer(unsigned(start_address));
	variable last : integer := start + num_acc+1;
	begin
		if (rising_edge(clk)) then
			if (stall = '0') then
				if (readWrite = '1') then
					for I in 0 to num_acc loop
						data_out((I*16+15) downto (I*16)) <= data_memory(I);
					end loop;
				else
					for I in 0 to num_acc loop
						data_memory(I) <= data_in((I*16+15) downto (I*16));
					end loop;
				end if;
				pc_next <= pc_in;
			end if;
		end if;
	end process;
end architecture Mem_Arch;
		
