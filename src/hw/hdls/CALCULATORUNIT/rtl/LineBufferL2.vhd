library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity LineBufferL2 is
port (
    clk: in STD_LOGIC;
    reset: in STD_LOGIC;
    doneIn:  in STD_LOGIC;
    valueIn: in STD_LOGIC;
    bufferOut: out STD_LOGIC_VECTOR(63 downto 0);
    validOut: out STD_LOGIC
);
end LineBufferL2;  

architecture rtl of LineBufferL2 is
    -- State signals
    type state_T is (Idle, Shift, Valid, WaitState);
    signal current_s, next_s: state_T;

    -- Other signals
    signal bufferValues_p: STD_LOGIC_VECTOR(63 downto 0);
    signal bufferValues_f: STD_LOGIC_VECTOR(63 downto 0);
    signal valid_p: STD_LOGIC;
    signal valid_f: STD_LOGIC;

begin
    bufferOut <= bufferValues_p; -- Linking output to present buffer
    validOut <= valid_p; -- Linking 

    synchrone_ASM: process(clk, reset)
    begin
        if(reset = '1') then
            current_s <= Idle;
            bufferValues_p <= (others => '0');
            valid_p <= '0';
        elsif(clk'event and clk = '1') then
            current_s <= next_s;
            bufferValues_p <= bufferValues_f;
            valid_p <= valid_f;
        end if;
    end process;

    asynchrone_ASM: process(doneIn, valueIn, current_s, bufferValues_p)
    begin
        case current_s is
            when Idle => if(doneIn = '1') then
                            next_s <= Shift;
                            bufferValues_f <= valueIn & bufferValues_p(63 downto 1);
                         else
                            next_s <= Idle;
                            bufferValues_f <= (others => '0');
                         end if;
                         valid_f <= '0';

            when Shift => if(doneIn = '1') then
                            next_s <= Shift;
                            bufferValues_f <= valueIn & bufferValues_p(63 downto 1);
                            valid_f <= '0';
                          else
                            next_s <= Valid;
                            bufferValues_f <= bufferValues_p;
                            valid_f <= '1';
                          end if;
            
            when Valid => if(doneIn = '1') then
                            next_s <= Shift;
                            bufferValues_f <= valueIn & bufferValues_p(63 downto 1);
                          else
                            next_s <= WaitState;
                            bufferValues_f <= bufferValues_p;
                          end if;
                          valid_f <= '0';

            when others => if(doneIn = '0') then
                              next_s <= Valid;
                              bufferValues_f <= bufferValues_p;
                           else
                              next_s <= Shift;
                              bufferValues_f <= valueIn & bufferValues_p(63 downto 1);
                           end if;
                           valid_f <= '0';
        end case;
    end process;

end rtl;
