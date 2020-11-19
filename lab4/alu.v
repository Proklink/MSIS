module alu (
	input [5:0] operator_i,
	input [31:0] operand_a_i,
	input [31:0] operand_b_i,
	output reg [31:0] result,
	output reg comparison_result
);

`define ALU_OP_WIDTH 4
`define ALU_ADD 4'b0000
`define ALU_SUB 4'b0001
`define ALU_XOR 4'b0010
`define ALU_OR  4'b0011
`define ALU_AND 4'b0100
`define ALU_SRA 4'b0101
`define ALU_SRL 4'b0110
`define ALU_SLL 4'b0111
`define ALU_LTS 4'b1000
`define ALU_LTU 4'b1001
`define ALU_GES 4'b1010
`define ALU_GEU 4'b1011
`define ALU_EQ  4'b1100
`define ALU_NE  4'b1101 



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
		endcase
end

endmodule