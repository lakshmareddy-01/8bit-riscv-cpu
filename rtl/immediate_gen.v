// Immediate Generator for multi-cycle 8-bit RISC-V inspired CPU
// Extracts and sign-extends immediate values from 16-bit instructions

module immediate_gen (
    input wire [15:0] instruction,   // The 16-bit instruction (from IR)
    input wire [1:0] imm_sel,        // Immediate select signal from control unit
    output reg [7:0] immediate       // The 8-bit immediate value
);

    // Immediate select codes
    localparam [1:0]
        IMM_I_TYPE = 2'b00,          // I-type instruction (ADDI, etc.)
        IMM_S_TYPE = 2'b01,          // S-type instruction (SB, SH)
        IMM_B_TYPE = 2'b10,          // B-type instruction (BEQ, etc.)
        IMM_J_TYPE = 2'b11;          // J-type instruction (JAL, JALR)
    
    // Immediate extraction and sign extension
    always @(*) begin
        case (imm_sel)
            IMM_I_TYPE: begin
                // I-type: bits[4:0] = immediate
                immediate = { {3{instruction[4]}}, instruction[4:0] }; // Sign extend
            end
            
            IMM_S_TYPE: begin
                // S-type: bits[4:0] = immediate
                immediate = { {3{instruction[4]}}, instruction[4:0] }; // Sign extend
            end
            
            IMM_B_TYPE: begin
                // B-type: bits[4:0] = offset
                immediate = { {3{instruction[4]}}, instruction[4:0] }; // Sign extend
            end
            
            IMM_J_TYPE: begin
                // J-type: bits[7:0] = offset
                immediate = instruction[7:0]; // No sign extension needed for 8-bit jump
            end
            
            default: immediate = 8'h00;
        endcase
    end

endmodule