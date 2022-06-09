library ieee; 
use ieee.std_logic_1164.all; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


entity testbench is    
end entity; 

architecture fum of testbench is 

component Data_Memory_64x32 is
    port (  
        rd        : out std_logic_vector(31 downto 0);
        ad        : in std_logic_vector(7 downto 0);
        wd         : in  std_logic_vector(31 downto 0);
        writeEnable : in  std_logic_vector(3 downto 0);
        clk      : in  std_logic
        ); 
    end component; 

    signal out1:  std_logic_vector (31 downto 0) := (others => '0');
    signal in1:   std_logic_vector (7 downto 0) := (others => '0');
    signal in2:   std_logic_vector (31 downto 0) := (others => '0');
    signal in3:   std_logic_vector (3 downto 0) := "0000";
    signal clock: std_logic := '1';

begin 

DUT: 
    Data_Memory_64x32 
    port map (out1, in1, in2, in3, clock); 

    process 
    begin 
    wait for 100 ns;
    in3 <= "0000";
    in1 <= "10001100";
    clock <= '0';
    wait for 100 ns;

    
    clock <= '0';
    in3 <= "1111";
    in1 <= "00000000";
    in2 <= x"a00b23cd";
    wait for 100 ns;

    clock <= '1';
    in3 <= "1111";
    in1 <= "00000100";
    in2 <= x"a04233cd";
    wait for 100 ns;

    clock <= '0';
    in3 <= "0011";
    in1 <= "00001000";
    in2 <= x"a00b2354";
    wait for 100 ns;

    clock <= '1';
    in3 <= "1101";
    in1 <= "00001100";
    in2 <= x"a00b23bb";
    wait for 100 ns;

    in3 <= "0000";
    in1 <= "00000000";
    clock <= '0';
    wait for 100 ns; 

    in3 <= "0000";
    in1 <= "00000100";
    clock <= '1';
    wait for 100 ns;

    in3 <= "0000";
    in1 <= "00001000";
    clock <= '0';
    wait for 100 ns;

    in3 <= "0000";
    in1 <= "00001100";
    clock <= '1';
    wait for 100 ns;
    
    in3 <= "0100";
    in1 <= "00001100";
    clock <= '1';
    wait for 100 ns;

    ASSERT FALSE REPORT "Test done. Open EPWave to see signals." SEVERITY NOTE;
    wait;
 end process; 
end; 