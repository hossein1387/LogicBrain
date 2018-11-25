-------------------------------------------------------------------------------
-- Title : Memory Instruction
-- Project : LogicBrain
-------------------------------------------------------------------------------
-- File : loadFirstLayerBias.vhd
-- Author : Nathan Heraief
-- Created : 22 nov 2018
-- Last update: 22 nov 2018
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
ENTITY loadFirstLayerBias IS
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
		data_o    : OUT std_logic_vector(1 DOWNTO 0);
		address_o : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
		wren      : OUT STD_LOGIC
	);
END ENTITY loadFirstLayerBias;

ARCHITECTURE loadFirstLayerBias_arch OF loadFirstLayerBias IS

	TYPE STATE IS (INIT, LOAD, FINISHED);

	SIGNAL bias_s	 : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL address_s : std_logic_vector(9 DOWNTO 0);
	SIGNAL state_s   : STATE   := INIT;
	SIGNAL counter_s : INTEGER := 0;
	signal busy_s 	 : STD_LOGIC;

BEGIN
	result <= datab;
	PROCESS (clk, reset)
	BEGIN
		IF (reset = '1') THEN
			busy_s <= '0';
			bias_s <= (OTHERS =>'0');
         address_s <= (OTHERS =>'0');             
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
						bias_s    <= dataa(1 DOWNTO 0);
						address_s <= datab(9 DOWNTO 0);
						busy_s    <= '1';
						state_s   <= INIT;
					ELSIF (busy_s = '1') THEN
                        state_s <= LOAD;
					END IF;
				WHEN LOAD =>
					wren      <= '1';
					data_o    <= bias_s;
					address_o <= address_s;
					state_s <= FINISHED;
				WHEN FINISHED =>
					done <= '1';
					busy_s <= '0';
					wren <= '0';
					state_s <= INIT;
			END CASE;
		END IF;
	END PROCESS;
END ARCHITECTURE loadFirstLayerBias_arch;

