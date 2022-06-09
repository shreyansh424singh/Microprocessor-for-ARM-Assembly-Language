library ieee; 
use ieee.std_logic_1164.all; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


entity testbench is    
end entity; 

architecture fum of testbench is 

component Stage8 is
    port(
        clk, reset, status : in  std_logic;
        input : in std_logic_vector(7 downto 0));
end component; 

    signal clock, reset, status: std_logic := '0';
    signal input : std_logic_vector(7 downto 0) := x"00";

begin 

DUT: Stage8 port map (clock, reset, status, input); 

    process 
    begin 

    reset <= '0';
    status <= '0';
    input <= "00000000";
    for I in 0 to 50 loop
    clock <= not(clock);
    wait for 100 ns;
    end loop;

    reset <= '1';
    for I in 0 to 5 loop
    clock <= not(clock);
    wait for 100 ns;
    end loop;

    reset <= '0';
    for I in 0 to 100 loop
    clock <= not(clock);
    wait for 100 ns;
    end loop;


    ASSERT FALSE REPORT "Test done. Open EPWave to see signals." SEVERITY NOTE;
    wait;
    end process; 
    end; 