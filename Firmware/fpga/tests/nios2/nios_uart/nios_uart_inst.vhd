	component nios_uart is
		port (
			clock_bridge_0_in_clk_clk        : in  std_logic := 'X'; -- clk
			reset_bridge_0_in_reset_reset_n  : in  std_logic := 'X'; -- reset_n
			uart_0_external_connection_rxd   : in  std_logic := 'X'; -- rxd
			uart_0_external_connection_txd   : out std_logic;        -- txd
			pio_0_external_connection_export : out std_logic         -- export
		);
	end component nios_uart;

	u0 : component nios_uart
		port map (
			clock_bridge_0_in_clk_clk        => CONNECTED_TO_clock_bridge_0_in_clk_clk,        --      clock_bridge_0_in_clk.clk
			reset_bridge_0_in_reset_reset_n  => CONNECTED_TO_reset_bridge_0_in_reset_reset_n,  --    reset_bridge_0_in_reset.reset_n
			uart_0_external_connection_rxd   => CONNECTED_TO_uart_0_external_connection_rxd,   -- uart_0_external_connection.rxd
			uart_0_external_connection_txd   => CONNECTED_TO_uart_0_external_connection_txd,   --                           .txd
			pio_0_external_connection_export => CONNECTED_TO_pio_0_external_connection_export  --  pio_0_external_connection.export
		);

