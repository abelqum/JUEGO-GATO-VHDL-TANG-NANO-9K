library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_module is
    Port (
        clk      : in  std_logic;          -- Reloj del sistema
        reset    : in  std_logic;          -- Reset (activo bajo)
        mov      : in  std_logic;          -- Señal de movimiento
        enter    : in  std_logic;          -- Confirmación de jugada
        rows     : out std_logic_vector(0 to 7);  -- Filas de la matriz LED
        cols     : out std_logic_vector(0 to 7);   -- Columnas de la matriz LED  
        --señales 
        ganador,empat,casilla,turno,movi,ini: out std_logic;
             sjugador,sjugador1: out std_logic_vector(0 to 8);
        estados: out std_logic_vector(0 to 8)
    );
end top_module;

architecture Behavioral of top_module is
    -- Señales internas para interconexión
    signal j1M, j2M, sjug,sjug1         : std_logic_vector(0 to 8):=(others=>'1');
    signal stadosM: std_logic_vector(0 to 8):=(others=>'0');
    signal ganM, empM,comiM         : std_logic:='0';
    signal jActualM          : std_logic:='0';  -- Jugador actual (0: J1, 1: J2)
   signal ganaM: std_logic_vector(1 downto 0):="00";
     -- Anti-rebote
    signal res_db,mov_db, enter_db: STD_LOGIC := '0';
    signal debounce_counter : integer := 0;
    
    -- Declaración de componentes
    component turnos
        Port (
            clk       : in  std_logic;
            reset     : in  std_logic;
            enter     : in  std_logic;
            win       : in  std_logic;
            jActual   : out std_logic; 
            comienzo  : out std_logic;
            empat     : in  std_logic
        );
    end component;

    component movimiento
        Port (
            clk            : in  std_logic;
            reset          : in  std_logic;
            mov            : in  std_logic;
            enter          : in std_logic;
            comienzo        : in std_logic;
            j1l            : out std_logic_vector(0 to 8);
            j2l            : out std_logic_vector(0 to 8);
            sj1             : out std_logic_vector(0 to 8);
            sj2             : out std_logic_vector(0 to 8);
            gan            : out std_logic;
            emp            : out std_logic;
            gana            : out std_logic_vector(1 downto 0);
            state       : out std_logic_vector(0 to 8);
            jActual        : in  std_logic
            
        );
    end component;

    component led_matrix_8x8
        Port (
            clk     : in  std_logic;
            reset   : in  std_logic;
            rows    : out std_logic_vector(0 to 7);
            cols    : out std_logic_vector(0 to 7);
            j1      : in  std_logic_vector(0 to 8);
            j2      : in  std_logic_vector(0 to 8);
            gan     : in  std_logic;
            comienzo: in std_logic;
            emp     : in  std_logic;
            gana: in std_logic_vector(1 downto 0);  
            jactual : in  std_logic
        );
    end component;

begin
    -- Instancia del módulo de turnos (controla jugadores)
    inst_turnos: turnos
    port map (
        clk       => clk,
        reset     => res_db,
        enter     => enter_db,
        win       => ganM,
        jActual   => jActualM,
        comienzo  => comiM,
        empat     => empM
    );

    -- Instancia del módulo de movimiento (selección de casillas)
    inst_movimiento: movimiento
    port map (
        clk            => clk,
        reset          => res_db,
        mov            => mov_db,
        enter          => enter_db,
        j1l            => j1M,
        j2l            => j2M,
        sj1            => sjug,
        sj2            => sjug1,
        gan            => ganM,
        emp            => empM,
        comienzo       => comiM,
        gana           => ganaM,
        state        => stadosM,
        jActual        => jActualM
      
    );

    -- Instancia del controlador de la matriz LED (visualización)
    inst_led_matrix: led_matrix_8x8
    port map (
        clk     => clk,
        reset   => res_db,
        rows    => rows,
        cols    => cols,
        j1      => j1M,
        j2      => j2M,
        gan     => ganM,
        gana    => ganaM,
        comienzo=> comiM,
        emp     => empM,
        jactual => jActualM
    );


 -- Reemplaza el process(clk) existente en topModule.vhd con este:
process(clk)
    -- Variables para sincronización
    variable mov_sync1, mov_sync2 : std_logic := '1';
    variable enter_sync1, enter_sync2 : std_logic := '1';
    variable reset_sync1, reset_sync2 : std_logic := '1';
    
    -- Variables para el estado estable (salida del debounce)
    variable mov_stable : std_logic := '1';
    variable enter_stable : std_logic := '1';
    
    -- Variables para detectar el flanco (valor anterior)
    variable mov_last : std_logic := '1';
    variable enter_last : std_logic := '1';
    
    -- Contadores independientes para cada botón (aprox 15ms a 27MHz)
    -- 27,000,000 * 0.015 = 405,000
    variable count_mov : integer range 0 to 500000 := 0;
    variable count_enter : integer range 0 to 500000 := 0;

begin
    if rising_edge(clk) then
        -- 1. Sincronización (evitar metaestabilidad)
        mov_sync2 := mov_sync1;     mov_sync1 := mov;
        enter_sync2 := enter_sync1; enter_sync1 := enter;
        reset_sync2 := reset_sync1; reset_sync1 := reset;
        res_db <= reset_sync2;

        -- 2. Antirrebotes para MOV
        if mov_sync2 /= mov_stable then
            if count_mov < 405000 then
                count_mov := count_mov + 1;
            else
                mov_stable := mov_sync2; -- Actualizar estado estable
                count_mov := 0;
            end if;
        else
            count_mov := 0;
        end if;

        -- 3. Antirrebotes para ENTER
        if enter_sync2 /= enter_stable then
            if count_enter < 405000 then
                count_enter := count_enter + 1;
            else
                enter_stable := enter_sync2; -- Actualizar estado estable
                count_enter := 0;
            end if;
        else
            count_enter := 0;
        end if;

        -- 4. Detector de Flanco (Genera pulso de 1 ciclo)
        -- Para MOV (Activo bajo: detectamos transición 1 -> 0)
        if mov_last = '1' and mov_stable = '0' then
            mov_db <= '0'; -- Pulso activo por 1 ciclo
        else
            mov_db <= '1';
        end if;
        mov_last := mov_stable; -- Guardar estado actual para el siguiente ciclo

        -- Para ENTER (Activo bajo: detectamos transición 1 -> 0)
        if enter_last = '1' and enter_stable = '0' then
            enter_db <= '0'; -- Pulso activo por 1 ciclo
        else
            enter_db <= '1';
        end if;
        enter_last := enter_stable; -- Guardar estado actual
        
    end if;

end process;
ini<=comiM;
sjugador1<=sjug1;
sjugador<=sjug;
estados<=stadosM;
ganador<= not ganM;
empat<= not empM;
casilla<= enter;
turno<= not jActualM;
movi<=mov;
end Behavioral;
