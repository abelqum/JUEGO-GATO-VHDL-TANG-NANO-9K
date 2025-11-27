library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity turnos is
    Port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        enter  : in  std_logic;
        win : in  std_logic;
        jActual,comienzo: out Std_logic;
        
        empat: in std_logic
        
    );
end entity;

architecture Behavioral of turnos is
    type turnos is (INICIO,PLAYER1, PLAYER2, WINNER, EMPATE);
    signal presente: turnos:=INICIO;
    signal siguiente : turnos:= INICIO;
    signal flage,flagg, jac : std_logic:='0';
 signal REFRESH_DIVIDER : integer := 0; -- 

signal clk_lento: std_logic:='0';
begin
   




process(clk)
   begin
        if rising_edge(clk) then
           if REFRESH_DIVIDER= 675000 then
                REFRESH_DIVIDER <= 0;
               clk_lento <= not clk_lento;
            else
                REFRESH_DIVIDER <= REFRESH_DIVIDER + 1;
            end if;
       end if;
    end process; 

   
   process(clk_lento,reset)
begin
 if reset = '0' then
  presente<=INICIO;
  
 elsif rising_edge(clk_lento) then
presente<=siguiente;
end if;
end process;


--estados
process(presente,reset,enter,win,empat)
begin

if reset='0' then
siguiente<= INICIO;

else



    case presente is


when INICIO => --INICIO DEL JUEGO 

comienzo<='1';
if(enter='0') then
    siguiente<=PLAYER1;
end if;
    


  when PLAYER1 => --JUGADOR 1
comienzo<='0';
    jac<='0';
    if win='1' then 
        siguiente<= WINNER;

    elsif empat='1' then
        siguiente<= EMPATE;

    else
        
      case enter is
        
        when '0'=>
       
            siguiente<= PLAYER2;
            
        when others=>
            flage<='0';
            flagg<='0';
            jac<='0';
 
        end case;
      end if;


 when PLAYER2 => -- JUGADOR 2
jac<='1';
comienzo<='0';
    if win='1' then 
        siguiente<= WINNER;
   
    elsif empat='1' then
        siguiente<= EMPATE;

    else
        
      case enter is
        
        when '0'=>
            siguiente<= PLAYER1;
        
        when others=>
            flage<='0';
            flagg<='0';
            
 
        end case;
      end if;



    when EMPATE =>
siguiente<=EMPATE;
        flage<='1';
        flagg<='0';
comienzo<='0';
     
    when WINNER =>
siguiente<=WINNER;
        flage<='0';
        flagg<='1';
     comienzo<='0';
    when others=> 
        null;
       end case;
   end if;
end process;


jActual<=jac;


end architecture;