library ieee;
use ieee.std_logic_1164.all;
use work.SWDComponents.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity Multiplexer_test is
end entity;








architecture behaviour of Multiplexer_test is


procedure swd_write_bit(signal swclk : in std_logic;
                        signal swdio : out std_logic;
                        bitval        : in std_logic) is
begin
  wait until falling_edge(swclk);
  swdio <= bitval;
end procedure;

-- Write a vector (LSB first) onto SWD
procedure swd_write_vector(signal swclk : in std_logic;
                           signal swdio : out std_logic;
                           data         : in std_logic_vector) is
begin
  for i in 0 to data'length-1 loop
    swd_write_bit(swclk, swdio, data(i));
  end loop;
end procedure;

-- Example: send SWD request packet (8 bits) and a 32-bit data word
procedure swd_send_request(signal swclk : in std_logic;
                           signal swdio : out std_logic;
                           signal swdio_2 : out std_logic;
                           req          : in std_logic_vector(7 downto 0);
                           dataword     : in std_logic_vector(31 downto 0)) is
constant ack : std_logic_vector(2 downto 0) := "001";
begin
  -- request phase (LSB first)
  swd_write_vector(swclk, swdio, req);

  -- turnaround: debugger releases line
  wait until falling_edge(swclk);
  swdio <= 'Z';
  for i in 0 to 2 loop
    wait until rising_edge(swclk);
    swdio_2 <= ack(i);
  end loop;

  wait until rising_edge(swclk);
  swdio_2 <= 'Z';
  wait until falling_edge(swclk);
  
  -- data phase (LSB first)
  swd_write_vector(swclk, swdio, dataword);

  -- parity bit (even parity on data)
  swd_write_bit(swclk, swdio, dataword(0));
  wait until falling_edge(swclk);
  swdio <= '0';
end procedure;


procedure swd_read_request(signal swclk : in std_logic;
                           signal swdio : out std_logic;
                           signal swdio_2 : out std_logic;
                           req          : in std_logic_vector(7 downto 0);
                           dataword     : in std_logic_vector(31 downto 0)) is
constant ack : std_logic_vector(2 downto 0) := "001";
begin
  -- request phase (LSB first)
  swd_write_vector(swclk, swdio, req);

  -- turnaround: debugger releases line
  wait until falling_edge(swclk);
  swdio <= 'Z';
  for i in 0 to 2 loop
    wait until rising_edge(swclk);
    swdio_2 <= ack(i);
  end loop;

  for i in 0 to dataword'length-1 loop
    wait until rising_edge(swclk);
    swdio_2 <= dataword(i);
  end loop;
  
  -- parity bit (even parity on data)
  wait until rising_edge(swclk);
  swdio_2 <= dataword(0);
  wait until rising_edge(swclk);
  swdio_2 <= 'Z';
  wait until falling_edge(swclk);
  swdio <= '0';
end procedure;







signal clk, reset, DbgToDvc, highz, direction_dbg_mux, direction_dvc_mux : std_logic := '0';
signal DvcToDbg : std_logic := 'Z';
begin
clk <= not clk after 100 ns;


tb : SWDProtocolEngine
port map(
clk => clk,
reset => reset, 
DbgToDvc => DbgToDvc,
DvcToDbg => DvcToDbg,
highz => highz,
direction_dbg_mux => direction_dbg_mux,
direction_dvc_mux => direction_dvc_mux
);




process
begin
	
	swd_send_request(clk, DbgToDvc, DvcToDbg, "10110001", "00000000000000000000000000000001");
  wait for 500 ns;
  swd_send_request(clk, DbgToDvc, DvcToDbg, "10101001", "00000000000000000000000000000000");
  wait for 500 ns;
  swd_read_request(clk, DbgToDvc, DvcToDbg, "10011111", "10000000000000000000001100000000");
	
end process;






end behaviour;