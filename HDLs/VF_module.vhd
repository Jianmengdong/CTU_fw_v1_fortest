
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.CTU_pack.all;
entity trig_module is
    generic(
    VFL_NUMBER : integer range 1 to 180 := 2
    );
    Port ( 
    clk_i : in STD_LOGIC;
    reset_i : in std_logic;
    ch_mask_in : in std_logic_vector(167 downto 0);
    raw_hit_in : in t_array64(23 downto 0);
    threshold_i: in std_logic_vector(15 downto 0);
    trig_o : out std_logic_vector(7 downto 0);
    reset_event_cnt_i : in std_logic;
    global_time_i : in std_logic_vector(67 downto 0);
    --ch_delay_tap : in t_array672(VFL_NUMBER - 1 downto 0);
    period_i : in std_logic_vector(31 downto 0);
    window_i : in std_logic_vector(4 downto 0);
    hit_sum : out std_logic_vector(15 downto 0);
    --=========================================--
    en_trig_i : in STD_LOGIC_vector(6 downto 0);
    -- => en_trig_i(4): enable calibration trigger
    -- => en_trig_i(3): enable TT trigger
    -- => en_trig_i(2): enable VETO trigger
    -- => en_trig_i(1): enable periodic trigger
    -- => en_trig_i(0): enable physics trigger
    --=========================================--
    ext_trig_i : in std_logic_vector(4 downto 0)
    -- => ext_trig_i(4): FMC trigger 2
    -- => ext_trig_i(3): FMC trigger 1
    -- => ext_trig_i(2): calibration trigger
    -- => ext_trig_i(1): TT trigger
    -- => ext_trig_i(0): VETO trigger
    --=========================================--
    );
end trig_module;

architecture Behavioral of trig_module is

    signal accept : std_logic_vector(VFL_NUMBER - 1 downto 0);
    signal accept_u : unsigned(VFL_NUMBER - 1 downto 0);
    signal trig_per,trig_per_i,trig_phy,trig_phy_i,accept_o : std_logic;
    signal period_cnt,period : unsigned(31 downto 0);
    signal trig_cnt : unsigned(31 downto 0);
    signal ext_trig,ext_trig_r,ext_trig_r2 : std_logic_vector(4 downto 0);
    signal trig_type : std_logic_vector(2 downto 0);
    signal dead_time : std_logic;
    signal dead_cnt : unsigned(3 downto 0);
    signal st : std_logic_vector(1 downto 0);
    signal trig_time : std_logic_vector(67 downto 0);
    --signal trig_o : std_logic_vector(7 downto 0);

begin
-- Gen_txdata: for i in 23 downto 0 generate
-- begin
    -- trig_out(i) <= trig_o & x"000000000000BC";
-- end generate;
trig_o(7) <= accept_o when dead_time = '0' else '0';
trig_o(6 downto 4) <= trig_type when dead_time = '0' else "000";
trig_o(3 downto 0) <= f_hamming_encoder_4bit(accept_o&trig_type);
--rst_event <= trig_cnt(8);
---- trigger enable----------
ext_trig_r(4) <= ext_trig_i(4) when en_trig_i(6) = '1' else '0';
ext_trig_r(3) <= ext_trig_i(3) when en_trig_i(5) = '1' else '0';
ext_trig_r(2) <= ext_trig_i(2) when en_trig_i(4) = '1' else '0';
ext_trig_r(1) <= ext_trig_i(1) when en_trig_i(3) = '1' else '0';
ext_trig_r(0) <= ext_trig_i(0) when en_trig_i(2) = '1' else '0';
trig_per <= trig_per_i when en_trig_i(1) = '1' else '0';
trig_phy <= trig_phy_i when en_trig_i(0) = '1' else '0';
--generate trig and catch trigger time, count trigger numbers
process(clk_i)
begin
    if reset_i = '1' then
        accept_o <= '0';
        trig_time <= (others => '0');
        trig_cnt <= (others => '0');
    elsif rising_edge(clk_i) then
        accept_o <= ext_trig(4) or ext_trig(3) or ext_trig(2) or ext_trig(1) or ext_trig(0) or trig_per or trig_phy;
        if ext_trig(2) = '1' then
            trig_type <= "010"; --manual trigger
        elsif trig_phy = '1' then
            trig_type <= "001"; --physics trigger
        elsif trig_per = '1' then
            trig_type <= "011"; --periodic trigger
        elsif ext_trig(0) = '1' then
            trig_type <= "100"; --SMA3 trigger
        elsif ext_trig(1) = '1' then
            trig_type <= "101"; --SMA4 trigger
        elsif ext_trig(3) = '1' then
            trig_type <= "110"; --FMC trigger 1
        elsif ext_trig(4) = '1' then
            trig_type <= "111"; --FMC trigger 2
        
        else
            trig_type <= "000";
        end if;
        if accept_o = '1' then
            trig_time <= global_time_i;
            if reset_event_cnt_i = '1' then
                trig_cnt <= (others => '0');
            else
                trig_cnt <= trig_cnt + 1;
            end if;
        end if;
    end if;
