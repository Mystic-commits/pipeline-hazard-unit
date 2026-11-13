`timescale 1ns/1ps
module forwarding_unit(
 input [4:0] rs1, rs2, mem_rd, wb_rd,
 input use1, use2, mem_write, mem_load, wb_write,
 output [1:0] forward_a, forward_b);
 wire ma,mb,wa,wb;
 register_match a(rs1,mem_rd,use1,mem_write,ma);
 register_match b(rs2,mem_rd,use2,mem_write,mb);
 register_match c(rs1,wb_rd,use1,wb_write,wa);
 register_match d(rs2,wb_rd,use2,wb_write,wb);
 // A newer load blocks an older WB match; its data is not ready in MEM.
 assign forward_a = ma ? (mem_load ? 2'b00 : 2'b10) : wa ? 2'b01 : 2'b00;
 assign forward_b = mb ? (mem_load ? 2'b00 : 2'b10) : wb ? 2'b01 : 2'b00;
endmodule
