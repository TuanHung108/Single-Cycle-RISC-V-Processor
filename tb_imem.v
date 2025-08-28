`timescale 1ns/1ps

module tb_imem;

    reg [31:0] pc;
    reg iready;
    wire [31:0] ins;

    // Instantiate module
    imem uut (
        .pc(pc),
        .iready(iready),
        .ins(ins)
    );

    initial begin
        // Init
        pc = 0;
        iready = 0;

        // Bật iready, đọc instruction tại PC=0
        #5 iready = 1;
        #5 $display("PC=0, ins=%h", ins);

        // PC = 4 (next instruction)
        #10 pc = 4;
        #5 $display("PC=4, ins=%h", ins);

        // PC = 8
        #10 pc = 8;
        #5 $display("PC=8, ins=%h", ins);

        // Tắt iready
        #10 iready = 0;
        #5 $display("PC=8, iready=0, ins=%h (expect 0)", ins);

        #20 $finish;
    end

endmodule
