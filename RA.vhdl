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
		data_out : out std_logic_vector(127 downto 0);
		cz_out : out std_logic_vector(1 downto 0);		
		r_co : out std_logic_vector(2 downto 0);
		op_out : out std_logic_vector(3 downto 0);
		pc_out : out std_logic_vector(15 downto 0);
		mem_address_out : out std_logic_vector(15 downto 0);
		reg_updates : out std_logic_vector(7 downto 0);
		mem_updates : out std_logic_vector(7 downto 0);
		mem_sr : out std_logic;
		
		--forwarding
		data_in_alu : in std_logic_vector(15 downto 0) ;
		wb_in_alu : in std_logic_vector(2 downto 0);
		
		-- write_back
		enable_5 : in std_logic ;
		data_5 : in std_logic_vector(127 downto 0);
		addr_5 : in std_logic_vector(2 downto 0);
		reg_addr_5 : in std_logic_vector(7 downto 0)
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
		data_out : out std_logic_vector(127 downto 0);
		cz_out : out std_logic_vector(1 downto 0);		
		r_co : out std_logic_vector(2 downto 0);
		op_out : out std_logic_vector(3 downto 0);
		pc_out : out std_logic_vector(15 downto 0);
		mem_address_out : out std_logic_vector(15 downto 0);
		reg_updates : out std_logic_vector(7 downto 0);
		mem_updates : out std_logic_vector(7 downto 0);
		mem_sr : out std_logic;
		
		--forwarding
		data_in_alu : in std_logic_vector(15 downto 0) ;
		wb_in_alu : in std_logic_vector(2 downto 0);
		
		-- write_back
		enable_5 : in std_logic ;
		data_5 : in std_logic_vector(127 downto 0);
		addr_5 : in std_logic_vector(2 downto 0);
		reg_addr_5 : in std_logic_vector(7 downto 0)
		);
end entity register_read;

architecture Reg of register_read is
type RF is array(7 downto 0) of std_logic_vector(data_width-1 downto 0);
signal RFile : RF := (others => (others => '0'));

