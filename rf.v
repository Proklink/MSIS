module rf(
	input clk,
	input reset,
	input [4:0] A1,
	input [4:0] A2,
	input [4:0] A3,
	input [31:0] WD3,
	input WE,
	output [31:0] RD1,
	output [31:0] RD2
);

reg [31:0] reg_mem [0:31];

assign RD1 = reg_mem[A1];
assign RD2 = reg_mem[A2];

integer i;

always @ (posedge clk or posedge reset)
	if (reset) 
		for (i = 0; i < 32; i = i + 1)
			reg_mem[i] <= 32'b0;
	else if (WE)
		if (A3 != 0)
			reg_mem[A3] <= WD3;
	
endmodule
