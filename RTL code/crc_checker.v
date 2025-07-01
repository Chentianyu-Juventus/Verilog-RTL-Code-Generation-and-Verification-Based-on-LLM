module crc_checker (
    input        clk_in,
    input        rst_n,
    input [127:0] data,
    input [15:0]  CRC,
    input [4:0]   data_valid,
    input [7:0]   ch_sel,
    output reg [127:0] data_crc_out,
    output reg    crc_valid,
    output reg    crc_err,
    output reg    write_en,
    output reg   [7:0]ch_sel_out
);

// 将CRC计算函数嵌入模块内部
function automatic [15:0] crc_ccitt_128b;
    input [127:0] data;
    input [4:0]   data_valid;
    reg [15:0]    crc;
    integer i, j;  // 循环变量声明必须在begin块之前
    begin
        crc = 16'hFFFF;
        for (i = 0; i < data_valid; i = i + 1) begin
            crc[15:8] = crc[15:8] ^ data[i*8 +:8];
            for (j = 0; j < 8; j = j + 1) begin
                crc = {crc[14:0], 1'b0} ^ (crc[15] ? 16'h1021 : 16'h0);
            end
        end
        crc_ccitt_128b = crc;
    end
endfunction

// 计算结果的连线声明
wire [15:0] calc_crc = crc_ccitt_128b(data, data_valid);

// 组合逻辑判断
wire data_zero = (data == 128'b0);
//wire valid_in_range = (data_valid >= 2) && (data_valid <= 16);

always @(posedge clk_in or negedge rst_n) begin
    if (!rst_n) begin
        data_crc_out <= 128'b0;
        crc_valid    <= 1'b0;
        crc_err      <= 1'b0;
        ch_sel_out  <=1'b0;
        write_en      <=1'b0; 
    end else begin
        data_crc_out <= 128'b0;
        crc_valid    <= 1'b0;
        crc_err      <= 1'b0;
        ch_sel_out  <=1'b0;
        write_en      <=1'b0;

      //  if (!data_zero && valid_in_range && (data_valid != 0)) 
        if (!data_zero) 
        begin
            if (calc_crc == CRC) begin
                data_crc_out <= data;
                ch_sel_out <= ch_sel;
                crc_valid    <= 1'b1;
                write_en      <=1'b1;
            end else begin
                crc_err <= 1'b1;
            end
        end
        
    //    if (!valid_in_range && !data_zero && !(data_valid==0) ) begin
    //        crc_err <= 1'b1;
    //    end
    end
end

endmodule


