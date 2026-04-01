----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2025 06:54:21 PM
-- Design Name: 
-- Module Name: tb_System_TOP - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.02 - Agregados modelos de sensor
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_System_TOP is
end tb_System_TOP;

architecture Behavioral of tb_System_TOP is

    -- Componente a probar (La "Placa Madre")
    component System_TOP is
        Port (
            clk   : in  std_logic;
            reset : in  std_logic;
            
            -- NUEVO: Puertos para la simulación de sensores
            sim_echos_in    : in  STD_LOGIC_VECTOR(3 downto 0);
            sim_triggers_out : out STD_LOGIC_VECTOR(3 downto 0);
            
            -- Puertos de Debug
            o_pc_conteo  : out std_logic_vector(7 downto 0);
            o_mar_out    : out std_logic_vector(7 downto 0);
            o_gpr_instr  : out std_logic_vector(7 downto 0);
            o_gpr_data   : out std_logic_vector(7 downto 0);
            o_ret_out    : out std_logic_vector(7 downto 0);
            o_uc_state   : out std_logic_vector(1 downto 0);
            o_alu_out : out std_logic_vector(7 downto 0);
            o_acc_out : out std_logic_vector (7 downto 0);
            o_sens_data_out : out std_logic_vector (7 downto 0);
            
            o_RET_load_state   : out std_logic;
            o_pc_sc_load_state   : out std_logic;
            o_sc_sel_state   : out std_logic;
            
            o_freq_sel : out std_logic_vector(1 downto 0);
            o_beep : out std_logic;
            
            o_vibra_outs : out std_logic_vector(3 downto 0);
            
            o_distance : out std_logic_vector(7 downto 0);
            o_motor_sel : out std_logic_vector(1 downto 0) 
        );
    end component;

    
    component Sensor_HCSR04_Modelo
        port (
            trigger_in  : in  std_logic;
            echo_out    : out std_logic;
            -- NUEVO PUERTO para la distancia dinámica
            sim_dist_in : in  integer 
        );
    end component;

    -- Señales Globales
    signal s_clk   : std_logic := '0';
    signal s_reset : std_logic := '0';
    constant t_clk : time := 10 ns; -- Reloj de 100 MHz

    -- Señales de Debug
    signal s_pc_conteo  : std_logic_vector(7 downto 0);
    signal s_mar_out    : std_logic_vector(7 downto 0);
    signal s_gpr_instr  : std_logic_vector(7 downto 0);
    signal s_gpr_data   : std_logic_vector(7 downto 0);
    signal s_ret_out    : std_logic_vector(7 downto 0);
    signal s_uc_state   : std_logic_vector(1 downto 0);
    signal s_RET_load_state   : std_logic;
    signal s_pc_sc_load_state   : std_logic;
    signal s_sc_sel_state   : std_logic;
    signal s_alu_out : std_logic_vector (7 downto 0);
    signal s_acc_out : std_logic_vector (7 downto 0);
    signal s_sens_data_out: std_logic_vector (7 downto 0);

    
    signal s_tb_echos    : STD_LOGIC_VECTOR(3 downto 0);
    signal s_tb_triggers : STD_LOGIC_VECTOR(3 downto 0);
    
    -- buzzer 
    signal s_freq_sel : std_logic_vector(1 downto 0);
    signal s_beep : std_logic;
    
    -- motores
    signal s_vibra_outs : std_logic_vector(3 downto 0);
    
    signal s_distance :  std_logic_vector(7 downto 0);
    signal s_motor_sel :  std_logic_vector(1 downto 0);
    
    -- Un array de 4 enteros, uno para cada sensor
    type t_dist_array is array (0 to 3) of integer;
    -- Señal que "alimentará" a los 4 modelos de sensor
    signal s_current_distances : t_dist_array;
    
begin

    -- Instancia del Diseño Bajo Prueba (DUT)
    UUT: System_TOP
        port map (
            clk   => s_clk,
            reset => s_reset,
            
            -- NUEVO: Conectar los puertos de sensores
            sim_echos_in     => s_tb_echos,
            sim_triggers_out => s_tb_triggers,
            
            -- Puertos de Debug
            o_pc_conteo  => s_pc_conteo,
            o_mar_out    => s_mar_out,
            o_gpr_instr  => s_gpr_instr,
            o_gpr_data   => s_gpr_data,
            o_ret_out    => s_ret_out,
            o_uc_state   => s_uc_state,
            
            o_RET_load_state => s_RET_load_state,
            o_pc_sc_load_state => s_pc_sc_load_state,
            o_sc_sel_state => s_sc_sel_state,
            o_sens_data_out => s_sens_data_out,
            
            o_alu_out => s_alu_out,
            o_acc_out => s_acc_out,
            
            o_freq_sel => s_freq_sel,
            o_beep => s_beep,
            
            o_vibra_outs => s_vibra_outs,
            
            o_motor_sel => s_motor_sel,
            o_distance => s_distance
        );

    -- Instancias del Modelo (simulacion de sensores reales)
    -- Genera 4 sensores simulados.
    G_Models : for i in 0 to 3 generate
    begin
        Model_Inst : Sensor_HCSR04_Modelo
            port map (
                trigger_in  => s_tb_triggers(i), -- Trigger 'i' del DUT
                echo_out    => s_tb_echos(i),    -- Echo 'i' hacia el DUT
                -- Conecta la señal de distancia correspondiente
                sim_dist_in => s_current_distances(i) 
            );
    end generate G_Models;


    -- Generador de Reloj
    clk_process : process
    begin
        s_clk <= not s_clk;
        wait for t_clk / 2;
    end process;

    -- Proceso de Estímulos
    stim_process : process
        -- Define las 4 distancias que quieres probar
        type t_test_vec is array (0 to 3) of integer;
        constant DISTANCIAS_TEST : t_test_vec := (3, 15, 30, 40);
    begin
        -- 1. Aplicar Reset
        s_reset <= '1';
        wait for 15 ns; -- Sostener por 1.5 ciclos
        s_reset <= '0';
        
        wait for 50 ns; -- espera a que los sensores se estabilicen
        
        -- 2. Bucle de prueba
        -- Este bucle 'for' iterará 4 veces, una por cada distancia
        for i in 0 to 3 loop
        
            -- Asigna la distancia de prueba (ej. 3cm) a TODOS los sensores
            s_current_distances(0) <= DISTANCIAS_TEST(i);
            s_current_distances(1) <= DISTANCIAS_TEST(i);
            s_current_distances(2) <= DISTANCIAS_TEST(i);
            s_current_distances(3) <= DISTANCIAS_TEST(i);
            
            -- Mantiene esta distancia por 2 ms
            wait for 2 ms; 
            
            -- En la siguiente iteración, pondrá la nueva distancia (ej. 15cm)
            
        end loop;

        -- 3. Fin de las pruebas
        report "Fin de las pruebas de distancia." severity failure; -- 'failure' detiene la simulación
        wait;
    end process;

end Behavioral;