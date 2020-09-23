
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity clk_gen is
    Port ( 
    sysclk_p : in STD_LOGIC;
    sysclk_n : in STD_LOGIC;
    clk_x2_o : out STD_LOGIC;
    clk_o : out STD_LOGIC;
    reset_i : in std_logic;
    pps_i : in std_logic;
    LOCKED_OUT : out std_logic
    );
end clk_gen;

architecture Behavioral of clk_gen is

    signal sysclk,clkin1,clkfbout : std_logic;
    signal clkout0,clkout0_inv,clkout1 : std_logic;
    signal clk_inv,clk_i,clk_x2,clk_u : std_logic;
    signal pps_b,pps_r,pps_r1 : std_logic;

begin
Inst_bufds:IBUFDS
    generic map(
    DIFF_TERM => TRUE
    )
    port map(
    I => sysclk_p,
    IB => sysclk_n,
    O => sysclk
    );
clkin1_buf : BUFG
  port map
   (O => clkin1,
    I => sysclk);
mmcm_adv_inst : MMCME2_ADV
  generic map
   (BANDWIDTH            => "OPTIMIZED",
    CLKOUT4_CASCADE      => FALSE,
    COMPENSATION         => "ZHOLD",
    STARTUP_WAIT         => FALSE,
    DIVCLK_DIVIDE        => 1,
    CLKFBOUT_MULT_F      => 5.0,
    CLKFBOUT_PHASE       => 0.000,
    CLKFBOUT_USE_FINE_PS => FALSE,
    CLKOUT0_DIVIDE_F     => 10.0,
    CLKOUT0_PHASE        => 0.000,
    CLKOUT0_DUTY_CYCLE   => 0.500,
    CLKOUT0_USE_FINE_PS  => FALSE,
    CLKIN1_PERIOD        => 8.0,
    CLKOUT1_DIVIDE       => 5,
    CLKOUT1_PHASE        => 0.000,
    CLKOUT1_DUTY_CYCLE   => 0.500,
    CLKOUT1_USE_FINE_PS  => FALSE,
    CLKOUT2_DIVIDE       => 10,
    CLKOUT2_PHASE        => 0.000,
    CLKOUT2_DUTY_CYCLE   => 0.500,
    CLKOUT2_USE_FINE_PS  => FALSE,
    CLKOUT3_DIVIDE       => 10,
    CLKOUT3_PHASE        => 0.000,
    CLKOUT3_DUTY_CYCLE   => 0.500,
    CLKOUT3_USE_FINE_PS  => FALSE,
    REF_JITTER1          => 0.010)
  port map
    -- Output clocks
   (CLKFBOUT            => clkfbout,
    CLKFBOUTB           => open,
    CLKOUT0             => clkout0,
    CLKOUT0B            => clkout0_inv,
    CLKOUT1             => clkout1,
    CLKOUT1B            => open,
    CLKOUT2             => open,
    CLKOUT2B            => open,
    CLKOUT3             => open,
    CLKOUT3B            => open,
    CLKOUT4             => open,
    CLKOUT5             => open,
    CLKOUT6             => open,
    -- Input clock control
    CLKFBIN             => clkfbout,
    CLKIN1              => clkin1,
    CLKIN2              => '0',
    -- Tied to always select the primary input clock
    CLKINSEL            => '1',
    -- Ports for dynamic reconfiguration
    DADDR               => (others => '0'),
    DCLK                => '0',
    DEN                 => '0',
    DI                  => (others => '0'),
    DO                  => open,
    DRDY                => open,
    DWE                 => '0',
    -- Ports for dynamic phase shift
    PSCLK               => '0',
    PSEN                => '0',
    PSINCDEC            => '0',
    PSDONE              => open,
    -- Other control and status signals
    LOCKED              => LOCKED_OUT,
    CLKINSTOPPED        => open,
    CLKFBSTOPPED        => open,
    PWRDWN              => '0',
    RST                 => reset_i);
clkout0_buf : BUFG
  port map
   (O => clk_i,
    I => clkout0);
clkout0inv_buf : BUFG
  port map
   (O => clk_inv,
    I => clkout0_inv);
-- sample pps with 125M clock
process(clk_x2)
begin
    if rising_edge(clk_x2) then
        pps_b <= pps_i;
    end if;
end process;
-- find pps rising edge with 62.5M clock
process(clk_i)
begin
if rising_edge(clk_i) then
    pps_r1 <= pps_i;
    if pps_i = '1' and pps_r1 = '0' then
        pps_r <= pps_b;
    end if;
end if;
end process;
clk_u <= clk_i when pps_r = '1' else clk_inv;
clko_buf : BUFG
  port map
   (O => clk_o,
    I => clk_u);
clkout1_buf : BUFG
  port map
   (O => clk_x2,
    I => clkout1);
clk_x2_o <= clk_x2;
end Behavioral;
