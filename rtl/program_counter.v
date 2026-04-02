// Program Counter for multi-cycle 8-bit RISC-V inspired CPU
// Only updates when pc_load is asserted by the control unit

module program_counter (
    input wire clk,                  // Clock signal
    input wire reset,                // Active high reset
    input wire pc_load,              // Control signal to load new address
    input wire [7:0] pc_load_val,    // New address to load
    output reg [7:0] pc_out          // Current PC value
);

    // Program counter update logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 8'h00;         // Reset PC to 0
        end else if (pc_load) begin
            pc_out <= pc_load_val;   // Update PC when load is asserted
        end
        // In multi-cycle design, PC only changes when pc_load is asserted
        // No automatic increment every cycle
    end

endmodule