###################################################################
# 1. Project Paraemeters
###################################################################

set STUDENT_NUMBER    "172320"
set CLK_PERIOD        10.0
set MCLK_PERIOD       54.25347222
set FILTER_TAPS       53.0
set AUDIO_FIFO_SIZE   60.0

###################################################################
# 2. Top-module selection (uncomment only one!)
###################################################################

#set DESIGN_NAME "tlm_audioport"
#set DESIGN_NAME "audioport"
#set DESIGN_NAME "control_unit"
set DESIGN_NAME "i2s_unit"
#set DESIGN_NAME "cdc_unit"
#set DESIGN_NAME "dsp_unit"

###################################################################
# 3. Read module-specific setup
###################################################################

if [info exists env(FORCED_DESIGN_NAME) ] {
    set DESIGN_NAME $env(FORCED_DESIGN_NAME)
}

source input/0_setup_${DESIGN_NAME}.tcl

###################################################################
# 4. UVM test name override with env variable (e.g. from Makefile)
###################################################################

if [info exists env(UVM_TESTNAME) ] {
    set UVM_TESTNAME $env(UVM_TESTNAME)
}

# Set UVM_TESTBENCH flag of a test name hae been specified
if [info exists UVM_TESTNAME] {
    set UVM_TESTBENCH 1
} else {
    set UVM_TESTBENCH 0
}

###################################################################
# 5. Common settings for compilation scripts
###################################################################

# QuestaSim Verilog compiler settings
if [info exists VLOG_RTL_OPTIONS] {
    set VLOG_RTL_OPTIONS [concat $VLOG_RTL_OPTIONS " -suppress 13314 -suppress 13233 +define+RTL_SIM" ]
} else {
    set VLOG_RTL_OPTIONS " -suppress 13314 -suppress 13233 +define+RTL_SIM  "
}

# QuestaSim VHDL compiler settings
set VCOM_RTL_OPTIONS "-2008"

# QuestaSim Verilog compiler settings Verilog DUT in SystemC TB
if [info exists VLOG_SYSTEMC_OPTIONS] {
    set VLOG_SYSTEMC_OPTIONS [concat $VLOG_SYSTEMC_OPTIONS " -suppress 13314 -suppress 13233 +define+RTL_SIM " ]
} else {
    set VLOG_SYSTEMC_OPTIONS " -suppress 13314 -suppress 13233 +define+RTL_SIM "
}

# QuestaSim Verilog compiler settings SystemC DUT in Verilog TB simulation 
if [info exists VLOG_MIXEDLANG_OPTIONS] {
    set VLOG_MIXEDLANG_OPTIONS [concat $VLOG_MIXEDLANG_OPTIONS " -suppress 13314 -suppress 13233 +define+RTL_SIM +define+SYSTEMC_DUT" ]
} else {
    set VLOG_MIXEDLANG_OPTIONS " -suppress 13314 -suppress 13233 +define+RTL_SIM +define+SYSTEMC_DUT "
}

# QuestaSim Verilog compiler settings for gate-level simulation
if [info exists VLOG_GATELEVEL_OPTIONS] {
    set VLOG_GATELEVEL_OPTIONS [concat $VLOG_GATELEVEL_OPTIONS " +nowarn3448 -suppress 13314 -suppress 13233 +define+GATELEVEL_SIM " ]
} else {
    set VLOG_GATELEVEL_OPTIONS " +nowarn3448 -suppress 13314 -suppress 13233 +define+GATELEVEL_SIM "
}

# QuestaSim Verilog compiler settings for postlayout-level simulation
if [info exists VLOG_POSTLAYOUT_OPTIONS] {
    set VLOG_POSTLAYOUT_OPTIONS [concat $VLOG_POSTLAYOUT_OPTIONS " +nowarn3448 +nowarn3438 +nowarnTSCALE -suppress 13314 -suppress 13233 +define+POSTLAYOUT_SIM " ]
} else {
    set VLOG_POSTLAYOUT_OPTIONS " +nowarn3448 +nowarn3438 +nowarnTSCALE -suppress 13314 -suppress 13233 +define+POSTLAYOUT_SIM "
}

# QuestaSim settings for gate-level simulation
if [info exists VSIM_GATELEVEL_OPTIONS] {
    set VSIM_GATELEVEL_OPTIONS [concat $VSIM_GATELEVEL_OPTIONS " +nowarn3448 +nowarn8756 " ]
} else {
    set VSIM_GATELEVEL_OPTIONS " +nowarn3448 +nowarn8756 "
}

