----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2019/08/01 16:30:03
-- Design Name: 
-- Module Name: gt_wrapper - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.CTU_pack.all;

entity gt_wrapper is
    Port ( 
    --==========================================--
    GTH_REFCLK_P : in STD_LOGIC_VECTOR(2 DOWNTO 0);
    GTH_REFCLK_N : in STD_LOGIC_VECTOR(2 DOWNTO 0);
    GTH_TXP : out std_logic_vector(31 downto 0);
    GTH_TXN : out std_logic_vector(31 downto 0);
    GTH_RXP : in std_logic_vector(31 downto 0);
    GTH_RXN : in std_logic_vector(31 downto 0);
    --==========================================--
    sysclk_i : in STD_LOGIC;
    locked   : in std_logic;
    --==========================================--
    --resetdone_out : out std_logic_vector(31 downto 0);
    trig_in : in std_logic_vector(7 downto 0);
    rxdata_out : out t_array64(31 downto 0);
    rx_aligned : out std_logic_vector(31 downto 0);
    --rxslide_in : in std_logic_vector(31 downto 0);
    --==========================================--
    --txusrclk2_out: out std_logic
    txusrclk2_in : in std_logic;
    txusrclk_in : in std_logic
    );
end gt_wrapper;

architecture Behavioral of gt_wrapper is

    signal rxdata_i,txdata_in : t_array64(31 downto 0);
    signal txusrclk2 : std_logic;
    signal tx_resetdone,rx_resetdone,rxslide_in,resetdone_i : std_logic_vector(31 downto 0);
    signal txcharisk_in : t_array8(31 downto 0);
    
begin
--txusrclk2_out <= txusrclk2;
Gen_txdata: for i in 23 downto 0 generate
begin
    txdata_in(i) <= trig_in & x"000000000000BC";
end generate;
txdata_in(31 downto 24) <= (others => (x"00000000000000BC"));
process(txusrclk2_in)
variable cnt : integer range 0 to 65535 :=0;
begin
    if locked = '0' then
        txcharisk_in <= (others => (others => '0'));
    elsif rising_edge(txusrclk2_in) then
        if cnt = 65535 then
            txcharisk_in <= (others => (0 => '1', others => '0'));
            cnt := 0;
        else
            txcharisk_in <= (others => (others => '0'));
            cnt := cnt + 1;
        end if;
    end if;
end process;
process(txusrclk2_in)
begin
    if rising_edge(txusrclk2_in) then
        rxdata_out <= rxdata_i;
    end if;
end process;
Gen_resetdone:for i in 31 downto 0 generate
begin
    process(txusrclk2_in)
    begin
        if rising_edge(txusrclk2_in) then
            resetdone_i(i) <= tx_resetdone(i) and rx_resetdone(i);
        end if;
    end process;
end generate;
Gen_rxalign: for i in 31 downto 0 generate
begin
    Inst_rx_align:entity work.rx_alignment
        generic map(
        NUMBER_TO_ALIGN => 10,
        LOSS_ALIGN => 20,
        DATA_WIDTH => 64
        )
        port map(
        clk_i => txusrclk2_in,
        reset_i => not resetdone_i(i),
        slide_o => rxslide_in(i),
        rx_data_i => rxdata_i(i),
        aligned_o => rx_aligned(i),
        re_align_i => '0',
        debug_fsm => open
        );
