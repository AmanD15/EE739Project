library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;

entity VSCPU is
	generic( addr_width : natural := 8;
				data_width : natural := 16;
				pc_start : natural := 1
			);
	port( clk : in std_logic;
			reset : in std_logic;
			start : in std_logic;
			write_flag : in std_logic;
			addr : in std_logic_vector(addr_width-1 downto 0);
			data : in std_logic_vector(data_width-1 downto 0)
			);
end entity VSCPU;

architecture arch of VSCPU is

type RAM is array(2**addr_width-1 downto 0) of std_logic_vector(data_width-1 downto 0);
signal memory : RAM := (others => (others => '0'));

signal state, state_ns : STATES;

signal IR, IR_ns : INSTRUCTION;
signal acc, acc_ns, DR, DR_ns : std_logic_vector(data_width-1 downto 0) := (others => '0');
signal pc, pc_ns: std_logic_vector(addr_width-1 downto 0);

signal read_from_bus : std_logic := '0';

signal address, AR, AR_ns : std_logic_vector(addr_width-1 downto 0) := (others => '0');
signal data_rd : std_logic_vector(data_width-1 downto 0);
signal write_store : std_logic := '0';

begin

--Load the data to read into the bus
address <= addr when state=HALT else AR;
data_rd <= memory(to_integer(unsigned(address))) when (read_from_bus='1' and write_flag='0') else (others => 'Z');


--Update program counter, accumulator and other registers
	process(clk)
	begin
		if rising_edge(clk) then
			if (reset = '1') then
				acc <= (others =>'0');
				pc <= std_logic_vector(to_unsigned(pc_start,addr_width));
				AR <= (others =>'0');
				IR <= INSTRUCTION'left;
				DR <= (others =>'0');				
			else
				pc <= pc_ns;
				acc <= acc_ns;
				AR <= AR_ns;
				IR <= IR_ns;
				DR <= DR_ns;
			end if;
		end if;	
		
	end process;
	
--Update memory when write_flag is high or the CPU is reset
	process(clk)
	begin
		if rising_edge(clk) then
			if (reset = '1') then
				memory <= (others => (others => '0'));
			elsif (write_flag='1' and read_from_bus='0') then
				memory(to_integer(unsigned(address))) <= data;
			elsif (write_store='1' and read_from_bus='0') then
				memory(to_integer(unsigned(address))) <= DR;
			end if;		
		end if;
	end process;
	
--Update state at clock edge
	process(clk)
	begin
		if rising_edge(clk) then
			if (reset = '1') then
				state <= HALT;
			elsif (start = '1') then
				state <= FETCH1;
			else
				state <= state_ns;
			end if;			
		end if;
	end process;
	
--Next state logic. 
--Need to update next state only when cureent state changes
	process(state)
	begin
		case state is
			when HALT => state_ns <= HALT;
			when FETCH1 => state_ns <= FETCH2;
			when FETCH2 => state_ns <= FETCH3;
			when FETCH3 => case IR is
				when ADD => state_ns <= ADD1;
				when ANDL => state_ns <= ANDL1;
				when ORL => state_ns <= ORL1;
				when XORL => state_ns <= XORL1;
				
				when INC => state_ns <= INC1;
				when NOTL => state_ns <= NOTL1;
				when NEG => state_ns <= NEG1;
				when LUI => state_ns <= LUI1;
				
				when ADDI => state_ns <= ADDI1;
				when ANDI => state_ns <= ANDI1;
				when ORI => state_ns <= ORI1;
				when XORI => state_ns <= XORI1;
				
				when SLLI => state_ns <= SLLI1;
				when SRLI => state_ns <= SRLI1;
				when SLLV => state_ns <= SLLV1;
				when SRLV => state_ns <= SRLV1;
				
				when JMP => state_ns <= JMP1;
				when BEQZ => state_ns <= BEQZ1;
				when BNEZ => state_ns <= BNEZ1;
				
				
				when LOAD => state_ns <= LOAD1;
				when STORE => state_ns <= STORE1;
				when others => null;
			end case;
			
			when ADD1 => state_ns <= ADD2;
			when ANDL1 => state_ns <= ANDL2;
			when ORL1 => state_ns <= ORL2;
			when XORL1 => state_ns <= XORL2;
			when LOAD1 => state_ns <= LOAD2;
			when STORE1 => state_ns <= STORE2;
			when SLLV1 => state_ns <= SLLV2;
			when SRLV1 => state_ns <= SRLV2;
			
			when ADD2 | ANDL2 | ORL2 | XORL2 | ADDI1 | ANDI1 | ORI1 | XORI1 | JMP1 | INC1 |
				BEQZ1 | BNEZ1 | LOAD2 | STORE2 | SLLI1 | SRLI1 | SRLV2 | SLLV2 | NOTL1 | NEG1 | LUI1
			=> state_ns <= FETCH1;
			when others => null;
		end case;
	end process;
	
