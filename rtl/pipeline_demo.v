`timescale 1ns/1ps
// Decoded-instruction teaching core: op 0=ADD, 1=SUB, 2=LW.
// Program/data arrays are initialized by the simulation harness.
module pipeline_demo #(parameter MODE=1, N=10)(input clk,reset,
 output reg [31:0] cycles,retired,stalls, output done);
 reg [1:0] program_op[0:N-1];
 reg [4:0] program_rs1[0:N-1],program_rs2[0:N-1],program_rd[0:N-1];
 reg [31:0] program_imm[0:N-1];
 reg [31:0] regs[0:31], memory[0:255];
 integer pc,i;
 reg dv,ev,mv,wv;
 reg [1:0] dop,eop;
 reg [4:0] ds1,ds2,dd,es1,es2,ed,md,wd;
 reg [31:0] di,ei,ea,eb,mresult,wvalue;
 reg ml;
 wire stall,pc_write,if_id_write,id_ex_flush;
 wire [1:0] fa,fb;
 wire [31:0] a,b,result;
 wire ew=ev && ed!=0, mw=mv && md!=0, ww=wv && wd!=0;
 hazard_detection h(ds1,ds2,ed,md,dv,dv && dop!=2,
 ew,ev && eop==2,mw,MODE==1,stall);
 stall_control control(stall,pc_write,if_id_write,id_ex_flush);
 forwarding_unit f(es1,es2,md,wd,ev,ev && eop!=2,mw,ml,ww,fa,fb);
 forward_mux mux_a(ea,wvalue,mresult,MODE==1 ? fa : 2'b00,a);
 forward_mux mux_b(eb,wvalue,mresult,MODE==1 ? fb : 2'b00,b);
 assign result = eop==2 ? a+ei : eop==1 ? a-b : a+b;
 assign done = retired==N;
 // WB-to-ID bypass defines same-cycle write/read behavior explicitly.
 function [31:0] read_reg(input [4:0] r);
 begin read_reg = r==0 ? 0 : ww && wd==r ? wvalue : regs[r]; end
 endfunction
 always @(posedge clk) begin
  if(reset) begin
   pc<=0; dv<=0;ev<=0;mv<=0;wv<=0;
   dop<=0;eop<=0;ds1<=0;ds2<=0;dd<=0;es1<=0;es2<=0;
   ed<=0;md<=0;wd<=0;di<=0;ei<=0;ea<=0;eb<=0;
   mresult<=0;wvalue<=0;ml<=0;cycles<=0;retired<=0;stalls<=0;
   for(i=0;i<32;i=i+1) regs[i]<=i;
   regs[0]<=0;
  end else if(!done) begin
   cycles<=cycles+1;
   if(wv) begin
    retired<=retired+1;
    if(wd!=0) regs[wd]<=wvalue;
   end
   wv<=mv;wd<=md;wvalue<=ml ? memory[mresult[7:0]] : mresult;
   mv<=ev;md<=ed;ml<=eop==2;mresult<=result;
   if(id_ex_flush) begin ev<=0;stalls<=stalls+1;end
   else begin
    ev<=dv;eop<=dop;ed<=dd;es1<=ds1;es2<=ds2;ei<=di;
    ea<=read_reg(ds1);eb<=read_reg(ds2);
   end
   if(if_id_write) begin
    dv<=pc<N;
    if(pc<N) begin
     dop<=program_op[pc];ds1<=program_rs1[pc];ds2<=program_rs2[pc];
     dd<=program_rd[pc];di<=program_imm[pc];
    end
   end
   if(pc_write && pc<N) pc<=pc+1;
  end
 end
endmodule
