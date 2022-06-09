library ieee; 
use ieee.std_logic_1164.all; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


entity testbench is    
end entity; 

architecture fum of testbench is 

component Stage6 is
    port(clk, reset : in  std_logic);
    end component; 

    signal clock, reset: std_logic := '0';

begin 

DUT: Stage6 port map (clock, reset); 

    process 
    begin 

    reset <= '0';
    for I in 0 to 220 loop
    clock <= not(clock);
    wait for 100 ns;
    end loop;


    ASSERT FALSE REPORT "Test done. Open EPWave to see signals." SEVERITY NOTE;
    wait;
    end process; 
    end; 