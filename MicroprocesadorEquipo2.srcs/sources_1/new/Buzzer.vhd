----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.11.2025 22:42:50
-- Design Name: 
-- Module Name: Buzzer - Behavioral
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

entity Buzzer is
  Port (
    clk : in std_logic;
    reset : in std_logic;
    enable : in std_logic;
    freq_sel : in std_logic_vector(1 downto 0); -- para valores del 0 al 3
    beep : buffer std_logic
  );
end Buzzer;

architecture Behavioral of Buzzer is
    signal contador_nota : integer range 0 to 100000;
    signal limite_cuenta : integer range 0 to 100000;
    
    -- CAMBIO: Corregir las constantes basadas en un reloj de 100MHz (10ns)
    constant freq_250HZ  : integer := 0; -- grave - objeto lejos
    constant freq_500HZ  : integer := 50000;  -- medio - objeto medio cerca
    constant freq_1000HZ : integer := 25000;  -- agudo - objeto cerca
    constant freq_2000HZ : integer := 12500;  -- muy agudo - objeto demasiado cerca
     
    
begin
-- para definir cual es la frecuencia que se va a manejar
-- vendrá de la microinstruccion, pueden ser microinstrucciones de BUZ0, BUZ1, BUZ2, BUZ3 -> con la frecuencia y enable = 1
    process(freq_sel)
    begin
        case freq_sel is
            when "00" => 
                limite_cuenta <= freq_250Hz; -- este es para que se apague el buzzer pq es mayor a 20 cm la distancia
            when "01" => 
                limite_cuenta <= freq_500Hz;
            when "10" => 
                limite_cuenta <= freq_1000Hz;
            when "11" => 
                limite_cuenta <= freq_2000Hz;
            when others => 
                limite_cuenta <= freq_500Hz;
        end case;   
    end process;
    
    process (clk, reset)
    begin
        if reset = '1' then 
            contador_nota <= 0; -- contador para cuantas veces se mostrará el mismo beep
            beep <= '0'; -- salida del buzzer
        elsif rising_edge(CLK) then
                
            -- solo generar tono si enable está activo
            if not (freq_sel = "00") then 
            -- hace hasta que el contador llega a limite cuenta de ahi se cambia a la señal inversa
                if contador_nota >= limite_cuenta then 
                    contador_nota <= 0;
                    beep <= not beep;  -- invierte la señal para generar onda cuadrada
                else
                    contador_nota <= contador_nota + 1;
                end if;
            else
                -- si está deshabilitado, resetear contador y apagar
                contador_nota <= 0;
                beep <= '0';
            end if;
        end if;
    end  process;

end Behavioral;

