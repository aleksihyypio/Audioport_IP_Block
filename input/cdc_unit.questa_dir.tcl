########################################################################################
# cdc_unit directive file for Questa CDC and RDC scripts
########################################################################################

#########################################################################################
# Design settings
#########################################################################################

# To do: Specify your clk period
netlist clock clk  -period 17.5
netlist clock mclk -period 54.25347222

# Resets
netlist reset rst_n  -async -group rst_n -active_low
netlist reset mrst_n -async -group mrst_n -active_low

# Analysis is done in normal mode
netlist constant test_mode_in 1'b0

if { $EDA_TOOL == "Questa-CDC" } {
# Assign ports to clock domains
netlist port domain -clock clk \
    test_mode_in play_in tick_in audio0_in audio1_in req_out rst_n
netlist port domain -clock mclk \
    play_out tick_out audio0_out audio1_out req_in muxrst_n_out

# Assign ports to reset domains
netlist port resetdomain -reset rst_n \
    play_in tick_in audio0_in audio1_in req_out
netlist port resetdomain -reset mrst_nt \
    play_out tick_out audio0_out audio1_out req_in
}
#########################################################################################
# Clock Domain Crossing Check Settings
#########################################################################################

# Make qcdc recognize handshake synchronizers
cdc scheme on -handshake

# Make qcdc flag multibit two-dff synchronizers as violations
cdc report scheme bus_two_dff -severity violation

# Enable reconvergence analysis
cdc preference reconvergence -depth 4
cdc preference protocol -promote_reconvergence
cdc reconvergence on

cdc preference protocol -promote_async_reset

# Metastability window setting example:
# cdcfx fx window -start 25 -stop 10 -percent -rx_clock mclk -tx_clock clk





