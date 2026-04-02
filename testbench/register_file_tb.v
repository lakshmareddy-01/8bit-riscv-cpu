`timescale 1ns/1ps

module register_file_tb;
    // Testbench signals
    reg clk;
    reg reset;
    reg [2:0] rs1_addr;
    reg [2:0] rs2_addr;
    reg [2:0] rd_addr;
    reg [7:0] rd_data;
    reg wr_en;
    wire [7:0] rs1_data;
    wire [7:0] rs2_data;
    
    // For test program register addresses
    localparam [2:0]
        REG_ZERO = 3'b000,
        REG_R1   = 3'b001,
        REG_R2   = 3'b010,
        REG_R3   = 3'b011,
        REG_R4   = 3'b100;
    
    // Instantiate the Unit Under Test (UUT)
    register_file uut (
        .clk(clk),
        .reset(reset),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .wr_en(wr_en),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Test stimulus and verification
    initial begin
        // Initialize VCD file
        $dumpfile("results/sim/waves/register_file_tb.vcd");
        $dumpvars(0, register_file_tb);
        
        // Initialize Inputs
        rs1_addr = 3'b000;
        rs2_addr = 3'b000;
        rd_addr = 3'b000;
        rd_data = 8'h00;
        wr_en = 0;
        
        // Apply reset
        reset = 1;
        #10 reset = 0;
        #10;
        
        // Test case 1: Verify r0 is hardwired to 0
        rs1_addr = REG_ZERO;
        #5;
        if (rs1_data !== 8'h00) begin
            $display("ERROR: r0 not hardwired to 0. Got: %h", rs1_data);
        end else begin
            $display("PASS: r0 is hardwired to 0");
        end
        
        // Test case 2: Verify r0 is hardwired to 0 (write attempt)
        rd_addr = REG_ZERO;
        rd_data = 8'hFF;
        wr_en = 1;
        #10 wr_en = 0;
        rs1_addr = REG_ZERO;
        #5;
        if (rs1_data !== 8'h00) begin
            $display("ERROR: r0 not hardwired to 0 after write attempt. Got: %h", rs1_data);
        end else begin
            $display("PASS: r0 remains 0 after write attempt");
        end
        
        // Test case 3: Write to r1
        rd_addr = REG_R1;
        rd_data = 8'h05;
        wr_en = 1;
        #10 wr_en = 0;
        rs1_addr = REG_R1;
        #5;
        if (rs1_data !== 8'h05) begin
            $display("ERROR: r1 value incorrect after write. Expected: 0x05, Got: %h", rs1_data);
        end else begin
            $display("PASS: r1 correctly set to 5");
        end
        
        // Test case 4: Write to r2
        rd_addr = REG_R2;
        rd_data = 8'h07;
        wr_en = 1;
        #10 wr_en = 0;
        rs1_addr = REG_R2;
        #5;
        if (rs1_data !== 8'h07) begin
            $display("ERROR: r2 value incorrect after write. Expected: 0x07, Got: %h", rs1_data);
        end else begin
            $display("PASS: r2 correctly set to 7");
        end
        
        // Test case 5: Simultaneous read of r1 and r2
        rs1_addr = REG_R1;
        rs2_addr = REG_R2;
        #5;
        if (rs1_data !== 8'h05 || rs2_data !== 8'h07) begin
            $display("ERROR: Simultaneous read failed. Expected: r1=0x05, r2=0x07, Got: r1=%h, r2=%h", rs1_data, rs2_data);
        end else begin
            $display("PASS: Simultaneous read of r1 and r2 correct");
        end
        
        // Test case 6: Write to r3
        rd_addr = REG_R3;
        rd_data = 8'h0C;
        wr_en = 1;
        #10 wr_en = 0;
        rs1_addr = REG_R3;
        #5;
        if (rs1_data !== 8'h0C) begin
            $display("ERROR: r3 value incorrect after write. Expected: 0x0C, Got: %h", rs1_data);
        end else begin
            $display("PASS: r3 correctly set to 12");
        end
        
        // Test case 7: Write to r4
        rd_addr = REG_R4;
        rd_data = 8'h0C;
        wr_en = 1;
        #10 wr_en = 0;
        rs1_addr = REG_R4;
        #5;
        if (rs1_data !== 8'h0C) begin
            $display("ERROR: r4 value incorrect after write. Expected: 0x0C, Got: %h", rs1_data);
        end else begin
            $display("PASS: r4 correctly set to 12");
        end
        
        // Test case 8: Reset all registers
        reset = 1;
        #10 reset = 0;
        #5;
        rs1_addr = REG_R1;
        #5;
        if (rs1_data !== 8'h00) begin
            $display("ERROR: r1 not reset. Expected: 0x00, Got: %h", rs1_data);
        end else begin
            $display("PASS: r1 correctly reset to 0");
        end
        rs1_addr = REG_R3;
        #5;
        if (rs1_data !== 8'h00) begin
            $display("ERROR: r3 not reset. Expected: 0x00, Got: %h", rs1_data);
        end else begin
            $display("PASS: r3 correctly reset to 0");
        end
        
        #10;
        $finish;
    end
endmodule