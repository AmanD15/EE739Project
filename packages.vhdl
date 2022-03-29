library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package my_pkg is
type INSTRUCTION is (
ADD,ANDL,ORL,XORL,
ADDI,ANDI,ORI,XORI,
NOTL,INC,NEG,LUI,
SLLI,SRLI,SLLV,SRLV,
JMP,BEQZ,BNEZ,
LOAD,STORE);

type STATES is (
FETCH1,FETCH2,FETCH3,HALT,

ADD1,ADD2,
ANDL1,ANDL2,
ORL1,ORL2,
XORL1,XORL2,

NOTL1,NEG1,INC1,LUI1,

ADDI1,ANDI1,ORI1,XORI1,
SLLI1,SRLI1,SLLV1,SLLV2,SRLV1,SRLV2,

JMP1,BEQZ1,BNEZ1,

LOAD1,LOAD2,STORE1,STORE2
);

function int2slv ( int : integer; size : integer) return std_logic_vector;

component memory is 
	generic (addr_width : natural := 8;
				data_width : natural := 16);
	port ( addr : in std_logic_vector(addr_width-1 downto 0);
			data : in std_logic_vector(data_width-1 downto 0);
			readWrite : in std_logic;
			output : out std_logic_vector(data_width-1 downto 0));
end component memory;
end package my_pkg;


package body my_pkg is

function int2slv ( int : integer; size : integer)
return std_logic_vector is
begin
return std_logic_vector(to_unsigned(int,size));
end function;
end package body my_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is 
	generic (addr_width : natural := 8;
				data_width : natural := 16);
	port ( addr : in std_logic_vector(addr_width-1 downto 0);
			data : in std_logic_vector(data_width-1 downto 0);
			readWrite : in std_logic;
			output : out std_logic_vector(data_width-1 downto 0));
end entity memory;

architecture arch of memory is
type RAM is array(2**addr_width-1 downto 0) of std_logic_vector(data_width-1 downto 0);
signal storage : RAM := (others => (others => '0'));
begin

end architecture arch;