//synopsys state_vector state_reg

module binary_to_gray_serializer (
    input wire clk_out_s,          // ʱ���ź�
    input wire rst_n,              // �첽��λ�źţ��͵�ƽ��Ч
    input wire [135:0] data_out,  // ������������ݣ�bit [7:0] Ϊ������

    // ����ź�
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

    output reg data_out_req,      // ���ݷ��������ź�
    output reg data_out_start,    // ���ݷ�����ʼ�ź�
    output reg data_out_end ,      // ���ݷ��ͽ����ź�
    input wire data_out_grant    // �����������ź�
);

// ================== �޸Ŀ�ʼ ================== //
// ��SystemVerilog��always��ת��ΪVerilog���ݸ�ʽ
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
// ================== �޸Ľ��� ================== //

// �ڲ��������ź�
reg [127:0] gray_data;

// ================== �޸Ŀ�ʼ ================== //
// ��SystemVerilog��functionת��ΪVerilog���ݸ�ʽ
function [3:0] bin2gray;
    input [3:0] bin;
    integer i;
    begin
        bin2gray[3] = bin[3]; // ���λ���ֲ���
        for ( i = 2; i >= 0; i = i - 1) begin
            bin2gray[i] = bin[i] ^ bin[i+1];
        end
    end
endfunction
// ================== �޸Ľ��� ================== //

// ��always�������ת��
always @(data_out) begin:b2g
    integer i;
    for ( i = 0; i < 32; i = i + 1) begin // ѭ��������(135-8+1)/4=32
        gray_data[i*4 +: 4] = bin2gray(data_out[i*4 + 8 +: 4]);
    end
end:b2g

// ״̬������
// ================== �޸Ŀ�ʼ ================== //
// ��SystemVerilog��enumת��ΪVerilog���ݸ�ʽ
parameter IDLE = 2'b00, SEND = 2'b01;
reg [1:0] current_state, next_state; 
// ================== �޸Ľ��� ================== //

// ״̬�Ĵ���
reg [6:0] bit_counter; // ���ڼ�¼���͵�λ��
reg [127:0] shift_reg; // ��λ�Ĵ���
reg [4:0] zero_counter; // ���ڼ�¼������ĸ���
reg data_sent; // ��־λ��ָʾ�Ƿ��Ѿ�������һ������
reg data_changed; // ������������Ƿ�仯�ı�ʶ�ź�

// ���ڱ���ǰһ���������ݵļĴ���
reg [135:0] prev_data_out;

// ״̬���߼�
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
        // ������������Ƿ�仯
        if (data_out != prev_data_out) begin
            data_changed <= 1;
            prev_data_out <= data_out;
            // �������ݵ���ʱ����data_out_end�õ�
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
                data_out_req <= (data_changed && !data_sent) ? 1 : 0; // ����⵽���ݱ仯ʱ������
                data_out_start <= 0;
                zero_counter <= 0;
                data_sent <= 0; // ���÷��ͱ�־λ
            end

            SEND: begin
                // ���ݵ�ǰ��Ч��ͨ�������Ӧ������λ
                if (data_vld_ch1) data_out_ch1 <= shift_reg[bit_counter];
                if (data_vld_ch2) data_out_ch2 <= shift_reg[bit_counter];
                if (data_vld_ch3) data_out_ch3 <= shift_reg[bit_counter];
                if (data_vld_ch4) data_out_ch4 <= shift_reg[bit_counter];
                if (data_vld_ch5) data_out_ch5 <= shift_reg[bit_counter];
                if (data_vld_ch6) data_out_ch6 <= shift_reg[bit_counter];
                if (data_vld_ch7) data_out_ch7 <= shift_reg[bit_counter];
                if (data_vld_ch8) data_out_ch8 <= shift_reg[bit_counter];

                // ��λ����
                bit_counter <= bit_counter + 1;

                // ���������ʮ��0
                if (shift_reg[bit_counter] == 1) begin
                    zero_counter <= 0;
                end else begin
                    zero_counter <= zero_counter + 1;
                end

                // �ж��Ƿ��������
                if (bit_counter == 127 || zero_counter >= 20) begin
                    data_sent <= 1; // ��������ѷ������
                    data_out_end <= 1; // ����data_out_end��������
                end
            end

        endcase

        // ����data_out_start
        if (current_state == IDLE && next_state == SEND && data_out_grant) begin
            data_out_start <= 1;
        end else begin
            data_out_start <= 0;
        end

        // ����data_out_req
        if (current_state == IDLE && data_changed && !data_sent) begin
            data_out_req <= 1;
        end else if (current_state == SEND && data_out_grant) begin
            data_out_req <= 0;
        end
    end
end

// ״̬ת���߼�
always @(*) begin
    //next_state = current_state;

    case (current_state)
        IDLE: begin
            if (data_changed && data_out_grant && !data_sent) begin // ֻ�е����ݱ仯ʱ�Ž���SEND״̬
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

