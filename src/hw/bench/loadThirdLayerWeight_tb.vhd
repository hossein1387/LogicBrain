-------------------------------------------------------------------------------
-- Title : Memory Instruction
-- Project : LogicBrain
-------------------------------------------------------------------------------
-- File : loadThirdLayerWeight_tb.vhd
-- Author : Heraief Nathan
-- Created : 22 nov 2018
-- Last update: 22 nov 2018
-------------------------------------------------------------------------------
-- Description:
-- Test Bench of loadSecondLayerWeight
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
-------------------------------------

ENTITY loadThirdLayerWeight_tb IS
END ENTITY loadThirdLayerWeight_tb;


ARCHITECTURE loadThirdLayerWeight_tb_arch OF loadThirdLayerWeight_tb IS
COMPONENT loadThirdLayerWeight
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
END COMPONENT;

constant TIME_DELTA : time := 6 ns;
SIGNAL clk_s : std_logic := '0';
SIGNAL reset_s : std_logic ;
SIGNAL clk_en_s : std_logic ;
SIGNAL start_s : std_logic ;
SIGNAL done_s : std_logic ;
SIGNAL dataa_s : std_logic_vector(31 DOWNTO 0) ;
SIGNAL datab_s : std_logic_vector(31 DOWNTO 0) ;
SIGNAL data_o_s    : std_logic_vector(127 DOWNTO 0);
SIGNAL address_o_s : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL wren_s : STD_LOGIC;

BEGIN
    DUT : loadThirdLayerWeight
    PORT MAP(
        clk => clk_s,
        reset => reset_s,
        clk_en => clk_en_s,
        start => start_s,
        done => done_s,
        dataa => dataa_s,
        datab => datab_s,
        data_o => data_o_s,
        address_o => address_o_s,
        wren => wren_s
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
-- First Weight sent
-------------------------------------------------------------------------------
      dataa_s <= "00000000000000000000000000000001";
      datab_s <= "00000000000000000000000000000000";
      wait for TIME_DELTA;
      start_s <= '1';
		wait for 2*TIME_DELTA;
		start_s <= '0';
		wait for 8*TIME_DELTA;
-------------------------------------------------------------------------------
-- Second Weight sent
-------------------------------------------------------------------------------
      dataa_s <= "00000000000000000000000000000011";
      datab_s <= "00000000000000000000000000000001";
      wait for TIME_DELTA;
      start_s <= '1';
		wait for 2*TIME_DELTA;
		start_s <= '0';
		wait for 8*TIME_DELTA;
-------------------------------------------------------------------------------
-- Last Weight sent
-------------------------------------------------------------------------------
      dataa_s <= "11111111111111111111111111111100";
      datab_s <= "00000000000000000000000000000001";
      wait for TIME_DELTA;
      start_s <= '1';
		wait for 2*TIME_DELTA;
		start_s <= '0';
		wait for 8*TIME_DELTA;
-------------------------------------------------------------------------------
-- Weight sent to RAM
-------------------------------------------------------------------------------
      wait;
    end process do_check_out_result;

END ARCHITECTURE loadThirdLayerWeight_tb_arch;

