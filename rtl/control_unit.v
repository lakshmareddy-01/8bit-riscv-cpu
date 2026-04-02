// Multi-Cycle Control Unit for 8-bit RISC-V inspired CPU
// Implements state machine and generates cycle-specific control signals

module control_unit (
    input wire clk,                  // Clock signal
    input wire reset,                // Reset signal
    input wire [4:0] opcode,         // 5-bit opcode field
    input wire [1:0] func,           // 2-bit function field (for R-type)
    input wire zero_flag,            // Zero flag from ALU
    input wire negative_flag,        // Negative flag from ALU
    
    // State output (for debugging)
    output reg [2:0] state,          // Current state of the CPU
    
    // Datapath control signals
    output reg pc_write,             // Write to PC
    output reg ir_write,             // Write to Instruction Register
    output reg reg_write,            // Register file write enable
    
    output reg [3:0] alu_op,         // ALU operation select
    output reg [1:0] alu_src_a,      // ALU A input source selector (0: PC, 1: A register)
    output reg [1:0] alu_src_b,      // ALU B input source selector (0: B register, 1: 4'h2, 2: Immediate)
    
    output reg mem_read,             // Memory read enable
    output reg mem_write,            // Memory write enable
    
    output reg a_write,              // A register write enable
    output reg b_write,              // B register write enable
    output reg alu_out_write,        // ALU out register write enable
    output reg mdr_write,            // Memory data register write enable
    
    output reg [1:0] reg_write_src,  // Register write source (0: ALU out, 1: MDR, 2: PC)
    output reg [1:0] pc_source,      // PC source (0: ALU result, 1: ALU out)
    
    output reg [1:0] imm_sel,        // Immediate select for different instruction types
    output reg branch_taken          // Indicates branch is taken (computed in Execute state)
);

    // Instruction opcode ranges (same as original design)
    localparam [4:0]
        // R-type instructions
        OP_ADD  = 5'b00000,
        OP_MISC = 5'b00001,          // XOR, SLL, SRL, SRA
        
        // I-type instructions
        OP_ADDI = 5'b01000,
        OP_ANDI = 5'b01001,
        OP_ORI  = 5'b01010,
        OP_XORI = 5'b01011,
        OP_SLLI = 5'b01100,
        OP_SRLI = 5'b01101,
        OP_SRAI = 5'b01110,
        OP_LUI  = 5'b01111,
        
        // Load instructions
        OP_LB   = 5'b10000,
        OP_LH   = 5'b10001,
        
        // Store instructions
        OP_SB   = 5'b10100,
        OP_SH   = 5'b10101,
        
        // Branch instructions
        OP_BEQ  = 5'b11000,
        OP_BNE  = 5'b11001,
        OP_BLT  = 5'b11010,
        OP_BGE  = 5'b11011,
        
        // Jump instructions
        OP_JAL  = 5'b11100,
        OP_JALR = 5'b11101;
    
    // Immediate select codes (same as original design)
    localparam [1:0]
        IMM_I_TYPE = 2'b00,
        IMM_S_TYPE = 2'b01,
        IMM_B_TYPE = 2'b10,
        IMM_J_TYPE = 2'b11;
    
    // ALU operation codes (same as original design)
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
    
    // Multi-cycle state definition
    localparam [2:0]
        S_FETCH    = 3'b000,  // Instruction fetch
        S_DECODE   = 3'b001,  // Instruction decode and register fetch
        S_EXECUTE  = 3'b010,  // Execute operation or calculate address
        S_MEMORY   = 3'b011,  // Memory access
        S_WRITEBACK = 3'b100;  // Write result back to register
    
    // State transition logic - unchanged from original
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S_FETCH;
        end else begin
            case (state)
                S_FETCH: begin
                    state <= S_DECODE;
                end
                
                S_DECODE: begin
                    state <= S_EXECUTE;
                end
                
                S_EXECUTE: begin
                    // For load and store, go to memory access
                    if ((opcode == OP_LB) || (opcode == OP_LH) || 
                        (opcode == OP_SB) || (opcode == OP_SH)) begin
                        state <= S_MEMORY;
                    end 
                    // For R-type, I-type, go to writeback
                    else if ((opcode == OP_ADD) || (opcode == OP_MISC) ||
                             (opcode >= OP_ADDI && opcode <= OP_LUI) ||
                             (opcode == OP_JAL) || (opcode == OP_JALR)) begin
                        state <= S_WRITEBACK;
                    end
                    // For branch, go back to fetch
                    else if ((opcode >= OP_BEQ) && (opcode <= OP_BGE)) begin
                        state <= S_FETCH;
                    end
                    // Default: go back to fetch
                    else begin
                        state <= S_FETCH;
                    end
                end
                
                S_MEMORY: begin
                    // For loads, go to writeback
                    if ((opcode == OP_LB) || (opcode == OP_LH)) begin
                        state <= S_WRITEBACK;
                    end
                    // For stores, go back to fetch
                    else begin
                        state <= S_FETCH;
                    end
                end
                
                S_WRITEBACK: begin
                    state <= S_FETCH;
                end
                
                default: state <= S_FETCH;
            endcase
        end
    end
    
    // Control signal generation - REFACTORED to use combinational logic instead of arrays
    always @(*) begin
        // Default values for all control signals
        pc_write = 0;
        ir_write = 0;
        reg_write = 0;
        alu_op = ALU_ADD;
        alu_src_a = 2'b00;      // Default is PC
        alu_src_b = 2'b01;      // Default is 2 (for PC+2)
        mem_read = 0;
        mem_write = 0;
        a_write = 0;
        b_write = 0;
        alu_out_write = 0;
        mdr_write = 0;
        reg_write_src = 2'b00;  // Default is ALU out
        pc_source = 2'b00;      // Default is ALU result
        imm_sel = IMM_I_TYPE;   // Default immediate type
        branch_taken = 0;
        
        case (state)
            S_FETCH: begin
                // Control signals for fetch cycle
                mem_read = 1;        // Read from memory
                alu_src_a = 2'b00;   // ALU input A = PC
                alu_src_b = 2'b01;   // ALU input B = 2 (constant for PC+2)
                alu_op = ALU_ADD;    // ALU performs addition
                pc_write = 1;        // Update PC
                ir_write = 1;        // Update instruction register
            end
            
            S_DECODE: begin
                // Read registers and compute PC-relative branch/jump target 
                alu_src_a = 2'b00;   // ALU input A = PC
                
                // Generate immediate select based on instruction type
                if ((opcode >= OP_BEQ) && (opcode <= OP_BGE)) begin
                    imm_sel = IMM_B_TYPE;
                end else if ((opcode == OP_JAL) || (opcode == OP_JALR)) begin
                    imm_sel = IMM_J_TYPE;
                end else if ((opcode == OP_SB) || (opcode == OP_SH)) begin
                    imm_sel = IMM_S_TYPE;
                end else begin
                    imm_sel = IMM_I_TYPE;
                end
                
                alu_src_b = 2'b10;   // ALU input B = immediate value (for branch/jump prep)
                alu_op = ALU_ADD;    // ALU performs addition
                alu_out_write = 1;   // Save PC-relative target
                a_write = 1;         // Store rs1 value
                b_write = 1;         // Store rs2 value
            end
            
            S_EXECUTE: begin
                // ALU operation based on instruction type
                alu_src_a = 2'b01;   // ALU input A = A register (rs1 value)
                
                // Handle different instruction types
                case(opcode)
                    // R-type instructions
                    OP_ADD: begin
                        alu_src_b = 2'b00;  // ALU input B = B register (rs2 value)
                        
                        case (func)
                            2'b00: alu_op = ALU_ADD;
                            2'b01: alu_op = ALU_SUB;
                            2'b10: alu_op = ALU_AND;
                            2'b11: alu_op = ALU_OR;
                        endcase
                        
                        alu_out_write = 1;   // Save result
                    end
                    
                    OP_MISC: begin
                        alu_src_b = 2'b00;  // ALU input B = B register (rs2 value)
                        
                        case (func)
                            2'b00: alu_op = ALU_XOR;
                            2'b01: alu_op = ALU_SLL;
                            2'b10: alu_op = ALU_SRL;
                            2'b11: alu_op = ALU_SRA;
                        endcase
                        
                        alu_out_write = 1;   // Save result
                    end
                    
                    // I-type ALU instructions
                    OP_ADDI, OP_ANDI, OP_ORI, OP_XORI, OP_SLLI, OP_SRLI, OP_SRAI, OP_LUI: begin
                        alu_src_b = 2'b10;  // ALU input B = immediate
                        
                        case(opcode)
                            OP_ADDI: alu_op = ALU_ADD;
                            OP_ANDI: alu_op = ALU_AND;
                            OP_ORI:  alu_op = ALU_OR;
                            OP_XORI: alu_op = ALU_XOR;
                            OP_SLLI: alu_op = ALU_SLL;
                            OP_SRLI: alu_op = ALU_SRL;
                            OP_SRAI: alu_op = ALU_SRA;
                            OP_LUI:  alu_op = ALU_LUI;
                            default: alu_op = ALU_ADD;
                        endcase
                        
                        alu_out_write = 1;   // Save result
                    end
                    
                    // Load and store instructions
                    OP_LB, OP_LH, OP_SB, OP_SH: begin
                        alu_src_b = 2'b10;  // ALU input B = immediate
                        alu_op = ALU_ADD;    // Calculate address
                        alu_out_write = 1;   // Save address
                    end
                    
                    // Branch instructions
                    OP_BEQ, OP_BNE, OP_BLT, OP_BGE: begin
                        alu_src_b = 2'b00;  // ALU input B = B register
                        alu_op = ALU_SUB;    // Subtract for comparison
                        
                        // Determine if branch should be taken
                        case(opcode)
                            OP_BEQ: branch_taken = zero_flag;
                            OP_BNE: branch_taken = !zero_flag;
                            OP_BLT: branch_taken = negative_flag & !zero_flag;
                            OP_BGE: branch_taken = !negative_flag | zero_flag;
                            default: branch_taken = 0;
                        endcase
                        
                        // Update PC if branch taken
                        if (branch_taken) begin
                            pc_source = 2'b01;  // Use ALU_out (PC-relative target)
                            pc_write = 1;       // Update PC
                        end
                    end
                    
                    // Jump instructions
                    OP_JAL: begin
                        // Save return address to ALU out
                        alu_src_a = 2'b00;    // ALU input A = PC
                        alu_src_b = 2'b01;    // ALU input B = 2 (PC+2)
                        alu_op = ALU_ADD;     // Compute return address
                        alu_out_write = 1;    // Save return address
                        
                        // Update PC
                        pc_source = 2'b01;    // Use saved branch target
                        pc_write = 1;         // Update PC
                    end
                    
                    OP_JALR: begin
                        // Calculate jump target: rs1 + immediate
                        alu_src_a = 2'b01;    // ALU input A = A register (rs1 value)
                        alu_src_b = 2'b10;    // ALU input B = immediate
                        alu_op = ALU_ADD;     // Calculate target
                        
                        // Update PC to jump target
                        pc_source = 2'b00;    // Use ALU result directly
                        pc_write = 1;         // Update PC
                        
                        // Save return address to ALU out
                        alu_out_write = 1;    // Save for writeback
                    end
                    
                    default: begin
                        // Default values already set
                    end
                endcase
            end
            
            S_MEMORY: begin
                // Memory operations
                case(opcode)
                    // Load instructions
                    OP_LB, OP_LH: begin
                        mem_read = 1;       // Read from memory
                        mdr_write = 1;      // Save to MDR
                    end
                    
                    // Store instructions
                    OP_SB, OP_SH: begin
                        mem_write = 1;      // Write to memory
                    end
                    
                    default: begin
                        // Default values already set
                    end
                endcase
            end
            
            S_WRITEBACK: begin
                // Register writeback
                case(opcode)
                    // R-type and I-type instructions
                    OP_ADD, OP_MISC, OP_ADDI, OP_ANDI, OP_ORI, OP_XORI, 
                    OP_SLLI, OP_SRLI, OP_SRAI, OP_LUI: begin
                        reg_write = 1;        // Enable register write
                        reg_write_src = 2'b00; // Source = ALU out
                    end
                    
                    // Load instructions
                    OP_LB, OP_LH: begin
                        reg_write = 1;        // Enable register write
                        reg_write_src = 2'b01; // Source = MDR
                    end
                    
                    // Jump instructions with link
                    OP_JAL, OP_JALR: begin
                        reg_write = 1;        // Enable register write
                        reg_write_src = 2'b00; // Source = ALU out (return address)
                    end
                    
                    default: begin
                        // Default values already set
                    end
                endcase
            end
            
            default: begin
                // Default state, do nothing - default values already set
            end
        endcase
    end

endmodule