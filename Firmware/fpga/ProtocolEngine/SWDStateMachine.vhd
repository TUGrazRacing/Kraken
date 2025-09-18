library ieee;
use ieee.std_logic_1164.all;



entity SWDStateMachine is
    port(
        clk : in std_logic;
        reset : in std_logic;  -- asynch reset
        data_in_r : in std_logic; -- data sampled on the rising edge
        data_in_f : in std_logic; -- data sampled on the falling edge
        direction : out std_logic; -- 0 = debugger to device; 1 = device to debugger
        highz_hc : out std_logic; -- control signal for the highz controller for a half cycle
        highz_thc : out std_logic; -- control signal for the highz controller for three half cycles
        highz : out std_logic -- direct control signal for highz
    );
end entity;



architecture behaviour of SWDStateMachine is
type States_t is (IDLE, RW, ACK, RX, TX);
signal state : States_t := IDLE;
signal rw_counter : integer range 0 to 8 := 0;
signal RnW : std_logic := '0'; -- 0 = is write; 1 = is read;
signal ack_counter : integer range 0 to 2 := 0;
signal data_counter : integer range 0 to 33 := 0;



begin
    process(clk)
    variable ack_var : std_logic_vector(2 downto 0) := (others => '0');
    begin
        if(clk'event and clk='0') then
            case state is
                when IDLE =>
                    direction <= '0';
                    highz_hc <= '0';
                    highz_thc <= '0';
                    highz <= '0';

                    if(data_in_r='1') then
                        state <= RW;
                    end if;

                when RW =>
                    if(rw_counter < 5) then
                        rw_counter <= rw_counter + 1;
                    else
                        rw_counter <= 0;
                        state <= ACK;
                        direction <= '1';
                        highz_hc <= '0';
                    end if;

                    if(rw_counter = 1) then
                        RnW <= data_in_r;
                    end if;

                    if(rw_counter = 5 and not data_in_r='0') then
                        state <= IDLE;
                        rw_counter <= 0;
                    else
                        highz_hc <= '1';
                    end if;

                when ACK =>
                    ack_var(ack_counter) := data_in_f;

                    if(ack_counter < 2) then
                        ack_counter <= ack_counter + 1;
                    else
                        if(ack_var = "001") then
                            if(RnW = '1') then
                                state <= RX;
                            else
                                state <= TX;
                                highz_thc <= '1';
                            end if;
                        else
                            state <= IDLE;
                            highz_thc <= '1';
                        end if;

                        ack_var := (others => '0');
                        ack_counter <= 0;
                    end if;

                when RX =>
                    if(data_counter < 32) then
                        data_counter <= data_counter + 1;
                    else
                        data_counter <= 0;
                        state <= IDLE;
                        highz <= '1';
                    end if;

                when TX =>
                    highz_thc <= '0';
                    direction <= '0';

                    if(data_counter < 33) then
                        data_counter <= data_counter + 1;
                    else
                        data_counter <= 0;
                        state <= IDLE;
                    end if;
                        
                when others =>
                    state <= IDLE;
            end case;
                
        else
            if(reset='1') then
                state <= IDLE;
                rw_counter <= 0;
                ack_counter <= 0;
                data_counter <= 0;
            end if;
        end if;
    end process;
end behaviour;