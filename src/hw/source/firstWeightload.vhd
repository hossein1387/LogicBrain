-------------------------------------------------------------------------------
-- Title : Memory Instruction
-- Project : LogicBrain
-------------------------------------------------------------------------------
-- File : loadFirstLayerWeight.vhd
-- Author : Nathan Heraief
-- Created : 22 nov 2018
-- Last update: 22 nov 2018
-------------------------------------------------------------------------------
-- Description:
-- Load Weight of 1st Layer from Software into RAM
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
-------------------------------------
ENTITY loadFirstLayerWeight IS
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
		data_o    : OUT std_logic_vector(511 DOWNTO 0);
		address_o : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
		wren      : OUT STD_LOGIC
	);
END ENTITY loadFirstLayerWeight;

ARCHITECTURE loadFirstLayerWeight_arch OF loadFirstLayerWeight IS

    -- TYPE STATE IS (INIT, LOAD, STORE, FINISHED);
    type state_T is (INIT, LOAD, SHIFT, FINISHED);
    -- Process signals
    signal current_s, next_s: state_T;

    -- Other signals
    signal done_p, done_f: std_logic;
    signal load_en: std_logic;
    signal wren_p, wren_f: std_logic;
    signal data_o_p, data_o_f: std_logic_vector(511 downto 0);

BEGIN
    done <= done_p;
    load_en <= datab(10);
    address_o <= datab(9 downto 0);
    wren <= wren_p;
    result <= data_o_p(31 downto 0);
    data_o <= data_o_p;

    synchrone_ASM: process(clk, reset)
    begin
        if(reset = '1') then
            data_o_p <= (others => '0');
            current_s <= INIT;
            done_p <= '0';
            wren_p <= '0';
        elsif(clk'event and clk = '1') then
            data_o_p <= data_o_f;
            current_s <= next_s;
            done_p <= done_f;
            wren_p <= wren_f;
        end if;
    end process;

    asynchrone_ASM: process(current_s, load_en, data_o_p, start)
    begin
        case current_s is
            when INIT => if(start = '1') then
                            if(load_en = '1') then
                                next_s <= LOAD;
                                wren_f <= '1';
                            else
                                next_s <= SHIFT;
                                wren_f <= '0';
                             end if;
                            data_o_f <= dataa(1 DOWNTO 0) & data_o_p(511 DOWNTO 2);
                            done_f <= '0';
                         else
                             next_s <= INIT;
                             wren_f <= '0';
                             data_o_f <= data_o_p;
                             done_f <= '0';
                         end if;

            when LOAD => next_s <= FINISHED;
                         wren_f <= '0';
                         data_o_f <= data_o_p;
                         done_f <= '1';

            when SHIFT => next_s <= FINISHED;
                          wren_f <= '0';
                          data_o_f <= data_o_p;
                          done_f <= '1';

            when others => next_s <= INIT;
                             wren_f <= '0';
                             data_o_f <= data_o_p;
                             done_f <= '0';
        end case;
    end process;
END ARCHITECTURE loadFirstLayerWeight_arch;
