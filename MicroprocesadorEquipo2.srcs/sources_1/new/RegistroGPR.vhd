----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2025 11:15:44 AM
-- Design Name: 
-- Module Name: RegistroGPR - Behavioral
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

entity RegistroGPR is
    Port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        gpr_enable       : in  std_logic; 
        gpr_in     : in  std_logic_vector(15 downto 0);
        data_out   : out std_logic_vector(7 downto 0); 
        instr_out  : out std_logic_vector(7 downto 0)   
    );
end RegistroGPR;

architecture Behavioral of RegistroGPR is
    signal reg_data  : std_logic_vector(7 downto 0);
    signal reg_instr : std_logic_vector(7 downto 0);
begin
    -- Salidas
    data_out  <= reg_data;
    instr_out <= reg_instr;
    
    process(clk, reset)
    begin
        if reset = '1' then
            reg_data  <= (others => '0');
            reg_instr <= (others => '0');
        elsif rising_edge(clk) then
            if gpr_enable = '1' then
                reg_data <= gpr_in(7 downto 0);
                reg_instr <= gpr_in(15 downto 8);
            end if;
        end if;
    end process;

end Behavioral;