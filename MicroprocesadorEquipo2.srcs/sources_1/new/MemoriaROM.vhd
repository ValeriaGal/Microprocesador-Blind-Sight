----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2025 11:15:44 AM
-- Design Name: 
-- Module Name: MemoriaROM - Behavioral
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

entity MemoriaROM is
    Port (
        bus_direcc      : in  std_logic_vector(7 downto 0); 
        -- w_r             : in  std_logic; -- 1 para read 0 para write  
        -- enable          : in  std_logic;                   
        -- data_in         : in  std_logic_vector(7 downto 0); 
        data_out        : out std_logic_vector(15 downto 0)
    );
end MemoriaROM;

architecture Behavioral of MemoriaROM is

    type mem_array is array (0 to 255) of std_logic_vector(15 downto 0); -- matriz de memoria ROM
    constant mem : mem_array := (
        1 => x"0950", -- 00001001 (CALL) | 01010000 (80) 80
        2 => x"0957", -- 00001001 (CALL) | 01010101 (85) 87
        3 => x"095C", -- 00001001 (CALL) | 01011001 (89) 92
        4 => x"0961", -- 00001001 (CALL) | 01010000 (93) 97
        5 => x"0900", -- 00001001 (CALL) | 00000000 (0) 0
        
        80 => x"0B00", -- 00001011 (READS) | 00000000 (0) (lee sensor 0)
        81 => x"0C00", -- 00001100 (WRITEB)| 00000000 (0) (escribe buzzer 0) 
        82 => x"0F00", -- 00001111 (SETB)  | 00000000 (0) (escribe buzzer 0)
        83 => x"0E00", -- 00001110 (CALC_DIS) | 00000000 (0) (calcula distancia invertida)
        84 => x"0D00", -- 00001101 (WRITEM) | 00000000 (0) (excribe motor 0) 
        85 => x"0A00", -- 00001010 (RET) | 00000000 (0) (dato ignorado)
        
        87 => x"0B01", -- 00001011 (READS) | 00000001 (1) (lee sensor 1)
        88 => x"0E01", -- 00001110 (CALC_DIS) | 00000001 (1) (calcula distancia invertida)
        89 => x"0D01", -- 00001101 (WRITEM) | 00000001 (1) (excribe motor 1) 
        90 => x"0A00", -- 00001010 (RET) | 00000000 (0) (dato ignorado)
        
        92 => x"0B02", -- 00001011 (READS) | 00000010 (2) (lee sensor 2)
        93 => x"0E02", -- 00001110 (CALC_DIS) | 00000010 (2) (calcula distancia invertida)
        94 => x"0D02", -- 00001101 (WRITEM) | 00000010 (2) (excribe motor 2) 
        95 => x"0A00", -- 00001010 (RET) | 00000000 (0) (dato ignorado)
        
        97 => x"0B03", -- 00001011 (READS) | 00000011 (3) (lee sensor 3)
        98 => x"0E03", -- 00001110 (CALC_DIS) | 00000011 (3) (calcula distancia invertida)
        99 => x"0D03", -- 00001101 (WRITEM) | 00000011 (3) (excribe motor 3) 
        100 => x"0A00", -- 00001010 (RET) | 00000000 (0) (dato ignorado)
        
        -- Rellena todo lo demás con NOP (00000000 00000000)
        others => x"0000"
    );

    
    signal direcc_int : integer range 0 to 255;
begin
    direcc_int <= TO_INTEGER(unsigned(bus_direcc));
    data_out <= mem(direcc_int);
    --data_out <= mem(direcc_int) when enable = '1' else (others => 'Z');
    
--    process(bus_direcc, w_r, data_in, enable)
--    begin        
--        if enable = '1' then
--                data_out <= mem(direcc_int);
--            else
--                mem(direcc_int)(7 downto 0) <= data_in;
--            end if;
--        end if;
--    end process;
end Behavioral;