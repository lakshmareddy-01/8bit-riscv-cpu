`timescale 1ns/1ps

module alu_tb;
    // Testbench signals
    reg [7:0] operand_a;
    reg [7:0] operand_b;
    reg [3:0] alu_op;
    wire [7:0] result;
    wire zero_flag;
    wire negative_flag;
    
    // ALU operation codes
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
    
    // Instantiate the ALU
    alu uut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .alu_op(alu_op),
        .result(result),
        .zero_flag(zero_flag),
        .negative_flag(negative_flag)
    );
    
    // Test stimulus
    initial begin
        // Initialize waveform dump
        $dumpfile("results/sim/waves/alu_tb.vcd");
        $dumpvars(0, alu_tb);
        
        // Initialize inputs
        operand_a = 8'h00;
        operand_b = 8'h00;
        alu_op = ALU_ADD;
        #10;
        
        // Test case 1: ADD operation
        operand_a = 8'h00;
        operand_b = 8'h05;
        alu_op = ALU_ADD;
        #10;
        if (result !== 8'h05) $display("ADD Error: Expected 0x05, got %h", result);
        else $display("ADD Passed");
        
        // Test case 2: SUB operation
        operand_a = 8'h05;
        operand_b = 8'h05;
        alu_op = ALU_SUB;
        #10;
        if (result !== 8'h00) $display("SUB Error: Expected 0x00, got %h", result);
        else $display("SUB Passed");
        
        // Test case 3: AND operation  
        operand_a = 8'h0F;
        operand_b = 8'h33;
        alu_op = ALU_AND;
        #10;
        if (result !== 8'h03) $display("AND Error: Expected 0x03, got %h", result);
        else $display("AND Passed");
        
        // Test case 4: OR operation
        operand_a = 8'h0F;
        operand_b = 8'h30;
        alu_op = ALU_OR;
        #10;
        if (result !== 8'h3F) $display("OR Error: Expected 0x3F, got %h", result);
        else $display("OR Passed");
        
        // Test case 5: XOR operation
        operand_a = 8'h0F;
        operand_b = 8'h33;
        alu_op = ALU_XOR;
        #10;
        if (result !== 8'h3C) $display("XOR Error: Expected 0x3C, got %h", result);
        else $display("XOR Passed");
        
        // Test case 6: SLL operation
        operand_a = 8'h05;
        operand_b = 8'h02;
        alu_op = ALU_SLL;
        #10;
        if (result !== 8'h14) $display("SLL Error: Expected 0x14, got %h", result);
        else $display("SLL Passed");
        
        // Test case 7: SRL operation
        operand_a = 8'h80;
        operand_b = 8'h04;
        alu_op = ALU_SRL;
        #10;
        if (result !== 8'h08) $display("SRL Error: Expected 0x08, got %h", result);
        else $display("SRL Passed");
        
        // Test case 8: SRA operation
        operand_a = 8'h80;
        operand_b = 8'h01;
        alu_op = ALU_SRA;
        #10;
        if (result !== 8'hC0) $display("SRA Error: Expected 0xC0, got %h", result);
        else $display("SRA Passed");
        
        // Test case 9: LUI operation
        operand_a = 8'h00;
        operand_b = 8'h3A;
        alu_op = ALU_LUI;
        #10;
        if (result !== 8'h3A) $display("LUI Error: Expected 0x3A, got %h", result);
        else $display("LUI Passed");
        
        // Test case 10: Flag testing
        operand_a = 8'h00;
        operand_b = 8'h00;
        alu_op = ALU_SUB;
        #10;
        if (zero_flag !== 1'b1) $display("Zero Flag Error");
        else $display("Zero Flag Passed");
        
        operand_a = 8'h01;
        operand_b = 8'h02;
        alu_op = ALU_SUB;
        #10;
        if (negative_flag !== 1'b1) $display("Negative Flag Error");
        else $display("Negative Flag Passed");
        
        #10;
        $finish;
    end
endmodule