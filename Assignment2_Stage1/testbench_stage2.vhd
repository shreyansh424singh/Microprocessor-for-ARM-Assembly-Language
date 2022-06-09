library ieee; 
use ieee.std_logic_1164.all; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


entity testbench is    
end entity; 

architecture fum of testbench is 

component Stage2 is
    port(clk : in  std_logic);
    end component; 

    signal clock: std_logic := '1';

begin 

DUT: Stage2 port map (clock); 

    process 
    begin 

    for I in 0 to 200 loop
    wait for 100 ns;
    clock <= not(clock);
    end loop;


    ASSERT FALSE REPORT "Test done. Open EPWave to see signals." SEVERITY NOTE;
    wait;
    end process; 
    end; 