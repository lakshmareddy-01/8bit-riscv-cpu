module cpu_top (
    input wire clk,                  
    input wire reset,                
    output wire [7:0] pc_debug,      
    output wire [15:0] instr_debug,  
    output wire [7:0] result_debug,
    output wire [2:0] state_debug    // Debug output for current state
);

    // Simplified reset buffering with single buffer
    wire reset_buffered;
    
    // Use technology cell for synthesis, direct connection for simulation
    `ifdef SYNTHESIS
        assign rst_buf = rst;
    `else
        assign reset_buffered = reset; // Direct connection for simulation
    `endif
    
    // Internal signals for multi-cycle control
    wire [2:0] state;                // Current state
    wire pc_write;                   // Write to PC
    wire ir_write;                   // Write to Instruction Register
    wire a_write;                    // Write to A register
    wire b_write;                    // Write to B register
    wire alu_out_write;              // Write to ALU out register
    wire mdr_write;                  // Write to MDR register
    wire [1:0] alu_src_a;            // ALU A input source selector
    wire [1:0] alu_src_b;            // ALU B input source selector
    wire [1:0] reg_write_src;        // Register write source selector
    wire [1:0] pc_source;            // PC source selector
    wire branch_taken;               // Branch taken flag
    
    // Datapath and control signals from original design
    wire reg_write;                  
    wire [3:0] alu_op;               
    wire mem_read;                   
    wire mem_write;                  
    wire [1:0] imm_sel;              
    
    // PC signals
    wire [7:0] pc_out;               // Current PC value
    wire [7:0] pc_next;              // Next PC value
    
    // Instruction handling
    reg [15:0] instr_reg;            // Instruction register
    wire [15:0] memory_instr;        // Instruction read from memory
    wire [4:0] opcode;               // Instruction opcode
    wire [2:0] rd, rs1, rs2;         // Register addresses
    wire [1:0] func;                 // Function field
    
    // Check if current instruction is S-type (SB or SH)
    wire is_store = (opcode == 5'b10100) || (opcode == 5'b10101);
    
    // Register file signals
    // For S-type instructions, swap the register addressing to match S-type format
    wire [2:0] rs1_addr = is_store ? rd : rs1;   // Use rd as base addr for stores
    wire [2:0] rs2_addr = is_store ? rs1 : rs2;  // Use rs1 as data register for stores
    wire [7:0] rs1_data, rs2_data;   // Data from register file
    reg [7:0] a_reg, b_reg;          // Pipeline registers for rs1 and rs2 data
    
    // ALU signals
    wire [7:0] alu_a, alu_b;         // ALU inputs
    wire [7:0] alu_result;           // ALU result
    reg [7:0] alu_out_reg;           // ALU output register
    wire zero_flag, negative_flag;   // ALU flags
    
    // Memory signals
    wire [7:0] immediate;            // Immediate value
    wire [15:0] mem_read_data;       // Data read from memory
    reg [7:0] mdr_reg;               // Memory Data Register
    
    // Register writeback signals
    wire [7:0] write_data;           // Data to write to register file
    
    // Debug outputs
    assign pc_debug = pc_out;
    assign instr_debug = instr_reg;
    assign result_debug = alu_out_reg;
    assign state_debug = state;
    
    // Next PC value selection
    assign pc_next = (pc_source == 2'b01) ? alu_out_reg : alu_result;
    
    // ALU input selection
    assign alu_a = (alu_src_a == 2'b00) ? pc_out : 
                   (alu_src_a == 2'b01) ? a_reg : 
                   8'h00;  // Default
                   
    assign alu_b = (alu_src_b == 2'b00) ? b_reg : 
                   (alu_src_b == 2'b01) ? 8'h02 :  // Constant 2 for PC+2
                   (alu_src_b == 2'b10) ? immediate : 
                   8'h00;  // Default
    
    // Register write data selection
    assign write_data = (reg_write_src == 2'b00) ? alu_out_reg :
                        (reg_write_src == 2'b01) ? mdr_reg :
                        8'h00;  // Default
    
    // Pipeline registers
    // Instruction Register
    always @(posedge clk or posedge reset_buffered) begin
        if (reset_buffered) begin
            instr_reg <= 16'h0000;
        end else if (ir_write) begin
            instr_reg <= memory_instr;
        end
    end
    
    // A Register (rs1 data)
    always @(posedge clk or posedge reset_buffered) begin
        if (reset_buffered) begin
            a_reg <= 8'h00;
        end else if (a_write) begin
            a_reg <= rs1_data;
        end
    end
    
    // B Register (rs2 data)
    always @(posedge clk or posedge reset_buffered) begin
        if (reset_buffered) begin
            b_reg <= 8'h00;
        end else if (b_write) begin
            b_reg <= rs2_data;
        end
    end
    
    // ALU Out Register
    always @(posedge clk or posedge reset_buffered) begin
        if (reset_buffered) begin
            alu_out_reg <= 8'h00;
        end else if (alu_out_write) begin
            alu_out_reg <= alu_result;
        end
    end
    
    // Memory Data Register
    always @(posedge clk or posedge reset_buffered) begin
        if (reset_buffered) begin
            mdr_reg <= 8'h00;
        end else if (mdr_write) begin
            // For half-word loads (LH), get the first byte (memory[data_addr]) which is in the upper byte of read_data
            // For byte loads (LB), get the addressed byte which is in the lower byte of read_data
            mdr_reg <= (opcode == 5'b10001) ? mem_read_data[15:8] : mem_read_data[7:0];
        end
    end
    
    // Program Counter
    program_counter pc (
        .clk(clk),
        .reset(reset_buffered),
        .pc_load(pc_write),
        .pc_load_val(pc_next),
        .pc_out(pc_out)
    );
    
    // Memory Interface
    memory_interface mem (
        .clk(clk),
        .reset(reset_buffered),          // Connect reset signal
        .instr_addr(pc_out),
        .instruction(memory_instr),
        .data_addr(alu_out_reg),
        .write_data(b_reg),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .is_byte(opcode == 5'b10000 || opcode == 5'b10100),
        .read_data(mem_read_data)
    );
    
    // Instruction Decoder - use IR as input
    instruction_decoder decoder (
        .instruction(instr_reg),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .func(func)
    );
    
    // Control Unit - now has state machine logic
    control_unit ctrl (
        .clk(clk),
        .reset(reset_buffered),
        .opcode(opcode),
        .func(func),
        .zero_flag(zero_flag),
        .negative_flag(negative_flag),
        .state(state),
        .pc_write(pc_write),
        .ir_write(ir_write),
        .reg_write(reg_write),
        .alu_op(alu_op),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .a_write(a_write),
        .b_write(b_write),
        .alu_out_write(alu_out_write),
        .mdr_write(mdr_write),
        .reg_write_src(reg_write_src),
        .pc_source(pc_source),
        .imm_sel(imm_sel),
        .branch_taken(branch_taken)
    );
    
    // Register File with conditional register addressing for S-type
    register_file regfile (
        .clk(clk),
        .reset(reset_buffered),
        .rs1_addr(rs1_addr),  // Conditionally use rd for S-type
        .rs2_addr(rs2_addr),  // Conditionally use rs1 for S-type
        .rd_addr(rd),
        .rd_data(write_data),
        .wr_en(reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );
    
    // Immediate Generator
    immediate_gen immgen (
        .instruction(instr_reg),
        .imm_sel(imm_sel),
        .immediate(immediate)
    );
    
    // ALU
    alu main_alu (
        .operand_a(alu_a),
        .operand_b(alu_b),
        .alu_op(alu_op),
        .result(alu_result),
        .zero_flag(zero_flag),
        .negative_flag(negative_flag)
    );

    // Debug monitor block for simulation only
    `ifndef SYNTHESIS
        // This block will print key events during simulation
        always @(posedge clk) begin
            // Print register writes
            if (reg_write) begin
                $display("Register write: r%0d = %h", rd, write_data);
            end
            
            // Print memory operations
            if (mem_write) begin
                $display("Memory write: mem[%h] = %h", alu_out_reg, b_reg);
            end
            
            if (mem_read && state == 3'b011) begin // Only in MEMORY state
                $display("Memory read: mem[%h] = %h", alu_out_reg, mem_read_data[7:0]);
            end
            
            // Print state transitions
            if (state == 3'b000) begin // FETCH
                $display("Starting new instruction at PC=%h", pc_out);
            end
        end
    `endif

endmodule
