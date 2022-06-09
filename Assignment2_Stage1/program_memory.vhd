  library ieee;
  use ieee.std_logic_1164.all;
  USE IEEE.STD_LOGIC_UNSIGNED.ALL;
  use ieee.numeric_std.all;

  entity Program_Memory_64x32 is
    port(
      rd        : out std_logic_vector(31 downto 0);
      ad        : in std_logic_vector(7 downto 0)
      );
  end Program_Memory_64x32;

  architecture behavioral of Program_Memory_64x32 is
    type memory is array(0 to 63) of std_logic_vector(31 downto 0);
    --memory is initialized to random values
    signal mem : memory :=
    ( 0 => X"E3A0000A",
      1 => X"E3A01005",
      2 => X"E5801000",
      3 => X"E2811002",
      4 => X"E5801004",
      5 => X"E5902000",
      6 => X"E5903004",
      7 => X"E0434002",
      others => X"00000000"
    );

  begin 
  process (ad) is
    begin
      rd <= mem(to_integer(unsigned(ad(7 downto 2))));           --ad is 8 bit last 2 bits are discarded
    end process;
  end behavioral;