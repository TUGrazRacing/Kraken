library ieee;
use ieee.std_logic_1164.all;

entity SWDRst is
    port(
        rst : out std_logic;
        clk : in std_logic;
        data : in std_logic
    );
end entity;



architecture behaviour of SWDRst is 
signal counter : integer range 0 to 50;
begin
    process(clk)
    begin
        if (clk'event and clk='1') then
            if(data='1') then
                if(counter < 50) then
                    counter <= counter + 1;
                else
                    rst <= '1';
                    counter <= 0;
                end if;
            else
                rst <= '0';
                counter <= 0;
            end if;
        end if;
    end process;
end behaviour;
