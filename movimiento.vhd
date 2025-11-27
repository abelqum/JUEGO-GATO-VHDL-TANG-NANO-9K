library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity movimiento is
    Port (
        clk    : in  std_logic;
        reset  : in  std_logic;
       mov  : in  std_logic;
        enter: in std_logic;
        comienzo: in std_logic;
j1l,j2l,sj1,sj2: out STD_LOGIC_VECTOR(0 to 8);
gan,emp: out std_logic;
gana: out std_logic_vector(1 downto 0);
state: out std_logic_vector(0 to 8);
       jActual: in Std_logic
        
        
    );
end entity;

architecture Behavioral of movimiento is
    type movs is (S1, S2, S3, S4, S5, S6, S7, S8, S9);
    signal presente,siguiente : movs:= S1;
    signal disponible: std_logic_vector(0 to 8):=(others => '1');
    
signal j1: std_logic_vector(0 to 8):= (others => '1');
signal j2: std_logic_vector(0 to 8):= (others => '1');
signal nactual: std_logic_vector(0 to 8):=(others => '1');
signal estados: std_logic_vector(0 to 8):=(others => '0');
signal     win_detected: std_logic:= '0'; 
 signal REFRESH_DIVIDER : natural := 0; -- 
signal clk_lento: std_logic:='0';
signal juego_activo: std_logic := '1';

function sigCasilla(
    i: integer range 0 to 8; 
    k: integer range 1 to 9;
    disponible: std_logic_vector(0 to 8)
) return movs is
    variable next_pos: integer;
begin
    -- Lógica para determinar la siguiente posición disponible
    if disponible((i+1) mod 9) = '0' then
        if disponible((i+2) mod 9) = '0' then
            if disponible((i+3) mod 9) = '0' then
                if disponible((i+4) mod 9) = '0' then
                    if disponible((i+5) mod 9) = '0' then
                        if disponible((i+6) mod 9) = '0' then
                            if disponible((i+7) mod 9) = '0' then
                                if disponible((i+8) mod 9) = '0' then 
                                    next_pos := k;
                                else
                                    next_pos := (k + 7) mod 9 + 1;  -- Ajuste para k+8
                                end if;
                            else 
                                next_pos := (k + 6) mod 9 + 1;  -- Ajuste para k+7
                            end if;
                        else 
                            next_pos := (k + 5) mod 9 + 1;  -- Ajuste para k+6
                        end if;
                    else
                        next_pos := (k + 4) mod 9 + 1;  -- Ajuste para k+5
                    end if;
                else
                    next_pos := (k + 3) mod 9 + 1;  -- Ajuste para k+4
                end if;
            else
                next_pos := (k + 2) mod 9 + 1;  -- Ajuste para k+3
            end if;
        else
            next_pos := (k + 1) mod 9 + 1;  -- Ajuste para k+2
        end if;
    else
        next_pos := k mod 9 + 1;  -- Ajuste para k+1
    end if;

    -- Retornar el valor movs correspondiente
    case next_pos is
        when 1 => return S1;
        when 2 => return S2;
        when 3 => return S3;
        when 4 => return S4;
        when 5 => return S5;
        when 6 => return S6;
        when 7 => return S7;
        when 8 => return S8;
        when 9 => return S9;
        when others => return S1;  -- Nunca debería llegar aquí
    end case;
end function;



begin
   

process(clk)
   begin
        if rising_edge(clk) then
           if REFRESH_DIVIDER=675000 then
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
  presente<=S1;
 

 elsif rising_edge(clk_lento) then
presente<=siguiente;
end if;
end process;


--estados
process(presente,reset,mov,jActual)
begin
if reset = '0' then

siguiente<=S1;
disponible<=(others => '1');
j1<=(others => '1');
j2<=(others => '1');

else




if(comienzo='1') then
siguiente<=S1;
else
case presente is



when S1 => --PRIMER ESTADO


if jActual='0' then
estados<='0'&j1(1 to 8);
else
estados<='0'&j2(1 to 8);
end if;
    case mov is

    when '0'=>
         siguiente<=sigCasilla(0,1,disponible);
    when others =>


       if(enter='0') then 


              siguiente<=sigCasilla(0,1,disponible);


            if(jActual='0') then
                j1(0)<='0';
            else
                j2(0)<='0';
            end if;
         disponible(0)<='0';
          

        end if;
    end case;
  

