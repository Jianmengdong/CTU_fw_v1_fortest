
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.CTU_pack.all;
use work.lite_bus_pack.all;
use work.ipbus.all;

entity CTU_v0_top is
    generic (
    g_cs_wonly_deep : natural:= 11; -- configuration space number of write only registers;
    g_cs_ronly_deep : natural:= 14;  -- configuration space number of read only registers;
    g_NSLV          : positive := 5
    );
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
    -- XADC port
    vp_in : in std_logic;
    vn_in : in std_logic;
    --  ipbus interface
    ipbus_tx_p : out std_logic;
    ipbus_tx_n : out std_logic;
    ipbus_rx_p : in std_logic;
    ipbus_rx_n : in std_logic;
    ipbus_clk_n : in std_logic;
    ipbus_clk_p : in std_logic;
    
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
    
    constant HW_VER : std_logic_vector(15 downto 0) := x"0000";
    constant FW_VER : std_logic_vector(15 downto 0) := x"01FF";
    signal clk_local,clk_localx2,clk_sys,locked,pps_i : std_logic;
    signal data_from_RMU_i,data_to_RMU,raw_hit_i : t_array64(31 downto 0);
    signal tg_compare_error,init_calib_complete : std_logic;
    signal data_from_RMU : std_logic_vector(63 downto 0);
    signal rx_aligned,resetdone_i,rx_slide,period : std_logic_vector(31 downto 0);
    signal period_i :std_logic_vector(31 downto 0) := x"03B9ACA0";
    signal ch_mask_in,ch_mask : std_logic_vector(167 downto 0);
    signal threshold_i,threshold,hit_sum : std_logic_vector(15 downto 0);
    signal trig_mask,trig_mask_i : std_logic_vector(4 downto 0);
    signal ch_delay_tap : t_array672(VFL_NUMBER - 1 downto 0);
    signal lite_bus_w : t_lite_wbus_arry(NSLV - 1 downto 0);
    signal lite_bus_r : t_lite_rbus_arry(NSLV - 1 downto 0);
    signal register_array,register_array_r : t_array48(NSLV - 1 downto 0);
    signal sel : integer range 0 to 255;
    signal write_tap,write_tap_r,sma_sel,pps_original,use_vio : std_logic;
    signal ext_trig_i : std_logic_vector(2 downto 0);
    signal trig_i : std_logic_vector(7 downto 0);
    signal ch_sel : std_logic_vector(4 downto 0);
    signal ch : integer range 0 to 31;
    signal timestamp_i,local_timer,timestamp_wr : std_logic_vector(67 downto 0);
    signal trig_led,live_led,force_trig : std_logic;
    signal window_i,window : std_logic_vector(4 downto 0);
    signal cs_data_o:  t_array32(g_cs_wonly_deep-1 downto 0);
    signal cs_data_i: t_array32(g_cs_ronly_deep-1 downto 0);
    signal daq_wr : ipb_wbus;
    signal daq_rd : ipb_rbus;
    signal ipb_clk,sn_alert,rst_regs,timer_valid : std_logic;
    signal temp_die_reg,vccint_reg,vccaux_reg : std_logic_vector(11 downto 0);
    signal timer_8ns : unsigned(27 downto 0);
    signal timer_utc : unsigned(39 downto 0);
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
P_local_timer:process(clk_localx2)
begin
    if locked = '0' then
        timer_8ns <= (others => '0');
        timer_utc <= (others => '0');
    elsif rising_edge(clk_localx2) then
        timer_8ns <= timer_8ns + 1;
        if timer_8ns = 124999999 then
            timer_8ns <= (others => '0');
            timer_utc <= timer_utc + 1;
        end if;
    end if;
end process;
local_timer(27 downto 0) <= std_logic_vector(timer_8ns);
local_timer(67 downto 28) <= std_logic_vector(timer_utc);
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
O => ext_trig_i(1)
);
Inst_fmc_Ibuf3:IBUFDS
generic map(
DIFF_TERM => TRUE
)
port map(
I => FMC_I3_P,
IB => FMC_I3_N,
O => sn_alert
);
Inst_trig_module:entity work.trig_module
    generic map(
    VFL_NUMBER => VFL_NUMBER
    )
    port map(
    clk_i => clk_sys,
    reset_i => not locked,
    daq_clk => ipb_clk,
    daq_wr => daq_wr,
    daq_rd_o => daq_rd,
    ch_mask_in => ch_mask_in,
    raw_hit_in => raw_hit_i(23 downto 0),
    --ch_delay_tap => ch_delay_tap,
    trig_o   => trig_i,
    threshold_i => threshold_i,
    reset_event_cnt_i => '0',
    hit_sum => hit_sum,
    window_i => window_i,
    en_trig_i => trig_mask_i,
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
    timer_valid => timer_valid,
    timestamp_o => timestamp_wr
    );
    timestamp_i <= timestamp_wr when timer_valid = '1' else local_timer;
