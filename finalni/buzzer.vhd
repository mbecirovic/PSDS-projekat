library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buzzer is
	port(clk: in std_logic;
		  sound_length: in std_logic_vector(2 downto 0);
		  enable: in std_logic;
		  sound: out std_logic);
end buzzer;

architecture buzzer_arch of buzzer is
	signal counter50, counter50_next: integer := 0;
	signal sekunde, sekunde_next: integer := 0;

	begin
	process(clk, enable)
		begin
		if enable = '0' then
			sekunde <= 0;
			counter50 <= 0;
		elsif rising_edge(clk) then
			counter50 <= counter50_next;
			sekunde <= sekunde_next;
		end if;
	end process;
	

	
	counter50_next <= 0 when counter50 = 50_000_000 else
							counter50 + 1;
							
	sekunde_next <= sekunde +  1 when counter50 = 50_000_000 else sekunde;	
	
	sound <= '0' when sekunde <= to_integer(unsigned(sound_length)) and enable = '1' else
				'1';
				
end buzzer_arch; 