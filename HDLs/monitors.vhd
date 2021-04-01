library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ctu_pack.all;

entity monitors is
    Port ( 
    clk_i : in STD_LOGIC;
    rst_i : in STD_LOGIC;
    read_reg : in std_logic;
    vp_in : in std_logic;
    vn_in : in std_logic;
    temp_die_reg : out std_logic_vector(11 downto 0);
    vccint_reg : out std_logic_vector(11 downto 0);
    vccaux_reg : out std_logic_vector(11 downto 0)
    );
end monitors;

architecture Behavioral of monitors is
    
    constant TEMP_DIE : std_logic_vector(6 downto 0) := "0000000";
    constant VCCINT : std_logic_vector(6 downto 0) := "0000001";
    constant VCCAUX : std_logic_vector(6 downto 0) := "0000010";
    type t_state is (st0_idle,st1_start,st2_sendAddr,st_read,st_read1,st_read2,
                    st_write,st_dread,st_dread1,st_dread2);
    signal state,state_after_sendAddr :t_state;
    signal read_reg_r,read_reg_s,error : std_logic;
    signal temp_reg : t_array16(2 downto 0);
    signal sel : integer range 0 to 3 := 0;
    signal daddr : std_logic_vector(6 downto 0);
    signal den,drdy : std_logic;
    signal do : std_logic_vector(15 downto 0);
begin
-- find rising_edge of read_reg
P_read_start:process(clk_i)
begin
    if rising_edge(clk_i) then
        read_reg_r <= read_reg;
        if read_reg = '1' and read_reg_r = '0' then
            read_reg_s <= '1';
        else
            read_reg_s <= '0';
        end if;
    end if;
end process;
    daddr <= VCCAUX when sel = 1 else
             VCCINT   when sel = 2 else
             TEMP_DIE;
P_read_regs:process(clk_i)
begin
    if rst_i = '1' then
        state <= st0_idle;
        den <= '0';
        sel <= 0;
        temp_reg <= (others => (others => '0'));
    elsif rising_edge(clk_i) then
        case state is
            when st0_idle =>
                den <= '0';
                sel <= 0;
                if read_reg_s = '1' then
                    state <= st_dread;
                end if;
            when st_dread =>
                den <= '1';
                state <= st_dread1;
            when st_dread1 =>
                den <= '0';
                if drdy = '1' then
                    temp_reg(sel) <= do;
                    state <= st_dread2;
                end if;
            when st_dread2 => 
                if sel < 2 then
                    sel <= sel + 1;
                    state <= st_dread;
                else
                    sel <= 0;
                    state <= st0_idle;
                end if;
            when others =>
                state <= st0_idle;
        end case;
    end if;
end process;
temp_die_reg <= temp_reg(0)(15 downto 4);
vccint_reg <= temp_reg(1)(15 downto 4);
vccaux_reg <= temp_reg(2)(15 downto 4);
-- XADC inst
Inst_xadc: entity work.xadc_wiz_0
    port map(
    daddr_in => daddr,
    den_in => den,
    di_in => (others => '0'),
    dwe_in => '0',
    do_out => do,
    drdy_out => drdy,
    dclk_in => clk_i,
    reset_in => rst_i,
    vp_in => vp_in,
    vn_in => vn_in
    );

end Behavioral;
