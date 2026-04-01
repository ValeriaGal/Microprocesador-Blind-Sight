----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2025 12:06:24 PM
-- Design Name: 
-- Module Name: tb_ALU - Behavioral
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

entity tb_ALU is
end tb_ALU;

architecture Behavioral of tb_ALU is

    component ALU
        Port(
            clk: in std_logic;
            reset: in std_logic;
            enable: in std_logic;
            A: in std_logic_vector (7 downto 0);
            B: in std_logic_vector (7 downto 0);
            OUTPUT: out std_logic_vector (7 downto 0);
            SEL: in std_logic_vector (2 downto 0)
        );
    end component;
    
    -- senales para ingresar y leer prueba
    -- entradas
    signal clk: std_logic := '0';
    signal reset: std_logic := '0';
    signal enable: std_logic := '0';
    signal A: std_logic_vector (7 downto 0) := (others => '0');
    signal B: std_logic_vector (7 downto 0) := (others => '0');
    signal SEL: std_logic_vector (2 downto 0) := (others => '0');
    
    -- salida
    signal OUTPUT: std_logic_vector (7 downto 0);
    
    
    -- periodo de ciclo de reloj
    constant t : time := 10ns;
    
begin
    -- instancia de UUT, conecta puertos con sus respectivas senales de la TB
    UUT: ALU Port Map (
        clk => clk,
        reset => reset,
        enable => enable,
        A => A,
        B => B,
        SEL => SEL,
        OUTPUT => OUTPUT
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
        enable <= '0';
        wait for 15ns;
        
        reset <= '0';
        wait until rising_edge(clk);
        
        A <= "00000101";
        B <= "00000010";
        SEL <= "000";        
        enable <= '1';
        wait until rising_edge(clk);
        
        SEL <= "001";
        wait until rising_edge(clk);
        
        SEL <= "010";
        wait until rising_edge(clk);
        
        SEL <= "011";
        wait until rising_edge(clk);
        
        SEL <= "100";
        wait until rising_edge(clk);
        
        SEL <= "101";
        wait until rising_edge(clk);
        
        enable <= '0';
        
        wait;
    end process;


end Behavioral;
