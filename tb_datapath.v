`timescale 1ns/1ps

module tb_datapath;
    reg clk;
    reg rst_n;
    wire [31:0] pc_out;
    wire [31:0] ALU_result;


    // DUT
    datapath dut (
        .clk(clk),
        .rst_n(rst_n),
        .pc_out(pc_out),
        .ALU_result(ALU_result)
    );

    // Clock: period 10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #10;
        rst_n = 1;
    end

    always @(posedge clk) begin
    $display("time=%0t pc=%08h pcsel=%b immsel=%03b regwen=%b brun=%b asel=%b bsel=%b alusel=%03b memw=%b wbsel=%02b",
             $time,
             tb_datapath.dut.pc_out,
             tb_datapath.dut.control_unit_inst.pcsel,
             tb_datapath.dut.control_unit_inst.immsel,
             tb_datapath.dut.control_unit_inst.regwen,
             tb_datapath.dut.control_unit_inst.brun,
             tb_datapath.dut.control_unit_inst.asel,
             tb_datapath.dut.control_unit_inst.bsel,
             tb_datapath.dut.control_unit_inst.alusel,
             tb_datapath.dut.control_unit_inst.memrw,
             tb_datapath.dut.control_unit_inst.wbsel
    );
end

    initial begin
        #200;
        $display("Simulation finished.");
        $finish;
    end
endmodule
