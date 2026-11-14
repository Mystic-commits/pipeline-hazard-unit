`timescale 1ns/1ps
module tb_reset;
 reg clk=0,reset=1;
 always #5 clk=~clk;
 wire [31:0] cycles,retired,stalls;
 wire done;
 pipeline_demo #(1,4) dut(clk,reset,cycles,retired,stalls,done);
 integer i,steps;
 task check_reset;
 begin
  if(cycles!==0 || retired!==0 || stalls!==0 || dut.pc!==0 ||
     dut.dv!==0 || dut.ev!==0 || dut.mv!==0 || dut.wv!==0)
   $fatal(1,"reset failed to clear pipeline and counters");
  for(i=0;i<32;i=i+1)
   if(dut.regs[i]!==i) $fatal(1,"reset failed for register %0d",i);
 end endtask
 initial begin
  for(i=0;i<256;i=i+1) dut.memory[i]=100+i;
  for(i=0;i<4;i=i+1) begin
   dut.program_op[i]=0;dut.program_rd[i]=i+1;
   dut.program_rs1[i]=i;dut.program_rs2[i]=1;dut.program_imm[i]=0;
  end
  dut.program_op[0]=2; // LW r1,0(r0)
  dut.program_rs2[1]=2; // ADD r2,r1,r2 = 102
  // ADD r3,r2,r1 = 202
  dut.program_op[3]=1; // SUB r4,r3,r1 = 102
  @(negedge clk);check_reset;reset=0;
  steps=0;
  while(!dut.stall && steps<20) begin @(negedge clk);steps=steps+1;end
  if(!dut.stall) $fatal(1,"expected load-use hazard before reset");
  // Interrupt a live dependency; no stale load or bubble may survive reset.
  reset=1;
  @(negedge clk);check_reset;
  @(negedge clk);check_reset;reset=0;
  steps=0;
  while(!done && steps<30) begin @(negedge clk);steps=steps+1;end
  if(!done || retired!=4 || cycles!=9 || stalls!=1)
   $fatal(1,"restart failed timing checks");
  if(dut.regs[0]!==0 || dut.regs[1]!==100 || dut.regs[2]!==102 ||
     dut.regs[3]!==202 || dut.regs[4]!==102)
   $fatal(1,"restart produced stale architectural state");
  $display("PASS synchronous reset during load-use hazard and clean restart");
  $finish;
 end
endmodule
