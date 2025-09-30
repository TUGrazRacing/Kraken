library ieee;
use ieee.std_logic_1164.all;

entity SWDHcH is
    port (
        clk         : in  std_logic;
        trigger     : in  std_logic;
        out_signal  : out std_logic
    );
end entity;

architecture rtl of SWDHcH is
    signal trigger_prev   : std_logic := '0';
    signal pulse_rise     : std_logic := '0';
    signal pulse_fall     : std_logic := '0';
begin

    -- Rising edge process: detect trigger rising edge and start pulse
    process(clk)
    begin
        if falling_edge(clk) then
            if (trigger = '1' and trigger_prev = '0') then
                pulse_rise <= '1';
            end if;

            if (pulse_fall='1') then 
	            pulse_rise <= '0';
            end if;

            trigger_prev <= trigger;
        end if;
    end process;

    -- Falling edge process: used for ending the half-cycle or full-cycle pulse
    process(clk)
    begin
        if rising_edge(clk) then
            if (pulse_rise = '1') then
                pulse_fall <= '1';
            else
                pulse_fall <= '0';  -- Reset fall flag
            end if;
        end if;
    end process;

    -- Output signal is high only while pulse is active
    out_signal <= '1' when (pulse_rise = '1' and pulse_fall = '0') else '0';

end architecture;
