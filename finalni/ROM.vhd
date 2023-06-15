library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM is
	port(
		
		re_i: in std_logic;
		raddr_i: in std_logic_vector(1 downto 0);
		rdata_o: out std_logic_vector(2 downto 0)
	);
end ROM;

architecture ROM_arch of ROM is
	
	type ROM_type is array(0 to 3) of std_logic_vector(2 downto 0);
	constant ROM: ROM_type := (0 => "001",
									 1 => "010",
									 2 => "011",
									 3 => "100");  --trajanje tonova: 1, 2, 3, 4 sekunde

	begin
	rdata_o <= ROM(to_integer(unsigned(raddr_i))) when re_i = '1' else "000";

	
end ROM_arch; 