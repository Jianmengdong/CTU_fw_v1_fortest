
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.CTU_pack.all;
use work.lite_bus_pack.all;

entity CTU_v0_top is
    Port (
    sysclk_p : in STD_LOGIC;
    sysclk_n : in STD_LOGIC;
    -- DDR3
    -- ddr3_dq      : inout std_logic_vector(15 downto 0);
    -- ddr3_dqs_p   : inout std_logic_vector(1 downto 0);
    -- ddr3_dqs_n   : inout std_logic_vector(1 downto 0);
    -- ddr3_addr    : out   std_logic_vector(14 downto 0);
    -- ddr3_ba      : out   std_logic_vector(2 downto 0);
    -- ddr3_ras_n   : out   std_logic;
    -- ddr3_cas_n   : out   std_logic;
    -- ddr3_we_n    : out   std_logic;
    -- ddr3_reset_n : out   std_logic;
    -- ddr3_ck_p    : out   std_logic_vector(0 downto 0);
    -- ddr3_ck_n    : out   std_logic_vector(0 downto 0);
    -- ddr3_cke     : out   std_logic_vector(0 downto 0);
    -- ddr3_cs_n    : out   std_logic_vector(0 downto 0);
    -- ddr3_dm      : out   std_logic_vector(1 downto 0);
    -- ddr3_odt     : out   std_logic_vector(0 downto 0);
    sdram_pen    : out std_logic; --enbale onboard sdram power
    sdram_pg     : in std_logic; --board sdram power good
    -- RMU links
    GTH_REFCLK_P : in STD_LOGIC_VECTOR(2 downto 0);
    GTH_REFCLK_N : in STD_LOGIC_VECTOR(2 downto 0);
    GTH_TXP : out std_logic_vector(31 downto 0);
    GTH_TXN : out std_logic_vector(31 downto 0);
    GTH_RXP : in std_logic_vector(31 downto 0);
    GTH_RXN : in std_logic_vector(31 downto 0);
    --     interface with Mini-WR
    PDATA_RX : in std_logic_vector(9 downto 0);
    PDATA_TX : inout std_logic_vector(9 downto 0);
    PPS_IN_P : in std_logic;
    PPS_IN_N : in std_logic;
    -- GPIOs
    SMA_o : inout std_logic_vector(4 downto 1);
    led : out std_logic_vector(2 downto 1);
    TEST_header: inout std_logic_vector(6 downto 0);
    -- FMC signals
    FMC_I0_P : in std_logic;
    FMC_I0_N : in std_logic;
    OE0_N : out std_logic;
    FMC_O0_P : out std_logic;
    FMC_O0_N : out std_logic;
    TERM_EN0 : out std_logic;
    FMC_I1_P : in std_logic;
    FMC_I1_N : in std_logic;
    OE1_N : out std_logic;
    FMC_O1_P : out std_logic;
    FMC_O1_N : out std_logic;
    TERM_EN1 : out std_logic;
    FMC_I2_P : in std_logic;
    FMC_I2_N : in std_logic;
    FMC_I3_P : in std_logic;
    FMC_I3_N : in std_logic;
    FMC_LED : out std_logic_vector(2 downto 1)
    );
end CTU_v0_top;

architecture Behavioral of CTU_v0_top is

    signal clk_local,clk_localx2,clk_sys,locked,pps_i : std_logic;
    signal data_from_RMU_i,data_to_RMU,raw_hit_i : t_array64(31 downto 0);
    signal tg_compare_error,init_calib_complete : std_logic;
    signal data_from_RMU : std_logic_vector(63 downto 0);
    signal rx_aligned,resetdone_i,rx_slide,period_i : std_logic_vector(31 downto 0);
    signal ch_mask_in : std_logic_vector(167 downto 0);
    signal threshold_i,hit_sum : std_logic_vector(15 downto 0);
    signal trig_mask : std_logic_vector(6 downto 0);
    signal ch_delay_tap : t_array672(VFL_NUMBER - 1 downto 0);
    signal lite_bus_w : t_lite_wbus_arry(NSLV - 1 downto 0);
    signal lite_bus_r : t_lite_rbus_arry(NSLV - 1 downto 0);
    signal register_array,register_array_r : t_array48(NSLV - 1 downto 0);
    signal sel : integer range 0 to 255;
    signal write_tap,write_tap_r,sma_sel,pps_original : std_logic;
    signal ext_trig_i : std_logic_vector(4 downto 0);
    signal trig_i : std_logic_vector(7 downto 0);
    signal ch_sel : std_logic_vector(4 downto 0);
    signal ch : integer range 0 to 31;
    signal timestamp_i : std_logic_vector(67 downto 0);
    signal trig_led,live_led : std_logic;
    signal window_i : std_logic_vector(4 downto 0);
