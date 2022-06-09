LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
 
ENTITY Stage6 IS
port(clk, reset : in  std_logic);
END Stage6;
 
ARCHITECTURE behavior OF Stage6 IS 
 
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

    signal alu_operand1: std_logic_vector(31 downto 0) := (others => '0');
    signal alu_operand2: std_logic_vector(31 downto 0) := (others => '0');
    signal alu_result: std_logic_vector(31 downto 0) := (others => '0');
    signal alu_carry_in: std_logic := '0';
    signal alu_carry_out: std_logic := '0';
    signal alu_opcode: std_logic_vector(3 downto 0) := (others => '0');

    component Register_File_16x32 is
    port (  
        rd1        : out std_logic_vector(31 downto 0);
        rd2        : out std_logic_vector(31 downto 0);
        wd         : in  std_logic_vector(31 downto 0);
        writeEnable : in  std_logic;
        rad1     : in  std_logic_vector(3 downto 0);
        rad2     : in  std_logic_vector(3 downto 0);
        wad      : in  std_logic_vector(3 downto 0);
        clk      : in  std_logic
    ); 
    end component; 

    signal rf_rd1:     std_logic_vector (31 downto 0) := (others => '0');
    signal rf_rd2:     std_logic_vector (31 downto 0) := (others => '0');
    signal rf_wd:       std_logic_vector (31 downto 0) := (others => '0');
    signal rf_writeEnable: std_logic := '0';
    signal rf_rad1:     std_logic_vector (3 downto 0) := (others => '0');
    signal rf_rad2:     std_logic_vector (3 downto 0) := (others => '0');
    signal rf_wad:     std_logic_vector (3 downto 0) := (others => '0');
    signal rf_clk:  std_logic := '0';

    component Data_Memory_128x32 is
        port(
            rd        : out std_logic_vector(31 downto 0);
            ad        : in std_logic_vector(7 downto 0);
            wd         : in  std_logic_vector(31 downto 0);
            writeEnable : in  std_logic_vector(3 downto 0);
            clk      : in  std_logic
        );
        end component; 

    signal dm_rd        : std_logic_vector(31 downto 0) := (others => '0');
    signal dm_ad        : std_logic_vector(7 downto 0) := (others => '0');
    signal dm_wd         :  std_logic_vector(31 downto 0) := (others => '0');
    signal dm_writeEnable :  std_logic_vector(3 downto 0) := (others => '0');
    signal dm_clk      :  std_logic := '0';

    component Shifter is
        port(
            data_in     : in  std_logic_vector(31 downto 0);
            data_out    : out std_logic_vector(31 downto 0);
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

    component flags is
        port (  
            Fset : in std_logic;
            operation : in std_logic_vector(3 downto 0);
            S : in std_logic;
            carry_alu : in std_logic;
            result_alu: in std_logic_vector(31 downto 0);
            msb_alu_a : in std_logic; 
            msb_alu_b : in std_logic;
            C : out std_logic;
            N : out std_logic;
            V : out std_logic;
            Z : out std_logic
        ); 
    end component; 

    signal fg_Fset : std_logic := '0';
    signal fg_operation : std_logic_vector(3 downto 0) := (others => '0');
    signal fg_S : std_logic := '0';
    signal fg_carry_alu : std_logic := '0';
    signal fg_result_alu: std_logic_vector(31 downto 0) := (others => '0');
    signal fg_msb_alu_a : std_logic := '0';
    signal fg_msb_alu_b : std_logic := '0';
    signal fg_C : std_logic := '0';
    signal fg_N : std_logic := '0';
    signal fg_V : std_logic := '0';
    signal fg_Z : std_logic := '0';


    component PMconnect is
        port(
          Adr      : in  std_logic_vector(1 downto 0);
          Ins      : in  std_logic_vector(3 downto 0);
          Rout     : in  std_logic_vector(31 downto 0);
          Rin      : out std_logic_vector(31 downto 0);
          Mout     : in  std_logic_vector(31 downto 0);
          Min      : out std_logic_vector(31 downto 0);
          MW       : out std_logic_vector(3 downto 0)
        );
    end component;

    signal pmc_Adr   : std_logic_vector(1 downto 0) := "00";
    signal pmc_Ins   : std_logic_vector(3 downto 0) := "0000";
    signal pmc_Rout  : std_logic_vector(31 downto 0) := x"00000000";
    signal pmc_Rin   : std_logic_vector(31 downto 0) := x"00000000";
    signal pmc_Mout  : std_logic_vector(31 downto 0) := x"00000000";
    signal pmc_Min   : std_logic_vector(31 downto 0) := x"00000000";
    signal pmc_MW    : std_logic_vector(3 downto 0) := "0000";


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

    signal mul_Ins      : std_logic_vector(3 downto 0) := x"0";
    signal mul_RdHi     : std_logic_vector(31 downto 0) := x"00000000";
    signal mul_RdLo     : std_logic_vector(31 downto 0) := x"00000000";
    signal mul_Rs       : std_logic_vector(31 downto 0) := x"00000000";
    signal mul_Rm       : std_logic_vector(31 downto 0) := x"00000000";
    signal mul_result   : std_logic_vector(63 downto 0) := x"0000000000000000";

    component control_fsm is
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
            M2R  : out std_logic_vector(1 downto 0);
            IorD : out std_logic_vector(1 downto 0);
            Dsrc : out std_logic_vector(1 downto 0);
            Tsrc : out std_logic;
            AMsrc : out std_logic_vector(1 downto 0);
            Rsrc2 : out std_logic_vector(1 downto 0);
            Wsrc : out std_logic;
            Asrc1: out std_logic;
            Asrc2: out std_logic_vector (2 downto 0);
            MulIns: out std_logic_vector (3 downto 0);
            Rsrc1 : out std_logic; 
            EW   : out std_logic;
            Fset : out std_logic
        );
        end component;

    signal fsm_Inst : std_logic_vector (31 downto 0) := x"00000000";
    signal fsm_pmIns : std_logic_vector (3 downto 0) := "0000";
    signal fsm_F    : std_logic_vector (1 downto 0) := "00";
    signal fsm_Cond : std_logic_vector (3 downto 0) := "0000";
    signal fsm_OP   : std_logic_vector (3 downto 0) := "0000";
    signal fsm_regOr: std_logic := '0';
    signal fsm_Pbit : std_logic := '0';
    signal fsm_Wbit : std_logic := '0';
    signal fsm_Bbit : std_logic := '0';
    signal fsm_Ubit : std_logic := '0';
    signal fsm_Lbit : std_logic := '0';
    signal fsm_Ibit : std_logic := '0';
    signal fsm_N    : std_logic := '0';
    signal fsm_Z    : std_logic := '0';
    signal fsm_V    : std_logic := '0';
    signal fsm_C    : std_logic := '0';
    signal old_state:integer range 1 to 14 := 1;
    signal new_state:integer range 1 to 14 := 1;
    signal fsm_out_OP: std_logic_vector (3 downto 0) := "0000";
    signal PW       : std_logic := '0';
    signal RW       : std_logic := '0';
    signal CW       : std_logic := '0';
    signal SW       : std_logic := '0';
    signal MW       : std_logic_vector (3 downto 0) := "0000";
    signal IW       : std_logic := '0';
    signal AW       : std_logic := '0';
    signal BW       : std_logic := '0';
    signal DW       : std_logic := '0';
    signal ReW      : std_logic := '0';
    signal M2R      : std_logic_vector(1 downto 0) := "00";
    signal IorD     : std_logic_vector(1 downto 0) := "00";
    signal Dsrc     : std_logic_vector(1 downto 0) := "00";
    signal Tsrc     : std_logic := '0';
    signal AMsrc    : std_logic_vector(1 downto 0) := "00";
    signal Rsrc2    : std_logic_vector(1 downto 0) := "00";
    signal Wsrc     : std_logic := '0';
    signal Asrc1    : std_logic := '0';
    signal Asrc2    : std_logic_vector (2 downto 0) := "000";
    signal MulIns   : std_logic_vector (3 downto 0) := "0000";
    signal Rsrc1    : std_logic := '0';
    signal EW       : std_logic := '0';
    signal Fset     : std_logic := '0';
    
