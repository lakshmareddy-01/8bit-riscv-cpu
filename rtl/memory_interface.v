// Memory Interface for multi-cycle 8-bit RISC-V inspired CPU
// Provides separate instruction and data paths to memory

module memory_interface (
    input wire clk,
    input wire reset,                // Reset signal for ASIC compatibility
    // Separate instruction path
    input wire [7:0] instr_addr,
    output wire [15:0] instruction,
    
    // Data path
    input wire [7:0] data_addr,
    input wire [7:0] write_data,
    input wire mem_read,
    input wire mem_write,
    input wire is_byte,
    output reg [15:0] read_data
);
    
    // === SIMULATION MODEL ===
    `ifdef SIMULATION
        // Simulation model with full memory array
        reg [7:0] memory [0:255];
        
        // Initial setup - runs once at simulation start
        integer i;
        initial begin
            // Clear memory
            for (i = 0; i < 256; i = i + 1) begin
                memory[i] = 8'h00;
            end
            
            // Load the test program
            memory[0] = 8'h41; 
            memory[1] = 8'h05;
            memory[2] = 8'h42; 
            memory[3] = 8'h07;
            memory[4] = 8'h03; 
            memory[5] = 8'h28;
            memory[6] = 8'hA0;
            memory[7] = 8'h60;
            memory[8] = 8'h84; 
            memory[9] = 8'h00;
        end
        
        // Reset handler - reinitializes memory to test program on reset
        always @(posedge clk or posedge reset) begin
            if (reset) begin
                // Reload the test program on reset
                memory[0] <= 8'h41; 
                memory[1] <= 8'h05;
                memory[2] <= 8'h42; 
                memory[3] <= 8'h07;
                memory[4] <= 8'h03; 
                memory[5] <= 8'h28;
                memory[6] <= 8'hA0;
                memory[7] <= 8'h60;
                memory[8] <= 8'h84; 
                memory[9] <= 8'h00;
                // Clear rest of memory
                for (i = 10; i < 256; i = i + 1) begin
                    memory[i] <= 8'h00;
                end
            end
        end
        
        // Instruction access is always available (combinational)
        assign instruction = {memory[instr_addr], memory[instr_addr + 8'h01]};
        
        // Data access is controlled by mem_read/mem_write
        always @(*) begin
            if (mem_read) begin
                if (is_byte) begin
                    read_data = {8'h00, memory[data_addr]};
                end else begin
                    read_data = {memory[data_addr], memory[data_addr + 8'h01]};
                end
            end else begin
                read_data = 16'h0000;
            end
        end
        
        always @(posedge clk) begin
            if (!reset && mem_write) begin
                if (is_byte) begin
                    memory[data_addr] <= write_data;
                end else begin
                    memory[data_addr] <= write_data;
                    memory[data_addr + 8'h01] <= 8'h00;
                end
            end
        end
    
    // === SYNTHESIS MODEL ===
    `else
        // Synthesis model with register array (more scalable)
        reg [7:0] synth_mem [0:15];  // 16-byte memory array
        
        // Reset-based initialization for ASIC implementation
        // All memory is initialized to zero on reset for deterministic startup
        integer i;
        always @(posedge clk or posedge reset) begin
            if (reset) begin
                // Initialize ALL memory locations to zero
                for (i = 0; i < 16; i = i + 1) begin
                    synth_mem[i] <= 8'h00;
                end
            end else if (mem_write) begin
                // Write operation - simplified with array access
                if (is_byte) begin
                    if (data_addr < 16) begin
                        synth_mem[data_addr] <= write_data;
                    end
                end else begin
                    if (data_addr < 16) begin
                        synth_mem[data_addr] <= write_data;
                        if (data_addr + 1 < 16) begin
                            synth_mem[data_addr + 1] <= 8'h00;
                        end
                    end
                end
            end
        end
        
        // Instruction fetch logic - using array access
        reg [15:0] instr_out;
        always @(*) begin
            instr_out = 16'h0000; // Default value
            if (instr_addr < 15) begin
                instr_out = {synth_mem[instr_addr], synth_mem[instr_addr + 1]};
            end
        end
        assign instruction = instr_out;
        
        // Data read logic - using array access for cleaner code
        always @(*) begin
            read_data = 16'h0000; // Default value
            if (mem_read) begin
                if (is_byte) begin
                    if (data_addr < 16) begin
                        read_data = {8'h00, synth_mem[data_addr]};
                    end
                end else begin
                    if (data_addr < 15) begin
                        read_data = {synth_mem[data_addr], synth_mem[data_addr + 1]};
                    end
                end
            end
        end
    `endif

endmodule