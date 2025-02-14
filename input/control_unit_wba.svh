   // PSLVERR : r_pslverr

   property r_pslverr;
     @(posedge clk ) disable iff (rst_n == '0)
       !PSLVERR;
   endproperty

   ar_pslverr: assert property(r_pslverr) else assert_error("ar_pslverr");
   cr_pslverr: cover property(r_pslverr);

   // PREADY : r_pready

   property r_pready;
      @(posedge clk ) disable iff (rst_n == '0)
	PREADY;
   endproperty

   ar_pready: assert property(r_pready) else assert_error("ar_pready");
   cr_pready: cover property(r_pready);

   // rindex : r_rindex_on

   property r_rindex_on;
      @(posedge clk ) disable iff (rst_n == '0)
	PSEL |-> (rindex == PADDR[$clog2(AUDIOPORT_REGISTERS+2)+1:2]);
   endproperty

   ar_rindex_on: assert property(r_rindex_on) else assert_error("ar_rindex_on");
   cr_rindex_on: cover property(r_rindex_on);

   // rindex : r_rindex_off

   property r_rindex_off;
      @(posedge clk ) disable iff (rst_n == '0)
	!PSEL |-> (rindex == 0);
   endproperty

   ar_rindex_off: assert property(r_rindex_off) else assert_error("ar_rindex_off");
   cr_rindex_off: cover property(r_rindex_off);

   // rindex : r_index_range

   property r_index_range;
      @(posedge clk ) disable iff (rst_n == '0)
	rindex >= 0 && rindex < (AUDIOPORT_REGISTERS+2);
   endproperty

   ar_index_range: assert property(r_index_range) else assert_error("ar_index_range");
   cr_index_range: cover property(r_index_range);

   // apbwrite : r_apbwrite_on

    property r_apbwrite_on;
      @(posedge clk ) disable iff (rst_n == '0)
	(PSEL && PENABLE && PREADY && PWRITE) |-> apbwrite;
   endproperty

   ar_apbwrite_on: assert property(r_apbwrite_on) else assert_error("ar_apbwrite_on");
   cr_apbwrite_on: cover property(r_apbwrite_on);

   // apbwrite : r_apbwrite_off

    property r_apbwrite_off;
      @(posedge clk ) disable iff (rst_n == '0)
	!(PSEL && PENABLE && PREADY && PWRITE) |-> !apbwrite;
   endproperty

   ar_apbwrite_off: assert property(r_apbwrite_off) else assert_error("ar_apbwrite_off");
   cr_apbwrite_off: cover property(r_apbwrite_off);

   // apbread : r_apbread_on

    property r_apbread_on;
      @(posedge clk ) disable iff (rst_n == '0)
	(PSEL && PENABLE && PREADY && !PWRITE) |-> apbread;
   endproperty

   ar_apbread_on: assert property(r_apbread_on) else assert_error("ar_apbread_on");
   cr_apbread_on: cover property(r_apbread_on);

   // apbread : r_apbread_off

    property r_apbread_off;
      @(posedge clk ) disable iff (rst_n == '0)
	!(PSEL && PENABLE && PREADY && !PWRITE) |-> !apbread;
   endproperty

   ar_apbread_off: assert property(r_apbread_off) else assert_error("ar_apbread_off");
   cr_apbread_off: cover property(r_apbread_off);

   // rbank_r : r_rbank_r_write

   property r_rbank_r_write;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbwrite && rindex < AUDIOPORT_REGISTERS) |=> rbank_r[$past(rindex)] == $past(PWDATA);
   endproperty

   ar_rbank_r_write: assert property(r_rbank_r_write) else assert_error("ar_rbank_r_write");
   cr_rbank_r_write: cover property(r_rbank_r_write);

   // rbank_r : r_status_reg_play

   property r_status_reg_play;
      @(posedge clk ) disable iff (rst_n == '0)
	start |=> rbank_r[STATUS_REG_INDEX][STATUS_PLAY] == '1;
   endproperty

   ar_status_reg_play: assert property(r_status_reg_play) else assert_error("ar_status_reg_play");
   cr_status_reg_play: cover property(r_status_reg_play);

   // rbank_r : r_status_reg_standby

   property r_status_reg_standby;
      @(posedge clk ) disable iff (rst_n == '0)
	stop |=> rbank_r[STATUS_REG_INDEX][STATUS_PLAY] == '0;
   endproperty

   ar_status_reg_standby: assert property(r_status_reg_standby) else assert_error("ar_status_reg_standby");
   cr_status_reg_standby: cover property(r_status_reg_standby);

   // rbank_r : r_rbank_r_stable

   property r_rbank_r_stable;
      @(posedge clk ) disable iff (rst_n == '0)
	!((apbwrite && rindex < AUDIOPORT_REGISTERS) || start || stop) |=> $stable(rbank_r);
   endproperty

   ar_rbank_r_stable: assert property(r_rbank_r_stable) else assert_error("ar_rbank_r_stable");
   cr_rbank_r_stable: cover property(r_rbank_r_stable);

   // cfg_reg_out : r_cfg_reg_out

   property r_cfg_reg_out;
      @(posedge clk ) disable iff (rst_n == '0)
	cfg_reg_out == rbank_r[CFG_REG_INDEX];
   endproperty

   ar_cfg_reg_out: assert property(r_cfg_reg_out) else assert_error("ar_cfg_reg_out");
   cr_cfg_reg_out: cover property(r_cfg_reg_out);

   // level_reg_out : r_level_reg_out

   property r_level_reg_out;
      @(posedge clk ) disable iff (rst_n == '0)
	level_reg_out == rbank_r[LEVEL_REG_INDEX];
   endproperty

   ar_level_reg_out: assert property(r_level_reg_out) else assert_error("ar_level_reg_out");
   cr_level_reg_out: cover property(r_level_reg_out);

   // dsp_regs_out : r_dsp_regs_out

   property r_dsp_regs_out;
      @(posedge clk ) disable iff (rst_n == '0)
	dsp_regs_out == rbank_r[DSP_REGS_END_INDEX:DSP_REGS_START_INDEX];
   endproperty

   ar_dsp_regs_out: assert property(r_dsp_regs_out) else assert_error("ar_dsp_regs_out");
   cr_dsp_regs_out: cover property(r_dsp_regs_out);

////////////////////////////
   // ldata_r : r_ldata_r_write

   property r_ldata_r_write;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbwrite && rindex == LEFT_FIFO_INDEX && !lfull) |=> ldata_r[$past(lhead_r)] == $past(PWDATA[23:0]);
   endproperty

   ar_ldata_r_write: assert property(r_ldata_r_write) else assert_error("ar_ldata_r_write");
   cr_ldata_r_write: cover property(r_ldata_r_write);

   // ldata_r : r_ldata_r_failed_write

   property r_ldata_r_failed_write;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbwrite && rindex == LEFT_FIFO_INDEX && lfull) |=> $stable(ldata_r[$past(lhead_r)]);
   endproperty

   ar_ldata_r_failed_write: assert property(r_ldata_r_failed_write) else assert_error("ar_ldata_r_failed_write");
   cr_ldata_r_failed_write: cover property(r_ldata_r_failed_write);

   // ldata_r : r_ldata_r_stable

   property r_ldata_r_stable;
      @(posedge clk ) disable iff (rst_n == '0)
	!(apbwrite && rindex == LEFT_FIFO_INDEX) && !clr |=> $stable(ldata_r);
   endproperty

   ar_ldata_r_stable: assert property(r_ldata_r_stable) else assert_error("ar_ldata_r_stable");
   cr_ldata_r_stable: cover property(r_ldata_r_stable);

   // lhead_r : r_lhead_r_inc

   property r_lhead_r_inc;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbwrite && rindex == LEFT_FIFO_INDEX && !lfull && lhead_r != (AUDIO_FIFO_SIZE-1)) |=> lhead_r == $past(lhead_r) + 1;
   endproperty

   ar_lhead_r_inc: assert property(r_lhead_r_inc) else assert_error("ar_lhead_r_inc");
   cr_lhead_r_inc: cover property(r_lhead_r_inc);

   // lhead_r : r_lhead_r_loop

   property r_lhead_r_loop;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbwrite && rindex == LEFT_FIFO_INDEX && !lfull && lhead_r == (AUDIO_FIFO_SIZE-1)) |=> lhead_r == 0;
   endproperty

   ar_lhead_r_loop: assert property(r_lhead_r_loop) else assert_error("ar_lhead_r_loop");
   cr_lhead_r_loop: cover property(r_lhead_r_loop);

   // lhead_r : r_lhead_r_stable

   property r_lhead_r_stable;
      @(posedge clk ) disable iff (rst_n == '0)
	(!(apbwrite && rindex == LEFT_FIFO_INDEX && !lfull) && !clr) |=> $stable(lhead_r);
   endproperty

   ar_lhead_r_stable: assert property(r_lhead_r_stable) else assert_error("ar_lhead_r_stable");
   cr_lhead_r_stable: cover property(r_lhead_r_stable);

   // llooped_r : r_llooped_r_on

   property r_llooped_r_on;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbwrite && rindex == LEFT_FIFO_INDEX && !lfull && lhead_r == (AUDIO_FIFO_SIZE-1)) |=> llooped_r;
   endproperty

   ar_llooped_r_on: assert property(r_llooped_r_on) else assert_error("ar_llooped_r_on");
   cr_llooped_r_on: cover property(r_llooped_r_on);

   // llooped_r : r_llooped_r_off_1

   property r_llooped_r_off_1;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbread && rindex == LEFT_FIFO_INDEX && !lempty && ltail_r == (AUDIO_FIFO_SIZE-1)) |=> !llooped_r;
   endproperty

   ar_llooped_r_off_1: assert property(r_llooped_r_off_1) else assert_error("ar_llooped_r_off_1");
   cr_llooped_r_off_1: cover property(r_llooped_r_off_1);

   // llooped_r : r_llooped_r_off_2

   property r_llooped_r_off_2;
      @(posedge clk ) disable iff (rst_n == '0)
	(play_r && req_r && !lempty && ltail_r == (AUDIO_FIFO_SIZE-1)) |=> !llooped_r;
   endproperty

   ar_llooped_r_off_2: assert property(r_llooped_r_off_2) else assert_error("ar_llooped_r_off_2");
   cr_llooped_r_off_2: cover property(r_llooped_r_off_2);

   // llooped_r : r_llooped_r_stable

   property r_llooped_r_stable;
      @(posedge clk ) disable iff (rst_n == '0)
	!(apbwrite && rindex == LEFT_FIFO_INDEX && !lfull) && !(apbread && rindex == LEFT_FIFO_INDEX && !lempty) && !(play_r && req_r && !lempty) && !clr |=> $stable(llooped_r);
   endproperty

   ar_llooped_r_stable: assert property(r_llooped_r_stable) else assert_error("ar_llooped_r_stable");
   cr_llooped_r_stable: cover property(r_llooped_r_stable);

   // ltail_r : r_ltail_r_inc_1

   property r_ltail_r_inc_1;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbread && rindex == LEFT_FIFO_INDEX && !lempty && ltail_r != (AUDIO_FIFO_SIZE-1)) |=> ltail_r == $past(ltail_r) + 1;
   endproperty

   ar_ltail_r_inc_1: assert property(r_ltail_r_inc_1) else assert_error("ar_ltail_r_inc_1");
   cr_ltail_r_inc_1: cover property(r_ltail_r_inc_1);

   // ltail_r : r_ltail_r_inc_2

   property r_ltail_r_inc_2;
      @(posedge clk ) disable iff (rst_n == '0)
	(play_r && req_r && !lempty && ltail_r != (AUDIO_FIFO_SIZE-1)) |=> ltail_r == $past(ltail_r) + 1;
   endproperty

   ar_ltail_r_inc_2: assert property(r_ltail_r_inc_2) else assert_error("ar_ltail_r_inc_2");
   cr_ltail_r_inc_2: cover property(r_ltail_r_inc_2);

   // ltail_r : r_ltail_r_loop_1

   property r_ltail_r_loop_1;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbread && rindex == LEFT_FIFO_INDEX && !lempty && ltail_r == (AUDIO_FIFO_SIZE-1)) |=> ltail_r == 0;
   endproperty

   ar_ltail_r_loop_1: assert property(r_ltail_r_loop_1) else assert_error("ar_ltail_r_loop_1");
   cr_ltail_r_loop_1: cover property(r_ltail_r_loop_1);

   // ltail_r : r_ltail_r_loop_2

   property r_ltail_r_loop_2;
      @(posedge clk ) disable iff (rst_n == '0)
	(play_r && req_r && !lempty && ltail_r == (AUDIO_FIFO_SIZE-1)) |=> ltail_r == 0;
   endproperty

   ar_ltail_r_loop_2: assert property(r_ltail_r_loop_2) else assert_error("ar_ltail_r_loop_2");
   cr_ltail_r_loop_2: cover property(r_ltail_r_loop_2);

   // ltail_r : r_ltail_r_stable

   property r_ltail_r_stable;
      @(posedge clk ) disable iff (rst_n == '0)
	!(apbread && rindex == LEFT_FIFO_INDEX && !lempty) &&
	 !(play_r && req_r && !lempty) && !clr |=> $stable(ltail_r);
   endproperty

   ar_ltail_r_stable: assert property(r_ltail_r_stable) else assert_error("ar_ltail_r_stable");
   cr_ltail_r_stable: cover property(r_ltail_r_stable);

   // lempty : r_lempty_on

   property r_lempty_on;
      @(posedge clk ) disable iff (rst_n == '0)
	(lhead_r == ltail_r) && !llooped_r |-> lempty;
   endproperty

   ar_lempty_on: assert property(r_lempty_on) else assert_error("ar_lempty_on");
   cr_lempty_on: cover property(r_lempty_on);

   // lempty : r_lempty_of

   property r_lempty_of;
      @(posedge clk ) disable iff (rst_n == '0)
	!( (lhead_r == ltail_r) && !llooped_r) |-> !lempty;
   endproperty

   ar_lempty_of: assert property(r_lempty_of) else assert_error("ar_lempty_of");
   cr_lempty_of: cover property(r_lempty_of);

   // lfull : r_lfull_on

   property r_lfull_on;
      @(posedge clk ) disable iff (rst_n == '0)
	(lhead_r == ltail_r) && llooped_r |-> lfull;
   endproperty

   ar_lfull_on: assert property(r_lfull_on) else assert_error("ar_lfull_on");
   cr_lfull_on: cover property(r_lfull_on);

   // lfull : r_lfull_off

   property r_lfull_off;
      @(posedge clk ) disable iff (rst_n == '0)
	!( (lhead_r == ltail_r) && llooped_r) |-> !lfull;
   endproperty

   ar_lfull_off: assert property(r_lfull_off) else assert_error("ar_lfull_off");
   cr_lfull_off: cover property(r_lfull_off);

   // lfifo : r_lfifo_output_on

   property r_lfifo_output_on;
      @(posedge clk ) disable iff (rst_n == '0)
	!lempty |-> lfifo == ldata_r[ltail_r];
   endproperty

   ar_lfifo_output_on: assert property(r_lfifo_output_on) else assert_error("ar_lfifo_output_on");
   cr_lfifo_output_on: cover property(r_lfifo_output_on);

   // lfifo : r_lfifo_output_off

   property r_lfifo_output_off;
      @(posedge clk ) disable iff (rst_n == '0)
	lempty |-> lfifo == 0;
   endproperty

   ar_lfifo_output_off: assert property(r_lfifo_output_off) else assert_error("ar_lfifo_output_off");
   cr_lfifo_output_off: cover property(r_lfifo_output_off);

///////////////

   // rdata_r : r_rdata_r_write

   property r_rdata_r_write;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbwrite && rindex == RIGHT_FIFO_INDEX && !rfull) |=> rdata_r[$past(rhead_r)] == $past(PWDATA[23:0]);
   endproperty

   ar_rdata_r_write: assert property(r_rdata_r_write) else assert_error("ar_rdata_r_write");
   cr_rdata_r_write: cover property(r_rdata_r_write);

   // rdata_r : r_rdata_r_failed_write

   property r_rdata_r_failed_write;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbwrite && rindex == RIGHT_FIFO_INDEX && rfull) |=> $stable(rdata_r[$past(rhead_r)]);
   endproperty

   ar_rdata_r_failed_write: assert property(r_rdata_r_failed_write) else assert_error("ar_rdata_r_failed_write");
   cr_rdata_r_failed_write: cover property(r_rdata_r_failed_write);

   // rdata_r : r_rdata_r_stable

   property r_rdata_r_stable;
      @(posedge clk ) disable iff (rst_n == '0)
	!(apbwrite && rindex == RIGHT_FIFO_INDEX) && !clr |=> $stable(rdata_r);
   endproperty

   ar_rdata_r_stable: assert property(r_rdata_r_stable) else assert_error("ar_rdata_r_stable");
   cr_rdata_r_stable: cover property(r_rdata_r_stable);

   // rhead_r : r_rhead_r_inc

   property r_rhead_r_inc;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbwrite && rindex == RIGHT_FIFO_INDEX && !rfull && rhead_r != (AUDIO_FIFO_SIZE-1)) |=> rhead_r == $past(rhead_r) + 1;
   endproperty

   ar_rhead_r_inc: assert property(r_rhead_r_inc) else assert_error("ar_rhead_r_inc");
   cr_rhead_r_inc: cover property(r_rhead_r_inc);

   // rhead_r : r_rhead_r_loop

   property r_rhead_r_loop;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbwrite && rindex == RIGHT_FIFO_INDEX && !rfull && rhead_r == (AUDIO_FIFO_SIZE-1)) |=> rhead_r == 0;
   endproperty

   ar_rhead_r_loop: assert property(r_rhead_r_loop) else assert_error("ar_rhead_r_loop");
   cr_rhead_r_loop: cover property(r_rhead_r_loop);

   // rhead_r : r_rhead_r_stable

   property r_rhead_r_stable;
      @(posedge clk ) disable iff (rst_n == '0)
	(!(apbwrite && rindex == RIGHT_FIFO_INDEX && !rfull) && !clr) |=> $stable(rhead_r);
   endproperty

   ar_rhead_r_stable: assert property(r_rhead_r_stable) else assert_error("ar_rhead_r_stable");
   cr_rhead_r_stable: cover property(r_rhead_r_stable);

   // rlooped_r : r_rlooped_r_on

   property r_rlooped_r_on;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbwrite && rindex == RIGHT_FIFO_INDEX && !rfull && rhead_r == (AUDIO_FIFO_SIZE-1)) |=> rlooped_r;
   endproperty

   ar_rlooped_r_on: assert property(r_rlooped_r_on) else assert_error("ar_rlooped_r_on");
   cr_rlooped_r_on: cover property(r_rlooped_r_on);

   // rlooped_r : r_rlooped_r_off_1

   property r_rlooped_r_off_1;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbread && rindex == RIGHT_FIFO_INDEX && !rempty && rtail_r == (AUDIO_FIFO_SIZE-1)) |=> !rlooped_r;
   endproperty

   ar_rlooped_r_off_1: assert property(r_rlooped_r_off_1) else assert_error("ar_rlooped_r_off_1");
   cr_rlooped_r_off_1: cover property(r_rlooped_r_off_1);

   // rlooped_r : r_rlooped_r_off_2

   property r_rlooped_r_off_2;
      @(posedge clk ) disable iff (rst_n == '0)
	(play_r && req_r && !rempty && rtail_r == (AUDIO_FIFO_SIZE-1)) |=> !rlooped_r;
   endproperty

   ar_rlooped_r_off_2: assert property(r_rlooped_r_off_2) else assert_error("ar_rlooped_r_off_2");
   cr_rlooped_r_off_2: cover property(r_rlooped_r_off_2);

   // rlooped_r : r_rlooped_r_stable

   property r_rlooped_r_stable;
      @(posedge clk ) disable iff (rst_n == '0)
	!(apbwrite && rindex == RIGHT_FIFO_INDEX && !rfull) && !(apbread && rindex == RIGHT_FIFO_INDEX && !rempty) && !(play_r && req_r && !rempty) && !clr |=> $stable(rlooped_r);
   endproperty

   ar_rlooped_r_stable: assert property(r_rlooped_r_stable) else assert_error("ar_rlooped_r_stable");
   cr_rlooped_r_stable: cover property(r_rlooped_r_stable);

   // rtail_r : r_rtail_r_inc_1

   property r_rtail_r_inc_1;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbread && rindex == RIGHT_FIFO_INDEX && !rempty && rtail_r != (AUDIO_FIFO_SIZE-1)) |=> rtail_r == $past(rtail_r) + 1;
   endproperty

   ar_rtail_r_inc_1: assert property(r_rtail_r_inc_1) else assert_error("ar_rtail_r_inc_1");
   cr_rtail_r_inc_1: cover property(r_rtail_r_inc_1);

   // rtail_r : r_rtail_r_inc_2

   property r_rtail_r_inc_2;
      @(posedge clk ) disable iff (rst_n == '0)
	(play_r && req_r && !rempty && rtail_r != (AUDIO_FIFO_SIZE-1)) |=> rtail_r == $past(rtail_r) + 1;
   endproperty

   ar_rtail_r_inc_2: assert property(r_rtail_r_inc_2) else assert_error("ar_rtail_r_inc_2");
   cr_rtail_r_inc_2: cover property(r_rtail_r_inc_2);

   // rtail_r : r_rtail_r_loop_1

   property r_rtail_r_loop_1;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbread && rindex == RIGHT_FIFO_INDEX && !rempty && rtail_r == (AUDIO_FIFO_SIZE-1)) |=> rtail_r == 0;
   endproperty

   ar_rtail_r_loop_1: assert property(r_rtail_r_loop_1) else assert_error("ar_rtail_r_loop_1");
   cr_rtail_r_loop_1: cover property(r_rtail_r_loop_1);

   // rtail_r : r_rtail_r_loop_2

   property r_rtail_r_loop_2;
      @(posedge clk ) disable iff (rst_n == '0)
	(play_r && req_r && !rempty && rtail_r == (AUDIO_FIFO_SIZE-1)) |=> rtail_r == 0;
   endproperty

   ar_rtail_r_loop_2: assert property(r_rtail_r_loop_2) else assert_error("ar_rtail_r_loop_2");
   cr_rtail_r_loop_2: cover property(r_rtail_r_loop_2);

   // rtail_r : r_rtail_r_stable

   property r_rtail_r_stable;
      @(posedge clk ) disable iff (rst_n == '0)
	!(apbread && rindex == RIGHT_FIFO_INDEX && !rempty) &&
	 !(play_r && req_r && !rempty) && !clr |=> $stable(rtail_r);
   endproperty

   ar_rtail_r_stable: assert property(r_rtail_r_stable) else assert_error("ar_rtail_r_stable");
   cr_rtail_r_stable: cover property(r_rtail_r_stable);

   // rempty : r_rempty_on

   property r_rempty_on;
      @(posedge clk ) disable iff (rst_n == '0)
	(rhead_r == rtail_r) && !rlooped_r |-> rempty;
   endproperty

   ar_rempty_on: assert property(r_rempty_on) else assert_error("ar_rempty_on");
   cr_rempty_on: cover property(r_rempty_on);

   // rempty : r_rempty_of

   property r_rempty_of;
      @(posedge clk ) disable iff (rst_n == '0)
	!( (rhead_r == rtail_r) && !rlooped_r) |-> !rempty;
   endproperty

   ar_rempty_of: assert property(r_rempty_of) else assert_error("ar_rempty_of");
   cr_rempty_of: cover property(r_rempty_of);

   // rfull : r_rfull_on

   property r_rfull_on;
      @(posedge clk ) disable iff (rst_n == '0)
	(rhead_r == rtail_r) && rlooped_r |-> rfull;
   endproperty

   ar_rfull_on: assert property(r_rfull_on) else assert_error("ar_rfull_on");
   cr_rfull_on: cover property(r_rfull_on);

   // rfull : r_rfull_off

   property r_rfull_off;
      @(posedge clk ) disable iff (rst_n == '0)
	!( (rhead_r == rtail_r) && rlooped_r) |-> !rfull;
   endproperty

   ar_rfull_off: assert property(r_rfull_off) else assert_error("ar_rfull_off");
   cr_rfull_off: cover property(r_rfull_off);

   // rfifo : r_rfifo_output_on

   property r_rfifo_output_on;
      @(posedge clk ) disable iff (rst_n == '0)
	!rempty |-> rfifo == rdata_r[rtail_r];
   endproperty

   ar_rfifo_output_on: assert property(r_rfifo_output_on) else assert_error("ar_rfifo_output_on");
   cr_rfifo_output_on: cover property(r_rfifo_output_on);

   // rfifo : r_rfifo_output_off

   property r_rfifo_output_off;
      @(posedge clk ) disable iff (rst_n == '0)
	rempty |-> rfifo == 0;
   endproperty

   ar_rfifo_output_off: assert property(r_rfifo_output_off) else assert_error("ar_rfifo_output_off");
   cr_rfifo_output_off: cover property(r_rfifo_output_off);

///////////////


   // PRDATA : r_prdata_rbank

   property r_prdata_rbank;
      @(posedge clk ) disable iff (rst_n == '0)
	PSEL && rindex < AUDIOPORT_REGISTERS |-> PRDATA == rbank_r[rindex];
   endproperty

   ar_prdata_rbank: assert property(r_prdata_rbank) else assert_error("ar_prdata_rbank");
   cr_prdata_rbank: cover property(r_prdata_rbank);

   // PRDATA : r_prdata_lfifo

   property r_prdata_lfifo;
      @(posedge clk ) disable iff (rst_n == '0)
	PSEL && rindex == LEFT_FIFO_INDEX |-> PRDATA == lfifo;
   endproperty

   ar_prdata_lfifo: assert property(r_prdata_lfifo) else assert_error("ar_prdata_lfifo");
   cr_prdata_lfifo: cover property(r_prdata_lfifo);

   // PRDATA : r_prdata_rfifo

   property r_prdata_rfifo;
      @(posedge clk ) disable iff (rst_n == '0)
	PSEL && rindex == RIGHT_FIFO_INDEX |-> PRDATA == rfifo;
   endproperty

   ar_prdata_rfifo: assert property(r_prdata_rfifo) else assert_error("ar_prdata_rfifo");
   cr_prdata_rfifo: cover property(r_prdata_rfifo);

   // PRDATA : r_prdata_off

   property r_prdata_off;
      @(posedge clk ) disable iff (rst_n == '0)
	!PSEL |-> PRDATA == 0;
   endproperty

   ar_prdata_off: assert property(r_prdata_off) else assert_error("ar_prdata_off");
   cr_prdata_off: cover property(r_prdata_off);

   // play_r : r_play_r_rise

   property r_play_r_rise;
      @(posedge clk ) disable iff (rst_n == '0)
	start |=> play_r;
   endproperty

   ar_play_r_rise: assert property(r_play_r_rise) else assert_error("ar_play_r_rise");
   cr_play_r_rise: cover property(r_play_r_rise);

   // play_r : r_play_r_fall

   property r_play_r_fall;
      @(posedge clk ) disable iff (rst_n == '0)
	stop |=> !play_r;
   endproperty

   ar_play_r_fall: assert property(r_play_r_fall) else assert_error("ar_play_r_fall");
   cr_play_r_fall: cover property(r_play_r_fall);

   // play_r : r_play_r_stable

   property r_play_r_stable;
      @(posedge clk ) disable iff (rst_n == '0)
	(!start && !stop) |=> $stable(play_r);
   endproperty

   ar_play_r_stable: assert property(r_play_r_stable) else assert_error("ar_play_r_stable");
   cr_play_r_stable: cover property(r_play_r_stable);

   // play_out : r_play_out_state

   property r_play_out_state;
      @(posedge clk ) disable iff (rst_n == '0)
	play_out == play_r;
   endproperty

   ar_play_out_state: assert property(r_play_out_state) else assert_error("ar_play_out_state");
   cr_play_out_state: cover property(r_play_out_state);

   // clr : r_clr_on

   property r_clr_on;
      @(posedge clk ) disable iff (rst_n == '0)
	(!play_r && apbwrite && (rindex == CMD_REG_INDEX)&& (PWDATA == CMD_CLR)) |-> clr;
   endproperty

   ar_clr_on: assert property(r_clr_on) else assert_error("ar_clr_on");
   cr_clr_on: cover property(r_clr_on);

   // clr : r_clr_off

   property r_clr_off;
      @(posedge clk ) disable iff (rst_n == '0)
	!(!play_r && apbwrite && (rindex == CMD_REG_INDEX) && (PWDATA == CMD_CLR)) |-> !clr;
   endproperty

   ar_clr_off: assert property(r_clr_off) else assert_error("ar_clr_off");
   cr_clr_off: cover property(r_clr_off);

   // clr_out : r_clr_out

   property r_clr_out;
      @(posedge clk ) disable iff (rst_n == '0)
	clr_out == clr;
   endproperty

   ar_clr_out: assert property(r_clr_out) else assert_error("ar_clr_out");
   cr_clr_out: cover property(r_clr_out);

   // cfg_out : r_cfg_out_on

   property r_cfg_out_on;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbwrite && (rindex == CMD_REG_INDEX)&& (PWDATA == CMD_CFG)) |-> cfg_out;
   endproperty

   ar_cfg_out_on: assert property(r_cfg_out_on) else assert_error("ar_cfg_out_on");
   cr_cfg_out_on: cover property(r_cfg_out_on);

   // cfg_out : r_cfg_out_off

   property r_cfg_out_off;
      @(posedge clk ) disable iff (rst_n == '0)
	!(apbwrite && (rindex == CMD_REG_INDEX)&& (PWDATA == CMD_CFG)) |-> !cfg_out;
   endproperty

   ar_cfg_out_off: assert property(r_cfg_out_off) else assert_error("ar_cfg_out_off");
   cr_cfg_out_off: cover property(r_cfg_out_off);

   // start : r_start_on

   property r_start_on;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbwrite && (rindex == CMD_REG_INDEX) && (PWDATA == CMD_START) ) |-> start;
   endproperty

   ar_start_on: assert property(r_start_on) else assert_error("ar_start_on");
   cr_start_on: cover property(r_start_on);

   // start : r_start_off

   property r_start_off;
      @(posedge clk ) disable iff (rst_n == '0)
	!(apbwrite && (rindex == CMD_REG_INDEX) && (PWDATA == CMD_START) ) |-> !start;
   endproperty

   ar_start_off: assert property(r_start_off) else assert_error("ar_start_off");
   cr_start_off: cover property(r_start_off);

   // stop : r_stop_on

   property r_stop_on;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbwrite && (rindex == CMD_REG_INDEX) && (PWDATA == CMD_STOP) ) |-> stop;
   endproperty

   ar_stop_on: assert property(r_stop_on) else assert_error("ar_stop_on");
   cr_stop_on: cover property(r_stop_on);

   // stop : r_stop_off

   property r_stop_off;
      @(posedge clk ) disable iff (rst_n == '0)
	!(apbwrite && (rindex == CMD_REG_INDEX) && (PWDATA == CMD_STOP) ) |-> !stop;
   endproperty

   ar_stop_off: assert property(r_stop_off) else assert_error("ar_stop_off");
   cr_stop_off: cover property(r_stop_off);

   // level_out : r_level_out_on

   property r_level_out_on;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbwrite && (rindex == CMD_REG_INDEX) && (PWDATA == CMD_LEVEL) ) |-> level_out;
   endproperty

   ar_level_out_on: assert property(r_level_out_on) else assert_error("ar_level_out_on");
   cr_level_out_on: cover property(r_level_out_on);

   // level_out : r_level_out_off

   property r_level_out_off;
      @(posedge clk ) disable iff (rst_n == '0)
	!(apbwrite && (rindex == CMD_REG_INDEX) && (PWDATA == CMD_LEVEL) ) |-> !level_out;
   endproperty

   ar_level_out_off: assert property(r_level_out_off) else assert_error("ar_level_out_off");
   cr_level_out_off: cover property(r_level_out_off);

   // irqack : r_irqack_on

   property r_irqack_on;
      @(posedge clk ) disable iff (rst_n == '0)
	(apbwrite && (rindex == CMD_REG_INDEX) && (PWDATA == CMD_IRQACK) ) |-> irqack;
   endproperty

   ar_irqack_on: assert property(r_irqack_on) else assert_error("ar_irqack_on");
   cr_irqack_on: cover property(r_irqack_on);

   // irqack : r_irqack_off

   property r_irqack_off;
      @(posedge clk ) disable iff (rst_n == '0)
	!(apbwrite && (rindex == CMD_REG_INDEX) && (PWDATA == CMD_IRQACK) ) |-> !irqack;
   endproperty

   ar_irqack_off: assert property(r_irqack_off) else assert_error("ar_irqack_off");
   cr_irqack_off: cover property(r_irqack_off);

   // tick_out : r_tick_out_on

   property r_tick_out_on;
      @(posedge clk ) disable iff (rst_n == '0)
	!play_r |-> !tick_out;
   endproperty

   ar_tick_out_on: assert property(r_tick_out_on) else assert_error("ar_tick_out_on");
   cr_tick_out_on: cover property(r_tick_out_on);

   // tick_out : r_tick_out_of

   property r_tick_out_of;
      @(posedge clk ) disable iff (rst_n == '0)
	play_r |-> (tick_out == req_r);
   endproperty

   ar_tick_out_of: assert property(r_tick_out_of) else assert_error("ar_tick_out_of");
   cr_tick_out_of: cover property(r_tick_out_of);

   // req_r : r_req_r_on

   property r_req_r_on;
      @(posedge clk ) disable iff (rst_n == '0)
	play_r |=> req_r == $past(req_in);
   endproperty

   ar_req_r_on: assert property(r_req_r_on) else assert_error("ar_req_r_on");
   cr_req_r_on: cover property(r_req_r_on);

   // req_r : r_req_r_off

   property r_req_r_off;
      @(posedge clk ) disable iff (rst_n == '0)
	!play_r |=> !req_r;
   endproperty

   ar_req_r_off: assert property(r_req_r_off) else assert_error("ar_req_r_off");
   cr_req_r_off: cover property(r_req_r_off);

   // irq_r : r_irq_r_rise

   property r_irq_r_rise;
      @(posedge clk ) disable iff (rst_n == '0)
	(!stop && ! irqack && play_r && lempty && rempty) |=> irq_r;
   endproperty

   ar_irq_r_rise: assert property(r_irq_r_rise) else assert_error("ar_irq_r_rise");
   cr_irq_r_rise: cover property(r_irq_r_rise);

   // irq_r : r_irq_r_fall_stop

   property r_irq_r_fall_stop;
      @(posedge clk ) disable iff (rst_n == '0)
	stop |=> !irq_r;
   endproperty

   ar_irq_r_fall_stop: assert property(r_irq_r_fall_stop) else assert_error("ar_irq_r_fall_stop");
   cr_irq_r_fall_stop: cover property(r_irq_r_fall_stop);

   // irq_r : r_irq_r_fall_irqack

   property r_irq_r_fall_irqack;
      @(posedge clk ) disable iff (rst_n == '0)
	irqack |=> !irq_r;
   endproperty

   ar_irq_r_fall_irqack: assert property(r_irq_r_fall_irqack) else assert_error("ar_irq_r_fall_irqack");
   cr_irq_r_fall_irqack: cover property(r_irq_r_fall_irqack);

   // irq_r : r_irq_r_stable

   property r_irq_r_stable;
      @(posedge clk ) disable iff (rst_n == '0)
	!( (!stop && !irqack && play_r && lempty && rempty) || stop || irqack ) |=> $stable(irq_r);
   endproperty

   ar_irq_r_stable: assert property(r_irq_r_stable) else assert_error("ar_irq_r_stable");
   cr_irq_r_stable: cover property(r_irq_r_stable);

   // irq_out : r_irq_out

   property r_irq_out;
      @(posedge clk ) disable iff (rst_n == '0)
	irq_out == irq_r;
   endproperty

   ar_irq_out: assert property(r_irq_out) else assert_error("ar_irq_out");
   cr_irq_out: cover property(r_irq_out);


