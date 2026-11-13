module forward_mux(input [31:0] original, wb_value, mem_value,
 input [1:0] select, output [31:0] value);
 assign value = select == 2'b10 ? mem_value : select == 2'b01 ? wb_value : original;
endmodule
