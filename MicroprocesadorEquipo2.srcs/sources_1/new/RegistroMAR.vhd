----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2025 11:15:44 AM
-- Design Name: 
-- Module Name: RegistroMAR - Behavioral
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

entity RegistroMAR is
    Port (
        clk     : in  std_logic;                   
        reset   : in  std_logic;                    
        mar_enable : in  std_logic;                    
        mar_in  : in  std_logic_vector(7 downto 0); 
        direccion_out : out std_logic_vector(7 downto 0) 
    );
end RegistroMAR;

architecture Behavioral of RegistroMAR is
    signal output_address : std_logic_vector(7 downto 0);
begin
    direccion_out <= output_address;
    
    process(clk, reset)
    begin
        if reset = '1' then
            output_address <= (others => '0');
        elsif rising_edge(clk) then
            if mar_enable = '1' then
                output_address <= mar_in;
            end if;
        end if;
    end process;
end Behavioral;