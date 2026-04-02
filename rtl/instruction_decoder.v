// Instruction Decoder for multi-cycle 8-bit RISC-V inspired CPU
// Decodes 16-bit instructions into their component fields

module instruction_decoder (
    input wire [15:0] instruction,   // The 16-bit instruction to decode (from IR)
    output wire [4:0] opcode,        // Opcode field
    output wire [2:0] rd,            // Destination register
    output wire [2:0] rs1,           // Source register 1
    output wire [2:0] rs2,           // Source register 2
    output wire [1:0] func           // Function code (for R-type)
);
    
    // Extract fields based on instruction format
    // All instructions share the same opcode position
    assign opcode = instruction[15:11];
    
    // For R-type instructions
    assign rd = instruction[10:8];
    assign rs1 = instruction[7:5];
    assign rs2 = instruction[4:2];
    assign func = instruction[1:0];
    
    // Note: For other instruction types, the fields might have different meanings,
    // but the bit positions remain the same. The control unit will determine
    // how to interpret these fields based on the opcode.

endmodule