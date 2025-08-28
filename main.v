module program_counter (
    input clk,
    input rst_n,
    input pcsel,
    input [31:0] pc_plus4,
    input [31:0] pc_target,
    output reg [31:0] pc_out
); 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out <= 32'b0;
        end 
        else if (pcsel) begin
            pc_out <= pc_target;
        end
        else begin 
            pc_out <= pc_plus4;
        end
    end
endmodule 


module alu(
    input [31:0] addr_rs1, addr_rs2, 
    input [31:0] imm_extend, pc
    input asel, bsel,
    input [2:0] alusel, 
    output reg [31:0] addr_rd
);
    wire [31:0] op1, op2;

    assign op1 = asel ? addr_rs1 : pc;
    assign op2 = bsel ? addr_rs2 : imm_extend; 

    always @(alusel) begin
        case(alusel)
            3'b000: addr_rd = op1 + op2;
            3'b001: addr_rd = op1 - op2;
            3'b010: addr_rd = op1 & op2;
            3'b011: addr_rd = op1 | op2;
            3'b100: addr_rd = op1 ^ op2;
            default: addr_rd = 0;
        endcase
    end
endmodule


module register_file (
    input clk, rst_n,
    input regwen,
    input [4:0] addrA, // read addr1
    input [4:0] addrB, // read addr2
    input [4:0] addrD, // write addr
    input [31:0] data_in,
    output reg [31:0] data_A,
    output reg [31:0] data_B
);
    reg [31:0] mem [0:31]; 

    // Read asynchronous
    assign data_A = mem[addrA];
    assign data_B = mem[addrB];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_A <= 32'b0;
            data_B <= 32'b0;
        end
        else if (regwen) begin
            mem[addrD] <= data_in;
        end
        else begin
            mem[addrD] <= 32'b0;
        end
    end
endmodule   

module imem #(
    parameter COL = 32,          // số bit mỗi ô nhớ (1 instruction = 32 bit)
    parameter ROW = 256          // số dòng (số instruction tối đa)
)(
    input  [31:0] pc,            // Program Counter
    output [31:0] instruction    // Instruction output
);

    // Bộ nhớ instruction
    reg [COL-1:0] memory [0:ROW-1];
    // Địa chỉ word-aligned: bỏ 2 bit thấp vì mỗi instruction = 4 byte
    wire [$clog2(ROW)-1:0] rom_addr = pc[31:2];
    // Load chương trình từ file (hex hoặc bin)
    initial begin
        // Ví dụ dùng file .hex (mỗi dòng 1 instruction 32-bit)
        $readmemb("test.txt", memory);
    end
    // Đọc combinational
    assign instruction = memory[rom_addr];
endmodule

module branch (
    // input brun,
    input [31:0] data_A,
    input [31:0] data_B,
    output breq,
    output brlt
);
    always @(data_A, data_B) begin
        breq = (dataA == dataB);
        brlt = (dataA < data_B);
    end
endmodule 

// Cần xem lại
module data_memory (
    input clk, rst_n,
    input memw,
    input [31:0] address,
    input [31:0] data_write,
    output reg [31:0] data_read
);
    reg [31:0] mem [0:31];

    assign data_read = mem[address];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_read <= 32'b0;
        end
        else if (memw) begin
            mem[address] <= data_write;
        end
    end
endmodule 


