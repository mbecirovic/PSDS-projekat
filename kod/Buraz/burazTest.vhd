library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity burazTest is
	port(clk: in std_logic;
		  enable: in std_logic;
		  composition: in std_logic_vector(9 downto 0);
		  sound: out std_logic
	);
end burazTest;

architecture buraz_arch of burazTest is
	
	component buraz is
	port(clk: in std_logic;
		  enable: in std_logic;
		  composition: in std_logic_vector(9 downto 0);
		  sound: out std_logic
	);
	end component;
	
	begin
		
	testiranje : buraz port map(clk,enable,"0011000011",sound);	
end buraz_arch;