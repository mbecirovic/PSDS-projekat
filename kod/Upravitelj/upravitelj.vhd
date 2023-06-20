library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity upravitelj is 
	port(
		clk, rst: in std_logic; --sw 17
		opcija: in std_logic_vector(1 downto 0); --sw01
		trig: out std_logic; --gpio1[2]
		echo: in std_logic;	--gpio1[3]
		adresniVektorKompozicije : in std_logic_vector(1 downto 0);

		sound: out std_logic;	--gpio0[2]	
		Hex0: out std_logic_vector(6 downto 0); --br unesenih tipki
		adr_tona_ispis: out std_logic_vector(1 downto 0); --udaljenost ->  -ledr1 i ledr0
		kompozicija_upis_check: out std_logic_vector(9 downto 0);
		Hex4: out std_logic_vector(6 downto 0) --odabir reda za upis i citanje
	);
end upravitelj;


architecture upravitelj_arch of upravitelj is
	
	component sonic is
    port(clk: in std_logic;
          echo: in std_logic;
          trig: out std_logic;
			 adresa_tona: out std_logic_vector(1 downto 0)
          );
end component;
	
	component RAM is
	port(
		rst: in std_logic;
		
		we_i: in std_logic;
		waddr_i: in std_logic_vector(1 downto 0);
		wdata_i: in std_logic_vector(9 downto 0);
		
		re_i: in std_logic;
		raddr_i: in std_logic_vector(1 downto 0);
		rdata_o: out std_logic_vector(9 downto 0)
		
	);
end component;
  
  component player is
	port(clk: in std_logic;
		  enable: in std_logic;
		  composition: in std_logic_vector(9 downto 0);
		  sound: out std_logic
	);
	end component;
	
	component seg27 is
    port(
        i: in unsigned(3 downto 0);
        o : out std_logic_vector(6 downto 0)
    );
end component;
	
	type state_type is (NISTA, SNIMANJE, SVIRANJE, BRISANJE);
	signal state, state_next: state_type;
	
	signal adresa_tona: std_logic_vector(1 downto 0);
	signal trig_signal: std_logic;
	
	signal kompozicija_upisivanje: std_logic_vector(9 downto 0);
	
	signal brisi_RAM: std_logic;

	
	signal sekunde, sekunde_next: integer := 0;
	signal counter50, counter50_next: integer := 0;
	signal i, i_next: integer := 0;
	
	signal a_ton1, a_ton2, a_ton3, a_ton4, a_ton5: std_logic_vector(1 downto 0):="00";

	signal we_i : std_logic;
	signal waddr_i : std_logic_vector(1 downto 0);
	signal wdata_i : std_logic_vector(9 downto 0);
	
	signal re_i : std_logic;
	signal raddr_i : std_logic_vector(1 downto 0);
	signal rdata_o : std_logic_vector(9 downto 0);
	
	
	
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
						
	--SVIRANJE	
	
	re_i <= '1' when state = SVIRANJE else '0';

	counter50_next <= 0 when counter50 = 50_000_000 else
							counter50 + 1;
	
	
	za_playera: player port map(clk, re_i, rdata_o , sound);
	
	--BRISANJE 
	
	brisi_RAM <= '1' when state = BRISANJE else '0';
	
	--SNIMANJE
			
	sekunde_next <= sekunde + 1 when counter50 = 50_000_000 and sekunde < 11 and state = SNIMANJE and i <= 5 else
						 0	when counter50 = 50_000_000 and  state /= SNIMANJE else
						 sekunde;

						 
	i_next <= i + 1 when sekunde mod 2 = 0 and sekunde /= 0 and i <= 5 and counter50 = 50_000_000 and state = SNIMANJE else 
				 0 when state /= SNIMANJE and counter50 = 50_000_000 else
				 i;
				 				 
	--a_ton1 <= (others => '0') when state = BRISANJE else adresa_tona when sekunde = 2;
	--a_ton2 <= (others => '0') when state = BRISANJE else adresa_tona when sekunde = 4;
	--a_ton3 <= (others => '0') when state = BRISANJE else adresa_tona when sekunde = 6;
	--a_ton4 <= (others => '0') when state = BRISANJE else adresa_tona when sekunde = 8;
	--a_ton5 <= (others => '0') when state = BRISANJE else adresa_tona when sekunde = 10;
	
	a_ton1 <= (others => '0') when state /= SNIMANJE else adresa_tona when sekunde = 2;
	a_ton2 <= (others => '0') when state /= SNIMANJE else adresa_tona when sekunde = 4;
	a_ton3 <= (others => '0') when state /= SNIMANJE else adresa_tona when sekunde = 6;
	a_ton4 <= (others => '0') when state /= SNIMANJE else adresa_tona when sekunde = 8;
	a_ton5 <= (others => '0') when state /= SNIMANJE else adresa_tona when sekunde = 10;
	
	

	 
	kompozicija_upisivanje <= a_ton1 & a_ton2 & a_ton3 & a_ton4 & a_ton5 when state = SNIMANJE else "0000000000";
	
	
	za_sonica: sonic port map(clk, echo, trig, adresa_tona);

	
	adr_tona_ispis <= a_ton1 when sekunde = 2 else
							a_ton2 when sekunde = 4 else
							a_ton3 when sekunde = 6 else
							a_ton4 when sekunde = 8 else
							a_ton5 when sekunde = 10 else "00";
							
	kompozicija_upis_check <= kompozicija_upisivanje;
	

	za_Hex0: seg27 port map(to_unsigned(i, 4), Hex0);
	za_Hex4: seg27 port map(unsigned("00" & adresniVektorKompozicije), Hex4);
	
	za_RAM : RAM port map(brisi_RAM, we_i, waddr_i, wdata_i, re_i, raddr_i, rdata_o);
	

	


	
	we_i <= '1' when sekunde = 10 and state = SNIMANJE else '0';
	waddr_i <= adresniVektorKompozicije;
	raddr_i <= adresniVektorKompozicije;

	wdata_i <= kompozicija_upisivanje;
	
end upravitelj_arch;