library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.CTU_pack.all;
entity ch_hit_delay_v2 is
    Port ( 
    clk_i : in STD_LOGIC;
    data_in : in unsigned(15 downto 0);
    data_mask : in std_logic;
    tap_cnt_in : in std_logic_vector(3 downto 0);
    data_out : out unsigned(15 downto 0)
    );
end ch_hit_delay_v2;

architecture Behavioral of ch_hit_delay_v2 is
    signal data_r : t_uarray16(11 downto 0);
    signal sel : integer range 0 to 11;
begin
data_r(0) <= data_in;
P_delay_pipe:process(clk_i)
begin
    if rising_edge(clk_i) then
        data_r(1) <= data_in;
        data_r(2) <= data_r(1);
        data_r(3) <= data_r(2);
        data_r(4) <= data_r(3);
        data_r(5) <= data_r(4);
        data_r(6) <= data_r(5);
        data_r(7) <= data_r(6);
        data_r(8) <= data_r(7);
        data_r(9) <= data_r(8);
        data_r(10) <= data_r(9);
        data_r(11) <= data_r(10);
    end if;
end process;

sel <= to_integer(unsigned(tap_cnt_in));
data_out <= data_r(sel);
end Behavioral;
