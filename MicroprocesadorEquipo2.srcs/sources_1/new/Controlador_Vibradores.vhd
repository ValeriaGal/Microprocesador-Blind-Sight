----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.11.2025 01:29:35
-- Design Name: 
-- Module Name: Controlador_Vibradores - Behavioral
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

entity Controlador_Vibradores is
    Port ( 
        clk           : in  std_logic;
        reset         : in  std_logic;
        
        -- microinstruccion 'writeM'. un pulso de 1 ciclo para escribir. -- como trigger
        write_enable  : in  std_logic; 
        -- distancia que esta guardada en el acumulador
        distance_in   : in  std_logic_vector(7 downto 0); 
        -- el motor que se controla (0-3)
        motor_sel     : in  std_logic_vector(1 downto 0); 
        -- salidas de los 4 motores
        vibra_outs    : out std_logic_vector(3 downto 0)
    );
end entity;

architecture Behavioral of Controlador_Vibradores is

    -- instancia del actuador 
    component ActuadorVibracion is
      Port (
        clk       : in std_logic;
        reset     : in std_logic;
        enable    : in std_logic;
        distance  : in std_logic_vector (7 downto 0);
        vibra_out : buffer std_logic
      );
    end component;
    
    -- 4 registros para guardar la distancia de cada motor
    type t_distance_reg is array (0 to 3) of STD_LOGIC_VECTOR(7 downto 0);
    signal reg_distances : t_distance_reg := (others => "00100000"); -- 32 para que empiecen apagados

    -- señales internas
    signal s_enables    : std_logic_vector(3 downto 0);
    signal s_vibra_outs : std_logic_vector(3 downto 0);
    signal s_sel_int    : integer range 0 to 3;
    
begin

    -- pasar selector a int
    s_sel_int <= to_integer(unsigned(motor_sel));
    
    -- proceso donde writeM actualiza la distancia de un motor -- escribir en la mini memoria
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- resetea todas las distancias guardadas a 32 que es apagado, 0 seria maxima
                reg_distances <= (others => "00100000"); -- 32 apagado
            elsif write_enable = '1' then
                -- actualiza SOLO UN registro (el seleccionado)
                reg_distances(s_sel_int) <= distance_in;
            -- tal vez poner un else que diga quereg(s_sel_int) <= 32; para cuando el enable sea 0
            end if;
            -- si write_enable='0', los registros no cambian
            -- y los motores siguen funcionando con su valor anterior.
        end if;
    end process;

    
    -- *** Lógica de LECTURA (Paralela) ***
    -- Genera los 4 actuadores. Cada uno está permanentemente
    -- conectado a su propia "memoria" (reg_distances(i)).
    G_Vibrador_Instances: for i in 0 to 3 generate
        -- Lógica de ENABLE individual (tu regla: apagar si > 31)
    begin
        s_enables(i) <= '0' when to_integer(unsigned(reg_distances(i))) > 31 else '1';
        VIB_Inst: entity work.ActuadorVibracion
            port map (
                clk       => clk,
                reset     => reset,
                enable    => s_enables(i),      -- enable individual
                distance  => reg_distances(i),  -- distancia individual
                vibra_out => s_vibra_outs(i)
            );
    end generate G_Vibrador_Instances;
    
    -- conectar salidas internas al puerto externo
    vibra_outs <= s_vibra_outs;

end architecture;


