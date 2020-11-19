module ProgDev(
	input        clk,
	input        reset
);

reg  [31:0]  PC;
reg  [31:0]  WD3;
reg  [31:0]	 alu_operand_a, alu_operand_b;
reg  [31:0]  shift_const;
wire [31:0]  instr;
wire [31:0]  RD1, RD2, RD;
wire [31:0]  result;

wire [31:0]  SE_imm_I, SE_imm_S, SE_imm_J, SE_imm_B;
wire comparison_result_o;

wire [1:0] ex_op_a_sel_o;		
wire [2:0] ex_op_b_sel_o; 			
wire [5:0] alu_op_o;	
wire mem_req_o;					 
wire mem_we_o;					
wire [2:0] mem_size_o; 		
wire gpr_we_a_o;		
wire wb_src_sel_o; 			
wire illegal_instr_o; 	
wire branch_o;		
wire jal_o;				
wire jarl_o; 		

MainDecoder md( 	.fetched_instr_i(instr), 		
						.ex_op_a_sel_o(ex_op_a_sel_o), 			
						.ex_op_b_sel_o(ex_op_b_sel_o), 			
						.alu_op_o(alu_op_o), 			
						.mem_req_o(mem_req_o), 						 
						.mem_we_o(mem_we_o), 					
						.mem_size_o(mem_size_o), 		
						.gpr_we_a_o(gpr_we_a_o), 				
						.wb_src_sel_o(wb_src_sel_o), 			
						.illegal_instr_o(illegal_instr_o), 	
						.branch_o(branch_o), 					
						.jal_o(jal_o), 					
						.jarl_o(jarl_o) );


instr_mem instruction_memory(	.a(PC), 
										.rd(instr));								


//данные для памяти данных
/////////////////////////////////////////////////////////////////		
dm DataMemory(	.clk(clk),        
					.A(result),    
					.WD(RD2),
					.WE(mem_we_o),   
					.mem_size_o(mem_size_o),
					.mem_req_o(mem_req_o),					
					.RD(RD) 
);
/////////////////////////////////////////////////////////////////
										
//данные для регистрового файла
/////////////////////////////////////////////////////////////////		
always @ (*) begin
	case (wb_src_sel_o)
		1'b0 : WD3 <= result;
		1'b1 : WD3 <= RD; 
	endcase
end
									
rf register_file(	.clk(clk), 
						.reset(reset), 
						.A1(instr[19:15]), 
						.A2(instr[24:20]),
						.A3(instr[11:7]), 
						.WD3(WD3), 
						.WE(gpr_we_a_o), 
						.RD1(RD1), 
						.RD2(RD2)
);
/////////////////////////////////////////////////////////////////
	
//данные для АЛУ
/////////////////////////////////////////////////////////////////
always @ (*) begin
	case (ex_op_a_sel_o)
		2'b00 : alu_operand_a <= RD1;
		2'b01 : alu_operand_a <= PC; 
		2'b10 : alu_operand_a <= 32'b0;
		//2'b11 : alu_operand_a <= 32'b0;
	endcase
end

always @ (*) begin
	case (ex_op_b_sel_o)
		3'b000 : alu_operand_b <= RD2;
		3'b001 : alu_operand_b <= SE_imm_I; 
		3'b010 : alu_operand_b <= {instr[31:12],{12'b0}};//спорно
		3'b011 : alu_operand_b <= SE_imm_S;
		3'b100 : alu_operand_b <= 32'd4;
	endcase
end

	
alu ALU(				.operator_i(alu_op_o), 
						.operand_a_i(alu_operand_a), 
						.operand_b_i(alu_operand_b), 
						.result(result), 
						.comparison_result(comparison_result_o)
);
/////////////////////////////////////////////////////////////////


//данные для константы для перехода
/////////////////////////////////////////////////////////////////
always @ ( posedge clk ) begin
	if ( branch_o ) 
		shift_const = SE_imm_B;
	else
		shift_const = SE_imm_J;
end
/////////////////////////////////////////////////////////////////

//данные для знакового расширителя констант
/////////////////////////////////////////////////////////////////
assign SE_imm_I = {{20{instr[31]}},instr[31:20]};
assign SE_imm_S = {{20{instr[31]}},instr[31:25],instr[11:7]};
assign SE_imm_J = {{12{instr[31]}},instr[19:12],instr[20],instr[30:21],1'b0};//may be {0}
assign SE_imm_B = {{20{instr[31]}},instr[7],instr[30:25],instr[11:8],1'b0};//may be {0}
/////////////////////////////////////////////////////////////////

//данные для PC
/////////////////////////////////////////////////////////////////
assign Jamp  =  (comparison_result_o & branch_o) | jal_o;

always @ ( posedge clk ) begin
	if ( reset ) 
		PC <= 32'b0;
	else begin
	
			if ( jarl_o )
				PC <= RD1;
			else
				if ( Jamp ) 
					PC <= PC + shift_const;
				else 
					PC <= PC + 32'd4;
					
		end
end
/////////////////////////////////////////////////////////////////

endmodule