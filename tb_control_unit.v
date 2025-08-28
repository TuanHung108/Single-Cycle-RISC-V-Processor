`timescale 1ns/1ps

module tb_control_unit();

    reg [31:0] ins;
    reg breq, brlt;
    reg iready;
    wire pcsel, regwen, asel, bsel, memw;
    wire [1:0] wbsel;
    wire [2:0] alusel, immsel;

    // DUT
    control_unit uut (
        .ins(ins), .breq(breq), .brlt(brlt), .iready(iready),
        .pcsel(pcsel), .regwen(regwen), .asel(asel), .bsel(bsel), .memw(memw),
        .wbsel(wbsel), .alusel(alusel), .immsel(immsel)
    );

    task show_ctrl;
        input [127:0] msg;
        begin
            $display("%s | pcsel=%b regwen=%b asel=%b bsel=%b alusel=%b memw=%b wbsel=%b immsel=%b",
                msg, pcsel, regwen, asel, bsel, alusel, memw, wbsel, immsel);
        end
    endtask

    initial begin
        $display("=== TESTBENCH CONTROL UNIT START ===");
        breq = 0; brlt = 0;
        iready = 1;

        // ADD: opcode=0110011 funct3=000 funct7=0000000
        ins = 32'b0000000_00010_00001_000_00011_0110011; #10;
        show_ctrl("R-type ADD");

        // SUB: opcode=0110011 funct3=000 funct7=0100000
        ins = 32'b0100000_00010_00001_000_00011_0110011; #10;
        show_ctrl("R-type SUB");

        // AND: funct3=111
        ins = 32'b0000000_00010_00001_111_00011_0110011; #10;
        show_ctrl("R-type AND");

        // OR: funct3=110
        ins = 32'b0000000_00010_00001_110_00011_0110011; #10;
        show_ctrl("R-type OR");

        // XOR: funct3=100
        ins = 32'b0000000_00010_00001_100_00011_0110011; #10;
        show_ctrl("R-type XOR");

        // ADDI: opcode=0010011
        ins = 32'b000000000100_00001_000_00011_0010011; #10;
        show_ctrl("I-type ADDI");

        // LW: opcode=0000011
        ins = 32'b000000000100_00001_010_00011_0000011; #10;
        show_ctrl("I-type LW");

        // SW: opcode=0100011
        ins = 32'b0000000_00011_00001_010_00100_0100011; #10;
        show_ctrl("S-type SW");

        // BEQ: opcode=1100011 funct3=000
        breq = 1;
        ins = 32'b0000000_00011_00001_000_00100_1100011; #10;
        show_ctrl("B-type BEQ (taken)");

        // BNE: funct3=001
        breq = 0;
        ins = 32'b0000000_00011_00001_001_00100_1100011; #10;
        show_ctrl("B-type BNE");

        // BLT: funct3=100
        brlt = 1;
        ins = 32'b0000000_00011_00001_100_00100_1100011; #10;
        show_ctrl("B-type BLT");

        // JAL: opcode=1101111
        ins = 32'b000000000001_00000000_00000_1101111; #10;
        show_ctrl("J-type JAL");

        $display("=== TESTBENCH END ===");
        $stop;
    end

endmodule
