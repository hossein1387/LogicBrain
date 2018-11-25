library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity PE is
port (
    weightInput: in STD_LOGIC_VECTOR(15 downto 0);
    imageInput: in STD_LOGIC_VECTOR(7 downto 0);
    peOutput: out STD_LOGIC_VECTOR(4 downto 0);
    errorDetect: out STD_LOGIC
);
end PE;

architecture rtl of PE is

    signal out0, out1, out2, out3, out4, out5, out6, out7: STD_LOGIC_VECTOR(1 downto 0);

    function TO_STD_LOGIC(L: BOOLEAN) return std_ulogic is
    begin
        if L then
            return('1');
        else
            return('0');
        end if;
    end function TO_STD_LOGIC;

begin

    out7 <= (weightInput(15) AND weightInput(14) AND imageInput(7)) & (weightInput(14) AND imageInput(7));
    out6 <= (weightInput(13) AND weightInput(12) AND imageInput(6)) & (weightInput(12) AND imageInput(6));
    out5 <= (weightInput(11) AND weightInput(10) AND imageInput(5)) & (weightInput(10) AND imageInput(5));
    out4 <= (weightInput(9) AND weightInput(8) AND imageInput(4)) & (weightInput(8) AND imageInput(4));
    out3 <= (weightInput(7) AND weightInput(6) AND imageInput(3)) & (weightInput(6) AND imageInput(3));
    out2 <= (weightInput(5) AND weightInput(4) AND imageInput(2)) & (weightInput(4) AND imageInput(2));
    out1 <= (weightInput(3) AND weightInput(2) AND imageInput(1)) & (weightInput(2) AND imageInput(1));
    out0 <= (weightInput(1) AND weightInput(0) AND imageInput(0)) & (weightInput(0) AND imageInput(0));

    errorDetect <= TO_STD_LOGIC((weightInput(15 downto 14) = "10") OR 
                             (weightInput(13 downto 12) = "10") OR 
                             (weightInput(11 downto 10) = "10") OR 
                             (weightInput(9 downto 8) = "10") OR 
                             (weightInput(7 downto 6) = "10") OR 
                             (weightInput(5 downto 4) = "10") OR 
                             (weightInput(3 downto 2) = "10") OR 
                             (weightInput(1 downto 0) = "10"));

    peOutput <= STD_LOGIC_VECTOR(resize(signed(out7), peOutput'length) 
                                + resize(signed(out6), peOutput'length)
                                + resize(signed(out5), peOutput'length)
                                + resize(signed(out4), peOutput'length)
                                + resize(signed(out3), peOutput'length)
                                + resize(signed(out2), peOutput'length)
                                + resize(signed(out1), peOutput'length)
                                + resize(signed(out0), peOutput'length));

end rtl;
