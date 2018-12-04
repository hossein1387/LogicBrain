library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity CalculatorUnit is
port (
    clk:      in STD_LOGIC;
    reset:    in STD_LOGIC;
    start:    in STD_LOGIC;
    W1:       in STD_LOGIC_VECTOR(511 downto 0);
    I1:       in STD_LOGIC_VECTOR(255 downto 0);
    b1:       in STD_LOGIC_VECTOR(4 downto 0);
    W2:       in STD_LOGIC_VECTOR(2047 downto 0);
    b2:       in STD_LOGIC_VECTOR(4 downto 0);
    W3:       in STD_LOGIC_VECTOR(127 downto 0);
    b3:       in STD_LOGIC_VECTOR(4 downto 0);
    valid_1:  out STD_LOGIC;
    valid_2:  out STD_LOGIC;
    valid_3:  out STD_LOGIC;
    calcOutput: out STD_LOGIC_VECTOR(9 downto 0)
);
end CalculatorUnit;  

architecture rtl of CalculatorUnit is
    
    -- Components
    component AccelCoreL1
    port(
        weightIn: in STD_LOGIC_VECTOR(511 downto 0);
        imageIn:  in STD_LOGIC_VECTOR(255 downto 0);
        biasIn:   in STD_LOGIC_VECTOR(4 downto 0);
        start:    in STD_LOGIC;
        clk:      in STD_LOGIC;
        reset:    in STD_LOGIC;
        done:     out STD_LOGIC;
        errorOut: out STD_LOGIC;
        L1_out:   out STD_LOGIC
    );
    end component;

    component AccelCoreL2
    port(
        weightIn: in STD_LOGIC_VECTOR(2047 downto 0);
        imageIn:  in STD_LOGIC_VECTOR(1023 downto 0);
        biasIn:   in STD_LOGIC_VECTOR(4 downto 0);
        start:    in STD_LOGIC;
        clk:      in STD_LOGIC;
        reset:    in STD_LOGIC;
        done:     out STD_LOGIC;
        errorOut: out STD_LOGIC;
        L1_out:   out STD_LOGIC
    );
    end component;

    component AccelCoreL3
    port(
        weightIn: in STD_LOGIC_VECTOR(127 downto 0);
        imageIn:  in STD_LOGIC_VECTOR(63 downto 0);
        biasIn:   in STD_LOGIC_VECTOR(4 downto 0);
        start:    in STD_LOGIC;
        clk:      in STD_LOGIC;
        reset:    in STD_LOGIC;
        done:     out STD_LOGIC;
        errorOut: out STD_LOGIC;
        L1_out:   out STD_LOGIC
    );
    end component;

    component LineBufferL1
    port(
        clk: in STD_LOGIC;
        reset: in STD_LOGIC;
        doneIn:  in STD_LOGIC;
        valueIn: in STD_LOGIC;
        bufferOut: out STD_LOGIC_VECTOR(1023 downto 0);
        validOut: out STD_LOGIC
    );
    end component;

    component LineBufferL2
    port(
        clk: in STD_LOGIC;
        reset: in STD_LOGIC;
        doneIn:  in STD_LOGIC;
        valueIn: in STD_LOGIC;
        bufferOut: out STD_LOGIC_VECTOR(63 downto 0);
        validOut: out STD_LOGIC
    );
    end component;

    component LineBufferL3
    port(
        clk: in STD_LOGIC;
        reset: in STD_LOGIC;
        doneIn:  in STD_LOGIC;
        valueIn: in STD_LOGIC;
        bufferOut: out STD_LOGIC_VECTOR(9 downto 0);
        validOut: out STD_LOGIC
    );
    end component;

    signal errorOut_SIG1, errorOut_SIG2, errorOut_SIG3: STD_LOGIC;
    signal done1_SIG, done2_SIG, done3_SIG: STD_LOGIC;
    signal out1_SIG, out2_SIG, out3_SIG: STD_LOGIC;
    signal bufferOut1_SIG: STD_LOGIC_VECTOR(1023 downto 0);
    signal bufferOut2_SIG: STD_LOGIC_VECTOR(63 downto 0);
    signal valid1_SIG, valid2_SIG: STD_LOGIC;

begin
    valid_1 <= valid1_SIG;
    valid_2 <= valid2_SIG;
    
    AC1: AccelCoreL1 port map(
        weightIn    => W1,
        imageIn     => I1,
        biasIn      => b1,
        start       => start,
        clk         => clk,
        reset       => reset,
        done        => done1_SIG, 
        errorOut    => errorOut_SIG1,
        L1_out      => out1_SIG
   );

   LB1: LineBufferL1 port map(
        clk         => clk,
        reset       => reset,
        doneIn      => done1_SIG,
        valueIn     => out1_SIG,
        bufferOut   => bufferOut1_SIG,
        validOut    => valid1_SIG
   );

   AC2: AccelCoreL2 port map(
        weightIn    => W2,
        imageIn     => bufferOut1_SIG,
        biasIn      => b2,
        start       => valid1_SIG,
        clk         => clk,
        reset       => reset,
        done        => done2_SIG,
        errorOut    => errorOut_SIG2,
        L1_out      => out2_SIG
   );

   LB2: LineBufferL2 port map(
        clk         => clk,
        reset       => reset,
        doneIn      => done2_SIG,
        valueIn     => out2_SIG,
        bufferOut   => bufferOut2_SIG,
        validOut    => valid2_SIG
   );

   AC3: AccelCoreL3 port map(
        weightIn    => W3,
        imageIn     => bufferOut2_SIG,
        biasIn      => b3,
        start       => valid2_SIG,
        clk         => clk,
        reset       => reset,
        done        => done3_SIG,
        errorOut    => errorOut_SIG3,
        L1_out      => out3_SIG
   );

   LB3: LineBufferL3 port map(
        clk         => clk,
        reset       => reset,
        doneIn      => done3_SIG,
        valueIn     => out3_SIG,
        bufferOut   => calcOutput,
        validOut    => valid_3
   );

end rtl;