--	Update next values for registers
	process(pc, IR, AR, DR, data_rd, acc, state)
	variable IR_var : INSTRUCTION;
	variable acc_var, DR_var: std_logic_vector(data_width-1 downto 0);
	variable pc_var, AR_var: std_logic_vector(addr_width-1 downto 0);
	variable imm_zeros : std_logic_vector(data_width-1 downto data_width-addr_width) := (others => '0');
	variable read_from_bus_var : std_logic;
	variable write_store_var : std_logic;
	begin
		AR_var := AR;
		pc_var := pc;
		IR_var := IR;
		acc_var := acc;
		DR_var := DR;
		read_from_bus_var := '0';
		write_store_var := '0';
		
		case state is
			when FETCH1 => AR_var := pc;
			when FETCH2 => 
				pc_var := std_logic_vector(unsigned(pc)+1);
				DR_var := data_rd;
				read_from_bus_var := '1';
				IR_var := INSTRUCTION'val(to_integer(unsigned(DR_var(data_width-1 downto data_width-addr_width))));
				AR_var := DR_var(addr_width-1 downto 0);
			when ADD1 | ANDL1 | ORL1 | XORL1 | LOAD1 | SLLV1 | SRLV1 => 
			DR_var := data_rd;
			read_from_bus_var := '1';
			
			when ADD2 => acc_var := std_logic_vector(unsigned(acc)+unsigned(DR));
			when ANDL2 => acc_var := acc and DR;
			when ORL2 => acc_var := acc or DR;
			when XORL2 => acc_var := acc xor DR;
			
			when ADDI1 => acc_var := std_logic_vector(unsigned(acc)+unsigned(AR));
			when ANDI1 => acc_var := acc and imm_zeros & AR;
			when ORI1 => acc_var := acc or imm_zeros & AR;
			when XORI1 => acc_var := acc xor imm_zeros & AR;
			
			when NOTL1 => acc_var := not acc;
			when NEG1 => acc_var := std_logic_vector(unsigned(not acc) + 1);
			when INC1 => acc_var := std_logic_vector(unsigned(acc)+1);
			when LUI1 => acc_var := AR & imm_zeros;
			
			when SLLI1 => acc_var := std_logic_vector(unsigned(acc) sll to_integer(unsigned(AR)));
			when SRLI1 => acc_var := std_logic_vector(unsigned(acc) srl to_integer(unsigned(AR)));
			when SLLV2 => acc_var := std_logic_vector(unsigned(acc) sll to_integer(unsigned(DR)));
			when SRLV2 => acc_var := std_logic_vector(unsigned(acc) srl to_integer(unsigned(DR)));
			
			when BEQZ1 => if (unsigned(acc) = to_unsigned(0,acc'length)) then
					pc_var := DR(addr_width-1 downto 0);
				end if;
				
			when BNEZ1 => if (unsigned(acc) /= to_unsigned(0,acc'length)) then
					pc_var := DR(addr_width-1 downto 0);
				end if;
			
			when JMP1 => pc_var := DR(addr_width-1 downto 0);
			
			when LOAD2 => acc_var := DR;
			when STORE1 => DR_var := acc;
			when STORE2 => write_store_var := '1';
			when others => null;
		end case;
		
		AR_ns <= AR_var;
		pc_ns <= pc_var;
		IR_ns <= IR_var;
		acc_ns <= acc_var;
		DR_ns <= DR_var;
		read_from_bus <= read_from_bus_var;
		write_store <= write_store_var;
		
	end process;
	
end architecture arch;
