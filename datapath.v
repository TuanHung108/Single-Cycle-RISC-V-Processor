module datapath (
    input clk,
    input rst_n,
    input [1:0] wbsel,
    input [31:0] ins,
    input pcsel, regwen, asel, bsel, brun,
    input [2:0] alusel,
    input [2:0] immsel,
    input [31:0] data_read,
    output [31:0] pc_out,
    output [31:0] ALU_result, data_write,
    output breq, brlt
);

    reg  [31:0] pc;
    wire [31:0] pc_next, pc4;


    // wire [4:0]  rs1, rs2, rd;
    wire [31:0] data_B, data;
    wire [31:0] ALUres;

    // PC
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) pc <= 32'd0;
        else        pc <= pc_next;
    end

    // PC + 4
    assign pc4 = pc + 32'd4;

    // PC next
    assign pc_next = pcsel ? ALUres : pc4;

    register_file register_file_inst (
        .clk     (clk),
        .rst_n   (rst_n),
        .ins     (ins),
        .regwen  (regwen),
        .immsel  (immsel),
        .data_in (data),
        .pc      (pc),
        .brun    (brun),
        .asel    (asel),
        .bsel    (bsel),
        .alusel  (alusel),
        .alu_res (ALUres),
        .breq    (breq),
        .brlt    (brlt),
        .data_B  (data_B)
    );


    // Outputs
    assign ALU_result = ALUres;
    assign pc_out     = pc;
    assign data_write = data_B;

    // Write-back mux
    assign data = (wbsel == 2'b00) ? data_read :
                  (wbsel == 2'b01) ? ALUres    :
                  (wbsel == 2'b11) ? pc4       :  32'b0;   
endmodule
