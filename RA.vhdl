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
		enable_b : in std_logic;
		enale_c : in std_logic;
		--regwrite : in std_logic; 
		data_write : in std_logic_vector(data_width-1 downto 0) ;


		data_a : out std_logic_vector(data_width-1 downto 0);
		data_b : out std_logic_vector(data_width-1 downto 0);
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
signal imm_o : std_logic_vector(data_width-1 downto 0) ;
signal temp_b : std_logic_vector(data_width-1 downto 0) ;

begin
	process(clk)
	begin
	if (rising_edge(clk)) then
		if (not stall) then
			if (enable_5) then
				RFile(to_integer(unsigned(addr_5))) <= data_5;
			end if;
			if (op_code(3 downto 2) = "01" or op_code(3 downto 2) = "010") then
				-- LW/SW
				data_a <= RFile(to_integer(unsigned(r_b)));
			else 
				data_a <= RFile(to_integer(unsigned(r_a)));
			end if;
			temp_b <= RFile(to_integer(unsigned(r_b))) 
			-- when (enable_b='1' else (others => 'Z');
			--r_co <= r_c ;


			case op_code is 
				-- 9 bit imm zero pad or SW/LW
				when "1001"|"1011"|"0101"|"0100" => 	imm_o <= (data_width-1 downto imm'length => '0') & imm;
				-- 6 bit signed extension
				when "0000"|"1000" => imm_o <= std_logic_vector(resize(signed(imm(5 downto 0)), 16));
				when "0011" => imm_o <= imm & (data_width-1 downto imm'length => '0') ; 
			end case;
			
			if (cz="11" and op_code="0001") then
				-- ADL
				temp_b <= temp_b(data_width-1 downto 1) & (0 downto 0 => '0')
			end if;
			
			case op_code is 
				when "0001"|"0010" => 
					data_b <= temp_b ;
					r_co <= r_c ;
				when "0000" =>
					data_b <= imm_o ;
					r_co <= temp_b ;
			    when "0011"
			    	data_b<=imm_o;
			    	r_co <= r_a; 
		    	when "0100" =>
		    		data_b <= imm_o;
		    		r_co <= r_a;
	    		-- when "0101" =>
	    		when "1000" | "1001" =>
	    			data_b <= imm_o;
	    			r_co <= r_a;
	    		when "1010" =>
	    			data_b <= temp_b ;
	    			r_co <= r_a ;
	    		when "1011" <= 
	    			data_b <= imm_o; 


			end case;

			
			if (enable_b) then:
				-- true when reg_B
				data_b <= temp_b ;
			else
				data_b <= imm_o ;
			end if;
		end if;
	end if ;
	end process;
end architecture Reg;