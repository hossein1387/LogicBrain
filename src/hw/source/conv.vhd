-------------------------------------------------------------------------------
-- Title : Memory Instruction
-- Project : LogicBrain
-------------------------------------------------------------------------------
-- File : conv.vhd
-- Author : Nathan Heraief
-- Created : 25 nov 2018
-- Last update: 25 nov 2018
-------------------------------------------------------------------------------
-- Description:
-- Load Bias of 1st Layer from Software into RAM
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
-------------------------------------
ENTITY conv IS
	PORT (
		-- Required by CPU
		clk       : IN std_logic; -- CPU system clock (always required)
		reset     : IN std_logic; -- CPU master asynchronous active high reset (always required)
		clk_en    : IN std_logic; -- Clock-qualifier (always required)
		start     : IN std_logic; -- Active high signal used to specify that inputs are valid (always required)
		done      : OUT std_logic; -- Active high signal used to notify the CPU that result is valid (required for variable multi-cycle)
		dataa     : IN std_logic_vector(31 DOWNTO 0); -- Operand A (always required)
		datab     : IN std_logic_vector(31 DOWNTO 0); -- Operand B (optional)
		result    : OUT std_logic_vector(31 DOWNTO 0); -- result (always required)
		--Custom I/O
		start_o   : OUT STD_LOGIC;
		valid_i 	: IN STD_LOGIC;
		output_i  : IN std_logic_vector(9 DOWNTO 0)
	);
END ENTITY conv;

ARCHITECTURE conv_arch OF conv IS

	TYPE STATE IS (INIT, FINISHED);

	SIGNAL state_s   : STATE   := INIT;
	signal busy_s 	 : STD_LOGIC;

BEGIN
	result <= (31 downto output_i'length => '0') & output_i;
	PROCESS (clk, reset)
	BEGIN
		IF (reset = '1') THEN
			busy_s <= '0';
			state_s <= INIT;
			done <= '0';
		ELSIF (rising_edge(clk)) THEN
			CASE state_s IS
				WHEN INIT =>
					done <= '0';
					IF (start = '1' AND busy_s = '0') THEN
						busy_s    <= '1';
						state_s   <= INIT;
					ELSIF (busy_s = '1' AND valid_i ='1') THEN
            state_s <= FINISHED;
					END IF;
				WHEN FINISHED =>
					done <= '1';
					busy_s <= '0';
					state_s <= INIT;
			END CASE;
		END IF;
	END PROCESS;
END ARCHITECTURE conv_arch;
