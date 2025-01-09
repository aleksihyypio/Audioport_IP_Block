`include "audioport.svh"

package audioport_pkg;
   import apb_pkg::*;

   //////////////////////////////////////////////////////////////////
   // 1. Project parameters
   //////////////////////////////////////////////////////////////////

`ifndef SYNTHESIS
   string student_number                = "Y58172320";
   localparam realtime CLK_PERIOD       = 10ns;        
   localparam realtime MCLK_PERIOD      = 54.25347222ns; // Same for all students
`endif
   localparam int FILTER_TAPS          = 53;
   localparam int AUDIO_FIFO_SIZE      = 60;

   //////////////////////////////////////////////////////////////////
   // 2. Register counts for address computation
   //////////////////////////////////////////////////////////////////

   // Number of coefficient registers for two FIR filters (2 * FILTER_TAPS)
   localparam int DSP_REGISTERS       = 106;

   // Total number of registers excluding FIFOs
   localparam int AUDIOPORT_REGISTERS = 111;

   //////////////////////////////////////////////////////////////////
   // 3. Register indices (rindex)
   //////////////////////////////////////////////////////////////////

   localparam int CMD_REG_INDEX        = 0;
   localparam int STATUS_REG_INDEX     = 1;
   localparam int LEVEL_REG_INDEX      = 2;
   localparam int CFG_REG_INDEX        = 3;
   localparam int DSP_REGS_START_INDEX = 4;
   localparam int DSP_REGS_END_INDEX   = 110;
   localparam int LEFT_FIFO_INDEX      = 111;
   localparam int RIGHT_FIFO_INDEX     = 171;
   
   //////////////////////////////////////////////////////////////////
   // 4. Register addresses in APB address space
   //////////////////////////////////////////////////////////////////   

   localparam logic [31:0]  AUDIOPORT_START_ADDRESS  = 32'h8c000000;   
   localparam logic [31:0]  AUDIOPORT_END_ADDRESS    = 32'h8c0001B8;   
   localparam logic [31:0]  CMD_REG_ADDRESS          = 32'h8c000000;   
   localparam logic [31:0]  STATUS_REG_ADDRESS       = 32'h8c000004;   
   localparam logic [31:0]  LEVEL_REG_ADDRESS        = 32'h8c000008;   
   localparam logic [31:0]  CFG_REG_ADDRESS          = 32'h8c00000C;   
   localparam logic [31:0]  DSP_REGS_START_ADDRESS   = 32'h8c000010;   
   localparam logic [31:0]  DSP_REGS_END_ADDRESS     = 32'h8c0001B8;   
   localparam logic [31:0]  LEFT_FIFO_ADDRESS        = 32'h8c0001BC;   
   localparam logic [31:0]  RIGHT_FIFO_ADDRESS       = 32'h8c0002AC;   
   
   //////////////////////////////////////////////////////////////////
   // 5. Useful Constants
   //////////////////////////////////////////////////////////////////   

   //----------------------------------------------------------------
   // a: Command register CMD_REG
   //----------------------------------------------------------------
   
   // Command codes (one-hot encoded)    
   localparam logic [31:0]  CMD_NOP =          32'h00000000;
   localparam logic [31:0]  CMD_CLR =          32'h00000001;
   localparam logic [31:0]  CMD_CFG =          32'h00000002;
   localparam logic [31:0]  CMD_START =        32'h00000004;
   localparam logic [31:0]  CMD_STOP =         32'h00000008;
   localparam logic [31:0]  CMD_LEVEL =        32'h00000010;   
   localparam logic [31:0]  CMD_IRQACK =       32'h00000020;

   //----------------------------------------------------------------
   // b: Status register STATUS_REG
   //----------------------------------------------------------------

   localparam int 	   STATUS_PLAY      = 0;
   localparam int 	   STATUS_NODATA    = 1;
   
   //----------------------------------------------------------------   
   // c: Configuration register CFG_REG   
   //----------------------------------------------------------------

   // Config bit indices

   localparam int 	   CFG_FILTER = 0;
   
   // Config bit values

   localparam logic 	   DSP_FILTER_OFF = 1'b0;
   localparam logic 	   DSP_FILTER_ON  = 1'b1;

   //----------------------------------------------------------------   
   // d: Clock divider rations (clk cycles per sample)
   //----------------------------------------------------------------   

`ifndef SYNTHESIS   
   localparam logic [31:0] CLK_DIV_48000  = int'($ceil((1000000000.0/48000.0)/(CLK_PERIOD)));
`endif
   
   //----------------------------------------------------------------      
   // e: Clock divider ratios for I2S interface (same for all students)
   //----------------------------------------------------------------
   
   localparam logic [31:0]  MCLK_DIV_48000 =        8;

   //----------------------------------------------------------------   
   // f: cdc_unit verification settings
   //----------------------------------------------------------------   

`ifndef SYNTHESIS
   localparam int 	    CDC_DATASYNC_INTERVAL   = 6 + int'(6.0*$ceil(MCLK_PERIOD/CLK_PERIOD)); // in clk cycles
   localparam int 	    CDC_DATASYNC_LATENCY    = 6 + int'(3.0*$ceil(MCLK_PERIOD/CLK_PERIOD)); // in mclk cycles
   localparam int 	    CDC_BITSYNC_INTERVAL    = int'($ceil(MCLK_PERIOD/CLK_PERIOD));         // in clk cycles
   localparam int 	    CDC_BITSYNC_LATENCY     = 2;  // in mclk cycles 
   localparam int 	    CDC_PULSESYNC_INTERVAL  = 1;  // in mclk cycles
   localparam int 	    CDC_PULSESYNC_LATENCY    = 2+int'($ceil(MCLK_PERIOD/CLK_PERIOD));      // in clk cycles
`endif

   //----------------------------------------------------------------      
   // g: dsp_unit max latency
   //----------------------------------------------------------------   

`ifndef SYNTHESIS   
   localparam int 	    DSP_UNIT_MAX_LATENCY = int'($ceil(real'(CLK_DIV_48000)/16.0));
`endif

endpackage
   
