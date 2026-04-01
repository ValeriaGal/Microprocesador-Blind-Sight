----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2025 04:57:54 PM
-- Design Name: 
-- Module Name: distance_calculation - Behavioral
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

entity distance_calculation is
    port(
        echo_count : in STD_LOGIC_VECTOR (19 downto 0);
        distance : out STD_LOGIC_VECTOR (8 downto 0)
    );
end distance_calculation;

architecture Behavioral of distance_calculation is
    
    -- SIMULACIÓN RÁPIDA:
    -- En Sensor_HCSR04_Modelo, 10cm = 100ns de pulso.
    -- En SensorULTSON, 100ns = 10 ciclos de reloj (con t_clk=10ns).
    -- Por lo tanto, DIVIDIMOS POR 1 para que 10 ciclos = 10cm.
    constant DIVISOR : integer := 1; 
    
    signal s_echo_count_u : unsigned(19 downto 0);
    signal s_dist_int : unsigned(8 downto 0);
    
begin
    
    s_echo_count_u <= unsigned(echo_count);
    
    -- Lógica de división:
    -- Si el contador es 0, la distancia es 0.
    -- de lo contrario, divide el conteo de ciclos / DIVISOR
    s_dist_int <= (others => '0') when s_echo_count_u = 0 else
                  resize(s_echo_count_u / DIVISOR, 9);
    
    distance <= std_logic_vector(s_dist_int);
    
end Behavioral;
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;


--entity distance_calculation is
--port(
--echo_count : in STD_LOGIC_VECTOR (19 downto 0);
--distance : out  STD_LOGIC_VECTOR (8 downto 0)
--);
--end distance_calculation;

--architecture Behavioral of distance_calculation is

--    signal echo_count_u : unsigned(19 downto 0);
    
--begin
--    echo_count_u <= unsigned(echo_count);
    
