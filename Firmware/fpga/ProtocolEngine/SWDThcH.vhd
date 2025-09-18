library ieee;
use ieee.std_logic_1164.all;

entity SWDTchH is
    port (
        clk        : in  std_logic;
        trigger    : in  std_logic;
        out_signal : out std_logic
    );
end entity;

architecture rtl of SWDTchH is
    signal trigger_prev : std_logic := '0';

    signal half_cycle_1 : std_logic := '0';
    signal half_cycle_2 : std_logic := '0';
    signal half_cycle_3 : std_logic := '0';

    signal pulse_active_r : std_logic := '0';
    signal pulse_active_f : std_logic := '1';
begin

    -- Rising edge process: start pulse and control half cycles 1 and 3
    process(clk)
    begin
        if rising_edge(clk) then
            trigger_prev <= trigger;

            if (trigger = '1' and trigger_prev = '0') then
                pulse_active_r <= '1';
                half_cycle_1 <= '1';
            end if;

            if pulse_active_r = '1' then
                half_cycle_3 <= half_cycle_2;
            end if;

            if(pulse_active_f = '0') then
                half_cycle_1 <= '0';
                half_cycle_3 <= '0';
                pulse_active_r <= '0';
            end if;
        end if;
    end process;

    -- Falling edge process: control half cycle 2
    process(clk)
    begin
        if falling_edge(clk) then
            if pulse_active_r = '1' then
                half_cycle_2 <= half_cycle_1;
                pulse_active_f <= not half_cycle_3;
            else
                half_cycle_2 <= '0';
                pulse_active_f <= '1';
            end if;
        end if;
    end process;

    -- Output is high if any half cycle is active
    out_signal <= pulse_active_r and pulse_active_f;

end architecture;
