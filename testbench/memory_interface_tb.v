`timescale 1ns/1ps
`define SIMULATION  // Define SIMULATION for testbench

module memory_interface_tb;
    // Testbench signals
    reg clk;
    reg reset;
    reg [7:0] instr_addr;
    wire [15:0] instruction;
    reg [7:0] data_addr;
    reg [7:0] write_data;
    reg mem_read;
    reg mem_write;
    reg is_byte;
    wire [15:0] read_data;
    
    // For test program instructions (UPDATED WITH CORRECTED LB INSTRUCTION)
    localparam [15:0]
        INSTR_ADDI_R1 = 16'h4105, // ADDI r1, r0, 5
        INSTR_ADDI_R2 = 16'h4207, // ADDI r2, r0, 7
        INSTR_ADD_R3  = 16'h0328, // ADD r3, r1, r2
        INSTR_SB_R3   = 16'hA060, // SB r3, 0(r0)
        INSTR_LB_R4   = 16'h8400; // CORRECTED: LB r4, 0(r0)
    
    // Instantiate the Unit Under Test (UUT)
    memory_interface uut (
        .clk(clk),
        .reset(reset),
        .instr_addr(instr_addr),
        .instruction(instruction),
        .data_addr(data_addr),
        .write_data(write_data),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .is_byte(is_byte),
        .read_data(read_data)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Test stimulus and verification
    initial begin
        // Initialize VCD file
        $dumpfile("results/sim/waves/memory_interface_tb.vcd");
        $dumpvars(0, memory_interface_tb);
        
        // Initialize Inputs
        reset = 1;                // Start with reset active
        instr_addr = 8'h00;
        data_addr = 8'h00;
        write_data = 8'h00;
        mem_read = 0;
        mem_write = 0;
        is_byte = 0;
        
        // Apply reset for a few cycles
        #20 reset = 0;
        #10;
        
        // Test case 1: Verify reset-based initialization
        $display("Testing reset-based initialization...");
        instr_addr = 8'h00;
        #5;
        
        // In simulation, the memory should be initialized to the test program
        if (instruction !== INSTR_ADDI_R1) begin
            $display("ERROR: Instruction at 0x00 mismatch after reset. Expected: %h, Got: %h", INSTR_ADDI_R1, instruction);
        end else begin
            $display("PASS: Instruction at 0x00 correctly initialized after reset: %h (ADDI r1, r0, 5)", instruction);
        end
        
        // Continue with original test cases
        // Test case 2: Instruction fetch for ADDI r2, r0, 7 (address 0x02)
        instr_addr = 8'h02;
        #5;
        
        // Verify instruction
        if (instruction !== INSTR_ADDI_R2) begin
            $display("ERROR: Instruction at 0x02 mismatch. Expected: %h, Got: %h", INSTR_ADDI_R2, instruction);
        end else begin
            $display("PASS: Instruction at 0x02 correctly fetched: %h (ADDI r2, r0, 7)", instruction);
        end
        
        // Test case 3: Test store and load operations
        data_addr = 8'h00;
        write_data = 8'h0C; // Value in r3 (12)
        mem_write = 1;
        is_byte = 1;
        #10; // One clock cycle
        mem_write = 0;
        #5;
        
        // Load byte from memory
        mem_read = 1;
        #5;
        
        // Verify loaded data
        if (read_data[7:0] !== 8'h0C) begin
            $display("ERROR: Loaded byte mismatch. Expected: 0x0C, Got: %h", read_data[7:0]);
        end else begin
            $display("PASS: Byte correctly loaded from memory: %h", read_data[7:0]);
        end
        mem_read = 0;
        
        // Test reset again to verify it properly reinitializes memory
        reset = 1;
        #20;
        reset = 0;
        #10;
        
        // Verify memory state after reset - in simulation this should restore the test program
        data_addr = 8'h00;
        mem_read = 1;
        is_byte = 1;
        #5;
        
        // After reset, memory should still contain the test program in simulation mode
        if (read_data[7:0] !== 8'h41) begin
            $display("ERROR: Memory not properly reinitialized after second reset. Expected: 0x41, Got: %h", read_data[7:0]);
        end else begin
            $display("PASS: Memory properly reinitialized after second reset");
        end
        
        #10 $finish;
    end
endmodule
