module imem #(
    parameter COL = 32,          // số bit mỗi ô nhớ (1 ins = 32 bit)
    parameter ROW = 256          // số dòng (số ins tối đa)
)(
    input  [31:0] pc,            // Program Counter
    input iready,
    output [31:0] ins    // Instruction output
);

    // Bộ nhớ ins
    reg [COL-1:0] memory [0:ROW-1];
    // Địa chỉ word-aligned: bỏ 2 bit thấp vì mỗi ins = 4 byte
    wire [$clog2(ROW)-1:0] rom_addr = pc[31:2];
    // Load chương trình từ file (hex hoặc bin)
    initial begin
        // Ví dụ dùng file .hex (mỗi dòng 1 ins 32-bit)
        $readmemh("imem_data.txt", memory);
    end
    // Đọc combinational
    assign ins = (iready == 1) ? memory[rom_addr] : 32'b0;

endmodule
