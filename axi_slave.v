module axi_slave (
    input wire clk,
    input wire rst_n,

    // AXI4-Lite Write Address Channel
    input wire [31:0] awaddr,
    input wire awvalid,
    output reg awready,

    // AXI4-Lite Write Data Channel
    input wire [31:0] wdata,
    input wire [3:0] wstrb,
    input wire wvalid,
    output reg wready,

    // AXI4-Lite Write Response Channel
    output reg [1:0] bresp,
    output reg bvalid,
    input wire bready,

    // AXI4-Lite Read Address Channel
    input wire [31:0] araddr,
    input wire arvalid,
    output reg arready,

    // AXI4-Lite Read Data Channel
    output wire [31:0] rdata,
    output reg [1:0] rresp,
    output reg rvalid,
    input wire rready
);

// State machine for write transaction
localparam [1:0] IDLE = 2'b00, WRITE = 2'b01, WRITE_RESP = 2'b10;
reg [1:0] write_state;

// Internal wires for connecting to register_file
wire [2:0] write_reg_addr;
wire [2:0] read_reg_addr;

// Instantiate the register file
register_file u_register_file (
    .clk(clk),
    .rst_n(rst_n),
    .read_addr(read_reg_addr),
    .read_data(rdata),
    .write_addr(write_reg_addr),
    .write_data(wdata),
    .write_en(wvalid && wready) // Write enable signal
);

// --- WRITE CHANNEL LOGIC ---
assign write_reg_addr = awaddr[4:2]; // Use bits 4:2 for 8 registers

// FSM for write transactions
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        write_state <= IDLE;
        awready <= 1'b0;
        wready <= 1'b0;
        bvalid <= 1'b0;
        bresp <= 2'b00;
    end else begin
        case (write_state)
            IDLE: begin
                awready <= 1'b1; // Always ready to accept a new address
                wready <= 1'b1;  // Always ready to accept new data
                if (awvalid && wvalid) begin // Handshake complete
                    write_state <= WRITE;
                end
            end
            WRITE: begin
                awready <= 1'b0;
                wready <= 1'b0;
                bvalid <= 1'b1; // Assert response valid
                bresp <= 2'b00; // OKAY response
                write_state <= WRITE_RESP;
            end
            WRITE_RESP: begin
                if (bready) begin // Master has accepted the response
                    bvalid <= 1'b0;
                    write_state <= IDLE;
                end
            end
        endcase
    end
end

// --- READ CHANNEL LOGIC ---
assign read_reg_addr = araddr[4:2];

// Read logic uses combinational and simple sequential logic
reg [1:0] read_state;
localparam [1:0] R_IDLE = 2'b00, R_READ = 2'b01;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        read_state <= R_IDLE;
        arready <= 1'b0;
        rvalid <= 1'b0;
        rresp <= 2'b00;
    end else begin
        case (read_state)
            R_IDLE: begin
                arready <= 1'b1; // Ready for a read address
                if (arvalid) begin
                    read_state <= R_READ;
                end
            end
            R_READ: begin
                arready <= 1'b0;
                rvalid <= 1'b1; // Assert read data is valid
                rresp <= 2'b00;
                if (rready) begin // Master has accepted data
                    rvalid <= 1'b0;
                    read_state <= R_IDLE;
                end
            end
        endcase
    end
end
endmodule