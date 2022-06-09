library ieee;
use ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity Data_Memory_128x32 is
  port(
    rd        : out std_logic_vector(31 downto 0);
    ad        : in std_logic_vector(7 downto 0);
    wd         : in  std_logic_vector(31 downto 0);
    writeEnable : in  std_logic_vector(3 downto 0);
    clk      : in  std_logic
    );
end Data_Memory_128x32;
    

architecture behavioral of Data_Memory_128x32 is
  type memory is array(0 to 127) of std_logic_vector(31 downto 0);
-- program memory is from 0 63 
-- data memory is from 64 to 127
  signal mem : memory:= 
(0 => X"E3A00C01",
        1 => X"E3A01007",
        2 => X"E3A0200F",
        3 => X"E3A03003",
        4 => X"E7821180",
        5 => X"E0823310",
        6 => X"E0822180",
        7 => X"E08221A0",
        8 => X"E08221E0",
        9 => X"E08221C0",
        10 => X"E5924000",
        11 => X"E2845004",
        12 => X"E502500A",
        13 => X"E512600A",
        14 => X"E0867004",
        others => X"00000000" );
  

  signal addr, temp : integer range 0 to 128 := 0;

begin 

  temp <= to_integer(unsigned(ad(7 downto 2)));
  addr <= temp + 64 when (ad(1) = '1')
  		else temp;
        
	rd <= mem(addr);          --ad is 8 bit last 2 bits are discarded
  
process (clk, addr) is
  begin
      if (writeEnable(3) = '1') then                        --if writeEnable(3) = 1 then write in first quater
        mem(addr)(31 downto 24) <= wd(31 downto 24);
      end if;
      if (writeEnable(2) = '1') then
        mem(addr)(23 downto 16) <= wd(23 downto 16);
      end if;
      if (writeEnable(1) = '1') then
        mem(addr)(15 downto 8) <= wd(15 downto 8);
      end if;
      if (writeEnable(0) = '1') then
        mem(addr)(7 downto 0) <= wd(7 downto 0);
      end if;
  end process;
end behavioral;