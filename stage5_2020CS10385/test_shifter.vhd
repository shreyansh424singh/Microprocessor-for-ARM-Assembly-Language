library ieee; 
use ieee.std_logic_1164.all; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


entity testbench is    
end entity; 

architecture fum of testbench is 

component Shifter is
    port(
        data_in     : in  std_logic_vector(31 downto 0);
        data_out    : out std_logic_vector(31 downto 0);
        -- carry_ina   : in  std_logic;
        carry_outa  : out std_logic;
        typea       : in  std_logic_vector(1 downto 0);
        amount      : in  std_logic_vector(7 downto 0)          --only 5 bits are needed actually from 0 to 4.
    );
    end component; 

    signal data_in     : std_logic_vector(31 downto 0):=x"00000000";
    signal data_out    : std_logic_vector(31 downto 0):=x"00000000";
    signal carry_outa  : std_logic :='0';
    signal typea       : std_logic_vector(1 downto 0) :="00";
    signal amount      : std_logic_vector(7 downto 0) :="00000000";

begin 

DUT: Shifter port map(data_in, data_out, carry_outa, typea, amount); 

    process 
    begin 

    data_in <= x"000F0000";
    typea <= "00";
    amount <= x"08";
    wait for 100 ns;

    data_in <= x"000F0000";
    typea <= "01";
    amount <= x"08";
    wait for 100 ns;
    
    data_in <= x"000F0000";
    typea <= "10";
    amount <= x"08";
    wait for 100 ns;

    data_in <= x"000F0000";
    typea <= "11";
    amount <= x"08";
    wait for 100 ns;

    data_in <= x"000F0000";
    typea <= "00";
    amount <= x"08";
    wait for 100 ns;

    data_in <= x"000F0000";
    typea <= "01";
    amount <= x"08";
    wait for 100 ns;
    
    data_in <= x"000F0000";
    typea <= "10";
    amount <= x"08";
    wait for 100 ns;

    data_in <= x"000F0000";
    typea <= "11";
    amount <= x"08";
    wait for 100 ns;

    ASSERT FALSE REPORT "Test done. Open EPWave to see signals." SEVERITY NOTE;
    wait;
    end process; 
    end; 