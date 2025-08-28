module data_memory (
    input        clk,
    input        memw,             
    input [31:0] address,          
    input [31:0] data_write,
    output[31:0] data_read
);
    reg [31:0] ram [0:255];         
    wire [7:0] addr = address[9:2]; // bỏ 2 bit thấp để lấy word index

    integer i;
    initial begin
        for(i=0; i<256; i=i+1)
            ram[i] = 32'd0;
    end

    always @(posedge clk) begin
        if (memw) ram[addr] <= data_write;
    end
    assign data_read = ram[addr];
endmodule
