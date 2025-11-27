library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_matrix_8x8 is
    Port (
        clk     : in  STD_LOGIC;      -- Reloj del sistema (ej. 50 MHz)
        reset   : in  STD_LOGIC;      -- Reset activo alto
        rows    : out STD_LOGIC_VECTOR(0 to 7);  -- Salidas para filas (ánodo)
        j1,j2: in STD_LOGIC_VECTOR(0 to 8);
         gan,emp,comienzo: in std_logic;
        jactual: in std_logic;
             gana: in std_logic_vector(1 downto 0);  
        cols    : out STD_LOGIC_VECTOR(0 to 7)   -- Salidas para columnas (cátodo)
    );
end led_matrix_8x8;

architecture Behavioral of led_matrix_8x8 is
    signal refresh_counter : std_logic:='0';
    signal col_selector    : integer:= 0;
    signal row_pattern     : STD_LOGIC_VECTOR(7 downto 0);
    signal col_pattern     : STD_LOGIC_VECTOR(0 to 7);
   
    -- Constante para el divisor de frecuencia (ajustar según necesidad)
    signal REFRESH_DIVIDER : integer := 0; -- Para ~1 kHz de tasa de refresco

    
begin
    -- Proceso para el contador de refresco y selección de fila
   process(clk)
    begin
        if rising_edge(clk) then
            if REFRESH_DIVIDER= 13500 then
                REFRESH_DIVIDER <= 0;
               refresh_counter <= not refresh_counter;
            else
                REFRESH_DIVIDER <= REFRESH_DIVIDER + 1;
            end if;
        end if;
    end process;
    
     -- Multiplexor de displays
    process(refresh_counter)
    begin
        if rising_edge(refresh_counter) then
            col_selector <= (col_selector + 1) mod 8;
        end if;
    end process;

-- Selección del dígito actual
    process(col_selector)
    begin
    
        case col_selector is
            when 0 =>
                 col_pattern <= "10000000"; -- Columna 2 encendida (bit 1 en 0)  0-7
                if(comienzo='1')then
                    row_pattern<="00011110"; 
                elsif(gan='1') then
               
                row_pattern<="00000000"; 
                elsif(emp='1') then --0-7
               row_pattern<="00000000"; 
                else
                
                row_pattern<=j1(0)&j2(0)&'0'&j1(3)&j2(3)&'0'&j1(6)&j2(6);  --0-7
end if;
            when 1 =>
                 col_pattern <= "01000000"; -- Columna 2 encendida (bit 1 en 0)  0-7
                if(comienzo='1')then
                    row_pattern<="10101001"; 
                elsif(gan='1') then
                row_pattern<="01111110"; 
                elsif(emp='1') then --0-7
                row_pattern<="01111110"; 
                else
                row_pattern<="11011011";  --0-7
end if;
            when 2 =>
                 col_pattern <= "00100000"; -- Columna 2 encendida (bit 1 en 0)  0-7
                if(comienzo='1')then
                    row_pattern<="10010000"; 
                elsif(gan='1') then
                    row_pattern<="01111010";
                elsif(emp='1') then --0-7
                 row_pattern<="01011010"; 
                else
                row_pattern<="00000000";  --0-7
end if;
            when 3 =>
                 col_pattern <= "00010000"; -- Columna 2 encendida (bit 1 en 0)  0-7
                if(comienzo='1')then
                    row_pattern<="10101000"; 
                elsif(gan='1') then
                row_pattern<="01010010";
                elsif(emp='1') then --0-7
                row_pattern<="01011010";
                else
                row_pattern<=j1(1)&j2(1)&'0'&j1(4)&j2(4)&'0'&j1(7)&j2(7);  --0-7
end if;
            when 4 =>
                 col_pattern <= "00001000"; -- Columna 2 encendida (bit 1 en 0)  0-7
                if(comienzo='1')then
                    row_pattern<="00011000"; 
                elsif(gan='1') then
                     if(gana="01") then
                row_pattern<="01111110";
                    elsif (gana="10") then   
                row_pattern<="01111110";
                end if;
                elsif(emp='1') then --0-7
                row_pattern<="01011010";
                else
                row_pattern<="11011011";  --0-7
                end if;
            when 5 =>
                 col_pattern <= "00000100"; -- Columna 2 encendida (bit 1 en 0)  0-7
                if(comienzo='1')then
                    row_pattern<="11111100"; 
                elsif(gan='1') then
                     
                if(gana="01") then
                row_pattern<="01000010";
                    elsif (gana="10")   then 
                row_pattern<="01010010";
                end if;

                elsif(emp='1') then --0-7
                row_pattern<="01011010"; 
                else
                row_pattern<="00000000";  --0-7
end if;
            when 6 =>
                 col_pattern <= "00000010"; -- Columna 2 encendida (bit 1 en 0)  0-7
                    if(comienzo='1')then
                    row_pattern<="11111110"; 
                elsif(gan='1') then
                    
                     if(gana="01") then
                row_pattern<="01111110";
                    elsif(gana="10")  then  
                row_pattern<="01001010";
                end if;
          
                elsif(emp='1') then --0-7
                 row_pattern<="01111110"; 
                else
                row_pattern<=j1(2)&j2(2)&'0'&j1(5)&j2(5)&'0'&j1(8)&j2(8);  --0-7
end if;
            when 7 =>
                 col_pattern <= "00000001"; -- Columna 2 encendida (bit 1 en 0)  0-7
                if(comienzo='1')then
                    row_pattern<="11000001"; 
                elsif(gan='1') then
                row_pattern<="00000000";
                elsif(emp='1') then --0-7
                 row_pattern<="00000000";
                else
                row_pattern<="11011011";  --0-7
            end if;
            when others =>
               null;
        end case;
end process;
    
   
    -- Asignación de salidas
    rows <= row_pattern;
    cols <= col_pattern;
    
end Behavioral;