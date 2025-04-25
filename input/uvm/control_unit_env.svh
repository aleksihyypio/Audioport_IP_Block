///////////////////////////////////////////////////////////
//
// control_unit_env
//
///////////////////////////////////////////////////////////

class control_unit_env extends uvm_env;
   `uvm_component_utils(control_unit_env)

   //-------------------------------------------------------- 
   // Member variables
   //--------------------------------------------------------
   control_unit_agent m_control_unit_agent;
   irq_agent m_irq_agent;  

   //-------------------------------------------------------- 
   // Member functions
   //--------------------------------------------------------
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      m_control_unit_agent = control_unit_agent::type_id::create("control_unit_agent", this);
      m_irq_agent = irq_agent::type_id::create("irq_agent", this);
   endfunction

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      m_irq_agent.analysis_port.connect(m_control_unit_agent.irq_analysis_export);
   endfunction
   
endclass   
