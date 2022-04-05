	library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;

type RF is array(7 downto 0) of std_logic_vector(data_width-1 downto 0);

entity register_read is
generic (inst_width : integer := 16;data_width : integer := 16);
port (stall : in std_logic;
		clk : in std_logic;
		pc : in std_logic;
		r_a : in std_logic_vector(2 downto 0);
		r_b : in std_logic_vector(2 downto 0);
		r_c : in std_logic_vector(2 downto 0);
		imm : in std_logic_vector(8 downto 0);
		enable_b : in std_logic;
		enale_c : in std_logic;
		regwrite : in std_logic; 
		data_write : in std_logic_vector(data_width-1 downto 0) ;
		data_a : out std_logic_vector(data_width-1 downto 0);
		data_b : out std_logic_vector(data_width-1 downto 0);
		r_co : out std_logic_vector(2 downto 0);
		addr_5 : in 
		data_5 :
		enable_5 : 
		-- other alu cotrol/ further stage signals to be added
		);
end entity register_read;

architecture Reg of register_read is
signal RFile : RF := (others => (others => '0'));
signal imm_o : std_logic_vector(data_width-1 downto 0) ;
signal temp_b : std_logic_vector(data_width-1 downto 0) ;

begin
	process(clk)
	begin
		if (not stall) then
			if (not regwrite) then
				if (SW or LW) then
					data_a <= RFile(to_integer(unsigned(r_b)));
				else 
					data_a <= RFile(to_integer(unsigned(r_a)));
				end if;
				temp_b <= RFile(to_integer(unsigned(r_b))) when (enable_b='1' else (others => 'Z');
				r_co <= r_c ;
			else 
				RFile(to_integer(unsigned(r_c))) <= data_write;
			end if;
			if (not i_ext) then 
				-- i_ext true when opcode is 0000 or 0100 or 0101 or 1000 
				imm_o <= (31 downto imm'length => '0') & imm;
			else
				imm_o <= std_logic_vector(resize(signed(imm(5 downto 0)), 16));
			end if;

			if (ALUSrc) then:
				-- true when reg_B
				data_b <= temp_b ;
			else
				data_b <= imm_o ;
			end if;
		end if;
	end process;
end architecture Reg;