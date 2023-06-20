library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buzzerTest is
	port(clk: in std_logic;
		  sound_length: in std_logic_vector(2 downto 0);
		  enable: in std_logic;
		  sound: out std_logic);
end buzzerTest;

architecture b of buzzerTest is
		signal play : std_logic := '0';
		
		component buzzer is
			port(clk: in std_logic;
			sound_length: in std_logic_vector(2 downto 0);
			enable: in std_logic;
			sound: out std_logic);
		end component;
		
		begin
		testiranje: buzzer port map(clk,"011",enable,sound);
		play <= enable;
end b; 