begin
	process(clk)
	variable temp_a : std_logic_vector(data_width-1 downto 0);
	variable temp_b : std_logic_vector(data_width-1 downto 0);
	variable data_out_var : std_logic_vector(127 downto 0);
	variable r_co_var : std_logic_vector(2 downto 0);
	variable imm_o : std_logic_vector(data_width-1 downto 0);
	variable num_acc_var, num_wb_var : integer;
	variable mem_updates_var : std_logic_vector(7 downto 0);
	variable mem_sr_var : std_logic;
	variable data_wb_var : RF;
	begin
	if (rising_edge(clk)) then
		if(stall_w = '0') then 
			if (enable_5='1') then
				RFile(to_integer(unsigned(addr_5))) <= data_5(15 downto 0);
			elsif (reg_addr_5 /= "00000000") then
				num_wb_var := 0;
				data_wb_var(7) := data_5(127 downto 112);
				data_wb_var(6) := data_5(111 downto 96);
				data_wb_var(5) := data_5(95 downto 80);
				data_wb_var(4) := data_5(79 downto 64);
				data_wb_var(3) := data_5(63 downto 48);
				data_wb_var(2) := data_5(47 downto 32);
				data_wb_var(1) := data_5(31 downto 16);
				data_wb_var(0) := data_5(15 downto 0);
				for i in 0 to 7 loop
					if (reg_addr_5(i) = '1') then
						RFile(i) <= data_wb_var(num_wb_var);
						num_wb_var := num_wb_var + 1;
					end if;
				end loop;
			end if;
		end if;
		if (stall_r = '0') then
			num_acc_var := 0;
			temp_a := RFile(to_integer(unsigned(r_a)));
			temp_b := RFile(to_integer(unsigned(r_b)));
			imm_o(15 downto 6) := (others => imm(5));
			imm_o(5 downto 0) := imm(5 downto 0);
			r_co_var := r_c;
			mem_updates_var := "00000000";
			mem_sr_var := '0';
			case op_code is 
				-- 9 bit imm zero pad or SW/LW
				when "1001"|"1011"|"0101"|"0100" => imm_o := "0000000" & imm;
				when "0011" => imm_o := imm & (data_width-1 downto imm'length => '0') ;
				when others => null;
			end case;
						
			case op_code is 
				-- add/nand
				when "0001"|"0010" => 
					data_out_var(15 downto 0) := temp_a;
					data_out_var(31 downto 16) := temp_b;
				
				-- addi
				when "0000" =>
					data_out_var(15 downto 0) := temp_a;
					data_out_var(31 downto 16) := imm_o ;
					r_co_var := r_b;
			   
				-- lhi
				when "0011" =>
			    	data_out_var(31 downto 16) := imm_o;
			    	r_co_var := r_a; 
		    	
				-- lw
				when "0100" =>
					data_out_var(15 downto 0) := temp_b;
		    		data_out_var(31 downto 16) := imm_o;
		    		r_co_var := r_a;
				
				-- sw
				when "0101" =>
					data_out_var(15 downto 0) := temp_b;
		    		data_out_var(31 downto 16) := imm_o;
		    		data_out_var(47 downto 32) := temp_a;
					mem_sr_var := '1';
					
				-- beq
	    		when "1000" =>
					data_out_var(15 downto 0) := temp_a;
					data_out_var(31 downto 16) := temp_b;
					data_out_var(47 downto 32) := imm_o;
				
				-- jal
				when "1001" =>
	    			data_out_var(47 downto 32) := imm_o;
	    			r_co_var := r_a;
	    		
				-- jlr
				when "1010" =>
	    			data_out_var(31 downto 16) := temp_b ;
	    			r_co_var := r_a ;
	    		
				-- jri
				when "1011" =>
					data_out_var(15 downto 0) := temp_a;
	    			data_out_var(31 downto 16) := imm_o;
				
				-- lm
				when "1100" =>
				mem_address_out <= temp_a;
				reg_updates <= imm(7 downto 0);
				for i in 7 downto 0 loop
					if (imm(7-i) = '1') then
						mem_updates_var(num_acc_var) := '1';
						num_acc_var := num_acc_var + 1;
					end if;
				end loop;
				
				-- sm
				when "1101" =>
					mem_address_out <= temp_a;
					reg_updates <= imm(7 downto 0);
					mem_sr_var := '1';
					for i in 7 downto 0 loop
						if (imm(7-i) = '1') then
							data_out_var(num_acc_var*16+15 downto num_acc_var*16) := RFile(i);
							num_acc_var := num_acc_var + 1;
							mem_updates_var(num_acc_var) := '1';
						end if;
					end loop;
				
				-- la
				when "1110" =>
				mem_address_out <= temp_a;
				reg_updates <= "11111110";
				mem_updates_var := "01111111";
				
				-- sa
				when "1111" =>
				mem_address_out <= temp_a;
				reg_updates <= "11111110";
				mem_updates_var := "01111111";
				mem_sr_var := '1';
				data_out_var := ("0000000000000000" & RFile(6) & RFile(5) & RFile(4) & RFile(3) & RFile(2) & RFile(1) & RFile(0));
				
				when others => null;
			end case;
			
			-- forwarding from alu
--			if (r_a = wb_in_alu) then
--				data_out_var(15 downto 0) := data_in_alu;
--			end if;
--			if (r_b = wb_in_alu) then
--				data_out_var(31 downto 16) := data_in_alu;
--			end if;				
				
			data_out <= data_out_var;
			r_co <= r_co_var;
			cz_out <= cz;
			op_out <= op_code;
			pc_out <= pc;
			mem_updates <= mem_updates_var;
			mem_sr <= mem_sr_var;
		end if;
	end if ;
	end process;
end architecture Reg;