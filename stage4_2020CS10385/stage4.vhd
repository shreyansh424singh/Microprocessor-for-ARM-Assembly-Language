LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
 
ENTITY Stage3 IS
port(clk, reset : in  std_logic);
END Stage3;
 
ARCHITECTURE behavior OF Stage3 IS 
 
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

    component control_fsm is
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
        end component;

    signal fsm_F    : std_logic_vector (1 downto 0) := "00";
    signal fsm_Cond : std_logic_vector (3 downto 0) := "0000";
    signal fsm_OP   : std_logic_vector (3 downto 0) := "0000";
    signal fsm_Ubit : std_logic := '0';
    signal fsm_Lbit : std_logic := '0';
    signal fsm_Ibit : std_logic := '0';
    signal fsm_N    : std_logic := '0';
    signal fsm_Z    : std_logic := '0';
    signal fsm_V    : std_logic := '0';
    signal fsm_C    : std_logic := '0';
    signal old_state:integer range 1 to 9 := 1;
    signal new_state:integer range 1 to 9 := 1;
    signal fsm_out_OP: std_logic_vector (3 downto 0) := "0000";
    signal PW   : std_logic := '0';
    signal RW   : std_logic := '0';
    signal MW   : std_logic_vector (3 downto 0) := "0000";
    signal IW   : std_logic := '0';
    signal AW   : std_logic := '0';
    signal BW   : std_logic := '0';
    signal DW   : std_logic := '0';
    signal ReW  : std_logic := '0';
    signal M2R  : std_logic := '0';
    signal IorD : std_logic := '0';
    signal Rsrc : std_logic := '0';
    signal Asrc1: std_logic := '0';
    signal Asrc2: std_logic_vector (2 downto 0) := "000";
    signal Fset : std_logic := '0';
    
signal F: std_logic_vector (1 downto 0) := "00";
signal OP, Cond : std_logic_vector (3 downto 0) := "0000";
signal Ubit, Lbit, Ibit : std_logic := '0';
signal Imm: std_logic_vector (7 downto 0) := "00000000"; 
signal Offset : std_logic_vector (11 downto 0) := x"000"; 
signal S_offset : std_logic_vector (23 downto 0) := x"000000";
signal Rd, Rn, Rm : std_logic_vector (3 downto 0) := "0000";
signal S_ext : std_logic_vector(5 downto 0);

signal PC, IR, DR, A, B, RES : std_logic_vector (31 downto 0) := x"00000000"; 

    begin
        DUT: ALU port map(alu_operand1, alu_operand2, alu_result, alu_carry_in, 
                alu_carry_out, alu_opcode);
        DUT1: Register_File_16x32 port map(rf_rd1, rf_rd2, rf_wd, rf_writeEnable, 
             rf_rad1, rf_rad2, rf_wad, rf_clk); 
        DUT2: Data_Memory_128x32 port map(dm_rd, dm_ad, dm_wd, dm_writeEnable,
             dm_clk);
        DUT3: flags port map(fg_Fset, fg_operation, fg_S, fg_carry_alu, fg_result_alu,
             fg_msb_alu_a, fg_msb_alu_b, fg_C, fg_N, fg_V, fg_Z);
        DUT4: control_fsm port map(fsm_F, fsm_Cond, fsm_OP, fsm_Ubit, fsm_Lbit,
            fsm_Ibit, fsm_N, fsm_Z, fsm_V, fsm_C, old_state, new_state, fsm_out_OP,
            PW, RW, MW, IW, AW, BW, DW, ReW, M2R, IorD, Rsrc, Asrc1, Asrc2, Fset);

    process (clk, reset) is
    begin
        -- updates the input signals of control_fsm
        if(rising_edge(clk)) then
            fsm_F <= F;
            fsm_Cond <= Cond;
            fsm_OP <= OP;
            fsm_Ubit <= Ubit;
            fsm_Lbit <= Lbit;
            fsm_Ibit <= Ibit;
            fsm_N <= fg_N;
            fsm_Z <= fg_Z;
            fsm_C <= fg_C;
            fsm_V <= fg_V;

            old_state <= new_state;
          end if;
          
        -- update pc register
          if(falling_edge(clk)) then 
          	PC <= (alu_result(29 downto 0) & "00") when PW = '1';           
          end if;
        --   reset pc when reset signal is 1
          if(reset = '1') then PC <= x"00000000"; end if;
    end process;
    
    -- update registers when write is enabled
    IR <= dm_rd when IW = '1';
    DR <= dm_rd when DW = '1';
    A <= rf_rd1 when AW = '1';
    B <= rf_rd2 when BW = '1';
    RES <= alu_result when ReW = '1';

    -- decode from the instruction
    F <= IR (27 downto 26); 
    OP <= IR (24 downto 21); 
    Cond <= IR (31 downto 28);
    Ibit <= IR (25); 
    Ubit <= IR (23); 
    Lbit <= IR (20);
    Imm <= IR (7 downto 0); 
    Offset <= IR (11 downto 0); 
    S_offset <= IR (23 downto 0);
    Rd <= IR(15 downto 12);
    Rn <= IR(19 downto 16);
    Rm <= IR(3 downto 0);
    S_ext <= "111111" when (S_offset(23) = '1') else "000000";

    -- update input signals of data memory
    dm_ad <= PC(7 downto 0) when IorD = '0'
        else (RES(7 downto 2) & "10");
    dm_wd <= B;
    dm_writeEnable <= MW;
    dm_clk <= clk;

    -- update input signals of register file
    rf_rad1 <= Rn;
    rf_rad2 <= Rm when Rsrc='0'
        else Rd;
    rf_wad <= Rd;
    rf_wd <= RES when M2R='0'
        else DR;
    rf_writeEnable <= RW;
    rf_clk <= clk;

    -- update input signals of ALU
    with Asrc1 select
    alu_operand1 <= ("00" & PC(31 downto 2)) when '0',
    rf_rd1 when others;

-- alu operand 2 can have 5 different values
    with Asrc2 select
    alu_operand2 <= rf_rd2 when "000",     --in DP instruction when Ibit is 0 eg. add r1, r2, r3
    x"00000000" when "001",                --4 will be added via carry_alu in pc register
    (x"00000" & offset) when "010",        --for DT instructions (load and store)
    ("00" & S_ext & S_offset) when "011",  --for branching adds this in pc
    (x"000000" & Imm) when others;         --in DP instruction when Ibit is 0 eg. add r1, r2, #3 

    alu_carry_in <= '1' when PW='1'
    	else fg_carry_alu;
    alu_opcode <= fsm_out_OP;

    -- update input signals of flags component
    fg_Fset <= Fset;
    fg_operation <= OP;
    fg_S <= '0';               --for this stage
    fg_carry_alu <= alu_carry_out;
    fg_result_alu <= alu_result;
    fg_msb_alu_a <= rf_rd1(31);
    fg_msb_alu_b <= rf_rd2(31);

end behavior;