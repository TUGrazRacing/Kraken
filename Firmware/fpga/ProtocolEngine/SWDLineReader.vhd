library ieee;
use ieee.std_logic_1164.all;


entity SWDLineReader is
    port(
        clk : in std_logic;
        data_in : in std_logic;
        data_out : out std_logic
    );
end entity;



architecture behaviour of SWDLineReader is
begin
    process(clk)
    begin
        if(clk'event and clk='1') then
            data_out <= data_in;
        end if;
    end process;
end behaviour;