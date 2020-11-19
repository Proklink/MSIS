`include "miriscv_defines.v"

module MainDecoder( 
		input [31:0] fetched_instr_i, 		//инструкция 
		output reg [1:0] ex_op_a_sel_o, 			//Управляющий сигнал мультиплексора для выбора первого операнда АЛУ
		output reg [2:0] ex_op_b_sel_o, 			//Управляющий сигнал мультиплексора для выбора второго операнда АЛУ
		output reg [5:0] alu_op_o, 				//Операция АЛУ
		output reg mem_req_o, 						 //Запрос на доступ к памяти (часть интерфейса памяти)
		output reg mem_we_o, 					//Сигнал разрешения записи в память, «write enable» (при равенстве нулю происходит чтение)
		output reg [2:0] mem_size_o, 		//Управляющий сигнал для выбора размера слова при чтении-записи в память(часть интерфейса памяти)
		output reg gpr_we_a_o, 				//Сигнал разрешения записи в регистровый файл
		output reg wb_src_sel_o, 			//Управляющий сигнал мультиплексора для выбора данных, записываемых в регистровый файл
		output reg illegal_instr_o, 		//Сигнал о некорректной инструкции
		output reg branch_o, 					//Сигнал об инструкции условного перехода
		output reg jal_o, 						//Сигнал об инструкции безусловного перехода jal
		output reg jarl_o 						//Сигнал об инструкции безусловного перехода jarl
);

wire [6:0] opcode;
reg [2:0] func3;
reg [6:0] func7;
assign opcode = fetched_instr_i[6:0];
assign NEopcod = ~fetched_instr_i[6:2];

integer i;

always @ (*) begin
	
	if ( (opcode[1:0] == 2'b11 )) 
	begin
		if (	((opcode[6:2] > `LOAD_OPCODE) & (opcode[6:2] < `MISC_MEM_OPCODE))	| 
				((opcode[6:2] > `AUIPC_OPCODE) & (opcode[6:2] < `STORE_OPCODE)) 		|
				((opcode[6:2] > `STORE_OPCODE) & (opcode[6:2] < `OP_OPCODE)) 			| 
				((opcode[6:2] > `LUI_OPCODE) & (opcode[6:2] < `BRANCH_OPCODE)) 		|
				((opcode[6:2] > `JALR_OPCODE) & (opcode[6:2] < `JAL_OPCODE)) 			|
				((opcode[6:2] > `JAL_OPCODE) & (opcode[6:2] < `SYSTEM_OPCODE))	) 
			illegal_instr_o = 1;
		case (opcode[6:2])
			`LOAD_OPCODE:
				begin
					ex_op_a_sel_o = `OP_A_RS1;
					ex_op_b_sel_o = `OP_B_IMM_I;
					alu_op_o = `ALU_ADD;
					mem_req_o = 1;
					mem_we_o = 0;
					gpr_we_a_o = 1;
					wb_src_sel_o = `WB_LSU_DATA;
					jarl_o = 0;
					jal_o = 0;
					branch_o = 0;
					illegal_instr_o = 0;
					
					func3 = fetched_instr_i[14:12];
					case (func3)
						`LDST_B:
							mem_size_o = 3'd0;
						`LDST_H:
							mem_size_o = 3'd1;
						`LDST_W:
							mem_size_o = 3'd2;
						`LDST_BU:
							mem_size_o = 3'd4;
						`LDST_HU:
							mem_size_o = 3'd5;
						default:
							illegal_instr_o = 1;
					endcase
				end
			`OP_IMM_OPCODE:
				begin
					ex_op_a_sel_o = `OP_A_RS1;
					ex_op_b_sel_o = `OP_B_IMM_I;
					mem_req_o = 0;
					mem_we_o = 0;
					gpr_we_a_o = 1;
					wb_src_sel_o = `WB_EX_RESULT;
					mem_size_o = `LDST_B;//no important
					jarl_o = 0;
					jal_o = 0;
					branch_o = 0;
					illegal_instr_o = 0;
					
					func3 = fetched_instr_i[14:12];
					
					case (func3)
						3'b000:
							alu_op_o = `ALU_ADD;
						3'b100:
							alu_op_o = `ALU_XOR;
						3'b110:
							alu_op_o = `ALU_OR;
						3'b111:
							alu_op_o = `ALU_AND;
						3'b001:
							begin
								if (fetched_instr_i[31:25] == 7'b0000000)
									alu_op_o = `ALU_SLL;
								else
									illegal_instr_o = 1;
							end
						3'b011:
							alu_op_o = `ALU_SLTU;
						3'b010:
							alu_op_o = `ALU_SLTS;
						3'b101: 
							begin
							
								case (fetched_instr_i[31:25])
									7'b0000000: 
										alu_op_o = `ALU_SRL;
									7'h20: 
										alu_op_o = `ALU_SRA;
									default:
										illegal_instr_o = 1;
								endcase
								
							end
						default:
							illegal_instr_o = 1;
					endcase
					
				end
			`AUIPC_OPCODE:
				begin
					ex_op_a_sel_o = `OP_A_CURR_PC;
					ex_op_b_sel_o = `OP_B_IMM_U;
					mem_req_o = 0;
					mem_we_o = 0;
					gpr_we_a_o = 1;
					wb_src_sel_o = `WB_EX_RESULT;
					mem_size_o = `LDST_B;//no important
					alu_op_o = `ALU_ADD;
					jarl_o = 0;
					jal_o = 0;
					branch_o = 0;
					illegal_instr_o = 0;
				end
			`STORE_OPCODE:
				begin
					ex_op_a_sel_o = `OP_A_RS1;
					ex_op_b_sel_o = `OP_B_IMM_S;
					mem_req_o = 1;
					mem_we_o = 1;
					gpr_we_a_o = 0;
					wb_src_sel_o = `WB_EX_RESULT;
					alu_op_o = `ALU_ADD;
					jarl_o = 0;
					jal_o = 0;
					branch_o = 0;
					illegal_instr_o = 0;
					
				func3 = fetched_instr_i[14:12];
				case (func3)
					3'b000:
						mem_size_o = `LDST_B;
					3'b001:
						mem_size_o = `LDST_H;
					3'b010:
						mem_size_o = `LDST_W;
					default:
						illegal_instr_o = 1;
				endcase
				
				end
			`OP_OPCODE:
				begin
					ex_op_a_sel_o = `OP_A_RS1;
					ex_op_b_sel_o = `OP_B_RS2;
					mem_req_o = 0;
					mem_we_o = 0;
					gpr_we_a_o = 1;
					wb_src_sel_o = `WB_EX_RESULT;
					mem_size_o = `LDST_B;//no important
					jarl_o = 0;
					jal_o = 0;
					branch_o = 0;
					illegal_instr_o = 0;
					
					func3 = fetched_instr_i[14:12];
					func7 = fetched_instr_i[31:25];
					
					case (func3)
						3'b000:
							case (func7)
								7'b0000000:
									alu_op_o = `ALU_ADD;
								7'h20:
									alu_op_o = `ALU_SUB;
								default: 
									illegal_instr_o = 1;
							endcase
						3'b100:
							if (func7 == 7'h0)
								alu_op_o = `ALU_XOR;
							else
								illegal_instr_o = 1;
						3'b110:
							if (func7 == 7'h0)
								alu_op_o = `ALU_OR;
							else
								illegal_instr_o = 1;
						3'b111:
							if (func7 == 7'h0)
								alu_op_o = `ALU_AND;
							else
								illegal_instr_o = 1;
						3'b001:
							if (func7 == 7'h0)
								alu_op_o = `ALU_SLL;
							else
								illegal_instr_o = 1;
						3'b101:
							case (func7)
								7'h0:
									alu_op_o = `ALU_SRL;
								7'h20:
									alu_op_o = `ALU_SRA;
								default: 
									illegal_instr_o = 1;
							endcase
						3'b010:
							if (func7 == 7'h0)
								alu_op_o = `ALU_SLTS;
							else
								illegal_instr_o = 1;
						3'b011:
							if (func7 == 7'h0)
								alu_op_o = `ALU_SLTU;
							else
								illegal_instr_o = 1;
						default: 
							illegal_instr_o = 1;
					endcase
					
				end
			`LUI_OPCODE:
				begin
					ex_op_a_sel_o = `OP_A_ZERO;
					ex_op_b_sel_o = `OP_B_IMM_U;
					mem_req_o = 0;
					mem_we_o = 0;
					gpr_we_a_o = 1;
					wb_src_sel_o = `WB_EX_RESULT;
					mem_size_o = `LDST_B;//no important
					alu_op_o = `ALU_ADD;
					jarl_o = 0;
					jal_o = 0;
					branch_o = 0;
					illegal_instr_o = 0;
				end
			`BRANCH_OPCODE:
				begin
					ex_op_a_sel_o = `OP_A_RS1;
					ex_op_b_sel_o = `OP_B_RS2;
					mem_req_o = 0;
					mem_we_o = 0;
					gpr_we_a_o = 0;
					wb_src_sel_o = `WB_EX_RESULT;
					mem_size_o = `LDST_B;//no important
					jarl_o = 0;
					jal_o = 0;
					branch_o = 1;
					illegal_instr_o = 0;
					
					func3 = fetched_instr_i[14:12];
				case (func3)
					3'b000:
						alu_op_o = `ALU_EQ;
					3'b001:
						alu_op_o = `ALU_NE;
					3'b100:
						alu_op_o = `ALU_LTS;
					3'b101:
						alu_op_o = `ALU_GES;
					3'b110:
						alu_op_o = `ALU_LTU;
					3'b111:
						alu_op_o = `ALU_GEU;
					default:
						illegal_instr_o = 1;
				endcase
				end
			`JALR_OPCODE:
				begin
					ex_op_a_sel_o = `OP_A_CURR_PC;
					ex_op_b_sel_o = `OP_B_INCR;
					mem_req_o = 0;
					mem_we_o = 0;
					gpr_we_a_o = 1;
					wb_src_sel_o = `WB_EX_RESULT;
					mem_size_o = `LDST_B;//no important
					jarl_o = 1;
					jal_o = 0;
					branch_o = 0;
					alu_op_o = `ALU_ADD;
					illegal_instr_o = 0;
					
					func3 = fetched_instr_i[14:12];
					if (func3 != 3'h0)
						illegal_instr_o = 1;
				end
			`JAL_OPCODE:
				begin
					ex_op_a_sel_o = `OP_A_CURR_PC;
					ex_op_b_sel_o = `OP_B_INCR;
					mem_req_o = 0;
					mem_we_o = 0;
					gpr_we_a_o = 1;
					wb_src_sel_o = `WB_EX_RESULT;
					mem_size_o = `LDST_B;//no important
					jarl_o = 0;
					jal_o = 1;
					branch_o = 0;
					alu_op_o = `ALU_ADD;
					illegal_instr_o = 0;
				end
			`SYSTEM_OPCODE:
				begin
					ex_op_a_sel_o = `OP_A_RS1;
					ex_op_b_sel_o = `OP_B_RS2;
					mem_req_o = 0;
					mem_we_o = 0;
					gpr_we_a_o = 0;
					wb_src_sel_o = `WB_EX_RESULT;
					mem_size_o = `LDST_B;//no important
					jarl_o = 0;
					jal_o = 0;
					branch_o = 0;
					alu_op_o = `ALU_ADD;
					illegal_instr_o = 0;
				end
			`MISC_MEM_OPCODE:
				begin
					ex_op_a_sel_o = `OP_A_RS1;
					ex_op_b_sel_o = `OP_B_RS2;
					mem_req_o = 0;
					mem_we_o = 0;
					gpr_we_a_o = 0;
					wb_src_sel_o = `WB_EX_RESULT;
					mem_size_o = `LDST_B;//no important
					jarl_o = 0;
					jal_o = 0;
					branch_o = 0;
					alu_op_o = `ALU_ADD;
					illegal_instr_o = 0;
				end

			default:
				illegal_instr_o = 1;
		endcase
		
	end
	else 
		illegal_instr_o = 1;
end




endmodule