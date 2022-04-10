library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_pkg.all;

entity TB_VSCPU is
	generic( addr_width : natural := 16;
				data_width : natural := 16
			);
end entity TB_VSCPU;

architecture arch of TB_VSCPU is
	signal clk,reset,start,write_flag : std_logic := '0';
	signal addr : std_logic_vector(addr_width-1 downto 0);
	signal data : std_logic_vector(data_width-1 downto 0);
	
	procedure next_input 
		(signal clk: in std_logic;
		signal write_flag: out std_logic;
		signal addr_out,data_out : out std_logic_vector;
		data_in: in std_logic_vector;
		i : inout integer) is
	begin
		wait until (clk='1');
		write_flag <= '1';
		addr_out <= int2slv(i,addr_out'length);
		data_out <= data_in;
		wait until (clk='0');
		write_flag <= '0';
		i := i + 1;
	end procedure;
	
begin
	dut : entity work.VSCPU(arch) 
		generic map (addr_width => addr_width, data_width => data_width)
		port map(clk,reset,start,write_flag,addr,data);
	
	process
	variable num_funcs : integer := 10;
	variable data_to_write : std_logic_vector(data_width-1 downto 0);
	variable i : integer := 0;
	
	begin
	wait until clk='0';
	reset <= '1';
	wait until clk='1';
	reset <= '0';

----	add
	data_to_write := "0000"&"000"&"010"&"000101";
	next_input(clk,write_flag,addr,data,data_to_write,i);
	
	data_to_write := "0000"&"001"&"000"&"001101";
	next_input(clk,write_flag,addr,data,data_to_write,i);
	
	data_to_write := "0000"&"100"&"001"&"001011";
	next_input(clk,write_flag,addr,data,data_to_write,i);
	
	data_to_write := "0000"&"011"&"000"&"101101";
	next_input(clk,write_flag,addr,data,data_to_write,i);
	
	data_to_write := "0000"&"010"&"010"&"000111";
	next_input(clk,write_flag,addr,data,data_to_write,i);
	
	data_to_write := "0000"&"101"&"000"&"111101";
	next_input(clk,write_flag,addr,data,data_to_write,i);

----	srlv
--	data_to_write := int2slv(INSTRUCTION'pos(SRLV),data_width-addr_width) & int2slv(num_funcs+1,addr_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
----	and
--	data_to_write := int2slv(INSTRUCTION'pos(ANDL),data_width-addr_width) & int2slv(num_funcs+2,addr_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
----	sllv
--	data_to_write := int2slv(INSTRUCTION'pos(SLLV),data_width-addr_width) & int2slv(num_funcs+1,addr_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
---- notl
--	data_to_write := int2slv(INSTRUCTION'pos(NOTL),data_width-addr_width) & int2slv(0,addr_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
----	bnez
--	data_to_write := int2slv(INSTRUCTION'pos(BNEZ),data_width-addr_width) & int2slv(15,addr_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
----	or
--	data_to_write := int2slv(INSTRUCTION'pos(ORL),data_width-addr_width) & int2slv(num_funcs+3,addr_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
----	xor
--	data_to_write := int2slv(INSTRUCTION'pos(XORL),data_width-addr_width) & int2slv(num_funcs+4,addr_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
----	addi
--	data_to_write := int2slv(INSTRUCTION'pos(ADDI),data_width-addr_width) & int2slv(10,addr_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
----	ori
--	data_to_write := int2slv(INSTRUCTION'pos(ORI),data_width-addr_width) & int2slv(16#34#,addr_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
----	store
--	data_to_write := int2slv(INSTRUCTION'pos(STORE),data_width-addr_width) & int2slv(num_funcs+4,addr_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
----	srli
--	data_to_write := int2slv(INSTRUCTION'pos(SRLI),data_width-addr_width) & int2slv(4,addr_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
----	jmp
--	data_to_write := int2slv(INSTRUCTION'pos(JMP),data_width-addr_width) & int2slv(1,addr_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
----	neg
--	data_to_write := int2slv(INSTRUCTION'pos(NEG),data_width-addr_width) & int2slv(0,addr_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
----	xori
--	data_to_write := int2slv(INSTRUCTION'pos(XORI),data_width-addr_width) & int2slv(16#FF#,addr_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
----	slli
--	data_to_write := int2slv(INSTRUCTION'pos(SLLI),data_width-addr_width) & int2slv(5,addr_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
----	inc
--	data_to_write := int2slv(INSTRUCTION'pos(INC),data_width-addr_width) & int2slv(0,addr_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
----	lui
--	data_to_write := int2slv(INSTRUCTION'pos(LUI),data_width-addr_width) & int2slv(16#AB#,addr_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
----	andi
--	data_to_write := int2slv(INSTRUCTION'pos(ANDI),data_width-addr_width) & int2slv(0,addr_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
----	beqz
--	data_to_write := int2slv(INSTRUCTION'pos(BEQZ),data_width-addr_width) & int2slv(8,addr_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
--
----	memory
--	data_to_write := int2slv(16#03#,data_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
--
--	data_to_write := int2slv(16#37#,data_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
--	
--	data_to_write := int2slv(16#4B#,data_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
--	
--	data_to_write := int2slv(16#5D#,data_width);
--	next_input(clk,write_flag,addr,data,data_to_write,i);
	
	start <= '1';
	wait until clk='1';
	start <= '0';
	wait;
	end process;
	
	process
	begin
		for i in 1 to 500 loop
			clk <= not clk;
			wait for 1ns;
		end loop;
		wait;
	end process;
	
end architecture arch;
