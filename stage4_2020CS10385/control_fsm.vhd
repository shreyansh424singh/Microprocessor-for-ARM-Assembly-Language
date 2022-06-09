LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
 
ENTITY control_fsm IS
port(
    F    : in std_logic_vector (1 downto 0);
    Cond : in std_logic_vector (3 downto 0);
    OP   : in std_logic_vector (3 downto 0);
    Ubit : in std_logic;
    Lbit : in std_logic;
    Ibit : in std_logic;
    N    : in std_logic;
    Z    : in std_logic;
    V    : in std_logic;
    C    : in std_logic;
    old_state: in integer range 0 to 9;
    new_state: out integer range 0 to 9;
    out_OP : out std_logic_vector (3 downto 0);
    PW   : out std_logic;
    RW   : out std_logic;
    MW   : out std_logic_vector (3 downto 0);
    IW   : out std_logic;
    AW   : out std_logic;
    BW   : out std_logic;
    DW   : out std_logic;
    ReW  : out std_logic;
    M2R  : out std_logic;
    IorD : out std_logic;
    Rsrc : out std_logic;
    Asrc1: out std_logic;
    Asrc2: out std_logic_vector (2 downto 0);
    Fset : out std_logic
);
END control_fsm;
 
ARCHITECTURE behavior OF control_fsm IS 

    signal predicate : std_logic := '0';
    
begin
    with Cond select	
    predicate <=  Z when "0000",
                  not Z when "0001",
                  C when "0010",
                  not C when "0011",
                  N when "0100",
                  not N when "0101",
                  V when "0110",
                  not V when "0111",
                  (C and (not Z)) when "1000",
                  ((not C) and Z) when "1001",
                  not (N xor V) when "1010",
                  (N xor V) when "1011",
                  not ((N xor V) or Z) when "1100",
                  ((N xor V) and Z) when "1101",
                  '1' when others;

process (old_state) is
begin

case old_state is
    
    when 1 =>
        MW <= "0000";
        IW <= '1';
        PW <= '0';
        Asrc1 <= '0';
        Asrc2 <= "000";
        RW    <= '0';
        AW    <= '0';
        BW    <= '0';
        DW    <= '0';
        ReW   <= '0';
        M2R   <= '0';
        IorD  <= '0';
        Rsrc  <= '0';
        Fset  <= '0';
        out_OP <= OP;

        new_state <= 2;

    when 2 =>
        Rsrc <= '0' when F="00"
            else '1';
        AW <= '1';
        BW <= '1';
        PW <= '1';
        out_OP <= "0101";   --add with carry
        Asrc1 <= '0';
        Asrc2 <= "001";
        RW    <= '0';
        MW    <= "0000";
        IW    <= '0';
        DW    <= '0';
        ReW   <= '0';
        M2R   <= '0';
        IorD  <= '0';
        Fset  <= '0';
        
        new_state <= 3 when F="00"
                else 4 when F="01" 
                else 5 when F="10";
    
    when 3 =>
        
        Asrc1 <= '1';
        Asrc2 <= "000" when Ibit = '0'
            else "100";
        ReW <= '1';
        Fset <= '0';  --done in next cycle
        PW    <= '0';
        RW    <= '0';
        MW    <= "0000";
        IW    <= '0';
        AW    <= '0';
        BW    <= '0';
        DW    <= '0';
        M2R   <= '0';
        IorD  <= '0';
        Rsrc  <= '0';
        out_OP <= OP;

        new_state <= 6;

    when 4 =>
        
        Asrc1 <= '1';
        Asrc2 <= "010";
        ReW <= '1';
        PW    <= '0';
        RW    <= '0';
        MW    <= "0000";
        IW    <= '0';
        AW    <= '0';
        BW    <= '0';
        DW    <= '0';
        M2R   <= '0';
        IorD  <= '0';
        Rsrc  <= '0';
        Fset  <= '0';
        out_OP <= OP;

        new_state <= 7 when Lbit='0'
                else 8;

    when 5 =>
                    
        Asrc1 <= '0';
        Asrc2 <= "011" when (F="10" and predicate='1');
        -- put alu carry_in as 1
        PW <= '1' when (F="10" and predicate='1');
        out_OP <= "0101";   --add with carry
        RW    <= '0';
        MW    <= "0000";
        IW    <= '0';
        AW    <= '0';
        BW    <= '0';
        DW    <= '0';
        ReW   <= '0';
        M2R   <= '0';
        IorD  <= '0';
        Rsrc  <= '0';
        Fset  <= '0';

        new_state <= 1; --check

    when 6 =>

        RW <= '0' when (OP="1010" or OP="1011" or OP="1000" or OP="1001")  --don't write when cmp/cmn/tst/teq
            else '1';
        M2R <= '0';
        Fset <= '1';
        PW    <= '0';
        MW    <= "0000";
        IW    <= '0';
        AW    <= '0';
        BW    <= '0';
        DW    <= '0';
        ReW   <= '0';
        IorD  <= '0';
        Rsrc  <= '0';
        Asrc1 <= '0';
        Asrc2 <= "000";
        out_OP <= OP;

        new_state <= 1;

    when 7 =>

        IorD <= '1';
        MW <= "1111";
        PW    <= '0';
        RW    <= '0';
        IW    <= '0';
        AW    <= '0';
        BW    <= '0';
        DW    <= '0';
        ReW   <= '0';
        M2R   <= '0';
        Rsrc  <= '0';
        Asrc1 <= '0';
        Asrc2 <= "000";
        Fset  <= '0';
        out_OP <= OP;

        new_state <= 1;

    when 8 =>

        IorD <= '1';
        MW <= "0000";
        DW <= '1';
        PW    <= '0';
        RW    <= '0';
        IW    <= '0';
        AW    <= '0';
        BW    <= '0';
        ReW   <= '0';
        M2R   <= '0';
        Rsrc  <= '0';
        Asrc1 <= '0';
        Asrc2 <= "000";
        Fset  <= '0';
        out_OP <= OP;

        new_state <= 9;

    when 9 =>

        RW <= '1';
        M2R <= '1';
        PW    <= '0';
        MW    <= "0000";
        IW    <= '0';
        AW    <= '0';
        BW    <= '0';
        DW    <= '0';
        ReW   <= '0';
        IorD  <= '0';
        Rsrc  <= '0';
        Asrc1 <= '0';
        Asrc2 <= "000";
        Fset  <= '0';
        out_OP <= OP;

        new_state <= 1;

    when others =>
        RW <= '0';
        M2R <= '0';
        PW    <= '0';
        MW    <= "0000";
        IW    <= '0';
        AW    <= '0';
        BW    <= '0';
        DW    <= '0';
        ReW   <= '0';
        IorD  <= '0';
        Rsrc  <= '0';
        Asrc1 <= '0';
        Asrc2 <= "000";
        Fset  <= '0';
        out_OP <= OP;

    end case;

end process;

end behavior;