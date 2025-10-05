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

signal highz_sig : std_logic := '0';
signal t_hchighz, t_thchighz, t_fchighz : std_logic := '0';
signal data_out_f : std_logic := '0';
signal direction : std_logic := '0';

signal rst, reset_sig : std_logic := '1';


begin

	 Linereset_detector : SWDRst
	 port map(
		rst => rst,
		clk => clk,
		data => DbgToDvc
	 );
    

    fallingEdgeSampler : SWDLineReader
    port map(
        clk      => clk,
        data_in  => DvcToDbg,
        data_out => data_out_f
    );

    StateMachine : SWDStateMachine
    port map(
        clk       => clk,
        reset     => reset_sig,
        data_in_r => DbgToDvc,
        data_in_f => data_out_f,
        direction => direction,
        highz     => highz_sig
    );
	 
	 reset_sig <= rst and reset;

    direction_dbg_mux <= direction;
    direction_dvc_mux <= not direction;
    highz <= highz_sig;
end behaviour;