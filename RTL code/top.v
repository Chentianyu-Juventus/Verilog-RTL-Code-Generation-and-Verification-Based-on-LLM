module top (
    // 全局输入
    input         clk_in,
    input         clk_out,
    input         clk_out_s,
    input         rst_n,
    input  [15:0] data_in,
    input         data_in_valid,
    input         read_en,
    input         data_out_grant,
    // 全局输出
    output        crc_err,
    output        crc_valid,
    output        fifo_full,
    output        fifo_empty,
    output        data_vld_ch1,
    output        data_vld_ch2,
    output        data_vld_ch3,
    output        data_vld_ch4,
    output        data_vld_ch5,
    output        data_vld_ch6,
    output        data_vld_ch7,
    output        data_vld_ch8,
    output        data_out_ch1,  // 修改为1位
    output        data_out_ch2,
    output        data_out_ch3,
    output        data_out_ch4,
    output        data_out_ch5,
    output        data_out_ch6,
    output        data_out_ch7,
    output        data_out_ch8,
    output        data_out_req,
    output        data_out_start,
    output        data_out_end
);

// 内部连接信号声明（保持原样）
wire [127:0] deframe2crc_data;
wire  [7:0] deframe2crc_ch_sel;
wire [15:0] deframe2crc_crc;
wire  [4:0] deframe2crc_data_valid;

wire [127:0] crc2fifo_data;
wire  [7:0] crc2fifo_ch_sel;
wire        crc2fifo_write_en;

wire [135:0] fifo2serial_data;


// 解帧模块实例化
deframer u_deframer (
    .clk_in        (clk_in),
    .rst_n         (rst_n),
    .data_in_valid (data_in_valid),
    .data_in       (data_in),
    .data          (deframe2crc_data),
    .ch_sel        (deframe2crc_ch_sel),
    .crc          (deframe2crc_crc),
    .data_valid    (deframe2crc_data_valid)
);

// CRC校验模块实例化
crc_checker u_crc_checker (
    .clk_in        (clk_in),
    .rst_n         (rst_n),
    .data          (deframe2crc_data),
    .ch_sel        (deframe2crc_ch_sel),
    .CRC           (deframe2crc_crc),
    .data_valid    (deframe2crc_data_valid),
    .crc_valid     (crc_valid),
    .crc_err       (crc_err),
    .data_crc_out  (crc2fifo_data),
    .write_en      (crc2fifo_write_en),
    .ch_sel_out        (crc2fifo_ch_sel)
);

// FIFO模块实例化
async_fifo u_fifo (
    .clk_in        (clk_in),
    .rst_n         (rst_n),
    .clk_out       (clk_out),
    .data_crc_out  (crc2fifo_data),
    .write_en      (crc2fifo_write_en),
    .read_en       (read_en),
    .ch_sel        (crc2fifo_ch_sel),
    .FIFO_full     (fifo_full),
    .FIFO_empty    (fifo_empty),
    .data_FIFO_out (fifo2serial_data)
);

// 串行输出模块实例化（修改位宽）
binary_to_gray_serializer u_serial_output (
    .clk_out_s     (clk_out_s),
    .rst_n         (rst_n),
    .data_out (fifo2serial_data),
    // 有效信号保持原样
    .data_vld_ch1  (data_vld_ch1),
    .data_vld_ch2  (data_vld_ch2),
    .data_vld_ch3  (data_vld_ch3),
    .data_vld_ch4  (data_vld_ch4),
    .data_vld_ch5  (data_vld_ch5),
    .data_vld_ch6  (data_vld_ch6),
    .data_vld_ch7  (data_vld_ch7),
    .data_vld_ch8  (data_vld_ch8),
    // 数据输出改为1位
    .data_out_ch1  (data_out_ch1),
    .data_out_ch2  (data_out_ch2),
    .data_out_ch3  (data_out_ch3),
    .data_out_ch4  (data_out_ch4),
    .data_out_ch5  (data_out_ch5),
    .data_out_ch6  (data_out_ch6),
    .data_out_ch7  (data_out_ch7),
    .data_out_ch8  (data_out_ch8),
    .data_out_grant  (data_out_grant),
    .data_out_end  (data_out_end),
    .data_out_start  (data_out_start),
    .data_out_req  (data_out_req)
);

endmodule