when S2 => --SEGUNDO ESTADO



if jActual='0' then
estados<=j1(0)&'0'&j1(2 to 8);
else
estados<=j2(0)&'0'&j2(2 to 8);
end if;

    case mov is

    when '0'=>
    siguiente<=sigCasilla(1,2,disponible);
    when others =>

       if(enter='0') then 
              siguiente<=sigCasilla(1,2,disponible);
            if(jActual='0') then
                j1(1)<='0';
            else
                j2(1)<='0';
            end if;
         disponible(1)<='0';
          

        end if;
    end case;
 


when S3 => --TERCER ESTADO


if jActual='0' then
estados<=j1(0 to 1)&'0'&j1(3 to 8);
else
estados<=j2(0 to 1)&'0'&j2(3 to 8);
end if;


 
    case mov is

    when '0'=>
     siguiente<=sigCasilla(2,3,disponible);
    when others =>

       if(enter='0') then 
              siguiente<=sigCasilla(2,3,disponible);
            if(jActual='0') then
                j1(2)<='0';
            else
                j2(2)<='0';
            end if;
         disponible(2)<='0';
          
          
    
        end if;
    end case;
 



when S4 => --CUARTO ESTADO

if jActual='0' then
estados<=j1(0 to 2)&'0'&j1(4 to 8);
else
estados<=j2(0 to 2)&'0'&j2(4 to 8);
end if;


   case mov is

    when '0'=>
     siguiente<=sigCasilla(3,4,disponible);
    when others =>

       if(enter='0') then 
             siguiente<=sigCasilla(3,4,disponible);
            if(jActual='0') then
                j1(3)<='0';
            else
                j2(3)<='0';
            end if;
         disponible(3)<='0';
          

        end if;
    end case;



when S5 => -- QUINTO ESTADO

if jActual='0' then
estados<=j1(0 to 3)&'0'&j1(5 to 8);
else
estados<=j2(0 to 3)&'0'&j2(5 to 8);
end if;

    case mov is

    when '0'=>
     siguiente<=sigCasilla(4,5,disponible);
    when others =>

       if(enter='0') then 
             siguiente<=sigCasilla(4,5,disponible);
            if(jActual='0') then
                j1(4)<='0';
            else
                j2(4)<='0';
            end if;
         disponible(4)<='0';
          

        end if;
    end case;
 


when S6 => -- SEXTO ESTADO

if jActual='0' then
estados<=j1(0 to 4)&'0'&j1(6 to 8);
else
estados<=j2(0 to 4)&'0'&j2(6 to 8);
end if;


   case mov is

    when '0'=>
    siguiente<=sigCasilla(5,6,disponible);
    when others =>

       if(enter='0') then 
             siguiente<=sigCasilla(5,6,disponible);
            if(jActual='0') then
                j1(5)<='0';
            else
                j2(5)<='0';
            end if;
         disponible(5)<='0';
          

        end if;
    end case;


when S7 => -- SÉPTIMO ESTADO


if jActual='0' then
estados<=j1(0 to 5)&'0'&j1(7 to 8);
else
estados<=j2(0 to 5)&'0'&j2(7 to 8);
end if;

 
    case mov is

    when '0'=>
    siguiente<=sigCasilla(6,7,disponible);
    when others =>

       if(enter='0') then 
             siguiente<=sigCasilla(6,7,disponible);
            if(jActual='0') then
                j1(6)<='0';
            else
                j2(6)<='0';
            end if;
         disponible(6)<='0';
          

        end if;
    end case;
  



when S8 => -- OCTAVO ESTADO

if jActual='0' then
estados<=j1(0 to 6)&'0'&j1(8);
else
estados<=j2(0 to 6)&'0'&j2(8);
end if;


   case mov is

    when '0'=>
     siguiente<=sigCasilla(7,8,disponible);
    when others =>

       if(enter='0') then 
 siguiente<=sigCasilla(7,8,disponible);
            if(jActual='0') then
                j1(7)<='0';
            else
                j2(7)<='0';
            end if;
         disponible(7)<='0';
          

        end if;
    end case;



