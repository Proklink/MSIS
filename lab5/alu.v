`include "miriscv_defines.v"

module alu (
	input [`ALU_OP_WIDTH - 1:0] operator_i,
	input [31:0] operand_a_i,
	input [31:0] operand_b_i,
	output reg [31:0] result,
	output reg comparison_result
);


always @ (*) begin 
		case(operator_i)
			`ALU_ADD: 
				begin
					result = operand_a_i + operand_b_i;
					comparison_result = 0;
				end
			`ALU_SUB: 
				begin
					result = operand_a_i - operand_b_i;
					comparison_result = 0;
				end
			`ALU_XOR: 
				begin
					result = operand_a_i ^ operand_b_i;
					comparison_result = 0;
				end
			`ALU_OR: 
				begin
					result = operand_a_i | operand_b_i;
					comparison_result = 0;
				end
			`ALU_AND: 
				begin
					result = operand_a_i & operand_b_i;
					comparison_result = 0;
				end
			`ALU_SRA: 
				begin
					result = operand_a_i >>> operand_b_i;
					comparison_result = 0;
				end
			`ALU_SRL: 
				begin
					result = operand_a_i >> operand_b_i;
					comparison_result = 0;
				end
			`ALU_SLL: 
				begin
					result = operand_a_i << operand_b_i;
					comparison_result = 0;
				end
			`ALU_LTS: 
				begin
					result = ( $signed(operand_a_i) < $signed(operand_b_i)) ? 1 : 0;
					comparison_result = result;
				end
			`ALU_LTU: 
				begin
					result = ( (operand_a_i) < (operand_b_i)) ? 1 : 0;
					comparison_result = result;
				end
			`ALU_GES: 
				begin
					result = ( $signed(operand_a_i) >= $signed(operand_b_i)) ? 1 : 0;
					comparison_result = result;
				end
			`ALU_GEU: 
				begin
					result = ( (operand_a_i) >= (operand_b_i)) ? 1 : 0;
					comparison_result = result;
				end
			`ALU_EQ: 
				begin
					result = ( (operand_a_i) == (operand_b_i)) ? 1 : 0;
					comparison_result = result;
				end
			`ALU_NE: 
				begin
					result = ( (operand_a_i) != (operand_b_i)) ? 1 : 0;
					comparison_result = result;
				end
			`ALU_SLTS: 
				begin
					result = ( $signed(operand_a_i) < $signed(operand_b_i)) ? 1 : 0;
					comparison_result = result;
				end
			`ALU_SLTU: 
				begin
					result = ( (operand_a_i) < (operand_b_i)) ? 1 : 0;
					comparison_result = result;
				end
		endcase
end

endmodule