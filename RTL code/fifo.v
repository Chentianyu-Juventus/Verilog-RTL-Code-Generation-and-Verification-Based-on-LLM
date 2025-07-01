module async_fifo #(
    parameter DATA_WIDTH = 136,  // 128位数据 + 8位通道选择
    parameter DATA_DEPTH = 16,
    parameter PTR_WIDTH = 5       //5位
)(
    // 写时钟域
    input clk_in,
    input rst_n,
    input write_en,
    input [127:0] data_crc_out,
    input [7:0] ch_sel,
    
    // 读时钟域
    input clk_out,
    input read_en,
    
    // 输出信号
    output wire FIFO_full,
    output wire FIFO_empty,
    output reg [DATA_WIDTH-1:0] data_FIFO_out
);

    // 写指针和读指针（二进制）
    reg [PTR_WIDTH-1:0] wr_ptr_reg;
    reg [PTR_WIDTH-1:0] rd_ptr_reg;

    // 同步后的读指针（在写时钟域）
    reg [PTR_WIDTH-1:0] rd_ptr_gray_sync1;
    reg [PTR_WIDTH-1:0] rd_ptr_gray_sync2;
    
    // 同步后的写指针（在读时钟域）
    reg [PTR_WIDTH-1:0] wr_ptr_gray_sync1;
    reg [PTR_WIDTH-1:0] wr_ptr_gray_sync2;

    // RAM存储
    reg [DATA_WIDTH-1:0] mem [0:DATA_DEPTH-1];
  
    // 格雷码转换
    wire [PTR_WIDTH-1:0] wr_ptr_gray;
    wire [PTR_WIDTH-1:0] rd_ptr_gray;
    wire [PTR_WIDTH - 2 : 0] wr_ptr_true; // 真实写地址指针，作为写RAM的地址
    wire [PTR_WIDTH - 2 : 0] rd_ptr_true; // 真实读地址指针，作为读RAM的地址

    // 读写RAM地址赋值
    assign wr_ptr_true = wr_ptr_reg [PTR_WIDTH - 2 : 0]; // 写RAM地址等于写指针的低DATA_DEPTH位（去除最高位）
    assign rd_ptr_true = rd_ptr_reg [PTR_WIDTH - 2 : 0]; // 读RAM地址等于读指针的低DATA_DEPTH位（去除最高位）

    // 写时钟域逻辑
    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr_reg <= 0;  
           // FIFO_full <= 1'b0;
        end else begin
            if (write_en && !FIFO_full) begin
                mem[wr_ptr_true] <= {data_crc_out, ch_sel};
                wr_ptr_reg <= wr_ptr_reg + 1'd1;         
            end
        end
    end

   // 修改后的FIFO_full逻辑
   assign  FIFO_full  = ( wr_ptr_gray == { ~(rd_ptr_gray_sync2[PTR_WIDTH-1 : PTR_WIDTH - 2]),rd_ptr_gray_sync2[PTR_WIDTH - 3 : 0]})? 1'b1 : 1'b0;


    // 读时钟域逻辑
    always @(posedge clk_out or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr_reg <= 0;
           // FIFO_empty <= 1'b1;
            data_FIFO_out <= 0;
        end else begin
            if (read_en && !FIFO_empty) begin
                data_FIFO_out <= mem[rd_ptr_true];
                rd_ptr_reg <= rd_ptr_reg + 1'd1;
            end
        end
    end

 assign	FIFO_empty = ( rd_ptr_gray == wr_ptr_gray_sync2) ? 1'b1 : 1'b0;

    // 格雷码转换
    assign wr_ptr_gray = wr_ptr_reg ^ (wr_ptr_reg >> 1);
    assign rd_ptr_gray = rd_ptr_reg ^ (rd_ptr_reg >> 1);

    // 写时钟域同步读指针
    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr_gray_sync1 <= 0;
            rd_ptr_gray_sync2 <= 0;
        end else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end

    // 读时钟域同步写指针
    always @(posedge clk_out or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr_gray_sync1 <= 0;
            wr_ptr_gray_sync2 <= 0;
        end else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end
    end

endmodule

