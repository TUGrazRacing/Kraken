library ieee;
use ieee.std_logic_1164.all;
use work.SWDComponents.all;



entity SWDProtocolEngine is
    port(
        clk : in std_logic;
        reset : in std_logic;
        DbgToDvc : in std_logic; -- debugger to device date line
        DvcToDbg : in std_logic; -- device to debugger data line
        highz : out std_logic;
        direction_dbg_mux : out std_logic;
        direction_dvc_mux : out std_logic
    );
end entity;



architecture behaviour of SWDProtocolEngine is

signal hchighz, thchighz, fchighz : std_logic := '0';
signal t_hchighz, t_thchighz, t_fchighz : std_logic := '0';
signal data_out_r : std_logic := '0';

begin
    halfCycleHighZ : SWDHcH
    port map(
        clk       => clk,
        out_signal => hchighz,
        trigger    => t_hchighz
    );

    treeHalfCycleHighZ : SWDThcH
    port map(
        clk        => clk,
        out_signal => thchighz,
        trigger    => t_thchighz
    );

    risingEdgeSampler : SWDLineReader
    port map(
        clk      => clk,
        data_in  => DbgToDvc,
        data_out => data_out_r
    );

    StateMachine : SWDStateMachine
    port map(
        clk       => clk,
        reset     => reset,
        data_in_r => data_out_r,
        data_in_f => DvcToDbg,
        direction => direction,
        highz_hc  => t_hchighz,
        highz_thc => t_thchighz,
        highz     => t_fchighz
    );

    direction_dbg_mux <= direction;
    direction_dvc_mux <= not direction;
    highz <= hchighz or thchighz or fchighz;
end behaviour;