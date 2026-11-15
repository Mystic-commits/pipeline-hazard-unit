`timescale 1ns/1ps
module tb_edges;
 reg clk=0,reset=1;
 always #5 clk=~clk;
 wire [31:0] fc,fr,fs,sc,sr,ss,uc,ur,us;
 wire fd,sd,ud;
 pipeline_demo #(1,4) fast(clk,reset,fc,fr,fs,fd);
 pipeline_demo #(0,4) slow(clk,reset,sc,sr,ss,sd);
 pipeline_demo #(2,4) unsafe_core(clk,reset,uc,ur,us,ud);
 reg [31:0] model[0:31],x,y,value;
 integer c,i,steps,expected_stalls,fp,mismatches;
 task instruction(input integer n,input [1:0] op,input [4:0] d,a,b,input [31:0] imm);
 begin
  fast.program_op[n]=op;slow.program_op[n]=op;unsafe_core.program_op[n]=op;
  fast.program_rd[n]=d;slow.program_rd[n]=d;unsafe_core.program_rd[n]=d;
  fast.program_rs1[n]=a;slow.program_rs1[n]=a;unsafe_core.program_rs1[n]=a;
  fast.program_rs2[n]=b;slow.program_rs2[n]=b;unsafe_core.program_rs2[n]=b;
  fast.program_imm[n]=imm;slow.program_imm[n]=imm;unsafe_core.program_imm[n]=imm;
 end endtask
 initial begin
  fp=$fopen("build/edge-results.csv","w");
  if(fp==0) $fatal(1,"cannot open edge results");
  $fdisplay(fp,"case,forwarding_cycles,forwarding_stalls,stall_only_cycles,unprotected_cycles,unprotected_register_mismatches");
  for(c=0;c<9;c=c+1) begin
   reset=1;expected_stalls=0;
   for(i=0;i<256;i=i+1) begin
    fast.memory[i]=100+i;slow.memory[i]=100+i;unsafe_core.memory[i]=100+i;
   end
   for(i=0;i<4;i=i+1) instruction(i,0,20+i,1,2,0);
   case(c)
    0: begin end // Independent ALU stream, no false stalls.
    1: begin // LW ignores rs2 even when it aliases a previous load destination.
     instruction(0,2,5,0,0,3);instruction(1,2,6,0,5,4);
    end
    2: begin // Loading r0 does not create a dependency.
     instruction(0,2,0,0,0,3);instruction(1,0,6,0,1,0);
    end
    3: begin // Load consumed only as operand B.
     instruction(0,2,5,0,0,3);instruction(1,1,6,1,5,0);expected_stalls=1;
    end
    4: begin // Load result used as the following load's base address.
     instruction(0,2,5,0,0,3);instruction(1,2,6,5,0,1);expected_stalls=1;
    end
    5: begin // WB on operand A and MEM on operand B in the same cycle.
     instruction(0,0,5,1,2,0);instruction(1,0,6,3,4,0);instruction(2,1,7,5,6,0);
    end
    6: begin // Newest load to the same register must win.
     instruction(0,2,5,0,0,3);instruction(1,2,5,0,0,4);
     instruction(2,0,6,5,5,0);expected_stalls=1;
    end
    7: begin // A newer load masks an older ALU producer.
     instruction(0,0,5,1,2,0);instruction(1,2,5,0,0,4);
     instruction(2,0,6,5,5,0);expected_stalls=1;
    end
    8: begin // Explicit with/without handling comparison.
     instruction(0,0,5,1,2,0);instruction(1,1,6,5,3,0);
    end
   endcase
   for(i=0;i<32;i=i+1) model[i]=i;
   for(i=0;i<4;i=i+1) begin
    x=model[fast.program_rs1[i]];y=model[fast.program_rs2[i]];
    case(fast.program_op[i])
     0:value=x+y;
     1:value=x-y;
     2:value=100+((x+fast.program_imm[i])&255);
    endcase
    if(fast.program_rd[i]!=0) model[fast.program_rd[i]]=value;
   end
   repeat(2) @(negedge clk);reset=0;
   steps=0;
   while(!(fd && sd && ud) && steps<40) begin @(negedge clk);steps=steps+1;end
   if({fd,sd,ud}!==3'b111) $fatal(1,"edge timeout case=%0d",c);
   mismatches=0;
   for(i=0;i<32;i=i+1) begin
    if(fast.regs[i]!==model[i] || slow.regs[i]!==model[i])
     $fatal(1,"edge mismatch case=%0d register=%0d",c,i);
    if(unsafe_core.regs[i]!==model[i]) mismatches=mismatches+1;
   end
   if(fs!==expected_stalls || fc!==8+expected_stalls || sc!==8+ss ||
      fr!==4 || sr!==4 || ur!==4 || uc!==8 || us!==0)
    $fatal(1,"edge timing case=%0d",c);
   if(c<=2 && (ss!==0 || mismatches!=0)) $fatal(1,"false dependency case=%0d",c);
   if(c==8 && (mismatches==0 || unsafe_core.regs[6]!==2 || fast.regs[6]!==0))
    $fatal(1,"unprotected demonstration did not expose RAW error");
   $fdisplay(fp,"%0d,%0d,%0d,%0d,%0d,%0d",c,fc,fs,sc,uc,mismatches);
  end
  $fclose(fp);
  $display("PASS 9 edge cases including false stalls, mixed forwarding and unprotected RAW failure");
  $finish;
 end
endmodule
