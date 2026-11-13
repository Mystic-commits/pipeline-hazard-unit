module stall_control(input stall, output pc_write, if_id_write, id_ex_flush);
 assign pc_write = !stall;
 assign if_id_write = !stall;
 assign id_ex_flush = stall;
endmodule
