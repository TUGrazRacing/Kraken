library ieee;
use ieee.std_logic_1164.all;

package SWDComponents is

    component SWDStateMachine is
        port(
            clk : in std_logic;
            reset : in std_logic;  -- asynch reset
            data_in_r : in std_logic; -- data sampled on the rising edge
            data_in_f : in std_logic; -- data sampled on the falling edge
            direction : out std_logic; -- 0 = debugger to device; 1 = device to debugger
            highz_hc : out std_logic; -- control signal for the highz controller for a half cycle
            highz_thc : out std_logic; -- control signal for the highz controller for three half cycles
            highz : out std_logic -- direct control signal for highz
        );
    end component;

    component SWDDbgMux is
        port(
            pin : inout std_logic;
            toDevice : out std_logic;
            toDebugger : in std_logic;
            highz : in std_logic;
            direction : in std_logic -- 0 = debugger to device; 1 = device to debugger;
        );
    end component;

    component SWDDvcMux is
        generic(
            port_count : integer := 1;
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

    component SWDLineReader is
        port(
            clk : in std_logic;
            data_in : in std_logic;
            data_out : out std_logic
        );
    end component;

    component SWDHcH is
        port (
            clk         : in  std_logic;
            trigger     : in  std_logic;
            out_signal  : out std_logic
        );
    end component;

    component SWDThcH is
        port (
            clk         : in  std_logic;
            trigger     : in  std_logic;
            out_signal  : out std_logic
        );
    end component;

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