library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU is
    port(
        operand1: in std_logic_vector(31 downto 0);
        operand2: in std_logic_vector(31 downto 0);
        result: out std_logic_vector(31 downto 0);
        carry_in: in std_logic;
        carry_out: out std_logic;
        opcode: in std_logic_vector(3 downto 0)
    );
end ALU;

architecture rtl of ALU is
begin
  process(operand1, operand2, carry_in, opcode) is
    variable temp: std_logic_vector(31 downto 0);

  begin
    if opcode="0000" then    --and
      result <= operand1 and operand2;
      carry_out <= carry_in;

    elsif opcode="0001" then   --eor
      result <= operand1 xor operand2;
      carry_out <= carry_in;

    elsif opcode="0010" then   --sub
      result <= operand1 +  not(operand2) + '1';
      if (operand2 > operand1) then carry_out <= '0';       --carr_out will be 0 when op2 > op1 else 1
      else carry_out <= '1';
      end if;

    elsif opcode="0011" then    --rsb 
      result <= not(operand1) + operand2 + '1';
      if (operand2 < operand1) then carry_out <= '0';       --carr_out will be 0 when op1 > op2 else 1
      else carry_out <= '1';
      end if;

    elsif opcode="0100" then   --add
      result <= operand1 + operand2;
      temp := operand1 + operand2;
      if (temp < operand1) or (temp < operand2) then        --carr_out will be 1 when overflow occurs else 0
        carry_out <= '1';
      else carry_out <= '0';
      end if;

    elsif opcode="0101" then   --adc
      result <= operand1 + operand2 + carry_in;
      carry_out <= carry_in;

    elsif opcode="0110" then   --sbc
      result <= operand1 + not(operand2) + carry_in;
      carry_out <= carry_in;

    elsif opcode="0111" then   --rsc
      result <= not(operand1) + operand2 + carry_in;
      carry_out <= carry_in;

    elsif opcode="1000" then   --tst
      result <= operand1 and operand2;
      carry_out <= carry_in;

    elsif opcode="1001" then   --teq
      result <= operand1 xor operand2;
      carry_out <= carry_in;

    elsif opcode="1010" then   --cmp
      result <= operand1 +  not(operand2) + '1';
      if (operand1 < operand2) then carry_out <= '0'; --carry_out is 0 if op1 < op2
      else carry_out <= '1';                          --esle it will be 0
      end if;

    elsif opcode="1011" then   --cmn
      result <= operand1 + operand2;
      if (operand1 < not(operand2)) then carry_out <= '0'; --carry_out is 0 if op1 < not(op2)
      else carry_out <= '1';                          --esle it will be 0
      end if;

    elsif opcode="1100" then   --orr
      result <= operand1 or operand2;
      carry_out <= carry_in;

    elsif opcode="1101" then   --mov
      result <= operand2;
      carry_out <= carry_in;

    elsif opcode="1110" then   --bic
      result <= operand1 and not(operand2);
      carry_out <= carry_in;
      
    else                       --mvn
    	result <= not operand2;
      carry_out <= carry_in;
    end if;
  end process;
end rtl;