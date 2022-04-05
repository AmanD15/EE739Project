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
		data_a : in std_logic_vector(15 downto 0);
		data_b : in std_logic_vector(15 downto 0);
		data_out : out std_logic_vector(15 downto 0);
		write_back_add : out std_logic_vector(15 downto 0);
		wb_enable : out std_logic;
		pc_next : out std_logic_vector(15 downto 0)
		);
end entity Execute;

architecture Exec of Execute is
signal c_flag : std_logic := '0';
signal z_flag : std_logic := '0';
begin
	process(clk)
	
	variable data_add : std_logic_vector(16 downto 0);
	variable data_add2 : std_logic_vector(16 downto 0);
	variable data_nand : std_logic_vector(16 downto 0);
	variable z_var : std_logic;
	variable z_var2 : std_logic;
	variable pc_var : std_logic_vector(15 downto 0) := std_logic_vector(unsigned(pc) + 1);
	
	begin

	data_add := std_logic_vector(signed(data_a)+signed(data_b));
		data_add := std_logic_vector(signed(data_a)+signed(data_b sll 1));
		data_nand := (data_a nand data_b);
		if (data_add = (others => '0')) then z_var := '1'; else z_var := '0'; end if;
		if (data_nand = (others => '0')) then z_var2 := '1'; else z_var2 := '0'; end if;
	
	if (rising_edge(clk)) then
			if (stall='0') then
								
				case op_code is
					-- add immediate
					when "0000" =>
						z_flag <= z_var;
						data_out <= data_add(15 downto 0);
						c_flag <= data_add(16);
					
					-- add
					when "0001" => case cz is
						when "00" => 
							z_flag <= z_var;
							c_flag <= data_add(16);
							data_out <= data_add(15 downto 0);
						when "01" => 
							if (z_flag='1') then 
								data_out <= data_add(15 downto 0);
								z_flag <= z_var;
								c_flag <= data_add(16);
							end if;
						when "10" =>
							if (c_flag='1') then
								data_out <= data_add(15 downto 0);
								z_flag <= z_var;
								c_flag <= data_add(16);
							end if;
						when "11" =>
							data_out <= data_add2(15 downto 0);
							if (data_add2 = (others => '0')) then z_flag <= '1'; else z_flag <= '0'; end if;
							c_flag <= data_add2(16);
					end case;
					
					-- nand
					when "0010" =>
						case cz is
							when "00" => data_out <= data_nand; z_flag <= z_var2;
							when "01" => if (z_flag='1') then data_out <= data_nand; z_flag <= z_var2; end if;
							when "10" => if (c_flag='1') then data_out <= data_nand; z_flag <= z_var2; end if;
							when others => null;
						end case;
						
					--lhi
					when "0011" => data_out <= (imm9 & "0000000");
					
					--lw , sw
					when "0100" | "0101" => data_out <= data_add;
					
					--beq
					
					-- jal
					when "1001" => pc_var := std_logic_vector(unsigned(pc)+unsigned(data_b));
					
					-- jlr
					when "1010" => pc_var := data_b;
					
					--jri
					when "1011" =>	pc_var := data_add;
					when others => null;
				end case;
				
				
				pc_next <= pc_var;
			end if;
		end if;
	end process;
end architecture Exec;