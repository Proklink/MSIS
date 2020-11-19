module dm (
	input clk,         		// сигнал синхронизации
	input [31:0] A,    		// адрес слова
	input [31:0] WD,   		// write data
	input WE,          		// write enable
	input [2:0] mem_size_o,	//size of word
	input mem_req_o,			//access to memory
	output [31:0] RD   		// read data
);

reg [31:0] mem [0:63];  // создать память из 64-х 32-битных ячеек

assign RD = (A < 32'h09000000 || A > 32'h090000fc)? 0 : mem[(A & 8'hff) >> 2];
initial $readmemb ("C:/Users/danil/Desktop/msis/lab5/data.txt", mem);
reg [31:0] example;

always @ (posedge clk) begin
	example <= A & 8'hff;
	if (A >= 32'h09000000 && A <= 32'h090000fc)
		//if (mem_req_o)
			if (WE) 
				mem[(A & 8'hff) >> 2] <= WD;
			//else 
				//RD <= (A < 32'h09000000 || A > 32'h090000fc)? 0 : mem[(A & 8'hff) >> 2];
end
endmodule
