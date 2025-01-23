`ifndef SYNTHESIS

`include "audioport.svh"

import apb_pkg::*;
import audioport_pkg::*;
import audioport_util_pkg::*;

module control_unit_tb;
   
   logic clk;
   logic rst_n;

   // Signals connect to DUT ports

   logic PSEL;
   logic PENABLE;
   logic PWRITE;
   logic [31:0] PADDR;
   logic [31:0] PWDATA;
   logic [31:0] PRDATA;
   logic 	PREADY;
   logic 	PSLVERR;

   logic [23:0] audio0_out;
   logic [23:0] audio1_out;      
   logic 	irq_out;
   logic 	cfg_out;
   logic 	level_out;
   logic 	clr_out;   
   logic [31:0] cfg_reg_out;
   logic [31:0] level_reg_out;
   logic [DSP_REGISTERS*32-1:0] dsp_regs_out;
   logic 			play_out;
   logic 			tick_out;
   logic 			req_in;
   

   ////////////////////////////////////////////////////////////////////////////
   // Interface object declarations and connections
   ////////////////////////////////////////////////////////////////////////////
   
   apb_if apb(clk, rst_n);   
   irq_out_if irq(clk, rst_n);   

   assign PSEL = apb.psel;
   assign PENABLE = apb.penable;   
   assign PWRITE = apb.pwrite;
   assign PADDR = apb.paddr;
   assign PWDATA = apb.pwdata;
   assign apb.prdata = PRDATA;
   assign apb.pready = ((PADDR >= DUT_START_ADDRESS && PADDR <= DUT_END_ADDRESS ) ? PREADY : 1'b1);
   assign apb.pslverr = ((PADDR >= DUT_START_ADDRESS && PADDR <= DUT_END_ADDRESS)  ? PSLVERR : 1'b0);

   assign irq.irq_out = irq_out;   

   ////////////////////////////////////////////////////////////////////////////
   // Clock generation (reset is in test program)
   ////////////////////////////////////////////////////////////////////////////

   initial
     begin
	clk = '0;
	forever #(CLK_PERIOD/2) clk = ~clk;
     end
   
   ////////////////////////////////////////////////////////////////////////////
   // DUT instantiation
   ////////////////////////////////////////////////////////////////////////////
   
   control_unit DUT_INSTANCE
     (.clk(clk),
      .rst_n(rst_n),
      .PSEL(PSEL),
      .PENABLE(PENABLE),
      .PWRITE(PWRITE),
      .PADDR(PADDR),	      
      .PWDATA(PWDATA),
      .PRDATA(PRDATA),
      .PREADY(PREADY),
      .PSLVERR(PSLVERR),
      .clr_out(clr_out),   
      .cfg_out(cfg_out),
      .cfg_reg_out(cfg_reg_out),
      .level_out(level_out),
      .level_reg_out(level_reg_out),
      .dsp_regs_out(dsp_regs_out),
      .audio0_out(audio0_out),
      .audio1_out(audio1_out),
      .irq_out(irq_out),
      .tick_out(tick_out),
      .play_out(play_out),      
      .req_in(req_in)
      );

   ////////////////////////////////////////////////////////////////////////////
   // Include SVA assertion module bindings
   ////////////////////////////////////////////////////////////////////////////

 `include "sva_bindings.svh"
   
   ////////////////////////////////////////////////////////////////////////////
   // Test program instantiation
   ////////////////////////////////////////////////////////////////////////////
   
   control_unit_test TEST (.clk(clk),
			   .rst_n(rst_n),
			   .apb(apb),
			   .irq(irq),			   
			   .cfg_out(cfg_out),
			   .cfg_reg_out(cfg_reg_out),
			   .level_out(level_out),
			   .level_reg_out(level_reg_out),
			   .dsp_regs_out(dsp_regs_out),
			   .clr_out(clr_out),
			   .audio0_out(audio0_out),
			   .audio1_out(audio1_out),
			   .play_out(play_out),
			   .tick_out(tick_out),
			   .req_in(req_in)
			   );
   
   initial
     begin
	save_test_parameters("reports/3_vsim_control_unit_test_parameters.txt");	
     end
   
endmodule 



`endif