when S9 => -- NOVENO ESTADO


if jActual='0' then
estados<=j1(0 to 7)&'0';
else
estados<=j2(0 to 7)&'0';
end if;



   case mov is

    when '0'=>
     siguiente<=sigCasilla(8,9,disponible);
    when others =>

       if(enter='0') then 
             siguiente<=sigCasilla(8,9,disponible);

            if(jActual='0') then
                j1(8)<='0';
            else
                j2(8)<='0';
            end if;
         disponible(8)<='0';
        
           

        end if;
    end case;
  




    when others=>
        siguiente<=presente;
       
    end case;
   end if;

end if;

 
end process;


j1l<= estados when jActual='0' else j1;
j2l<= estados when jActual='1' else j2;
state<=estados;



process(j1,j2,clk)
    begin
    if reset='0' then
    emp<='0';

    elsif rising_edge(clk) then
         if(disponible="000000000") then    
            emp<='1';
        else
            emp<='0';
        end if;
    end if;
end process;

process(nactual, clk_lento)
begin
if reset='0' then
    gan<='0';
    gana<="00";
juego_activo <= '1';
    win_detected<='0';
    elsif rising_edge(clk) then

     if juego_activo = '1' then
        -- Lógica de movimiento   DETECTA AL GANADOR EN TURNO
        if jActual = '0' then
            nactual <= j1;
        else 
            nactual <= j2;
        end if;
    
        -- Filas
        if std_logic_vector'(nactual(0) & nactual(1) & nactual(2)) = "000" then
            win_detected <= '1';
             
        if jActual = '0' then
            gana <= "01";
        elsif jActual='1' then 
            gana <= "10";
        end if;
juego_activo <= '0';  -- Bloquear juego
        elsif std_logic_vector'(nactual(3) & nactual(4) & nactual(5)) = "000" then
            win_detected <= '1';
         if jActual = '0' then
            gana <= "01";
        elsif jActual='1' then 
            gana <= "10";
        end if;
juego_activo <= '0';  -- Bloquear juego
        elsif std_logic_vector'(nactual(6) & nactual(7) & nactual(8)) = "000" then
            win_detected <= '1';
            if jActual = '0' then
            gana <= "01";
        elsif jActual='1' then 
            gana <= "10";
        end if;
        -- Columnas
juego_activo <= '0';  -- Bloquear juego
        elsif std_logic_vector'(nactual(0) & nactual(3) & nactual(6)) = "000" then
            win_detected <= '1';
             if jActual = '0' then
            gana <= "01";
        elsif jActual='1' then 
            gana <= "10";
        end if;
juego_activo <= '0';  -- Bloquear juego
        elsif std_logic_vector'(nactual(1) & nactual(4) & nactual(7)) = "000" then
            win_detected <= '1';
              if jActual = '0' then
            gana <= "01";
        elsif jActual='1' then 
            gana <= "10";
        end if;
juego_activo <= '0';  -- Bloquear juego
        elsif std_logic_vector'(nactual(2) & nactual(5) & nactual(8)) = "000" then
            win_detected <= '1';
         if jActual = '0' then
            gana <= "01";
        elsif jActual='1' then 
            gana <= "10";
        end if;
        -- Diagonales
juego_activo <= '0';  -- Bloquear juego
        elsif std_logic_vector'(nactual(0) & nactual(4) & nactual(8)) = "000" then
            win_detected <= '1';
             if jActual = '0' then
            gana <= "01";
        elsif jActual='1' then 
            gana <= "10";
        end if;
juego_activo <= '0';  -- Bloquear juego
        elsif std_logic_vector'(nactual(6) & nactual(4) & nactual(2)) = "000" then
            win_detected <= '1';
              if jActual = '0' then
            gana <= "01";
        elsif jActual='1' then 
            gana <= "10";
        end if;
juego_activo <= '0';  -- Bloquear juego
        else
juego_activo <= '1';  -- Bloquear juego
            win_detected <= '0';
            gana<="00";
        end if;
    end if;
        
        gan <= win_detected;
    end if;
end process;


--salida de los leds en proto
sj1<=disponible;
sj2<=estados;

end architecture;