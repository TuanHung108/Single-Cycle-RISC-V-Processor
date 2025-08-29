module control_unit(
    input  [31:0] ins,
    input         breq, brlt,
    output        pcsel, regwen, asel, bsel, memw, brun,
    output [1:0]  wbsel,
    output [2:0]  alusel,
    output [2:0]  immsel
);
    // PCSel_ImmSel_RegWEn_brun_ASel_BSel_ALUSel_MemW_WBSel
    wire [6:0] opcode = ins[6:0];
    wire [2:0] funct3 = ins[14:12];
    wire [6:0] funct7 = ins[31:25];

    reg [13:0] control;
    assign {pcsel, immsel, regwen, brun, asel, bsel, alusel, memrw, wbsel} = control;

    always @(funct3, funct7, opcode) begin
        control = 14'b0_000_0_0_0_0_000_0_00;
        case (opcode)
            7'b0110011: begin
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0000000)
                            control = 14'b0_000_1_0_0_0_000_0_01; // add
                        else
                            control = 14'b0_000_1_0_0_0_001_0_01; // sub
                    end
                    3'b111: control = 14'b0_000_1_0_0_0_010_0_01; // and
                    3'b110: control = 14'b0_000_1_0_0_0_011_0_01; // or
                    3'b100: control = 14'b0_000_1_0_0_0_100_0_01; // xor
                    default:control = 14'b0_000_1_0_0_0_000_0_01;
                endcase
            end

            7'b0010011: control = 14'b0_001_1_0_0_1_000_0_01; // addi
            7'b0000011: control = 14'b0_001_1_0_0_1_000_0_00; // lw
            7'b1100111: control = 14'b1_001_1_0_0_1_000_0_11; // jalr
            7'b0100011: control = 14'b0_010_0_0_0_1_000_1_00; // sw

            7'b1100011: begin
                case (funct3)
                    3'b000: control =  breq  ? 14'b1_011_0_0_1_1_000_0_00
                                             : 14'b0_011_0_0_1_1_000_0_00; // beq
                    3'b001: control = ~breq  ? 14'b1_011_0_0_1_1_000_0_00
                                             : 14'b0_011_0_0_1_1_000_0_00; // bne
                    3'b100: control =  brlt  ? 14'b1_011_0_0_1_1_000_0_00
                                             : 14'b0_011_0_0_1_1_000_0_00; // blt
                    3'b101: control = ~brlt  ? 14'b1_011_0_0_1_1_000_0_00
                                             : 14'b0_011_0_0_1_1_000_0_00; // bge
                    default:control = 14'b0_000_0_0_0_0_000_0_00;
                endcase
            end

            7'b1101111: control = 14'b1_100_1_0_1_1_000_0_11; // jal
            default:    control = 14'b0_000_0_0_0_0_000_0_00;
        endcase
    end
endmodule
