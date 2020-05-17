library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.subprograms_pkg.all;

entity signedAdderTest is
	generic (
		NUM_BITS: integer := 4);
	port(
		a, b: in std_logic_vector(NUM_BITS-1 downto 0); --inputs
		ci: in std_logic;											--carry in
		sum: out std_logic_vector(NUM_BITS-1 downto 0); --sum
		co: out std_logic);										--carry out
end entity;

architecture functional of signedAdderTest is

begin

	signed_adder(a, b, ci, sum, co); --call the adder procedure
	
end architecture;
	