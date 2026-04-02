`timescale 1ns/1ps

module cpu_top_tb;
    // Testbench signals
    reg clk;
    reg reset;
    wire [7:0] pc_debug;
    wire [15:0] instr_debug;
    wire [7:0] result_debug;
    wire [2:0] state_debug;
    
    // Instantiate the Unit Under Test (UUT)
    cpu_top uut (
        .clk(clk),
        .reset(reset),
        .pc_debug(pc_debug),
        .instr_debug(instr_debug),
        .result_debug(result_debug),
        .state_debug(state_debug)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Convert state to readable format for display
    task display_state;
        input [2:0] state;
        begin
            case(state)
                3'b000: $write("FETCH");
                3'b001: $write("DECODE");
                3'b010: $write("EXECUTE");
                3'b011: $write("MEMORY");
                3'b100: $write("WRITEBACK");
                default: $write("UNKNOWN");
            endcase
        end
    endtask
    
    // Display current CPU state
    always @(posedge clk) begin
        $write("Time %0t: PC=%h, Instr=%h, State=", $time, pc_debug, instr_debug);
        display_state(state_debug);
        $display("");
    end
    
    // Test stimulus and verification
    initial begin
        // Initialize VCD file
        $dumpfile("results/sim/waves/cpu_top_tb.vcd");
        $dumpvars(0, cpu_top_tb);
        
        // Apply reset
        reset = 1;
        #20 reset = 0;
        
        // Display start of simulation
        $display("Starting CPU simulation at time %0t", $time);
        $display("-------------------------------------------");
        $display("Testing test program execution:");
        $display("1. ADDI r1, r0, 5    (r1 = 5)");
        $display("2. ADDI r2, r0, 7    (r2 = 7)");
        $display("3. ADD r3, r1, r2    (r3 = 12)");
        $display("4. SB r3, 0(r0)      (mem[0] = 12)");
        $display("5. LB r4, 0(r0)      (r4 = 12)");
        $display("-------------------------------------------");
        
        // Run long enough for the test program to complete
        #500;
        
        // Summary
        $display("-------------------------------------------");
        $display("Test program execution completed!");
        $display("Check the waveform to verify the values in registers.");
        $display("When viewing in GTKWave, add the internal CPU signals to");
        $display("observe r1=5, r2=7, r3=12, and memory operation results.");
        $display("-------------------------------------------");
        
        // End simulation
        #10;
        $finish;
    end
endmodule