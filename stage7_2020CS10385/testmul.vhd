library ieee; 
use ieee.std_logic_1164.all; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


entity testbench is    
end entity; 

architecture fum of testbench is 

component Mul is
    port(
        Ins      : in  std_logic_vector(3 downto 0);
        RdHi     : in  std_logic_vector(31 downto 0);
        RdLo     : in  std_logic_vector(31 downto 0);
        Rs       : in  std_logic_vector(31 downto 0);
        Rm       : in  std_logic_vector(31 downto 0);
        result   : out std_logic_vector(63 downto 0)
    );
end component; 

    signal Ins      : std_logic_vector(3 downto 0) := x"0";
    signal RdHi     : std_logic_vector(31 downto 0) := x"00000000";
    signal RdLo     : std_logic_vector(31 downto 0) := x"00000000";
    signal Rs       : std_logic_vector(31 downto 0) := x"00000000";
    signal Rm       : std_logic_vector(31 downto 0) := x"00000000";
    signal result   : std_logic_vector(63 downto 0) := x"0000000000000000";

begin 

DUT: Mul port map (Ins, RdHi, RdLo, Rs, Rm, result); 

process 
    begin 

        Ins <= x"0";
        Rdhi <= x"00000001";
        RdLo <= x"00000002";
        Rs <= x"00000003";
        Rm <= x"00000004";
        wait for 100 ns;

        Ins <= x"1";
        Rdhi <= x"00000001";
        RdLo <= x"00000002";
        Rs <= x"00000003";
        Rm <= x"00000004";
        wait for 100 ns;

        Ins <= x"2";
        Rdhi <= x"00000001";
        RdLo <= x"00000002";
        Rs <= x"00000003";
        Rm <= x"00000004";
        wait for 100 ns;

        Ins <= x"3";
        Rdhi <= x"00000001";
        RdLo <= x"00000002";
        Rs <= x"00000003";
        Rm <= x"00000004";
        wait for 100 ns;

        Ins <= x"4";
        Rdhi <= x"00000001";
        RdLo <= x"00000002";
        Rs <= x"00000003";
        Rm <= x"00000004";
        wait for 100 ns;

        Ins <= x"5";
        Rdhi <= x"00000001";
        RdLo <= x"00000002";
        Rs <= x"00000003";
        Rm <= x"00000004";
        wait for 100 ns;

        Ins <= x"8";
        Rdhi <= x"00000001";
        RdLo <= x"00000002";
        Rs <= x"00000003";
        Rm <= x"00000004";
        wait for 100 ns;

    ASSERT FALSE REPORT "Test done. Open EPWave to see signals." SEVERITY NOTE;
    wait;
end process; 
end;    