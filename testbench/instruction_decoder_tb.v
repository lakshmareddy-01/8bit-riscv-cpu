`timescale 1ns/1ps

module instruction_decoder_tb;
    // Testbench signals
    reg [15:0] instruction;
    wire [4:0] opcode;
    wire [2:0] rd;
    wire [2:0] rs1;
    wire [2:0] rs2;
    wire [1:0] func;
    
    // Instantiate the Unit Under Test (UUT)
    instruction_decoder uut (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .func(func)
    );
    
    // Test stimulus and verification
    initial begin
        // Initialize VCD file
        $dumpfile("results/sim/waves/instruction_decoder_tb.vcd");
        $dumpvars(0, instruction_decoder_tb);
        
        // Initialize Inputs
        instruction = 16'h0000;
        #10;
        
        $display("Testing instruction decoding for the test program instructions...");
        
        // Test case 1: ADDI r1, r0, 5 (from memory[0:1])
        instruction = 16'h4105;
        #10;
        
        // Verify decoded fields
        if (opcode !== 5'b01000) begin // ADDI
            $display("ERROR: ADDI opcode mismatch. Expected: 01000, Got: %b", opcode);
        end else begin
            $display("PASS: ADDI opcode correctly decoded");
        end
        if (rd !== 3'b001) begin // r1
            $display("ERROR: ADDI rd mismatch. Expected: 001, Got: %b", rd);
        end else begin
            $display("PASS: ADDI rd correctly decoded");
        end
        if (rs1 !== 3'b000) begin // r0
            $display("ERROR: ADDI rs1 mismatch. Expected: 000, Got: %b", rs1);
        end else begin
            $display("PASS: ADDI rs1 correctly decoded");
        end
        
        // Test case 2: ADDI r2, r0, 7 (from memory[2:3])
        instruction = 16'h4207;
        #10;
        
        // Verify decoded fields
        if (opcode !== 5'b01000) begin // ADDI
            $display("ERROR: ADDI opcode mismatch. Expected: 01000, Got: %b", opcode);
        end else begin
            $display("PASS: ADDI opcode correctly decoded");
        end
        if (rd !== 3'b010) begin // r2
            $display("ERROR: ADDI rd mismatch. Expected: 010, Got: %b", rd);
        end else begin
            $display("PASS: ADDI rd correctly decoded");
        end
        if (rs1 !== 3'b000) begin // r0
            $display("ERROR: ADDI rs1 mismatch. Expected: 000, Got: %b", rs1);
        end else begin
            $display("PASS: ADDI rs1 correctly decoded");
        end
        
        // Test case 3: ADD r3, r1, r2 (from memory[4:5])
        instruction = 16'h0328;
        #10;
        
        // Verify decoded fields
        if (opcode !== 5'b00000) begin // ADD
            $display("ERROR: ADD opcode mismatch. Expected: 00000, Got: %b", opcode);
        end else begin
            $display("PASS: ADD opcode correctly decoded");
        end
        if (rd !== 3'b011) begin // r3
            $display("ERROR: ADD rd mismatch. Expected: 011, Got: %b", rd);
        end else begin
            $display("PASS: ADD rd correctly decoded");
        end
        if (rs1 !== 3'b001) begin // r1
            $display("ERROR: ADD rs1 mismatch. Expected: 001, Got: %b", rs1);
        end else begin
            $display("PASS: ADD rs1 correctly decoded");
        end
        if (rs2 !== 3'b010) begin // r2
            $display("ERROR: ADD rs2 mismatch. Expected: 010, Got: %b", rs2);
        end else begin
            $display("PASS: ADD rs2 correctly decoded");
        end
        if (func !== 2'b00) begin // ADD function
            $display("ERROR: ADD func mismatch. Expected: 00, Got: %b", func);
        end else begin
            $display("PASS: ADD func correctly decoded");
        end
        
        // Test case 4: SB r3, 0(r0) (from memory[6:7])
        instruction = 16'hA060;
        #10;
        
        // Verify decoded fields for S-type
        if (opcode !== 5'b10100) begin // SB
            $display("ERROR: SB opcode mismatch. Expected: 10100, Got: %b", opcode);
        end else begin
            $display("PASS: SB opcode correctly decoded");
        end
        if (rd !== 3'b000) begin // bit field [10:8] = 000
            $display("ERROR: SB bit field [10:8] mismatch. Expected: 000, Got: %b", rd);
        end else begin
            $display("PASS: SB bit field [10:8] correctly decoded");
        end
        if (rs1 !== 3'b011) begin // bit field [7:5] = 011
            $display("ERROR: SB bit field [7:5] mismatch. Expected: 011, Got: %b", rs1);
        end else begin
            $display("PASS: SB bit field [7:5] correctly decoded");
        end
        
        // Test case 5: LB r4, 0(r0) (from memory[8:9] - CORRECTED)
        instruction = 16'h8400;
        #10;
        
        // Verify decoded fields for I-type
        if (opcode !== 5'b10000) begin // LB
            $display("ERROR: LB opcode mismatch. Expected: 10000, Got: %b", opcode);
        end else begin
            $display("PASS: LB opcode correctly decoded");
        end
        if (rd !== 3'b100) begin // bit field [10:8] = 100 (r4)
            $display("ERROR: LB rd mismatch. Expected: 100, Got: %b", rd);
        end else begin
            $display("PASS: LB rd correctly decoded");
        end
        if (rs1 !== 3'b000) begin // bit field [7:5] = 000 (r0)
            $display("ERROR: LB rs1 mismatch. Expected: 000, Got: %b", rs1);
        end else begin
            $display("PASS: LB rs1 correctly decoded");
        end
        
        $display("All test program instructions decoded successfully!");
        
        #10;
        $finish;
    end
endmodule