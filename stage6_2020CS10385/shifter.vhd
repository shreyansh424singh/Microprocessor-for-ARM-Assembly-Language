library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Shifter is
  port(
    data_in     : in  std_logic_vector(31 downto 0);
    data_out    : out std_logic_vector(31 downto 0);
    carry_outa  : out std_logic;
    typea       : in  std_logic_vector(1 downto 0);
    amount      : in  std_logic_vector(7 downto 0)          --only 5 bits are needed actually from 0 to 4.
    );
end Shifter;
    

architecture behavioral of Shifter is
    signal in1, in2, in3, in4, in5, outf: std_logic_vector(31 downto 0);
    signal carry1, carry2, carry3, carry4: std_logic;
begin 

    -- reverse when LSL
    A: for i in 0 to 31 generate
        in1(i) <= data_in(31-i) when typea="00" else data_in(i);
    end generate;


    in2 <= in1 when amount(0) = '0'
        else (in1(0) & in1(31 downto 1)) when (amount(0)='1' and typea="11")
        else ('1' & in1(31 downto 1)) when (amount(0)='1' and typea="10" and in1(31)='1')
        else ('0' & in1(31 downto 1));

    carry1 <= '0' when amount(0) = '0'
        else in1(0);


    in3 <= in2 when amount(1) = '0'
        else (in2(1 downto 0) & in2(31 downto 2)) when (amount(1)='1' and typea="11")
        else ("11" & in2(31 downto 2)) when (amount(1)='1' and typea="10" and in2(31)='1')
        else ("00" & in2(31 downto 2));

    carry2 <= carry1 when amount(1) = '0'
        else in2(1);


    in4 <= in3 when amount(2) = '0'
        else (in3(3 downto 0) & in3(31 downto 4)) when (amount(2)='1' and typea="11")
        else ("1111" & in3(31 downto 4)) when (amount(2)='1' and typea="10" and in3(31)='1')
        else ("0000" & in3(31 downto 4));

    carry3 <= carry2 when amount(2) = '0'
        else in3(3);
        

    in5 <= in4 when amount(3) = '0'
        else (in4(7 downto 0) & in4(31 downto 8)) when (amount(3)='1' and typea="11")
        else (x"FF" & in4(31 downto 8)) when (amount(3)='1' and typea="10" and in4(31)='1')
        else (x"00" & in4(31 downto 8));

    carry4 <= carry3 when amount(3) = '0'
        else in4(7);


    outf <= in5 when amount(4) = '0'
        else (in5(15 downto 0) & in5(31 downto 16)) when (amount(4)='1' and typea="11")
        else (x"FFFF" & in5(31 downto 16)) when (amount(4)='1' and typea="10" and in5(31)='1')
        else (x"0000" & in5(31 downto 16));

    carry_outa <= carry4 when amount(4) = '0'
        else in5(15);

            
    -- reverse when LSL
    B: for i in 0 to 31 generate
        data_out(i) <= outf(31-i) when typea="00" else outf(i);
    end generate;

end behavioral;