end generate;
gtwizard_0_i :entity work.gtwizard_0
port map
(
    SOFT_RESET_TX_IN => '0',
    SOFT_RESET_RX_IN => '0',
    DONT_RESET_ON_DATA_ERROR_IN => '1',
    Q2_CLK0_GTREFCLK_PAD_N_IN => GTH_REFCLK_N(0),
    Q2_CLK0_GTREFCLK_PAD_P_IN => GTH_REFCLK_P(0),
    Q5_CLK0_GTREFCLK_PAD_N_IN => GTH_REFCLK_N(1),
    Q5_CLK0_GTREFCLK_PAD_P_IN => GTH_REFCLK_P(1),
    Q7_CLK0_GTREFCLK_PAD_N_IN => GTH_REFCLK_N(2),
    Q7_CLK0_GTREFCLK_PAD_P_IN => GTH_REFCLK_P(2),
    ---------------------------------------------
    ----reset done
    GT0_TX_FSM_RESET_DONE_OUT  => tx_resetdone(0),
    GT1_TX_FSM_RESET_DONE_OUT  => tx_resetdone(1),
    GT2_TX_FSM_RESET_DONE_OUT  => tx_resetdone(2),
    GT3_TX_FSM_RESET_DONE_OUT  => tx_resetdone(3),
    GT4_TX_FSM_RESET_DONE_OUT  => tx_resetdone(4),
    GT5_TX_FSM_RESET_DONE_OUT  => tx_resetdone(5),
    GT6_TX_FSM_RESET_DONE_OUT  => tx_resetdone(6),
    GT7_TX_FSM_RESET_DONE_OUT  => tx_resetdone(7),
    GT8_TX_FSM_RESET_DONE_OUT  => tx_resetdone(8),
    GT9_TX_FSM_RESET_DONE_OUT  => tx_resetdone(9),
    GT10_TX_FSM_RESET_DONE_OUT => tx_resetdone(10),
    GT11_TX_FSM_RESET_DONE_OUT => tx_resetdone(11),
    GT12_TX_FSM_RESET_DONE_OUT => tx_resetdone(12),
    GT13_TX_FSM_RESET_DONE_OUT => tx_resetdone(13),
    GT14_TX_FSM_RESET_DONE_OUT => tx_resetdone(14),
    GT15_TX_FSM_RESET_DONE_OUT => tx_resetdone(15),
    GT16_TX_FSM_RESET_DONE_OUT => tx_resetdone(16),
    GT17_TX_FSM_RESET_DONE_OUT => tx_resetdone(17),
    GT18_TX_FSM_RESET_DONE_OUT => tx_resetdone(18),
    GT19_TX_FSM_RESET_DONE_OUT => tx_resetdone(19),
    GT20_TX_FSM_RESET_DONE_OUT => tx_resetdone(20),
    GT21_TX_FSM_RESET_DONE_OUT => tx_resetdone(21),
    GT22_TX_FSM_RESET_DONE_OUT => tx_resetdone(22),
    GT23_TX_FSM_RESET_DONE_OUT => tx_resetdone(23),
    GT24_TX_FSM_RESET_DONE_OUT => tx_resetdone(24),
    GT25_TX_FSM_RESET_DONE_OUT => tx_resetdone(25),
    GT26_TX_FSM_RESET_DONE_OUT => tx_resetdone(26),
    GT27_TX_FSM_RESET_DONE_OUT => tx_resetdone(27),
    GT28_TX_FSM_RESET_DONE_OUT => tx_resetdone(28),
    GT29_TX_FSM_RESET_DONE_OUT => tx_resetdone(29),
    GT30_TX_FSM_RESET_DONE_OUT => tx_resetdone(30),
    GT31_TX_FSM_RESET_DONE_OUT => tx_resetdone(31),
    GT0_RX_FSM_RESET_DONE_OUT  => rx_resetdone(0),
    GT1_RX_FSM_RESET_DONE_OUT  => rx_resetdone(1),
    GT2_RX_FSM_RESET_DONE_OUT  => rx_resetdone(2),
    GT3_RX_FSM_RESET_DONE_OUT  => rx_resetdone(3),
    GT4_RX_FSM_RESET_DONE_OUT  => rx_resetdone(4),
    GT5_RX_FSM_RESET_DONE_OUT  => rx_resetdone(5),
    GT6_RX_FSM_RESET_DONE_OUT  => rx_resetdone(6),
    GT7_RX_FSM_RESET_DONE_OUT  => rx_resetdone(7),
    GT8_RX_FSM_RESET_DONE_OUT  => rx_resetdone(8),
    GT9_RX_FSM_RESET_DONE_OUT  => rx_resetdone(9),
    GT10_RX_FSM_RESET_DONE_OUT => rx_resetdone(10),
    GT11_RX_FSM_RESET_DONE_OUT => rx_resetdone(11),
    GT12_RX_FSM_RESET_DONE_OUT => rx_resetdone(12),
    GT13_RX_FSM_RESET_DONE_OUT => rx_resetdone(13),
    GT14_RX_FSM_RESET_DONE_OUT => rx_resetdone(14),
    GT15_RX_FSM_RESET_DONE_OUT => rx_resetdone(15),
    GT16_RX_FSM_RESET_DONE_OUT => rx_resetdone(16),
    GT17_RX_FSM_RESET_DONE_OUT => rx_resetdone(17),
    GT18_RX_FSM_RESET_DONE_OUT => rx_resetdone(18),
    GT19_RX_FSM_RESET_DONE_OUT => rx_resetdone(19),
    GT20_RX_FSM_RESET_DONE_OUT => rx_resetdone(20),
    GT21_RX_FSM_RESET_DONE_OUT => rx_resetdone(21),
    GT22_RX_FSM_RESET_DONE_OUT => rx_resetdone(22),
    GT23_RX_FSM_RESET_DONE_OUT => rx_resetdone(23),
    GT24_RX_FSM_RESET_DONE_OUT => rx_resetdone(24),
    GT25_RX_FSM_RESET_DONE_OUT => rx_resetdone(25),
    GT26_RX_FSM_RESET_DONE_OUT => rx_resetdone(26),
    GT27_RX_FSM_RESET_DONE_OUT => rx_resetdone(27),
    GT28_RX_FSM_RESET_DONE_OUT => rx_resetdone(28),
    GT29_RX_FSM_RESET_DONE_OUT => rx_resetdone(29),
    GT30_RX_FSM_RESET_DONE_OUT => rx_resetdone(30),
    GT31_RX_FSM_RESET_DONE_OUT => rx_resetdone(31),
     GT0_DATA_VALID_IN => '1',
     GT1_DATA_VALID_IN => '1',
     GT2_DATA_VALID_IN => '1',
     GT3_DATA_VALID_IN => '1',
     GT4_DATA_VALID_IN => '1',
     GT5_DATA_VALID_IN => '1',
     GT6_DATA_VALID_IN => '1',
     GT7_DATA_VALID_IN => '1',
     GT8_DATA_VALID_IN => '1',
     GT9_DATA_VALID_IN => '1',
     GT10_DATA_VALID_IN => '1',
     GT11_DATA_VALID_IN => '1',
     GT12_DATA_VALID_IN => '1',
     GT13_DATA_VALID_IN => '1',
     GT14_DATA_VALID_IN => '1',
     GT15_DATA_VALID_IN => '1',
     GT16_DATA_VALID_IN => '1',
     GT17_DATA_VALID_IN => '1',
     GT18_DATA_VALID_IN => '1',
     GT19_DATA_VALID_IN => '1',
     GT20_DATA_VALID_IN => '1',
     GT21_DATA_VALID_IN => '1',
     GT22_DATA_VALID_IN => '1',
     GT23_DATA_VALID_IN => '1',
     GT24_DATA_VALID_IN => '1',
     GT25_DATA_VALID_IN => '1',
     GT26_DATA_VALID_IN => '1',
     GT27_DATA_VALID_IN => '1',
     GT28_DATA_VALID_IN => '1',
     GT29_DATA_VALID_IN => '1',
     GT30_DATA_VALID_IN => '1',
     GT31_DATA_VALID_IN => '1',
    txusrclk2_in => txusrclk2_in,
    txusrclk_in => txusrclk_in,
     --GT0_TXUSRCLK2_OUT => txusrclk2,
     -- GT0_RXUSRCLK2_OUT => GT0_RXUSRCLK2_OUT,
     -- GT1_RXUSRCLK2_OUT => GT1_RXUSRCLK2_OUT,
     -- GT2_RXUSRCLK2_OUT => GT2_RXUSRCLK2_OUT,
     -- GT3_RXUSRCLK2_OUT => GT3_RXUSRCLK2_OUT,
     -- GT4_RXUSRCLK2_OUT => GT4_RXUSRCLK2_OUT,
     -- GT5_RXUSRCLK2_OUT => GT5_RXUSRCLK2_OUT,
     -- GT6_RXUSRCLK2_OUT => GT6_RXUSRCLK2_OUT,
     -- GT7_RXUSRCLK2_OUT => GT7_RXUSRCLK2_OUT,
     -- GT8_RXUSRCLK2_OUT => GT8_RXUSRCLK2_OUT,
     -- GT9_RXUSRCLK2_OUT => GT9_RXUSRCLK2_OUT,
     -- GT10_RXUSRCLK2_OUT => GT10_RXUSRCLK2_OUT,
     -- GT11_RXUSRCLK2_OUT => GT11_RXUSRCLK2_OUT,
     -- GT12_RXUSRCLK2_OUT => GT12_RXUSRCLK2_OUT,
     -- GT13_RXUSRCLK2_OUT => GT13_RXUSRCLK2_OUT,
     -- GT14_RXUSRCLK2_OUT => GT14_RXUSRCLK2_OUT,
     -- GT15_RXUSRCLK2_OUT => GT15_RXUSRCLK2_OUT,
     -- GT16_RXUSRCLK2_OUT => GT16_RXUSRCLK2_OUT,
     -- GT17_RXUSRCLK2_OUT => GT17_RXUSRCLK2_OUT,
     -- GT18_RXUSRCLK2_OUT => GT18_RXUSRCLK2_OUT,
     -- GT19_RXUSRCLK2_OUT => GT19_RXUSRCLK2_OUT,
     -- GT20_RXUSRCLK2_OUT => GT20_RXUSRCLK2_OUT,
     -- GT21_RXUSRCLK2_OUT => GT21_RXUSRCLK2_OUT,
     -- GT22_RXUSRCLK2_OUT => GT22_RXUSRCLK2_OUT,
     -- GT23_RXUSRCLK2_OUT => GT23_RXUSRCLK2_OUT,
     -- GT24_RXUSRCLK2_OUT => GT24_RXUSRCLK2_OUT,
     -- GT25_RXUSRCLK2_OUT => GT25_RXUSRCLK2_OUT,
     -- GT26_RXUSRCLK2_OUT => GT26_RXUSRCLK2_OUT,
     -- GT27_RXUSRCLK2_OUT => GT27_RXUSRCLK2_OUT,
     -- GT28_RXUSRCLK2_OUT => GT28_RXUSRCLK2_OUT,
     -- GT29_RXUSRCLK2_OUT => GT29_RXUSRCLK2_OUT,
     -- GT30_RXUSRCLK2_OUT => GT30_RXUSRCLK2_OUT,
     -- GT31_RXUSRCLK2_OUT => GT31_RXUSRCLK2_OUT,
    -------EXT PORTS
        gt0_gthrxp_in                   =>      GTH_RXP(0),
        gt0_gthrxn_in                   =>      GTH_RXN(0),
        gt0_gthtxn_out                  =>      GTH_TXN(0),
        gt0_gthtxp_out                  =>      GTH_TXP(0),
        gt1_gthrxp_in                   =>      GTH_RXP(1),
        gt1_gthrxn_in                   =>      GTH_RXN(1),
        gt1_gthtxn_out                  =>      GTH_TXN(1),
        gt1_gthtxp_out                  =>      GTH_TXP(1),
        gt2_gthrxp_in                   =>      GTH_RXP(2),
        gt2_gthrxn_in                   =>      GTH_RXN(2),
        gt2_gthtxn_out                  =>      GTH_TXN(2),
        gt2_gthtxp_out                  =>      GTH_TXP(2),
        gt3_gthrxp_in                   =>      GTH_RXP(3),
        gt3_gthrxn_in                   =>      GTH_RXN(3),
        gt3_gthtxn_out                  =>      GTH_TXN(3),
        gt3_gthtxp_out                  =>      GTH_TXP(3),
        gt4_gthrxp_in                   =>      GTH_RXP(4),
        gt4_gthrxn_in                   =>      GTH_RXN(4),
        gt4_gthtxn_out                  =>      GTH_TXN(4),
        gt4_gthtxp_out                  =>      GTH_TXP(4),
        gt5_gthrxp_in                   =>      GTH_RXP(5),
        gt5_gthrxn_in                   =>      GTH_RXN(5),
        gt5_gthtxn_out                  =>      GTH_TXN(5),
        gt5_gthtxp_out                  =>      GTH_TXP(5),
        gt6_gthrxp_in                   =>      GTH_RXP(6),
        gt6_gthrxn_in                   =>      GTH_RXN(6),
        gt6_gthtxn_out                  =>      GTH_TXN(6),
        gt6_gthtxp_out                  =>      GTH_TXP(6),
        gt7_gthrxp_in                   =>      GTH_RXP(7),
        gt7_gthrxn_in                   =>      GTH_RXN(7),
        gt7_gthtxn_out                  =>      GTH_TXN(7),
        gt7_gthtxp_out                  =>      GTH_TXP(7),
        gt8_gthrxp_in                   =>      GTH_RXP(8),
        gt8_gthrxn_in                   =>      GTH_RXN(8),
        gt8_gthtxn_out                  =>      GTH_TXN(8),
        gt8_gthtxp_out                  =>      GTH_TXP(8),
        gt9_gthrxp_in                   =>      GTH_RXP(9),
        gt9_gthrxn_in                   =>      GTH_RXN(9),
        gt9_gthtxn_out                  =>      GTH_TXN(9),
        gt9_gthtxp_out                  =>      GTH_TXP(9),
        gt10_gthrxp_in                  =>      GTH_RXP(10),
        gt10_gthrxn_in                  =>      GTH_RXN(10),
        gt10_gthtxn_out                 =>      GTH_TXN(10),
        gt10_gthtxp_out                 =>      GTH_TXP(10),
        gt11_gthrxp_in                  =>      GTH_RXP(11),
        gt11_gthrxn_in                  =>      GTH_RXN(11),
        gt11_gthtxn_out                 =>      GTH_TXN(11),
        gt11_gthtxp_out                 =>      GTH_TXP(11),
        gt12_gthrxp_in                  =>      GTH_RXP(12),
        gt12_gthrxn_in                  =>      GTH_RXN(12),
        gt12_gthtxn_out                 =>      GTH_TXN(12),
        gt12_gthtxp_out                 =>      GTH_TXP(12),
        gt13_gthrxp_in                  =>      GTH_RXP(13),
        gt13_gthrxn_in                  =>      GTH_RXN(13),
        gt13_gthtxn_out                 =>      GTH_TXN(13),
        gt13_gthtxp_out                 =>      GTH_TXP(13),
        gt14_gthrxp_in                  =>      GTH_RXP(14),
        gt14_gthrxn_in                  =>      GTH_RXN(14),
        gt14_gthtxn_out                 =>      GTH_TXN(14),
        gt14_gthtxp_out                 =>      GTH_TXP(14),
        gt15_gthrxp_in                  =>      GTH_RXP(15),
        gt15_gthrxn_in                  =>      GTH_RXN(15),
        gt15_gthtxn_out                 =>      GTH_TXN(15),
        gt15_gthtxp_out                 =>      GTH_TXP(15),
        gt16_gthrxp_in                  =>      GTH_RXP(16),
        gt16_gthrxn_in                  =>      GTH_RXN(16),
        gt16_gthtxn_out                 =>      GTH_TXN(16),
        gt16_gthtxp_out                 =>      GTH_TXP(16),
        gt17_gthrxp_in                  =>      GTH_RXP(17),
        gt17_gthrxn_in                  =>      GTH_RXN(17),
        gt17_gthtxn_out                 =>      GTH_TXN(17),
        gt17_gthtxp_out                 =>      GTH_TXP(17),
        gt18_gthrxp_in                  =>      GTH_RXP(18),
        gt18_gthrxn_in                  =>      GTH_RXN(18),
        gt18_gthtxn_out                 =>      GTH_TXN(18),
        gt18_gthtxp_out                 =>      GTH_TXP(18),
        gt19_gthrxp_in                  =>      GTH_RXP(19),
        gt19_gthrxn_in                  =>      GTH_RXN(19),
        gt19_gthtxn_out                 =>      GTH_TXN(19),
        gt19_gthtxp_out                 =>      GTH_TXP(19),
        gt20_gthrxp_in                  =>      GTH_RXP(20),
        gt20_gthrxn_in                  =>      GTH_RXN(20),
        gt20_gthtxn_out                 =>      GTH_TXN(20),
        gt20_gthtxp_out                 =>      GTH_TXP(20),
        gt21_gthrxp_in                  =>      GTH_RXP(21),
        gt21_gthrxn_in                  =>      GTH_RXN(21),
        gt21_gthtxn_out                 =>      GTH_TXN(21),
        gt21_gthtxp_out                 =>      GTH_TXP(21),
        gt22_gthrxp_in                  =>      GTH_RXP(22),
        gt22_gthrxn_in                  =>      GTH_RXN(22),
        gt22_gthtxn_out                 =>      GTH_TXN(22),
        gt22_gthtxp_out                 =>      GTH_TXP(22),
        gt23_gthrxp_in                  =>      GTH_RXP(23),
        gt23_gthrxn_in                  =>      GTH_RXN(23),
        gt23_gthtxn_out                 =>      GTH_TXN(23),
        gt23_gthtxp_out                 =>      GTH_TXP(23),
        gt24_gthrxp_in                  =>      GTH_RXP(24),
        gt24_gthrxn_in                  =>      GTH_RXN(24),
        gt24_gthtxn_out                 =>      GTH_TXN(24),
        gt24_gthtxp_out                 =>      GTH_TXP(24),
        gt25_gthrxp_in                  =>      GTH_RXP(25),
        gt25_gthrxn_in                  =>      GTH_RXN(25),
        gt25_gthtxn_out                 =>      GTH_TXN(25),
        gt25_gthtxp_out                 =>      GTH_TXP(25),
        gt26_gthrxp_in                  =>      GTH_RXP(26),
        gt26_gthrxn_in                  =>      GTH_RXN(26),
        gt26_gthtxn_out                 =>      GTH_TXN(26),
        gt26_gthtxp_out                 =>      GTH_TXP(26),
        gt27_gthrxp_in                  =>      GTH_RXP(27),
        gt27_gthrxn_in                  =>      GTH_RXN(27),
        gt27_gthtxn_out                 =>      GTH_TXN(27),
        gt27_gthtxp_out                 =>      GTH_TXP(27),
        gt28_gthrxp_in                  =>      GTH_RXP(28),
        gt28_gthrxn_in                  =>      GTH_RXN(28),
        gt28_gthtxn_out                 =>      GTH_TXN(28),
        gt28_gthtxp_out                 =>      GTH_TXP(28),
        gt29_gthrxp_in                  =>      GTH_RXP(29),
        gt29_gthrxn_in                  =>      GTH_RXN(29),
        gt29_gthtxn_out                 =>      GTH_TXN(29),
        gt29_gthtxp_out                 =>      GTH_TXP(29),
        gt30_gthrxp_in                  =>      GTH_RXP(30),
        gt30_gthrxn_in                  =>      GTH_RXN(30),
        gt30_gthtxn_out                 =>      GTH_TXN(30),
        gt30_gthtxp_out                 =>      GTH_TXP(30),
        gt31_gthrxp_in                  =>      GTH_RXP(31),
        gt31_gthrxn_in                  =>      GTH_RXN(31),
        gt31_gthtxn_out                 =>      GTH_TXN(31),
        gt31_gthtxp_out                 =>      GTH_TXP(31),
    ----------------------------------------------------------
    ---- TX Data ports
        gt0_txdata_in                   =>      txdata_in(0),
        gt1_txdata_in                   =>      txdata_in(1),
        gt2_txdata_in                   =>      txdata_in(2),
        gt3_txdata_in                   =>      txdata_in(3),
        gt4_txdata_in                   =>      txdata_in(4),
        gt5_txdata_in                   =>      txdata_in(5),
        gt6_txdata_in                   =>      txdata_in(6),
        gt7_txdata_in                   =>      txdata_in(7),
        gt8_txdata_in                   =>      txdata_in(8),
        gt9_txdata_in                   =>      txdata_in(9),
        gt10_txdata_in                  =>      txdata_in(10),
        gt11_txdata_in                  =>      txdata_in(11),
        gt12_txdata_in                  =>      txdata_in(12),
        gt13_txdata_in                  =>      txdata_in(13),
        gt14_txdata_in                  =>      txdata_in(14),
        gt15_txdata_in                  =>      txdata_in(15),
        gt16_txdata_in                  =>      txdata_in(16),
        gt17_txdata_in                  =>      txdata_in(17),
        gt18_txdata_in                  =>      txdata_in(18),
        gt19_txdata_in                  =>      txdata_in(19),
        gt20_txdata_in                  =>      txdata_in(20),
        gt21_txdata_in                  =>      txdata_in(21),
        gt22_txdata_in                  =>      txdata_in(22),
        gt23_txdata_in                  =>      txdata_in(23),
        gt24_txdata_in                  =>      txdata_in(24),
        gt25_txdata_in                  =>      txdata_in(25),
        gt26_txdata_in                  =>      txdata_in(26),
        gt27_txdata_in                  =>      txdata_in(27),
        gt28_txdata_in                  =>      txdata_in(28),
        gt29_txdata_in                  =>      txdata_in(29),
        gt30_txdata_in                  =>      txdata_in(30),
        gt31_txdata_in                  =>      txdata_in(31),
    -----------------------------------------------------------
    ----tx char is k
        gt0_txcharisk_in                =>      txcharisk_in(0),
        gt1_txcharisk_in                =>      txcharisk_in(1),
        gt2_txcharisk_in                =>      txcharisk_in(2),
        gt3_txcharisk_in                =>      txcharisk_in(3),
        gt4_txcharisk_in                =>      txcharisk_in(4),
        gt5_txcharisk_in                =>      txcharisk_in(5),
        gt6_txcharisk_in                =>      txcharisk_in(6),
        gt7_txcharisk_in                =>      txcharisk_in(7),
        gt8_txcharisk_in                =>      txcharisk_in(8),
        gt9_txcharisk_in                =>      txcharisk_in(9),
        gt10_txcharisk_in               =>      txcharisk_in(10),
        gt11_txcharisk_in               =>      txcharisk_in(11),
        gt12_txcharisk_in               =>      txcharisk_in(12),
        gt13_txcharisk_in               =>      txcharisk_in(13),
        gt14_txcharisk_in               =>      txcharisk_in(14),
        gt15_txcharisk_in               =>      txcharisk_in(15),
        gt16_txcharisk_in               =>      txcharisk_in(16),
        gt17_txcharisk_in               =>      txcharisk_in(17),
        gt18_txcharisk_in               =>      txcharisk_in(18),
        gt19_txcharisk_in               =>      txcharisk_in(19),
        gt20_txcharisk_in               =>      txcharisk_in(20),
        gt21_txcharisk_in               =>      txcharisk_in(21),
        gt22_txcharisk_in               =>      txcharisk_in(22),
        gt23_txcharisk_in               =>      txcharisk_in(23),
        gt24_txcharisk_in               =>      txcharisk_in(24),
        gt25_txcharisk_in               =>      txcharisk_in(25),
        gt26_txcharisk_in               =>      txcharisk_in(26),
        gt27_txcharisk_in               =>      txcharisk_in(27),
        gt28_txcharisk_in               =>      txcharisk_in(28),
        gt29_txcharisk_in               =>      txcharisk_in(29),
        gt30_txcharisk_in               =>      txcharisk_in(30),
        gt31_txcharisk_in               =>      txcharisk_in(31),
    ----RX data ports
        gt0_rxdata_out                  =>      rxdata_i(0),
        gt1_rxdata_out                  =>      rxdata_i(1),
        gt2_rxdata_out                  =>      rxdata_i(2),
        gt3_rxdata_out                  =>      rxdata_i(3),
        gt4_rxdata_out                  =>      rxdata_i(4),
        gt5_rxdata_out                  =>      rxdata_i(5),
        gt6_rxdata_out                  =>      rxdata_i(6),
        gt7_rxdata_out                  =>      rxdata_i(7),
        gt8_rxdata_out                  =>      rxdata_i(8),
        gt9_rxdata_out                  =>      rxdata_i(9),
        gt10_rxdata_out                 =>      rxdata_i(10),
        gt11_rxdata_out                 =>      rxdata_i(11),
        gt12_rxdata_out                 =>      rxdata_i(12),
        gt13_rxdata_out                 =>      rxdata_i(13),
        gt14_rxdata_out                 =>      rxdata_i(14),
        gt15_rxdata_out                 =>      rxdata_i(15),
        gt16_rxdata_out                 =>      rxdata_i(16),
        gt17_rxdata_out                 =>      rxdata_i(17),
        gt18_rxdata_out                 =>      rxdata_i(18),
        gt19_rxdata_out                 =>      rxdata_i(19),
        gt20_rxdata_out                 =>      rxdata_i(20),
        gt21_rxdata_out                 =>      rxdata_i(21),
        gt22_rxdata_out                 =>      rxdata_i(22),
        gt23_rxdata_out                 =>      rxdata_i(23),
        gt24_rxdata_out                 =>      rxdata_i(24),
        gt25_rxdata_out                 =>      rxdata_i(25),
        gt26_rxdata_out                 =>      rxdata_i(26),
        gt27_rxdata_out                 =>      rxdata_i(27),
        gt28_rxdata_out                 =>      rxdata_i(28),
        gt29_rxdata_out                 =>      rxdata_i(29),
        gt30_rxdata_out                 =>      rxdata_i(30),
        gt31_rxdata_out                 =>      rxdata_i(31),
    ------------------------------------------------------------------
    ----rx aligned
        -- gt0_rxbyteisaligned_out         =>      rx_aligned(0),
        -- gt1_rxbyteisaligned_out         =>      rx_aligned(1),
        -- gt2_rxbyteisaligned_out         =>      rx_aligned(2),
        -- gt3_rxbyteisaligned_out         =>      rx_aligned(3),
        -- gt4_rxbyteisaligned_out         =>      rx_aligned(4),
        -- gt5_rxbyteisaligned_out         =>      rx_aligned(5),
        -- gt6_rxbyteisaligned_out         =>      rx_aligned(6),
        -- gt7_rxbyteisaligned_out         =>      rx_aligned(7),
        -- gt8_rxbyteisaligned_out         =>      rx_aligned(8),
        -- gt9_rxbyteisaligned_out         =>      rx_aligned(9),
        -- gt10_rxbyteisaligned_out        =>      rx_aligned(10),
        -- gt11_rxbyteisaligned_out        =>      rx_aligned(11),
        -- gt12_rxbyteisaligned_out        =>      rx_aligned(12),
        -- gt13_rxbyteisaligned_out        =>      rx_aligned(13),
        -- gt14_rxbyteisaligned_out        =>      rx_aligned(14),
        -- gt15_rxbyteisaligned_out        =>      rx_aligned(15),
        -- gt16_rxbyteisaligned_out        =>      rx_aligned(16),
        -- gt17_rxbyteisaligned_out        =>      rx_aligned(17),
        -- gt18_rxbyteisaligned_out        =>      rx_aligned(18),
        -- gt19_rxbyteisaligned_out        =>      rx_aligned(19),
        -- gt20_rxbyteisaligned_out        =>      rx_aligned(20),
        -- gt21_rxbyteisaligned_out        =>      rx_aligned(21),
        -- gt22_rxbyteisaligned_out        =>      rx_aligned(22),
        -- gt23_rxbyteisaligned_out        =>      rx_aligned(23),
        -- gt24_rxbyteisaligned_out        =>      rx_aligned(24),
        -- gt25_rxbyteisaligned_out        =>      rx_aligned(25),
        -- gt26_rxbyteisaligned_out        =>      rx_aligned(26),
        -- gt27_rxbyteisaligned_out        =>      rx_aligned(27),
        -- gt28_rxbyteisaligned_out        =>      rx_aligned(28),
        -- gt29_rxbyteisaligned_out        =>      rx_aligned(29),
        -- gt30_rxbyteisaligned_out        =>      rx_aligned(30),
        -- gt31_rxbyteisaligned_out        =>      rx_aligned(31),
    --------------------------------------------------------------
    ----rx slide
        gt0_rxslide_in                  =>      rxslide_in(0),
        gt1_rxslide_in                  =>      rxslide_in(1),
        gt2_rxslide_in                  =>      rxslide_in(2),
        gt3_rxslide_in                  =>      rxslide_in(3),
        gt4_rxslide_in                  =>      rxslide_in(4),
        gt5_rxslide_in                  =>      rxslide_in(5),
        gt6_rxslide_in                  =>      rxslide_in(6),
        gt7_rxslide_in                  =>      rxslide_in(7),
        gt8_rxslide_in                  =>      rxslide_in(8),
        gt9_rxslide_in                  =>      rxslide_in(9),
        gt10_rxslide_in                 =>      rxslide_in(10),
        gt11_rxslide_in                 =>      rxslide_in(11),
        gt12_rxslide_in                 =>      rxslide_in(12),
        gt13_rxslide_in                 =>      rxslide_in(13),
        gt14_rxslide_in                 =>      rxslide_in(14),
        gt15_rxslide_in                 =>      rxslide_in(15),
        gt16_rxslide_in                 =>      rxslide_in(16),
        gt17_rxslide_in                 =>      rxslide_in(17),
        gt18_rxslide_in                 =>      rxslide_in(18),
        gt19_rxslide_in                 =>      rxslide_in(19),
        gt20_rxslide_in                 =>      rxslide_in(20),
        gt21_rxslide_in                 =>      rxslide_in(21),
        gt22_rxslide_in                 =>      rxslide_in(22),
        gt23_rxslide_in                 =>      rxslide_in(23),
        gt24_rxslide_in                 =>      rxslide_in(24),
        gt25_rxslide_in                 =>      rxslide_in(25),
        gt26_rxslide_in                 =>      rxslide_in(26),
        gt27_rxslide_in                 =>      rxslide_in(27),
        gt28_rxslide_in                 =>      rxslide_in(28),
        gt29_rxslide_in                 =>      rxslide_in(29),
        gt30_rxslide_in                 =>      rxslide_in(30),
        gt31_rxslide_in                 =>      rxslide_in(31),
    --_________________________________________________________________________
    --GT0  (X0Y4)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt0_drpaddr_in                  =>      (others => '0'),
        gt0_drpdi_in                    =>      (others => '0'),
        gt0_drpen_in                    =>      '0',
        gt0_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt0_eyescanreset_in             =>      '0',
        gt0_rxuserrdy_in                =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt0_eyescantrigger_in           =>      '1',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt0_rxmonitorsel_in             =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt0_gtrxreset_in                =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt0_gttxreset_in                =>      '0',
        gt0_txuserrdy_in                =>      '1',

    --GT1  (X0Y5)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt1_drpaddr_in                  =>      (others => '0'),
        gt1_drpdi_in                    =>      (others => '0'),
        gt1_drpen_in                    =>      '0',
        gt1_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt1_eyescanreset_in             =>      '0',
        gt1_rxuserrdy_in                =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt1_eyescantrigger_in           =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt1_rxmonitorsel_in             =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt1_gtrxreset_in                =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt1_gttxreset_in                =>      '0',
        gt1_txuserrdy_in                =>      '1',

    --GT2  (X0Y6)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt2_drpaddr_in                  =>      (others => '0'),
        gt2_drpdi_in                    =>      (others => '0'),
        gt2_drpen_in                    =>      '0',
        gt2_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt2_eyescanreset_in             =>      '0',
        gt2_rxuserrdy_in                =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt2_eyescantrigger_in           =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt2_rxmonitorsel_in             =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt2_gtrxreset_in                =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt2_gttxreset_in                =>      '0',
        gt2_txuserrdy_in                =>      '1',

    --GT3  (X0Y7)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt3_drpaddr_in                  =>      (others => '0'),
        gt3_drpdi_in                    =>      (others => '0'),
        gt3_drpen_in                    =>      '0',
        gt3_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt3_eyescanreset_in             =>      '0',
        gt3_rxuserrdy_in                =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt3_eyescantrigger_in           =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt3_rxmonitorsel_in             =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt3_gtrxreset_in                =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt3_gttxreset_in                =>      '0',
        gt3_txuserrdy_in                =>      '1',

    --GT4  (X0Y8)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt4_drpaddr_in                  =>      (others => '0'),
        gt4_drpdi_in                    =>      (others => '0'),
        gt4_drpen_in                    =>      '0',
        gt4_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt4_eyescanreset_in             =>      '0',
        gt4_rxuserrdy_in                =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt4_eyescantrigger_in           =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt4_rxmonitorsel_in             =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt4_gtrxreset_in                =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt4_gttxreset_in                =>      '0',
        gt4_txuserrdy_in                =>      '1',

    --GT5  (X0Y9)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt5_drpaddr_in                  =>      (others => '0'),
        gt5_drpdi_in                    =>      (others => '0'),
        gt5_drpen_in                    =>      '0',
        gt5_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt5_eyescanreset_in             =>      '0',
        gt5_rxuserrdy_in                =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt5_eyescantrigger_in           =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt5_rxmonitorsel_in             =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt5_gtrxreset_in                =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt5_gttxreset_in                =>      '0',
        gt5_txuserrdy_in                =>      '1',

    --GT6  (X0Y10)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt6_drpaddr_in                  =>      (others => '0'),
        gt6_drpdi_in                    =>      (others => '0'),
        gt6_drpen_in                    =>      '0',
        gt6_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt6_eyescanreset_in             =>      '0',
        gt6_rxuserrdy_in                =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt6_eyescantrigger_in           =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt6_rxmonitorsel_in             =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt6_gtrxreset_in                =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt6_gttxreset_in                =>      '0',
        gt6_txuserrdy_in                =>      '1',

    --GT7  (X0Y11)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt7_drpaddr_in                  =>      (others => '0'),
        gt7_drpdi_in                    =>      (others => '0'),
        gt7_drpen_in                    =>      '0',
        gt7_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt7_eyescanreset_in             =>      '0',
        gt7_rxuserrdy_in                =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt7_eyescantrigger_in           =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt7_rxmonitorsel_in             =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt7_gtrxreset_in                =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt7_gttxreset_in                =>      '0',
        gt7_txuserrdy_in                =>      '1',

    --GT8  (X0Y12)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt8_drpaddr_in                  =>      (others => '0'),
        gt8_drpdi_in                    =>      (others => '0'),
        gt8_drpen_in                    =>      '0',
        gt8_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt8_eyescanreset_in             =>      '0',
        gt8_rxuserrdy_in                =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt8_eyescantrigger_in           =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt8_rxmonitorsel_in             =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt8_gtrxreset_in                =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt8_gttxreset_in                =>      '0',
        gt8_txuserrdy_in                =>      '1',

    --GT9  (X0Y13)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt9_drpaddr_in                  =>      (others => '0'),
        gt9_drpdi_in                    =>      (others => '0'),
        gt9_drpen_in                    =>      '0',
        gt9_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt9_eyescanreset_in             =>      '0',
        gt9_rxuserrdy_in                =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt9_eyescantrigger_in           =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt9_rxmonitorsel_in             =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt9_gtrxreset_in                =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt9_gttxreset_in                =>      '0',
        gt9_txuserrdy_in                =>      '1',

    --GT10  (X0Y14)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt10_drpaddr_in                  =>      (others => '0'),
        gt10_drpdi_in                    =>      (others => '0'),
        gt10_drpen_in                    =>      '0',
        gt10_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt10_eyescanreset_in            =>      '0',
        gt10_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt10_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt10_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt10_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt10_gttxreset_in               =>      '0',
        gt10_txuserrdy_in               =>      '1',

    --GT11  (X0Y15)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt11_drpaddr_in                  =>      (others => '0'),
        gt11_drpdi_in                    =>      (others => '0'),
        gt11_drpen_in                    =>      '0',
        gt11_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt11_eyescanreset_in            =>      '0',
        gt11_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt11_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt11_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt11_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt11_gttxreset_in               =>      '0',
        gt11_txuserrdy_in               =>      '1',

    --GT12  (X0Y16)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt12_drpaddr_in                  =>      (others => '0'),
        gt12_drpdi_in                    =>      (others => '0'),
        gt12_drpen_in                    =>      '0',
        gt12_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt12_eyescanreset_in            =>      '0',
        gt12_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt12_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt12_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt12_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt12_gttxreset_in               =>      '0',
        gt12_txuserrdy_in               =>      '1',

    --GT13  (X0Y17)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt13_drpaddr_in                  =>      (others => '0'),
        gt13_drpdi_in                    =>      (others => '0'),
        gt13_drpen_in                    =>      '0',
        gt13_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt13_eyescanreset_in            =>      '0',
        gt13_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt13_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt13_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt13_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt13_gttxreset_in               =>      '0',
        gt13_txuserrdy_in               =>      '1',

    --GT14  (X0Y18)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt14_drpaddr_in                  =>      (others => '0'),
        gt14_drpdi_in                    =>      (others => '0'),
        gt14_drpen_in                    =>      '0',
        gt14_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt14_eyescanreset_in            =>      '0',
        gt14_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt14_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt14_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt14_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt14_gttxreset_in               =>      '0',
        gt14_txuserrdy_in               =>      '1',

    --GT15  (X0Y19)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt15_drpaddr_in                  =>      (others => '0'),
        gt15_drpdi_in                    =>      (others => '0'),
        gt15_drpen_in                    =>      '0',
        gt15_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt15_eyescanreset_in            =>      '0',
        gt15_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt15_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt15_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt15_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt15_gttxreset_in               =>      '0',
        gt15_txuserrdy_in               =>      '1',

    --GT16  (X0Y20)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt16_drpaddr_in                  =>      (others => '0'),
        gt16_drpdi_in                    =>      (others => '0'),
        gt16_drpen_in                    =>      '0',
        gt16_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt16_eyescanreset_in            =>      '0',
        gt16_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt16_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt16_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt16_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt16_gttxreset_in               =>      '0',
        gt16_txuserrdy_in               =>      '1',

    --GT17  (X0Y21)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt17_drpaddr_in                  =>      (others => '0'),
        gt17_drpdi_in                    =>      (others => '0'),
        gt17_drpen_in                    =>      '0',
        gt17_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt17_eyescanreset_in            =>      '0',
        gt17_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt17_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt17_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt17_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt17_gttxreset_in               =>      '0',
        gt17_txuserrdy_in               =>      '1',

    --GT18  (X0Y22)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt18_drpaddr_in                  =>      (others => '0'),
        gt18_drpdi_in                    =>      (others => '0'),
        gt18_drpen_in                    =>      '0',
        gt18_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt18_eyescanreset_in            =>      '0',
        gt18_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt18_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt18_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt18_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt18_gttxreset_in               =>      '0',
        gt18_txuserrdy_in               =>      '1',

    --GT19  (X0Y23)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt19_drpaddr_in                  =>      (others => '0'),
        gt19_drpdi_in                    =>      (others => '0'),
        gt19_drpen_in                    =>      '0',
        gt19_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt19_eyescanreset_in            =>      '0',
        gt19_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt19_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt19_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt19_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt19_gttxreset_in               =>      '0',
        gt19_txuserrdy_in               =>      '1',

    --GT20  (X0Y24)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt20_drpaddr_in                  =>      (others => '0'),
        gt20_drpdi_in                    =>      (others => '0'),
        gt20_drpen_in                    =>      '0',
        gt20_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt20_eyescanreset_in            =>      '0',
        gt20_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt20_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt20_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt20_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt20_gttxreset_in               =>      '0',
        gt20_txuserrdy_in               =>      '1',

    --GT21  (X0Y25)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt21_drpaddr_in                  =>      (others => '0'),
        gt21_drpdi_in                    =>      (others => '0'),
        gt21_drpen_in                    =>      '0',
        gt21_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt21_eyescanreset_in            =>      '0',
        gt21_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt21_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt21_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt21_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt21_gttxreset_in               =>      '0',
        gt21_txuserrdy_in               =>      '1',

    --GT22  (X0Y26)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt22_drpaddr_in                  =>      (others => '0'),
        gt22_drpdi_in                    =>      (others => '0'),
        gt22_drpen_in                    =>      '0',
        gt22_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt22_eyescanreset_in            =>      '0',
        gt22_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt22_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt22_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt22_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt22_gttxreset_in               =>      '0',
        gt22_txuserrdy_in               =>      '1',

    --GT23  (X0Y27)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt23_drpaddr_in                  =>      (others => '0'),
        gt23_drpdi_in                    =>      (others => '0'),
        gt23_drpen_in                    =>      '0',
        gt23_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt23_eyescanreset_in            =>      '0',
        gt23_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt23_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt23_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt23_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt23_gttxreset_in               =>      '0',
        gt23_txuserrdy_in               =>      '1',

    --GT24  (X0Y28)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt24_drpaddr_in                  =>      (others => '0'),
        gt24_drpdi_in                    =>      (others => '0'),
        gt24_drpen_in                    =>      '0',
        gt24_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt24_eyescanreset_in            =>      '0',
        gt24_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt24_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt24_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt24_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt24_gttxreset_in               =>      '0',
        gt24_txuserrdy_in               =>      '1',

    --GT25  (X0Y29)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt25_drpaddr_in                  =>      (others => '0'),
        gt25_drpdi_in                    =>      (others => '0'),
        gt25_drpen_in                    =>      '0',
        gt25_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt25_eyescanreset_in            =>      '0',
        gt25_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt25_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt25_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt25_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt25_gttxreset_in               =>      '0',
        gt25_txuserrdy_in               =>      '1',

    --GT26  (X0Y30)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt26_drpaddr_in                  =>      (others => '0'),
        gt26_drpdi_in                    =>      (others => '0'),
        gt26_drpen_in                    =>      '0',
        gt26_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt26_eyescanreset_in            =>      '0',
        gt26_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt26_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt26_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt26_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt26_gttxreset_in               =>      '0',
        gt26_txuserrdy_in               =>      '1',

    --GT27  (X0Y31)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt27_drpaddr_in                  =>      (others => '0'),
        gt27_drpdi_in                    =>      (others => '0'),
        gt27_drpen_in                    =>      '0',
        gt27_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt27_eyescanreset_in            =>      '0',
        gt27_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt27_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt27_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt27_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt27_gttxreset_in               =>      '0',
        gt27_txuserrdy_in               =>      '1',

    --GT28  (X0Y32)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt28_drpaddr_in                  =>      (others => '0'),
        gt28_drpdi_in                    =>      (others => '0'),
        gt28_drpen_in                    =>      '0',
        gt28_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt28_eyescanreset_in            =>      '0',
        gt28_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt28_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt28_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt28_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt28_gttxreset_in               =>      '0',
        gt28_txuserrdy_in               =>      '1',

    --GT29  (X0Y33)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt29_drpaddr_in                  =>      (others => '0'),
        gt29_drpdi_in                    =>      (others => '0'),
        gt29_drpen_in                    =>      '0',
        gt29_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt29_eyescanreset_in            =>      '0',
        gt29_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt29_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt29_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt29_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt29_gttxreset_in               =>      '0',
        gt29_txuserrdy_in               =>      '1',

    --GT30  (X0Y34)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt30_drpaddr_in                  =>      (others => '0'),
        gt30_drpdi_in                    =>      (others => '0'),
        gt30_drpen_in                    =>      '0',
        gt30_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt30_eyescanreset_in            =>      '0',
        gt30_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt30_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt30_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt30_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt30_gttxreset_in               =>      '0',
        gt30_txuserrdy_in               =>      '1',

    --GT31  (X0Y35)
    --____________________________CHANNEL PORTS________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
        gt31_drpaddr_in                  =>      (others => '0'),
        gt31_drpdi_in                    =>      (others => '0'),
        gt31_drpen_in                    =>      '0',
        gt31_drpwe_in                    =>      '0',
    --------------------- RX Initialization and Reset Ports --------------------
        gt31_eyescanreset_in            =>      '0',
        gt31_rxuserrdy_in               =>      '1',
    -------------------------- RX Margin Analysis Ports ------------------------
        gt31_eyescantrigger_in          =>      '0',
    --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt31_rxmonitorsel_in            =>      "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt31_gtrxreset_in               =>      '0',
    --------------------- TX Initialization and Reset Ports --------------------
        gt31_gttxreset_in               =>      '0',
        gt31_txuserrdy_in               =>      '1',
     sysclk_in => sysclk_i

);

end Behavioral;
