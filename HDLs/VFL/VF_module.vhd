
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.CTU_pack.all;
entity VF_module is
    Port ( 
    clk_i : in STD_LOGIC;
    ch_mask_in : in std_logic_vector(167 downto 0);
    raw_hit_in : t_array64(23 downto 0);
    threshold_i: in std_logic_vector(15 downto 0);
    accept_o : out std_logic
    );
end VF_module;

architecture Behavioral of VF_module is
signal accept : std_logic_vector(1 downto 0);
begin
Gen_VFL:for i in 0 to 1 generate
    Inst_VFL:entity work.VFL_top
        generic map(
        delay_cycle_vector => delay_cycle_vector(i)
        )
        port map(
        clk_i => clk_i,
        threshold_i => threshold_i,
        raw_hit_in => raw_hit_in,
        ch_mask_in => ch_mask_in,
        nhit_sum_o => open,
        accept_o => accept(i)
        );
end generate;
accept_o <= accept(0) or accept(1);
end Behavioral;