module decode(
    input  [31:0] instr,
    output reg [4:0]  rs1,
    output reg [4:0]  rs2,
    output reg [4:0]  rd,
    output reg [2:0]  funct3,
    output reg [6:0]  funct7,
    output reg [31:0] imm_extend
);

    wire [6:0] opcode;
    assign opcode = instr[6:0];

    always @(opcode) begin
        // default
        rs1    = 5'b0;
        rs2    = 5'b0;
        rd     = 5'b0;
        funct3 = 3'b0;
        funct7 = 7'b0;
        imm_extend    = 32'b0;

        case (opcode)
            // R-type: rd, rs1, rs2, funct3, funct7
            7'b0110011: begin
                rd     = instr[11:7];
                funct3 = instr[14:12];
                rs1    = instr[19:15];
                rs2    = instr[24:20];
                funct7 = instr[31:25];
                imm_extend    = 32'b0; // không có imm
            end

            // I-type: rd, rs1, funct3, imm
            // (ADDI, ANDI, ORI, XORI, JALR, LOAD…)
            7'b0010011, // OP-IMM
            7'b0000011, // LOAD
            7'b1100111: // JALR
            begin
                rd     = instr[11:7];
                funct3 = instr[14:12];
                rs1    = instr[19:15];
                imm_extend    = {{20{instr[31]}}, instr[31:20]}; // sign-extend
            end

            // S-type: rs1, rs2, funct3, imm
            // (SW, SH, SB)
            7'b0100011: begin
                funct3 = instr[14:12];
                rs1    = instr[19:15];
                rs2    = instr[24:20];
                imm_extend    = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            // B-type: rs1, rs2, funct3, imm
            // (BEQ, BNE, BLT, BGE…)
            7'b1100011: begin
                funct3 = instr[14:12];
                rs1    = instr[19:15];
                rs2    = instr[24:20];
                imm_extend    = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            end

            // U-type
            7'b0110111, // LUI
            7'b0010111: // AUIPC
            begin
                rd  = instr[11:7];
                imm_extend = {instr[31:12], 12'b0};
            end

            // J-type: rd, imm
            // (JAL)
            7'b1101111: begin
                rd  = instr[11:7];
                imm_extend = {{12{instr[31]}}, instr[31],
                       instr[19:12], instr[20], instr[30:21], 1'b0};
            end
        endcase
    end
endmodule



module control_units( //need fix
    input [31:0] ins, 
    input breq, brlt,
    input iready,
    output wire pcsel, regwen, asel, bsel, memw, //brun,
    output wire [1:0] wbsel,
    output wire [2:0] alusel
);
    wire [6:0] opcode; 
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode = iready ? ins[6:0] : 7'b0;
    assign funct3 = ins[14:12];
    assign funct7 = ins[31:25];

    reg [9:0] control_signals;
    assign {pcselm, regwen, asel, bsel, alusel, memw, wbsel} = control_signals;

    always @(opcode, funct3, funct7) begin
        case(opcode)
            7'b0110011: begin
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0000000)
                            control_signals = 10'b0_1_1_1_000_0_01;  // add
                        else 
                            control_signals = 10'b0_1_1_1_000_0_01;  // sub
                    end
                    3'b111: control_signals = 10'b0_1_1_1_000_0_01;  // and
                    3'b110: control_signals = 10'b0_1_1_1_000_0_01;  // or
                    3'b100: control_signals = 10'b0_1_1_1_000_0_01;  // xor
                endcase
            end
            7'b0010011: control_signals = 10'b0_1_1_0_000_0_01;  // addi
            7'b0000011: control_signals = 10'b0_1_1_0_000_0_00;  // lw
            7'b1100111: control_signals = 10'b0_1_1_0_000_0_11;  // jalr
            7'b0100011: control_signals = 10'b0_1_1_0_000_0_xx;   // sw
            7'b1100011: begin 
                case(funct3)
                    3'b000: control_signals = {breq, 1'b0, 1'b0, 1'b0, 3'b000, 1'b0, 2'b00};  // beq
                    3'b001: control_signals = {~breq, 1'b0, 1'b0, 1'b0, 3'b000, 1'b0, 2'b00}; // bne
                    3'b100: control_signals = {brlt, 1'b0, 1'b0, 1'b0, 3'b000, 1'b0, 2'b00};  // blt
                    3'b101: control_signals = {~brlt, 1'b0, 1'b0, 1'b0, 3'b000, 1'b0, 2'b00}; // bge           
                endcase
            end
            7'b1101111: control_signals = 10'b1_1_0_0_000_0_11; // jal
            default: control_signals = 10'b0_0_0_0_000_0_00;
        endcase
    end


    // always @(opcode, funct3, funct7) begin
    //     case(opcode)
    //         7'b0110011: begin
    //             case (funct3)
    //                 3'b000: begin
    //                     if (funct7 == 7'b0000000)
    //                         begin pcsel = 0; regwen = 1; asel = 1; bsel = 1; alusel = 3'b000; memw = 0; wbsel = 2'b01; end  // add
    //                     else 
    //                         begin pcsel = 0; regwen = 1; asel = 1; bsel = 1; alusel = 3'b001; memw = 0; wbsel = 2'b01; end  // sub
    //                 end
    //                 3'b111: begin pcsel = 0; regwen = 1; asel = 1; bsel = 1; alusel = 3'b010; memw = 0; wbsel = 2'b01; end  // and
    //                 3'b110: begin pcsel = 0; regwen = 1; asel = 1; bsel = 1; alusel = 3'b011; memw = 0; wbsel = 2'b01; end  // or
    //                 3'b100: begin pcsel = 0; regwen = 1; asel = 1; bsel = 1; alusel = 3'b100; memw = 0; wbsel = 2'b01; end  // xor
    //             endcase
    //         end
    //         7'b0010011: begin pcsel = 0; regwen = 1; asel = 1; bsel = 0; alusel = 3'b000; memw = 0; wbsel = 2'b01; end  // addi
    //         7'b0000011: begin pcsel = 0; regwen = 1; asel = 1; bsel = 0; alusel = 3'b000; memw = 0; wbsel = 2'b00; end  // lw
    //         7'b1100111: begin pcsel = 1; regwen = 1; asel = 1; bsel = 0; alusel = 3'b000; memw = 0; wbsel = 2'b11; end  // jalr
    //         7'b0100011: begin pcsel = 0; regwen = 0; asel = 1; bsel = 0; alusel = 3'b000; memw = 1; end                 // sw
    //         7'b1100011: begin 
    //             case(funct3)
    //                 3'b000: begin pcsel = breq; regwen = 0; brun = 0; asel = 0; bsel = 0; alusel = 3'b000; memw = 0; end  // beq
    //                 3'b001: begin pcsel = ~breq; regwen = 0; brun = 0; asel = 0; bsel = 0; alusel = 3'b000; memw = 0; end // bne
    //                 3'b100: begin pcsel = brlt; regwen = 0; brun = 0; asel = 0; bsel = 0; alusel = 3'b000; memw = 0; end  // blt
    //                 3'b101: begin pcsel = ~brlt; regwen = 0; brun = 0; asel = 0; bsel = 0; alusel = 3'b000; memw = 0; end // bge
    //                 default: 
    //             endcase
    //         end
    //         7'b1101111: begin pcsel = 1; regwen = 1; asel = 0; bsel = 0; alusel = 3'b000; memw = 0; wbsel = 2'b11; end   // jal
    //         default: begin pcsel = 0; regwen = 1; asel = 1; bsel = 1; alusel = 3'b000; memw = 0; wbsel = 2'b01; end //R type
    //     endcase
    // end

endmodule