end process;
process(clk_i)
begin
    if reset_i = '1' then
        dead_time <= '0';
        dead_cnt <= (others => '0');
    elsif rising_edge(clk_i) then
        case st is 
            when "00" =>
                if accept_o = '1' then
                    st <= "01";
                    dead_time <= '1';  --2019/6/28: changed to avoid 2 clk width trig_o
                    dead_cnt <= (others => '0');
                end if;
            when "01" =>
                dead_cnt <= dead_cnt + 1;
                if dead_cnt = 10 then
                    dead_time <= '0'; --2019/6/28: changed to avoid 2 clk width trig_o
                    st <= "00";
                end if;
            when others =>
                st <= "00";
        end case;
    end if;
end process;
-- vertex fitting logic   not used in integration test, change to adder
-- Gen_VFL:for i in 0 to VFL_NUMBER - 1 generate
    Inst_VFL:entity work.VFL_top
        -- generic map(
        -- delay_cycle_vector => delay_cycle_vector(i)
        -- )
        port map(
        clk_i => clk_i,
        threshold_i => threshold_i,
        raw_hit_in => raw_hit_in,
        ch_mask_in => ch_mask_in,
        window_i => window_i,
        --ch_delay_tap => ch_delay_tap(i),
        nhit_sum_o => hit_sum,
        accept_o => trig_phy_i
        );
-- end generate;
--accept_u <= unsigned(accept);
-- process(clk_i)
-- begin
    -- if rising_edge(clk_i) then
        -- if accept_u > 0 then
            -- trig_phy_i <= '1';
        -- else
            -- trig_phy_i <= '0';
        -- end if;
    -- end if;
-- end process;
---- periodic trigger generate----
period <= unsigned(period_i);
process(clk_i)
begin
    if reset_i = '1' or en_trig_i(1) = '0' then
        period_cnt <= period;
        trig_per_i <= '0';
    elsif rising_edge(clk_i) then
        if period_cnt = 0 then
            trig_per_i <= '1';
            period_cnt <= period;
        else
            trig_per_i <= '0';
            period_cnt <= period_cnt - 1;
        end if;
    end if;
end process;
---- external trigger generate----
process(clk_i)
begin
    if rising_edge(clk_i) then
        ext_trig_r2 <= ext_trig_r;
        if ext_trig_r2(4) = '0' and ext_trig_r(4) = '1' then
            ext_trig(4) <= '1';
        else
            ext_trig(4) <= '0';
        end if;
        if ext_trig_r2(3) = '0' and ext_trig_r(3) = '1' then
            ext_trig(3) <= '1';
        else
            ext_trig(3) <= '0';
        end if;
        if ext_trig_r2(2) = '0' and ext_trig_r(2) = '1' then
            ext_trig(2) <= '1';
        else
            ext_trig(2) <= '0';
        end if;
        if ext_trig_r2(1) = '0' and ext_trig_r(1) = '1' then
            ext_trig(1) <= '1';
        else
            ext_trig(1) <= '0';
        end if;
        if ext_trig_r2(0) = '0' and ext_trig_r(0) = '1' then
            ext_trig(0) <= '1';
        else
            ext_trig(0) <= '0';
        end if;
    end if;
end process;
end Behavioral;
