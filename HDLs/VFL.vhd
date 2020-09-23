library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.CTU_pack.all;
entity VFL_top is
-- generic(
-- delay_cycle_vector : std_logic_vector(671 downto 0) := 
 -- x"888887777777777766666666666666665555555555555555555555554444444444444444444444444444444333333333533333333333333333333222222222222222222221111111111111111111000000000000"
-- );
  Port (
    clk_i : in std_logic;
    threshold_i: in std_logic_vector(15 downto 0);
    raw_hit_in : in t_array64(23 downto 0);
    ch_mask_in : in std_logic_vector(167 downto 0);
    nhit_sum_o : out std_logic_vector(15 downto 0);
    window_i : in std_logic_vector(4 downto 0);
    --ch_delay_tap : in std_logic_vector(671 downto 0);
    accept_o : out std_logic
  );
end VFL_top;

architecture Behavioral of VFL_top is

    signal ch_hit,ch_hit_i,ch_hit_delayed : t_uarray16(167 downto 0);
    signal sum1 : t_uarray16(23 downto 0);
    signal sum,sum2_1,sum2_2,sum2_3,sum2_4,sum3,sum3_r,sum3_r2 : unsigned(15 downto 0);
    signal threshold : unsigned(15 downto 0);
    signal sum_t : t_uarray16(31 downto 0);
    signal accept : std_logic_vector(31 downto 0);
    signal tw : integer range 0 to 31; --trigger window

begin
threshold <= unsigned(threshold_i);
tw <= to_integer(unsigned(window_i));
----distribute each channel
Gen_raw_hit:for i in 23 downto 0 generate
    Gen_ch_hit: for j in 7 downto 1 generate
        ch_hit_i(i*7+j-1) <= x"00" & unsigned(raw_hit_in(i)(j*8+7 downto j*8));
        ch_hit(i*7+j-1) <= ch_hit_i(i*7+j-1) when ch_mask_in(i*7+j-1) = '0' else (others => '0');
    end generate;
end generate;
-----------------------------
----delay hit according channel position
-- Gen_ch_hit_delay:for i in 167 downto 0 generate
-- Inst_ch_hit_delay:entity work.ch_hit_delay
    -- generic map(
    -- DELAY_CYCLE => to_integer(unsigned(delay_cycle_vector(i*4+3 downto i*4)))
    -- )
    -- port map(
    -- clk_in => clk_i,
    -- data_in => ch_hit(i),
    -- data_mask => ch_mask_in(i),
    -- data_out => ch_hit_delayed(i)
    -- );
-- end generate;
-- Gen_ch_hit_delay:for i in 167 downto 0 generate
-- Inst_ch_hit_delay:entity work.ch_hit_delay_v2
    -- port map(
    -- clk_i => clk_i,
    -- data_in => ch_hit(i),
    -- data_mask => ch_mask_in(i),
    -- tap_cnt_in => ch_delay_tap(i*4 + 3 downto i*4),
    -- data_out => ch_hit_delayed(i)
    -- );
-- end generate;
---------------------------------
----add all channel hit
Gen_lvl1_adder:for i in 23 downto 0 generate
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            sum1(i) <= ch_hit(i)+ch_hit(i+1)+ch_hit(i+2)+ch_hit(i+3)+ch_hit(i+4)+ch_hit(i+5)+ch_hit(i+6);
        end if;
    end process;
end generate;
process(clk_i)
begin
    if rising_edge(clk_i) then
        sum2_1 <= sum1(0) + sum1(1) + sum1(2) + sum1(3) + sum1(4) + sum1(5);
        sum2_2 <= sum1(6) + sum1(7) + sum1(8) + sum1(9) + sum1(10) + sum1(11);
        sum2_3 <= sum1(12) + sum1(13) + sum1(14) + sum1(15) + sum1(16) + sum1(17);
        sum2_4 <= sum1(18) + sum1(19) + sum1(20) + sum1(21) + sum1(22) + sum1(23);
        sum3 <= sum2_1 + sum2_2 + sum2_3 + sum2_4;
    end if;
end process;
--implement trigger window.
Gen_accept: for i in 0 to 31 generate
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if sum_t(i) > threshold then
                accept(i) <= '1';
            else
                accept(i) <= '0';
            end if;
        end if;
    end process;
end generate;
-- process(clk_i)
-- begin
    -- if rising_edge(clk_i) then
        -- sum3_r <= sum3;
        -- sum3_r2 <= sum3_r;
        -- sum <= sum3 + sum3_r + sum3_r2;
        -- if sum >= threshold then
            -- accept_o <= '1';
        -- else
            -- accept_o <= '0';
        -- end if;
    -- end if;
-- end process;
process(clk_i)
begin
    if rising_edge(clk_i) then
        sum_t(0) <= sum3;
        sum_t(1) <= sum_t(0) + sum3;
        sum_t(2) <= sum_t(1) + sum3;
        sum_t(3) <= sum_t(2) + sum3;
        sum_t(4) <= sum_t(3) + sum3;
        sum_t(5) <= sum_t(4) + sum3;
        sum_t(6) <= sum_t(5) + sum3;
        sum_t(7) <= sum_t(6) + sum3;
        sum_t(8) <= sum_t(7) + sum3;
        sum_t(9) <= sum_t(8) + sum3;
        sum_t(10) <= sum_t(9) + sum3;
        sum_t(11) <= sum_t(10) + sum3;
        sum_t(12) <= sum_t(11) + sum3;
        sum_t(13) <= sum_t(12) + sum3;
        sum_t(14) <= sum_t(13) + sum3;
        sum_t(15) <= sum_t(14) + sum3;
        sum_t(16) <= sum_t(15) + sum3;
        sum_t(17) <= sum_t(16) + sum3;
        sum_t(18) <= sum_t(17) + sum3;
        sum_t(19) <= sum_t(18) + sum3;
        sum_t(20) <= sum_t(19) + sum3;
        sum_t(21) <= sum_t(20) + sum3;
        sum_t(22) <= sum_t(21) + sum3;
        sum_t(23) <= sum_t(22) + sum3;
        sum_t(24) <= sum_t(23) + sum3;
        sum_t(25) <= sum_t(24) + sum3;
        sum_t(26) <= sum_t(25) + sum3;
        sum_t(27) <= sum_t(26) + sum3;
        sum_t(28) <= sum_t(27) + sum3;
        sum_t(29) <= sum_t(28) + sum3;
        sum_t(30) <= sum_t(29) + sum3;
        sum_t(31) <= sum_t(30) + sum3;
    end if;
end process;
nhit_sum_o <= std_logic_vector(sum_t(tw));
accept_o <= accept(tw);
--------------------------
end Behavioral;