signal F, shift_type: std_logic_vector (1 downto 0) := "00";
signal OP, Cond : std_logic_vector (3 downto 0) := "0000";
signal Ubit, Lbit, Ibit, Pbit, Wbit, Bbit, regOrCons : std_logic := '0';
signal Imm: std_logic_vector (7 downto 0) := "00000000"; 
signal Offset : std_logic_vector (11 downto 0) := x"000"; 
signal Updated_Offset, Updated_imm : std_logic_vector (31 downto 0) := x"00000000"; 
signal S_offset : std_logic_vector (23 downto 0) := x"000000";
signal Rd, Rn, Rm, Rs : std_logic_vector (3 downto 0) := "0000";
signal S_ext : std_logic_vector(5 downto 0) := "000000";
signal Cons, rot : std_logic_vector(4 downto 0) := "00000";
signal half_word : std_logic := '0';

signal PC, IR, DR, A, B, C, S, RES, UO : std_logic_vector (31 downto 0) := x"00000000"; 

    begin
        DUT: ALU port map(alu_operand1, alu_operand2, alu_result, alu_carry_in, 
                alu_carry_out, alu_opcode);
        DUT1: Register_File_16x32 port map(rf_rd1, rf_rd2, rf_wd, rf_writeEnable, 
             rf_rad1, rf_rad2, rf_wad, rf_clk); 
        DUT2: Data_Memory_128x32 port map(dm_rd, dm_ad, dm_wd, dm_writeEnable,
             dm_clk);
        DUT3: flags port map(fg_Fset, fg_operation, fg_S, fg_carry_alu, fg_result_alu,
             fg_msb_alu_a, fg_msb_alu_b, fg_C, fg_N, fg_V, fg_Z);
        DUT4: control_fsm port map(fsm_Inst, fsm_pmIns, fsm_F, fsm_Cond, fsm_OP, fsm_regOr,
            fsm_Pbit, fsm_Wbit, fsm_Bbit, fsm_Ubit, fsm_Lbit,fsm_Ibit, 
            fsm_N, fsm_Z, fsm_V, fsm_C, old_state, new_state, fsm_out_OP,
            PW, RW, CW, SW, MW, IW, AW, BW, DW, ReW, M2R, IorD, Dsrc, Tsrc, AMsrc, Rsrc2, Wsrc, 
            Asrc1, Asrc2, MulIns, Rsrc1, EW, Fset);
        DUT5: Shifter port map(data_in, data_out, carry_outa, typea, amount); 
        DUT6: PMconnect port map(pmc_Adr, pmc_Ins, pmc_Rout, pmc_Rin, pmc_Mout, pmc_Min, pmc_MW); 
