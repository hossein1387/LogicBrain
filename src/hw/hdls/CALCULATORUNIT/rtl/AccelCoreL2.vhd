library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity AccelCoreL2 is
port (
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
end AccelCoreL2;  

architecture rtl of AccelCoreL2 is

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
    signal imageIn_p:  STD_LOGIC_VECTOR(1023 downto 0);
    signal imageIn_f:  STD_LOGIC_VECTOR(1023 downto 0);
    signal biasIn_q: STD_LOGIC_VECTOR(4 downto 0);
    signal peOutputArray, peOutputArray_q: STD_LOGIC_VECTOR(639 downto 0);
    signal peErrorDetectArray: STD_LOGIC_VECTOR(127 downto 0);
    signal sumPEs:     STD_LOGIC_VECTOR(31 downto 0);
    signal activation_p: STD_LOGIC;
    signal activation_f: STD_lOGIC;
    signal counter_p : STD_LOGIC_VECTOR(5 downto 0);
    signal counter_f : STD_LOGIC_VECTOR(5 downto 0);

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
    for I in 0 to 127 generate
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

        sumPEs <= STD_LOGIC_VECTOR(resize(signed(peOutputArray(639 downto 635)), sumPEs'length) 
                + resize(signed(peOutputArray(634 downto 630)), sumPEs'length) 
                + resize(signed(peOutputArray(629 downto 625)), sumPEs'length) 
                + resize(signed(peOutputArray(624 downto 620)), sumPEs'length) 
                + resize(signed(peOutputArray(619 downto 615)), sumPEs'length) 
                + resize(signed(peOutputArray(614 downto 610)), sumPEs'length) 
                + resize(signed(peOutputArray(609 downto 605)), sumPEs'length) 
                + resize(signed(peOutputArray(604 downto 600)), sumPEs'length) 
                + resize(signed(peOutputArray(599 downto 595)), sumPEs'length) 
                + resize(signed(peOutputArray(594 downto 590)), sumPEs'length) 
                + resize(signed(peOutputArray(589 downto 585)), sumPEs'length) 
                + resize(signed(peOutputArray(584 downto 580)), sumPEs'length) 
                + resize(signed(peOutputArray(579 downto 575)), sumPEs'length) 
                + resize(signed(peOutputArray(574 downto 570)), sumPEs'length) 
                + resize(signed(peOutputArray(569 downto 565)), sumPEs'length) 
                + resize(signed(peOutputArray(564 downto 560)), sumPEs'length) 
                + resize(signed(peOutputArray(559 downto 555)), sumPEs'length) 
                + resize(signed(peOutputArray(554 downto 550)), sumPEs'length) 
                + resize(signed(peOutputArray(549 downto 545)), sumPEs'length) 
                + resize(signed(peOutputArray(544 downto 540)), sumPEs'length) 
                + resize(signed(peOutputArray(539 downto 535)), sumPEs'length) 
                + resize(signed(peOutputArray(534 downto 530)), sumPEs'length) 
                + resize(signed(peOutputArray(529 downto 525)), sumPEs'length) 
                + resize(signed(peOutputArray(524 downto 520)), sumPEs'length) 
                + resize(signed(peOutputArray(519 downto 515)), sumPEs'length) 
                + resize(signed(peOutputArray(514 downto 510)), sumPEs'length) 
                + resize(signed(peOutputArray(509 downto 505)), sumPEs'length) 
                + resize(signed(peOutputArray(504 downto 500)), sumPEs'length) 
                + resize(signed(peOutputArray(499 downto 495)), sumPEs'length) 
                + resize(signed(peOutputArray(494 downto 490)), sumPEs'length) 
                + resize(signed(peOutputArray(489 downto 485)), sumPEs'length) 
                + resize(signed(peOutputArray(484 downto 480)), sumPEs'length) 
                + resize(signed(peOutputArray(479 downto 475)), sumPEs'length) 
                + resize(signed(peOutputArray(474 downto 470)), sumPEs'length) 
                + resize(signed(peOutputArray(469 downto 465)), sumPEs'length) 
                + resize(signed(peOutputArray(464 downto 460)), sumPEs'length) 
                + resize(signed(peOutputArray(459 downto 455)), sumPEs'length) 
                + resize(signed(peOutputArray(454 downto 450)), sumPEs'length) 
                + resize(signed(peOutputArray(449 downto 445)), sumPEs'length) 
                + resize(signed(peOutputArray(444 downto 440)), sumPEs'length) 
                + resize(signed(peOutputArray(439 downto 435)), sumPEs'length) 
                + resize(signed(peOutputArray(434 downto 430)), sumPEs'length) 
                + resize(signed(peOutputArray(429 downto 425)), sumPEs'length) 
                + resize(signed(peOutputArray(424 downto 420)), sumPEs'length) 
                + resize(signed(peOutputArray(419 downto 415)), sumPEs'length) 
                + resize(signed(peOutputArray(414 downto 410)), sumPEs'length) 
                + resize(signed(peOutputArray(409 downto 405)), sumPEs'length) 
                + resize(signed(peOutputArray(404 downto 400)), sumPEs'length) 
                + resize(signed(peOutputArray(399 downto 395)), sumPEs'length) 
                + resize(signed(peOutputArray(394 downto 390)), sumPEs'length) 
                + resize(signed(peOutputArray(389 downto 385)), sumPEs'length) 
                + resize(signed(peOutputArray(384 downto 380)), sumPEs'length) 
                + resize(signed(peOutputArray(379 downto 375)), sumPEs'length) 
                + resize(signed(peOutputArray(374 downto 370)), sumPEs'length) 
                + resize(signed(peOutputArray(369 downto 365)), sumPEs'length) 
                + resize(signed(peOutputArray(364 downto 360)), sumPEs'length) 
                + resize(signed(peOutputArray(359 downto 355)), sumPEs'length) 
                + resize(signed(peOutputArray(354 downto 350)), sumPEs'length) 
                + resize(signed(peOutputArray(349 downto 345)), sumPEs'length) 
                + resize(signed(peOutputArray(344 downto 340)), sumPEs'length) 
                + resize(signed(peOutputArray(339 downto 335)), sumPEs'length) 
                + resize(signed(peOutputArray(334 downto 330)), sumPEs'length) 
                + resize(signed(peOutputArray(329 downto 325)), sumPEs'length) 
                + resize(signed(peOutputArray(324 downto 320)), sumPEs'length) 
                + resize(signed(peOutputArray(319 downto 315)), sumPEs'length) 
                + resize(signed(peOutputArray(314 downto 310)), sumPEs'length) 
                + resize(signed(peOutputArray(309 downto 305)), sumPEs'length) 
                + resize(signed(peOutputArray(304 downto 300)), sumPEs'length) 
                + resize(signed(peOutputArray(299 downto 295)), sumPEs'length) 
                + resize(signed(peOutputArray(294 downto 290)), sumPEs'length) 
                + resize(signed(peOutputArray(289 downto 285)), sumPEs'length) 
                + resize(signed(peOutputArray(284 downto 280)), sumPEs'length) 
                + resize(signed(peOutputArray(279 downto 275)), sumPEs'length) 
                + resize(signed(peOutputArray(274 downto 270)), sumPEs'length) 
                + resize(signed(peOutputArray(269 downto 265)), sumPEs'length) 
                + resize(signed(peOutputArray(264 downto 260)), sumPEs'length) 
                + resize(signed(peOutputArray(259 downto 255)), sumPEs'length) 
                + resize(signed(peOutputArray(254 downto 250)), sumPEs'length) 
                + resize(signed(peOutputArray(249 downto 245)), sumPEs'length) 
                + resize(signed(peOutputArray(244 downto 240)), sumPEs'length) 
                + resize(signed(peOutputArray(239 downto 235)), sumPEs'length) 
                + resize(signed(peOutputArray(234 downto 230)), sumPEs'length) 
                + resize(signed(peOutputArray(229 downto 225)), sumPEs'length) 
                + resize(signed(peOutputArray(224 downto 220)), sumPEs'length) 
                + resize(signed(peOutputArray(219 downto 215)), sumPEs'length) 
                + resize(signed(peOutputArray(214 downto 210)), sumPEs'length) 
                + resize(signed(peOutputArray(209 downto 205)), sumPEs'length) 
                + resize(signed(peOutputArray(204 downto 200)), sumPEs'length) 
                + resize(signed(peOutputArray(199 downto 195)), sumPEs'length) 
                + resize(signed(peOutputArray(194 downto 190)), sumPEs'length) 
                + resize(signed(peOutputArray(189 downto 185)), sumPEs'length) 
                + resize(signed(peOutputArray(184 downto 180)), sumPEs'length) 
                + resize(signed(peOutputArray(179 downto 175)), sumPEs'length) 
                + resize(signed(peOutputArray(174 downto 170)), sumPEs'length) 
                + resize(signed(peOutputArray(169 downto 165)), sumPEs'length) 
                + resize(signed(peOutputArray(164 downto 160)), sumPEs'length) 
                + resize(signed(peOutputArray(159 downto 155)), sumPEs'length) 
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

        errorOut <= peErrorDetectArray(119) 
                    OR peErrorDetectArray(118) OR peErrorDetectArray(117) OR peErrorDetectArray(116) 
                    OR peErrorDetectArray(115) OR peErrorDetectArray(114) OR peErrorDetectArray(113) 
                    OR peErrorDetectArray(112) OR peErrorDetectArray(111) OR peErrorDetectArray(110) 
                    OR peErrorDetectArray(109) OR peErrorDetectArray(108) OR peErrorDetectArray(107) 
                    OR peErrorDetectArray(106) OR peErrorDetectArray(105) OR peErrorDetectArray(104) 
                    OR peErrorDetectArray(103) OR peErrorDetectArray(102) OR peErrorDetectArray(101) 
                    OR peErrorDetectArray(100) OR peErrorDetectArray(99) OR peErrorDetectArray(98) 
                    OR peErrorDetectArray(97) OR peErrorDetectArray(96) OR peErrorDetectArray(95) 
                    OR peErrorDetectArray(94) OR peErrorDetectArray(93) OR peErrorDetectArray(92) 
                    OR peErrorDetectArray(91) OR peErrorDetectArray(90) OR peErrorDetectArray(89) 
                    OR peErrorDetectArray(88) OR peErrorDetectArray(87) OR peErrorDetectArray(86) 
                    OR peErrorDetectArray(85) OR peErrorDetectArray(84) OR peErrorDetectArray(83) 
                    OR peErrorDetectArray(82) OR peErrorDetectArray(81) OR peErrorDetectArray(80) 
                    OR peErrorDetectArray(79) OR peErrorDetectArray(78) OR peErrorDetectArray(77) 
                    OR peErrorDetectArray(76) OR peErrorDetectArray(75) OR peErrorDetectArray(74) 
                    OR peErrorDetectArray(73) OR peErrorDetectArray(72) OR peErrorDetectArray(71) 
                    OR peErrorDetectArray(70) OR peErrorDetectArray(69) OR peErrorDetectArray(68) 
                    OR peErrorDetectArray(67) OR peErrorDetectArray(66) OR peErrorDetectArray(65) 
                    OR peErrorDetectArray(64) OR peErrorDetectArray(63) OR peErrorDetectArray(62) 
                    OR peErrorDetectArray(61) OR peErrorDetectArray(60) OR peErrorDetectArray(59) 
                    OR peErrorDetectArray(58) OR peErrorDetectArray(57) OR peErrorDetectArray(56) 
                    OR peErrorDetectArray(55) OR peErrorDetectArray(54) OR peErrorDetectArray(53) 
                    OR peErrorDetectArray(52) OR peErrorDetectArray(51) OR peErrorDetectArray(50) 
                    OR peErrorDetectArray(49) OR peErrorDetectArray(48) OR peErrorDetectArray(47) 
                    OR peErrorDetectArray(46) OR peErrorDetectArray(45) OR peErrorDetectArray(44) 
                    OR peErrorDetectArray(43) OR peErrorDetectArray(42) OR peErrorDetectArray(41) 
                    OR peErrorDetectArray(40) OR peErrorDetectArray(39) OR peErrorDetectArray(38) 
                    OR peErrorDetectArray(37) OR peErrorDetectArray(36) OR peErrorDetectArray(35) 
                    OR peErrorDetectArray(34) OR peErrorDetectArray(33) OR peErrorDetectArray(32) 
                    OR peErrorDetectArray(31) OR peErrorDetectArray(30) OR peErrorDetectArray(29) 
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

            when others => if(counter_p = "111111") then
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