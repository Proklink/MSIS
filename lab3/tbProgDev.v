`timescale 1ns / 10ps
 module tbProgDev();

reg 				clk;
reg 	[9:0]		SW ;
reg				reset;
wire	[6:0]		HEX;

ProgDev DUT(
	.clk   ( clk   ),
	.SW	 ( SW    ),
	.reset ( reset ),
	.HEX0 ( HEX   )
);

initial SW = 10'b0001010111;

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