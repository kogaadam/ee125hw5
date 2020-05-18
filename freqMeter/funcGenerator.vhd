library ieee;
use ieee.std_logic_1164.all;

entity funcGenerator is
	generic (
		F_CLK: natural := 50000000);

	port (
		-- input clock
		clk: in std_logic;
	 
		-- user inputs to select the signal to output
		sig1, sig2, sig3, sig4: in std_logic;
		
		-- the output of the function generator
		sigOut: out std_logic);
		  
end entity;


architecture waveformGen of funcGenerator is
	
	-- used to generate pulses in particular ranges
	signal countRange: natural range 0 to 50000000;

begin

	-- sets the frequency of pulse generation
	countRange <= (F_CLK/2) when sig1 = '1' else
					  (F_CLK/3333) when sig2 = '1' else
					  (F_CLK/9996) when sig3 = '1' else
					  (F_CLK/10100) when sig4 = '1' else
					  (F_CLK/4);  

	process(clk)
		variable count: natural range 0 to 25000000;
	begin
		if rising_edge(clk) then
			if count = 0 then
				sigOut <= '1';
				count := count + 1;
			else
				count := count + 1;
				if count = countRange then
					count := 0;
				end if;
				sigOut <= '0';
			end if;		
		end if;
	end process;
end architecture;