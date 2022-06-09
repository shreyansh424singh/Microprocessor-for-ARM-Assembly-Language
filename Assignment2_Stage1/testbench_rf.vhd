library ieee; 
use ieee.std_logic_1164.all; 

entity testbench is    
end entity; 

architecture fum of testbench is 

component Register_File_16x32 is
    port (  
        writeEnable:       in  std_logic; 
        wad:    in  std_logic_vector (3 downto 0);
        wd:      in  std_logic_vector (31 downto 0);
        rad1:    in  std_logic_vector (3 downto 0);
        rad2:    in  std_logic_vector (3 downto 0);
        rd1:     out std_logic_vector (31 downto 0);
        rd2:     out std_logic_vector (31 downto 0);
        clk: in  std_logic
        ); 
    end component; 

signal RegWrite:        std_logic := '1';
signal clock:           std_logic := '1';
signal WriteRegNum:     std_logic_vector (3 downto 0) := "0000";
signal WriteData:       std_logic_vector (31 downto 0) := (others => '0');
signal ReadRegNumA:     std_logic_vector (3 downto 0) := "0000";
signal ReadRegNumB:     std_logic_vector (3 downto 0) := "0000";
signal PortA:           std_logic_vector (31 downto 0) := (others => '0');
signal PortB:           std_logic_vector (31 downto 0) := (others => '0');

begin 

DUT: 
    Register_File_16x32 
    port map (rd1 => PortA, rd2 => PortB, wd => WriteData, 
        writeEnable => RegWrite, rad1 => ReadRegNumA, 
        rad2 => ReadRegNumB, wad => WriteRegNum, clk => clock); 

    process 
    begin 
    wait for 100 ns;
    WriteData <= x"feed4252"; 
    WriteRegnum <= "0000";
    RegWrite <= '1';
    clock <= '0';
    wait for 100 ns;

    WriteData <= x"7328face"; 
    WriteRegnum <= "0001";
    RegWrite <= '1';
    clock <= '1';
    wait for 100 ns;

    ReadRegNumA <= "0001";
    ReadRegNumB <= "0000";
    RegWrite <= '0';
    clock <= '0';
    wait for 100 ns;

    WriteData <= x"ab2334bb"; 
    WriteRegnum <= "0101";
    RegWrite <= '1';
    clock <= '1';
    wait for 100 ns;

    WriteData <= x"abcdefee";
    WriteRegnum <= "0001";
    RegWrite <= '1';
    clock <= '0';
    ReadRegNumA <= "0011";
    wait for 100 ns;

    WriteData <= x"67964576";
    WriteRegNum <= "0101";
    ReadRegNumB <= "0101";
    RegWrite <= '0';
    clock <= '1';
    wait for 100 ns; 

    wait;
 end process; 
end; 