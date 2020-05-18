library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.subprograms_pkg.all;

entity freqMeter is

	generic (
				
		-- the frequency of the on board clock
		F_CLK: natural := 50000000;
		
		-- the saturation value of the counter in the frequency meter
		CNT_SAT_VAL: natural := 9999);

	port (
	 
		-- user input to select frequency of signal generator
		-- the output of the signal generator acts as the input pulse
		-- 	train for the frequency meter
		signal sig1, sig2, sig3, sig4: in std_logic;
		  
		-- the system clock
		signal clk: in std_logic;
		  
		-- the counter overflow flag
		signal oflow: out std_logic;
		  
		-- the digits to display on the SSDs
		signal dig1, dig2, dig3, dig4: out std_logic_vector(6 downto 0));
		  
end entity;


architecture freqMeterWithSync of freqMeter is

	-- the output of the pulse synchronizer
	signal syncPulses: std_logic;
	
	-- the number of bits required to represent the clock frequency
	constant BTR_F_CLK: natural := integer(ceil(log2(real(F_CLK))));
	
	-- the write/clear signal
	signal write: std_logic;
	
   -- asynchronous pulses whose frequency we are trying to measure
	signal asyncPulses: std_logic;
	
	-- intermediate between counter and output to ssd's
	signal interPulseCnt: natural range 0 to CNT_SAT_VAL;

begin

	-- generate the input pulse train based on the user input via
	-- 	sig1, sig2, sig3, and sig4
	genPulses: entity work.funcGenerator
		port map (clk, sig1, sig2, sig3, sig4, asyncPulses);

	-- synchronize the input pulse train
	doPulseSync: entity work.oneShotPulseCapt
		port map (clk, asyncPulses, syncPulses);
	
	
	-- generate the write/clear signal
	-- based on the problem specification, we want the write/clear signal
	--		to be low for 1 second and high for 1 clock period
	process(clk)
	
		variable count: unsigned(BTR_F_CLK downto 0);
		
	begin
	
		if rising_edge(clk) then
			-- if the count was just reset or the program just started, pull write high
			if count = 0 then
				write <= '1';
				count := count + 1;
			else
				-- if one second has not elapsed, pull write low and continue counting 
				if count /= F_CLK then
					count := count + 1;
				-- if one second has elapsed, reset the count
				else
					count := (others => '0');
				end if;
				-- in any case, pull write low
				write <= '0';
			end if;
		end if;
		
	end process;
	
	
	-- count the input pulses
	process(clk)
	
		-- counts number of input pulses
		variable pulseCount: natural range 0 to CNT_SAT_VAL;
		
	begin
	
		-- the clock signal is active low to avoid metastability between clk
		-- 	and the enable signal for the counter, syncPulses
		if falling_edge(clk) then
			-- reset the count
			if write = '1' then
				pulseCount := 0;
				oflow <= '0';
			-- if the counter is enabled and write/clear is not active, count!
			elsif syncPulses = '1' then
				-- if the counter is saturated, do not modify the count and
				-- 	set the overflow flag
				if pulseCount = CNT_SAT_VAL then
					oflow <= '1';
				-- otherwise increment the counter
				else
					pulseCount := pulseCount + 1;
				end if;				
			end if;			
		end if;
		
		-- set the intermediate pulse count to the current pulse count
		interPulseCnt <= pulseCount;
		
	end process;

	-- now register the outputs to the ssd with the digit intermediates
	-- this happens about once every second, and ensures that the frequency displayed
	-- 	on the SSD'd is in Hz
	process (write)
	begin
	
		if rising_edge(write) then
			dig1 <= slv_to_ssd(std_logic_vector(to_unsigned((interPulseCnt mod 10), 4)));
			dig2 <= slv_to_ssd(std_logic_vector(to_unsigned(((interPulseCnt mod 100) / 10), 4)));
			dig3 <= slv_to_ssd(std_logic_vector(to_unsigned(((interPulseCnt mod 1000) / 100), 4)));
			dig4 <= slv_to_ssd(std_logic_vector(to_unsigned(((interPulseCnt mod 10000) / 1000), 4)));		
		end if;
		
	end process;

end architecture;