begin
-- clock genrator
Inst_clk_gen:entity work.clk_gen
    port map(
    sysclk_p => sysclk_p,
    sysclk_n => sysclk_n,
    clk_x2_o => clk_localx2,
    clk_o    => clk_sys,
    pps_i => pps_i,
    reset_i => '0',
    locked_out => locked
    );
--================================================--
sdram_pen <= '0';
-- in integration test, ddr is not needed, power off.
-- DDR3 example design for test purpose
-- Inst_ddr3:entity work.example_top
    -- port map(
    -- ddr3_dq      => ddr3_dq,
    -- ddr3_dqs_p   => ddr3_dqs_p,
    -- ddr3_dqs_n   => ddr3_dqs_n,
    -- ddr3_addr    => ddr3_addr,
    -- ddr3_ba      => ddr3_ba,
    -- ddr3_ras_n   => ddr3_ras_n,
    -- ddr3_cas_n   => ddr3_cas_n,
    -- ddr3_we_n    => ddr3_we_n,
    -- ddr3_reset_n => ddr3_reset_n,
    -- ddr3_ck_p    => ddr3_ck_p,
    -- ddr3_ck_n    => ddr3_ck_n,
    -- ddr3_cke     => ddr3_cke,
    -- ddr3_cs_n    => ddr3_cs_n,
    -- ddr3_dm      => ddr3_dm,
    -- ddr3_odt     => ddr3_odt,
    -- sys_clk_i    => clk_localx2,
    -- sdram_pen    => sdram_pen, --enbale onboard sdram power
    -- sdram_pg     => sdram_pg, --board sdram power good
    -- tg_compare_error => tg_compare_error,
    -- init_calib_complete => init_calib_complete
    -- );
    --data_to_RMU(31 downto 24) <= (others => (x"00000000000000BC"));
-- RMU links
Inst_RMU_links:entity work.gt_wrapper
    port map(
    GTH_REFCLK_P => GTH_REFCLK_P,
    GTH_REFCLK_N => GTH_REFCLK_N,
    GTH_TXP => GTH_TXP,
    GTH_TXN => GTH_TXN,
    GTH_RXP => GTH_RXP,
    GTH_RXN => GTH_RXN,
    sysclk_i => clk_localx2,
    locked  => locked,
    trig_in => trig_i,
    rxdata_out => data_from_RMU_i,
    rx_aligned => rx_aligned,
    txusrclk2_in => clk_sys,
    txusrclk_in => clk_localx2
    );
Gen_rxalign: for i in 31 downto 0 generate
begin
    raw_hit_i(i) <= data_from_RMU_i(i) when rx_aligned(i) = '1' else (others => '0');
