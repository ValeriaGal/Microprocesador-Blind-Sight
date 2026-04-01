----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2025 04:54:39 PM
-- Design Name: 
-- Module Name: System_TOP - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.02 - Integración de Sensores, ALU y ACC
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- unidad principal, dentro de este componente se instancian el resto
-- y se conectan entre si para trabajar en conjunto
entity System_TOP is
    Port (
        clk   : in  std_logic;
        reset : in  std_logic;
        
        sim_echos_in    : in  STD_LOGIC_VECTOR(3 downto 0);
        sim_triggers_out : out STD_LOGIC_VECTOR(3 downto 0);
        
        -- Puertos de Debug (para ver en el testbench)
        o_pc_conteo  : out std_logic_vector(7 downto 0);
        o_mar_out    : out std_logic_vector(7 downto 0);
        o_gpr_instr  : out std_logic_vector(7 downto 0);
        o_gpr_data   : out std_logic_vector(7 downto 0);
        o_ret_out    : out std_logic_vector(7 downto 0);
        o_uc_state   : out std_logic_vector(1 downto 0); -- Debug de la FSM
        o_sens_data_out : out std_logic_vector (7 downto 0);
        
        o_RET_load_state   : out std_logic;
        o_pc_sc_load_state   : out std_logic;
        o_sc_sel_state   : out std_logic;
        
        -- Puertos de debug para ALU y ACC
        o_alu_out : out std_logic_vector(7 downto 0);
        o_acc_out : out std_logic_vector(7 downto 0);
        
        -- buzzer
        o_freq_sel : out std_logic_vector(1 downto 0);
        o_beep : out std_logic;
        -- motores
        o_vibra_outs : out std_logic_vector(3 downto 0);
        o_distance : out std_logic_vector(7 downto 0);
        o_motor_sel : out std_logic_vector(1 downto 0)
    );
end System_TOP;

