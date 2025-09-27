library ieee;
use ieee.std_logic_1164.all;
use work.SWDComponents.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity Multiplexer_test is
end entity;








architecture behaviour of Multiplexer_test is


procedure host_linereset(signal pin : inout std_logic;
                         signal clk : in std_logic
                
) is
begin

for i in 0 to 50 loop
  wait until falling_edge(clk);
  pin <= '1';
end loop;

wait until falling_edge(clk);
pin <= '0';
wait until falling_edge(clk);
wait until falling_edge(clk);

end procedure;


procedure device_linereset(signal pin : inout std_logic;
                           signal clk : in std_logic;
                           signal reset : out std_logic
) is
begin
  for i in 0 to 49 loop
    wait until rising_edge(clk);
    if(pin /= '1') then
      return;
    end if;
  end loop;

  wait until rising_edge(clk) and pin = '0';
  wait until rising_edge(clk) and pin = '0';

  report "Line reset!";
  reset <= '1';
end procedure;



procedure host_write_request(signal pin : inout std_logic;
                     signal clk : in std_logic;
                     APnDP : in std_logic;
                     RnW : in std_logic;
                     reg : in std_logic_vector(1 downto 0);
                     parity : in std_logic
) is
begin
wait until falling_edge(clk); -- send start bit
pin <= '1';

wait until falling_edge(clk);
pin <= APnDP;

wait until falling_edge(clk);
pin <= RnW;

for i in 0 to 1 loop
  wait until falling_edge(clk);
  pin <= reg(i);
end loop;

wait until falling_edge(clk);
pin <= parity;

wait until falling_edge(clk); -- stop bit
pin <= '0';

wait until falling_edge(clk); -- park bit
pin <= '1';

wait until falling_edge(clk); -- release line
pin <= 'Z';

end procedure;


procedure host_write(signal pin : inout std_logic;
                     signal clk : in std_logic;
                     APnDP : in std_logic;
                     reg : in std_logic_vector(1 downto 0);
                     parity : in std_logic;
                     data : in std_logic_vector(31 downto 0) 
) is
  variable ack : std_logic_vector(2 downto 0);
begin

host_write_request(pin, clk, APnDP, '0', reg, parity);

for i in 0 to 2 loop   -- get ack from device
  wait until falling_edge(clk);
  ack(i) := pin;
end loop;

if(ack = "100" or ack = "010") then    -- return if ack is not OK
  wait until falling_edge(clk);
  wait until falling_edge(clk);
  pin <= '0';
  return;
elsif (ack /= "001") then
  return;
end if;

wait until falling_edge(clk);  -- trn period

for i in 0 to 31 loop   -- send data
  wait until falling_edge(clk);
  pin <= data(i);
end loop;

wait until falling_edge(clk);
pin <= '1';   -- send parity bit; not important for now!

wait until falling_edge(clk);   -- reset line
pin <= '0';

end procedure;


procedure host_read(signal pin : inout std_logic;
                     signal clk : in std_logic;
                     APnDP : in std_logic;
                     reg : in std_logic_vector(1 downto 0);
                     parity : in std_logic;
                     signal data : out std_logic_vector(31 downto 0) 
) is
  variable ack : std_logic_vector(2 downto 0);
begin

host_write_request(pin, clk, APnDP, '1', reg, parity);

for i in 0 to 2 loop   -- get ack from device
  wait until falling_edge(clk);
  ack(i) := pin;
end loop;

if(ack = "100" or ack = "010") then    -- return if ack is not OK
  wait until falling_edge(clk);
  wait until falling_edge(clk);
  pin <= '0';
  return;
elsif (ack /= "001") then
  return;
end if;


for i in 0 to 31 loop   -- send data
  wait until falling_edge(clk);
  data(i) <= pin;
end loop;

wait until falling_edge(clk);
wait until falling_edge(clk);   -- trn
wait until falling_edge(clk);   -- reset line
pin <= '0';

end procedure;


