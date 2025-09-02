// Processor: call instance and connect wire between control unit and datapath

module riscv (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] ins,
    input  wire [31:0] data_read,

    output wire        memrw,
    output wire [31:0] data_write,   
    output wire [31:0] ALUres,      
    output wire [31:0] pc      
);
    // control
    wire [1:0] wbsel;
    wire       pcsel, asel, bsel, regwen, brun;
    wire [2:0] immsel, alusel;
    wire       breq, brlt;

    // Controller
    control_unit u_ctrl (
        .ins    (ins),
        .breq   (breq),
        .brlt   (brlt),
        .pcsel  (pcsel),
        .regwen (regwen),
        .asel   (asel),
        .bsel   (bsel),
        .memrw  (memrw),
        .brun   (brun),
        .wbsel  (wbsel),
        .alusel (alusel),
        .immsel (immsel)
    );

    // Datapath
    datapath u_dp (
        .clk       (clk),
        .rst_n     (rst_n),
        .ins       (ins),
        .data_read (data_read),
        .pcsel     (pcsel),
        .regwen    (regwen),
        .asel      (asel),
        .bsel      (bsel),
        .brun      (brun),
        .wbsel     (wbsel),
        .alusel    (alusel),
        .immsel    (immsel),
        .ALU_result(ALUres),
        .breq      (breq),
        .brlt      (brlt),
        .data_write(data_write),
        .pc        (pc)
    );
endmodule
