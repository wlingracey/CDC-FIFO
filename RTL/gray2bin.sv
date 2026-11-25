module gray2bin
  #(parameter width_p = 5)
   (input [width_p-1 : 0] gray_i
    ,output [width_p-1 : 0] bin_o);

    genvar i;
    for (i = 0; i < width_p; i = i + 1) begin : gen
      assign bin_o[i] = ^gray_i[width_p-1 : i];
    end


endmodule
