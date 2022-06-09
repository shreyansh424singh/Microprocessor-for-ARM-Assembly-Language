library ieee;
use ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity Data_Memory_512x32 is
  port(
    rd        : out std_logic_vector(31 downto 0);
    ad        : in std_logic_vector(7 downto 0);
    wd        : in  std_logic_vector(31 downto 0);
    writeEnable : in  std_logic_vector(3 downto 0);
    mode     : in  std_logic;
    clk      : in  std_logic
    );
end Data_Memory_512x32;
    

architecture behavioral of Data_Memory_512x32 is
  type memory is array(0 to 511) of std_logic_vector(31 downto 0);

-- system area is from 0 to 127
-- user program memory is from 128 to 255
-- data memory is from 256 to 512

signal mem : memory:= 
( -- don't change the following instructions 
  -- they are part of system area
  0 => X"E6000011",          --ISR for reset (rte command)
  --next 2 are ISR for SWI
  2 => X"E5910000",          --load input value into r0 for swi
  3 => X"E6000011",          --rte for swi


  --user area for instructions to be loaded
  128 => X"E3A00004",
  129 => X"E3A01001",
  130 => X"E3A02000",
  131 => X"EA000002",
  132 => X"E2811001",
  133 => X"E2822002",
  134 => X"E6000010",
  135 => X"E2800004",
  136 => X"EBFFFFFA",
  137 => X"E0813002",
  138 => X"E3A02000",
  139 => X"E0804002",
  others => X"00000000");

  signal addr, temp : integer range 0 to 512 := 0;


begin 

  temp <= to_integer(unsigned(ad(7 downto 2)));
  addr <= temp + 128 when (ad(1 downto 0) = "11")    --program memory
     else temp + 256 when (ad(1 downto 0) = "10")    --data memory
     else temp;
        
	rd <= mem(addr);          --ad is 8 bit last 2 bits are discarded
  
process (clk, addr) is
  begin
      if (addr > 5) then
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
    end if;
  end process;
end behavioral;