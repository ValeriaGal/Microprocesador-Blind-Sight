----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.11.2025 01:28:16
-- Design Name: 
-- Module Name: ActuadorVibracion - Behavioral
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
use IEEE.numeric_std.all;

entity ActuadorVibracion is
  Port ( 
    clk : in std_logic;
    reset : in std_logic;
    enable : in std_logic;
    distance : in std_logic_vector (7 downto 0);
    vibra_out : buffer std_logic
  );
end ActuadorVibracion;

architecture Behavioral of ActuadorVibracion is
-- frecuencia de 200Hz, entonces 1/ 200Hz = 0.005 s = 5,000,000 ns, entonces clk es 10ns,
-- entonces se necesitan 500,000 ciclos de reloj para hacer un ciclo de vibración
-- 500,000 / 32 (distancias) = 16129,  pwm ira de 0 a 500,000

-- este necesita 100,000 ciclos de reloj para hacer un ciclo de vibracion * 10 ns = 1,000,000 ns = .001 s = periodo
-- 1 / .001 = frecuencia => 1000Hz
    constant periodo_completo : integer := 99999; 
   -- constant rango_contador : integer := 100000; -- innecesario lo puse directamente
    constant scala_factor  : integer := 3225;
    
    signal contador_pwm : integer range 0 to 100000;
    signal limite_pulso : integer range 0 to 100000;
    
    
    
    -- para real de 200Hz, para propositos de la simulacion sera otro (1000hz).
--    constant periodo_completo : integer := 499999; 
   -- constant rango_contador : integer := 500000;
--    constant scala_factor  : integer := 16129;
    
--    signal contador_pwm : integer range 0 to 500000;
--    signal limite_pulso : integer range 0 to 500000;

begin
    
    -- distance ya viene con la intensidad invertida
    process(distance)
        variable intensity_int : integer range 0 to 255;
    begin
        intensity_int := to_integer(unsigned(distance));        
        limite_pulso <= intensity_int * scala_factor;
    end process;
    
    
    process(clk, reset)
    begin
        if reset = '1' then
            contador_pwm <= 0;
            vibra_out <= '0';
        elsif rising_edge(clk) then
            if enable = '1' then
                if contador_pwm >= periodo_completo then
                    contador_pwm <= 0;
                else
                    contador_pwm <= contador_pwm +1;
                end if;
                
                if contador_pwm < limite_pulso then
                    vibra_out <= '1';
                else
                    vibra_out <= '0';                
                end if;
            else 
                contador_pwm <= 0;
                vibra_out <= '0';
            end if;
        end if;
        
        
    end process;
    
end Behavioral;