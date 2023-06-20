library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seg27 is
    port(
        i: in unsigned(3 downto 0);
        o : out std_logic_vector(6 downto 0)
    );
end seg27;

architecture Seg27 of seg27 is
begin
    o(0) <= not( i(3) or i(1) or not(i(2) xor i(0)));
    o(1) <= not( not i(2) or not(i(1) xor i(0)));
    o(2) <= not( not i(1) or i(0) or i(2));
    o(3) <= not( i(3) or (not i(2) and not i(0)) or (not i(2) and i(1)) or (i(1) and not i(0)) or (i(2) and not i(1) and i(0)));
    o(4) <= not((i(1) and not i(0)) or (not i(2) and not i(0)));
    o(5) <= not( i(3) or (i(2) and not i(0)) or (i(2) and not i(1)) or (not i(1) and not i(0)));
    o(6) <= not( i(3) or (i(1) and not i(0)) or (i(2) xor i(1)));
end Seg27;