----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/14/2025 01:48:53 PM
-- Design Name: 
-- Module Name: tb_SistemaSensores - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_Sensor_System is
end tb_Sensor_System;

architecture Behavioral of tb_Sensor_System is

    -- 1. COMPONENTE 1: TU DISEÑO (EL BANCO DE REGISTROS)
    component RegistrosSensores is
        Port (
            clk          : in  STD_LOGIC;
            reset        : in  STD_LOGIC;
            echos_in     : in  STD_LOGIC_VECTOR(3 downto 0);
            triggers_out : out STD_LOGIC_VECTOR(3 downto 0);
            reg_address  : in  STD_LOGIC_VECTOR(1 downto 0);
            reg_data_out : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    -- 2. COMPONENTE 2: EL MODELO DE SIMULACIÓN (EL SENSOR)
    component Sensor_HCSR04_Modelo
        generic (
            SIM_DISTANCIA_CM : integer := 30
        );
        port (
            trigger_in : in  std_logic;
            echo_out   : out std_logic
        );
    end component;

    -- SEÑALES DEL TESTBENCH
    -- Globales
    signal s_clk    : STD_LOGIC := '0';
    signal s_reset  : STD_LOGIC := '0';
    constant t_clk  : time := 20 ns; -- Reloj de 50 MHz

    -- Conexiones al DUT (RegistrosSensores)
    -- Conexiones al DUT (RegistrosSensores)
    signal s_echos_in     : STD_LOGIC_VECTOR(3 downto 0);
    signal s_triggers_out : STD_LOGIC_VECTOR(3 downto 0);
    signal s_reg_address  : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal s_reg_data_out : STD_LOGIC_VECTOR(7 downto 0);

begin

    -- 3. INSTANCIA DEL DISEÑO (DUT)
    -- Se conecta a los buses de echos y triggers
    UUT_Registers : RegistrosSensores
        port map (
            clk          => s_clk,
            reset        => s_reset,
            echos_in     => s_echos_in,
            triggers_out => s_triggers_out,
            reg_address  => s_reg_address,
            reg_data_out => s_reg_data_out
        );

    -- 4. INSTANCIAS DEL MODELO (EL MUNDO EXTERIOR)
    -- Usamos un 'generate' para crear 4 sensores simulados.
    G_Models : for i in 0 to 3 generate
    begin
        -- Cada sensor (i) simulará una distancia diferente:
        -- i=0 -> 10 cm
        -- i=1 -> 20 cm
        -- i=2 -> 30 cm
        -- i=3 -> 40 cm
        Model_Inst : Sensor_HCSR04_Modelo
            generic map (
                SIM_DISTANCIA_CM => 10 * (i + 1)
            )
            port map (
                -- Conecta el trigger 'i' del DUT al 'trigger_in' de este modelo
                trigger_in => s_triggers_out(i),
                -- Conecta el 'echo_out' de este modelo al bus 'i' de echos
                echo_out   => s_echos_in(i)
            );
    end generate G_Models;


    -- 5. GENERADOR DE RELOJ
    clk_process : process
    begin
        s_clk <= not s_clk;
        wait for t_clk / 2;
    end process;

    -- 6. PROCESO DE ESTÍMULOS (SIMULANDO AL MICROPROCESADOR)
    stim_process : process
    begin
        -- Reset
        s_reset <= '1';
        wait for t_clk * 2;
        s_reset <= '0';
        
        -- Espera a que los sensores hagan su primer ciclo
        wait for 5 ms; 
        
        -- El microprocesador lee el registro del SENSOR 0
        s_reg_address <= "00";
        wait for 1 ms;
        -- En la onda, 's_reg_data_out' debería mostrar 10 (x"0A")
        
        -- El microprocesador lee el registro del SENSOR 1
        s_reg_address <= "01";
        wait for 1 ms;
        -- En la onda, 's_reg_data_out' debería mostrar 20 (x"14")
        
        -- El microprocesador lee el registro del SENSOR 2
        s_reg_address <= "10";
        wait for 1 ms;
        -- En la onda, 's_reg_data_out' debería mostrar 30 (x"1E")
        
        -- El microprocesador lee el registro del SENSOR 3
        s_reg_address <= "11";
        wait for 1 ms;
        -- En la onda, 's_reg_data_out' debería mostrar 40 (x"28")
        
        wait;
        
    end process;

end Behavioral;