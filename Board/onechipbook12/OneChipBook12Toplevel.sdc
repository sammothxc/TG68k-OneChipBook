# OneChipBook-12 Timing Constraints
# For TimeQuest Timing Analyzer

#**************************************************************
# Create Clock
#**************************************************************

# Input clock: 21.47727 MHz
create_clock -name {clk_21m} -period 46.560 -waveform { 0.000 23.280 } [get_ports {clk_21m}]

# PLL output clocks (derived from input clock)
# System clock ~43 MHz (21.47727 * 2)
create_generated_clock -name {clk_sys} -source [get_ports {clk_21m}] -multiply_by 2 -duty_cycle 50.00 [get_pins {pll_inst|altpll_component|pll|clk[0]}]

# SDRAM clock (phase shifted)
create_generated_clock -name {clk_sdram} -source [get_ports {clk_21m}] -multiply_by 2 -phase -90 -duty_cycle 50.00 [get_pins {pll_inst|altpll_component|pll|clk[1]}]

#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clk_sys}] -rise_to [get_clocks {clk_sys}] 0.200
set_clock_uncertainty -rise_from [get_clocks {clk_sys}] -fall_to [get_clocks {clk_sys}] 0.200
set_clock_uncertainty -fall_from [get_clocks {clk_sys}] -rise_to [get_clocks {clk_sys}] 0.200
set_clock_uncertainty -fall_from [get_clocks {clk_sys}] -fall_to [get_clocks {clk_sys}] 0.200

#**************************************************************
# Set Input Delay
#**************************************************************

# SDRAM data input
set_input_delay -add_delay -max -clock [get_clocks {clk_sdram}] 6.000 [get_ports {sdram_data[*]}]
set_input_delay -add_delay -min -clock [get_clocks {clk_sdram}] 1.000 [get_ports {sdram_data[*]}]

# Serial input (asynchronous, use false path instead)
set_false_path -from [get_ports {rs232_rxd}]

# PS/2 input (asynchronous)
set_false_path -from [get_ports {ps2_clk}]
set_false_path -from [get_ports {ps2_dat}]

# SD card MISO (asynchronous to system clock)
set_false_path -from [get_ports {sd_miso}]

# DIP switches (asynchronous)
set_false_path -from [get_ports {dip_sw[*]}]

#**************************************************************
# Set Output Delay
#**************************************************************

# SDRAM outputs
set_output_delay -add_delay -max -clock [get_clocks {clk_sdram}] 2.000 [get_ports {sdram_addr[*]}]
set_output_delay -add_delay -min -clock [get_clocks {clk_sdram}] -1.000 [get_ports {sdram_addr[*]}]
set_output_delay -add_delay -max -clock [get_clocks {clk_sdram}] 2.000 [get_ports {sdram_data[*]}]
set_output_delay -add_delay -min -clock [get_clocks {clk_sdram}] -1.000 [get_ports {sdram_data[*]}]
set_output_delay -add_delay -max -clock [get_clocks {clk_sdram}] 2.000 [get_ports {sdram_ba[*]}]
set_output_delay -add_delay -min -clock [get_clocks {clk_sdram}] -1.000 [get_ports {sdram_ba[*]}]
set_output_delay -add_delay -max -clock [get_clocks {clk_sdram}] 2.000 [get_ports {sdram_*dqm}]
set_output_delay -add_delay -min -clock [get_clocks {clk_sdram}] -1.000 [get_ports {sdram_*dqm}]
set_output_delay -add_delay -max -clock [get_clocks {clk_sdram}] 2.000 [get_ports {sdram_*_n}]
set_output_delay -add_delay -min -clock [get_clocks {clk_sdram}] -1.000 [get_ports {sdram_*_n}]
set_output_delay -add_delay -max -clock [get_clocks {clk_sdram}] 2.000 [get_ports {sdram_cke}]
set_output_delay -add_delay -min -clock [get_clocks {clk_sdram}] -1.000 [get_ports {sdram_cke}]

# VGA outputs (directly active pixel clock relationship)
set_false_path -to [get_ports {vga_*}]

# LEDs (no timing requirement)
set_false_path -to [get_ports {led[*]}]

# Serial output
set_false_path -to [get_ports {rs232_txd}]

# PS/2 output
set_false_path -to [get_ports {ps2_clk}]
set_false_path -to [get_ports {ps2_dat}]

# SD card outputs
set_false_path -to [get_ports {sd_cs_n}]
set_false_path -to [get_ports {sd_clk}]
set_false_path -to [get_ports {sd_mosi}]

#**************************************************************
# Set False Path (unrelated clock domains)
#**************************************************************

# Between PLL clocks that are already constrained
# set_false_path -from [get_clocks {clk_sys}] -to [get_clocks {clk_sdram}]
# set_false_path -from [get_clocks {clk_sdram}] -to [get_clocks {clk_sys}]

#**************************************************************
# Set Multicycle Path
#**************************************************************

# None required for basic operation

#**************************************************************
# Set Maximum Delay
#**************************************************************

# None required for basic operation

#**************************************************************
# Set Minimum Delay
#**************************************************************

# None required for basic operation
