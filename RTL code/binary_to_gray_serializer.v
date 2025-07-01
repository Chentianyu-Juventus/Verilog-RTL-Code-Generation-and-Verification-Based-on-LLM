//synopsys state_vector state_reg

module binary_to_gray_serializer (
    input wire clk_out_s,          // 时钟信号
    input wire rst_n,              // 异步复位信号，低电平有效
    input wire [135:0] data_out,  // 输入二进制数据，bit [7:0] 为独热码

    // 输出信号
    output reg data_vld_ch1,
    output reg data_vld_ch2,
    output reg data_vld_ch3,
    output reg data_vld_ch4,
    output reg data_vld_ch5,
    output reg data_vld_ch6,
    output reg data_vld_ch7,
    output reg data_vld_ch8,

    output reg data_out_ch1,
    output reg data_out_ch2,
    output reg data_out_ch3,
    output reg data_out_ch4,
    output reg data_out_ch5,
    output reg data_out_ch6,
    output reg data_out_ch7,
    output reg data_out_ch8,

    output reg data_out_req,      // 数据发送请求信号
    output reg data_out_start,    // 数据发送起始信号
    output reg data_out_end ,      // 数据发送结束信号
    input wire data_out_grant    // 数据允许发送信号
);

// ================== 修改开始 ================== //
// 将SystemVerilog的always块转换为Verilog兼容格式
always @(posedge clk_out_s or negedge rst_n) begin
    if (!rst_n) begin
        data_vld_ch1 <= 0;
        data_vld_ch2 <= 0;
        data_vld_ch3 <= 0;
        data_vld_ch4 <= 0;
        data_vld_ch5 <= 0;
        data_vld_ch6 <= 0;
        data_vld_ch7 <= 0;
        data_vld_ch8 <= 0;
    end else begin
        data_vld_ch1 <= (data_out[7:0] == 8'b00000001);
        data_vld_ch2 <= (data_out[7:0] == 8'b00000010);
        data_vld_ch3 <= (data_out[7:0] == 8'b00000100);
        data_vld_ch4 <= (data_out[7:0] == 8'b00001000);
        data_vld_ch5 <= (data_out[7:0] == 8'b00010000);
        data_vld_ch6 <= (data_out[7:0] == 8'b00100000);
        data_vld_ch7 <= (data_out[7:0] == 8'b01000000);
        data_vld_ch8 <= (data_out[7:0] == 8'b10000000);
    end
end
// ================== 修改结束 ================== //

// 内部格雷码信号
reg [127:0] gray_data;

// ================== 修改开始 ================== //
// 将SystemVerilog的function转换为Verilog兼容格式
function [3:0] bin2gray;
    input [3:0] bin;
    integer i;
    begin
        bin2gray[3] = bin[3]; // 最高位保持不变
        for ( i = 2; i >= 0; i = i - 1) begin
            bin2gray[i] = bin[i] ^ bin[i+1];
        end
    end
endfunction
// ================== 修改结束 ================== //

// 在always块中完成转换
always @(data_out) begin:b2g
    integer i;
    for ( i = 0; i < 32; i = i + 1) begin // 循环次数是(135-8+1)/4=32
        gray_data[i*4 +: 4] = bin2gray(data_out[i*4 + 8 +: 4]);
    end
end:b2g

// 状态机定义
// ================== 修改开始 ================== //
// 将SystemVerilog的enum转换为Verilog兼容格式
parameter IDLE = 2'b00, SEND = 2'b01;
reg [1:0] current_state, next_state; 
// ================== 修改结束 ================== //

// 状态寄存器
reg [6:0] bit_counter; // 用于记录发送的位数
reg [127:0] shift_reg; // 移位寄存器
reg [4:0] zero_counter; // 用于记录连续零的个数
reg data_sent; // 标志位，指示是否已经发送完一组数据
reg data_changed; // 检测输入数据是否变化的标识信号

// 用于保存前一个输入数据的寄存器
reg [135:0] prev_data_out;

// 状态机逻辑
always @(posedge clk_out_s or negedge rst_n) begin
    if (!rst_n) begin
       // current_state <= IDLE;
        bit_counter <= 0;
        shift_reg <= 0;
        data_out_ch1 <= 0;
        data_out_ch2 <= 0;
        data_out_ch3 <= 0;
        data_out_ch4 <= 0;
        data_out_ch5 <= 0;
        data_out_ch6 <= 0;
        data_out_ch7 <= 0;
        data_out_ch8 <= 0;
        data_out_req <= 0;
        data_out_start <= 0;
        data_out_end <= 0;
        zero_counter <= 0;
        data_sent <= 0;
        data_changed <= 0;
        prev_data_out <= 0;
    end else begin
        // 检测输入数据是否变化
        if (data_out != prev_data_out) begin
            data_changed <= 1;
            prev_data_out <= data_out;
            // 当新数据到来时，将data_out_end置低
            if (data_out != 0) begin
                data_out_end <= 0;
            end
        end else begin
            data_changed <= 0;
        end

       // current_state <= next_state;

        case (current_state)
            IDLE: begin
                bit_counter <= 0;
                shift_reg <= gray_data;
                data_out_ch1 <= 0;
                data_out_ch2 <= 0;
                data_out_ch3 <= 0;
                data_out_ch4 <= 0;
                data_out_ch5 <= 0;
                data_out_ch6 <= 0;
                data_out_ch7 <= 0;
                data_out_ch8 <= 0;
                data_out_req <= (data_changed && !data_sent) ? 1 : 0; // 当检测到数据变化时请求发送
                data_out_start <= 0;
                zero_counter <= 0;
                data_sent <= 0; // 重置发送标志位
            end

            SEND: begin
                // 根据当前有效的通道输出对应的数据位
                if (data_vld_ch1) data_out_ch1 <= shift_reg[bit_counter];
                if (data_vld_ch2) data_out_ch2 <= shift_reg[bit_counter];
                if (data_vld_ch3) data_out_ch3 <= shift_reg[bit_counter];
                if (data_vld_ch4) data_out_ch4 <= shift_reg[bit_counter];
                if (data_vld_ch5) data_out_ch5 <= shift_reg[bit_counter];
                if (data_vld_ch6) data_out_ch6 <= shift_reg[bit_counter];
                if (data_vld_ch7) data_out_ch7 <= shift_reg[bit_counter];
                if (data_vld_ch8) data_out_ch8 <= shift_reg[bit_counter];

                // 移位操作
                bit_counter <= bit_counter + 1;

                // 检测连续二十个0
                if (shift_reg[bit_counter] == 1) begin
                    zero_counter <= 0;
                end else begin
                    zero_counter <= zero_counter + 1;
                end

                // 判断是否结束发送
                if (bit_counter == 127 || zero_counter >= 20) begin
                    data_sent <= 1; // 标记数据已发送完成
                    data_out_end <= 1; // 拉高data_out_end，并保持
                end
            end

        endcase

        // 设置data_out_start
        if (current_state == IDLE && next_state == SEND && data_out_grant) begin
            data_out_start <= 1;
        end else begin
            data_out_start <= 0;
        end

        // 更新data_out_req
        if (current_state == IDLE && data_changed && !data_sent) begin
            data_out_req <= 1;
        end else if (current_state == SEND && data_out_grant) begin
            data_out_req <= 0;
        end
    end
end

// 状态转移逻辑
always @(*) begin
    //next_state = current_state;

    case (current_state)
        IDLE: begin
            if (data_changed && data_out_grant && !data_sent) begin // 只有当数据变化时才进入SEND状态
                next_state = SEND;
            end
        end

        SEND: begin
            if (bit_counter == 127 || zero_counter >= 20) begin
                next_state = IDLE;
            end
        end
    endcase
end

always@(posedge clk_out_s or negedge rst_n) begin
  if(!rst_n)
    current_state <= IDLE;
  else
    current_state <= next_state;
end
endmodule

