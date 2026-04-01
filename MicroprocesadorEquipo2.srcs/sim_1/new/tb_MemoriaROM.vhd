----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2025 06:54:21 PM
-- Design Name: 
-- Module Name: tb_MemoriaROM - Behavioral
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

entity tb_MemoriaROM is
end tb_MemoriaROM;

architecture Behavioral of tb_MemoriaROM is

    -- Componente (tu entidad de ROM pura)
    component MemoriaROM
        Port (
            bus_direcc : in  std_logic_vector(7 downto 0);
            enable     : in  std_logic;
            data_out   : out std_logic_vector(15 downto 0)
        );
    end component;

    -- Señales del Testbench
    signal s_bus_direcc : std_logic_vector(7 downto 0) := (others => '0');
    signal s_enable     : std_logic := '0';
    signal s_data_out   : std_logic_vector(15 downto 0);

    -- Constante de espera para dar tiempo a que las señales se propaguen
    constant T_WAIT : time := 10 ns;

begin

    -- Instancia del "Device Under Test" (DUT)
    UUT: MemoriaROM Port Map (
        bus_direcc => s_bus_direcc,
        enable     => s_enable,
        data_out   => s_data_out
    );

    -- Proceso de Estímulos (las pruebas)
    stim_process : process
    begin
        -- 1. Estado inicial (Enable = 0)
        -- 'data_out' debería estar en Alta Impedancia ('Z')
        s_enable     <= '0';
        s_bus_direcc <= "00000000";
        wait for T_WAIT;

        -- 2. Habilitar y LEER la dirección 0
        -- 'data_out' debería ser "00000001"
        s_enable <= '1';
        wait for T_WAIT;

        -- 3. LEER la dirección 1 (mientras sigue habilitado)
        -- 'data_out' debería ser "00000010"
        s_bus_direcc <= "00000001";
        wait for T_WAIT;
        
        -- 4. LEER la dirección 2
        -- 'data_out' debería ser "11110000"
        s_bus_direcc <= "00000010";
        wait for T_WAIT;

        -- 5. LEER una dirección no definida (ej: 10)
        -- 'data_out' debería ser "00000000" (el valor de 'others')
        s_bus_direcc <= "00001010";
        wait for T_WAIT;

        -- 6. Deshabilitar de nuevo
        -- 'data_out' debería volver a "ZZZZZZZZ"
        s_enable <= '0';
        wait for T_WAIT;

        -- 7. Fin de la simulación
        wait;
        
    end process;

end Behavioral;