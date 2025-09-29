library ieee;
use ieee.std_logic_1164.all;


entity SWDDbgMux is
    port(
        pin : inout std_logic := 'Z';
        toDevice : out std_logic;
        toDebugger : in std_logic;
        highz : in std_logic;
        direction : in std_logic -- 0 = debugger to device; 1 = device to debugger;
    );
end entity;

architecture behaviour of SWDDbgMux is 
begin

toDevice <= pin;
pin <= toDebugger when (direction='1' and highz='0') else 'Z'; 

end behaviour;