LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY testbench IS
END testbench;
 
ARCHITECTURE behavior OF testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ALU is
    PORT(
        operand1: in std_logic_vector(31 downto 0);
        operand2: in std_logic_vector(31 downto 0);
        result: out std_logic_vector(31 downto 0);
        carry_in: in std_logic;
        carry_out: out std_logic;
        opcode: in std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal in1 : std_logic_vector(31 downto 0) := (others => '0');
   signal in2 : std_logic_vector(31 downto 0) := (others => '0');
   signal in3 : std_logic_vector(3 downto 0) := (others => '0');
   signal in4 : std_logic := '0';

   --Outputs
   signal out1 : std_logic_vector(31 downto 0);
   signal out2 : std_logic;
 
   constant period : time := 100 ns;
 
BEGIN
 
   -- Instantiate the Unit Under Test (DUT)
   DUT : ALU PORT MAP (in1, in2, out1, in4, out2, in3);

   -- Stimulus process
   process
   begin    

   in1 <= x"010011bc";
   in2 <= x"00ad1001";
   in4 <= '0';
   in3 <= "0000";
   
   wait for period;
   
   in1 <= x"0000ff11";
   in2 <= x"0cd01001";
   in4 <= '1';
   in3 <= "0001";
   
   wait for period;
   
   in1 <= x"aaa01111";
   in2 <= x"bbb01001";
   in4 <= '1';
   in3 <= "0010";
   
   wait for period;

   in1 <= x"00001111";
   in2 <= x"00001001";
   in4 <= '0';
   in3 <= "0011";
   
   wait for period;
   
   in1 <= x"ffcd1111";
   in2 <= x"ffff1001";
   in4 <= '0';
   in3 <= "0100";
   
   wait for period;

   in1 <= x"00001431";
   in2 <= x"08801001";
   in4 <= '0';
   in3 <= "0101";
   
   wait for period;

   in1 <= x"98701111";
   in2 <= x"03401001";
   in4 <= '0';
   in3 <= "0110";
   
   wait for period;

   in1 <= x"00004111";
   in2 <= x"00d01001";
   in4 <= '0';
   in3 <= "0111";
   
   wait for period;

   in1 <= x"0de01111";
   in2 <= x"a0001001";
   in4 <= '0';
   in3 <= "1000";
   
   wait for period;

   in1 <= x"f0001111";
   in2 <= x"0bb01001";
   in4 <= '0';
   in3 <= "1001";
   
   wait for period;

   in1 <= x"aa001111";
   in2 <= x"cc001001";
   in4 <= '0';
   in3 <= "1010";
   
   wait for period;

   in1 <= x"000ac111";
   in2 <= x"000ad001";
   in4 <= '0';
   in3 <= "1011";
   
   wait for period;

   in1 <= x"000bb111";
   in2 <= x"00bfc001";
   in4 <= '0';
   in3 <= "1100";
   
   wait for period;

   in1 <= x"0000cde1";
   in2 <= x"000bcda1";
   in4 <= '0';
   in3 <= "1101";
   
   wait for period;

   in1 <= x"0000fe11";
   in2 <= x"00034501";
   in4 <= '0';
   in3 <= "1110";
   
   wait for period;

   in1 <= x"00006351";
   in2 <= x"00054261";
   in4 <= '0';
   in3 <= "1111";
   
   wait for period;
      -- Wait indefinitely.
   wait;

   end process;

END;
