library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.SWDComponents.all;


entity hardware_mux_test is
port (
	rst_mux : in std_logic := '1';
	clk_in : in std_logic := '0';
	reset_in : in std_logic := '1';
	DbgPin : inout std_logic := 'Z';
	DvcPins : inout std_logic_vector(0 downto 0) := (others => 'Z');
	clk_out : out std_logic_vector(0 downto 0) := (others => 'Z');
	reset_out : out std_logic_vector(0 downto 0) := (others => 'Z')
);
end entity;





architecture behaviour of hardware_mux_test is

signal sel : std_logic_vector(0 downto 0) := "0";
signal reset : std_logic := '1';
signal DbgToDvc, DvcToDbg, highz, direction_dbg_mux, direction_dvc_mux : std_logic;


constant port_count : integer := 1;

begin

reset <= rst_mux and reset_in;


 


DvcToDbg <= DvcPins(to_integer(unsigned(sel)));
DbgToDvc <= DbgPin;

DbgPin <= DvcToDbg when (direction_dbg_mux='1' and highz='0') else 'Z';

DeviceMultiplexer : process(sel, DbgToDvc, clk_in, reset_in, highz, direction_dvc_mux)
begin
    DvcPins <= (others => 'Z');
    clk_out <= (others => 'Z');
    reset_out <= (others => 'Z');

    clk_out(to_integer(unsigned(sel))) <= clk_in;
    reset_out(to_integer(unsigned(sel))) <= reset_in;

    if(highz = '0' and to_integer(unsigned(sel)) < port_count and direction_dvc_mux = '1') then
        DvcPins(to_integer(unsigned(sel))) <= DbgToDvc; 
    end if;
end process;



ProtocolEngine : SWDProtocolEngine
port map(
	clk => clk_in,
	reset => reset,
	DbgToDvc => DbgToDvc,
	DvcToDbg => DvcToDbg,
	highz => highz,
	direction_dbg_mux => direction_dbg_mux,
	direction_dvc_mux => direction_dvc_mux
);












end behaviour;