--------------------------------------------------------------------------------
--
-- CTU CAN FD IP Core
-- Copyright (C) 2021-present Ondrej Ille
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this VHDL component and associated documentation files (the "Component"),
-- to use, copy, modify, merge, publish, distribute the Component for
-- educational, research, evaluation, self-interest purposes. Using the
-- Component for commercial purposes is forbidden unless previously agreed with
-- Copyright holder.
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Component.
--
-- THE COMPONENT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHTHOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE COMPONENT OR THE USE OR OTHER DEALINGS
-- IN THE COMPONENT.
--
-- The CAN protocol is developed by Robert Bosch GmbH and protected by patents.
-- Anybody who wants to implement this IP core on silicon has to obtain a CAN
-- protocol license from Bosch.
--
-- -------------------------------------------------------------------------------
--
-- CTU CAN FD IP Core
-- Copyright (C) 2015-2020 MIT License
--
-- Authors:
--     Ondrej Ille <ondrej.ille@gmail.com>
--     Martin Jerabek <martin.jerabek01@gmail.com>
--
-- Project advisors:
-- 	Jiri Novak <jnovak@fel.cvut.cz>
-- 	Pavel Pisa <pisa@cmp.felk.cvut.cz>
--
-- Department of Measurement         (http://meas.fel.cvut.cz/)
-- Faculty of Electrical Engineering (http://www.fel.cvut.cz)
-- Czech Technical University        (http://www.cvut.cz/)
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this VHDL component and associated documentation files (the "Component"),
-- to deal in the Component without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Component, and to permit persons to whom the
-- Component is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Component.
--
-- THE COMPONENT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHTHOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE COMPONENT OR THE USE OR OTHER DEALINGS
-- IN THE COMPONENT.
--
-- The CAN protocol is developed by Robert Bosch GmbH and protected by patents.
-- Anybody who wants to implement this IP core on silicon has to obtain a CAN
-- protocol license from Bosch.
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  @Purpose:
--    Functional coverage for Bus Sampling
--
--------------------------------------------------------------------------------
-- Revision History:
--    27.4.2025   Created file
--------------------------------------------------------------------------------

Library ctu_can_fd_tb;
context ctu_can_fd_tb.ieee_context;
context ctu_can_fd_tb.tb_common_context;
context ctu_can_fd_tb.rtl_context;

use ctu_can_fd_tb.clk_gen_agent_pkg.all;
use ctu_can_fd_tb.tb_shared_vars_pkg.all;

entity func_cov_bus_sampling is
    port (
        -- DUT clock
        clk    :   in  std_logic
    );
end entity;

architecture tb of func_cov_bus_sampling is

    -----------------------------------------------------------------------------------------------
    -- Aliases to "bus_sampling" top
    -----------------------------------------------------------------------------------------------

    alias bit_err_ssp_valid is
        << signal .tb_top_ctu_can_fd.dut.bus_sampling_inst.bit_err_detector_inst.bit_err_ssp_valid : std_logic >>;

    alias bit_err_norm_valid is
        << signal .tb_top_ctu_can_fd.dut.bus_sampling_inst.bit_err_detector_inst.bit_err_norm_valid : std_logic >>;

    alias bit_err_ssp_capt_q is
        << signal .tb_top_ctu_can_fd.dut.bus_sampling_inst.bit_err_detector_inst.bit_err_ssp_capt_q : std_logic >>;

    alias bit_err_ssp_condition is
        << signal .tb_top_ctu_can_fd.dut.bus_sampling_inst.bit_err_detector_inst.bit_err_ssp_condition : std_logic >>;

    alias tq_edge is
        << signal .tb_top_ctu_can_fd.dut.bus_sampling_inst.tq_edge : std_logic >>;

    -----------------------------------------------------------------------------------------------
    -- Aliases to "data_edge_detector" top
    -----------------------------------------------------------------------------------------------

    alias rx_data_sync_prev is
        << signal .tb_top_ctu_can_fd.dut.bus_sampling_inst.data_edge_detector_inst.rx_data_sync_prev : std_logic >>;

    alias rx_data is
        << signal .tb_top_ctu_can_fd.dut.bus_sampling_inst.data_edge_detector_inst.rx_data : std_logic >>;

    alias prev_rx_sample is
        << signal .tb_top_ctu_can_fd.dut.bus_sampling_inst.data_edge_detector_inst.prev_rx_sample : std_logic >>;

    -----------------------------------------------------------------------------------------------
    -- Aliases to "trv_delay_meas" top
    -----------------------------------------------------------------------------------------------
    alias mr_ssp_cfg_ssp_src is
        << signal .tb_top_ctu_can_fd.dut.bus_sampling_inst.trv_delay_measurement_inst.mr_ssp_cfg_ssp_src : std_logic_vector(1 downto 0) >>;

    alias tran_delay_meas is
        << signal .tb_top_ctu_can_fd.dut.bus_sampling_inst.trv_delay_measurement_inst.tran_delay_meas : std_logic >>;

    alias ssp_delay_saturated is
        << signal .tb_top_ctu_can_fd.dut.bus_sampling_inst.trv_delay_measurement_inst.ssp_delay_saturated : std_logic_vector(C_SSP_POS_WIDTH-1 downto 0) >>;

    -----------------------------------------------------------------------------------------------
    -- Aliases to "tx_data_cache" top
    -----------------------------------------------------------------------------------------------
    alias write_pointer_q is
        << signal .tb_top_ctu_can_fd.dut.bus_sampling_inst.tx_data_cache_inst.write_pointer_q : natural range 0 to 7 >>;

    alias read_pointer_q is
        << signal .tb_top_ctu_can_fd.dut.bus_sampling_inst.tx_data_cache_inst.read_pointer_q : natural range 0 to 7 >>;

begin

    -- psl default clock is rising_edge(clk);

    -----------------------------------------------------------------------------------------------
    -- Bit Error detection
    -----------------------------------------------------------------------------------------------

    -- psl bit_err_secondary_cov : cover
    --  {bit_err_ssp_valid = '1' and bit_err_norm_valid = '0'};

    -- psl bit_err_secondary_capt_cov : cover
    --  {bit_err_ssp_valid = '1' and bit_err_ssp_capt_q = '1' and bit_err_ssp_condition = '0'};

    -- psl bit_err_secondary_direct_cov : cover
    --  {bit_err_ssp_valid = '1' and bit_err_ssp_capt_q = '0' and bit_err_ssp_condition = '1'};


    -----------------------------------------------------------------------------------------------
    -- Data edge detection
    -----------------------------------------------------------------------------------------------

    -- psl sync_edge_but_prev_sample_the_same_cov : cover
    --  {(rx_data_sync_prev /= rx_data) and (rx_data_sync_prev = RECESSIVE) and
    --   (prev_rx_sample = rx_data) and (tq_edge = '1')};


    -----------------------------------------------------------------------------------------------
    -- Transceiver delay measureement
    -----------------------------------------------------------------------------------------------

    -- psl ssp_meas_n_offset_cov : cover
    --  {mr_ssp_cfg_ssp_src = SSP_SRC_MEAS_N_OFFSET and tran_delay_meas = '1'};

    -- psl ssp_offset_cov : cover
    --  {mr_ssp_cfg_ssp_src = SSP_SRC_OFFSET and tran_delay_meas = '1'};

    -- psl ssp_no_ssp_cov : cover
    --  {mr_ssp_cfg_ssp_src = SSP_SRC_NO_SSP and tran_delay_meas = '1'};
    -- Note: Protocol control FSM actually requests the measurement of TRV delay
    --       even if SSP is not used!

    -- psl ssp_offset_sat_cov : cover
    --  {ssp_delay_saturated = std_logic_vector(to_unsigned(C_SSP_DELAY_SAT_VAL, C_SSP_POS_WIDTH))};


    -----------------------------------------------------------------------------------------------
    -- TX Data cache
    -----------------------------------------------------------------------------------------------

    -- psl tx_data_cache_one_bit_on_fly_cov : cover
    --  {write_pointer_q = read_pointer_q + 1};

    -- psl tx_data_cache_two_bits_on_fly_cov : cover
    --  {write_pointer_q = read_pointer_q + 2};

    -- psl tx_data_cache_three_bits_on_fly_cov : cover
    --  {write_pointer_q = read_pointer_q + 3};

    -- psl tx_data_cache_four_bits_on_fly_cov : cover
    --  {write_pointer_q = read_pointer_q + 4};

end architecture;