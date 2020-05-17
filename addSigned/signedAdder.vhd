library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package subprograms_pkg is
	procedure signed_adder (
		a, b: in std_logic_vector; 		 --inputs
		ci: in std_logic;						 --carry in
		signal sum: out std_logic_vector; --sum
		signal co: out std_logic);			 --carry out
end package;

package body subprograms_pkg is

	procedure signed_adder (a, b: in std_logic_vector; ci: in std_logic;
		signal sum: out std_logic_vector; signal co: out std_logic) is
		
		variable sum_sig: signed(sum'length downto 0); --signed sum
		
	begin
	
		-- Sign extension, conversion to signed, addition
		sum_sig := signed(a(a'left) & a) + signed(b) + ('0' & ci);
		
		-- Conversion to slv and get the carry out
		sum <= std_logic_vector(sum_sig(sum'length-1 downto 0));
		co <= a(a'left) xor b(b'left) xor sum_sig(sum_sig'left);
	
	end procedure;

end package body;