----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2025 04:44:07 PM
-- Design Name: 
-- Module Name: HCSR04_Modelo - Behavioral
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

library ieee;
use ieee.std_logic_1164.all;

entity Sensor_HCSR04_Modelo is
    port (
        trigger_in : in  std_logic;
        echo_out   : out std_logic;
        sim_dist_in : in  integer
    );
end entity;

architecture Behavioral of Sensor_HCSR04_Modelo is
begin
    process
    begin
        echo_out <= '0';
    
        -- Espera un flanco de subida en el trigger
        wait until falling_edge(trigger_in);
        
        -- Simula el tiempo de procesamiento interno del sensor
        -- wait for 50 us; 
        wait for 1 ns; 
        
        -- Genera el pulso de echo
        echo_out <= '1';
        wait for sim_dist_in * 10 * 1 ns;
        echo_out <= '0';
    end process;
end Behavioral;