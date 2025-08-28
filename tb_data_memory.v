`timescale 1ns / 1ps

module tb_data_memory;

    reg clk;
    reg memw;
    reg [31:0] address;
    reg [31:0] data_write;
    wire [31:0] data_read;

    // Instantiate module
    data_memory uut (
        .clk(clk),
        .memw(memw),
        .address(address),
        .data_write(data_write),
        .data_read(data_read)
    );

    // Clock generation
    always #5 clk = ~clk;  // Chu kỳ clock = 10ns

    initial begin
        // Init
        clk = 0;
        memw = 0;
        address = 0;
        data_write = 0;

        // Test 1: Write vào địa chỉ 4 (ram_addr = 4[8:1] = 2)
        #10;
        address = 32'd4;
        data_write = 32'hDEADBEEF;
        memw = 1;  // bật ghi
        #10;
        memw = 0;  // tắt ghi

        // Test 2: Read lại tại cùng địa chỉ
        #10;
        address = 32'd4;
        #10;
        $display("Read data at addr 4 = %h (expect DEADBEEF)", data_read);

        // Test 3: Write địa chỉ khác
        #10;
        address = 32'd8;
        data_write = 32'h12345678;
        memw = 1;
        #10;
        memw = 0;

        // Read lại
        #10;
        address = 32'd8;
        #10;
        $display("Read data at addr 8 = %h (expect 12345678)", data_read);

        // Test 4: Check default value (chưa ghi)
        #10;
        address = 32'd12;
        #10;
        $display("Read data at addr 12 = %h (expect 0)", data_read);

        #20 $finish;
    end
endmodule
