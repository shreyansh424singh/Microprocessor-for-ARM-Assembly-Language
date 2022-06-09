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
-- signal pct : std_logic_vector (31 downto 0) := x"00000000";
signal OP : std_logic_vector (3 downto 0);
signal Ubit, Lbit, Ibit : std_logic;
signal Imm: std_logic_vector (7 downto 0); 
signal Offset : std_logic_vector (11 downto 0); 
signal S_offset : std_logic_vector (23 downto 0);
signal Rd, Rn, Rm : std_logic_vector (3 downto 0);

    begin
        DUT: ALU port map(operand1 => alu_operand1, operand2 => alu_operand2, 
                result => alu_result, carry_in => alu_carry_in, 
                carry_out => alu_carry_out, opcode => alu_opcode);
        DUT1: Register_File_16x32 port map(rf_rd1, rf_rd2, rf_wd, rf_writeEnable, 
             rf_rad1, rf_rad2, rf_wad, rf_clk); 
        DUT2: Data_Memory_64x32 port map(dm_rd, dm_ad, dm_wd, dm_writeEnable,
             dm_clk);
        DUT3: Program_Memory_64x32 port map(pm_rd, pm_ad);
        DUT4: flags port map(fg_operation, fg_S, fg_carry_alu, fg_result_alu,
             fg_msb_alu_a, fg_msb_alu_b, fg_C, fg_N, fg_V, fg_Z);
        DUT5: pc port map(pc_Cond, pc_F, pc_old_pc, pc_new_pc, pc_S_offset, pc_C, pc_N, pc_V, pc_Z);

    process (clk) is
        variable counter: integer range 0 to 16 := 0;
        variable pct : std_logic_vector (31 downto 0) := x"00000000";
    begin
    
        counter := counter + 1;
        if counter = 8 then 
        	t1 <= not(t1);
if t1 = '1' then t2 <= not(t2); end if;
        	counter := 0;
        end if;

if t1 = '1' then

        pm_ad <= pct(7 downto 0);

if t2 = '1' or pc_old_pc = x"00000000" then	
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

if counter = 3 then
        rf_rad1 <= Rn;
        if F = "01" then rf_rad2 <= Rd;
        else rf_rad2 <= Rm;
        end if;
        rf_wad <= Rd;
end if;     
            
if counter = 4 then      
        if F = "01" then 
            alu_operand1 <= (x"0000000" & Rn);
            alu_operand2 <= (x"00000" & offset);
            if Ubit = '1' then 
                alu_opcode <= "0100";              --0100 is for add alu 
            else 
                alu_opcode <= "0010";              --0010 for sub
            end if;
        elsif F = "00" then
            alu_operand1 <= rf_rd1;
            alu_opcode <= OP;
            if Ibit = '0' then
                alu_operand2 <= rf_rd2;
            else 
                alu_operand2 <= (x"000000" & Imm);
            end if;
        end if;
        alu_carry_in <= fg_C;
end if;

            -- set flags
if counter = 5 then       
        if F = "00" then
            fg_operation <= OP;
            -- S value is set for stage2 only it will be different later
            if OP = "1010" then fg_S <= '1';
            else fg_S <= '0';
            end if;
            -- fg_S <= '1' when (OP = "1010") else '0';   --S is 1 for compare else 0
            fg_carry_alu <= alu_carry_out;
            fg_result_alu <= alu_result;
            fg_msb_alu_a <= rf_rd1(31);
            fg_msb_alu_b <= rf_rd2(31);
        end if;
end if;

if counter = 6 then
        if F = "01" then
            dm_ad <= alu_result(7 downto 0);
            dm_wd <= rf_rd2;
            if Lbit = '1' then        --means ldr instruction
                dm_writeEnable <= "0000";
            else                      -- str instruction
                dm_writeEnable <= "1111";
                dm_clk <= not(dm_clk);
            end if;
        end if;
end if;        
        

if counter = 7 then
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

end if;

if counter = 0 then
    pc_Cond <= Cond;
    pc_F <= F;
    pc_old_pc <= pct;
    pc_S_offset <= S_offset;
    pc_C <= fg_C;
    pc_N <= fg_N;
    pc_V <= fg_V;
    pc_Z <= fg_Z;
    pct := pc_new_pc;
end if;  

end if;

    end process;
end behavior;