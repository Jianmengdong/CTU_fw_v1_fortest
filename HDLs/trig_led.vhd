
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity trig_led is
    Port ( clk_i : in STD_LOGIC;
           trig_i : in STD_LOGIC;
           led_o : out STD_LOGIC);
end trig_led;

architecture Behavioral of trig_led is
signal st : integer range 0 to 1;
signal cnt : integer range 0 to 624999;
begin

process(clk_i)
begin
    if rising_edge(clk_i) then
        case st is
            when 0 =>
                led_o <= '0';
                cnt <= 0;
                if trig_i = '1' then
                    st <= 1;
                end if;
            when 1 => 
                led_o <= '1';
                cnt <= cnt + 1;
                if cnt >= 624999 then
                    st <= 0;
                end if;
            when others =>
                st <= 0;
        end case;
    end if;
end process;

end Behavioral;
