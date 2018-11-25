-------------------------------------------------------------------------------
-- Title : Memory Instruction
-- Project : LogicBrain
-------------------------------------------------------------------------------
-- File : loadThirdLayerWeight.vhd
-- Author : Heraief Nathan
-- Created : 22 nov 2018
-- Last update: 22 nov 2018
-------------------------------------------------------------------------------
-- Description:
-- Load Weight of 3rd Layer from Software into RAM
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
-------------------------------------
ENTITY loadThirdLayerWeight IS
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
		data_o    : OUT std_logic_vector(127 DOWNTO 0);
		address_o : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		wren      : OUT STD_LOGIC
	);
END ENTITY loadThirdLayerWeight;

ARCHITECTURE loadThirdLayerWeight_arch OF loadThirdLayerWeight IS

	TYPE STATE IS (INIT, LOAD, STORE, FINISHED);

	SIGNAL data_s    : STD_LOGIC_VECTOR (127 DOWNTO 0);
	SIGNAL weight_s	 : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL increment_s : std_logic_vector(10 DOWNTO 0);
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
			weight_s <= (OTHERS =>'0');
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
						weight_s    <= dataa(1 DOWNTO 0);
						increment_s <= datab(10 DOWNTO 0);
						busy_s      <= '1';
						state_s        <= INIT;
					ELSIF (busy_s = '1') THEN
						counter_s <= 10;
						IF (increment_s = "0000001001") THEN -- increment_s = 9
								state_s <= LOAD;
								ELSE
								state_s <= STORE;
						END IF;
					END IF;
				WHEN STORE =>
					data_s <= weight_s & data_s(127 DOWNTO 2);
					state_s        <= FINISHED;
				WHEN LOAD =>
					counter_s <= counter_s - 1;
					wren      <= '1';
					data_o    <= data_s;
					address_o <= std_logic_vector(to_unsigned(10 - counter_s, address_o'length));
					state_s <= FINISHED;
				WHEN FINISHED =>
					done <= '1';
					busy_s <= '0';
					wren <= '0';
					state_s <= INIT;
			END CASE;
		END IF;
	END PROCESS;
END ARCHITECTURE loadThirdLayerWeight_arch;