--         DUT7: Mul port map (mul_Ins, mul_RdHi, mul_RdLo, mul_Rs, mul_Rm, mul_result); 
        DUT7: Mul port map (mul_Ins, mul_RdHi, mul_RdLo, mul_Rs, C, mul_result); 

    process (clk, reset) is
    begin
        -- updates the input signals of control_fsm
        if(rising_edge(clk)) then
            fsm_Inst <= IR;
            fsm_F <= F;
            fsm_Cond <= Cond;
            fsm_OP <= OP;
            fsm_regOr <= regOrCons;
            fsm_Pbit <= Pbit;
            fsm_Wbit <= Wbit;
            fsm_Bbit <= Bbit;
            fsm_Ubit <= Ubit;
            fsm_Lbit <= Lbit;
            fsm_Ibit <= Ibit;
            fsm_N <= fg_N;
            fsm_Z <= fg_Z;
            fsm_C <= fg_C;
            fsm_V <= fg_V;

            old_state <= new_state;
      
			B <= rf_rd2 when BW = '1'                         
            	else S when (Dsrc="00" and SW='1');    --when shifter is used
          	PC <= (alu_result(29 downto 0) & "00") when PW = '1'; 

        end if;

        --   reset pc when reset signal is 1
          if(reset = '1') then PC <= x"00000000"; end if;
    end process;
    
    -- update registers when write is enabled
    IR <= dm_rd when IW = '1';
    DR <= dm_rd when DW = '1';
    A <= rf_rd1 when AW = '1';
    C <= rf_rd2 when CW = '1';
    S <= data_out when SW = '1';
    UO <= Updated_Offset when SW='1';
    RES <= alu_result when ReW = '1';

    -- decode from the instruction
    F <= IR (27 downto 26); 
    OP <= IR (24 downto 21); 
    Cond <= IR (31 downto 28);
    Ibit <= IR (25); 
    Pbit <= IR (24); 
    Ubit <= IR (23); 
    Bbit <= IR (22); 
    Wbit <= IR (21); 
    Lbit <= IR (20);
    shift_type <= IR (6 downto 5);
    regOrCons <= IR (4);
    Rs <= IR (11 downto 8);
    rot <= (IR (11 downto 8) & "0");
    Cons <= IR (11 downto 7);
    Imm <= IR (7 downto 0); 
    Offset <= IR (11 downto 0) when half_word='0'
         else ("0000" & IR(11 downto 8) & IR(3 downto 0)); 
    S_offset <= IR (23 downto 0);
    Rd <= IR(15 downto 12);
    Rn <= IR(19 downto 16);
    Rm <= IR(3 downto 0);
    S_ext <= "111111" when (S_offset(23) = '1') else "000000";
    half_word <= '1' when (IR(27 downto 25)="000" and IR(7)='1' and IR(4)='1');

    -- update input signals of data memory
    dm_ad <= (RES(7 downto 2) & "10") when IorD = "01"
        else (A(7 downto 2) & "10") when (IorD = "10" and Pbit='0')
        else PC(7 downto 0) when IorD = "00";
    dm_wd <= pmc_Min;
    dm_writeEnable <= pmc_MW when MW="1111"
                 else "0000";
    dm_clk <= clk;

    -- update input signals of register file
    rf_rad1 <= Rn when Rsrc1 = '0'
          else Rs;
    rf_rad2 <= Rm when Rsrc2="00"
        else Rd when Rsrc2="01"
        else Rs;
    rf_wad <= Rn when Wsrc='1'     --for write back in DT instructions
         else Rd;
    rf_wd <= RES when M2R="00"
        else DR when M2R="01"
        else mul_result(63 downto 32) when M2R="10"
        else mul_result(31 downto 0);
    rf_writeEnable <= RW;
    rf_clk <= clk;

