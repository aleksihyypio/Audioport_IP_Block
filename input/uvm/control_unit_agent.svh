///////////////////////////////////////////////////////////
//
// control_unit_agent
//
///////////////////////////////////////////////////////////

class control_unit_agent extends uvm_agent;
   `uvm_component_utils(control_unit_agent)

   //-------------------------------------------------------- 
   // Member variables
   //--------------------------------------------------------
   apb_driver m_driver;
   apb_monitor m_monitor;
   apb_sequencer m_sequencer;
   apb_analyzer m_analyzer;
   bit has_analyzer;

   uvm_analysis_port #(apb_transaction) analysis_port;
   uvm_analysis_imp #(irq_transaction, control_unit_agent) irq_analysis_export;
     
   uvm_event m_irq_event;
   
   //-------------------------------------------------------- 
   // Member functions
   //--------------------------------------------------------
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
      apb_agent_config agent_cfg;

      super.build_phase(phase);

      m_sequencer = apb_sequencer::type_id::create("m_sequencer", this);
      m_driver    = apb_driver::type_id::create("m_driver", this);
      m_monitor   = apb_monitor::type_id::create("m_monitor", this);

      analysis_port       = new("analysis_port", this);
      irq_analysis_export = new("irq_analysis_export", this);

      has_analyzer = 1;
      if (uvm_config_db #(apb_agent_config)::get(null, get_full_name(), "apb_agent_config", agent_cfg))
      begin
         has_analyzer = agent_cfg.has_analyzer; `uvm_info("", $sformatf("apb_agent configured %s analyzer component.",
                                (has_analyzer ? "with" : "without")), UVM_NONE);
      end

      if (has_analyzer)
         m_analyzer = apb_analyzer::type_id::create("m_analyzer", this);

      m_irq_event = uvm_event_pool::get_global("irq_out");


   endfunction

   function void connect_phase(uvm_phase phase);
      m_driver.seq_item_port.connect(m_sequencer.seq_item_export);

      if (has_analyzer)
         m_monitor.analysis_port.connect(m_analyzer.analysis_export);
      else
      m_monitor.analysis_port.connect(analysis_port);

   endfunction

   function void write(irq_transaction t);
      if(t.irq)

	m_irq_event.trigger();
   endfunction

endclass
 
