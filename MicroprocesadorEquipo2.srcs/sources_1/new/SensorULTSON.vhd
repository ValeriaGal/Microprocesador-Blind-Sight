----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2025 04:06:07 PM
-- Design Name: 
-- Module Name: SensorULTSON - Behavioral
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SensorULTSON is
    
    generic (n: integer := 20);
    
    Port ( 	  
        clk : in  STD_LOGIC;
        reset : in std_logic;
        echo : in  STD_LOGIC;
        Trigger : out  STD_LOGIC;
        distancia_out : out STD_LOGIC_VECTOR(7 downto 0); -- Salida de 8 bits
        data_ready_out: out STD_LOGIC  -- Pulso de 1 ciclo
    );
end SensorULTSON;

architecture Behavioral of SensorULTSON is 

    COMPONENT TriggerGen
        generic (n: integer :=20);
        PORT(
            clk : IN std_logic; 
            reset : IN std_logic;         
            trigger : OUT std_logic
        );
    END COMPONENT;
    
    COMPONENT counter
        generic (n: integer := 20);
        PORT(
            clk : IN std_logic;
            reset : IN std_logic;
            enable : IN std_logic;          
            q : OUT std_logic_vector(19 downto 0)
        );
    END COMPONENT;
        
    COMPONENT distance_calculation
        PORT(
            echo_count : IN std_logic_vector(19 downto 0);          
            distance : OUT std_logic_vector(8 downto 0)
        );
    END COMPONENT;
    
    signal Trigger_out: std_logic;
    signal echo_counter : STD_LOGIC_VECTOR (19 downto 0);
    signal echo_count : STD_LOGIC_VECTOR (19 downto 0);
    signal distance_bits : std_logic_vector(8 downto 0);

    -- Señales para el detector de flanco y el pulso
    signal data_ready_pulse : std_logic := '0';
    signal echo_prev        : std_logic := '0'; -- Para detectar el flanco
    signal counter_reset    : std_logic;

begin

    counter_reset <= reset OR Trigger_out;

    Inst_counter: counter 
        generic map (n => 20)
        PORT MAP(
        clk    => clk,
        reset  => counter_reset, -- El contador se resetea en cada disparo
        enable => echo,         -- El contador avanza mientras 'echo' es '1'
        q => echo_counter
    );
    
    Inst_TriggerGen: TriggerGen 
        generic map (n => 20)
        PORT MAP(       
            clk => clk,
            reset => reset,
            trigger => Trigger_out 
	       );
	
	Inst_distance_calculation: distance_calculation PORT MAP(
		echo_count => echo_count,
		distance => distance_bits 
	);
	
	Trigger <= Trigger_out;
	data_ready_out <= data_ready_pulse;
	
	distancia_out <= distance_bits(7 downto 0);
	
	
	
	process(clk) 
	begin
		if rising_edge(clk) then
			echo_prev <= echo;
                
			if (echo_prev = '1') AND  (echo = '0') then
			     echo_count <= echo_counter;
			     data_ready_pulse <= '1';
            elsif data_ready_pulse = '1' then
                data_ready_pulse <= '0';
            end if;
            
            if reset = '1' then
                echo_count       <= (others => '0');
                data_ready_pulse <= '0';
                echo_prev        <= '0';
            end if;
            
		end if;
	end process;
end Behavioral;