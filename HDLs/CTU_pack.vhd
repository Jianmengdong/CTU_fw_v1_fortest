
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

package CTU_pack is

    type t_array8 is array (integer range<>) of std_logic_vector(7 downto 0);
    type t_array16 is array (integer range<>) of std_logic_vector(15 downto 0);
    type t_array64 is array (integer range<>) of std_logic_vector(63 downto 0);
    type t_array672 is array (integer range<>) of std_logic_vector(671 downto 0);
    
    type t_uarray16 is array (integer range<>) of unsigned(15 downto 0);
    constant delay_cycle_vector : t_array672(1 downto 0) := 
           (0=> x"888887777777777766666666666666665555555555555555555555554444444444444444444444444444444333333333533333333333333333333222222222222222222221111111111111111111000000000000",
            1=> x"888887777777777766666666666666665555555555555555555555554444444444444444444444444444444333333333533333333333333333333222222222222222222221111111111111111111000000000000"
            );

end CTU_pack;

package body CTU_pack is


end CTU_pack;
