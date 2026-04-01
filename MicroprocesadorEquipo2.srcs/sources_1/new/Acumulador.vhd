----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/15/2025 03:27:37 PM
-- Design Name: 
-- Module Name: Acumulador - Behavioral
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

entity Acumulador is
  Port (
      clk : in std_logic; 
      reset : in std_logic;
      load_enable : in std_logic; -- se conecta al acc_pulse de la UC
      data_in : in std_logic_vector (7 downto 0);
      data_out : out std_logic_vector (7 downto 0)
  );
end Acumulador;

architecture Behavioral of Acumulador is

begin
    process (clk, reset)
    begin
        if reset = '1' then --Reinicio de registro a 0
            data_out <= (others => '0');
        elsif rising_edge(clk) then
            if load_enable = '1' then
                data_out <= data_in;
            end if;
        end if;
    end process;
end Behavioral;