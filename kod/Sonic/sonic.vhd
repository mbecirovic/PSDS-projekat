library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sonic is
    port(clk: in std_logic;
          echo: in std_logic;
          trig: out std_logic;
			 adresa_tona: out std_logic_vector(1 downto 0)
          );
end sonic;

architecture sonic_arch of sonic is

    signal counter50: integer := 0;
    signal counter50_next: integer := 1;
    signal cifra0, cifra1, cifra2: integer := 0;
    signal duration_of_feedback: integer:=0;
    signal duration_of_feedback_next: integer:=0;
    signal distanca: integer:=0;
    signal distanca_next: integer:=0;
    signal enable: std_logic:='0';
    signal broj_tipke: std_logic_vector(1 downto 0);
	  
    begin
    
        counter50_next <= 0 when counter50 = 4000000 else --4M jer je to maksimalan interval slanja i primanja signala, mozda i 40 kHz
                                counter50 + 1;
        duration_of_feedback_next<=duration_of_feedback+1 when echo ='1' --and enable='1' 
                                            else 0;
        distanca_next<=duration_of_feedback/2900 when echo='1' --and enable='1' 
                            else distanca;
									 
        trig <= '1' when counter50<500 else '0';
        enable <= '1' when counter50 = 4000000 else '0';    
        
    process(clk)
    begin
    
        if(rising_edge(clk)) then
                counter50 <= counter50_next;
                duration_of_feedback<=duration_of_feedback_next;
                distanca<=distanca_next;
        end if;
        
        

    end process;
    
     --fazon je da su tipke rasporedjene na nacin: 
     -- dist manja od 10.9 cm -tipka 1
     -- dist manja od 20.9 cm - tipka 2 a veca od 10
     -- dist manja od 30.9 cm -tipka 3 a veca od 20
     -- dist manja od 40.9 cm -tipka 4 a veca od 30
    
    --cifra0 <= distanca mod 10;
    --cifra1 <= (distanca/10) mod 10;
    --cifra2 <= distanca/100;
    
     broj_tipke <= "00" when distanca < 10 else 
						 "01" when distanca < 20 and distanca >= 10 else
						 "10" when distanca < 30 and distanca >= 20 else
						 "11";
						 
		adresa_tona <= broj_tipke;
							
   -- cifra0 <= distanca mod 10;
   -- cifra1 <= distanca /10;
    
    --izlazHex0: FourBit7seg port map(std_logic_vector(to_signed(broj_tipke, 4)), Hex0(0), Hex0(1), Hex0(2), Hex0(3), Hex0(4), Hex0(5), Hex0(6));
   -- izlazHex1: FourBit7seg port map(std_logic_vector(to_signed(cifra0, 4)), Hex1(0), Hex1(1), Hex1(2), Hex1(3), Hex1(4), Hex1(5), Hex1(6));
   -- izlazHex2: FourBit7seg port map(std_logic_vector(to_signed(cifra1, 4)), Hex2(0), Hex2(1), Hex2(2), Hex2(3), Hex2(4), Hex2(5), Hex2(6));

        
end sonic_arch;