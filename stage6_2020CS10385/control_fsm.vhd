LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
 
ENTITY control_fsm IS
port(
    Inst : in std_logic_vector (31 downto 0);
    pmIns : out std_logic_vector (3 downto 0);
    F    : in std_logic_vector (1 downto 0);
    Cond : in std_logic_vector (3 downto 0);
    OP   : in std_logic_vector (3 downto 0);
    regOrCons : in std_logic;
    Pbit : in std_logic;
    Wbit : in std_logic;
    Bbit : in std_logic;
    Ubit : in std_logic;
    Lbit : in std_logic;
    Ibit : in std_logic;
    N    : in std_logic;
    Z    : in std_logic;
    V    : in std_logic;
    C    : in std_logic;
    old_state: in integer range 0 to 14;
    new_state: out integer range 0 to 14;
    out_OP : out std_logic_vector (3 downto 0);
    PW   : out std_logic;
    RW   : out std_logic;
    CW   : out std_logic;
    SW   : out std_logic;
    MW   : out std_logic_vector (3 downto 0);
    IW   : out std_logic;
    AW   : out std_logic;
    BW   : out std_logic;
    DW   : out std_logic;
    ReW  : out std_logic;
    M2R  : out std_logic;
    IorD : out std_logic_vector(1 downto 0);
    Dsrc : out std_logic_vector(1 downto 0);
    Tsrc : out std_logic;
    AMsrc : out std_logic_vector(1 downto 0);
    Rsrc : out std_logic_vector(1 downto 0);
    Wsrc : out std_logic;
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
        IorD  <= "00";
        Rsrc  <= "00";
        Fset  <= '0';
        out_OP <= OP;
        CW    <= '0';
        SW    <= '0';
        Dsrc  <= "00";
        Wsrc  <= '0';
        AMsrc <= "00";
        Tsrc  <= '0';
        pmIns <= x"8";

        new_state <= 2;

    when 2 =>
        Rsrc <= "00" when F="00"
            else "01";
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
        IorD  <= "00";
        Fset  <= '0';
        CW    <= '0';
        SW    <= '0';
        Dsrc  <= "00";
        Wsrc  <= '0';
        AMsrc  <= "00";
        Tsrc  <= '0';
        pmIns <= x"8";
        
        new_state <= 4 when F="10"
                else 3;


    when 3 =>
        CW <= '1';
        Rsrc  <= "00" when (F="01" or (Inst(27 downto 25)="000" and Inst(7)='1' and Inst(4)='1'))   --read Rm
            else "10";              --read Rs
        RW    <= '0';
        M2R   <= '0';
        PW    <= '0';
        MW    <= "0000";
        IW    <= '0';
        AW    <= '0';
        BW    <= '0';
        DW    <= '0';
        ReW   <= '0';
        IorD  <= "00";
        Asrc1 <= '0';
        Asrc2 <= "000";
        Fset  <= '0';
        out_OP <= OP;
        SW    <= '0';     
        Dsrc  <= "00";
        Wsrc  <= '0';
        AMsrc <= "00";  
        Tsrc  <= '0';   
        pmIns <= x"8";

        new_state <= 5 when (F="00" and (not(Inst(4)='1' and Inst(7)='1')))
                else 6;

    when 4 =>
                    
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
        IorD  <= "00";
        Rsrc  <= "00";
        Fset  <= '0';
        CW    <= '0';
        SW    <= '0';
        Dsrc  <= "00";
        Wsrc  <= '0';
        AMsrc  <= "00";
        Tsrc  <= '0';
        pmIns <= x"8";

        new_state <= 1; --check

    when 5 =>
        
        SW <= '1';
        Dsrc  <= "10" when (Ibit='1' and F="00") --when rotate operation on constant pass imm to shifter
            else "00";                           --pass register B to shifter
        Tsrc  <= '1' when (Ibit='1' and F="00")  --when rotate operation on constant
            else '0';
        AMsrc <= "10" when (Ibit='1' and F="00") --when rotate operation on constant
            else "00" when regOrCons='0'         --amount from constant
            else "01";                           --amount from register
        RW    <= '0';
        M2R   <= '0';
        PW    <= '0';
        MW    <= "0000";
        IW    <= '0';
        AW    <= '0';
        BW    <= '0';
        DW    <= '0';
        ReW   <= '0';
        IorD  <= "00";
        Rsrc  <= "00";
        Wsrc  <= '0';
        Asrc1 <= '0';
        Asrc2 <= "000";
        Fset  <= '0';
        out_OP <= OP;
        CW    <= '0';
        pmIns <= x"8";

        new_state <= 7;


    when 6 =>
        
        SW <= '1';
        Dsrc  <= "01";      --pass register C to shifter
        Tsrc  <= '0';
        AMsrc <= "00"; 
        RW    <= '0';
        M2R   <= '0';
        PW    <= '0';
        MW    <= "0000";
        IW    <= '0';
        AW    <= '0';
        BW    <= '0';
        DW    <= '0';
        ReW   <= '0';
        IorD  <= "00";
        Rsrc  <= "00";
        Wsrc  <= '0';
        Asrc1 <= '0';
        Asrc2 <= "000";
        Fset  <= '0';
        out_OP <= OP;
        CW    <= '0';
        pmIns <= x"8";

        new_state <= 8;


                    
    when 7 =>
        
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
        IorD  <= "00";
        Rsrc  <= "00";
        out_OP <= OP;
        CW    <= '0';
        SW    <= '0';
        Dsrc  <= "00";
        Wsrc  <= '0';
        AMsrc  <= "00";
        Tsrc  <= '0';
        pmIns <= x"8";

        new_state <= 9;

    when 8 =>
        
        Asrc1 <= '1';
        Asrc2 <= "010";
        out_OP <= "0100" when Ubit='1'
             else "0010";
        ReW <= '1';
        PW    <= '0';
        RW    <= '0';
        MW    <= "0000";
        IW    <= '0';
        AW    <= '0';
        BW    <= '0';
        DW    <= '0';
        M2R   <= '0';
        IorD  <= "00";
        Rsrc  <= "00";
        Fset  <= '0';
        CW    <= '0';
        SW    <= '0';
        Dsrc  <= "00";
        Wsrc  <= '0';
        AMsrc  <= "00";
        Tsrc  <= '0';
        pmIns <= x"8";

        -- new_state <= 10 when Lbit='0'
        --         else 11;
        new_state <= 13;


    when 13 =>
    
        Wsrc  <= '1' when (Wbit='1' or Pbit='0')       -- for write back when wbit is 1 or it is post indexing
            else '0';
        RW  <= '1' when (Wbit='1' or Pbit='0')       -- for write back when wbit is 1 or it is post indexing
            else '0';
        pmIns <= x"8";
        M2R <= '0';
        PW    <= '0';
        MW    <= "0000";
        IW    <= '0';
        AW    <= '0';
        BW    <= '0';
        DW    <= '0';
        ReW   <= '0';
        IorD  <= "00";
        Rsrc  <= "00";
        Asrc1 <= '0';
        Asrc2 <= "000";
        Fset  <= '0';
        out_OP <= OP;
        CW    <= '0';
        SW    <= '0';
        Dsrc  <= "00";
        AMsrc <= "00";
        Tsrc  <= '0';

        new_state <= 10 when Lbit='0'
                else 11;



    when 9 =>

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
        IorD  <= "00";
        Rsrc  <= "00";
        Asrc1 <= '0';
        Asrc2 <= "000";
        out_OP <= OP;
        CW    <= '0';
        SW    <= '0';
        Dsrc  <= "00";
        Wsrc  <= '0';
        AMsrc  <= "00";
        Tsrc  <= '0';
        pmIns <= x"8";

        new_state <= 1;

    when 10 =>

        IorD <= "01" when Pbit='1'
           else "10";
        MW <= "1111";
        pmIns <= x"1" when (Lbit='0' and Inst(7 downto 4)="1011")
            else x"0" when (Lbit='0' and Bbit='0')
            else x"2" when (Lbit='0' and Bbit='1')
            else x"8";
        PW    <= '0';
        RW    <= '0';
        IW    <= '0';
        AW    <= '0';
        BW    <= '0';
        DW    <= '0';
        ReW   <= '0';
        M2R   <= '0';
        Rsrc  <= "00";
        Asrc1 <= '0';
        Asrc2 <= "000";
        Fset  <= '0';
        out_OP <= OP;
        CW    <= '0';
        SW    <= '0';
        Dsrc  <= "00";
        Wsrc  <= '0';
        AMsrc  <= "00";
        Tsrc  <= '0';

        new_state <= 1;

    when 11 =>

        IorD <= "01" when Pbit='1'
           else "10";
        MW <= "0000";
        DW <= '1';
        pmIns <= x"8";
        PW    <= '0';
        RW    <= '0';
        IW    <= '0';
        AW    <= '0';
        BW    <= '0';
        ReW   <= '0';
        M2R   <= '0';
        Rsrc  <= "00";
        Asrc1 <= '0';
        Asrc2 <= "000";
        Fset  <= '0';
        out_OP <= OP;
        CW    <= '0';
        SW    <= '0';
        Dsrc  <= "00";
        Wsrc  <= '0';
        AMsrc  <= "00";
        Tsrc  <= '0';

        new_state <= 12;

    when 12 =>

        RW <= '1';
        M2R <= '1';
        pmIns <= x"4" when (Lbit='1' and Inst(7 downto 4)="1011")  --ldrh
           else  x"7" when (Lbit='1' and Inst(7 downto 4)="1101")  --ldrsb
           else  x"5" when (Lbit='1' and Inst(7 downto 4)="1111")  --ldrsh
           else  x"3" when (Lbit='1' and Bbit='0')  --ldr
           else  x"6" when (Lbit='1' and Bbit='1')  --ldrb
           else  x"8";
        PW    <= '0';
        MW    <= "0000";
        IW    <= '0';
        AW    <= '0';
        BW    <= '0';
        DW    <= '0';
        ReW   <= '0';
        IorD  <= "00";
        Rsrc  <= "00";
        Asrc1 <= '0';
        Asrc2 <= "000";
        Fset  <= '0';
        out_OP <= OP;
        CW    <= '0';
        SW    <= '0';
        Dsrc  <= "00";
        Wsrc  <= '0';
        AMsrc  <= "00";
        Tsrc  <= '0';

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
        IorD  <= "00";
        Rsrc  <= "00";
        Asrc1 <= '0';
        Asrc2 <= "000";
        Fset  <= '0';
        out_OP <= OP;
        CW    <= '0';
        SW    <= '0';
        Dsrc  <= "00";
        Wsrc  <= '0';
        AMsrc  <= "00";
        Tsrc  <= '0';
        pmIns <= x"8";

        new_state <= 1;

    end case;

end process;

end behavior;