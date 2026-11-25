module fifo_1r1w_cdc
 #(parameter [31:0] width_p = 32
  ,parameter [31:0] depth_log2_p = 8
  )
  (input [0:0] cclk_i // for c domain inelastics/syncs
  ,input [0:0] creset_i // for c domain inelastics/syncs
  ,input [width_p - 1:0] cdata_i // goes straight into memory
  ,input [0:0] cvalid_i // into counter
  ,output [0:0] cready_o // into counter

  ,input [0:0] pclk_i // for p domain inelastics/syncs
  ,input [0:0] preset_i // for p domain inelastics/syncs
  ,output [0:0] pvalid_o // into counter
  ,output [width_p - 1:0] pdata_o  // comes straight out of memory?
  ,input [0:0] pready_i // into counter
  );
// write pointer sync wires
  wire c_up_w = cvalid_i & cready_o; // counter up input
  wire [depth_log2_p : 0] wr_ptr; // counter output
  wire [depth_log2_p : 0] gray_wr_ptr; // gray coded write pointer
  wire [depth_log2_p : 0] sync0_wr_ptr; // from first inelastic
  wire [depth_log2_p : 0] sync1_wr_ptr; // from second inelastic
  wire [depth_log2_p : 0] bin_wr_ptr; // bin coded write pointer

// read pointer sync wires
  wire p_up_w = pvalid_o & pready_i; // counter up input
  wire [depth_log2_p : 0] rd_ptr; // counter output
  wire [depth_log2_p : 0] gray_rd_ptr; // gray coded read pointer
  wire [depth_log2_p : 0] sync0_rd_ptr; // from first inelastic
  wire [depth_log2_p : 0] sync1_rd_ptr; // from second inelastic
  wire [depth_log2_p : 0] bin_rd_ptr; // bin coded read pointer

  // full and empty logic
  // c domain
  wire c_full_w = ((wr_ptr[depth_log2_p] != bin_rd_ptr[depth_log2_p]) && (wr_ptr[depth_log2_p - 1 : 0] == bin_rd_ptr[depth_log2_p - 1 : 0]));
  assign cready_o = !c_full_w; // can write more values if ram not full
  // p domain
  wire p_empty_w = (rd_ptr[depth_log2_p : 0] == bin_wr_ptr[depth_log2_p : 0]);
  assign pvalid_o = !p_empty_w; // can read more values if ram not empty

  // Write pointer (c domain)
  // counter instance
    // valid_i & ready_o connect to up_i
    // output goes to bin2gray, and write pointer to memory/full empty logic
    counter #(
      .width_p(depth_log2_p + 1)
    ) c_counter_inst (
      .clk_i(cclk_i),
      .reset_i(creset_i),
      .up_i(c_up_w),
      .down_i(1'b0),
      .count_o(wr_ptr)
    );

  // Read pointer (p domain)
  // counter instance
    // valid_o & ready_i connect to up_i
    // output goes to bin2gray, and read pointer to memory/full empty logic
    counter #(
      .width_p(depth_log2_p + 1)
    ) p_counter_inst (
      .clk_i(pclk_i),
      .reset_i(preset_i),
      .up_i(p_up_w),
      .down_i(1'b0),
      .count_o(rd_ptr)
    );

  // memory (c domain)
  // async instance
  ram_1r1w_async #(
    .width_p(width_p),
    .depth_p(1 << depth_log2_p),
    .init_p(1'b0),
    .filename_p("")
  ) ram_inst (
    .clk_i(cclk_i),
    .reset_i(creset_i),
    .wr_valid_i(c_up_w),
    .wr_data_i(cdata_i),
    .wr_addr_i(wr_ptr[depth_log2_p - 1 : 0]),
    .rd_addr_i(rd_ptr[depth_log2_p - 1 : 0]),
    .rd_data_o(pdata_o)
  );

  // write -> read sync (p domain)
  // bin2gray --> 2 inelastic --> gray2bin
  bin2gray #(
    .width_p(depth_log2_p + 1)
  ) p_bin2gray_inst (
    .bin_i(wr_ptr),
    .gray_o(gray_wr_ptr)
  );

  inelastic #(
    .width_p(depth_log2_p + 1),
    .datapath_reset_p(1'b1)
  ) p_inelastic_inst0 (
    .clk_i(pclk_i),
    .reset_i(preset_i),
    .en_i(1'b1),
    .data_i(gray_wr_ptr),
    .data_o(sync0_wr_ptr)
  );

  inelastic #(
    .width_p(depth_log2_p + 1),
    .datapath_reset_p(1'b1)
  ) p_inelastic_inst1 (
    .clk_i(pclk_i),
    .reset_i(preset_i),
    .en_i(1'b1),
    .data_i(sync0_wr_ptr),
    .data_o(sync1_wr_ptr)
  );

  gray2bin #(
    .width_p(depth_log2_p + 1)
  ) p_gray2bin_inst (
    .gray_i(sync1_wr_ptr),
    .bin_o(bin_wr_ptr)
  );

  // read -> write sync (c domain)
  // bin2gray --> 2 inelastic --> gray2bin
  bin2gray #(
    .width_p(depth_log2_p + 1)
  ) c_bin2gray_inst (
    .bin_i(rd_ptr),
    .gray_o(gray_rd_ptr)
  );

  inelastic #(
    .width_p(depth_log2_p + 1),
    .datapath_reset_p(1'b1)
  ) c_inelastic_inst0 (
    .clk_i(cclk_i),
    .reset_i(creset_i),
    .en_i(1'b1),
    .data_i(gray_rd_ptr),
    .data_o(sync0_rd_ptr)
  );

  inelastic #(
    .width_p(depth_log2_p + 1),
    .datapath_reset_p(1'b1)
  ) c_inelastic_inst1 (
    .clk_i(cclk_i),
    .reset_i(creset_i),
    .en_i(1'b1),
    .data_i(sync0_rd_ptr),
    .data_o(sync1_rd_ptr)
  );

  gray2bin #(
    .width_p(depth_log2_p + 1)
  ) c_gray2bin_inst (
    .gray_i(sync1_rd_ptr),
    .bin_o(bin_rd_ptr)
  );
   
endmodule

