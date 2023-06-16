library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity upravitelj is 
	port(
		clk, rst: in std_logic; --sw 17
		opcija: in std_logic_vector(1 downto 0); --sw01
		--key_potvrdi: in std_logic; --key3
		trig: out std_logic; --gpio1[2]
		echo: in std_logic;	--gpio1[3]

		sound: out std_logic;	--gpio0[2]	
		Hex0: out std_logic_vector(6 downto 0); --br unesenih tipki
		adr_tona1: out std_logic; --udaljenost -> tipka1 -ledr1
		adr_tona0: out std_logic; --udaljenost -> tipka0 -ledr0
		kompozicija_upis_check: out std_logic_vector(9 downto 0);
		Hex4: out std_logic_vector(6 downto 0); --sekunde
		Hex5: out std_logic_vector(6 downto 0); --sekunde



		full_FIFO: out std_logic --ledg0
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
	signal kompozicija_upisivanje: std_logic_vector(9 downto 0);
	signal kompozicija_citanje: std_logic_vector(9 downto 0);
	
	signal brisi_fifi: std_logic;
	signal full_FIFO_signal: std_logic;
	signal empty_FIFO_signal: std_logic;
	signal rdEnable, wrEnable: std_logic;

	
	signal sekunde, sekunde_next: integer := 0;
	signal counter50, counter50_next: integer := 0;
	signal i, i_next: integer := 0;
	
	signal a_ton1, a_ton2, a_ton3, a_ton4, a_ton5: std_logic_vector(1 downto 0):="00";
	signal tonovi:std_logic_vector(9 downto 0);
	signal adresa_tona_semplirana: std_logic_vector(1 downto 0);
	signal sekunde_sviranje, sekunde_sviranje_next: integer := 0;
	signal cifra0, cifra1: integer := 0;



	
	
	begin
 
	process(clk, rst, opcija) is
		begin
		if rst = '1' then
			state <= NISTA;
			sekunde <= 0;
			i <= 0;
		elsif rising_edge(clk) then
			state <= state_next;
			counter50 <= counter50_next;
			sekunde <= sekunde_next;
			i <= i_next;
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
			
	sekunde_next <= sekunde + 1 when counter50 = 50_000_000 and sekunde < 11 and state = SNIMANJE and i <= 5 else
						 0	when counter50 = 50_000_000 and  state /= SNIMANJE else
						 sekunde;

						 
	i_next <= i + 1 when sekunde mod 2 = 0 and sekunde /= 0 and i <= 5 and counter50 = 50_000_000 and state = SNIMANJE else 
				 0 when state /= SNIMANJE and counter50 = 50_000_000 else
				 i;
				 				 
	a_ton1 <= (others => '0') when state = BRISANJE else adresa_tona when sekunde = 2;
	a_ton2 <= (others => '0') when state = BRISANJE else adresa_tona when sekunde = 4;
	a_ton3 <= (others => '0') when state = BRISANJE else adresa_tona when sekunde = 6;
	a_ton4 <= (others => '0') when state = BRISANJE else adresa_tona when sekunde = 8;
	a_ton5 <= (others => '0') when state = BRISANJE else adresa_tona when sekunde = 10;
	 
	kompozicija_upisivanje <= a_ton1 & a_ton2 & a_ton3 & a_ton4 & a_ton5;
	
	full_FIFO <= full_FIFO_signal;
	--problem pogledati dostupnost upisa u fifi bafer
	
	rdEnable <= '1' when state = SVIRANJE else '0';
	wrEnable <= '1' when state = SNIMANJE and sekunde = 10 else '0'; 
	
	za_sonica: sonic port map(clk, echo, trig, adresa_tona);
	--za_fifi: fifi port map(clk, brisi_fifi, rdEnable ,wrEnable, kompozicija_upisivanje, empty_FIFO_signal, full_FIFO_signal, kompozicija_citanje);			  
	--za_buraza: buraz port map(clk, enable_za_buraza, kompozicija_citanje, sound);
	za_buraza: buraz port map(clk, enable_za_buraza, kompozicija_upisivanje, sound);

	
	adresa_tona_semplirana <= adresa_tona when counter50 = 50_000_000;
	adr_tona1 <= adresa_tona_semplirana(1);
	adr_tona0 <= adresa_tona_semplirana(0);
	kompozicija_upis_check <= kompozicija_upisivanje;
	cifra0 <= sekunde mod 10;
	cifra1 <= sekunde/10;


	za_Hex0: FourBit7seg port map(std_logic_vector(to_signed(i, 4)), Hex0);
	za_Hex4: FourBit7seg port map(std_logic_vector(to_signed(cifra0, 4)), Hex4);
	za_Hex5: FourBit7seg port map(std_logic_vector(to_signed(cifra1, 4)), Hex5);


	
	
	
	
	
	

end upravitelj_arch;