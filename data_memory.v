module data_memory (
    input clk,
    input memw,
    input [31:0] address,
    input [31:0] data_write,
    output [31:0] data_read
);
    integer i;  
    reg [31:0] ram [255:0];  
    wire [7:0] ram_addr = address[8 : 1];  

    initial begin  
        for(i=0;i<256;i=i+1)  
            ram[i] <= 32'd0;  
    end
    
    always @(posedge clk) begin  
        if (memw)  
            ram[ram_addr] <= data_write;  
    end  
    assign data_read = ram[ram_addr];
endmodule 
