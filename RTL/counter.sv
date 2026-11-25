module counter
  #(parameter width_p = 4,
    parameter [width_p-1:0] reset_val_p = '0)
   (input [0:0] clk_i
   ,input [0:0] reset_i
   ,input [0:0] up_i
   ,input [0:0] down_i
   ,output logic [width_p-1:0] count_o);

   always_ff @(posedge clk_i) begin
    if (reset_i)
      count_o <= reset_val_p;
    else if (up_i && !down_i)
      count_o <= count_o + width_p'(1);
    else if (down_i && !up_i)
      count_o <= count_o - width_p'(1);
    end
       
endmodule
