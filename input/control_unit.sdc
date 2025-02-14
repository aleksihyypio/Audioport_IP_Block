######################################################################
# control_unit.sdc: Timing Constraints File
######################################################################

# 1. Define clock period and clock edge times in ns

create_clock -name clk -period 10.0 clk

# 2. Define reset input timing wrt clock in ns

set_input_delay  -clock clk 1.25 rst_n

# 3. Define input external delays (arrival times) wrt clock in ns

set_input_delay -clock clk 1.25 PSEL
set_input_delay -clock clk 1.25 PENABLE
set_input_delay -clock clk 1.25 PWRITE
set_input_delay -clock clk 1.25 PADDR
set_input_delay -clock clk 1.25 PWDATA
set_input_delay -clock clk 1.25 req_in

# 4. Define output external delays (setup times) wrt clock in ns

set_output_delay -clock clk 1.25 PRDATA
set_output_delay -clock clk 1.25 PREADY
set_output_delay -clock clk 1.25 PSLVERR
set_output_delay -clock clk 1.25 irq_out
set_output_delay -clock clk 1.25 audio0_out
set_output_delay -clock clk 1.25 audio1_out
set_output_delay -clock clk 1.25 cfg_out
set_output_delay -clock clk 1.25 cfg_reg_out
set_output_delay -clock clk 1.25 level_out
set_output_delay -clock clk 1.25 level_reg_out
set_output_delay -clock clk 1.25 dsp_regs_out
set_output_delay -clock clk 1.25 clr_out   
set_output_delay -clock clk 1.25 tick_out
set_output_delay -clock clk 1.25 play_out

