library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;


--! @brief Serial Wire Dubug components
--! @details This package contains the necessary components to set up the SWDProtocolEngine for bidirectional multiplexing of the SWD protocol.
package SWDComponents is

    --! @brief Protocol engine state machine
    --! @param clk System clock
    --! @param reset System reset
    --! @param data_in_r Data sampled on the rising edge
    --! @param data_in_f Data sampled on the falling edge
    --! @param direction Direction control signal
    --! @param highz_hc Half cycle high impedance control signal
    --! @param highz_thc Three half cycle high impedance control signal
    --! @param highz Direct high impedance control signal
    component SWDStateMachine is
        port(
            clk : in std_logic;
            reset : in std_logic;  -- asynch reset
            data_in_r : in std_logic; -- data sampled on the rising edge
            data_in_f : in std_logic; -- data sampled on the falling edge
            direction : out std_logic; -- 0 = debugger to device; 1 = device to debugger
            highz : out std_logic -- direct control signal for highz
        );
    end component;

    --! @brief Demultiplexer on debugger side
    --! @param pin External pin
    --! @param toDevice Internal signal going to the device
    --! @param toDebugger Internal signal going to the debugger
    --! @param highz High impedance activation input signal
    --! @param direction Direction control input signal
    component SWDDbgMux is
        port(
            pin : inout std_logic;
            toDevice : out std_logic;
            toDebugger : in std_logic;
            highz : in std_logic;
            direction : in std_logic -- 0 = debugger to device; 1 = device to debugger;
        );
    end component;

    --! @brief Multiplexer on device side
    --! @param sel Device selection address
    --! @param toDebugger Internal signal going to the debugger
    --! @param toDevice Internal signal going to the device
    --! @param direction Direction control input signal
    --! @param highz High impedance activation input signal
    --! @param clk_in SWD clock signal input
    --! @param reset_in SWD reset signal input
    --! @param pin SWD data signal vector
    --! @param clk_out SWD clock signal output vector
    --! @param reset_out SWD reset signal output vector
    component SWDDvcMux is
        generic(
            port_count : integer := 1
        );
        port(
            sel : in std_logic_vector(integer(ceil(log2(real(port_count))))-1 downto 0); -- generate the correct number of select lines. Should be synthesizable!
            toDebugger : out std_logic;
            toDevice : in std_logic;
            direction : in std_logic;
            highz : in std_logic;
            clk_in : in std_logic;
            reset_in : in std_logic;
            pin : inout std_logic_vector(port_count-1 downto 0);
            clk_out : out std_logic_vector(port_count-1 downto 0);
            reset_out : out std_logic_vector(port_count-1 downto 0)
        );
    end component;

    --! @brief Samples the data line on the rising edge and buffers it
    --! @param clk SWD clock input
    --! @param data_in SWD data input line
    --! @param data_out Buffered output
    component SWDLineReader is
        port(
            clk : in std_logic;
            data_in : in std_logic;
            data_out : out std_logic
        );
    end component;

    --! @brief Generates an output signal of half a clock cycle starting from the next rising edge
    --! @param clk Input reference clock
    --! @param trigger Trigger signal
    --! @param out_signal Output signal
    component SWDHcH is
        port (
            clk         : in  std_logic;
            trigger     : in  std_logic;
            out_signal  : out std_logic
        );
    end component;

    --! @brief Generates an output signal of three half clock cycles starting from the next rising edge
    --! @param clk Input reference clock
    --! @param trigger Trigger signal
    --! @param out_signal Output signal 
    component SWDThcH is
        port (
            clk         : in  std_logic;
            trigger     : in  std_logic;
            out_signal  : out std_logic
        );
    end component;

    --! @brief SWD protocol engine responsible for correct bus driver switches
    --! @param clk SWD clock input
    --! @param reset SWD reset input
    --! @param DbgToDvc Internal signal going from debugger to device
    --! @param DvcToDbg Internal signal going from device to debugger
    --! @param highz High impedance activation signal output
    --! @param direction_dbg_mux Direction control signal for the debugger multiplexer
    --! @param direction_dvc_mux Direction control signal for the device multiplexer
    component SWDProtocolEngine is
        port(
            clk : in std_logic;
            reset : in std_logic;
            DbgToDvc : in std_logic; -- debugger to device date line
            DvcToDbg : in std_logic; -- device to debugger data line
            highz : out std_logic;
            direction_dbg_mux : out std_logic;
            direction_dvc_mux : out std_logic
        );
    end component;
end SWDComponents;