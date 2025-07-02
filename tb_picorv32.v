`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:55:42 06/20/2025 
// Design Name: 
// Module Name:    tb_picorv32 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module aes_coprocessor_tb;

    // Inputs
    reg clk;
    reg resetn;
    reg pcpi_valid;
    reg [31:0] pcpi_insn;
    reg [31:0] pcpi_rs1;
    reg [31:0] pcpi_rs2;

    // Memory model
    always @(posedge clk) begin
        if (mem_valid && mem_ready) begin
            if (mem_wstrb[0]) memory[mem_addr[11:2]] = {memory[mem_addr[11:2]][31:8], mem_wdata[7:0]};
            if (mem_wstrb[1]) memory[mem_addr[11:2]] = {memory[mem_addr[11:2]][31:16], mem_wdata[15:8], memory[mem_addr[11:2]][7:0]};
            if (mem_wstrb[2]) memory[mem_addr[11:2]] = {memory[mem_addr[11:2]][31:24], mem_wdata[23:16], memory[mem_addr[11:2]][15:0]};
            if (mem_wstrb[3]) memory[mem_addr[11:2]] = mem_wdata;
        end
    end

    assign mem_rdata = mem_valid ? memory[mem_addr[11:2]] : 32'b0;
    assign mem_ready = 1;  // Always ready

    // Memory interface
    assign mem_valid = dut.mem_valid;
    assign mem_instr = dut.mem_instr;
    assign mem_addr = dut.mem_addr;
    assign mem_wdata = dut.mem_wdata;
    assign mem_wstrb = dut.mem_wstrb;
    assign dut.mem_rdata = mem_rdata;
    assign dut.mem_ready = mem_ready;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz clock
    end

    // Reset sequence
    initial begin
        resetn = 0;
        #20;
        resetn = 1;
    end

    // Waveform dump
    initial begin
        $dumpfile("tb_picorv32.vcd");
        $dumpvars(0, tb_picorv32);
    end

    // Test procedure
    initial begin
        // Initialize test data
        test_data = 32'h12345678;
        test_key = 32'hAABBCCDD;
        expected_results[0] = test_data ^ 32'h000000e5;  // aes32dsi result
        expected_results[1] = test_data ^ 32'h00e0cd00;  // aes32dsmi result
        expected_results[2] = test_data ^ 32'hc9000000;  // aes32esi result
        expected_results[3] = test_data ^ 32'hb6aa0000;  // aes32esmi result

        // Initialize memory
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] = 32'b0;
        end

        // Test program
        // Load test data and key
        memory[0] = 32'h00000013;  // addi x1, x0, 0     (start address)
        memory[1] = 32'h00000017;  // auipc x2, 0        (data address)
        memory[2] = 32'h00000097;  // auipc x3, 0        (result address)
        memory[3] = 32'h000000b7;  // auipc x4, 0        (key address)
        
        // Store test data and key
        memory[1024/4] = test_data;     // Test data
        memory[1024/4 + 1] = test_key;  // Test key

        // Test AES32DSI (Decryption SubBytes Inverse)
        memory[4] = 32'h00052033;  // aes32dsi x5, x2, x4 (bs=0)
        memory[5] = 32'h00000023;  // sw x5, 0(x3)       (store result)
        
        // Test AES32DSMI (Decryption ShiftRows MixColumns Inverse)
        memory[6] = 32'h00156033;  // aes32dsmi x6, x2, x4 (bs=1)
        memory[7] = 32'h00100023;  // sw x6, 4(x3)       (store result)
        
        // Test AES32ESI (Encryption SubBytes Inverse)
        memory[8] = 32'h0025a033;  // aes32esi x7, x2, x4 (bs=2)
        memory[9] = 32'h00200023;  // sw x7, 8(x3)       (store result)
        
        // Test AES32ESMI (Encryption ShiftRows MixColumns Inverse)
        memory[10] = 32'h0035e033;  // aes32esmi x8, x2, x4 (bs=3)
        memory[11] = 32'h00300023;  // sw x8, 12(x3)      (store result)
        
        // Halt
        memory[12] = 32'h00000013;  // addi x9, x0, 0     (halt)
        memory[13] = 32'h00000000;  // nop

        // Wait for program to finish
        #1000;
        
        // Verify results
        $display("\nVerification Results:");
        $display("Test Data: %h", test_data);
        $display("Test Key: %h", test_key);
        
        // Check results for each AES instruction
        for (i = 0; i < 4; i = i + 1) begin
            $display("\nVerifying AES instruction %d:", i);
            $display("  Stored Result: %h", memory[1024/4 + 2 + i]);
            $display("  Expected Result: %h", expected_results[i]);
            
            if (memory[1024/4 + 2 + i] == expected_results[i]) begin
                $display("  Status: PASSED");
            end else begin
                $display("  Status: FAILED");
                $display("  Difference: %h", memory[1024/4 + 2 + i] ^ expected_results[i]);
            end
        end

        // Finish simulation
        $display("\nSimulation completed");
        $finish;
    end

    // Memory model
    reg [31:0] memory [1024];
    reg [31:0] test_data;
    reg [31:0] test_key;
    reg [31:0] expected_results [4];
    integer i;

    always @(posedge clk) begin
        if (pcpi_valid && pcpi_ready) begin
            if (pcpi_wr) begin
                if (pcpi_insn[14:12] == 3'b000) memory[pcpi_rs1[11:2]] = pcpi_rd;
                if (pcpi_insn[14:12] == 3'b001) memory[pcpi_rs1[11:2]] = {memory[pcpi_rs1[11:2]][31:8], pcpi_rd[7:0]};
                if (pcpi_insn[14:12] == 3'b010) memory[pcpi_rs1[11:2]] = {memory[pcpi_rs1[11:2]][31:16], pcpi_rd[15:8], memory[pcpi_rs1[11:2]][7:0]};
                if (pcpi_insn[14:12] == 3'b011) memory[pcpi_rs1[11:2]] = {memory[pcpi_rs1[11:2]][31:24], pcpi_rd[23:16], memory[pcpi_rs1[11:2]][15:0]};
                if (pcpi_insn[14:12] == 3'b100) memory[pcpi_rs1[11:2]] = pcpi_rd;
            end
        end
    end

    assign pcpi_rd = pcpi_valid ? memory[pcpi_rs1[11:2]] : 32'b0;
    assign pcpi_ready = 1;  // Always ready

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz clock
    end

    // Reset sequence
    initial begin
        resetn = 0;
        #20;
        resetn = 1;
    end

    // Waveform dump
    initial begin
        $dumpfile("tb_picorv32.vcd");
        $dumpvars(0, tb_picorv32);
    end

    // Test procedure
    initial begin
        // Initialize test data
        test_data = 32'h12345678;
        test_key = 32'hAABBCCDD;
        expected_results[0] = test_data ^ 32'h000000e5;  // aes32dsi result
        expected_results[1] = test_data ^ 32'h00e0cd00;  // aes32dsmi result
        expected_results[2] = test_data ^ 32'hc9000000;  // aes32esi result
        expected_results[3] = test_data ^ 32'hb6aa0000;  // aes32esmi result

        // Initialize memory
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] = 32'b0;
        end

        // Test program
        // Load test data and key
        memory[0] = 32'h00000013;  // addi x1, x0, 0     (start address)
        memory[1] = 32'h00000017;  // auipc x2, 0        (data address)
        memory[2] = 32'h00000097;  // auipc x3, 0        (result address)
        memory[3] = 32'h000000b7;  // auipc x4, 0        (key address)
        
        // Store test data and key
        memory[1024/4] = test_data;     // Test data
        memory[1024/4 + 1] = test_key;  // Test key

        // Test AES32DSI (Decryption SubBytes Inverse)
        memory[4] = 32'h00052033;  // aes32dsi x5, x2, x4 (bs=0)
        memory[5] = 32'h00000023;  // sw x5, 0(x3)       (store result)
        
        // Test AES32DSMI (Decryption ShiftRows MixColumns Inverse)
        memory[6] = 32'h00156033;  // aes32dsmi x6, x2, x4 (bs=1)
        memory[7] = 32'h00100023;  // sw x6, 4(x3)       (store result)
        
        // Test AES32ESI (Encryption SubBytes Inverse)
        memory[8] = 32'h0025a033;  // aes32esi x7, x2, x4 (bs=2)
        memory[9] = 32'h00200023;  // sw x7, 8(x3)       (store result)
        
        // Test AES32ESMI (Encryption ShiftRows MixColumns Inverse)
        memory[10] = 32'h0035e033;  // aes32esmi x8, x2, x4 (bs=3)
        memory[11] = 32'h00300023;  // sw x8, 12(x3)      (store result)
        
        // Halt
        memory[12] = 32'h00000013;  // addi x9, x0, 0     (halt)
        memory[13] = 32'h00000000;  // nop

        // Wait for program to finish
        #1000;
        
        // Verify results
        $display("\nVerification Results:");
        $display("Test Data: %h", test_data);
        $display("Test Key: %h", test_key);
        
        // Check results for each AES instruction
        for (i = 0; i < 4; i = i + 1) begin
            $display("\nVerifying AES instruction %d:", i);
            $display("  Stored Result: %h", memory[1024/4 + 2 + i]);
            $display("  Expected Result: %h", expected_results[i]);
            
            if (memory[1024/4 + 2 + i] == expected_results[i]) begin
                $display("  Status: PASSED");
            end else begin
                $display("  Status: FAILED");
                $display("  Difference: %h", memory[1024/4 + 2 + i] ^ expected_results[i]);
            end
        end

        // Finish simulation
        $display("\nSimulation completed");
        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile("tb_picorv32.vcd");
        $dumpvars(0, tb_picorv32);
    end
endmodule
