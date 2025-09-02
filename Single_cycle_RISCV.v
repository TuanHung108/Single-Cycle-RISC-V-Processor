module single_cycle_riscv (
    input clk,
    input rst_n,
    output [31:0] pc,
    output [31:0] ALUres, 
    output [31:0] data_read 
);
    wire [31:0] ins, data_B;
    wire memrw;

    // IMEM
    imem #(.COL(32), .ROW(256)) imem_inst (
        .pc (pc),
        .ins(ins)
    );

    data_memory data_memory_inst (
        .clk        (clk),
        .memrw      (memrw),
        .address    (ALUres),
        .data_write (data_B),
        .data_read  (data_read)
    );

    riscv riscv_inst (
        .clk(clk),
        .rst_n(rst_n),
        .ins(ins),
        .data_read(data_read),
        .memrw(memrw),
        .data_write(data_B),
        .ALUres(ALUres),
        .pc(pc)
    );

endmodule