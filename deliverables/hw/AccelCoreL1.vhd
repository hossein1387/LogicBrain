library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity AccelCoreL1 is
port (
    weightIn: in STD_LOGIC_VECTOR(511 downto 0);
    imageIn:  in STD_LOGIC_VECTOR(255 downto 0);
    biasIn:   in STD_LOGIC_VECTOR(1 downto 0);
    start:    in STD_LOGIC;
    clk:      in STD_LOGIC;
    reset:    in STD_LOGIC;
    done:     out STD_LOGIC;
    errorOut: out STD_LOGIC;
    L1_out:   out STD_LOGIC
);
end AccelCoreL1;  

architecture rtl of AccelCoreL1 is

    -- Defined functions
    function TO_STD_LOGIC(L: BOOLEAN) return std_ulogic is
    begin
        if L then
            return('1');
        else
            return('0');
        end if;
    end function TO_STD_LOGIC;

    -- State definition
    type state_T is (Idle, Proc, Proc2, EndP);
    -- Process signals
    signal current_s, next_s: state_T;
    signal done_p, done_f: std_logic;

    -- Other signals
    signal imageIn_p:  STD_LOGIC_VECTOR(255 downto 0);
    signal imageIn_f:  STD_LOGIC_VECTOR(255 downto 0);
    signal peOutputArray, peOutputArray_q: STD_LOGIC_VECTOR(159 downto 0);
    signal biasIn_q: STD_LOGIC_VECTOR(1 downto 0);
    signal peErrorDetectArray: STD_LOGIC_VECTOR(31 downto 0);
    signal sumPEs:     STD_LOGIC_VECTOR(31 downto 0);
    signal activation_p: STD_LOGIC;
    signal activation_f: STD_lOGIC;
    signal counter_p : STD_LOGIC_VECTOR(9 downto 0);
    signal counter_f : STD_LOGIC_VECTOR(9 downto 0);

    -- Components
    component PE 
    port( 
      weightInput: in STD_LOGIC_VECTOR(15 downto 0);
      imageInput:  in STD_LOGIC_VECTOR(7 downto 0);
      peOutput:    out STD_LOGIC_VECTOR(4 downto 0);
      errorDetect: out STD_LOGIC
    );
    end component;