end generate;
OE0_N <= '0';
OE1_N <= '0';
Inst_FMC_obuf0 : OBUFDS
port map(
I => pps_i,
O => FMC_O0_P,
OB => FMC_O0_N
);
Inst_FMC_obuf1 : OBUFDS
port map(
I => trig_i(7),
O => FMC_O1_P,
OB => FMC_O1_N
);
-- vertex fitting module
Inst_fmc_Ibuf0:IBUFDS
generic map(
DIFF_TERM => TRUE
)
port map(
I => FMC_I0_P,
IB => FMC_I0_N,
O => open
);
TERM_EN0 <= '0';
Inst_fmc_Ibuf1:IBUFDS
generic map(
DIFF_TERM => TRUE
)
port map(
I => FMC_I1_P,
IB => FMC_I1_N,
O => open
);
TERM_EN1 <= '0';
Inst_fmc_Ibuf2:IBUFDS
generic map(
DIFF_TERM => TRUE
)
port map(
I => FMC_I2_P,
IB => FMC_I2_N,
O => ext_trig_i(3)
);
Inst_fmc_Ibuf3:IBUFDS
generic map(
DIFF_TERM => TRUE
)
port map(
I => FMC_I3_P,
IB => FMC_I3_N,
O => ext_trig_i(4)
);
Inst_trig_module:entity work.trig_module
    generic map(
    VFL_NUMBER => VFL_NUMBER
    )
    port map(
    clk_i => clk_sys,
    reset_i => not locked,
    ch_mask_in => ch_mask_in,
    raw_hit_in => raw_hit_i(23 downto 0),
    --ch_delay_tap => ch_delay_tap,
    trig_o   => trig_i,
    threshold_i => threshold_i,
    reset_event_cnt_i => '0',
    hit_sum => hit_sum,
    window_i => window_i,
    en_trig_i => trig_mask,
    ext_trig_i => ext_trig_i,
    global_time_i => timestamp_i,
    period_i => period_i --x"0000F424"
    );
--=====================================================--

Inst_wr_interface:entity work.wr_interface
    port map(
    sys_clk_i => clk_localx2,
    reset_i => not locked,
    PPS_IN_P => PPS_IN_P,
    PPS_IN_N => PPS_IN_N,
    -- PDATA_RX => PDATA_RX,
    -- PDATA_TX => PDATA_TX,
    -- lite_bus_w => lite_bus_w,
    -- lite_bus_r => lite_bus_r,
    pps_o => pps_i,
    pps_original => pps_original,
    timestamp_o => timestamp_i
    );
-- current CTU_v0 could not support WR interface slow control, use vio and ila instead
-- WR interface
-- Inst_wr_interface:entity work.wr_interface
    -- port map(
    -- sys_clk_i => clk_localx2,
    -- reset_i => not locked,
    -- PPS_IN_P => PPS_IN_P,
    -- PPS_IN_N => PPS_IN_N,
    -- PDATA_RX => PDATA_RX,
    -- PDATA_TX => PDATA_TX,
    -- lite_bus_w => lite_bus_w,
    -- lite_bus_r => lite_bus_r,
    -- pps_o => pps_i
    -- );
-- --  local control_registers
-- Inst_regs:entity work.control_registers
    -- port map(
    -- sys_clk_i => clk_localx2,
    -- reset_i => not locked,
    -- lite_bus_w => lite_bus_w,
    -- lite_bus_r => lite_bus_r,
    -- register_o => register_array,
    -- register_i => register_array_r
    -- );
    -- sel <= to_integer(unsigned(register_array(20)(7 downto 0)));
    -- write_tap <= register_array(15)(0);
    -- register_array_r(20) <= x"0000000000"&std_logic_vector(to_unsigned(sel, 8));
-- process(clk_localx2)
-- begin
    -- if rising_edge(clk_localx2) then
        -- write_tap_r <= write_tap;
        -- if write_tap_r = '0' and write_tap = '1' then
            -- ch_delay_tap(sel)(47 downto 0) <= register_array(0);
            -- ch_delay_tap(sel)(95 downto 48) <= register_array(1);
            -- ch_delay_tap(sel)(143 downto 96) <= register_array(2);
            -- ch_delay_tap(sel)(191 downto 144) <= register_array(3);
            -- ch_delay_tap(sel)(239 downto 192) <= register_array(4);
            -- ch_delay_tap(sel)(287 downto 240) <= register_array(5);
            -- ch_delay_tap(sel)(335 downto 288) <= register_array(6);
            -- ch_delay_tap(sel)(383 downto 336) <= register_array(7);
            -- ch_delay_tap(sel)(431 downto 384) <= register_array(8);
            -- ch_delay_tap(sel)(479 downto 432) <= register_array(9);
            -- ch_delay_tap(sel)(527 downto 480) <= register_array(10);
            -- ch_delay_tap(sel)(575 downto 528) <= register_array(11);
            -- ch_delay_tap(sel)(623 downto 576) <= register_array(12);
            -- ch_delay_tap(sel)(671 downto 624) <= register_array(13);
        -- end if;
    -- end if;
