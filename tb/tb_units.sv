`timescale 1ns/1ps
module tb_units;
 reg [4:0] s,t,m,w;
 reg u,v,mw,ml,ww;
 wire [1:0] a,b;
 wire stall,pcw,idw,flush;
 reg enabled;
 reg [31:0] orig,wval,mval;
 wire [31:0] value;
 integer si,mi,wi,flags,count;
 reg ma,wa,mb,wb,expected_stall;
 reg [1:0] expected_a,expected_b;
 forwarding_unit f(s,t,m,w,u,v,mw,ml,ww,a,b);
 hazard_detection h(s,t,m,w,u,v,mw,ml,ww,enabled,stall);
 stall_control c(stall,pcw,idw,flush);
 forward_mux mux(orig,wval,mval,a,value);
 initial begin
  count=0;orig=11;wval=22;mval=33;
  // Exhaust every source/MEM/WB triple for each operand and all control bits.
  for(si=0;si<32;si=si+1)
  for(mi=0;mi<32;mi=mi+1)
  for(wi=0;wi<32;wi=wi+1)
  for(flags=0;flags<64;flags=flags+1) begin
   s=si;t=31-si;m=mi;w=wi;
   {enabled,u,v,mw,ml,ww}=flags;
   #1;
   ma=u && mw && m!=0 && s==m; mb=v && mw && m!=0 && t==m;
   wa=u && ww && w!=0 && s==w; wb=v && ww && w!=0 && t==w;
   expected_a=ma ? (ml ? 0 : 2) : wa ? 1 : 0;
   expected_b=mb ? (ml ? 0 : 2) : wb ? 1 : 0;
   expected_stall=enabled ? ml && (ma||mb) : ma||mb||wa||wb;
   if(a!==expected_a || b!==expected_b || stall!==expected_stall)
    $fatal(1,"unit mismatch registers=%0d,%0d,%0d,%0d flags=%0d",s,t,m,w,flags);
   if(pcw!==!stall || idw!==!stall || flush!==stall) $fatal(1,"control mismatch");
   if(value!==(a==2 ? mval : a==1 ? wval : orig)) $fatal(1,"mux mismatch");
   count=count+1;
  end
  $display("PASS unit combinations=%0d",count);$finish;
 end
endmodule
