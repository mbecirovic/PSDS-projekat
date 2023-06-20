library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM is
	port(
		rst: in std_logic;
		
		we_i: in std_logic;
		waddr_i: in std_logic_vector(1 downto 0);
		wdata_i: in std_logic_vector(9 downto 0);
		
		re_i: in std_logic;
		raddr_i: in std_logic_vector(1 downto 0);
		rdata_o: out std_logic_vector(9 downto 0)
		
	);
end entity;

architecture rtl of RAM is

type ram_type is array(1 downto 0) of std_logic_vector(9 downto 0);
signal ram: ram_type:=(others=>(others=>'0')); -- zero-initialize for SRAM-based FPGAs

begin

-- Write port

process (we_i,rst) is
begin
		if rst = '1' then
			ram <= (others=>(others=>'0'));
		elsif we_i='1' then
			ram(to_integer(unsigned(waddr_i)))<=wdata_i;
		end if;
end process;

-- Read port

process (re_i) is
begin
		if re_i='1' then
				rdata_o<=ram(to_integer(unsigned(raddr_i)));
		end if;

end process;

end architecture;