# QuestaSim settings for postlayout-level simulation
if [info exists VSIM_POSTLAYOUT_OPTIONS] {
    set VSIM_POSTLAYOUT_OPTIONS [concat $VSIM_POSTLAYOUT_OPTIONS " +nowarn3448 +nowarn3438 +nowarn8756 +nowarnTSCALE " ]
} else {
    set VSIM_POSTLAYOUT_OPTIONS " +nowarn3448 +nowarn3438 +nowarn8756 +nowarnTSCALE "
}

# VCS Verilog compiler settings for RTL simulation
if [info exists VCS_VLOG_RTL_OPTIONS] {
    set VCS_VLOG_RTL_OPTIONS [concat $VCS_VLOG_RTL_OPTIONS " +incdir+input +incdir+input/uvm +define+RTL_SIM " ]
} else {
    set VCS_VLOG_RTL_OPTIONS " +incdir+input +incdir+input/uvm +define+RTL_SIM "
}

# VCS simulator settings for RTL simulation
if [info exists VCS_RTL_OPTIONS] {
    set VCS_RTL_OPTIONS [concat $VCS_RTL_OPTIONS " -timescale=1ns/1ps" ]
} else {
    set VCS_RTL_OPTIONS " -timescale=1ns/1ps"
}

set XCELIUM_VLOG_RTL_OPTIONS       " -incdir input -incdir input/uvm -DEFINE RTL_SIM "
set XCELIUM_VLOG_MIXEDLANG_OPTIONS " -incdir input -incdir input/uvm -DEFINE RTL_SIM -DEFINE SYSTEMC_DUT " 

###################################################################
# 6. Assertion module bindings for the whole project
###################################################################

set SVA_BIND_FILE "input/sva_bindings.svh"


###################################################################
# 7. Enable SAIF activity data recording
###################################################################

set RTL_POWER_ESTIMATION      1

###################################################################
# 8. Misc. QuestaSim settings
###################################################################

# Enable/disable schematic generator
set VSIM_SCHEMATIC 0

# XML testplan file location
if { [file exists input/${DESIGN_NAME}_testplan.xml ] == 1} {
    set VSIM_TESTPLAN input/${DESIGN_NAME}_testplan.xml
}

# Testplan generation parameters
if { [info exists XML2UCDB_OPTIONS] == 0 || $XML2UCDB_OPTIONS == "" } {
    set XML2UCDB_OPTIONS "-GDESIGN_NAME=${DESIGN_NAME} -GSIM_PREFIX=/${DESIGN_NAME}_tb/DUT_INSTANCE -GFORMAL_PREFIX=/${DESIGN_NAME}"
}

###################################################################
# 9. Misc. synthesis settings
###################################################################

# Disable SDC file if it does not exits
if { [info exists SDC_FILE ] } {
    if { [file exists $SDC_FILE ] == 0} {
	unset SDC_FILE
    }
}

# Some Design Compiler settings
set DC_SUPPRESS_MESSAGES { "UID-401" "UID-348" "TEST-130" "TIM-104" "TIM-134" "TIM-179" "VER-26" "VO-4" "VHD-4"}

###################################################################
# 10. Misc. formal verification settings
###################################################################

# Filters for selecting assertions to report in Questa Formal
if { [info exists QFORMAL_BB_PROPERTIES] == 0 || $QFORMAL_BB_PROPERTIES == "" } {
    set QFORMAL_BB_PROPERTIES "CHECKER_MODULE.af_*"
}
if { [info exists QFORMAL_WB_PROPERTIES] == 0 || $QFORMAL_WB_PROPERTIES == "" } {
    set QFORMAL_WB_PROPERTIES "CHECKER_MODULE.ar_*"
}

set QAUTOCHECK_DISABLE_CHECKS { CASE_DEFAULT }

# Make Jasper FV to run longer
set JASPER_TRACE_LENGTH 3000


###################################################################
# 11. Select SDF backannotation delay types (MIN, TYP, MAX)
###################################################################

set GATELEVEL_SDF  MAX
set POSTLAYOUT_SDF MAX

#############################################################
# 12. Select technology setup file			     
#     scripts/0_setup_${TARGET_TECHNOLOGY}.tcl		     
#     to be loaded					     
#############################################################
							     
set TARGET_TECHNOLOGY "DT3"