architecture Behavioral of System_TOP is

    -- Declaración de todos los componentes
    component UnidadControl is
        Port(
            clk   : in  std_logic; reset : in  std_logic;
            instr : in  std_logic_vector (7 downto 0);
            mar_enable : out std_logic; gpr_enable : out std_logic;
            pc_enable     : out std_logic; pc_sc_load  : out std_logic;
            reg_sens_enable : out std_logic;
            RET_register_load : out std_logic; sc_sel : out std_logic;
            alu_sel   : out std_logic_vector(3 downto 0); 
            acc_pulse : out std_logic;
            acc_out : in std_logic_vector (7 downto 0);
            freq_sel : out std_logic_vector(1 downto 0);
            motor_write_enable_pulse : out std_logic -- puerto enable motores
        );
    end component;
    
    component Contador_PC is
        Port ( 
            clk : in STD_LOGIC; reset : in STD_LOGIC;
            pc_enable : in STD_LOGIC; pc_sc_load : in STD_LOGIC;
            sc : in STD_LOGIC_VECTOR (7 downto 0);
            conteo : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;
    
    component RegistroMAR is
        Port (
            clk : in std_logic; reset : in std_logic;
            mar_enable : in std_logic;
            mar_in  : in  std_logic_vector(7 downto 0); 
            direccion_out : out std_logic_vector(7 downto 0) 
        );
    end component;
    
    component RegistroGPR is
        Port (
            clk : in std_logic; reset : in std_logic;
            gpr_enable : in std_logic;
            gpr_in    : in  std_logic_vector(15 downto 0);
            data_out  : out std_logic_vector(7 downto 0); 
            instr_out : out std_logic_vector(7 downto 0) 
        );
    end component;

    component MemoriaROM is
        Port (
            bus_direcc : in  std_logic_vector(7 downto 0); 
            data_out   : out std_logic_vector(15 downto 0)
        );
    end component;
    
    component RegistroRET is
        Port ( 
            clk : in std_logic; reset : in std_logic;
            RET_register_load  : in  std_logic;
            direcc_in : in  std_logic_vector (7 downto 0);
            direcc_out: out std_logic_vector (7 downto 0)
        );
    end component;
    
    component RegistrosSensores is
        Port (
            clk      : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            echos_in     : in  STD_LOGIC_VECTOR(3 downto 0);
            triggers_out : out STD_LOGIC_VECTOR(3 downto 0);
            reg_enable : in std_logic;
            reg_address  : in  STD_LOGIC_VECTOR(7 downto 0);
            reg_data_out : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    
    component ALU is
        Port (
            clk: in std_logic;
            reset: in std_logic;
            enable: in std_logic;
            A: in std_logic_vector (7 downto 0);
            B: in std_logic_vector (7 downto 0);
            sens : in std_logic_vector (7 downto 0); -- entrada de registro Sensores
            OUTPUT: out std_logic_vector (7 downto 0);
            SEL: in std_logic_vector (3 downto 0) 
        );
    end component;
    
    component Acumulador is
        Port (
            clk : in std_logic; 
            reset : in std_logic;
            load_enable : in std_logic; -- se conecta al acc_pulse de la UC
            data_in : in std_logic_vector (7 downto 0);
            data_out : out std_logic_vector (7 downto 0)
        );
    end component;
    
    component Buzzer
    Port (
        clk : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        freq_sel : in std_logic_vector(1 downto 0); -- para valores del 0 al 3
        beep : buffer std_logic
    );
    end component;
    
    component Controlador_Vibradores is
        Port ( 
            clk           : in  std_logic;
            reset         : in  std_logic;
            write_enable  : in  std_logic;
            distance_in   : in  std_logic_vector(7 downto 0);
            motor_sel     : in  std_logic_vector(1 downto 0);
            vibra_outs    : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Señales de Control (Cables de la UC a los componentes)
    signal s_mar_load : std_logic;
    signal s_gpr_load : std_logic;
    signal s_pc_inc   : std_logic;
    signal s_pc_load  : std_logic;
    signal s_ret_load : std_logic;
    signal s_sc_sel   : std_logic;
    signal s_reg_enable : std_logic;
    
    signal s_alu_sel   : std_logic_vector(3 downto 0); 
    signal s_acc_pulse : std_logic;     

    -- Señales de Simulación de Sensores
    signal s_sim_echos    : std_logic_vector(3 downto 0);
    signal s_sim_triggers : std_logic_vector(3 downto 0);
    signal s_sens_data_out : std_logic_vector(7 downto 0); -- Salida de RegistrosSensores
    
    -- Señales del DataPath (Buses de datos)
    signal s_pc_conteo  : std_logic_vector(7 downto 0);
    signal s_mar_out    : std_logic_vector(7 downto 0);
    signal s_rom_out    : std_logic_vector(15 downto 0);
    signal s_gpr_instr  : std_logic_vector(7 downto 0);
    signal s_gpr_data   : std_logic_vector(7 downto 0);
    signal s_ret_out    : std_logic_vector(7 downto 0);
    signal s_pc_mux_in  : std_logic_vector(7 downto 0);
    
    signal s_alu_out : std_logic_vector(7 downto 0);
    signal s_acc_out : std_logic_vector(7 downto 0);
    
    -- buzzer
    signal s_freq_sel : std_logic_vector(1 downto 0);
    signal s_beep : std_logic;
    
    -- motores
    signal s_motor_write_pulse : std_logic;
    signal s_distance : std_logic_vector(7 downto 0);
    signal s_motor_sel         : std_logic_vector(1 downto 0);
    signal s_vibra_outs        : std_logic_vector(3 downto 0);
    
    
begin

    -- Instancia del Cerebro
    Inst_UC: UnidadControl
        port map (
            clk     => clk, 
            reset   => reset,
            instr   => s_gpr_instr,
            
            mar_enable => s_mar_load, 
            gpr_enable => s_gpr_load,
            pc_enable  => s_pc_inc,   
            pc_sc_load => s_pc_load,
            reg_sens_enable => s_reg_enable,
            RET_register_load => s_ret_load, 
            sc_sel     => s_sc_sel,
            
            alu_sel   => s_alu_sel,
            acc_pulse => s_acc_pulse,
            
            -- buzzer
            acc_out => s_acc_out,
            freq_sel => s_freq_sel,
            -- motores
            motor_write_enable_pulse => s_motor_write_pulse
        );

    -- Instancia del Contador de Programa (PC)
    Inst_PC: Contador_PC
        port map (
            clk        => clk, 
            reset      => reset,
            pc_enable  => s_pc_inc,
            pc_sc_load => s_pc_load,
            sc         => s_pc_mux_in,
            conteo     => s_pc_conteo
        );
        
    -- Instancia del Registro de Direcciones de Memoria (MAR)
    Inst_MAR: RegistroMAR
        port map (
            clk           => clk, 
            reset         => reset,
            mar_enable    => s_mar_load,
            mar_in        => s_pc_conteo, -- La MAR se carga desde el PC
            direccion_out => s_mar_out
        );
        
    -- Instancia del Registro de Instrucción/Datos (GPR)
    Inst_GPR: RegistroGPR
        port map (
            clk         => clk, 
            reset       => reset,
            gpr_enable  => s_gpr_load,
            gpr_in      => s_rom_out, -- El GPR se carga desde la ROM
            data_out    => s_gpr_data,
            instr_out   => s_gpr_instr
        );
        
    -- Instancia del Registro de Retorno (RET)
    Inst_RET: RegistroRET
        port map (
            clk               => clk, 
            reset             => reset,
            RET_register_load => s_ret_load,
            direcc_in         => s_pc_conteo, -- Guarda la dirección de retorno desde el PC
            direcc_out        => s_ret_out
        );
        
    -- Instancia de la Memoria (ROM)
    Inst_ROM: MemoriaROM
        port map (
            bus_direcc => s_mar_out, -- La ROM se direcciona con la MAR
            data_out   => s_rom_out
        );
        
    -- Instancia de los Registros de Sensores
    Inst_RegSens: RegistrosSensores
        port map (
            clk          => clk, 
            reset        => reset,
            -- Conexión a los puertos del TOP para simulación
            echos_in     => s_sim_echos,
            triggers_out => s_sim_triggers,
            -- Conexión al datapath del micro
            reg_enable   => s_reg_enable,
            reg_address  => s_gpr_data,      -- Controlado
            reg_data_out => s_sens_data_out -- Conectado a la ALU
        );
        
    -- Instancia de la ALU
    Inst_ALU: ALU
        port map (
            clk    => clk,
            reset  => reset,
            enable => '1',
            A      => s_gpr_data,    
            B      => s_acc_out,      
            sens   => s_sens_data_out, -- Entrada 'sens' viene de los sensores
            OUTPUT => s_alu_out,
            SEL    => s_alu_sel
        );
        
    -- Instancia del Acumulador
    Inst_ACC: Acumulador
        port map (
            clk      => clk, -- Se "activa" con el pulso de la UC
            reset    => reset,
            load_enable => s_acc_pulse,
            data_in  => s_alu_out,   -- La entrada viene de la salida de la ALU
            data_out => s_acc_out
        );
        
        -- Inst Buzzer
    Inst_BUZZER: Buzzer
        port map (
            clk => clk,
            reset => reset,
            enable => '1',
            freq_sel => s_freq_sel,
            beep => s_beep
        );
        
    -- Inst controlador vibradores
    Inst_Motores: Controlador_Vibradores
        port map (
            clk          => clk,
            reset        => reset,
            write_enable => s_motor_write_pulse, -- Pulso de la UC
            distance_in  => s_acc_out,           -- Distancia desde el Acumulador
            motor_sel    => s_motor_sel,         -- Selector desde el GPR
            vibra_outs   => s_vibra_outs
        );
        
    -- Lógica del DataPath
    
    -- señal para mandar selector de motores 2 bits, viene de gpr data 8 bits
    s_motor_sel <= s_gpr_data(1 downto 0);
    -- MUX para la entrada de carga del PC
    -- '0' = GPR (para CALL), '1' = RET (para RETURN)
    s_pc_mux_in <= s_gpr_data when s_sc_sel = '0' else s_ret_out;
                     
    -- Conexiones a los puertos de Simulación y Debug
    
    -- Pasa las señales de simulación hacia/desde los puertos del TOP
    s_sim_echos      <= sim_echos_in;
    sim_triggers_out <= s_sim_triggers;
    
    -- Conexiones a los puertos de Debug
    o_pc_conteo <= s_pc_conteo;
    o_mar_out   <= s_mar_out;
    o_gpr_instr <= s_gpr_instr;
    o_gpr_data  <= s_gpr_data;
    o_ret_out   <= s_ret_out;
    
    o_sens_data_out <= s_sens_data_out;
    
    -- debug UC
    o_RET_load_state   <= s_ret_load;
    o_pc_sc_load_state <= s_pc_load;
    o_sc_sel_state     <= s_sc_sel;
    
    -- debug ALU/ACC
    o_alu_out <= s_alu_out;
    o_acc_out <= s_acc_out;
    
    -- debug buzzer
    o_freq_sel <= s_freq_sel;
    o_beep <= s_beep;
    
    -- debug motores
    o_vibra_outs <= s_vibra_outs;
    o_motor_sel <= s_motor_sel;
    o_distance <= s_acc_out;
    
    -- (Debug de la FSM - requiere cambiar la FSM, omitido por simplicidad)
    o_uc_state <= "00"; 

end Behavioral;