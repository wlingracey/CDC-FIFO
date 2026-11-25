module inelastic
  #(parameter [31:0] width_p = 8
   ,parameter [0:0] datapath_reset_p = 0
   )
  (input [0:0] clk_i
  ,input [0:0] reset_i

  ,input [0:0] en_i

  ,input [width_p - 1 : 0] data_i
  ,output logic [width_p - 1 : 0] data_o);

  always_ff @(posedge clk_i) begin
    if (reset_i && datapath_reset_p) begin
      data_o <= '0;
    end else if (en_i) begin
      data_o <= data_i;
    end
  end





endmodule
