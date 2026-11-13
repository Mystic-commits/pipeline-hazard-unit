module hazard_detection(
 input [4:0] id_rs1,id_rs2,ex_rd,mem_rd,
 input id_use1,id_use2,ex_write,ex_load,mem_write,forwarding_enabled,
 output stall);
 wire e1,e2,m1,m2;
 register_match a(id_rs1,ex_rd,id_use1,ex_write,e1);
 register_match b(id_rs2,ex_rd,id_use2,ex_write,e2);
 register_match c(id_rs1,mem_rd,id_use1,mem_write,m1);
 register_match d(id_rs2,mem_rd,id_use2,mem_write,m2);
 assign stall = forwarding_enabled ? ex_load && (e1 || e2) : e1 || e2 || m1 || m2;
endmodule
