library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity turnos is
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        enter    : in  std_logic; -- Pulso de 1 ciclo (activo bajo)
        win      : in  std_logic;
        empat    : in  std_logic;
        jActual  : out std_logic;
        comienzo : out std_logic
    );
end entity;

architecture Behavioral of turnos is
    type t_estado is (INICIO, PLAYER1, PLAYER2, WINNER, EMPATE);
    signal presente, siguiente : t_estado := INICIO;
begin

    -- Proceso Secuencial (Reloj de sistema 27 MHz)
    process(clk, reset)
    begin
        if reset = '0' then
            presente <= INICIO;
        elsif rising_edge(clk) then
            presente <= siguiente;
        end if;
    end process;

    -- Lógica Combinacional de Estados
    process(presente, enter, win, empat)
    begin
        -- Valores por defecto para evitar latches
        siguiente <= presente;
        comienzo <= '0';
        jActual <= '0'; -- Por defecto J1 (0)

        case presente is
            when INICIO =>
                comienzo <= '1'; -- Muestra la animación de inicio
                if enter = '0' then
                    siguiente <= PLAYER1;
                end if;

            when PLAYER1 =>
                jActual <= '0';
                if win = '1' then
                    siguiente <= WINNER;
                elsif empat = '1' then
                    siguiente <= EMPATE;
                elsif enter = '0' then
                    siguiente <= PLAYER2; -- Cambio de turno
                end if;

            when PLAYER2 =>
                jActual <= '1';
                if win = '1' then
                    siguiente <= WINNER;
                elsif empat = '1' then
                    siguiente <= EMPATE;
                elsif enter = '0' then
                    siguiente <= PLAYER1; -- Cambio de turno
                end if;

            when WINNER =>
                -- Se queda aquí hasta que se presione Reset (handled by async reset arriba)
                null;

            when EMPATE =>
                -- Se queda aquí hasta que se presione Reset
                null;
                
            when others =>
                siguiente <= INICIO;
        end case;
    end process;

end Behavioral;
