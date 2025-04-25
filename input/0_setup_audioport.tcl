####################################################################################
# UVM test selection
####################################################################################
set UVM_TESTBENCH	      1
#set UVM_TESTNAME             "apb_test"
set UVM_TESTNAME             "control_unit_uvm_test"
#set UVM_TESTNAME             "audioport_uvm_test"
#set UVM_TESTNAME             "my_uvm_test"

####################################################################################
# audioport Design Files
####################################################################################

set DESIGN_NAME       "audioport"

set DESIGN_SUBMODULES { "control_unit" "dsp_unit" "cdc_unit" "i2s_unit" }

set DESIGN_FILES     {  "input/apb_pkg.sv" \
		       "input/audioport_pkg.sv" \
		       "input/audioport_util_pkg.sv" \
		     }

set RTL_FILES        { "input/control_unit.sv" \
		       "results/dsp_unit_hls_rtl.v" \
		       "input/dsp_unit.sv" \
		       "input/cdc_unit.sv" \
		       "input/i2s_unit.vhd" \
		       "results/audioport_hls_rtl.v" \			   
		       "input/audioport.sv" \
		    }
set SVA_FILES       {  "input/control_unit_svamod.sv" \
		       "input/dsp_unit_svamod.sv" \
		       "input/cdc_unit_svamod.sv" \
		       "input/i2s_unit_svamod.sv"  \
		       "input/audioport_svamod.sv"  \
		    }

if { [info exists UVM_TESTNAME] } {
    set TESTBENCH_FILES { \
			      "input/apb_if.sv" \
			      "input/irq_out_if.sv" \
			      "input/i2s_if.sv" \
			      "input/uvm/apb_env_pkg.sv" \
			      "input/uvm/control_unit_env_pkg.sv" \
			      "input/uvm/audioport_env_pkg.sv" \
			      "input/uvm/audioport_uvm_tests_pkg.sv" \
			      "input/audioport_tb.sv" \
			  }
} else {
    set TESTBENCH_FILES { \
			      "input/apb_if.sv" \
			      "input/irq_out_if.sv" \
			      "input/i2s_if.sv" \
			      "input/audioport_test.sv" \
			      "input/audioport_tb.sv" \
			  }
}

set RTL_LANGUAGE "SystemVerilog"

#####################################################################################
# SystemC code settings for reference model simulation
#####################################################################################

set SYSTEMC_SOURCE_FILES  { \
				"input/control_unit.cpp" \
				"input/dsp_unit.cpp" \
				"input/cdc_testmux.cpp" \
				"input/cdc_reset_sync.cpp" \
				"input/cdc_2ff_sync.cpp" \								
				"input/cdc_pulse_sync.cpp" \				
				"input/cdc_handshake.cpp" \				
				"input/cdc_unit.cpp" \
				"input/i2s_unit.cpp" \			
				"input/audioport.cpp" \
			    }

set SYSTEMC_HEADER_FILES    { \
				  "input/control_unit.h" \
				  "input/dsp_unit.h" \
				  "input/cdc_testmux.h" \
				  "input/cdc_reset_sync.h" \
				  "input/cdc_2ff_sync.h" \								
                                  "input/cdc_pulse_sync.h" \				
                                  "input/cdc_handshake.h" \				
				  "input/cdc_unit.h" \
				  "input/i2s_unit.h" \
				  "input/audioport.h" \
			      }

set SYSTEMC_TESTBENCH_FILES { \
				  "input/audioport_tb.cpp" \
				  "input/audioport_top.cpp" \
				  "input/audioport_sc_main.cpp" \
			      }

set SYSTEMC_MODULES         { control_unit dsp_unit cdc_testmux cdc_reset_sync cdc_2ff_sync cdc_pulse_sync cdc_handshake cdc_unit i2s_unit }


#####################################################################################
# Timing Constraints
#####################################################################################

