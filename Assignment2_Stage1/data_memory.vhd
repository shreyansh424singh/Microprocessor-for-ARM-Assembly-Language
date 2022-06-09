library ieee;
use ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity Data_Memory_64x32 is
  port(
    rd        : out std_logic_vector(31 downto 0);
    ad        : in std_logic_vector(7 downto 0);
    wd         : in  std_logic_vector(31 downto 0);
    writeEnable : in  std_logic_vector(3 downto 0);
    clk      : in  std_logic
    );
end Data_Memory_64x32;
    

architecture behavioral of Data_Memory_64x32 is
  type memory is array(0 to 63) of std_logic_vector(31 downto 0);
  signal mem : memory;

begin 
	rd <= mem(to_integer(unsigned(ad(7 downto 2))));          --ad is 8 bit last 2 bits are discarded
process (clk) is
  begin
      if (writeEnable(3) = '1') then                        --if writeEnable(3) = 1 then write in first quater
        mem(to_integer(unsigned(ad(7 downto 2))))(31 downto 24) <= wd(31 downto 24);
      end if;
      if (writeEnable(2) = '1') then
        mem(to_integer(unsigned(ad(7 downto 2))))(23 downto 16) <= wd(23 downto 16);
      end if;
      if (writeEnable(1) = '1') then
        mem(to_integer(unsigned(ad(7 downto 2))))(15 downto 8) <= wd(15 downto 8);
      end if;
      if (writeEnable(0) = '1') then
        mem(to_integer(unsigned(ad(7 downto 2))))(7 downto 0) <= wd(7 downto 0);
      end if;
  end process;
end behavioral;