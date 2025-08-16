module register_file (
    input wire clk,
    input wire rst_n,

    // Read Interface
    input wire [2:0] read_addr,
    output reg [31:0] read_data,

    // Write Interface
    input wire [2:0] write_addr,
    input wire [31:0] write_data,
    input wire write_en
);

// 8 registers, each 32 bits wide
reg [31:0] registers [7:0];

// Read Logic
always @(posedge clk) begin
    if (~rst_n) begin
        read_data <= 32'b0;
    end else begin
        read_data <= registers[read_addr];
    end
end

// Write Logic
always @(posedge clk) begin
    if (write_en) begin
        registers[write_addr] <= write_data;
    end
end
endmodule