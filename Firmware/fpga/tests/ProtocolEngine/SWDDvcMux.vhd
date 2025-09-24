library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;


entity SWDDvcMux is
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
end entity;


architecture behaviour of SWDDvcMux is
begin
toDebugger <= pin(to_integer(unsigned(sel)));

process(sel, toDevice, clk_in, reset_in)
begin
    pin <= (others => 'Z');
    clk_out <= (others => 'Z');
    reset_out <= (others => 'Z');

    if(highz = '0') then
        clk_out(to_integer(unsigned(sel))) <= clk_in;
        pin(to_integer(unsigned(sel))) <= toDevice;
        reset_out(to_integer(unsigned(sel))) <= reset_in;
    end if;
end process;


end behaviour;