LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
 
ENTITY Stage2 IS
port(clk : in  std_logic);
END Stage2;
 
ARCHITECTURE behavior OF Stage2 IS 
 
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

    component Data_Memory_64x32 is
        port (  
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

    component Program_Memory_64x32 is
        port (  
            rd        : out std_logic_vector(31 downto 0);
            ad        : in std_logic_vector(7 downto 0)
        ); 
    end component; 

    signal pm_rd        : std_logic_vector(31 downto 0) := (others => '0');
    signal pm_ad        : std_logic_vector(7 downto 0) := (others => '0');

    component flags is
        port (  
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

    component pc is 
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
    end component;

    signal pc_Cond : std_logic_vector(1 downto 0) := (others => '0');
    signal pc_F : std_logic_vector(1 downto 0) := (others => '0');
    signal pc_old_pc : std_logic_vector(31 downto 0) :=  x"00000000";
    signal pc_new_pc : std_logic_vector(31 downto 0) := x"00000000";
    signal pc_S_offset : std_logic_vector (23 downto 0) := (others => '0');
    signal pc_C : std_logic ;
    signal pc_N : std_logic ;
    signal pc_V : std_logic ;
    signal pc_Z : std_logic;
    
signal t1, t2 : std_logic := '0';
signal F, Cond: std_logic_vector (1 downto 0);
signal tempalu : std_logic_vector (31 downto 0) := x"00000000";
signal OP : std_logic_vector (3 downto 0);
signal Ubit, Lbit, Ibit : std_logic;
signal Imm: std_logic_vector (7 downto 0); 
signal Offset : std_logic_vector (11 downto 0); 
signal S_offset : std_logic_vector (23 downto 0);
signal Rd, Rn, Rm : std_logic_vector (3 downto 0);

    begin
        DUT: ALU port map(alu_operand1, alu_operand2, alu_result, alu_carry_in, 
                alu_carry_out, alu_opcode);
        DUT1: Register_File_16x32 port map(rf_rd1, rf_rd2, rf_wd, rf_writeEnable, 
             rf_rad1, rf_rad2, rf_wad, rf_clk); 
        DUT2: Data_Memory_64x32 port map(dm_rd, dm_ad, dm_wd, dm_writeEnable,
             dm_clk);
        DUT3: Program_Memory_64x32 port map(pm_rd, pm_ad);
        DUT4: flags port map(fg_operation, fg_S, fg_carry_alu, fg_result_alu,
             fg_msb_alu_a, fg_msb_alu_b, fg_C, fg_N, fg_V, fg_Z);
        DUT5: pc port map(pc_Cond, pc_F, pc_old_pc, pc_new_pc, pc_S_offset, pc_C, pc_N, pc_V, pc_Z);

    process (clk) is
    begin
        -- if(clk'event) then
-- 		if(rising_edge(clk)) then
        if(falling_edge(clk)) then 
        pc_Cond <= Cond;
        pc_F <= F;
        pc_old_pc <= pc_new_pc;
        pc_S_offset <= S_offset;
        pc_C <= fg_C;
        pc_N <= fg_N;
        pc_V <= fg_V;
        pc_Z <= fg_Z;
--         pct <= pc_new_pc;
        end if;

        if(falling_edge(clk)) then 
            if F = "00" then 
                if OP = "1010" then rf_writeEnable <= '0';   --don't write in cmp
                else rf_writeEnable <= '1';
                end if;
                rf_wd <= alu_result;
                rf_clk <= not(rf_clk);
            elsif F = "01" and Lbit = '1' then
                rf_wd <= dm_rd;
                rf_writeEnable <= '1';
                rf_clk <= not(rf_clk);
            else rf_writeEnable <= '0';
            end if;
        end if;
    end process;

        pm_ad <= pc_old_pc(7 downto 0);

        F <= pm_rd (27 downto 26); 
        OP <= pm_rd (24 downto 21); 
        Cond <= pm_rd (29 downto 28);
        Ibit <= pm_rd (25); 
        Ubit <= pm_rd (23); 
        Lbit <= pm_rd (20);
        Imm <= pm_rd (7 downto 0); 
        Offset <= pm_rd (11 downto 0); 
        S_offset <= pm_rd (23 downto 0);
        Rd <= pm_rd(15 downto 12);
        Rn <= pm_rd(19 downto 16);
        Rm <= pm_rd(3 downto 0);

        rf_rad1 <= Rn;
        rf_rad2 <= Rd when (F="01") 
                   else Rm;
        rf_wad <= Rd;

        alu_operand1 <= rf_rd1 when (F = "00")
                   else (x"0000000" & Rn) when (F = "01")
                   else x"00000000";
        alu_operand2 <= rf_rd2 when (F = "00" and Ibit = '0')
                   else (x"000000" & Imm) when (F = "00" and Ibit = '1')
                   else (x"00000" & offset) when (F = "01")
                   else x"00000000";
        alu_opcode <= OP when (F = "00")
                   else "0100" when (F="01" and Ubit='1')   
                   else "0010" when (F="01" and Ubit='1')   
                   else "0000"; 
        alu_carry_in <= fg_C;

-- ADD CONTROL SIGNAL FOR FLAG AND OTHERS
        fg_operation <= OP when (F="00")
                else "0000";
        fg_S <= '1' when (OP = "1010" and F="00")
                else '0';       
        fg_carry_alu <= alu_carry_out when (F="00")
                else '0';
        fg_result_alu <= alu_result when (F="00")
                else x"00000000";
        fg_msb_alu_a <= rf_rd1(31) when (F="00")
                else '0';
        fg_msb_alu_b <= rf_rd2(31) when (F="00")
                else '0';

        dm_ad <= alu_result(7 downto 0) when (F="01")
                else "00000000";
        dm_wd <= rf_rd2 when (F="01")
                else x"00000000";
        dm_writeEnable <= "1111" when (F="01" and Lbit = '0')
                else "0000";
        dm_clk <= clk;
--         dm_clk <= not(t1) when (F="01" and Lbit = '0');
        -- t1 <= dm_clk;

-- tempalu <= alu_result;
--  rf_wd <= alu_result  MAKES CYCLIC DEPENDENCY BETWEEN RF AND ALU DON'T KNOW HOW TO AVOID IT. 
--  REST CODE IS PERFECT
--         rf_wd <= x"00000008" when (F = "00")
--                 else dm_rd when (F = "10")
--                 else x"00000000";
-- --         rf_clk <= not(t2);
--         -- t2 <= rf_clk;
--         rf_writeEnable <= '1' when (F="01" and Lbit = '1')
--                 else '1' when (F="00" and OP /= "1010")
--                 else '0';

end behavior;