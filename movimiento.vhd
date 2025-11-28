library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity movimiento is
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        mov      : in  std_logic; -- Pulso de 1 ciclo
        enter    : in  std_logic; -- Pulso de 1 ciclo
        comienzo : in  std_logic;
        jActual  : in  std_logic;
        j1l, j2l : out std_logic_vector(0 to 8);
        sj1, sj2 : out std_logic_vector(0 to 8);
        gan, emp : out std_logic;
        gana     : out std_logic_vector(1 downto 0);
        state    : out std_logic_vector(0 to 8)
    );
end entity;

architecture Behavioral of movimiento is
    type movs is (S1, S2, S3, S4, S5, S6, S7, S8, S9);
    signal presente, siguiente : movs := S1;
    
    -- '1' = Disponible, '0' = Ocupado
    signal disponible : std_logic_vector(0 to 8) := (others => '1');
    signal j1 : std_logic_vector(0 to 8) := (others => '1');
    signal j2 : std_logic_vector(0 to 8) := (others => '1');
    
    signal estados : std_logic_vector(0 to 8) := (others => '1');
    signal juego_activo : std_logic := '1';
    signal win_detected : std_logic := '0';

    -- Función para saltar a la siguiente casilla libre
    function sigCasilla(
        curr_state_idx: integer; 
        disp_vec: std_logic_vector(0 to 8)
    ) return movs is
        variable check_idx : integer;
    begin
        for i in 1 to 9 loop
            check_idx := (curr_state_idx + i) mod 9;
            if disp_vec(check_idx) = '1' then
                case check_idx is
                    when 0 => return S1; when 1 => return S2; when 2 => return S3;
                    when 3 => return S4; when 4 => return S5; when 5 => return S6;
                    when 6 => return S7; when 7 => return S8; when 8 => return S9;
                    when others => return S1;
                end case;
            end if;
        end loop;
        -- Si no hay casillas, retorna la actual
        case curr_state_idx is
             when 0 => return S1; when 1 => return S2; when 2 => return S3;
             when 3 => return S4; when 4 => return S5; when 5 => return S6;
             when 6 => return S7; when 7 => return S8; when 8 => return S9;
             when others => return S1;
        end case;
    end function;

    function stateToIdx(s: movs) return integer is
    begin
        case s is
            when S1 => return 0; when S2 => return 1; when S3 => return 2;
            when S4 => return 3; when S5 => return 4; when S6 => return 5;
            when S7 => return 6; when S8 => return 7; when S9 => return 8;
            when others => return 0;
        end case;
    end function;

    -- Función pura para verificar victoria en un vector dado
    function check_victory(board: std_logic_vector(0 to 8)) return boolean is
    begin
        if (board(0)='0' and board(1)='0' and board(2)='0') or -- Fila 1
           (board(3)='0' and board(4)='0' and board(5)='0') or -- Fila 2
           (board(6)='0' and board(7)='0' and board(8)='0') or -- Fila 3
           (board(0)='0' and board(3)='0' and board(6)='0') or -- Col 1
           (board(1)='0' and board(4)='0' and board(7)='0') or -- Col 2
           (board(2)='0' and board(5)='0' and board(8)='0') or -- Col 3
           (board(0)='0' and board(4)='0' and board(8)='0') or -- Diag 1
           (board(6)='0' and board(4)='0' and board(2)='0') then -- Diag 2
           return true;
        else
           return false;
        end if;
    end function;

begin

    -- PROCESO PRINCIPAL
    process(clk, reset)
        variable v_j1, v_j2 : std_logic_vector(0 to 8);
        variable v_disp : std_logic_vector(0 to 8);
        variable idx : integer;
        variable w1, w2 : boolean;
    begin
        if reset = '0' then
            presente <= S1;
            disponible <= (others => '1');
            j1 <= (others => '1');
            j2 <= (others => '1');
            gan <= '0';
            gana <= "00";
            emp <= '0';
            juego_activo <= '1';
            win_detected <= '0';
            
        elsif rising_edge(clk) then
            -- Cargamos valores actuales en variables para modificar y leer al instante
            v_j1 := j1;
            v_j2 := j2;
            v_disp := disponible;
            
            -- Actualización de estado normal
            presente <= siguiente;

            if juego_activo = '1' then
                
                -- Lógica de ENTER (Marcar y Saltar)
                if enter = '0' then
                    idx := stateToIdx(presente);
                    
                    if v_disp(idx) = '1' then
                        -- 1. Actualizar variables (tablero)
                        v_disp(idx) := '0';
                        if jActual = '0' then
                            v_j1(idx) := '0';
                        else
                            v_j2(idx) := '0';
                        end if;
                        
                        -- 2. Salto automático a la siguiente libre
                        -- Usamos v_disp actualizado para que no salte a la que acabamos de marcar
                        presente <= sigCasilla(idx, v_disp);
                    end if;
                end if;

                -- Lógica de EMPATE (Si no hay espacios y nadie ha ganado aun)
                if v_disp = "000000000" and win_detected = '0' then
                    emp <= '1'; -- Se sobrescribirá abajo si alguien gana en el último turno
                    juego_activo <= '0';
                else
                    emp <= '0';
                end if;

                -- Lógica de GANADOR (Revisamos AMBOS tableros modificados)
                w1 := check_victory(v_j1);
                w2 := check_victory(v_j2);
                
                if w1 or w2 then
                    win_detected <= '1';
                    gan <= '1';
                    juego_activo <= '0';
                    emp <= '0'; -- Prioridad a la victoria sobre el empate
                    if w1 then gana <= "01"; else gana <= "10"; end if;
                end if;

            end if; -- Fin juego_activo

            -- Reinicio
            if comienzo = '1' then
                v_disp := (others => '1');
                v_j1 := (others => '1');
                v_j2 := (others => '1');
                gan <= '0';
                gana <= "00";
                emp <= '0';
                juego_activo <= '1';
                win_detected <= '0';
                presente <= S1;
            end if;

            -- Asignar variables a señales finales
            j1 <= v_j1;
            j2 <= v_j2;
            disponible <= v_disp;

        end if;
    end process;

    -- LÓGICA DE MOVIMIENTO MANUAL
    process(presente, mov, disponible, comienzo)
        variable current_idx : integer;
    begin
        siguiente <= presente; 
        current_idx := stateToIdx(presente);

        if comienzo = '1' then
            siguiente <= S1;
        elsif mov = '0' then 
            siguiente <= sigCasilla(current_idx, disponible);
        end if;
    end process;

    -- VISUALIZACIÓN
    process(presente, jActual, j1, j2)
        variable temp_view : std_logic_vector(0 to 8);
        variable idx : integer;
    begin
        if jActual = '0' then temp_view := j1; else temp_view := j2; end if;
        idx := stateToIdx(presente);
        temp_view(idx) := '0'; -- Cursor
        estados <= temp_view;
    end process;

    j1l <= estados when jActual = '0' else j1;
    j2l <= estados when jActual = '1' else j2;
    state <= estados;
    sj1 <= disponible;
    sj2 <= estados;

end Behavioral;
