library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use work.SWDComponents.all;





entity SWDMultiplexer is
    generic(
        port_count : integer := 1
    );
    port(
        DbgPin : inout std_logic := 'Z';
        DvcPins : inout std_logic_vector(port_count-1 downto 0) := (others => 'Z');
        clk_out : out std_logic_vector(port_count-1 downto 0);
        reset_out : out std_logic_vector(port_count-1 downto 0);
        clk_in : in std_logic;
        reset_in : in std_logic;
        sel : in std_logic_vector(log2ceil_safe(port_count)-1 downto 0) -- generate the correct number of select lines. Should be synthesizable!
    );
end entity;




architecture behaviour of SWDMultiplexer is

signal toDebugger, toDevice : std_logic := '0';
signal dir_dvc, dir_dbg : std_logic;
signal highz : std_logic := '1';
signal linereset : std_logic := '0';
signal reset : std_logic := '0';

begin

reset <= linereset or reset_in;


devicemux : SWDDvcMux
generic map(
    port_count => port_count
)
port map(
    sel => sel,
    toDebugger => toDebugger,
    toDevice => toDevice,
    direction => dir_dvc,
    highz => highz,
    clk_in => clk_in,
    reset_in => reset_in,
    pin => DvcPins,
    clk_out => clk_out,
    reset_out => reset_out
);

debuggermux : SWDDbgMux
port map(
    pin => DbgPin,
    toDevice => toDevice,
    toDebugger => toDebugger,
    highz => highz,
    direction => dir_dbg
);

protocolengine : SWDProtocolEngine
port map(
    clk => clk_in,
    reset => reset,
    DbgToDvc => toDevice,
    DvcToDbg => toDebugger,
    highz => highz,
    direction_dbg_mux => dir_dbg,
    direction_dvc_mux => dir_dvc
);

reset_dectector : SWDRst
port map(
    rst => linereset,
    clk => clk_in,
    data => toDevice
);






end behaviour;