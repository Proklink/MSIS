module instr_mem (
		input  [31:0]  a,
		output [31:0]  rd								
);

reg [31:0] MEM [0:63]; 

initial $readmemb ("C:/Users/danil/Desktop/msis/laba3/lab3(ProgDev)/instructions.txt", MEM);

assign rd = MEM[a[7:2]]; 


endmodule