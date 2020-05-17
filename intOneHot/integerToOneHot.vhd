library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity integerToOneHot is
	generic (
		BITS_IN: natural := 3;
		BITS_OUT: natural := 7); --calculated by the user as (2^BITS_IN)-1
	port (
		inp: in std_logic_vector(BITS_IN-1 downto 0);
		outp: out std_logic_vector(BITS_OUT-1 downto 0));
end entity;


architecture functional of integerToOneHot is
	
	-- Conversion function - take in an integer and output its one-hot representation
	function integer_to_onehot (input: natural) return std_logic_vector is
		variable result: std_logic_vector(BITS_OUT-1 downto 0); --result of conversion
	begin
	
		-- Initialize the result
		result := (others => '0');
		
		-- If the input is non zero then set the appropriate output bit
		if input /= 0 then
			result(input - 1) := '1';
		end if;
	
		return result;
	
	end function integer_to_onehot;

begin

	-- Call the conversion function
	outp <= integer_to_onehot(to_integer(unsigned(inp)));

end architecture;