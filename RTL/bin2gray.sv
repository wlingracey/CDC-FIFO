module bin2gray
  #(parameter width_p = 5)
  (input [width_p-1 : 0] bin_i
  ,output [width_p-1 : 0] gray_o);

   assign gray_o = bin_i ^ (bin_i >> 1);

endmodule