begin
    -- Connecting inputs to signals
    imageIn_f <= imageIn;
    L1_out <= activation_p;
    done <= done_p;

    GEN_PE:
    for I in 0 to 31 generate
        PE_X: PE port map(
             weightInput => weightIn(16*(I+1) - 1 downto 16*I),
             imageInput => imageIn_f(8*(I+1) - 1 downto 8*I), 
             peOutput => peOutputArray_q(5*(I+1) -1 downto 5*I), 
             errorDetect => peErrorDetectArray(I)
        );
    end generate;

    asynchrone_Logic1: process(peOutputArray, peErrorDetectArray, biasIn_q)
    begin
       -- for I in 0 to 31 generate
        --    weightInput(I) <= weightIn_q(16*(I+1) - 1 downto 16*I);
        --    imageInput(I) <= imageIn_q(16*(I+1) - 1 downto 16*I);
       -- end generate;

        sumPEs <= STD_LOGIC_VECTOR(resize(signed(peOutputArray(159 downto 155)), sumPEs'length) 
                + resize(signed(peOutputArray(154 downto 150)), sumPEs'length) 
                + resize(signed(peOutputArray(149 downto 145)), sumPEs'length) 
                + resize(signed(peOutputArray(144 downto 140)), sumPEs'length) 
                + resize(signed(peOutputArray(139 downto 135)), sumPEs'length) 
                + resize(signed(peOutputArray(134 downto 130)), sumPEs'length) 
                + resize(signed(peOutputArray(129 downto 125)), sumPEs'length) 
                + resize(signed(peOutputArray(124 downto 120)), sumPEs'length) 
                + resize(signed(peOutputArray(119 downto 115)), sumPEs'length) 
                + resize(signed(peOutputArray(114 downto 110)), sumPEs'length) 
                + resize(signed(peOutputArray(109 downto 105)), sumPEs'length) 
                + resize(signed(peOutputArray(104 downto 100)), sumPEs'length) 
                + resize(signed(peOutputArray(99 downto 95)), sumPEs'length) 
                + resize(signed(peOutputArray(94 downto 90)), sumPEs'length) 
                + resize(signed(peOutputArray(89 downto 85)), sumPEs'length) 
                + resize(signed(peOutputArray(84 downto 80)), sumPEs'length) 
                + resize(signed(peOutputArray(79 downto 75)), sumPEs'length) 
                + resize(signed(peOutputArray(74 downto 70)), sumPEs'length) 
                + resize(signed(peOutputArray(69 downto 65)), sumPEs'length) 
                + resize(signed(peOutputArray(64 downto 60)), sumPEs'length) 
                + resize(signed(peOutputArray(59 downto 55)), sumPEs'length) 
                + resize(signed(peOutputArray(54 downto 50)), sumPEs'length) 
                + resize(signed(peOutputArray(49 downto 45)), sumPEs'length) 
                + resize(signed(peOutputArray(44 downto 40)), sumPEs'length) 
                + resize(signed(peOutputArray(39 downto 35)), sumPEs'length) 
                + resize(signed(peOutputArray(34 downto 30)), sumPEs'length) 
                + resize(signed(peOutputArray(29 downto 25)), sumPEs'length) 
                + resize(signed(peOutputArray(24 downto 20)), sumPEs'length) 
                + resize(signed(peOutputArray(19 downto 15)), sumPEs'length) 
                + resize(signed(peOutputArray(14 downto 10)), sumPEs'length) 
                + resize(signed(peOutputArray(9 downto 5)), sumPEs'length)
                + resize(signed(peOutputArray(4 downto 0)), sumPEs'length)
                + resize(signed(biasIn_q), sumPEs'length));

        errorOut <= peErrorDetectArray(31) OR peErrorDetectArray(30) OR peErrorDetectArray(29) 
                    OR peErrorDetectArray(28) OR peErrorDetectArray(27) OR peErrorDetectArray(26)   
                    OR peErrorDetectArray(25) OR peErrorDetectArray(24) OR peErrorDetectArray(23)  
                    OR peErrorDetectArray(22) OR peErrorDetectArray(21) OR peErrorDetectArray(20)  
                    OR peErrorDetectArray(19) OR peErrorDetectArray(18) OR peErrorDetectArray(17)  
                    OR peErrorDetectArray(16) OR peErrorDetectArray(15) OR peErrorDetectArray(14)  
                    OR peErrorDetectArray(13) OR peErrorDetectArray(12) OR peErrorDetectArray(11)  
                    OR peErrorDetectArray(10) OR peErrorDetectArray(9) OR peErrorDetectArray(8)  
                    OR peErrorDetectArray(7) OR peErrorDetectArray(6) OR peErrorDetectArray(5)  
                    OR peErrorDetectArray(4) OR peErrorDetectArray(3) OR peErrorDetectArray(2)  
                    OR peErrorDetectArray(1) OR peErrorDetectArray(0);
    end process;

    asynchrone_Logic2: process(sumPEs)
    begin
        if(signed(sumPEs) > 0) then
            activation_f <= '1'; 
        else
            activation_f <= '0';
        end if;
    end process;

    synchrone_Logic: process(clk,reset)
    begin
        if(reset = '1') then
            imageIn_p <= (others => '0');
            activation_p <= '0';
            peOutputArray <= (others => '0');
            biasIn_q <= (others => '0');
        elsif(clk'event and clk = '1') then
            imageIn_p <= imageIn_f;
            activation_p <= activation_f;
            peOutputArray <= peOutputArray_q;
            biasIn_q <= biasIn;
        end if;
    end process;

    synchrone_ASM: process(clk, reset)
    begin
        if(reset = '1') then
            current_s <= Idle;
            done_p <= '0';
            counter_p <= (others => '0');
        elsif(clk'event and clk = '1') then
            current_s <= next_s;
            done_p <= done_f;
            counter_p <= counter_f;
        end if;
    end process;

    asynchrone_ASM: process(current_s, start, counter_p)
    begin
        case current_s is
            when Idle => if(start = '1') then
                             next_s <= Proc;
                         else
                             next_s <= Idle;
                         end if;
                         done_f <= '0';
                         counter_f <= (others => '0');

            when Proc => next_s <= Proc2;
                         done_f <= '0';
                         counter_f <= (others => '0');
            
            when Proc2 => next_s <= EndP;
                         done_f <= '1';
                         counter_f <= (others => '0');

            when others => if(counter_p = "1111111111") then
                              next_s <= Idle;
                              done_f <= '0';
                              counter_f <= (others => '0');
                           else
                              next_s <= EndP;
                              done_f <= '1';
                              counter_f <= STD_LOGIC_VECTOR(resize(unsigned(counter_p) + 1, counter_f'length));
                           end if;
        end case;
    end process;

end rtl;