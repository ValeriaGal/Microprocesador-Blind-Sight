----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2025 04:57:54 PM
-- Design Name: 
-- Module Name: TriggerGen - Behavioral
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

entity TriggerGen is
generic (n: integer :=20);
    Port ( 
        clk : in  STD_LOGIC;
        reset : in Std_logic;
        trigger : out  STD_LOGIC);

end TriggerGen;

architecture Behavioral of TriggerGen is

signal tick: unsigned(n-1 downto 0) := (others =>'0');
constant nclks: integer := 1000; -- manda un pulso cada segundo

begin
  process (clk, reset) 
  begin
    if reset = '1' then
        tick <= (others => '0');
   elsif clk'event and clk = '1' then
        if tick < nclks-1 then 
            tick <= tick + 1;
        else
            tick <= (others => '0');
        end if;
   end if;
  end process;
  
  -- si tick es mayor o igual a la cantidad de pulsos a esperar (nclks) - 500, poner trigger en 1
  -- gracias al -500, trigger se mantendra en 1 durante 500 ciclos
  -- el trigger reseteara el contador de echo del controlador y 
  -- activara el modelo de simulacion del sensor para entregar su distancia simulada
 trigger <= '1' when (tick >= (nclks - 50)) else '0';

end Behavioral;