-- end process;
    -- ch_mask_in(47 downto 0) <= register_array(14);
    -- ch_mask_in(95 downto 48) <= register_array(15);
    -- ch_mask_in(143 downto 96) <= register_array(16);
    -- ch_mask_in(167 downto 144) <= register_array(17)(23 downto 0);
    -- threshold_i <= register_array(18)(15 downto 0);
    -- trig_mask <= register_array(19)(4 downto 0);
    -- register_array_r(0)  <= ch_delay_tap(sel)(47 downto 0);
    -- register_array_r(1)  <= ch_delay_tap(sel)(95 downto 48);
    -- register_array_r(2)  <= ch_delay_tap(sel)(143 downto 96); 
    -- register_array_r(3)  <= ch_delay_tap(sel)(191 downto 144);
    -- register_array_r(4)  <= ch_delay_tap(sel)(239 downto 192);
    -- register_array_r(5)  <= ch_delay_tap(sel)(287 downto 240);
    -- register_array_r(6)  <= ch_delay_tap(sel)(335 downto 288);
    -- register_array_r(7)  <= ch_delay_tap(sel)(383 downto 336);
    -- register_array_r(8)  <= ch_delay_tap(sel)(431 downto 384);
    -- register_array_r(9)  <= ch_delay_tap(sel)(479 downto 432);
    -- register_array_r(10) <= ch_delay_tap(sel)(527 downto 480);
    -- register_array_r(11) <= ch_delay_tap(sel)(575 downto 528);
    -- register_array_r(12) <= ch_delay_tap(sel)(623 downto 576);
    -- register_array_r(13) <= ch_delay_tap(sel)(671 downto 524);
    -- register_array_r(14) <= ch_mask_in(47 downto 0);
    -- register_array_r(15) <= ch_mask_in(95 downto 48);
    -- register_array_r(16) <= ch_mask_in(143 downto 96);
    -- register_array_r(17) <= x"000000"&ch_mask_in(167 downto 144);
    -- register_array_r(18) <= x"00000000"&threshold_i;
    
    -- register_array_r(19) <= x"0000000000"&'0'&trig_mask&init_calib_complete&locked;
-- debug cores
--ch_mask_in(167 downto 14) <= (others => '1');
Inst_vio:entity work.vio_0
    port map(
    clk => clk_sys,
    probe_in0(0) => locked,
    probe_in1 => rx_aligned(1 downto 0),
    probe_out0 => ch_mask_in,--(13 downto 0),
    probe_out1 => threshold_i,
    probe_out2 => trig_mask, --'1' to enable trigger source
    probe_out3(0) => ext_trig_i(2), --manual trigger
    probe_out4 => ch_sel,
    probe_out5 => period_i, --default x"3B9ACA0", 1s
    probe_out6(0) => sma_sel,
    probe_out7 => window_i
    );
    ch <= to_integer(unsigned(ch_sel));
Inst_ila:entity work.ila_0
    port map(
    clk => clk_sys,
    probe0 => trig_i,
    probe1 => data_from_RMU,
    probe2 => hit_sum,
    probe3 => timestamp_i
    );
    data_from_RMU <= data_from_RMU_i(ch);
Inst_trig_led:entity work.trig_led
    port map(
    clk_i => clk_sys,
    trig_i => trig_i(7),
    led_o => trig_led
    );
    led(1) <= trig_led;
    FMC_LED(1) <= trig_led;
Inst_breath_led:entity work.LED_breath
    port map(
    clk     => clk_sys,
    led_o   => live_led
    );
    led(2) <= live_led;
    FMC_LED(2) <= live_led;
-- test signals
SMA_o(1) <= pps_original when sma_sel = '0' else pps_i;
SMA_o(2) <= clk_sys;
SMA_o(3) <= 'Z';
SMA_o(4) <= 'Z';
ext_trig_i(0) <= SMA_o(3);
ext_trig_i(1) <= SMA_o(4);
--ext_trig_i(4 downto 3) <= "00"; --from FMC, to be added
TEST_header(0) <= ext_trig_i(3);
TEST_header(1) <= ext_trig_i(4);
end Behavioral;
