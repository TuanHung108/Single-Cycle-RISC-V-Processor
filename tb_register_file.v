`timescale 1ns/1ps

module tb_register_file();

    reg clk, rst_n;
    reg regwen;
    reg [31:0] ins;
    reg [31:0] data_in;
    reg [31:0] pc;
    reg [2:0] immsel;
    reg asel, bsel;
    reg [2:0] alusel;
    wire [31:0] alu_res;
    wire breq, brlt;
    wire [31:0] data_B;

    // DUT
    register_file uut (
        .clk(clk), .rst_n(rst_n),
        .regwen(regwen),
        .ins(ins),
        .data_in(data_in),
        .pc(pc),
        .immsel(immsel),
        .asel(asel), .bsel(bsel),
        .alusel(alusel),
        .alu_res(alu_res),
        .breq(breq), .brlt(brlt),
        .data_B(data_B)
    );

    // Clock
    always #5 clk = ~clk;

    initial begin
        $display("=== TESTBENCH START ===");
        clk = 0; rst_n = 0;
        regwen = 0;
        ins = 0; data_in = 0;
        pc = 32'h10;
        immsel = 3'b000;
        asel = 0; bsel = 0;
        alusel = 3'b000;

        // Reset
        #10 rst_n = 1;
        #10;

        // Test ghi dữ liệu vào x5 = 0x1234
        ins = {25'b0, 5'd5, 2'b00}; // rd = 5
        data_in = 32'h1234;
        regwen = 1;
        #10 clk = 1; #10 clk = 0;
        regwen = 0;

        // Đọc lại rs1 = x5
        ins = {12'b0, 5'd5, 3'b000, 5'd0, 7'b0}; // rs1 = 5
        #10;
        $display("Read x5 = %h (expect 1234)", uut.mem[5]);

        // Thử ALU add (rs1=5, imm=10)
        ins = {20'b0, 12'd10}; // immediate = 10
        asel = 1; bsel = 0; // chọn data_A, imm
        immsel = 3'b001;     // I-type
        alusel = 3'b000;     // add
        #10;
        $display("ALU add result = %h (expect 123E)", alu_res);

        // Thử ALU sub (x5 - 10)
        alusel = 3'b001;
        #10;
        $display("ALU sub result = %h", alu_res);

        // Thử branch signals (x5 == x5)
        ins = {7'b0, 5'd5, 5'd5, 15'b0}; // rs1=5, rs2=5
        #10;
        $display("breq=%b (expect 1), brlt=%b", breq, brlt);

        // Thử branch signals (x5 < x6)
        uut.mem[6] = 32'h9999;
        ins = {7'b0, 5'd5, 5'd6, 15'b0}; // rs1=5, rs2=6
        #10;
        $display("breq=%b, brlt=%b (expect 1)", breq, brlt);

        $display("=== TESTBENCH END ===");
        $stop;
    end

endmodule
