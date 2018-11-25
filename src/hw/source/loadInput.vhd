-------------------------------------------------------------------------------
-- Title : Memory Instruction
-- Project : LogicBrain
-------------------------------------------------------------------------------
-- File : loadInput.vhd
-- Author : Nathan Heraief
-- Created : 22 nov 2018
-- Last update: 22 nov 2018
-------------------------------------------------------------------------------
-- Description:
-- Load Input from Software into RAM
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
-------------------------------------
ENTITY loadInput IS
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
		data_o    : OUT std_logic_vector(59 DOWNTO 0);
		address_o : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren      : OUT STD_LOGIC
	);
END ENTITY loadInput;

ARCHITECTURE loadInput_arch OF loadInput IS

	TYPE STATE IS (INIT, LOAD, STORE, FINISHED);

	SIGNAL data_s    : STD_LOGIC_VECTOR (59 DOWNTO 0);
	SIGNAL weight_s	 : STD_LOGIC;
	SIGNAL increment_s : std_logic_vector(7 DOWNTO 0);
	SIGNAL state_s   : STATE   := INIT;
	SIGNAL counter_s : INTEGER := 0;
	signal busy_s 	 : STD_LOGIC;

BEGIN
	result <= datab;
	PROCESS (clk, reset)
	BEGIN
		IF (reset = '1') THEN
			busy_s <= '0';
			data_s <= (OTHERS =>'0');
			weight_s <= '0';
			increment_s <= (OTHERS =>'0');			
			state_s <= INIT;
			done <= '0';
			data_o <= (OTHERS =>'0');
			address_o <= (OTHERS =>'0');
			wren <= '0';		
		ELSIF (rising_edge(clk)) THEN
			CASE state_s IS
				WHEN INIT =>
					done <= '0';
					IF (start = '1' AND busy_s = '0') THEN
						weight_s    <= dataa(0);
						increment_s <= datab(7 DOWNTO 0);
						busy_s      <= '1';
						state_s        <= INIT;
					ELSIF (busy_s = '1') THEN
						counter_s <= 60;
						IF (increment_s = "11000111") THEN
								state_s <= LOAD;
								ELSE
								state_s <= STORE;
						END IF;
					END IF;
				WHEN STORE =>
					data_s <= weight_s & data_s(59 DOWNTO 1);
					state_s        <= FINISHED;
				WHEN LOAD =>
					counter_s <= counter_s - 1;
					wren      <= '1';
					data_o    <= data_s;
					address_o <= std_logic_vector(to_unsigned(60 - counter_s, address_o'length));
					state_s <= FINISHED;
				WHEN FINISHED =>
					done <= '1';
					busy_s <= '0';
					wren <= '0';
					state_s <= INIT;
			END CASE;
		END IF;
	END PROCESS;
END ARCHITECTURE loadInput_arch;