--    Distance <=
--        "000000000" when (echo_count_u < 2900) else --0cm
--        "000000001" when (echo_count_u > 2900 and echo_count_u < 4350) else --1-1.5cm
--        "000000001" when (echo_count_u > 4350 and echo_count_u < 5800) else --1.5-2cm
--        "000000010" when (echo_count_u > 5800 and echo_count_u < 7250) else --2-2.5cm
--        "000000010" when (echo_count_u > 7250  and echo_count_u < 8700) else --2.5-3cm
--        "000000011" when (echo_count_u > 8700  and echo_count_u < 10150) else --3-3.5cm
--        "000000011" when (echo_count_u > 10150 and echo_count_u < 11600) else --3.5-4cm
--        "000000100" when (echo_count_u > 13050 and echo_count_u < 14500) else --4-4.5cm
--        "000000100" when (echo_count_u > 14500 and echo_count_u < 15950) else --4.5-5cm
--        ------------------------------------------------------------------------------
--        "000000101" when (echo_count_u > 15950 and echo_count_u < 17400) else --5-5.5cm
--        "000000101" when (echo_count_u > 17400 and echo_count_u < 18850) else --5.5-6cm
--        "000000110" when (echo_count_u > 18850 and echo_count_u < 20300) else --6-6.5cm
--        "000000110" when (echo_count_u > 20300 and echo_count_u < 21750) else --6.5-7cm
--        "000000111" when (echo_count_u > 21750 and echo_count_u < 23200) else --7-7.5cm 
--        "000000111" when (echo_count_u > 23200 and echo_count_u < 24650) else --7.5-8cm 
--        "000001000" when (echo_count_u > 24650 and echo_count_u < 26100) else --8-8.5cm 
--        "000001000" when (echo_count_u > 27550 and echo_count_u < 29000) else --8.5-9cm
--        "000001001" when (echo_count_u > 29000 and echo_count_u < 30450) else --9-9.5cm
--        "000001001" when (echo_count_u > 30450 and echo_count_u < 31900) else --9.5-10cm
--        ------------------------------------------------------------------------------
--        "000001010" when (echo_count_u > 30450 and echo_count_u < 31900) else --10-10.5cm
--        "000001010" when (echo_count_u > 31900 and echo_count_u < 33350) else --10.5-11cm
--        "000001011" when (echo_count_u > 33350 and echo_count_u < 34800) else --11-11.5cm
--        "000001011" when (echo_count_u > 34800 and echo_count_u < 36250) else --11.5-12cm
--        "000001100" when (echo_count_u > 36250 and echo_count_u < 37700) else --12-12.5cm
--        "000001100" when (echo_count_u > 37700 and echo_count_u < 39150) else --12.5-13cm
--        "000001101" when (echo_count_u > 39150 and echo_count_u < 40600) else --13-13.5cm
--        "000001101" when (echo_count_u > 40600 and echo_count_u < 42050) else --13.5-14cm
--        "000001110" when (echo_count_u > 42050 and echo_count_u < 43500) else --14-14.5cm
--        "000001110" when (echo_count_u > 43500 and echo_count_u < 44950) else --14.5-15cm
--        ------------------------------------------------------------------------------
--        "000001111" when (echo_count_u > 44950 and echo_count_u < 46400) else --15-15.5cm
--        "000001111" when (echo_count_u > 46400 and echo_count_u < 47850) else --15.5-16cm
--        "000010000" when (echo_count_u > 47850 and echo_count_u < 49300) else --16-16.5cm
--        "000010000" when (echo_count_u > 49300 and echo_count_u < 50750) else --16.5-17cm
--        "000010001" when (echo_count_u > 50750 and echo_count_u < 52200) else --17-17.5cm
--        "000010001" when (echo_count_u > 52200 and echo_count_u < 53650) else --17.5-18cm
--        "000010010" when (echo_count_u > 53650 and echo_count_u < 55100) else --18-18.5cm
--        "000010010" when (echo_count_u > 55100 and echo_count_u < 56550) else --18.5-19cm
--        "000010011" when (echo_count_u > 56550 and echo_count_u < 58000) else --19-19.5cm
--        "000010011" when (echo_count_u > 58000 and echo_count_u < 59450) else --19.5-20cm
--        ------------------------------------------------------------------------------
--        "000010100" when (echo_count_u > 59450 and echo_count_u < 60900) else --20-20.5cm
--        "000010100" when (echo_count_u > 60900 and echo_count_u < 62350) else --20.5-21cm
--        "000010101" when (echo_count_u > 62350 and echo_count_u < 63800) else --21-21.5cm
--        "000010101" when (echo_count_u > 63800 and echo_count_u < 65250) else --21.5-22cm
--        "000010110" when (echo_count_u > 65250 and echo_count_u < 66700) else --22-22.5cm
--        "000010110" when (echo_count_u > 66700 and echo_count_u < 68150) else --22.5-23cm
--        "000010111" when (echo_count_u > 68150 and echo_count_u < 69600) else --23-23.5cm
--        "000010111" when (echo_count_u > 69600 and echo_count_u < 71050) else --23.5-24cm
--        "000011000" when (echo_count_u > 71050 and echo_count_u < 72500) else --24-24.5cm
--        "000011000" when (echo_count_u > 72500 and echo_count_u < 73950) else --24.5-25cm
--        ------------------------------------------------------------------------------
--        "000011001" when (echo_count_u > 73950 and echo_count_u < 75400) else --25-25.5cm
--        "000011001" when (echo_count_u > 75400 and echo_count_u < 76850) else --25.5-26cm
--        "000011010" when (echo_count_u > 76850 and echo_count_u < 78300) else --26-26.5cm
--        "000011010" when (echo_count_u > 78300 and echo_count_u < 79750) else --26.5-27cm
--        "000011011" when (echo_count_u > 79750 and echo_count_u < 81200) else --27-27.5cm
--        "000011011" when (echo_count_u > 81200 and echo_count_u < 82650) else --27.5-28cm
--        "000011100" when (echo_count_u > 82650 and echo_count_u < 84100) else --28-28.5cm
--        "000011100" when (echo_count_u > 84100 and echo_count_u< 85550) else --28.5-29cm
--        "000011101" when (echo_count_u > 85550 and echo_count_u < 87000) else --29-29.5cm
--        "000011101" when (echo_count_u > 87000 and echo_count_u < 88450) else --29.5-30cm
--        "000011110" when (echo_count_u > 88450 and echo_count_u < 89900) else --30-30.5cm
--        "000011110" when (echo_count_u > 89900 and echo_count_u < 91350) else --30.5-31cm
--        "000011111";
	  	  
--end Behavioral;
