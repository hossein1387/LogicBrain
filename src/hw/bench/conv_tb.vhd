-------------------------------------------------------------------------------
-- Title : Memory Instruction
-- Project : LogicBrain
-------------------------------------------------------------------------------
-- File : conv_tb_tb.vhd
-- Author : Nathan Heraief
-- Created : 25 nov 2018
-- Last update: 25 nov 2018
-------------------------------------------------------------------------------
-- Description:
-- test bench of conv_tb.vhd
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
-------------------------------------
ENTITY conv_tb IS
END ENTITY conv_tb;

ARCHITECTURE conv_tb_arch OF conv_tb IS


COMPONENT conv
PORT (
	-- Required by CPU
	clk       : IN std_logic; -- CPU system clock (always required)
	reset     : IN std_logic; -- CPU master asynchronous active high reset (always required)
	clk_en    : IN std_logic; -- Clock-qualifier (always required)
	start     : IN std_logic; -- Active high signal used to specify that inputs are valid (always required)
	done      : OUT std_logic; -- Active high signal used to notify the CPU that result is valid (required for variable multi-cycle)
	dataa     : IN  std_logic_vector(31 DOWNTO 0); -- Operand A (always required)
	datab     : IN  std_logic_vector(31 DOWNTO 0); -- Operand B (optional)
	result    : OUT std_logic_vector(31 DOWNTO 0); -- result (always required)
	--Custom I/O
	start_o   : OUT STD_LOGIC;
	valid_i 	: IN  STD_LOGIC;
	output_i  : IN  std_logic_vector(9 DOWNTO 0)
);
END COMPONENT;

constant TIME_DELTA : time := 6 ns;
SIGNAL clk_s : std_logic := '0';
SIGNAL reset_s : std_logic ;
SIGNAL clk_en_s : std_logic ;
SIGNAL start_s : std_logic ;
SIGNAL done_s : std_logic ;
SIGNAL dataa_s : std_logic_vector(31 DOWNTO 0) ;
SIGNAL datab_s : std_logic_vector(31 DOWNTO 0) ;
SIGNAL start_o_s    : STD_LOGIC;
SIGNAL valid_i_s : STD_LOGIC;
SIGNAL output_i_s : STD_LOGIC_VECTOR (9 DOWNTO 0);



	BEGIN
	    DUT : conv
	    PORT MAP(
	        clk => clk_s,
	        reset => reset_s,
	        clk_en => clk_en_s,
	        start => start_s,
	        done => done_s,
	        dataa => dataa_s,
	        datab => datab_s,
					start_o => start_o_s,
					valid_i => valid_i_s,
					output_i => output_i_s
	    );
	    clk_s <= not clk_s after TIME_DELTA;

	    do_check_out_result:process
	      BEGIN
			wait for TIME_DELTA;
			reset_s <= '1';
			wait for TIME_DELTA;
			reset_s <= '0';
			wait for TIME_DELTA;
	-------------------------------------------------------------------------------
	-- First Bias sent
	-------------------------------------------------------------------------------
	      dataa_s <= "00000000000000000000000000000000";
	      datab_s <= "00000000000000000000000000000000";
				output_i_s <="0000000000";
	      wait for TIME_DELTA;
	      start_s <= '1';
				wait for 2*TIME_DELTA;
				start_s <= '0';
				wait for 8*TIME_DELTA;
	-------------------------------------------------------------------------------
	-- Second Bias sent
	-------------------------------------------------------------------------------
	      dataa_s <= "00000000000000000000000000000011";
	      datab_s <= "00000000000000000000000000000001";
				output_i_s <="1010101010";
	      wait for TIME_DELTA;
	      start_s <= '1';
			wait for 2*TIME_DELTA;
			start_s <= '0';
			wait for 8*TIME_DELTA;
	-------------------------------------------------------------------------------
	-- Last Bias sent
	-------------------------------------------------------------------------------
	      dataa_s <= "11111111111111111111111111111100";
	      datab_s <= "00000000000000000000000000000010";
				output_i_s <="1111111111";
				valid_i_s <= '1';
	      wait for TIME_DELTA;
	      start_s <= '1';
			wait for 2*TIME_DELTA;
			start_s <= '0';
			valid_i_s <= '0';
			wait for 8*TIME_DELTA;

	      wait;
	    end process do_check_out_result;

END ARCHITECTURE conv_tb_arch;
