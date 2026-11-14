`timescale 1ns/1ps
// Deterministic xorshift streams; seed is printed for exact reproduction.
module tb_random;
 localparam N=64, TRIALS=100;
 reg clk=0,reset=1;
 always #5 clk=~clk;
 wire [31:0] fc,fr,fs,sc,sr,ss;
 wire fd,sd;
 pipeline_demo #(1,N) fast(clk,reset,fc,fr,fs,fd);
 pipeline_demo #(0,N) slow(clk,reset,sc,sr,ss,sd);
 reg [31:0] model[0:31],expected[0:N-1],state,initial_seed,x,y,value;
 reg [4:0] destination[0:N-1],rd,rs1,rs2;
 reg [1:0] op;
 reg [31:0] imm;
 integer trial,i,steps,fi=0,si=0,unused;
 integer total_fast=0,total_slow=0;
 reg [31:0] held_fast_cycles,held_slow_cycles;
 function [31:0] random_word;
  input [31:0] old;
  reg [31:0] t;
  begin t=old^(old<<13);t=t^(t>>17);random_word=t^(t<<5);end
 endfunction
 task next_random;
  begin state=random_word(state);end
 endtask
 // Compare each architectural write before it commits, not just final registers.
 always @(posedge clk) begin
  if(reset) begin fi=0;si=0;end
  else begin
   if(!fd && fast.wv) begin
    if(fi>=N) $fatal(1,"extra fast retirement");
    if(fast.wd!==destination[fi] || (fast.wd!=0 && fast.wvalue!==expected[fi]))
     $fatal(1,"fast mismatch seed=%0d trial=%0d instruction=%0d",initial_seed,trial,fi);
    fi=fi+1;
   end
   if(!sd && slow.wv) begin
    if(si>=N) $fatal(1,"extra slow retirement");
    if(slow.wd!==destination[si] || (slow.wd!=0 && slow.wvalue!==expected[si]))
     $fatal(1,"slow mismatch seed=%0d trial=%0d instruction=%0d",initial_seed,trial,si);
    si=si+1;
   end
  end
 end
 initial begin
  initial_seed=32'h5a17c0de;
  unused=$value$plusargs("seed=%d",initial_seed);
  if(initial_seed==0) $fatal(1,"xorshift seed must be nonzero");
  state=initial_seed;
  for(trial=0;trial<TRIALS;trial=trial+1) begin
   reset=1;
   for(i=0;i<32;i=i+1) model[i]=i;
   for(i=0;i<256;i=i+1) begin
    fast.memory[i]=32'h80000000+i*17;slow.memory[i]=fast.memory[i];
   end
   for(i=0;i<N;i=i+1) begin
    next_random;op=state%3;
    next_random;rd=state%32;
    next_random;rs1=state%32;
    next_random;rs2=state%32;
    // Bias toward adjacent dependencies and repeated destinations.
    if(i>0 && i%3==0) rs1=destination[i-1];
    if(i>0 && i%5==0) begin rs2=destination[i-1];rd=rs2;end
    next_random;imm=state;
    fast.program_op[i]=op;slow.program_op[i]=op;
    fast.program_rd[i]=rd;slow.program_rd[i]=rd;
    fast.program_rs1[i]=rs1;slow.program_rs1[i]=rs1;
    fast.program_rs2[i]=rs2;slow.program_rs2[i]=rs2;
    fast.program_imm[i]=imm;slow.program_imm[i]=imm;
    x=model[rs1];y=model[rs2];
    case(op)
     0:value=x+y;
     1:value=x-y;
     2:value=32'h80000000+((x+imm)&255)*17;
    endcase
    destination[i]=rd;expected[i]=value;
    if(rd!=0) model[rd]=value;
   end
   repeat(2) @(negedge clk);reset=0;
   steps=0;
   while(!(fd && sd) && steps<4*N+10) begin @(negedge clk);steps=steps+1;end
   if(!fd || !sd || fi!=N || si!=N) $fatal(1,"retirement/timeout trial=%0d",trial);
   for(i=0;i<32;i=i+1)
    if(fast.regs[i]!==model[i] || slow.regs[i]!==model[i])
     $fatal(1,"register mismatch trial=%0d register=%0d",trial,i);
   if(fc!=N+4+fs || sc!=N+4+ss || fc>sc) $fatal(1,"cycle accounting mismatch");
   total_fast=total_fast+fc;total_slow=total_slow+sc;
   held_fast_cycles=fc;held_slow_cycles=sc;
   repeat(3) @(negedge clk);
   if(fr!=N || sr!=N || fc!=held_fast_cycles || sc!=held_slow_cycles)
    $fatal(1,"completed pipeline did not stay idle");
  end
  $display("PASS random seed=%0d programs=%0d instructions_per_mode=%0d fast_cycles=%0d slow_cycles=%0d",
   initial_seed,TRIALS,TRIALS*N,total_fast,total_slow);
  $finish;
 end
endmodule