set SDC_FILE              input/${DESIGN_NAME}.sdc
set CLOCK_NAMES           {"clk" "mclk"}
set CLOCK_PERIODS         [list $CLK_PERIOD $MCLK_PERIOD]
set CLOCK_UNCERTAINTIES   { 0.0     0.0}
set CLOCK_LATENCIES       { 0.0     0.0}
set INPUT_DELAYS          {   0       0}
set OUTPUT_DELAYS         {   0       0}
set OUTPUT_LOAD           0.01
set RESET_NAMES           { "rst_n"  "muxrst_n" }
set RESET_LEVELS          {  0       0}
set RESET_STYLES          {  "async"  "async" }
set CLOCK_DOMAIN_PORTS    { { PSEL PENABLE PWRITE PADDR PWDATA PRDATA PREADY PSLVERR \
			      irq_out scan_en_in test_mode_in rst_n } \
			  {  ws_out sck_out sdo_out } }

#####################################################################################
# Settings for mixed-language simulation (SystemC instantiated from SystemVerilog)
#####################################################################################

set MIXEDLANG_SIMULATION_TIME   "-all"

#####################################################################################
# Settings for SystemC simulation
#####################################################################################

set SC_EXE_ARGS               "-run systemc -output results"
set SYSTEMC_SIMULATION_TIME   "-all"
set VSIM_SYSTEMC_OPTIONS      "-sc_arg \"-run\" -sc_arg \"vsim_systemc\" -sc_arg \"-output\" -sc_arg \"results\" "
set VSIM_SCRTL_OPTIONS        "-t 1ps -sc_arg \"-run\" -sc_arg \"vsim_rtl\" -sc_arg \"-output\" -sc_arg \"results\""

#####################################################################################
# Settings for RTL simulation
#####################################################################################

# Simulation run times (set to  "-all" to run all)
set RTL_SIMULATION_TIME         "-all"

if { [info exists UVM_TESTNAME] } {
    set VSIM_RTL_WAVES             "input/3_vsim_audioport_rtl_simulation_waves.tcl"
    set VSIM_MIXEDLANG_WAVES       "input/3_vsim_audioport_rtl_simulation_waves.tcl"

    if { $UVM_TESTNAME == "apb_test" } {
	set VLOG_RTL_OPTIONS     " +define+apb_test_classes"
	set VCS_VLOG_RTL_OPTIONS " +define+apb_test_classes"

    }
    if { $UVM_TESTNAME == "control_unit_uvm_test" } {
	set VLOG_RTL_OPTIONS " +define+apb_test_classes +define+control_unit_uvm_test_classes"
	set VCS_VLOG_RTL_OPTIONS " +define+apb_test_classes"
    }
    if { $UVM_TESTNAME == "audioport_uvm_test" } {
	set VLOG_RTL_OPTIONS " +define+apb_test_classes +define+control_unit_uvm_test_classes +define+audioport_uvm_test_classes"
	set VCS_VLOG_RTL_OPTIONS " +define+apb_test_classes"
    }
    if { $UVM_TESTNAME == "my_uvm_test" } {
	set VLOG_RTL_OPTIONS " +define+apb_test_classes +define+control_unit_uvm_test_classes +define+audioport_uvm_test_classes +define+my_uvm_test_classes"
	set VCS_VLOG_RTL_OPTIONS " +define+apb_test_classes"
    }

    if { [info exists VLOG_RTL_OPTIONS] } {
	set VLOG_MIXEDLANG_OPTIONS $VLOG_RTL_OPTIONS
	set VLOG_GATELEVEL_OPTIONS $VLOG_RTL_OPTIONS
	set VLOG_POSTLAYOUT_OPTIONS $VLOG_RTL_OPTIONS	
    }    

} else {
    set VSIM_RTL_WAVES             "input/3_vsim_audioport_rtl_simulation_waves.tcl"
    set VSIM_MIXEDLANG_WAVES       "input/3_vsim_audioport_rtl_simulation_waves.tcl"
}


# Coverage Testplan Generation Settings
set XML2UCDB_OPTIONS ""

#####################################################################################
# Settings for static verification scripts
#####################################################################################

# Initialization file for Questa Formal
set QUESTA_INIT_FILE "input/rst.questa_init"

# Questa Formal coverage enable and max runtime
set QFORMAL_COVERAGE 1
set QFORMAL_TIMEOUT  48h

