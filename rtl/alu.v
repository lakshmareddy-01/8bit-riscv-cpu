module alu (
    input wire [7:0] operand_a,      // First operand
    input wire [7:0] operand_b,      // Second operand
    input wire [3:0] alu_op,         // ALU operation
    output reg [7:0] result,         // Result - changed from wire to reg for multi-cycle
    output wire zero_flag,           // Zero flag (result == 0)
    output wire negative_flag        // Negative flag (result[7] == 1)
);
    
    // ALU operation codes (matches control unit encoding)
    localparam [3:0] 
        ALU_ADD = 4'b0000,
        ALU_SUB = 4'b0001,
        ALU_AND = 4'b0010,
        ALU_OR  = 4'b0011,
        ALU_XOR = 4'b0100,
        ALU_SLL = 4'b0101,
        ALU_SRL = 4'b0110,
        ALU_SRA = 4'b0111,
        ALU_LUI = 4'b1000;
    
    // Simplified ALU operations for multi-cycle design
    // No internal result buffering needed - pipeline registers handle this
    always @(*) begin
        case (alu_op)
            ALU_ADD : result = operand_a + operand_b;
            ALU_SUB : result = operand_a - operand_b;
            ALU_AND : result = operand_a & operand_b;
            ALU_OR  : result = operand_a | operand_b;
            ALU_XOR : result = operand_a ^ operand_b;
            ALU_SLL : result = operand_a << operand_b[2:0]; // Only use lower 3 bits for shift amount
            ALU_SRL : result = operand_a >> operand_b[2:0]; // Only use lower 3 bits for shift amount
            ALU_SRA : result = $signed(operand_a) >>> operand_b[2:0]; // Arithmetic shift right
            ALU_LUI : result = operand_b; // Load Upper Immediate (just pass operand_b)
            default : result = 8'h00;
        endcase
    end
    
    // Compute flags directly from result
    assign zero_flag = (result == 8'h00);
    assign negative_flag = result[7];
    
    // No need for explicit result buffering in multi-cycle design
    // Pipeline registers in cpu_top.v handle this

endmodule