procedure device_react(signal pin : inout std_logic;
                       signal clk : in std_logic;
                       ack : in std_logic_vector(2 downto 0);
                       signal data : inout std_logic_vector(31 downto 0);
                       signal request : out std_logic_vector(2 downto 0)
) is
variable APnDP : std_logic;
variable RnW : std_logic;
variable reg : std_logic_vector(1 downto 0);
variable parity : std_logic;
begin
wait until (rising_edge(clk) and pin = '1');
wait until rising_edge(clk);
request(2) <= pin;
wait until rising_edge(clk);
RnW := pin;

for i in 0 to 1 loop
  wait until rising_edge(clk);
  request(i) <= pin;
end loop;

wait until rising_edge(clk);
parity := pin;

wait until rising_edge(clk);
if(pin /= '0') then -- stop bit error
  return;
end if;

wait until rising_edge(clk);
if (pin /= '1') then -- park bit error
  return;
end if;

for i in 0 to 2 loop
  wait until rising_edge(clk);
  pin <= ack(i);
end loop;

if(RnW = '1') then  -- host reads
  for i in 0 to 31 loop
    wait until rising_edge(clk);
    pin <= data(i);
  end loop;

  wait until rising_edge(clk);
  pin <= '1';   -- parity
  wait until rising_edge(clk);
  pin <= 'Z';
else   -- host writes
  wait until rising_edge(clk);
  pin <= 'Z';
  wait until rising_edge(clk);


  for i in 0 to 31 loop
    wait until rising_edge(clk);
    data(i) <= pin;
  end loop;

  wait until rising_edge(clk); -- parity
  
end if;


end procedure;





procedure test_cases(
    signal test_data_host : in std_logic_vector(31 downto 0);
    signal test_data_device : in std_logic_vector(31 downto 0);
    signal test_request_host : in std_logic_vector(2 downto 0);
    signal test_request_device : in std_logic_vector(2 downto 0)

) is
begin
  if(test_data_host /= test_data_device) then
    report "    - Data failed!" severity error;
  else
    report "    - Data passed!" severity note;
  end if;

  if(test_request_host /= test_request_device) then
    report "    - Request failed!" severity error;
  else
    report "    - Request passed!" severity note;
  end if;

end procedure;



signal test_pin : std_logic := 'Z';
signal test_data_host, test_data_device : std_logic_vector(31 downto 0);
signal test_request_host, test_request_device : std_logic_vector(2 downto 0);
signal read_comming : std_logic := '0';
signal line_reset : std_logic := '0';

signal clk, reset, dbgpin : std_logic := '0';
signal sel : std_logic_vector(0 downto 0);
signal dvcpin, clk_out, reset_out : std_logic_vector(0 downto 0);
signal DvcToDbg : std_logic := 'Z';


begin
clk <= not clk after 100 ns;


  tb : SWDMultiplexer
generic map(
  port_count => 1
)
port map(
DbgPin => dbgpin,
DvcPins => dvcpin,
clk_out => clk_out,
reset_out => reset_out,
clk_in => clk,
reset_in => reset,
sel => sel
);


sel(0) <= '0';

Host : process
begin

  host_linereset(test_pin, clk);

  wait until falling_edge(clk);
  test_request_host <= "001";  -- write test
  test_data_host <= "01100110100110011010101011110000";
  wait until falling_edge(clk);
  host_write(test_pin, clk, test_request_host(2), test_request_host(1 downto 0), '1', test_data_host);
  report "Write test finished:";
  test_cases(test_data_host, test_data_device, test_request_host, test_request_device);

  wait for 1000 ns;

  
  test_request_host <= "111";
  
  
  wait for 0 ns;
  host_read(test_pin, clk, test_request_host(2), test_request_host(1 downto 0), '1', test_data_host);
  wait until falling_edge(clk);
  report "Read test finished:";
  test_cases(test_data_host, test_data_device, test_request_host, test_request_device);




  wait for 500 ns;
  assert false report "Test finished!" severity failure;
  
end process;



Device : process
begin
  wait until rising_edge(clk);
  if(line_reset = '1') then
    device_react(test_pin, clk, "001", test_data_device, test_request_device);
  end if; 
--wait until rising_edge(clk);
--test_data_device <= "10100000010111110000000011111111";


end process;









Reset_detect : process
begin
  device_linereset(test_pin, clk, line_reset);
end process;









end behaviour;