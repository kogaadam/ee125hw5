library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter is
	generic (
		NUM_COEF: natural := 11;  --number of filter coefficients
		NUM_BITS: natural := 4);   --number of bits in input and coefficients
		--EXTRA_BITS: natural := 4); --calculated by the user as ceil(log2(NUM_COEF))
	port (
		clk, rst, load, run: in std_logic; --load is used for when we are loading the
													  --    coefficients into their shift register
													  --run is used for when the filter is being
													  --    calculated using the input
		x: in std_logic_vector(NUM_BITS-1 downto 0);
		coeff: in std_logic_vector(NUM_BITS-1 downto 0);
		y: out std_logic_vector(2*NUM_BITS-1 downto 0));
end entity;

architecture prog_coeff_chain_type of fir_filter is

	-- Internal signals
	type signed_array is array (natural range <>) of signed;
	signal coeff_array: signed_array(0 to NUM_COEF-1)(NUM_BITS-1 downto 0);
	signal input_shift_reg: signed_array(1 to NUM_COEF-1)(NUM_BITS-1 downto 0);
	signal prod: signed_array(0 to NUM_COEF-1)(2*NUM_BITS-1 downto 0);
	signal sum: signed_array(0 to NUM_COEF-1)(2*NUM_BITS-1 downto 0);

begin

	-- Coefficients shift register
	process(clk, rst)
		
	begin
		if load then
			if rst then
				coeff_array <= (others => (others => '0'));
			elsif rising_edge(clk) then
				coeff_array <= signed(coeff) & 
									coeff_array(0 to NUM_COEF-2);
			end if;
		end if;
		
	end process;
	
	-- Input shift register
	process(clk, rst)
	
	begin
		if run then
			if rst then
				input_shift_reg <= (others => (others => '0'));
			elsif rising_edge(clk) then
				input_shift_reg <= signed(x) & input_shift_reg(1 to NUM_COEF-2);
			end if;
		end if;
		
	end process;
	
	-- Multipliers:
	prod(0) <= coeff_array(0) * signed(x);
	mult: for i in 1 to NUM_COEF-1 generate
		prod(i) <= coeff_array(i) * input_shift_reg(i);
	end generate;
	
	-- Adder array:
	sum(0) <= resize(prod(0), 2*NUM_BITS);
	adder: for i in 1 to NUM_COEF-1 generate
		sum(i) <= sum(i-1) + prod(i);
	end generate;
	
	y <= std_logic_vector(sum(NUM_COEF-1));

end architecture;