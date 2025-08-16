`timescale 1ns / 1ps

module axi_slave_tb;

// --- Signals ---
reg clk;
reg rst_n;

// AXI master signals (driven by testbench)
reg [31:0] awaddr;
reg awvalid;
reg [31:0] wdata;
reg [3:0] wstrb;
reg wvalid;
wire awready;
wire wready;
wire bvalid;
wire [1:0] bresp;

reg [31:0] araddr;
reg arvalid;
wire arready;
wire [31:0] rdata;
wire [1:0] rresp;
wire rvalid;
reg rready;

// --- Instantiate the slave ---
axi_slave u_axi_slave (
    .clk(clk),
    .rst_n(rst_n),
    .awaddr(awaddr),
    .awvalid(awvalid),
    .awready(awready),
    .wdata(wdata),
    .wstrb(wstrb),
    .wvalid(wvalid),
    .wready(wready),
    .bresp(bresp),
    .bvalid(bvalid),
    .bready(bready),
    .araddr(araddr),
    .arvalid(arvalid),
    .arready(arready),
    .rdata(rdata),
    .rresp(rresp),
    .rvalid(rvalid),
    .rready(rready)
);

// --- Clock Generation ---
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10 ns period
end

// --- Dump for GTKWave ---
initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0, axi_slave_tb);
end

// --- Test Sequence ---
initial begin
    // 1. Initial Reset
    awvalid = 1'b0; wvalid = 1'b0; arvalid = 1'b0; rready = 1'b0;
    rst_n = 1'b0;
    #20;
    rst_n = 1'b1;
    #10;

    // 2. Write to register 0
    $display("Time %0t: Starting write transaction to reg 0.", $time);
    awaddr = 32'h00;
    wdata = 32'hdeadbeef;
    awvalid = 1'b1;
    wvalid = 1'b1;
    @(posedge clk);
    wait (awready && wready); // Wait for slave handshake
    awvalid = 1'b0;
    wvalid = 1'b0;
    wait (bvalid); // Wait for write response
    $display("Time %0t: Write transaction complete. Got response %b.", $time, bresp);
    #10;

    // 3. Read from register 0
    $display("Time %0t: Starting read transaction from reg 0.", $time);
    araddr = 32'h00;
    arvalid = 1'b1;
    @(posedge clk);
    wait (arready); // Wait for slave handshake
    arvalid = 1'b0;
    wait (rvalid); // Wait for read data
    if (rdata == 32'hdeadbeef) begin
        $display("Time %0t: Read transaction successful! Got data: %h", $time, rdata);
    end else begin
        $display("Time %0t: Read transaction failed! Got data: %h, expected: %h", $time, rdata, 32'hdeadbeef);
    end
    rready = 1'b1;
    @(posedge clk);
    rready = 1'b0;

    #20;
    $finish;
end
endmodule