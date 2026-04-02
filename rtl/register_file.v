// Register File for multi-cycle 8-bit RISC-V inspired CPU
// 8 registers (r0-r7), where r0 is hardwired to 0
// 2 read ports, 1 write port

module register_file (
    input wire clk,                // Clock signal
    input wire reset,              // Active high reset
    input wire [2:0] rs1_addr,     // Address for read port 1
    input wire [2:0] rs2_addr,     // Address for read port 2
    input wire [2:0] rd_addr,      // Address for write port
    input wire [7:0] rd_data,      // Data to write
    input wire wr_en,              // Write enable signal
    output wire [7:0] rs1_data,    // Data from read port 1
    output wire [7:0] rs2_data     // Data from read port 2
);

    // Register file (8 registers, 8 bits each)
    reg [7:0] registers [7:0];
    
    // Read ports (combinational)
    // Register 0 is hardwired to 0
    assign rs1_data = (rs1_addr == 3'b000) ? 8'h00 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 3'b000) ? 8'h00 : registers[rs2_addr];
    
    // Write port (sequential)
    // In multi-cycle CPU, write occurs during Writeback stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all registers except r0 (which is hardwired)
            registers[1] <= 8'h00;
            registers[2] <= 8'h00;
            registers[3] <= 8'h00;
            registers[4] <= 8'h00;
            registers[5] <= 8'h00;
            registers[6] <= 8'h00;
            registers[7] <= 8'h00;
        end else if (wr_en && (rd_addr != 3'b000)) begin
            // Write to the register if write is enabled and not r0
            registers[rd_addr] <= rd_data;
        end
    end

endmodule