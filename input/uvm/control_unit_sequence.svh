///////////////////////////////////////////////////////////
// control_unit_sequence
///////////////////////////////////////////////////////////

class control_unit_sequence extends uvm_sequence #(apb_transaction);
      `uvm_object_utils(control_unit_sequence)

   //-------------------------------------------------------- 
   // Member functions
   //--------------------------------------------------------
	
   function new (string name = "");
      super.new(name);
   endfunction

   
   task body;

      /////////////////////////////////////////////////////////////////////
      // Variable declarations
      /////////////////////////////////////////////////////////////////////      

      uvm_event                 irq_event;
      apb_transaction		tx;
      logic [23:0]		stream_wdata;
      int i;

      /////////////////////////////////////////////////////////////////////      
      // Executable code
      /////////////////////////////////////////////////////////////////////

      reset_test_stats;       
      irq_event = uvm_event_pool::get_global("irq_out");
      stream_wdata = 1;

      //    Example: You can wait for the irq_event like this:
      //    irq_event.wait_trigger();

      // 1. Write random values to DSP register region
      for (i = 0; i < DSP_REGISTERS; i++) begin
         // Create transaction for DSP register write
         tx = apb_transaction::type_id::create("tx");
         tx.addr = DSP_REGS_START_ADDRESS + i * 4;
         tx.data = $urandom();
         tx.write_mode = 1;
         tx.fail = 0;
         // Start and finish the transaction
         start_item(tx);
         finish_item(tx);
      end

      repeat (AUDIO_FIFO_SIZE) begin
        // Left FIFO (odd values: 1, 3, 5, ...)
        tx = apb_transaction::type_id::create("tx");
        tx.addr = LEFT_FIFO_ADDRESS;  // Left FIFO address from the package
        tx.data = stream_wdata;       // Assign current stream_wdata value (odd number)
        tx.write_mode = 1;
        start_item(tx);
        finish_item(tx);
        stream_wdata = stream_wdata +2;  // Increment to next odd number

        // Right FIFO (even values: 2, 4, 6, ...)
        tx = apb_transaction::type_id::create("tx");
        tx.addr = RIGHT_FIFO_ADDRESS;  // Right FIFO address from the package
        tx.data = stream_wdata + 1;       // Assign current stream_wdata value (even number)
        tx.write_mode = 1;
        start_item(tx);
        finish_item(tx);
        stream_wdata = stream_wdata + 2;  // Increment to next even number
      end

      // 3. Enable DSP filter
      tx = apb_transaction::type_id::create("tx");
      tx.addr = CFG_REG_ADDRESS;
      tx.data = 32'(DSP_FILTER_ON);
      start_item(tx);
      finish_item(tx);

      // 4. Send CMD_CFG
      tx = apb_transaction::type_id::create("tx");
      tx.addr = CMD_REG_ADDRESS;
      tx.data = CMD_CFG;
      start_item(tx);
      finish_item(tx);

      // 5. Set max playback level
      tx = apb_transaction::type_id::create("tx");
      tx.addr = LEVEL_REG_ADDRESS;
      tx.data = 32'hFFFFFFFF;  // Maximum volume level
      start_item(tx);
      finish_item(tx);

      // 6. Send CMD_LEVEL
      tx = apb_transaction::type_id::create("tx");
      tx.addr = CMD_REG_ADDRESS;
      tx.data = CMD_LEVEL;
      start_item(tx);
      finish_item(tx);

      // 7. Send CMD_START
      tx = apb_transaction::type_id::create("tx");
      tx.addr = CMD_REG_ADDRESS;
      tx.data = CMD_START;
      start_item(tx);
      finish_item(tx);

      // 8-10. Handle interrupts and refill FIFOs
      repeat (4) begin
         // Wait for interrupt event
         irq_event.wait_trigger();
         #1us; // Simulate interrupt latency

         // Refill FIFOs
         repeat (AUDIO_FIFO_SIZE) begin
            // Left FIFO
            tx = apb_transaction::type_id::create("tx");
            tx.addr = LEFT_FIFO_ADDRESS;
            tx.data = stream_wdata++;
            start_item(tx);
            finish_item(tx);

            // Right FIFO
            tx = apb_transaction::type_id::create("tx");
            tx.addr = RIGHT_FIFO_ADDRESS;
            tx.data = stream_wdata++;
            start_item(tx);
            finish_item(tx);
         end

         // Acknowledge interrupt
         tx = apb_transaction::type_id::create("tx");
         tx.addr = CMD_REG_ADDRESS;
         tx.data = CMD_IRQACK;
         start_item(tx);
         finish_item(tx);
      end

      // 11. Send CMD_STOP
      tx = apb_transaction::type_id::create("tx");
      tx.addr = CMD_REG_ADDRESS;
      tx.data = CMD_STOP;
      start_item(tx);
      finish_item(tx);

      // 12. Send CMD_CLR
      tx = apb_transaction::type_id::create("tx");
      tx.addr = CMD_REG_ADDRESS;
      tx.data = CMD_CLR;
      start_item(tx);
      finish_item(tx);

      // 13. Wait for clear to complete
      #10us;
   
   endtask


   //----------------------------------------------------------------
   // Notice! This sequence can only access the control_unit's APB
   //         bus ports. Therefore the test program functions that need
   //         access to other ports are not implemented.
   //-----------------------------------------------------------------

endclass 
