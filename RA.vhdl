library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;


entity register_read is 
generic (inst_width : integer := 16;data_width : integer := 16);
port (stall : in std_logic;
		clk : in std_logic;
		pc : in std_logic;
		r_a : in std_logic_vector(2 downto 0);
		r_b : in std_logic_vector(2 downto 0);
		r_c : in std_logic_vector(2 downto 0);
		imm : in std_logic_vector(8 downto 0);
		op_code : in std_logic_vector(3 downto 0);
		cz : in std_logic_vector(1 downto 0);

		--regwrite : in std_logic; 
		data_write : in std_logic_vector(data_width-1 downto 0) ;

		data_a : out std_logic_vector(data_width-1 downto 0);
		data_b : out std_logic_vector(data_width-1 downto 0);
		data_c : out std_logic_vector(data_width-1 downto 0);
		cz_out : out std_logic_vector(1 downto 0);		
		r_co : out std_logic_vector(2 downto 0);
		
		addr_5 : in std_logic_vector(2 downto 0);
		data_5 : in std_logic_vector(data_width-1 downto 0);
		enable_5 : in std_logic
		-- other alu cotrol/ further stage signals to be added
		);
end entity register_read;

architecture Reg of register_read is
type RF is array(7 downto 0) of std_logic_vector(data_width-1 downto 0);
signal RFile : RF := (others => (others => '0'));

begin
	process(clk)
	variable temp_a : std_logic_vector(data_width-1 downto 0) := RFile(to_integer(unsigned(r_a)));
	variable temp_b : std_logic_vector(data_width-1 downto 0) := RFile(to_integer(unsigned(r_b)));
	variable data_a_var, data_b_var, data_c_var : std_logic_vector(data_width-1 downto 0);
	variable r_co_var : std_logic_vector(2 downto 0) := r_c;
	variable imm_o : std_logic_vector(data_width-1 downto 0) := std_logic_vector(resize(signed(imm(5 downto 0)),16));
	begin
	if (rising_edge(clk)) then
		if (stall = '0') then
			if (enable_5 = '1') then
				RFile(to_integer(unsigned(addr_5))) <= data_5;
			end if;

			case op_code is 
				-- 9 bit imm zero pad or SW/LW
				when "1001"|"1011"|"0101"|"0100" => 	imm_o := (data_width-1 downto imm'length => '0') & imm;
				-- 6 bit signed extension
				when "0000"|"1000" => imm_o := std_logic_vector(resize(signed(imm(5 downto 0)), 16));
				when "0011" => imm_o := imm & (data_width-1 downto imm'length => '0') ; 
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
	    		-- when "0101" =>
	    		when "1000" =>
					data_a_var := temp_a;
					data_b_var := temp_b;
					data_c_var := imm_o;
				when "1001" =>
	    			data_b_var := imm_o;
	    			r_co_var := r_a;
	    		when "1010" =>
	    			data_b_var := temp_b ;
	    			r_co_var := r_a ;
	    		when "1011" =>
					data_a_var := r_a;
	    			data_b_var := imm_o; 
			end case;
					
			data_a <= data_a_var;
			data_b <= data_b_var;
			data_c <= data_c_var;
			r_co <= r_co_var;
			cz_out <= cz;
		end if;
	end if ;
	end process;
end architecture Reg;