library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pc is
  port(
    Cond : in std_logic_vector(1 downto 0);
    F : in std_logic_vector(1 downto 0);
    old_pc : in std_logic_vector(31 downto 0);
    new_pc : out std_logic_vector(31 downto 0);
    S_offset : in std_logic_vector (23 downto 0);
    C : in std_logic;
    N : in std_logic;
    V : in std_logic;
    Z : in std_logic
);
end pc;

architecture beh of pc is
    begin
    
    
    signal predicate : std_logic;    
    signal S_ext : std_logic_vector(5 downto 0);    
    with Cond select
        predicate <= '1' when "10",
                      Z when "00",
                      not Z when "01",
                      '0' when others;
    S_ext <= "111111" when (S_offset(23) = '1') else "000000";
    new_pc <= std_logic_vector (signed(old_pc) + signed(S_ext & S_offset & "00")) when(F = "10" and predicate = '1')
    else std_logic_vector (signed(old_pc) + 4);
end beh;