Inst_ipbus:entity work.ipbus_body
    generic map(g_cs_wonly_deep => g_cs_wonly_deep, -- configuration space number of write only registers;
           g_cs_ronly_deep => g_cs_ronly_deep,  -- configuration space number of read only registers;
	        g_NSLV  => 5
           )
    port map(
    eth_clk_p => ipbus_clk_p,
    eth_clk_n => ipbus_clk_n,
    gtrefclk_out => open,
    eth_tx_p => ipbus_tx_p,
	eth_tx_n => ipbus_tx_n,
	eth_rx_p => ipbus_rx_p,
	eth_rx_n => ipbus_rx_n,
    mac_addr => X"021ddba11574",
	ip_addr => X"C0A80A74", --192.168.10.32
    ipb_clk_o => ipb_clk,
    ipb_daq_wr => daq_wr,
    ipb_daq_rd => daq_rd,
    cs_data_o        => cs_data_o,
    cs_data_i        => cs_data_i
    );
Inst_vio:entity work.vio_1
    port map(
    clk => clk_sys,
    probe_in0(0) => locked,
    probe_in1 => rx_aligned(1 downto 0),
    probe_out0 => ch_mask,--(13 downto 0),
    probe_out1 => threshold,
    probe_out2 => trig_mask, --'1' to enable trigger source
    probe_out3(0) => force_trig, --manual trigger
    probe_out4 => ch_sel,
    probe_out5 => period, --default x"3B9ACA0", 1s
    probe_out6(0) => sma_sel,
    probe_out7 => window,
    probe_out8(0) => use_vio
    );
    ch <= to_integer(unsigned(ch_sel));
    cs_data_i(0) <= HW_VER&FW_VER;
    cs_data_i(1) <= rx_aligned;
    cs_data_i(2) <= ch_mask_in(31 downto 0);
    cs_data_i(3) <= ch_mask_in(63 downto 32);
    cs_data_i(4) <= ch_mask_in(95 downto 64);
    cs_data_i(5) <= ch_mask_in(127 downto 96);
    cs_data_i(6) <= ch_mask_in(159 downto 128);
    cs_data_i(7) <= ch_mask_in(167 downto 160);
    cs_data_i(8) <= x"0000" & threshold_i;
    cs_data_i(9) <= x"000000"&"000" & trig_mask_i;
    cs_data_i(10) <= x"000000"&"000" & window_i;
    cs_data_i(11) <= period_i;
    cs_data_i(12) <= x"000000"&temp_die_reg;
    cs_data_i(13) <= x"00"&vccaux_reg&vccint_reg;
    ch_mask_in(31 downto 0)   <= cs_data_o(0) when use_vio = '0' else ch_mask(31 downto 0);
    ch_mask_in(63 downto 32)  <= cs_data_o(1) when use_vio = '0' else ch_mask(63 downto 32);
    ch_mask_in(95 downto 64)  <= cs_data_o(2) when use_vio = '0' else ch_mask(95 downto 64);
    ch_mask_in(127 downto 96) <= cs_data_o(3) when use_vio = '0' else ch_mask(127 downto 96);
    ch_mask_in(159 downto 128)<= cs_data_o(4) when use_vio = '0' else ch_mask(159 downto 128);
    ch_mask_in(167 downto 160)<= cs_data_o(5)(7 downto 0) when use_vio = '0' else ch_mask(167 downto 160);
    threshold_i <= cs_data_o(6)(15 downto 0) when use_vio = '0' else threshold;
    trig_mask_i <= cs_data_o(7)(4 downto 0) when use_vio = '0' else trig_mask;
    ext_trig_i(2) <= cs_data_o(8)(0) when use_vio = '0' else force_trig;
    ext_trig_i(0) <= cs_data_o(8)(1);
    window_i <= cs_data_o(9)(4 downto 0) when use_vio = '0' else window;
    period_i <= cs_data_o(10) when use_vio = '0' else period;
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
Inst_monitors:entity work.monitors
    port map(
    clk_i => clk_sys,
    rst_i => '0',
    vp_in => vp_in,
    vn_in => vn_in,
    read_reg => timestamp_i(29),
    temp_die_reg => temp_die_reg,
    vccint_reg => vccint_reg,
    vccaux_reg => vccaux_reg
    );
-- test signals
SMA_o(1) <= pps_original when sma_sel = '0' else pps_i;
SMA_o(2) <= trig_i(7);
SMA_o(3) <= 'Z';
SMA_o(4) <= 'Z';
-- ext_trig_i(0) <= SMA_o(3);
--ext_trig_i(1) <= SMA_o(4);
--ext_trig_i(4 downto 3) <= "00"; --from FMC, to be added
-- TEST_header(0) <= ext_trig_i(3);
-- TEST_header(1) <= ext_trig_i(4);
end Behavioral;
