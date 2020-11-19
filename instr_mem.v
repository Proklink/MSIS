module instr_mem (
		input  [31:0]  a,
		output [31:0]  rd								
);

reg [31:0] MEM [0:127]; 

initial $readmemh ("C:/Users/danil/Desktop/msis/lab5/instructions.txt", MEM);

assign rd = MEM[a[8:2]]; 


endmodule