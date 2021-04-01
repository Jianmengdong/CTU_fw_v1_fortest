library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.CTU_pack.all;
entity ch_hit_delay is
    generic(
    DELAY_CYCLE : integer range 0 to 8 := 0
    );
    Port (
    clk_in  : in std_logic;
    data_in : in unsigned(15 downto 0);
    data_mask : in std_logic;
    data_out : out unsigned(15 downto 0)
  );
end ch_hit_delay;

architecture Behavioral of ch_hit_delay is
    signal data_r : t_uarray16(DELAY_CYCLE downto 0);
    signal data_d : unsigned(15 downto 0);
begin

NoDelayGen: if DELAY_CYCLE = 0 generate
begin
    data_d <= data_in;
end generate;

DelayGen: if DELAY_CYCLE > 0 generate
begin
    data_r(0) <= data_in;
    DelayChainGen: for i in 0 to DELAY_CYCLE - 1 generate
        process(clk_in)
        begin
            if rising_edge(clk_in) then
                data_r(i + 1) <= data_r(i);
            end if;
        end process;
    end generate;
    data_d <= data_r(DELAY_CYCLE);
end generate;
data_out <= data_d when data_mask = '0' else (others => '0');
end Behavioral;