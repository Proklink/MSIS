module dm (
	input clk,         // сигнал синхронизации
	input [31:0] A,    // адрес слова
	input [31:0] WD,   // write data
	input WE,          // write enable
	output [31:0] RD   // read data
);

reg [31:0] mem [0:63];  // создать память из 64-х 32-битных ячеек

assign RD = (A < 32'h09000000 || A > 32'h090000fc)? 0 : mem[(A && 8'hff) >> 2];


always @ (posedge clk)
	if (A >= 32'h09000000 && A <= 32'h090000fc)
		if (WE) mem[(A && 8'hff) >> 2] <= WD;
		
endmodule
