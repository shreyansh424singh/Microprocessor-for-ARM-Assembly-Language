library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mul is
  port(
    Ins      : in  std_logic_vector(3 downto 0);
    RdHi     : in  std_logic_vector(31 downto 0);
    RdLo     : in  std_logic_vector(31 downto 0);
    Rs       : in  std_logic_vector(31 downto 0);
    Rm       : in  std_logic_vector(31 downto 0);
    result   : out std_logic_vector(63 downto 0)
    );
end Mul;
    
-- Ins:
--   x"0"   means mul
--   x"1"   means mla
--   x"2"   means umull
--   x"3"   means umlal
--   x"4"   means smull
--   x"5"   means smlal

architecture behavioral of Mul is
    signal temp1 : signed(63 downto 0) := x"0000000000000000";
    signal temp2 : unsigned(63 downto 0) := x"0000000000000000";
    signal temp3 : std_logic_vector(63 downto 0) := x"0000000000000000";
    signal temp4 : signed(63 downto 0) := x"0000000000000000";

begin 
    temp1 <= signed(Rm)*signed(Rs);
    temp2 <= unsigned(Rm)*unsigned(Rs);
    temp3 <= std_logic_vector(temp1) when (Ins=x"4" or Ins=x"5")
        else std_logic_vector(temp2);
    temp4 <= (signed(temp3) + signed(RdHi & RdLo)) when (Ins=x"3" or Ins=x"5")
        else (signed(temp3) + signed(x"00000000" & RdLo)) when Ins=x"1"
        else signed(temp3);
    result <= x"0000000000000000" when Ins=x"8"
         else std_logic_vector(temp4);

end behavioral;