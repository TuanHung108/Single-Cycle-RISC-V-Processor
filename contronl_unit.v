module control_unit( //need fix
    input [31:0] ins, 
    input breq, brlt,
    input iready,
    output reg pcsel, regwen, asel, bsel, memw, //brun
    output reg [1:0] wbsel,
    output reg [2:0] alusel,
    output reg [2:0] immsel
);
    wire [6:0] opcode; 
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode = iready ? ins[6:0] : 7'b0;
    assign funct3 = ins[14:12];
    assign funct7 = ins[31:25];
    always @(opcode, funct3, funct7) begin
        pcsel  = 0;
        immsel = 3'b000;
        regwen = 0;
        asel   = 1;
        bsel   = 1;
        alusel = 3'b000;
        memw   = 0;
        wbsel  = 2'b01;

        case(opcode)
            7'b0110011: begin
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0000000)
                            begin pcsel = 0; regwen = 1; asel = 1; bsel = 1; alusel = 3'b000; memw = 0; wbsel = 2'b01; end  // add
                        else 
                            begin pcsel = 0; regwen = 1; asel = 1; bsel = 1; alusel = 3'b001; memw = 0; wbsel = 2'b01; end  // sub
                    end
                    3'b111: begin pcsel = 0; regwen = 1; asel = 1; bsel = 1; alusel = 3'b010; memw = 0; wbsel = 2'b01; end  // and
                    3'b110: begin pcsel = 0; regwen = 1; asel = 1; bsel = 1; alusel = 3'b011; memw = 0; wbsel = 2'b01; end  // or
                    3'b100: begin pcsel = 0; regwen = 1; asel = 1; bsel = 1; alusel = 3'b100; memw = 0; wbsel = 2'b01; end  // xor
                endcase
            end
            7'b0010011: begin pcsel = 0; immsel = 3'b001; regwen = 1; asel = 1; bsel = 0; alusel = 3'b000; memw = 0; wbsel = 2'b01; end  // addi
            7'b0000011: begin pcsel = 0; immsel = 3'b001; regwen = 1; asel = 1; bsel = 0; alusel = 3'b000; memw = 0; wbsel = 2'b00; end  // lw
            7'b1100111: begin pcsel = 1; immsel = 3'b001; regwen = 1; asel = 1; bsel = 0; alusel = 3'b000; memw = 0; wbsel = 2'b11; end  // jalr
            7'b0100011: begin pcsel = 0; immsel = 3'b010; regwen = 0; asel = 1; bsel = 0; alusel = 3'b000; memw = 1; end                 // sw
            7'b1100011: begin 
                case(funct3)
                    3'b000: begin pcsel = breq; immsel = 3'b011; regwen = 0; /*brun = 0;*/ asel = 0; bsel = 0; alusel = 3'b000; memw = 0; end  // beq
                    3'b001: begin pcsel = ~breq; immsel = 3'b011; regwen = 0; /*brun = 0;*/ asel = 0; bsel = 0; alusel = 3'b000; memw = 0; end // bne
                    3'b100: begin pcsel = brlt; immsel = 3'b011; regwen = 0; /*brun = 0;*/ asel = 0; bsel = 0; alusel = 3'b000; memw = 0; end  // blt
                    3'b101: begin pcsel = ~brlt; immsel = 3'b011; regwen = 0; /*brun = 0;*/ asel = 0; bsel = 0; alusel = 3'b000; memw = 0; end // bge
                    default: begin pcsel = 0; immsel = 3'b000; regwen = 1; asel = 1; bsel = 1; alusel = 3'b000; memw = 0; wbsel = 2'b01; end
                endcase
            end
            7'b1101111: begin pcsel = 1; immsel = 3'b100; regwen = 1; asel = 0; bsel = 0; alusel = 3'b000; memw = 0; wbsel = 2'b11; end   // jal
            default: begin pcsel = 0; immsel = 3'b000; regwen = 1; asel = 1; bsel = 1; alusel = 3'b000; memw = 0; wbsel = 2'b01; end //R type
        endcase
    end
endmodule
