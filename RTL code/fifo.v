module async_fifo #(
    parameter DATA_WIDTH = 136,  // 128λ���� + 8λͨ��ѡ��
    parameter DATA_DEPTH = 16,
    parameter PTR_WIDTH = 5       //5λ
)(
    // дʱ����
    input clk_in,
    input rst_n,
    input write_en,
    input [127:0] data_crc_out,
    input [7:0] ch_sel,
    
    // ��ʱ����
    input clk_out,
    input read_en,
    
    // ����ź�
    output wire FIFO_full,
    output wire FIFO_empty,
    output reg [DATA_WIDTH-1:0] data_FIFO_out
);

    // дָ��Ͷ�ָ�루�����ƣ�
    reg [PTR_WIDTH-1:0] wr_ptr_reg;
    reg [PTR_WIDTH-1:0] rd_ptr_reg;

    // ͬ����Ķ�ָ�루��дʱ����
    reg [PTR_WIDTH-1:0] rd_ptr_gray_sync1;
    reg [PTR_WIDTH-1:0] rd_ptr_gray_sync2;
    
    // ͬ�����дָ�루�ڶ�ʱ����
    reg [PTR_WIDTH-1:0] wr_ptr_gray_sync1;
    reg [PTR_WIDTH-1:0] wr_ptr_gray_sync2;

    // RAM�洢
    reg [DATA_WIDTH-1:0] mem [0:DATA_DEPTH-1];
  
    // ������ת��
    wire [PTR_WIDTH-1:0] wr_ptr_gray;
    wire [PTR_WIDTH-1:0] rd_ptr_gray;
    wire [PTR_WIDTH - 2 : 0] wr_ptr_true; // ��ʵд��ַָ�룬��ΪдRAM�ĵ�ַ
    wire [PTR_WIDTH - 2 : 0] rd_ptr_true; // ��ʵ����ַָ�룬��Ϊ��RAM�ĵ�ַ

    // ��дRAM��ַ��ֵ
    assign wr_ptr_true = wr_ptr_reg [PTR_WIDTH - 2 : 0]; // дRAM��ַ����дָ��ĵ�DATA_DEPTHλ��ȥ�����λ��
    assign rd_ptr_true = rd_ptr_reg [PTR_WIDTH - 2 : 0]; // ��RAM��ַ���ڶ�ָ��ĵ�DATA_DEPTHλ��ȥ�����λ��

    // дʱ�����߼�
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

   // �޸ĺ��FIFO_full�߼�
   assign  FIFO_full  = ( wr_ptr_gray == { ~(rd_ptr_gray_sync2[PTR_WIDTH-1 : PTR_WIDTH - 2]),rd_ptr_gray_sync2[PTR_WIDTH - 3 : 0]})? 1'b1 : 1'b0;


    // ��ʱ�����߼�
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

    // ������ת��
    assign wr_ptr_gray = wr_ptr_reg ^ (wr_ptr_reg >> 1);
    assign rd_ptr_gray = rd_ptr_reg ^ (rd_ptr_reg >> 1);

    // дʱ����ͬ����ָ��
    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr_gray_sync1 <= 0;
            rd_ptr_gray_sync2 <= 0;
        end else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end

    // ��ʱ����ͬ��дָ��
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

