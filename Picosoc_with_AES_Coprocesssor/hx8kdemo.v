/* Updated for Spartan 6 FPGA */

module hx8kdemo (
    input clk,

    output ser_tx,
    input ser_rx,

    output [7:0] leds,

    output flash_csb,
    output flash_clk,
    inout  flash_io0,
    inout  flash_io1,
    inout  flash_io2,
    inout  flash_io3
);

    reg [5:0] reset_cnt = 0;
    wire resetn = &reset_cnt;

    always @(posedge clk) begin
        reset_cnt <= reset_cnt + !resetn;
    end

    wire iomem_valid;
    reg  iomem_ready;
    wire [3:0] iomem_wstrb;
    wire [31:0] iomem_addr;
    wire [31:0] iomem_wdata;
    reg  [31:0] iomem_rdata;

    reg [31:0] gpio;
    assign leds = 8'b01011101;


    always @(posedge clk) begin
        if (!resetn) begin
            gpio <= 0;
        end else begin
            iomem_ready <= 0;
            if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h03) begin
                iomem_ready <= 1;
                iomem_rdata <= gpio;
                if (iomem_wstrb[0]) gpio[7:0] <= iomem_wdata[7:0];
                if (iomem_wstrb[1]) gpio[15:8] <= iomem_wdata[15:8];
                if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
                if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
            end
        end
    end

    // Instantiate picosoc module
    picosoc soc (
        .clk          (clk),
        .resetn       (resetn),
        .ser_tx       (ser_tx),
        .ser_rx       (ser_rx),
        .flash_csb    (flash_csb),
        .flash_clk    (flash_clk),
        .iomem_valid  (iomem_valid),
        .iomem_ready  (iomem_ready),
        .iomem_wstrb  (iomem_wstrb),
        .iomem_addr   (iomem_addr),
        .iomem_wdata  (iomem_wdata),
        .iomem_rdata  (iomem_rdata)
    );

endmodule