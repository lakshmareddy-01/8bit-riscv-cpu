`timescale 1ns/1ps

module program_counter_tb;
    // Testbench signals
    reg clk;
    reg reset;
    reg pc_load;
    reg [7:0] pc_load_val;
    wire [7:0] pc_out;
    
    // Instantiate the Unit Under Test (UUT)
    program_counter uut (
        .clk(clk),
        .reset(reset),
        .pc_load(pc_load),
        .pc_load_val(pc_load_val),
        .pc_out(pc_out)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Test stimulus and verification
    initial begin
        // Initialize VCD file
        $dumpfile("results/sim/waves/program_counter_tb.vcd");
        $dumpvars(0, program_counter_tb);
        
        // Initialize Inputs
        reset = 0;
        pc_load = 0;
        pc_load_val = 8'h00;
        
        // Apply reset
        #2 reset = 1;
        #10 reset = 0;
        
        // Test case 1: Loading first instruction address (0x00)
        #10;
        pc_load = 1;
        pc_load_val = 8'h00;
        #10 pc_load = 0;
        
        // Verify PC value after load
        #1;
        if (pc_out !== 8'h00) begin
            $display("ERROR: PC value mismatch after first load. Expected: 0x00, Got: %h", pc_out);
        end else begin
            $display("PASS: PC correctly loaded with 0x00");
        end
        
        // Test case 2: Loading next instruction address (0x02)
        // This simulates PC+2 for the next instruction
        #10;
        pc_load = 1;
        pc_load_val = 8'h02;
        #10 pc_load = 0;
        
        // Verify PC value after second load
        #1;
        if (pc_out !== 8'h02) begin
            $display("ERROR: PC value mismatch after second load. Expected: 0x02, Got: %h", pc_out);
        end else begin
            $display("PASS: PC correctly loaded with 0x02");
        end
        
        // Test case 3: Verify PC doesn't change when pc_load is not asserted
        #10;
        pc_load = 0;
        pc_load_val = 8'h04;
        #10;
        
        // Verify PC remains unchanged
        if (pc_out !== 8'h02) begin
            $display("ERROR: PC value changed without pc_load. Expected: 0x02, Got: %h", pc_out);
        end else begin
            $display("PASS: PC correctly maintained value when pc_load not asserted");
        end
        
        // Test case 4: Branch/jump simulation - load PC with branch target
        #10;
        pc_load = 1;
        pc_load_val = 8'h08; // Jump to load instruction
        #10 pc_load = 0;
        
        // Verify PC value after branch
        #1;
        if (pc_out !== 8'h08) begin
            $display("ERROR: PC value mismatch after branch. Expected: 0x08, Got: %h", pc_out);
        end else begin
            $display("PASS: PC correctly branched to 0x08");
        end
        
        // Test case 5: Reset during operation
        #10;
        reset = 1;
        #10 reset = 0;
        
        // Verify PC value after reset
        #1;
        if (pc_out !== 8'h00) begin
            $display("ERROR: PC value not reset. Expected: 0x00, Got: %h", pc_out);
        end else begin
            $display("PASS: PC correctly reset to 0x00");
        end
        
        #10 $finish;
    end
endmodule