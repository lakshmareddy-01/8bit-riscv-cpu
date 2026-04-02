`timescale 1ns/1ps

module immediate_gen_tb;
    // Testbench signals
    reg [15:0] instruction;
    reg [1:0] imm_sel;
    wire [7:0] immediate;
    
    // Immediate select codes
    localparam [1:0]
        IMM_I_TYPE = 2'b00,
        IMM_S_TYPE = 2'b01,
        IMM_B_TYPE = 2'b10,
        IMM_J_TYPE = 2'b11;
    
    // Instantiate the Unit Under Test (UUT)
    immediate_gen uut (
        .instruction(instruction),
        .imm_sel(imm_sel),
        .immediate(immediate)
    );
    
    // Test stimulus and verification
    initial begin
        // Initialize VCD file
        $dumpfile("results/sim/waves/immediate_gen_tb.vcd");
        $dumpvars(0, immediate_gen_tb);
        
        // Initialize Inputs
        instruction = 16'h0000;
        imm_sel = 2'b00;
        #10;
        
        // Test case 1: I-type - ADDI r1, r0, 5
        instruction = 16'h4105;
        imm_sel = IMM_I_TYPE;
        #10;
        
        if (immediate !== 8'h05) begin
            $display("ERROR: I-type immediate mismatch. Expected: 0x05, Got: %h", immediate);
        end else begin
            $display("PASS: I-type immediate correctly extracted");
        end
        
        // Test case 2: I-type - ADDI r2, r0, 7
        instruction = 16'h4207;
        imm_sel = IMM_I_TYPE;
        #10;
        
        if (immediate !== 8'h07) begin
            $display("ERROR: I-type immediate mismatch. Expected: 0x07, Got: %h", immediate);
        end else begin
            $display("PASS: I-type immediate correctly extracted");
        end
        
        // Test case 3: S-type - SB r3, 0(r0)
        instruction = 16'hA060;
        imm_sel = IMM_S_TYPE;
        #10;
        
        if (immediate !== 8'h00) begin
            $display("ERROR: S-type immediate mismatch. Expected: 0x00, Got: %h", immediate);
        end else begin
            $display("PASS: S-type immediate correctly extracted");
        end
        
        // Test case 4: B-type - BEQ r1, r2, 4
        instruction = 16'hC124;
        imm_sel = IMM_B_TYPE;
        #10;
        
        if (immediate !== 8'h04) begin
            $display("ERROR: B-type immediate mismatch. Expected: 0x04, Got: %h", immediate);
        end else begin
            $display("PASS: B-type immediate correctly extracted");
        end
        
        // Test case 5: J-type - JAL r1, 8
        instruction = 16'hE108;
        imm_sel = IMM_J_TYPE;
        #10;
        
        if (immediate !== 8'h08) begin
            $display("ERROR: J-type immediate mismatch. Expected: 0x08, Got: %h", immediate);
        end else begin
            $display("PASS: J-type immediate correctly extracted");
        end
        
        // Test case 6: I-type with negative immediate
        instruction = 16'h411E;
        imm_sel = IMM_I_TYPE;
        #10;
        
        if (immediate !== 8'hFE) begin
            $display("ERROR: Negative I-type immediate mismatch. Expected: 0xFE, Got: %h", immediate);
        end else begin
            $display("PASS: Negative I-type immediate correctly sign-extended");
        end
        
        // Test case 7: B-type with negative immediate
        instruction = 16'hC11C;
        imm_sel = IMM_B_TYPE;
        #10;
        
        if (immediate !== 8'hFC) begin
            $display("ERROR: Negative B-type immediate mismatch. Expected: 0xFC, Got: %h", immediate);
        end else begin
            $display("PASS: Negative B-type immediate correctly sign-extended");
        end
        
        // Test case 8: Large J-type immediate
        instruction = 16'hE1FF;
        imm_sel = IMM_J_TYPE;
        #10;
        
        if (immediate !== 8'hFF) begin
            $display("ERROR: Large J-type immediate mismatch. Expected: 0xFF, Got: %h", immediate);
        end else begin
            $display("PASS: Large J-type immediate correctly extracted");
        end
        
        #10;
        $finish;
    end
endmodule