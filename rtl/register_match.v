`timescale 1ns/1ps
module register_match(input [4:0] source, destination,
 input used, reg_write, output match);
 assign match = used && reg_write && destination != 0 && source == destination;
endmodule
