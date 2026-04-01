----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2025 11:15:44 AM
-- Design Name: 
-- Module Name: ALU - Behavioral
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

entity ALU is
    Port (
        clk: in std_logic;
        reset: in std_logic;
        enable: in std_logic;
        A: in std_logic_vector (7 downto 0);
        B: in std_logic_vector (7 downto 0);
        sens : in std_logic_vector (7 downto 0); -- entrada de registro Sensores
        OUTPUT: out std_logic_vector (7 downto 0);
        SEL: in std_logic_vector (3 downto 0) := (others => '0')
    );
end ALU;

architecture Behavioral of ALU is
    --senales para operaciones aritmeticas de la ALU
    signal A_u : UNSIGNED(7 downto 0);
    signal B_u : UNSIGNED(7 downto 0);
    signal OUTPUT_u : UNSIGNED(7 downto 0);
begin
    -- conexion de senales y puertos de la entidad
    A_u <= unsigned(A);
    B_u <= unsigned(B);
    OUTPUT <= std_logic_vector(OUTPUT_u);
    
    
    process(A_u, B_u, sens, SEL, A, B)
        variable dist_int : integer range 0 to 255;
    begin
        OUTPUT_u <= (others => '0');
        
        case SEL is -- para operaciones aritmeticas, se utilizan creadas
            when "0001" => 
                OUTPUT_u <= A_u + B_u; -- suma aritmetica
            when "0010" => 
                OUTPUT_u <= A_u - B_u; -- resta aritmetica
            when "0011" => 
                OUTPUT_u <= unsigned(A AND B); -- AND logico
            when "0100" =>
                OUTPUT_u <= unsigned(sens); -- sensor de entrada
            when "0101" => -- calcular distancia invertida para motores pwm
                -- distancia invertida
                dist_int := to_integer(unsigned(sens)); -- B_u viene del acumulador (distancia)
                
                if dist_int > 31 then
                    OUTPUT_u <= (others => '0'); -- intensidad 0 (apagado)
                else
                    -- invertir el valor: Intensidad = 31 - distancia
                    OUTPUT_u <= to_unsigned(31 - dist_int, 8);
                end if;
            when "0110" => -- calcular freq_sel segun la distancia 
                dist_int := to_integer(B_u); -- lee la distancia del ACC
                
                if dist_int <= 5 then
                    OUTPUT_u <= to_unsigned(3, 8); -- freq "11"
                elsif dist_int <= 10 then
                    OUTPUT_u <= to_unsigned(2, 8); -- freq "10"
                elsif dist_int <= 20 then
                    OUTPUT_u <= to_unsigned(1, 8); -- freq "01"
                else
                    OUTPUT_u <= to_unsigned(0, 8); -- freq "00"
                end if;
            when others => 
                OUTPUT_u <= (others => '0'); --default
        end case;
    end process;

end Behavioral;
