library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity CalculatorUnit_tb is
end CalculatorUnit_tb;

architecture behave of CalculatorUnit_tb is
    
    signal SIG_clk:         STD_LOGIC;
    signal SIG_reset:       STD_LOGIC;
    signal SIG_start:       STD_LOGIC;
    signal SIG_W1:          STD_LOGIC_VECTOR(511 downto 0);
    signal SIG_I1:          STD_LOGIC_VECTOR(255 downto 0);
    signal SIG_b1:          STD_LOGIC_VECTOR(1 downto 0);
    signal SIG_W2:          STD_LOGIC_VECTOR(2047 downto 0);
    signal SIG_b2:          STD_LOGIC_VECTOR(1 downto 0);
    signal SIG_W3:          STD_LOGIC_VECTOR(127 downto 0);
    signal SIG_b3:          STD_LOGIC_VECTOR(1 downto 0);
    signal SIG_valid_1:     STD_LOGIC;
    signal SIG_valid_2:     STD_LOGIC;
    signal SIG_valid_3:     STD_LOGIC;
    signal SIG_calcOutput:  STD_LOGIC_VECTOR(9 downto 0);
    constant num_cycles : integer := 1100;

    component CalculatorUnit is
        port(
            clk:      in STD_LOGIC;
            reset:    in STD_LOGIC;
            start:    in STD_LOGIC;
            W1:       in STD_LOGIC_VECTOR(511 downto 0);
            I1:       in STD_LOGIC_VECTOR(255 downto 0);
            b1:       in STD_LOGIC_VECTOR(1 downto 0);
            W2:       in STD_LOGIC_VECTOR(2047 downto 0);
            b2:       in STD_LOGIC_VECTOR(1 downto 0);
            W3:       in STD_LOGIC_VECTOR(127 downto 0);
            b3:       in STD_LOGIC_VECTOR(1 downto 0);
            valid_1:  out STD_LOGIC;
            valid_2:  out STD_LOGIC;
            valid_3:  out STD_LOGIC;
            calcOutput: out STD_LOGIC_VECTOR(9 downto 0)
        );
    end component;

begin 

       CALCULATORUNIT1_INST: CalculatorUnit
       port map(
            clk         => SIG_clk,
            reset       => SIG_reset,
            start       => SIG_start,
            W1          => SIG_W1,
            I1          => SIG_I1,
            b1          => SIG_b1,
            W2          => SIG_W2,
            b2          => SIG_b2,
            W3          => SIG_W3,
            b3          => SIG_b3,
            valid_1     => SIG_valid_1,
            valid_2     => SIG_valid_2,
            valid_3     => SIG_valid_3,
            calcOutput  => SIG_calcOutput
       );

     TB : process is
     begin
         SIG_reset <= '1';
         SIG_clk <= '0';
         SIG_W1 <= (others => '0');
         SIG_I1 <= (others => '0');
         SIG_b1 <= (others => '0');
         SIG_W2 <= (others => '0');
         SIG_b2 <= (others => '0');
         SIG_W3 <= (others => '0');
         SIG_b3 <= (others => '0');
         SIG_start <= '0';
         wait for 10 ns;
         SIG_reset <= '0';
         SIG_clk <= '1';
         wait for 10 ns;
         SIG_clk <= '0';
         SIG_W1 <= x"55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555";
         SIG_I1 <= (others => '1'); --x"9999999999999999999999999999999900000000000000000000000000000000";
         SIG_b1 <= "00";
         --SIG_W2 <= "01010101010101010101" & (others => '0');
         SIG_W2 <= "01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101";
         SIG_b2 <= "00";
         --SIG_W3 <= "01010101010101010101" & (others => '0');
         SIG_W3 <= "01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101";
         SIG_b3 <= "00";
         SIG_start <= '1';
         wait for 10 ns;
         SIG_clk <= '1';
         wait for 10 ns;
         SIG_clk <= '0';
         SIG_start <= '0';
         wait for 10 ns;
        for i in 1 to num_cycles loop
            SIG_clk <= '1';
            wait for 10 ns;
            SIG_clk <= '0';
            wait for 10 ns;
        end loop;
        SIG_clk <= '1';
        wait for 10 ns;
        SIG_W3 <= (others => '1');
        SIG_clk <= '0';
        wait for 10 ns;
        SIG_clk <= '1';
        wait for 10 ns;
        SIG_clk <= '0';
        wait for 10 ns;
        SIG_clk <= '1';
        wait for 10 ns;
        SIG_clk <= '0';
        wait for 10 ns;
        SIG_clk <= '1';
        wait for 10 ns;
        SIG_clk <= '0';
        wait for 10 ns;
        SIG_clk <= '1';
        wait for 10 ns;
        SIG_clk <= '0';
        wait for 10 ns;
        SIG_clk <= '1';
        wait for 10 ns;
        SIG_clk <= '0';
        wait for 10 ns;
        SIG_clk <= '1';
        wait for 10 ns;
        SIG_clk <= '0';
        wait for 10 ns;
        SIG_clk <= '1';
        wait for 10 ns;
        SIG_clk <= '0';
        wait for 10 ns;
        SIG_clk <= '1';
        wait for 10 ns;
        SIG_clk <= '0';
        wait for 10 ns;
        SIG_clk <= '1';
        wait for 10 ns;
        SIG_clk <= '0';
        wait for 10 ns;
        SIG_clk <= '1';
        wait for 10 ns;
        SIG_clk <= '0';
        wait for 10 ns;
        SIG_clk <= '1';
        wait for 10 ns;
        SIG_clk <= '0';
        wait for 10 ns;
        for i in 1 to num_cycles loop
            SIG_clk <= '1';
            wait for 10 ns;
            SIG_clk <= '0';
            wait for 10 ns;
        end loop;

    end process;

end behave; 
