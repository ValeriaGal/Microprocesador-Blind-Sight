------------------------------------------------------------------------------------
---- Company: 
---- Engineer: 
---- 
---- Create Date: 11/12/2025 11:15:44 AM
---- Design Name: 
---- Module Name: Contador_PC - Behavioral
---- Project Name: 
---- Target Devices: 
---- Tool Versions: 
---- Description: 
---- 
---- Dependencies: 
---- 
---- Revision:
---- Revision 0.01 - File Created
---- Additional Comments:
---- 
------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

entity Contador_PC is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           pc_enable : in STD_LOGIC;
           pc_sc_load : in STD_LOGIC;
           sc : in STD_LOGIC_VECTOR (7 downto 0);
           conteo : out STD_LOGIC_VECTOR (7 downto 0)
    );
end Contador_PC;

architecture Behavioral of Contador_PC is
    signal counter : unsigned (7 downto 0) := (others => '0');
    
begin
    conteo <= STD_LOGIC_VECTOR(counter);

    process(clk, reset)
    begin
        if reset = '1' then
            counter <= "00000000";
        elsif rising_edge(clk) then
            if pc_sc_load = '1' then
                counter <= unsigned(sc); -- sobrecarga en el contador
            elsif pc_enable = '1' then
                counter <= counter + 1;
            end if;
        end if;
    end process;
    
end Behavioral;