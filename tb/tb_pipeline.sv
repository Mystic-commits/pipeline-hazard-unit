`timescale 1ns/1ps
module tb_pipeline;
 reg clk=0,reset=1;
 always #5 clk=~clk;
 wire [31:0] fc,fr,fs,sc,sr,ss;
 wire fd,sd;
 pipeline_demo #(1,10) fast(clk,reset,fc,fr,fs,fd);
 pipeline_demo #(0,10) slow(clk,reset,sc,sr,ss,sd);
 reg [31:0] reference[0:31];
 reg [31:0] x,y;
 integer i,steps,fp;
 integer held_pc;
 reg [4:0] held_rs1,held_rs2;
 always @(posedge clk) begin
  if(!reset && !fd && fast.stall) begin
   held_pc=fast.pc;held_rs1=fast.ds1;held_rs2=fast.ds2;
   #1;
   if(fast.pc!==held_pc || fast.ds1!==held_rs1 || fast.ds2!==held_rs2 || fast.ev!==0)
    $fatal(1,"load-use stall failed to hold decode and inject bubble");
  end
 end
 task instruction(input integer n,input [1:0] op,input [4:0] d,a,b,input [31:0] imm);
 begin
  fast.program_op[n]=op;slow.program_op[n]=op;
  fast.program_rd[n]=d;slow.program_rd[n]=d;
  fast.program_rs1[n]=a;slow.program_rs1[n]=a;
  fast.program_rs2[n]=b;slow.program_rs2[n]=b;
  fast.program_imm[n]=imm;slow.program_imm[n]=imm;
 end endtask
 initial begin
  if($test$plusargs("wave")) begin $dumpfile("build/pipeline.vcd");$dumpvars(0,tb_pipeline);end
  for(i=0;i<256;i=i+1) begin fast.memory[i]=100+i;slow.memory[i]=100+i;end
  instruction(0,0,5,1,2,0); // r5=3
  instruction(1,1,6,5,3,0); // EX/MEM -> A, r6=0
  instruction(2,0,7,4,5,0); // MEM/WB -> B, r7=7
  instruction(3,0,5,7,1,0); // newer r5=8
  instruction(4,0,5,5,2,0); // newest r5=10
  instruction(5,0,8,5,5,0); // priority both operands: r8=20
  instruction(6,2,9,0,9,3); // r9=103; rs2 unused, no false self hazard
  instruction(7,0,10,9,8,0); // load-use bubble, r10=123
  instruction(8,0,0,10,9,0); // x0 write ignored
  instruction(9,1,11,10,0,0); // r11=123, x0 stays zero
  for(i=0;i<32;i=i+1) reference[i]=i;
  reference[0]=0;
  for(i=0;i<10;i=i+1) begin
   x=reference[fast.program_rs1[i]];y=reference[fast.program_rs2[i]];
   if(fast.program_rd[i]!=0)
    case(fast.program_op[i])
     0: reference[fast.program_rd[i]]=x+y;
     1: reference[fast.program_rd[i]]=x-y;
     2: reference[fast.program_rd[i]]=100+((x+fast.program_imm[i])&255);
    endcase
  end
  repeat(2) @(negedge clk); reset=0;
  steps=0;
  while(!(fd && sd) && steps<100) begin @(negedge clk);steps=steps+1;end
  if(!fd || !sd) $fatal(1,"pipeline timed out");
  for(i=0;i<32;i=i+1)
   if(fast.regs[i]!==reference[i] || slow.regs[i]!==reference[i])
    $fatal(1,"r%0d expected=%0d fast=%0d slow=%0d",i,reference[i],fast.regs[i],slow.regs[i]);
  if(fs!=1 || fc!=15 || sc!=10+4+ss || sc<=fc) $fatal(1,"unexpected timing");
  fp=$fopen("build/results.csv","w");
  $fdisplay(fp,"mode,instructions,cycles,stalls,cpi");
  $fdisplay(fp,"forwarding,%0d,%0d,%0d,%0.3f",fr,fc,fs,1.0*fc/fr);
  $fdisplay(fp,"stall_only,%0d,%0d,%0d,%0.3f",sr,sc,ss,1.0*sc/sr);
  $fclose(fp);
  $display("PASS pipeline: forwarding cycles=%0d stalls=%0d; stall-only cycles=%0d stalls=%0d",fc,fs,sc,ss);
  $finish;
 end
endmodule
