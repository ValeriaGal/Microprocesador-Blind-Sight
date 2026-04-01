----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2025 06:54:21 PM
-- Design Name: 
-- Module Name: tb_RegistroGPR - Behavioral
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

entity tb_RegistroGPR is
end tb_RegistroGPR;

architecture Behavioral of tb_RegistroGPR is
    
    component RegistroGPR
        Port(
            clk        : in  std_logic;
            reset      : in  std_logic;
            load       : in  std_logic; 
            gpr_in     : in  std_logic_vector(15 downto 0); 
            data_out   : out std_logic_vector(7 downto 0); 
            instr_out  : out std_logic_vector(7 downto 0)
        );
    end component;
    
    -- senales para ingresar y leer prueba
    -- entradas
    signal clk: std_logic := '0';
    signal reset: std_logic := '0';
    signal load: std_logic := '0';
    signal gpr_in: std_logic_vector (15 downto 0) := (others => '0');
    
    -- salida
    signal data_out: std_logic_vector (7 downto 0);
    signal instr_out: std_logic_vector (7 downto 0);
    
    
    -- periodo de ciclo de reloj
    constant t : time := 10ns;

begin
    -- instancia de UUT, conecta puertos con sus respectivas senales de la TB
    UUT: RegistroGPR Port Map (
        clk => clk,
        reset => reset,
        load => load,
        gpr_in => gpr_in,
        data_out => data_out,
        instr_out => instr_out
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
        load <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        reset <= '0';        
        
        gpr_in <= "0001010101000011";
        load <= '1';
        wait until rising_edge(clk);
        
        reset <= '1';
        load <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        reset <= '0';     
        
        gpr_in <= "1111111111111111";
        load <= '1';
        wait until rising_edge(clk);
        
        load <= '0';
        
        wait;        
    end process;


end Behavioral;