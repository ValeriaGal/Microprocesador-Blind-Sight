----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2025 11:15:44 AM
-- Design Name: 
-- Module Name: UnidadControl - Behavioral
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

-- controla de donde vienen las senales, que se activara y que se desactivara
entity UnidadControl is
    Port(
        instr : in std_logic_vector (7 downto 0); -- entrada de switch para instruccion a ejecutar
        reset : in std_logic;
        clk : in std_logic;
        
        -- salidas FSM
        -- la UC es el cerebro del micro, de este depende si las salidas cambian 
        -- independientemente del reloj del sistema
        pc_enable : out std_logic;
        mar_enable : out std_logic;
        gpr_enable : out std_logic;
        reg_sens_enable : out std_logic;      
        
        alu_sel : out std_logic_vector (3 downto 0); -- seleccion de salida de la ALU
        acc_pulse : out std_logic; -- pulso para cargar ACC
        
        -- El PC y el registro RET se conectan *directamente*
        -- La salida de PC le manda al registro RET la direccion actual + 1
        -- El registro RET se manda a un multiplexor cuya salida se conecta al puerto sc de la PC
        -- la otra entrada del multiplexor viene directamente de la salida de datos del GPR
        -- sc_sel determina cual de las dos entradas del multiplexor entrara en sc
        sc_sel : out std_logic; 
        pc_sc_load : out std_logic; -- activar sobrecarga de PC
        RET_register_load : out std_logic; -- carga el registro que guarda la direccion a regresar
        
        -- buzzer
        acc_out : in std_logic_vector (7 downto 0);
        freq_sel : out std_logic_vector(1 downto 0);
        
        -- motores
        motor_write_enable_pulse : out std_logic
    );
end UnidadControl;
    
architecture Behavioral of UnidadControl is
    -- define en que estado se encuentra el ciclo del micro
    type t_state is (
        FETCH_1,  -- Pulso 1: PC->MAR, PC++
        FETCH_2, -- Pulso 2: ROM->GPR/IR, PC->MAR, PC++
        EXECUTE               -- Pulso 3: Decodificar y Ejecutar
    );
    signal current_state : t_state := FETCH_1;
    signal s_freq_sel_next : std_logic_vector(1 downto 0);
    
begin
    
    -- determina el paso en el va el micro
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= FETCH_1;
        elsif rising_edge(clk) then
        
            -- Lógica de transición de estados
            case current_state is
            
                when FETCH_1 =>
                    current_state <= FETCH_2;
                    
                when FETCH_2 =>
                    current_state <= EXECUTE;
                    
                when EXECUTE =>
                    -- Después de ejecutar, SIEMPRE volvemos al inicio
                    current_state <= FETCH_1;
                    
            end case;
        end if;
    end process;
    
    -- Proceso de "Memoria" del Buzzer
    process(clk, reset)
    begin
        if reset = '1' then
            freq_sel <= "00"; -- Apagado al reset
        elsif rising_edge(clk) then
            if current_state = EXECUTE and instr = "00001100" then -- 0C = WRITEB
                freq_sel <= s_freq_sel_next;
            end if;
        end if;
    end process;
    
    process(instr, current_state)
        variable v_instr : unsigned(7 downto 0);
    begin
        v_instr := unsigned(instr);
    
        -- valores por defecto
        pc_enable <= '0';
        mar_enable <= '0';
        gpr_enable <= '0';
        reg_sens_enable <= '0';
        alu_sel <= "0000";
        acc_pulse <= '0';
        sc_sel <= '0'; -- El MUX del PC selecciona GPR por defecto
        pc_sc_load <= '0'; -- El PC se incrementará (si enable='1')
        RET_register_load <= '0';
        motor_write_enable_pulse <= '0';
        
        case current_state is
        
            when FETCH_1 => -- Pulso 1
                mar_enable <= '1';      -- Carga la MAR desde el PC
                pc_enable <= '1'; -- Incrementa el PC
                
            when FETCH_2 => -- Pulso 2
                gpr_enable <= '1';   -- Carga el GPR (desde ROM[MAR_vieja])
                
                
            when EXECUTE => -- Pulso 3
                -- Ahora, decodificamos la instrucción
                case v_instr is
                
                    when "00000001" => -- Suma Aritmetica
                        alu_sel   <= "0001"; -- selecciona la salida de la suma en la ALU
                        acc_pulse <= '1'; -- habilita la entrada al acumulador para el siguiente pulso
                   
                   
                    when "00000010" => -- Resta Aritmetica (gpr_data - acc)
                        alu_sel   <= "0010"; -- selecciona la salida de la resta en la ALU
                        acc_pulse <= '1'; -- habilita la entrada al acumulador para el siguiente pulso
                    
                    when "00000011" => -- AND
                        alu_sel   <= "0011"; -- selecciona la salida de AND en la ALU
                        acc_pulse <= '1'; -- habilita la entrada al acumulador para el siguiente pulso
                
                    when "00001001" => -- CALL
                        RET_register_load <= '1'; -- Guarda MAR (que tiene PC_de_retorno)
                        pc_sc_load    <= '1'; -- Carga PC con la dirección del GPR
                        sc_sel            <= '0'; -- MUX selecciona GPR
                        
                    when "00001010" => -- RET
                        -- Cargar PC con la dirección guardada en RET
                        sc_sel <= '1';  -- MUX selecciona RET
                        pc_sc_load <= '1';
                        
                    when "00001011" => -- READS
                        reg_sens_enable <= '1';
                        alu_sel   <= "0100";
                        acc_pulse <= '1';
                        
                    when "00001100" => -- WRITEB - para calcular la freq_sel y guardarla en acc                   
                        alu_sel   <= "0110"; -- usa ALU op 0110 (lee de salid ACC)
                        acc_pulse <= '1'; -- guarda el resultado (0,1,2 o 3) en ACC
                                                
                    when "00001111" => -- SETB (x0F) -- prender buzzer
                        -- lee el ACC (que tiene 0,1,2,o 3)
                        -- y lo envía al registro del buzzer
                        s_freq_sel_next <= acc_out(1 downto 0);
                    
                    when "00001110" => -- CALC_DIS (x0E) -- calcular la distancia invertida
                        alu_sel   <= "0101"; 
                        acc_pulse <= '1'; -- Carga el resultado (intensidad) en ACC 
                        
                    when "00001101" => -- WRITEM (x0D) -- prender el motor
                        motor_write_enable_pulse <= '1';
                        
                    when others => -- NOP, ADD, SUB, etc.
                        -- No hacemos NADA. El PC y la MAR ya están listos
                        -- para el siguiente ciclo de FETCH_1
                        null;
                
                end case;
        end case;      
    end process;
    
end Behavioral;
