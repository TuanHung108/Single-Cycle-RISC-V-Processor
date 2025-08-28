module datapath (
    input clk,
    input rst_n,
    output [31:0] pc_out,
    output [31:0] ALU_result
);

    reg [31:0] pc;
    wire [31:0] pc_next, pc4;
    wire [1:0] wbsel;
    wire iready;
    assign iready = 1'b1;
    wire [31:0] ins;
    wire pcsel;
    wire [2:0] immsel;
    wire memw;
    wire [2:0] alusel;
    wire asel, bsel;
    wire breq, brlt;
    wire regwen;
    wire [4:0] rs1, rs2, rd;
    wire [31:0] data_B, data;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [31:0] imm_extend;
    wire [31:0] data_read;
    wire [31:0] ALUres;


    // PC
    always @(posedge clk or negedge rst_n) begin 
        if (!rst_n) pc <= 0;
        else pc <= pc_next;
    end

    // PC + 4
    assign pc4 = pc + 4;

    // IMEM
    imem #(.COL(32), .ROW(256)) imem_inst (
        .pc(pc),
        .iready(iready),
        .ins(ins)
    );

    // Control Unit
    control_unit control_unit_inst (
        .ins(ins),
        .iready(iready),
        .pcsel(pcsel),
        .wbsel(wbsel),
        .memw(memw),
        .alusel(alusel),
        .bsel(bsel),
        .asel(asel),
        // .brun(brun),
        .breq(breq),
        .brlt(brlt),
        .regwen(regwen),
        .immsel(immsel)
    );

    // register file
    register_file register_file_inst (
        .clk(clk),
        .rst_n(rst_n),
        .regwen(regwen),
        .immsel(immsel),
        .data_in(data),
        .pc(pc),
        .asel(asel),
        .bsel(bsel),
        .alusel(alusel),
        .alu_res(ALUres),
        .breq(breq),
        .brlt(brlt),
        .data_B(data_B)
    );


    data_memory data_memory_inst (
        .clk(clk),
        .memw(memw),
        .address(ALUres),
        .data_write(data_B),
        .data_read(data_read)
    );

    // PCnext
    assign pc_next = (pcsel) ? ALUres : pc4; 

    // Output
    assign ALU_result = ALUres;
    assign pc_out = pc;

    // Write back
    assign data = (wbsel == 2'b00) ? data_read :
                    (wbsel == 2'b01) ? ALUres :
                    (wbsel == 2'b11) ? pc4 : 32'b0;

endmodule
