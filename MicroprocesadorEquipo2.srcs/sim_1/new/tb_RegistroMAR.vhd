----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2025 06:54:21 PM
-- Design Name: 
-- Module Name: tb_RegistroMAR - Behavioral
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

entity tb_RegistroMAR is
end tb_RegistroMAR;

architecture Behavioral of tb_RegistroMAR is
    
    component RegistroMAR
        Port(
            clk     : in  std_logic;                   
            reset   : in  std_logic;                    
            guardar : in  std_logic;                    
            mar_in  : in  std_logic_vector(7 downto 0); 
            direccion_out : out std_logic_vector(7 downto 0)
        );
    end component;
    
    -- senales para ingresar y leer prueba
    -- entradas
    signal clk: std_logic := '0';
    signal reset: std_logic := '0';
    signal guardar: std_logic := '0';
    signal mar_in: std_logic_vector (7 downto 0) := (others => '0');
    
    -- salida
    signal direccion_out: std_logic_vector (7 downto 0);
    
    
    -- periodo de ciclo de reloj
    constant t : time := 10ns;

begin
    -- instancia de UUT, conecta puertos con sus respectivas senales de la TB
    UUT: RegistroMAR Port Map (
        clk => clk,
        reset => reset,
        guardar => guardar,
        mar_in => mar_in,
        direccion_out => direccion_out
    );
    
    -- definicion de ciclo de reloj
    clock : process
    begin
        clk <= '0';
        wait for t/2;
        clk <= '1';
        wait for t/2;
    end process;
    
    stim : process
    begin
        reset <= '1';
        guardar <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        reset <= '0';        
        
        mar_in <= "00010101";
        guardar <= '1';
        wait until rising_edge(clk);
        
        reset <= '1';
        guardar <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        reset <= '0';     
        
        mar_in <= "01000011";
        guardar <= '1';
        wait until rising_edge(clk);
        
        guardar <= '0';
        
        wait;        
    end process;


end Behavioral;
