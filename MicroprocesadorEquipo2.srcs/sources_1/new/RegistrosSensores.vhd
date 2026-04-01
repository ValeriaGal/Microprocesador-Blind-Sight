----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/14/2025 01:26:05 PM
-- Design Name: 
-- Module Name: RegistrosSensores - Behavioral
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

-- Modulo compuesto de 4 registros, uno para cada sensor
-- Implementa un multiplexor para darle al microprocesador los valores del sensor que quiera
entity RegistrosSensores is
    Port (
        clk     : in  STD_LOGIC;
        reset   : in  STD_LOGIC;
        echos_in     : in  STD_LOGIC_VECTOR(3 downto 0); -- 4 pines de Echo
        triggers_out : out STD_LOGIC_VECTOR(3 downto 0); -- 4 pines de Trigger
        reg_enable : in std_logic;
        reg_address  : in  STD_LOGIC_VECTOR(7 downto 0); -- 8 bits de entrada (solo usara 2 para 4 sensores)
        reg_data_out : out STD_LOGIC_VECTOR(7 downto 0) -- valor del sensor elegido
    );
end entity;

architecture Behavioral of RegistrosSensores is

    component SensorULTSON is
        Port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            echo     : in  STD_LOGIC;
            trigger : out STD_LOGIC;
            distancia_out   : out STD_LOGIC_VECTOR(7 downto 0);
            data_ready_out  : out STD_LOGIC
        );
    end component;

    -- se instancian 4 registros itnernos, uno para cada sensor
    type t_register_bank is array (0 to 3) of STD_LOGIC_VECTOR(7 downto 0); 
    signal sensor_data_regs : t_register_bank := (others => (others => '0'));

    -- Señales intermedias para conectar todo
    signal s_distancias   : t_register_bank;
    signal s_data_readys  : STD_LOGIC_VECTOR(3 downto 0);
    signal s_address_comb : INTEGER range 0 to 255; 

begin

    -- se instancias 4 controladores diferentes
    G_Sensor_Instances : for i in 0 to 3 generate
    begin
        Sensor_Inst : SensorULTSON
            port map (
                clk         => clk,
                reset       => reset,
                echo     => echos_in(i),
                trigger => triggers_out(i),
                distancia_out   => s_distancias(i),
                data_ready_out  => s_data_readys(i)
            );
    end generate G_Sensor_Instances;


    -- actualiza el registro interno cuando su sensor tiene un dato nuevo
    process(clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                sensor_data_regs <= (others => (others => '0'));
            else
                for i in 0 to 3 loop
                    if s_data_readys(i) = '1' then
                        sensor_data_regs(i) <= s_distancias(i);
                    end if;
                end loop;
            end if;
        end if;
    end process;

    s_address_comb <= to_integer(unsigned(reg_address(1 downto 0)));
    
    process(s_address_comb, sensor_data_regs) 
    begin
        case s_address_comb is
            when 0 =>
                reg_data_out <= sensor_data_regs(0);
            when 1 =>
                reg_data_out <= sensor_data_regs(1);
            when 2 =>
                reg_data_out <= sensor_data_regs(2);
            when 3 =>
                reg_data_out <= sensor_data_regs(3);
            when others =>
                reg_data_out <= (others => '0');
        end case;
    end process;

end Behavioral;