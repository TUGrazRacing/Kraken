
module nios_uart (
	clock_bridge_0_in_clk_clk,
	reset_bridge_0_in_reset_reset_n,
	uart_0_external_connection_rxd,
	uart_0_external_connection_txd,
	pio_0_external_connection_export);	

	input		clock_bridge_0_in_clk_clk;
	input		reset_bridge_0_in_reset_reset_n;
	input		uart_0_external_connection_rxd;
	output		uart_0_external_connection_txd;
	output		pio_0_external_connection_export;
endmodule
