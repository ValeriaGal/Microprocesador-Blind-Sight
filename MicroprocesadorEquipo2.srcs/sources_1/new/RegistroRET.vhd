----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/14/2025 06:35:58 PM
-- Design Name: 
-- Module Name: RegistroRET - Behavioral
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

entity RegistroRET is
    Port ( 
        clk       : in  std_logic;
        reset     : in  std_logic;
        RET_register_load      : in  std_logic; -- '1' para cargar un nuevo valor
        direcc_in : in  std_logic_vector (7 downto 0); -- entra directamente de la MAR
        direcc_out: out std_logic_vector (7 downto 0)
    );
end RegistroRET;

architecture Behavioral of RegistroRET is
    
    signal s_direcc_reg : std_logic_vector(7 downto 0) := (others => '0');
    
begin

    direcc_out <= s_direcc_reg;

    process(clk, reset)
    begin
        if reset = '1' then
            s_direcc_reg <= (others => '0');
        elsif rising_edge(clk) then
            if RET_register_load = '1' then
                s_direcc_reg <= direcc_in; 
            end if;
        end if;
    end process;

end Behavioral;