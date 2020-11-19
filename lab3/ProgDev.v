module ProgDev(
	input        clk,
	input        reset,
	input  [9:0] SW,
	output [6:0] HEX0
);
reg  [31:0]  PC;
reg  [31:0]  WD3;
reg  [31:0]  PCsum;
wire [31:0]  instr;
wire [31:0]  RD1;
wire [31:0]  RD2;
wire [31:0]  result;
wire [31:0]  shift_const;
wire [31:0]  SE;
wire [31:0]  SE_SW;
wire [1:0]   WS;
wire B;
wire C;
//wire comparison_result_o;

instr_mem instruction_memory(.a(PC), .rd(instr));

rf register_file(.clk(clk), .reset(reset), .A1(instr[22:18]), .A2(instr[17:13]),
														.A3(instr[12:8]), .WD3(WD3), .WE(instr[29]), .RD1(RD1), .RD2(RD2));
	
alu ALU(.operator_i(instr[26:23]), .operand_a_i(RD1), .operand_b_i(RD2), .result(result), .comparison_result(comparison_result_o));

HEX HEX_ADD(.hex_i(RD1[3:0]), .HEX0(HEX0));

assign Jamp  =  (comparison_result_o & instr[30]) | instr[31];
assign shift_const = {{22{instr[7]}}, instr[7:0], 2'b0};
//always @ ( * ) begin
//	case ( Jamp )
//		1'b0: PCsum <= 32'd4; 
//		1'b1: PCsum <= shift_const; 
//	endcase
//end

assign WS 	  = instr[28:27];
assign SE     = {{24{instr[7]}},instr[7:0]};
assign SE_SW  = {{22{SW[9]}},SW[9:0]};
always @ (*) begin
	case (WS)
		2'b00 : WD3 <= SE;
		2'b01 : WD3 <= SE_SW; 
		2'b10 : WD3 <= result;
		2'b11 : WD3 <= 32'b0;
	endcase
end

always @ ( posedge clk ) begin
	if ( reset ) PC <= 32'b0;
	else begin
		if ( Jamp ) PC <= PC + shift_const;
		else PC <= PC + 32'd4;
	end
end

endmodule