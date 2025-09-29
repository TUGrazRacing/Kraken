library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity SWDStateMachine is
    port(
        clk : in std_logic;
        reset : in std_logic;  -- asynch reset
        data_in_r : in std_logic; -- data sampled on the rising edge
        data_in_f : in std_logic; -- data sampled on the falling edge
        direction : out std_logic := '0'; -- 0 = debugger to device; 1 = device to debugger
        highz : out std_logic -- direct control signal for highz
    );
end entity;



architecture behaviour of SWDStateMachine is
type States_t is (IDLE, RW, ACK, RX, TX, TRN);
signal state : States_t := IDLE;
signal state_after_trn : States_t := IDLE;
signal rw_counter : integer range 0 to 8 := 0;
signal RnW : std_logic := '0'; -- 0 = is write; 1 = is read;
signal ack_counter : integer range 0 to 2 := 0;
signal data_counter : integer range 0 to 33 := 0;
signal trn_counter : integer range 0 to 3 := 0;
signal trn_period : std_logic_vector(1 downto 0) := "00";
signal direction_sig : std_logic := '0';
signal parity : std_logic := '0';
signal protocol_error : std_logic := '0';
signal addr : std_logic_vector(1 downto 0) := "00";
signal isDP : std_logic := '0';
signal isSel : std_logic := '0';
signal isReg : std_logic := '0';
signal sel_reg : std_logic := '0';
signal orundetect : std_logic := '0';


procedure start_trn(
    signal state : out States_t;
    signal state_after_trn : out States_t;
    constant after_trn : in States_t;
    signal highz : out std_logic;
    signal direction_sig : inout std_logic;
    signal trn_counter : out integer range 0 to 3
) is
begin
state <= TRN;
state_after_trn <= after_trn;
trn_counter <= 1;
highz <= '1';
direction_sig <= not direction_sig;
end procedure;




begin
    process(clk)
    variable ack_var : std_logic_vector(2 downto 0) := (others => '0');
    begin
        if(clk'event and clk='1') then
            case state is
                when IDLE =>
                    direction_sig <= '0';
                    highz <= '0';
                    parity <= '0';
                    protocol_error <= '0';

                    if(data_in_r='1') then  -- detect start bit HIGH
                        state <= RW;
                    end if;

                when RW =>
                    if(rw_counter < 6) then
                        rw_counter <= rw_counter + 1;
                        if(data_in_r = '1') then -- calc parity
                            parity <= not parity;
                        end if;
                    else

                        isSel <= '0';
                        isReg <= '0';
            
                        if(isDP = '1' and addr = "01") then
                            isReg <= '1';
                        elsif(isDP = '1' and addr = "10") then
                            isSel <= '1';
                        end if;

                        if(data_in_r /= '1' or protocol_error = '1') then     -- check park bit error and other protocol errors 
                            state <= IDLE;
                        else
                            start_trn(state, state_after_trn, ACK, highz, direction_sig, trn_counter);  -- pre ack trn
                        end if;
                        rw_counter <= 0;
                    end if;

                    if(rw_counter = 1) then -- set RnW flag
                        RnW <= data_in_r;
                    end if;

                    if(rw_counter = 4 and data_in_r /= parity) then -- check parity error
                        protocol_error <= '1';
                    end if;

                    if(rw_counter = 5 and data_in_r/='0') then -- check end bit error
                        protocol_error <= '1';
                    end if;

                    if(rw_counter = 0) then
                        isDP <= not data_in_r;
                    end if;

                    if(isDP = '1') then
                        if(rw_counter = 2) then
                            addr(0) <= data_in_r;
                        elsif(rw_counter = 3) then
                            addr(1) <= data_in_r;
                        end if;
                    end if;




                    

                when ACK =>
                    ack_var(ack_counter) := data_in_f;   -- sample ack bits

                    if(ack_counter < 2) then
                        ack_counter <= ack_counter + 1;
                    else
                        if(ack_var = "001" or (orundetect = '1' and (ack_var = "010" or ack_var = "100"))) then   -- check if ack == OK
                            if(RnW = '1') then -- check read or write request
                                state <= RX;  -- transition to RX
                            else
                                start_trn(state, state_after_trn, TX, highz, direction_sig, trn_counter);   -- trn and TX
                            end if;
                        else
                           start_trn(state, state_after_trn, IDLE, highz, direction_sig, trn_counter);    -- trn and IDLE
                        end if;

                        ack_var := (others => '0');     -- reset ack variables
                        ack_counter <= 0;
                    end if;

                when RX =>
                    if(data_counter < 32) then    -- wait for all data bits and parity
                        data_counter <= data_counter + 1;
                    else
                        data_counter <= 0;
                        start_trn(state, state_after_trn, IDLE, highz, direction_sig, trn_counter);  -- trn and IDLE
                    end if;

                when TX =>
                    if(data_counter < 32) then  -- wait for all data bits and parity
                        data_counter <= data_counter + 1;
                    else
                        data_counter <= 0;
                        state <= IDLE;  -- transition to IDLE
                    end if;

                    if(isSel = '1' and data_counter = 0) then   -- get the selected register
                        sel_reg <= data_in_r;
                    end if;

                    if(isReg = '1' and sel_reg = '1') then    -- get the turnaround period 
                        if(data_counter = 8) then
                            trn_period(0) <= data_in_r;
                        elsif(data_counter = 9) then
                            trn_period(1) <= data_in_r;
                        end if;
                    end if;


                    if(isReg = '1' and sel_reg = '0') then
                        if(data_counter = 0) then
                            orundetect <= data_in_r;
                        end if;
                    end if;








                when TRN =>   -- variable length TrN period | start with procedure start_trn on highz starting edge
                    if(trn_counter < to_integer(unsigned(trn_period)) + 1) then
                        trn_counter <= trn_counter + 1;
                    else
                        state <= state_after_trn;
                        trn_counter <= 0;
                        highz <= '0';
                    end if;
                        
                when others =>
                    state <= IDLE;
            end case;
                
        else
            if(reset='1') then       -- asynch reset
                state <= IDLE;
                rw_counter <= 0;
                ack_counter <= 0;
                data_counter <= 0;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if(clk'event and clk='0') then         -- buffer direction signal to pin on the falling edge to avoid bus contention in TRN
            direction <= direction_sig;
        end if;
    end process;


end behaviour;