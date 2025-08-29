module register_file (
    input clk, rst_n,
    input regwen,
    input [31:0] ins,
    input [31:0] data_in,
    input [31:0] pc,
    input [2:0] immsel,
    input asel, bsel, 
    input brun,
    input [2:0] alusel, 
    output reg [31:0] alu_res,
    output breq, brlt,
    output [31:0] data_B
);
    reg [31:0] mem [0:31]; 

    wire [31:0] data_A, op1, op2;
    
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1)
                mem[i] <= 32'b0;
        end else if (regwen && (ins[11:7] != 0)) begin
            // ghi vào register khác x0
            mem[ins[11:7]] <= data_in;
        end
    end

    // Read asynchronous

    assign data_A = mem[ins[19:15]];
    assign data_B = mem[ins[24:20]];

    localparam  I_type = 3'b001,
                S_type = 3'b010,
                B_type = 3'b011,
                J_type = 3'b100,
                U_type = 3'b101;
    reg [31:0] imm_extend;

    always @(immsel, ins) begin
        imm_extend    = 32'b0;
        case (immsel)
            I_type: imm_extend = {{20{ins[31]}}, ins[31:20]};
            S_type: imm_extend = {{20{ins[31]}}, ins[31:25], ins[11:7]};
            B_type: imm_extend = {{19{ins[31]}}, ins[31], ins[7], ins[30:25], ins[11:8], 1'b0};
            J_type: imm_extend = {{11{ins[31]}}, ins[31], ins[19:12], ins[20], ins[30:21], 1'b0};
            U_type: imm_extend = {ins[31:12], 12'b0};
            default: imm_extend = 32'b0;
        endcase
    end


    assign op1 = asel ? pc : data_A;
    assign op2 = bsel ? imm_extend : data_B; 

    always @(alusel, op1, op2) begin
        alu_res = 0;
        case(alusel)
            3'b000: alu_res = op1 + op2;
            3'b001: alu_res = op1 - op2;
            3'b010: alu_res = op1 & op2;
            3'b011: alu_res = op1 | op2;
            3'b100: alu_res = op1 ^ op2;
            default: alu_res = 0;
        endcase
    end

    assign breq = (data_A == data_B);
    assign brlt = brun ? (data_A < data_B) : ($signed(data_A) <  $signed(data_B));

endmodule
