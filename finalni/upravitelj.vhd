library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity upravitelj is 
	port(
		clk, rst: in std_logic;
		opcija: in std_logic_vector(1 downto 0);
		key_potvrdi: in std_logic; --key3
		echo: in std_logic;	

		trig: out std_logic;
		sound: out std_logic;		
		br_unesenih_tipki: out std_logic_vector(6 downto 0);
		full_FIFO: out std_logic
	);
end upravitelj;


architecture upravitelj_arch of upravitelj is
	
	component sonic is
    port(clk: in std_logic;
          echo: in std_logic;
          saljemo: out std_logic;
			 adresa_tona: out std_logic_vector(1 downto 0)
          );
	end component;
	
	component buzzer is
	port(clk: in std_logic;
		  sound_length: in std_logic_vector(2 downto 0);
		  enable: in std_logic;
		  sound: out std_logic);
	end component;
	
	component fifi is
		generic(
			B: natural:=10; -- number of bits
			W: natural:=3 -- number of address bits
		);
		port(
			clk, reset: in std_logic;
			rd, wr: in std_logic;
			w_data: in std_logic_vector (B-1 downto 0);
			empty, full: out std_logic;
			r_data: out std_logic_vector (B-1 downto 0)
		);
   end component;
  
  component buraz is
	port(clk: in std_logic;
		  enable: in std_logic;
		  composition: in std_logic_vector(9 downto 0);
		  sound: out std_logic
	);
	end component;
	
	component FourBit7seg is
    port(
        U : in std_logic_vector(3 downto 0);
        segments : out std_logic_vector(6 downto 0)
    );
	end component;
	
	component ROM is
	port(
		
		re_i: in std_logic;
		raddr_i: in std_logic_vector(1 downto 0);
		rdata_o: out std_logic_vector(2 downto 0)
	);
	end component;
	
	type state_type is (NISTA, SNIMANJE, SVIRANJE, BRISANJE);
	signal state, state_next: state_type;
	
	signal adresa_tona: std_logic_vector(1 downto 0);
	signal trig_signal: std_logic;
	
	signal enable_za_buraza: std_logic;
	signal kompozicija_signal: std_logic_vector(9 downto 0);
	signal kompozicija_citanje: std_logic_vector(9 downto 0);
	
	signal brisi_fifi: std_logic;
	signal read_signal: std_logic;
	signal write_signal: std_logic;
	signal full_FIFO_signal: std_logic;
	signal ton_k: std_logic_vector(1 downto 0);
	signal empty_FIFO_signal: std_logic;
	
	signal sekunde, sekunde_next: integer := 0;
	signal counter50, counter50_next: integer := 0;
	signal i, i_next: integer := 0;
	
	signal a_ton1, a_ton2, a_ton3, a_ton4, a_ton5: std_logic_vector(1 downto 0):="00";
	signal tonovi:std_logic_vector(9 downto 0);
	signal rdEnable, wrEnable: std_logic;


	
	
	begin
 
	process(clk, rst) is
		begin
		if rst = '1' then
			state <= NISTA;
			sekunde <= 0;
			i <= 0;
		elsif rising_edge(clk) then
			state <= state_next;
			counter50 <= counter50_next;
			sekunde <= sekunde_next;
		end if;
	end process;
	
	state_next <=  NISTA when opcija = "00" else 
						SNIMANJE when opcija = "01" else
						SVIRANJE when opcija = "10" else
						BRISANJE when opcija = "11";
						
	enable_za_buraza <= '1' when state = SVIRANJE else 
							  '0';
	brisi_fifi <= '1' when state = BRISANJE else 
					  '0';
	
	counter50_next <= 0 when counter50 = 50_000_000 else
							counter50 + 1;
	--SNIMANJE
			
	sekunde_next <= sekunde + 1 when counter50 = 50_000_000 and sekunde < 10 and state = SNIMANJE and i< 4 else
						 0	when counter50 = 50_000_000 and sekunde = 10 and state = SNIMANJE and i < 4 else
						 sekunde;
						 
	i_next <= i + 1 when sekunde mod 2 = 0 and counter50 = 50_000_000 and state = SNIMANJE else 
				 i;
				 
	tonovi(i) <= adresa_tona when sekunde mod 2=0 and sekunde<=10;			 
				 
	a_ton1 <= adresa_tona when sekunde = 2;
	a_ton2 <= adresa_tona when sekunde = 4;
	a_ton3 <= adresa_tona when sekunde = 6;
	a_ton4 <= adresa_tona when sekunde = 8;
	a_ton5 <= adresa_tona when sekunde = 10;
	 
	kompozicija_signal <= a_ton1 & a_ton2 & a_ton3 & a_ton4 & a_ton5;
	
	full_FIFO <= full_FIFO_signal;
	--problem pogledati dostupnost upisa u fifi bafer
	--wrEnable<= '1' when sekunde=10 and falling_edge; 
							  
	za_buraza: buraz port map(clk, enable_za_buraza, kompozicija_citanje, sound);
	
	za_fifi: fifi port map(clk, brisi_fifi, rdEnable ,wrEnable, kompozicija_signal, empty_FIFO_signal, full_FIFO_signal, kompozicija_citanje);
		
	za_sonica: sonic port map(clk, echo, trig, adresa_tona);
	za_br_unesenih_tipki: FourBit7seg port map(std_logic_vector(to_signed(i, 4)), br_unesenih_tipki);
	
	--dragi moji, za SVIRANJE trebamo aktivirati enable_za_buraza i mi njemu bukvalno saljemo ovo i ne interesuje nas koliko traje. 
	--ne moras svaku rijec zapisivati pogotovo sto se izrazavam zargonski. stefani 
	
	
	
	

end upravitelj_arch;