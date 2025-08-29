module datapath (
    input clk,
    input rst_n,
    output [31:0] pc_out,
    output [31:0] ALU_result
);

    reg  [31:0] pc;
    wire [31:0] pc_next, pc4;
    wire [1:0]  wbsel;
    wire [31:0] ins;

    wire        pcsel;
    wire [2:0]  immsel;
    wire        memrw;   
    wire [2:0]  alusel;
    wire        asel, bsel;
    wire        breq, brlt;
    wire        regwen;
    wire        brun;    

    // wire [4:0]  rs1, rs2, rd;
    wire [31:0] data_B, data;
    wire [31:0] data_read;
    wire [31:0] ALUres;

    // PC
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) pc <= 32'd0;
        else        pc <= pc_next;
    end

    // PC + 4
    assign pc4 = pc + 32'd4;

    // IMEM
    imem #(.COL(32), .ROW(256)) imem_inst (
        .pc (pc),
        .ins(ins)
    );

    // Control Unit
    control_unit control_unit_inst (
        .ins   (ins),
        .breq  (breq),
        .brlt  (brlt),
        .pcsel (pcsel),
        .regwen(regwen),
        .asel  (asel),
        .bsel  (bsel),
        .memrw (memrw),   
        .brun  (brun),
        .wbsel (wbsel),
        .alusel(alusel),
        .immsel(immsel)
    );

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

    data_memory data_memory_inst (
        .clk        (clk),
        .memrw      (memrw),
        .address    (ALUres),
        .data_write (data_B),
        .data_read  (data_read)
    );

    // PC next
    assign pc_next = pcsel ? ALUres : pc4;

    // Outputs
    assign ALU_result = ALUres;
    assign pc_out     = pc;

    // Write-back mux
    assign data = (wbsel == 2'b00) ? data_read :
                  (wbsel == 2'b01) ? ALUres    :
                  (wbsel == 2'b11) ? pc4       :  32'b0;   
endmodule
