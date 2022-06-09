library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity flags is
  port(
    Fset : in std_logic;
    operation : in std_logic_vector(3 downto 0);
    S : in std_logic;
    -- rotation needs to be added in next stage 
    -- add LSL, LSR, ROR, ASR in mytype and input here
    -- input shift value
    carry_alu : in std_logic;
--     carry_sft : in std_logic;
    result_alu: in std_logic_vector(31 downto 0);
    msb_alu_a : in std_logic; 
    msb_alu_b : in std_logic;
    C : out std_logic;
    N : out std_logic;
    V : out std_logic;
    Z : out std_logic
    );
end flags;

architecture fls of flags is
    begin
      process(operation, S, carry_alu, result_alu, msb_alu_a, msb_alu_b, Fset) is
        variable msb_result : std_logic;

      begin
        if Fset = '1' then 
        msb_result := result_alu(31);
        if operation = "0100" then    --add
            if S = '1' then
                C <= carry_alu;
                N <= msb_result;
                V <= (msb_alu_a and msb_alu_b and not(msb_result)) or (not(msb_alu_a) and not(msb_alu_b) and msb_result);
                if result_alu = x"00000000" then Z <= '1'; 
                else Z <= '0';
                end if;
            end if;
        elsif operation = "0101" then    --adc
            if S = '1' then
                --   functionalty needs to be added in next stage
            end if;
        elsif operation = "0010" then     --sub
            if S = '1' then
                C <= carry_alu;
                N <= msb_result;
                V <= (msb_alu_a and not(msb_alu_b) and not(msb_result)) or (not(msb_alu_a) and msb_alu_b and msb_result);
                if result_alu = x"00000000" then Z <= '1'; 
                else Z <= '0';
                end if;
            end if;
        elsif operation = "0110" then     --sbc
            if S = '1' then
                --   functionalty needs to be added in next stage
            end if;
        elsif operation = "0011" then     --rsb
            if S = '1' then
                C <= carry_alu;
                N <= msb_result;
                V <= (msb_alu_b and not(msb_alu_a) and not(msb_result)) or (not(msb_alu_b) and msb_alu_a and msb_result);
                if result_alu = x"00000000" then Z <= '1'; 
                else Z <= '0';
                end if;
            end if;
        elsif operation = "0111" then     --rsc
            if S = '1' then
                --   functionalty needs to be added in next stage
            end if;
        elsif operation = "1010" then          --cmp
            C <= carry_alu;
            N <= msb_result;
            V <= (msb_alu_a and not(msb_alu_b) and not(msb_result)) or (not(msb_alu_a) and msb_alu_b and msb_result);
            if result_alu = x"00000000" then Z <= '1'; 
            else Z <= '0';
            end if;
        elsif operation = "1011" then          --cmn
            C <= carry_alu;
            N <= msb_result;
            V <= (msb_alu_b and not(msb_alu_a) and not(msb_result)) or (not(msb_alu_b) and msb_alu_a and msb_result);
            if result_alu = x"00000000" then Z <= '1'; 
            else Z <= '0';
            end if;
        elsif operation = "1101"  then           --mov
            if S = '1' then
            --   functionalty needs to be added in next stage
            end if;
        end if;
        elsif operation = "1111"  then           --mvn
            if S = '1' then
            --   functionalty needs to be added in next stage
            end if;
        elsif operation = "0000"  then           --and
            if S = '1' then
            --   functionalty needs to be added in next stage
            end if;
        elsif operation = "0001"  then           --eor
            if S = '1' then
            --   functionalty needs to be added in next stage
            end if;
        elsif operation = "1000"  then           --tst
            N <= msb_result;
            if result_alu = x"00000000" then Z <= '1'; 
            else Z <= '0';
            end if;
        elsif operation = "1001"  then           --teq
            N <= msb_result;
            if result_alu = x"00000000" then Z <= '1'; 
            else Z <= '0';
            end if;
        elsif operation = "1100"  then           --orr
            if S = '1' then
            --   functionalty needs to be added in next stage
            end if;
        else                                     --bic
            if S = '1' then
            --   functionalty needs to be added in next stage
            end if;
        end if;
      end process;
end fls;