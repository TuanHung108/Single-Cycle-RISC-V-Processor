`timescale 1ns/1ps

module tb_datapath;
    reg clk;
    reg rst_n;
    wire [31:0] pc_out;
    wire [31:0] ALU_result;

    // Internal signals tapping
    wire [31:0] writedata, dataadr;
    wire memwrite;

    // DUT
    datapath dut (
        .clk(clk),
        .rst_n(rst_n),
        .pc_out(pc_out),
        .ALU_result(ALU_result)
    );

    // expose internal signals
    assign writedata = dut.data_B;
    assign dataadr   = dut.ALUres;
    assign memwrite  = dut.memw;

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;   // 100MHz
    end

    // Reset
    initial begin
        rst_n = 0;
        #20;
        rst_n = 1;
    end

    // Monitor
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_datapath);
    end

    // Simulation runtime
    initial begin
        #2000;  // run 2000ns then stop
        $display("Timeout! End simulation.");
        $stop;
    end

    // Print PC and ALU
    always @(posedge clk) begin
        if (rst_n) begin
            $display("t=%0t  PC=%h  ALU=%h  memwrite=%b addr=%h data=%h",
                     $time, pc_out, ALU_result, memwrite, dataadr, writedata);
        end
    end

    // Check expected write
    always @(negedge clk) begin
        if (memwrite) begin
            if (dataadr == 32'd100 && writedata == 32'd25) begin
                $display("=== Simulation succeeded ===");
                $stop;
            end
        end
    end
endmodule
