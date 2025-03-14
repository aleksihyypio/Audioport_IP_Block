`include "audioport.svh"

import audioport_pkg::*;

module cdc_unit
  (
   input logic 	       clk,
   input logic 	       rst_n,
   input logic 	       test_mode_in,
   input logic [23:0]  audio0_in,
   input logic [23:0]  audio1_in,
   input logic 	       play_in,
   input logic 	       tick_in,
   output logic        req_out,

   input logic 	       mclk,
   output logic        muxclk_out,
   output logic        muxrst_n_out,
   output logic [23:0] audio0_out,
   output logic [23:0] audio1_out, 
   output logic        play_out,
   output logic        tick_out,
   input logic 	       req_in		
   );
   
   logic 	       mrst_n;
   logic 	       rsync_clk;
   logic	       reset_ff1;
   logic	       reset_ff2;
   logic	       play_ff1;
   logic	       play_ff2;
   logic	       req_ff1;
   logic	       req_ff2;
   logic [23:0]        tx_r1, tx_r2;
   logic [23:0]        rx_r1, rx_r2;
   logic 	       sreq, sack;
   logic	       req_r1, req_r2;
   logic	       ack_r1, ack_r2;
   typedef enum logic [1:0] {
     TX_IDLE = 2'b00,    
     TX_REQ  = 2'b01,    
     TX_ACK  = 2'b10     
   } tx_state_t;
   typedef enum logic {
     RX_IDLE = 1'b0,    
     RX_ACK  = 1'b1     
   } rx_state_t;
   tx_state_t tx_state, tx_next_state;
   rx_state_t rx_state, rx_next_state;

   always_comb begin : testmux
     if (test_mode_in) begin
	muxclk_out = clk;
	muxrst_n_out = rst_n;
	rsync_clk = clk;
     end else begin
	muxclk_out = mclk;
	muxrst_n_out = mrst_n;
	rsync_clk = ~mclk;
     end
   end : testmux
   
   always_ff @(posedge rsync_clk or negedge rst_n) begin : reset_sync
     if (rst_n == '0) begin
	reset_ff1 <= '0;
	reset_ff2 <= '0;
     end else begin
	reset_ff1 <= rst_n;
	reset_ff2 <= reset_ff1;
     end
   end : reset_sync

   assign mrst_n = reset_ff2;

   always_ff @(posedge mclk or negedge mrst_n) begin : bit_sync
     if (mrst_n == '0) begin
	play_ff1 <= '0;
	play_ff2 <= '0;
     end else begin
	play_ff1 <= play_in;
	play_ff2 <= play_ff1;
     end
   end : bit_sync

   assign play_out = play_ff2;

   always_ff @(posedge clk or negedge mrst_n) begin : req_sync
     if (mrst_n == '0) begin
	req_ff1 <= '0;
	req_ff2 <= '0;
     end else begin
	req_ff1 <= req_in;
	req_ff2 <= req_ff1;
     end
   end : req_sync

   assign req_out = ~req_ff1 & req_ff2;
   
   always_comb begin : tx_fsm_comb
     tx_next_state = tx_state; 
     case (tx_state)
       TX_IDLE: begin
         if (tick_in && !sack) begin
            tx_next_state = TX_REQ;
         end
       end
       TX_REQ: begin
         if (sack) begin
            tx_next_state = TX_ACK;
         end else begin
            tx_next_state = TX_REQ;
         end
       end
       TX_ACK: begin
         if (!sack) begin
            tx_next_state = TX_IDLE;
         end
       end
       default: tx_next_state = TX_IDLE;
     endcase
   end : tx_fsm_comb

   always_ff @(posedge clk or negedge rst_n) begin : tx_register_update
     if (rst_n == '0) begin
        tx_state <= TX_IDLE;
        tx_r1 <= 0;
        tx_r2 <= 0;
     end else begin
        tx_state <= tx_next_state;
        if (tick_in && !sack) begin
	  tx_r1 <= audio0_in;
	  tx_r2 <= audio1_in;
	end
     end
   end : tx_register_update

   always_comb begin : rx_fsm_comb
     rx_next_state = rx_state; 
     case (rx_state)
       RX_IDLE: begin
         tick_out = 0;
         if (sreq) begin
            rx_next_state = RX_ACK;
         end
       end
       RX_ACK: begin
         if (!sreq) begin
            tick_out = 1;
            rx_next_state = RX_IDLE;
         end else begin
            rx_next_state = RX_ACK;
         end
       end
       default: rx_next_state = RX_IDLE;
     endcase
   end : rx_fsm_comb

   always_ff @(posedge mclk or negedge mrst_n) begin : rx_register_update
     if (mrst_n == '0) begin
        rx_state <= RX_IDLE;
        rx_r1 <= 0;
        rx_r2 <= 0;
     end else begin
        rx_state <= rx_next_state; 
        if (sreq) begin
	  rx_r1 <= tx_r1;
	  rx_r2 <= tx_r2;
	end
     end
   end : rx_register_update

   always_ff @(posedge mclk or negedge mrst_n) begin
     if (mrst_n == '0) begin
        req_r1 <= '0;
        req_r2 <= '0;
     end else begin
        req_r1 <= (tx_state == TX_REQ);
        req_r2 <= req_r1;
     end
   end
   assign sreq = req_r2;

   assign audio0_out = rx_r1;
   assign audio1_out = rx_r2;

   always_ff @(posedge clk or negedge rst_n) begin
     if (rst_n == '0) begin
        ack_r1 <= '0;
        ack_r2 <= '0;
     end else begin
        ack_r1 <= (rx_state == RX_ACK);
        ack_r2 <= ack_r1;
     end
   end
   assign sack = ack_r2;

endmodule





