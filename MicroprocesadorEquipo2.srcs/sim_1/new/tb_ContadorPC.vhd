----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2025 06:54:21 PM
-- Design Name: 
-- Module Name: tb_ContadorPC - Behavioral
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

-- La entidad del testbench siempre está vacía
entity tb_ContadorPC is
end tb_ContadorPC;

architecture Behavioral of tb_ContadorPC is

    -- Declaración del Componente (tu Contador_PC)
    component Contador_PC
        Port (
            clk    : in  STD_LOGIC;
            reset  : in  STD_LOGIC;
            enable : in  STD_LOGIC;
            load   : in  STD_LOGIC;
            sc     : in  STD_LOGIC_VECTOR(7 downto 0);
            conteo : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    -- Señales del Testbench
    signal s_clk    : STD_LOGIC := '0';
    signal s_reset  : STD_LOGIC := '0';
    signal s_enable : STD_LOGIC := '0';
    signal s_load   : STD_LOGIC := '0';
    signal s_sc     : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal s_conteo : STD_LOGIC_VECTOR(7 downto 0);

    -- Constante de reloj (10ns = 100 MHz)
    constant t_clk : time := 10 ns;

begin

    -- Instancia del "Device Under Test" (DUT)
    UUT: Contador_PC Port Map (
        clk    => s_clk,
        reset  => s_reset,
        enable => s_enable,
        load   => s_load,
        sc     => s_sc,
        conteo => s_conteo
    );

    -- 1. Generador de Reloj
    clk_process : process
    begin
        s_clk <= not s_clk;
        wait for t_clk / 2;
    end process;

    -- 2. Proceso de Estímulos (Las Pruebas)
    stim_process : process
    begin
        -- 2A. APLICAR RESET ASÍNCRONO
        s_reset  <= '1';
        s_enable <= '0';
        s_load   <= '0';
        s_sc     <= (others => '0');
        wait for 15 ns; -- Sostenemos el reset por 1.5 ciclos
        
        s_reset <= '0';
        -- En este punto, 's_conteo' debe ser "00000000"

        -- 2B. PROBAR INCREMENTO NORMAL
        s_enable <= '1';
        s_load   <= '0';
        wait until rising_edge(s_clk); -- conteo = 1
        wait until rising_edge(s_clk); -- conteo = 2
        wait until rising_edge(s_clk); -- conteo = 3
        
        -- 's_conteo' ahora debe ser "00000011"

        -- 2C. PROBAR LOAD (JUMP)
        s_load <= '1';
        s_sc   <= x"AA"; -- Cargar "10101010"
        wait until rising_edge(s_clk);
        -- 's_conteo' ahora debe ser "10101010"

        -- 2D. VERIFICAR QUE SIGUE INCREMENTANDO (después del load)
        s_load <= '0';
        wait until rising_edge(s_clk);
        -- 's_conteo' ahora debe ser "10101011"
        
        -- 2E. PROBAR STALL (ENABLE = 0)
        s_enable <= '0';
        wait until rising_edge(s_clk);
        -- 's_conteo' debe *quedarse* en "10101011"
        wait until rising_edge(s_clk);
        -- 's_conteo' debe *quedarse* en "10101011"
        
        s_enable <= '1';
        wait until rising_edge(s_clk);
        wait until rising_edge(s_clk);
        wait until rising_edge(s_clk);

        -- 2F. PROBAR PRIORIDAD (ENABLE sobre LOAD)
        s_enable <= '0';
        s_load   <= '1';
        s_sc     <= x"FF";
        wait until rising_edge(s_clk);
        -- 's_conteo' debe *quedarse* en "10101011" (porque enable='0')

        -- 2G. RE-HABILITAR (debe cargar x"FF" inmediatamente)
        s_enable <= '1';
        wait until rising_edge(s_clk);
        -- 's_conteo' ahora debe ser "11111111"
        
        -- 2H. PROBAR RESET DE NUEVO
        s_reset <= '1';
        wait for 5 ns; -- El reset es asíncrono, debe ocurrir de inmediato
        -- 's_conteo' debe ser "00000000"
        
        s_reset <= '0';
        wait for t_clk;

        -- Fin de la simulación
        wait;
        
    end process;

end Behavioral;