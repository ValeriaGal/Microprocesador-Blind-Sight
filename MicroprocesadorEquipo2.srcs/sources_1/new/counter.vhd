----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2025 04:57:54 PM
-- Design Name: 
-- Module Name: counter - Behavioral
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

entity counter is
generic (N: integer := 20);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           q : out  STD_LOGIC_VECTOR (N-1 downto 0));
end counter;

architecture Behavioral of counter is
signal tick: unsigned(N-1 downto 0);

begin

process (reset, clk) begin

	if reset = '1' then
		tick <= (others => '0');
	elsif clk'event and clk = '1' then
		if enable = '1' then
			tick <= tick + 1;
		end if;
	end if;
end process;

q <= std_logic_vector(tick);

end Behavioral;