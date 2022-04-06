library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;

package RA_stage is
component register_read is 
generic (inst_width : integer := 16;data_width : integer := 16);
port (stall_r : in std_logic;
		stall_w : in std_logic;
		clk : in std_logic;
		pc : in std_logic_vector(15 downto 0);
		r_a : in std_logic_vector(2 downto 0);
		r_b : in std_logic_vector(2 downto 0);
		r_c : in std_logic_vector(2 downto 0);
		imm : in std_logic_vector(8 downto 0);
		op_code : in std_logic_vector(3 downto 0);
		cz : in std_logic_vector(1 downto 0);
		enable_5 : in std_logic ;
		data_5 : in std_logic_vector(data_width-1 downto 0);
		addr_5 : in std_logic_vector(data_width-1 downto 0);
		data_a : out std_logic_vector(data_width-1 downto 0);
		data_b : out std_logic_vector(data_width-1 downto 0);
		data_c : out std_logic_vector(data_width-1 downto 0);
		cz_out : out std_logic_vector(1 downto 0);		
		r_co : out std_logic_vector(2 downto 0);
		op_out : out std_logic_vector(3 downto 0);
		pc_out : out std_logic_vector(15 downto 0)
		data_out : in std_logic_vector(15 downto 0) ;
		wb_out : in std_logic_vector(2 downto 0);
		);
end component register_read;
end package RA_stage;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;

entity register_read is 
generic (inst_width : integer := 16;data_width : integer := 16);
port (stall_r : in std_logic;
		stall_w : in std_logic;
		clk : in std_logic;
		pc : in std_logic_vector(15 downto 0);
		r_a : in std_logic_vector(2 downto 0);
		r_b : in std_logic_vector(2 downto 0);
		r_c : in std_logic_vector(2 downto 0);
		imm : in std_logic_vector(8 downto 0);
		op_code : in std_logic_vector(3 downto 0);
		cz : in std_logic_vector(1 downto 0);
		enable_5 : in std_logic ;
		data_5 : in std_logic_vector(data_width-1 downto 0);
		addr_5 : in std_logic_vector(data_width-1 downto 0);
		data_a : out std_logic_vector(15 downto 0);
		data_b : out std_logic_vector(15 downto 0);
		data_c : out std_logic_vector(15 downto 0);
		cz_out : out std_logic_vector(1 downto 0);		
		r_co : out std_logic_vector(2 downto 0);
		op_out : out std_logic_vector(3 downto 0);
		pc_out : out std_logic_vector(15 downto 0)
		data_out : in std_logic_vector(15 downto 0) ;
		wb_out : in std_logic_vector(2 downto 0);
		);
end entity register_read;

architecture Reg of register_read is
type RF is array(7 downto 0) of std_logic_vector(data_width-1 downto 0);
signal RFile : RF := (others => (others => '0'));

begin
	process(clk)
	variable temp_a : std_logic_vector(data_width-1 downto 0);
	variable temp_b : std_logic_vector(data_width-1 downto 0);
	variable data_a_var, data_b_var, data_c_var : std_logic_vector(data_width-1 downto 0);
	variable r_co_var : std_logic_vector(2 downto 0) := r_c;
	variable imm_o : std_logic_vector(data_width-1 downto 0);
	begin
	if (rising_edge(clk)) then
		if(stall_w = '0') then 
			if (enable_5='1') then
				RFile(to_integer(unsigned(addr_5))) <= data_5;
			end if;
		end if;
		if (stall_r = '0') then
			temp_a := RFile(to_integer(unsigned(r_a)));
			temp_b := RFile(to_integer(unsigned(r_b)));
			imm_o(15 downto 6) := (others => imm(5));
			imm_o(5 downto 0) := imm(5 downto 0);
			case op_code is 
				-- 9 bit imm zero pad or SW/LW
				when "1001"|"1011"|"0101"|"0100" => imm_o := "0000000" & imm;
				when "0011" => imm_o := imm & (data_width-1 downto imm'length => '0') ;
				when others => null;
			end case;
						
			case op_code is 
				when "0001"|"0010" => 
					data_a_var := temp_a;
					data_b_var := temp_b;
				when "0000" =>
					data_a_var := temp_a;
					data_b_var := imm_o ;
					r_co_var := r_b;
			    when "0011" =>
			    	data_b_var := imm_o;
			    	r_co_var := r_a; 
		    	when "0100" =>
					data_a_var := temp_b;
		    		data_b_var := imm_o;
		    		r_co_var := r_a;
				when "0101" =>
					data_a_var := temp_b;
		    		data_b_var := imm_o;
		    		r_co_var := r_a;
	    		when "1000" =>
					data_a_var := temp_a;
					data_b_var := temp_b;
					data_c_var := imm_o;
				when "1001" =>
	    			data_c_var := imm_o;
	    			r_co_var := r_a;
	    		when "1010" =>
	    			data_b_var := temp_b ;
	    			r_co_var := r_a ;
	    		when "1011" =>
					data_a_var := temp_a;
	    			data_b_var := imm_o;
				when others => null;
			end case;
			
			
			if (r_a = wb_out) then
				data_a_var := data_out;
			end if;
			if (r_b = wb_out) then
				data_b_var := data_out;
			end if;				
			-- from memory as well
				
			
			data_a <= data_a_var;
			data_b <= data_b_var;
			data_c <= data_c_var;
			r_co <= r_co_var;
			cz_out <= cz;
			op_out <= op_code;
			pc_out <= pc;
		end if;
	end if ;
	end process;
end architecture Reg;