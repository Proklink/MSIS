`timescale 1ns / 10ps
 module tbProgDev();

reg 				clk;
reg				reset;

ProgDev DUT(
	.clk   ( clk   ),
	.reset ( reset )
);


initial begin
reset = 1;
#20;
reset = 0;
end


initial begin
  clk = 1'b0;
  forever #5 clk = ~clk;
  
end

endmodule