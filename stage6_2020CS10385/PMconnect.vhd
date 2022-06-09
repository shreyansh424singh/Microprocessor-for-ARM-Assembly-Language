library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PMconnect is
  port(
    Adr      : in  std_logic_vector(1 downto 0);
    Ins      : in  std_logic_vector(3 downto 0);
    Rout     : in  std_logic_vector(31 downto 0);
    Rin      : out std_logic_vector(31 downto 0);
    Mout     : in  std_logic_vector(31 downto 0);
    Min      : out std_logic_vector(31 downto 0);
    MW       : out std_logic_vector(3 downto 0)
    );
end PMconnect;
    
-- Ins:
--   x"0"   means str
--   x"1"   means strh
--   x"2"   means strb
--   x"3"   means ldr
--   x"4"   means ldrh
--   x"5"   means ldrsh
--   x"6"   means ldrb
--   x"7"   means ldrsb

architecture behavioral of PMconnect is
begin 

    Min <= Rout when Ins=x"0"
      else (Rout(15 downto 0) & Rout(15 downto 0)) when Ins=x"1"
      else (Rout(7 downto 0) & Rout(7 downto 0) & Rout(7 downto 0) & Rout(7 downto 0)) when Ins=x"2"
      else x"00000000";

    MW  <= "1111" when Ins=x"0"
      else "0011" when (Ins=x"1" and Adr="00")
      else "1100" when (Ins=x"1" and Adr="10")
      else "0001" when (Ins=x"2" and Adr="00")
      else "0010" when (Ins=x"2" and Adr="01")
      else "0100" when (Ins=x"2" and Adr="10")
      else "1000" when (Ins=x"2" and Adr="11")
      else "0000";

    Rin <= Mout when Ins=x"3"
      else (x"0000" & Mout(15 downto 0)) when (Ins=x"4" and Adr="00")
      else (x"0000" & Mout(31 downto 16)) when (Ins=x"4" and Adr="10")
      else (x"0000" & Mout(15 downto 0)) when (Ins=x"5" and Adr="00" and Mout(15)='0')
      else (x"FFFF" & Mout(15 downto 0)) when (Ins=x"5" and Adr="00" and Mout(15)='1')
      else (x"0000" & Mout(31 downto 16)) when (Ins=x"5" and Adr="10" and Mout(31)='0')
      else (x"FFFF" & Mout(31 downto 16)) when (Ins=x"5" and Adr="10" and Mout(31)='1')
      else (x"000000" & Mout(7 downto 0)) when (Ins=x"6" and Adr="00")
      else (x"000000" & Mout(15 downto 8)) when (Ins=x"6" and Adr="01")
      else (x"000000" & Mout(23 downto 16)) when (Ins=x"6" and Adr="10")
      else (x"000000" & Mout(31 downto 24)) when (Ins=x"6" and Adr="11")
      else (x"000000" & Mout(7 downto 0)) when (Ins=x"7" and Adr="00" and Mout(7)='0')
      else (x"FFFFFF" & Mout(7 downto 0)) when (Ins=x"7" and Adr="00" and Mout(7)='1')
      else (x"000000" & Mout(15 downto 8)) when (Ins=x"7" and Adr="01" and Mout(15)='0')
      else (x"FFFFFF" & Mout(15 downto 8)) when (Ins=x"7" and Adr="01" and Mout(15)='1')
      else (x"000000" & Mout(23 downto 16)) when (Ins=x"7" and Adr="10" and Mout(23)='0')
      else (x"FFFFFF" & Mout(23 downto 16)) when (Ins=x"7" and Adr="10" and Mout(23)='1')
      else (x"000000" & Mout(31 downto 24)) when (Ins=x"7" and Adr="11" and Mout(31)='0')
      else (x"FFFFFF" & Mout(31 downto 24)) when (Ins=x"7" and Adr="11" and Mout(31)='1')
      else x"00000000";

end behavioral;