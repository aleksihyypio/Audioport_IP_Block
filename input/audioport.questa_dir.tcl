########################################################################################
# audioport directive file for Questa CDC and RDC scripts
########################################################################################

#########################################################################################
# Design settings
#########################################################################################

# To do: Specify your clk period
netlist clock clk  -period 17.5
netlist clock mclk -period 54.25347222

# Resets
netlist reset rst_n -async -group rst_n -active_low
netlist reset cdc_unit_1.mrst_n -async -group mrst_n -active_low

# Analysis is done in normal mode
netlist constant test_mode_in 1'b0

if { $EDA_TOOL == "Questa-CDC" } {

    # Assign ports to clock domains
    netlist port domain -clock clk \
	PSEL PENABLE PWRITE PADDR PWDATA PRDATA PREADY PSLVERR \
	irq_out scan_en_in test_mode_in rst_n
    netlist port domain -clock mclk \
	ws_out sck_out sdo_out

    # Assign ports to reset domains
    netlist port resetdomain -reset rst_n \
	PSEL PENABLE PWRITE PADDR PWDATA PRDATA PREADY PSLVERR \
	irq_out scan_en_in test_mode_in
    netlist port resetdomain -reset cdc_unit1.mrst_n \
	ws_out sck_out sdo_out

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

# Metastability window tuning example:
#cdcfx fx window -start 25 -stop 25 -percent -rx_clock mclk -tx_clock clk
cdcfx check -fx -scheme handshake


