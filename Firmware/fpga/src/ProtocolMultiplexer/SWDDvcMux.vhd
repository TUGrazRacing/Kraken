library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use work.SWDComponents.all;


entity SWDDvcMux is
    generic(
        port_count : integer := 1
    );
    port(
        sel : in std_logic_vector(log2ceil_safe(port_count)-1 downto 0); -- generate the correct number of select lines. Should be synthesizable!
        toDebugger : out std_logic;
        toDevice : in std_logic;
        direction : in std_logic;
        highz : in std_logic;
        clk_in : in std_logic;
        reset_in : in std_logic;
        pin : inout std_logic_vector(port_count-1 downto 0) := (others => 'Z');
        clk_out : out std_logic_vector(port_count-1 downto 0);
        reset_out : out std_logic_vector(port_count-1 downto 0)
    );
end entity;


architecture behaviour of SWDDvcMux is


begin
toDebugger <= pin(to_integer(unsigned(sel)));

process(sel, toDevice, clk_in, reset_in, highz, direction)
begin
    pin <= (others => 'Z');
    clk_out <= (others => 'Z');
    reset_out <= (others => 'Z');

    clk_out(to_integer(unsigned(sel))) <= clk_in;
    reset_out(to_integer(unsigned(sel))) <= reset_in;

    if(highz = '0' and to_integer(unsigned(sel)) < port_count and direction = '1') then
        pin(to_integer(unsigned(sel))) <= toDevice; 
    end if;
end process;




end behaviour;