--     update input signals of shifter
    typea <= shift_type when Tsrc='0'
        else "11";                           --ROR when Rotate operation on constant
    amount <= ("000" & Cons) when AMsrc="00" --Constant value
        else C(7 downto 0) when AMsrc="01"   --Read from register
        else ("000" & rot);                  --when Rotate operation on constant
    data_in <= B when Dsrc="00"              --DP instruction
          else C when Dsrc="01"              --DT instruction
          else (x"000000" & Imm);            --when Rotate operation on constant
    Updated_Offset <= S when (Dsrc="01" and SW='1' and Ibit='1')    --when shifter is used
                else C when (half_word='1' and Bbit='0')
                else (x"00000" & Offset);
    Updated_imm <= S when SW='1';

    -- update input signals of ALU
    with Asrc1 select
    alu_operand1 <= ("00" & PC(31 downto 2)) when '0',
                    A when others;
-- alu operand 2 can have 5 different values
    with Asrc2 select
    alu_operand2 <= B when "000",          --in DP instruction when Ibit is 0 eg. add r1, r2, r3
    x"00000000" when "001",                --4 will be added via carry_alu in pc register
    UO when "010",             --for DT instructions (load and store)
    ("00" & S_ext & S_offset) when "011",  --for branching adds this in pc
    Updated_imm when others;         --in DP instruction when Ibit is 0 eg. add r1, r2, #3 

    alu_carry_in <= '1' when PW='1'
    	    else fg_carry_alu;
    alu_opcode <= fsm_out_OP;

--     update input signals of flags component
    fg_Fset <= Fset;
    fg_operation <= OP;
    fg_S <= IR(20);
    fg_carry_alu <= alu_carry_out;
    fg_result_alu <= alu_result;
    fg_msb_alu_a <= rf_rd1(31);
    fg_msb_alu_b <= rf_rd2(31);

    -- update input signals of PMconnect component
    pmc_Rout <= B;
    pmc_Mout <= DR;
    pmc_Ins  <= fsm_pmIns;
    pmc_Adr  <= A(1 downto 0);

    mul_Ins <= MulIns;
    mul_RdHi <= A;
    mul_RdLo <= B;
    mul_Rs   <= rf_rd1 when EW = '1';

end behavior;	