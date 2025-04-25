///////////////////////////////////////////////////////////
//
// control_unit_uvm_test
//
///////////////////////////////////////////////////////////
   
class control_unit_uvm_test extends uvm_test;
  `uvm_component_utils(control_unit_uvm_test)

   //-------------------------------------------------------- 
   // Member variables
   //--------------------------------------------------------
   control_unit_env m_env; 

   //-------------------------------------------------------- 
   // Member functions
   //--------------------------------------------------------
   // Constructor
   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction
   // Build phase
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      m_env = control_unit_env::type_id::create("m_env", this);
   endfunction: build_phase
   // Run phase
   task run_phase(uvm_phase phase);
      // Local variables
      control_unit_sequence seq;

      phase.raise_objection(this);

      // Executable code
      reset_test_stats; 

      seq = control_unit_sequence::type_id::create("seq");
      seq.start(m_env.m_control_unit_agent.m_sequencer);


      
      update_test_stats;      
      $display("#####################################################################################################");	
      $display("control_uvm_test results: PASSED: %d / FAILED: %d", tests_passed, tests_failed);
      $display("#####################################################################################################");	

      ia_control_unit_uvm_test: assert (tests_failed == 0) else 
	assert_error("ia_control_unit_uvm_test");  // See audioport_pkg.sv
      
      phase.drop_objection(this);
    endtask

endclass 
