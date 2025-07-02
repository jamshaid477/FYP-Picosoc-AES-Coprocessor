/* Updated SPRAM module for Spartan 6 */

module spartan6_spram (
    input clk,
    input [3:0] wen,
    input [13:0] addr,
    input [31:0] wdata,
    output reg [31:0] rdata
);

    reg [31:0] memory [0:16383];

    always @(posedge clk) begin
        if (wen[0]) memory[addr][7:0] <= wdata[7:0];
        if (wen[1]) memory[addr][15:8] <= wdata[15:8];
        if (wen[2]) memory[addr][23:16] <= wdata[23:16];
        if (wen[3]) memory[addr][31:24] <= wdata[31:24];
        rdata <= memory[addr];
    end

endmodule