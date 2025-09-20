	nios_uart u0 (
		.clock_bridge_0_in_clk_clk        (<connected-to-clock_bridge_0_in_clk_clk>),        //      clock_bridge_0_in_clk.clk
		.reset_bridge_0_in_reset_reset_n  (<connected-to-reset_bridge_0_in_reset_reset_n>),  //    reset_bridge_0_in_reset.reset_n
		.uart_0_external_connection_rxd   (<connected-to-uart_0_external_connection_rxd>),   // uart_0_external_connection.rxd
		.uart_0_external_connection_txd   (<connected-to-uart_0_external_connection_txd>),   //                           .txd
		.pio_0_external_connection_export (<connected-to-pio_0_external_connection_export>)  //  pio_0_external_connection.export
	);

