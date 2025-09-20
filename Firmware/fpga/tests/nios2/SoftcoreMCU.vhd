library ieee;
use ieee.std_logic_1164.all;



entity SoftcoreMCU is
	port(
		clk : in std_logic;
		rx : in std_logic;
		tx : out std_logic;
		pin : out std_logic
	);
end entity;


architecture behaviour of SoftcoreMCU is

component nios_uart is
	port (
		clock_bridge_0_in_clk_clk      : in  std_logic := 'X'; -- clk
		pio_0_external_connection_export : out std_logic;        --  pio_0_external_connection.export
		reset_bridge_0_in_reset_reset_n  : in  std_logic := 'X'; -- reset
		uart_0_external_connection_rxd : in  std_logic := 'X'; -- rxd
		uart_0_external_connection_txd : out std_logic         -- txd
		
	);
end component;

begin


MCU : nios_uart 
port map(
	clock_bridge_0_in_clk_clk => clk,
	reset_bridge_0_in_reset_reset_n => '1',
	uart_0_external_connection_rxd => rx,
	uart_0_external_connection_txd => tx,
	pio_0_external_connection_export => pin
);



end behaviour;