# Directives file for Questa (CDC)
set QUESTA_DIRECTIVES "input/audioport.questa_dir.tcl"

# Enable metastability injection in Questa CDC
set QCDC_RUN_CDCFX 1

# Enable reconvergence analysis in Questa CDC
set QCDC_RECONVERGENCE 1

# Questa Autocheck disabled modules
set QAUTOCHECK_DISABLE_MODULES { "dsp_unit_rtl" }

# Questa Lint disabled modules
set QLINT_IP_MODULES { "dsp_unit_rtl" }

# Jasper Connectivity Check (clocks cannot be inferred on Week 1)
set JASPER_INFER_CLOCKS 0

#####################################################################################
# Logic Synthesis Settings
#####################################################################################

# General constraints
set SYNTHESIS_CONSTRAINTS_FILE    "input/audioport.syn_constraints.tcl"

# Enable clock gating
set GATE_CLOCK             0
set CLOCK_GATE_MAX_FANOUT  16 

# Scan chain settings
set INSERT_SCAN_CHAINS     1
set DFT_SETUP_FILE         "input/audioport.dft_setup.tcl"
set DFT_AUTOFIX_SCRIPT     "input/audioport.dft_autofix.tcl"

#####################################################################################
# Formality RTL-vs-gates Logic Equivalence Check Settings
#####################################################################################

set FORMALITY_GLEC_SETUP_FILE "input/audioport.glec_setup.tcl"
set FORMALITY_TIMEOUT_LIMIT "02:00:00"

#####################################################################################
# Settings for Gate-Level simulation
#####################################################################################

# Run a short simulation
set GATELEVEL_SIMULATION_TIME   "1us"

# Disable all timing checks
set VSIM_GATELEVEL_OPTIONS      "+notimingchecks"

# Disable checks for synchronizers
# set VSIM_DISABLE_TIMINGCHECKS {  "*sff1*" }

#####################################################################################
# Design-fo-Test and ATPG Configuration
#####################################################################################

# Use post-layout netlist
set POSTLAYOUT_ATPG        0

# Tetramax run-time limit
set TMAX_ABORT_LIMIT       100000

# Continue with previous patters?
set TMAX_CONTINUE_ATPG     0

# Set ignored rules list
set TMAX_IGNORE_RULES { N21 N33 }

# Simulation in TestMax testbench
set VSIM_TMAXSIM_LOAD_SDF   1
#set VSIM_TMAXSIM_OPTIONS   "+notimingchecks -suppress 16107"
set TMAXSIM_SIMULATION_TIME  "-all"

#####################################################################################
# Layout Design Settings
#####################################################################################

# Suspend after every major phase
set INNOVUS_DEMO_MODE      1

# Run faster with bad results
set INNOVUS_PROTOTYPING_MODE      0

# Cell density: make it smaller to improve routability
set INNOVUS_STANDARD_CELL_DENSITY 0.7

# Innovus effort setting: express, standard or extreme
set INNOVUS_OPTIMIZATION_EFFORT "standard"

set INNOVUS_CPUS 4

#####################################################################################
# Formality Post-Layout Logic Equivalence Check Settings
#####################################################################################

set FORMALITY_PLEC_SETUP_FILE "input/audioport.glec_setup.tcl"

#####################################################################################
# Static Timing Analysis Settings
#####################################################################################

# set STA_SDC_FILE $SDC_FILE

#####################################################################################
# Postlayout Simulation Settings
#####################################################################################

# Disable all timing checks
#set VSIM_POSTLAYOUT_OPTIONS      "+notimingchecks"

set VCD_SNAPSHOT_START_TIME     0us  ; # VCD dump start time
set VCD_SNAPSHOT_LENGTH         10us ; # VCD dump length
set POSTLAYOUT_SIMULATION_TIME  10us ; # PL simulation time (should be at least START+LENGTH)

#####################################################################################
# Power Estimation Settings
#####################################################################################

# Select power waveforms to display
set WV_WAVEFORMS { "audioport" "dsp_unit_1" "control_unit_1" "i2s_unit_1" "cdc_unit_1" }


