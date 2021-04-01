library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.CTU_pack.all;
entity VFL_top is
generic(
delay_cycle_vector : std_logic_vector(671 downto 0) := 
 x"888887777777777766666666666666665555555555555555555555554444444444444444444444444444444333333333533333333333333333333222222222222222222221111111111111111111000000000000"
);
  Port (
    clk_i : in std_logic;
    threshold_i: in std_logic_vector(15 downto 0);
    raw_hit_in : in t_array64(23 downto 0);
    ch_mask_in : in std_logic_vector(167 downto 0);
    nhit_sum_o : out unsigned(15 downto 0);
    accept_o : out std_logic
  );
end VFL_top;

architecture Behavioral of VFL_top is

    signal ch_hit,ch_hit_delayed : t_uarray16(167 downto 0);
    signal sum1 : t_uarray16(23 downto 0);
    signal sum2_1,sum2_2,sum2_3,sum2_4,sum3 : unsigned(15 downto 0);
    signal threshold : unsigned(15 downto 0);

begin
threshold <= unsigned(threshold_i);
----distribute each channel
Gen_raw_hit:for i in 23 downto 0 generate
    Gen_ch_hit: for j in 7 downto 1 generate
        ch_hit(i*7+j-1) <= x"00" & unsigned(raw_hit_in(i)(j*8+7 downto j*8));
    end generate;
end generate;
-----------------------------
----delay hit according channel position
Gen_ch_hit_delay:for i in 167 downto 0 generate
Inst_ch_hit_delay:entity work.ch_hit_delay
    generic map(
    DELAY_CYCLE => to_integer(unsigned(delay_cycle_vector(i*4+3 downto i*4)))
    )
    port map(
    clk_in => clk_i,
    data_in => ch_hit(i),
    data_mask => ch_mask_in(i),
    data_out => ch_hit_delayed(i)
    );
end generate;
---------------------------------
----add all channel hit
Gen_lvl1_adder:for i in 23 downto 0 generate
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            sum1(i) <= ch_hit_delayed(i)+ch_hit_delayed(i+1)+ch_hit_delayed(i+2)+ch_hit_delayed(i+3)+ch_hit_delayed(i+4)+ch_hit_delayed(i+5)+ch_hit_delayed(i+6);
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
        if sum3 >= threshold then
            accept_o <= '1';
        else
            accept_o <= '0';
        end if;
    end if;
end process;
nhit_sum_o <= sum3;
--------------------------
end Behavioral;