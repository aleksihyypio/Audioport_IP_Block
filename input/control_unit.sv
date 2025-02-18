`include "audioport.svh"

import audioport_pkg::*;

module control_unit
    (
        input logic 				clk,
        input logic 				rst_n,
        input logic 				PSEL,
        input logic 				PENABLE,
        input logic 				PWRITE,
        input logic [31:0] 			PADDR,
        input logic [31:0] 			PWDATA,
        input logic 				req_in,
        output logic [31:0] 			PRDATA,
        output logic 				PSLVERR,
        output logic 				PREADY,   
        output logic 				irq_out,
        output logic [31:0] 			cfg_reg_out,
        output logic [31:0] 			level_reg_out,
        output logic [DSP_REGISTERS*32-1:0]     dsp_regs_out,
        output logic 				cfg_out,
        output logic 				clr_out,
        output logic 				level_out,
        output logic 				tick_out,
        output logic [23:0] 			audio0_out,
        output logic [23:0] 			audio1_out,
        output logic 				play_out
    );

    // Intergenal signals
    logic [$clog2(AUDIOPORT_REGISTERS+2)-1:0] rindex;
    logic apbwrite;
    logic apbread;
    logic [AUDIOPORT_REGISTERS-1:0][31:0] rbank_r;
    logic [AUDIO_FIFO_SIZE-1:0][23:0] ldata_r, ldata_ns;
    logic [AUDIO_FIFO_SIZE-1:0][23:0] rdata_r, rdata_ns;
    logic [$clog2(AUDIO_FIFO_SIZE)-1:0] lhead_r, lhead_ns, ltail_r, ltail_ns;
    logic [$clog2(AUDIO_FIFO_SIZE)-1:0] rhead_r, rhead_ns, rtail_r, rtail_ns;
    logic llooped_r, llooped_ns, rlooped_r, rlooped_ns;
    logic lempty, lfull, rempty, rfull;
    logic [23:0] lfifo, rfifo;
    logic start, stop, irqack;
    logic play_r, req_r, irq_r;
    logic clr;

    // APB3 Protocol Assumptions
    assign PSLVERR = 1'b0;  // No errors, always '0
    assign PREADY = 1'b1;   // Always ready, zero wait states

    // Register bank implementation (Style 1)
    always_ff @(posedge clk or negedge rst_n) begin : register_bank
        if (!rst_n)
            rbank_r <= '0;
        else begin
            // APB write to register bank
            if (apbwrite && rindex < AUDIOPORT_REGISTERS)
                rbank_r[rindex] <= PWDATA;
            // Set STATUS_PLAY bit to '1 on start command
            if (start)
                rbank_r[STATUS_REG_INDEX][STATUS_PLAY] <= '1;
            // Set STATUS_PLAY bit to '0 on stop command
            else if (stop)
                rbank_r[STATUS_REG_INDEX][STATUS_PLAY] <= '0;
        end
    end : register_bank

    // Address decoding
    always_comb begin : address_decoding
        if (PSEL)
            rindex = PADDR[$clog2(AUDIOPORT_REGISTERS+2)+1:2];
        else
            rindex = '0;
    end : address_decoding

    // APB write and read indicators
    assign apbwrite = PSEL && PENABLE && PWRITE;
    assign apbread = PSEL && PENABLE && !PWRITE;

    // Play Register
    always_ff @(posedge clk or negedge rst_n) begin : play_reg
        if (!rst_n)
            play_r <= 1'b0;
        else if (start)
            play_r <= 1'b1;
        else if (stop)
            play_r <= 1'b0;
    end : play_reg

    // Req Register
    always_ff @(posedge clk or negedge rst_n) begin : req_reg
        if (!rst_n)
            req_r <= 1'b0;
        else if (play_r)
            req_r <= req_in;
        else
            req_r <= 1'b0;
    end : req_reg

    // Command Decoder
    always_comb begin : command_decoder
        start = 1'b0;
        stop = 1'b0;
        cfg_out = 1'b0;
        level_out = 1'b0;
        irqack = 1'b0;
        clr = 1'b0;

        if (apbwrite && rindex == CMD_REG_INDEX) 
            case (PWDATA)
                CMD_CLR:   if (!play_r) clr = 1'b1;
                CMD_CFG:   cfg_out = 1'b1;
                CMD_START: start = 1'b1;
                CMD_STOP:  stop = 1'b1;
                CMD_LEVEL: level_out = 1'b1;
                CMD_IRQACK: irqack = 1'b1;
		default: 
		{clr, cfg_out, start, stop, level_out, irqack} = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
	    endcase
    end : command_decoder

    always_ff @(posedge clk or negedge rst_n) begin
     if (!rst_n)
        irq_r <= 1'b0;
     else if (!play_r)
        irq_r <= 1'b0;
     else if (stop || irqack)
        irq_r <= 1'b0; 
     else if (lempty && rempty)
        irq_r <= 1'b1;  
    end

    // Left Channel FIFO Implementation (Style 2)
    always_ff @(posedge clk or negedge rst_n) begin : left_fifo_registers
     if (!rst_n) begin
            ldata_r <= '0;
            lhead_r <= '0;
            ltail_r <= '0;
            llooped_r <= '0;
     end  
     else begin
        ldata_r <= ldata_ns;
        lhead_r <= lhead_ns;
        ltail_r <= ltail_ns;
        llooped_r <= llooped_ns;
     end
    end : left_fifo_registers

    always_comb begin : left_fifo_next_state
    // Default assignments
    ldata_ns = ldata_r;
    lhead_ns = lhead_r;
    ltail_ns = ltail_r;
    llooped_ns = llooped_r;
    
    // Write to FIFO
    if (apbwrite && rindex == LEFT_FIFO_INDEX && !lfull) begin
        ldata_ns[lhead_r] = PWDATA[23:0];
        if (lhead_r == AUDIO_FIFO_SIZE - 1) begin
            lhead_ns = '0;
            llooped_ns = '1; // Set llooped_r when write pointer wraps
        end else begin
            lhead_ns = lhead_r + 1;
        end
     end
    
    // Read from FIFO
    if ((play_r && req_r && !lempty) || (apbread && rindex == LEFT_FIFO_INDEX && !lempty)) begin
        if (ltail_r == AUDIO_FIFO_SIZE - 1) begin
            ltail_ns = '0;
            llooped_ns = '0; // Clear llooped_r when read pointer catches up
        end else begin
            ltail_ns = ltail_r + 1;
        end
     end

    // Clear FIFO
    if (clr) begin
      ldata_ns = '0;
      lhead_ns = '0;
      ltail_ns = '0;
      llooped_ns = '0;
    end

    end : left_fifo_next_state

    // Left FIFO Status Logic
    assign lempty = (lhead_r == ltail_r) && !llooped_r;
    assign lfull = (lhead_r == ltail_r) && llooped_r;
    assign lfifo = lempty ? '0 : ldata_r[ltail_r];

    // Right Channel FIFO Implementation (Style 2)
    always_ff @(posedge clk or negedge rst_n) begin : right_fifo_registers
     if (!rst_n) begin
        rdata_r <= '0;
        rhead_r <= '0;
        rtail_r <= '0;
        rlooped_r <= '0;
     end
     else begin
        rdata_r <= rdata_ns;
        rhead_r <= rhead_ns;
        rtail_r <= rtail_ns;
        rlooped_r <= rlooped_ns;
    end
    end : right_fifo_registers

    always_comb begin : right_fifo_next_state
    // Default assignments
    rdata_ns = rdata_r;
    rhead_ns = rhead_r;
    rtail_ns = rtail_r;
    rlooped_ns = rlooped_r;

    // Write to FIFO
    if (apbwrite && rindex == RIGHT_FIFO_INDEX && !rfull) begin
        rdata_ns[rhead_r] = PWDATA[23:0];
        if (rhead_r == AUDIO_FIFO_SIZE - 1) begin
            rhead_ns = '0;
            rlooped_ns = '1; // Set rlooped_r when write pointer wraps
        end else begin
            rhead_ns = rhead_r + 1;
        end
     end

    // Read from FIFO
    if ((play_r && req_r && !rempty) || (apbread && rindex == RIGHT_FIFO_INDEX && !rempty)) begin
        if (rtail_r == AUDIO_FIFO_SIZE - 1) begin
            rtail_ns = '0;
            rlooped_ns = '0; 
        end else begin
            rtail_ns = rtail_r + 1;
        end
     end

    // Clear FIFO
    if (clr) begin
      rdata_ns = '0;
      rhead_ns = '0;
      rtail_ns = '0;
      rlooped_ns = '0;
    end

    end : right_fifo_next_state

    // Right FIFO Status Logic
    assign rempty = (rhead_r == rtail_r) && !rlooped_r;
    assign rfull = (rhead_r == rtail_r) && rlooped_r;
    assign rfifo = rempty ? '0 : rdata_r[rtail_r];

    // PRDATA Driving Logic
    always_comb begin : prdata_driving
	// Default
	PRDATA = '0;
        if (PSEL) begin
            if (rindex < AUDIOPORT_REGISTERS)
                PRDATA = rbank_r[rindex];
            else if (rindex == LEFT_FIFO_INDEX)
                PRDATA = {8'b0, lfifo};
            else if (rindex == RIGHT_FIFO_INDEX)
                PRDATA = {8'b0, rfifo};
	end
    end : prdata_driving

    // Output Assignments
    assign play_out = play_r;
    assign irq_out = irq_r;
    assign clr_out = clr;
    assign audio0_out = lfifo;
    assign audio1_out = rfifo;
    assign cfg_reg_out = rbank_r[CFG_REG_INDEX];
    assign level_reg_out = rbank_r[LEVEL_REG_INDEX];
    assign dsp_regs_out = rbank_r[DSP_REGS_END_INDEX:DSP_REGS_START_INDEX];
    assign tick_out = play_r ? req_r : '0;

endmodule
