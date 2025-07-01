`timescale 1ns/1ps





module top_tb;

// Parameters
parameter CLK_IN_PERIOD = 10;    // 100MHz
parameter CLK_OUT_PERIOD = 10;   // 100MHz
parameter CLK_OUT_S_PERIOD = 0.625; // 16x clk_out (1.6GHz)
//parameter FRAME_HEADER = 32'hE0E0E0E0;
//parameter FRAME_TAIL = 32'h0E0E0E0E;

// Inputs
reg clk_in;
reg clk_out;
reg clk_out_s;
reg rst_n;
reg [15:0] data_in;
reg data_in_valid;
reg read_en;

// Outputs
wire crc_err;
wire crc_valid;
wire fifo_full;
wire fifo_empty;
wire data_vld_ch1;
wire data_vld_ch2;
wire data_vld_ch3;
wire data_vld_ch4;
wire data_vld_ch5;
wire data_vld_ch6;
wire data_vld_ch7;
wire data_vld_ch8;
wire data_out_ch1;
wire data_out_ch2;
wire data_out_ch3;
wire data_out_ch4;
wire data_out_ch5;
wire data_out_ch6;
wire data_out_ch7;
wire data_out_ch8;
wire data_out_req;
wire data_out_grant;
wire data_out_start;
wire data_out_end;
assign data_out_grant =1 ;

// Test variables
//reg [127:0] expected_data;
//reg [7:0] expected_channel;
//reg [15:0] expected_uut.u_deframer.crc;
integer data_length_bits;
integer bit_count;
reg [127:0] received_data;
reg [127:0] expected_gray;
reg [127:0] gray_data;
reg         compare_ok;


logic [7:0] data_vld_ch;
logic [7:0] data_out_ch;
//logic act_bit;
//logic exp_bit;
 bit[127:0] error_count;
 wire [127:0]data;
 bit [4:0]valid_byte;
 bit[7:0]ch_sel;
 bit[15:0]crc;
 int crc_err_cnt;
 int crc_correct_cnt;

 bit[15:0]crc_rand;
 bit[127:0] data_rand;

 
assign data = (valid_byte == 2 )  ? {112'b0, data_rand[15:0]  } : (valid_byte == 4)
                                  ? {96'b0 , data_rand[31:0]  } : (valid_byte == 6)
                                  ? {80'b0 , data_rand[47:0]  } : (valid_byte == 8)
                                  ? {64'b0 , data_rand[63:0]  } : (valid_byte == 10)
                                  ? {48'b0 , data_rand[79:0]  } : (valid_byte == 12)
                                  ? {32'b0 , data_rand[95:0]  } : (valid_byte == 14)
                                  ? {16'b0 , data_rand[111:0] } : (valid_byte == 16)
                                  ?          data_rand[127:0]   : 0;

//constraint valid_values {
  //      valid_byte inside {2,4,6,8,10,12,14,16};
//}



// Instantiate the Unit Under Test (UUT)
top uut (
    .clk_in(clk_in),
    .clk_out(clk_out),
    .clk_out_s(clk_out_s),
    .rst_n(rst_n),
    .data_in(data_in),
    .data_in_valid(data_in_valid),
    .read_en(read_en),
    .crc_err(rc_err),
    .crc_valid(crc_valid),
    .fifo_full(fifo_full),
    .fifo_empty(fifo_empty),
    .data_vld_ch1(data_vld_ch1),
    .data_vld_ch2(data_vld_ch2),
    .data_vld_ch3(data_vld_ch3),
    .data_vld_ch4(data_vld_ch4),
    .data_vld_ch5(data_vld_ch5),
    .data_vld_ch6(data_vld_ch6),
    .data_vld_ch7(data_vld_ch7),
    .data_vld_ch8(data_vld_ch8),
    .data_out_ch1(data_out_ch1),
    .data_out_ch2(data_out_ch2),
    .data_out_ch3(data_out_ch3),
    .data_out_ch4(data_out_ch4),
    .data_out_ch5(data_out_ch5),
    .data_out_ch6(data_out_ch6),
    .data_out_ch7(data_out_ch7),
    .data_out_ch8(data_out_ch8),
    .data_out_end(data_out_end),
    .data_out_start(data_out_start),
    .data_out_req(data_out_req),
    .data_out_grant(data_out_grant)
);


// === Pack data_vld_ch and data_out_ch from individual wires ===
always_comb begin
    data_vld_ch = {
        data_vld_ch8, data_vld_ch7, data_vld_ch6, data_vld_ch5,
        data_vld_ch4, data_vld_ch3, data_vld_ch2, data_vld_ch1
    };

    data_out_ch = {
        data_out_ch8, data_out_ch7, data_out_ch6, data_out_ch5,
        data_out_ch4, data_out_ch3, data_out_ch2, data_out_ch1
    };
end




// Clock generation
initial begin
    clk_in = 0;
    forever #(CLK_IN_PERIOD/2) clk_in = ~clk_in;
end

initial begin
    clk_out = 0;
    forever #(CLK_OUT_PERIOD/2) clk_out = ~clk_out;
end

initial begin
    clk_out_s = 0;
    forever #(CLK_OUT_S_PERIOD/2) clk_out_s = ~clk_out_s;
end

// Test sequence
initial begin
    // Initialize Inputs
    rst_n = 1;
#1;
    rst_n = 0;
    data_in = 0;
    data_in_valid = 0;
    read_en = 0;
    
    // Reset the system
    #100;
    rst_n = 1;
    #100;
    
    // Test Case: Normal frame with 32-bit data, channel 1
    
    // Send frame (header + channel 1 + 32-bit data + uut.u_deframer.crc + tail)
	
 
 	 // 测试用例1：（16字节数据）
	///////////通道选择1            128bit数据位                    正确uut.u_deframer.crc(手动填写，后续需加参考模型）        
  //  send_frame(8'b00000001, 128'hAABBCCDD_11223344_55667788_99AABBCC,   16);
	//
	//
  //  check_result(8'b00000001, 128'hAABBCCDD_11223344_55667788_99AABBCC, 16'h1A0D, 16);
  //  #100;//延时等数据
  //  // Read from FIFO to trigger output
  //  @(posedge clk_out);
  //  read_en = 1;
  //  @(posedge clk_out);
  //  read_en = 0;
  //  
	////Calculate expected Gray code
////	reg [127:0] gray_data;
  //  gray_data = uut.u_serial_output.gray_data; //调用gray_data 内部信号
	//                                                                   
	//calculate_expected_gray(136'hAABBCCDD_11223344_55667788_99AABBCC01, gray_data , compare_ok);//
  for (int n = 1; n <= 100; n = n + 1)
 begin
  std::randomize(data_rand);
  std::randomize(valid_byte)  with {valid_byte inside {2,4,6,8,10,12,14,16};};
  //ch_sel = 8'b0000_0001;
  //crc = uut.u_crc_checker.crc_ccitt_128b(data,valid_byte); // correct crc
   std::randomize(crc_rand);  //err crc
#1;
   std::randomize(crc) with {crc dist {crc_rand:=50 , uut.u_crc_checker.crc_ccitt_128b(data,valid_byte):=50};};
   if(crc == uut.u_crc_checker.crc_ccitt_128b(data,valid_byte)) begin
     $display("this is a correct CRC frame ");
     crc_correct_cnt <= crc_correct_cnt+1;
   end
   else begin
     $display("this is a ERROR CRC frame ");
     crc_err_cnt <= crc_err_cnt+1;
   end
   std::randomize(ch_sel) with {ch_sel inside {8'b0000_0001,
                                                       8'b0000_0010,
                                                       8'b0000_0100,
                                                       8'b0000_1000,
                                                       8'b0001_0000,
                                                       8'b0010_0000,  
                                                       8'b0100_0000,
                                                       8'b1000_0000
                                                       };};
  #1;
  one_frame_transfer(ch_sel,data,valid_byte,crc);
		$display(" data       is %h,\n data_rand  is %h,\n valid_byte is %h",data,data_rand,valid_byte);
    $display("--------------the %dst test is done-------------------",n);
end

//-----------------------Orientation testing-----------------------------
  data_rand = {128{1'b1}};
  crc = 16'hffff;
  for(int i =2;i<=16;i=i+2) begin
  valid_byte=i;
 #2;
		$display(" data       is %h,\n data_rand  is %h,\n valid_byte is %h",data,data_rand,valid_byte);
  one_frame_transfer(ch_sel,data,valid_byte,crc);
end

 data_rand = {128{1'b1}};
 #1;
  crc = uut.u_crc_checker.crc_ccitt_128b(data,valid_byte);
  for(int i =2;i<=16;i=i+2) begin
  valid_byte=i;
 #2;
		$display(" data       is %h,\n data_rand  is %h,\n valid_byte is %h",data,data_rand,valid_byte);
  one_frame_transfer(ch_sel,data,valid_byte,crc);
end

  data_rand = {128{1'b0}};
  crc = 16'h0;
  one_frame_transfer(ch_sel,data,valid_byte,crc);
  for(int i =2;i<=16;i=i+2) begin
  valid_byte=i;
 #2;
		$display(" data       is %h,\n data_rand  is %h,\n valid_byte is %h",data,data_rand,valid_byte);
  one_frame_transfer(ch_sel,data,valid_byte,crc);
end

	if(error_count == 0)begin
		$display("=====================TEST_PASSSED-====================");
		$display("=====================crc_correct frame is %d,crc_err frame is %d-====================",crc_correct_cnt,crc_err_cnt);
	end else begin
		$display("=====================TEST FAILED -%0d error(s) encountered===========", error_count);
	end
#10000;
    $finish;
end


task send_frame;
    input [7:0] channel;
    input [127:0] payload;
    input [4:0]  payload_length_bytes; // 👈 新增参数，真实要发的字节数
    integer i;
    input [15:0] crc_value;
    begin
    // crc_value = uut.u_crc_checker.crc_ccitt_128b(payload,payload_length_bytes);
        data_in_valid = 1;
        @(posedge clk_in);
        data_in = 16'he0e0; @(posedge clk_in);
        data_in = 16'he0e0; @(posedge clk_in);
        data_in = {channel, 8'h00}; @(posedge clk_in);

        // 发有效数据
		if (payload_length_bytes > 0) begin
        for (i = 0; i < (payload_length_bytes >> 1); i = i + 1) begin
            data_in = payload[ i*16 +: 16];  // Big-Endian
            @(posedge clk_in);
        end
		end
        data_in = crc_value; @(posedge clk_in);
        data_in = 16'h0e0e; @(posedge clk_in);
        data_in = 16'h0e0e; @(posedge clk_in);
	//	data_in = 16'h0e0e;
	//  repeat (2) @(posedge clk_in);
        data_in_valid = 0;
		data_in = 16'h0;
    end
endtask


// 检查解帧结果的函数
task check_result;
    input [7:0] exp_ch_sel;
    input [127:0] exp_data;
    
    input [4:0] exp_data_valid;
    input [15:0]exp_crc;
    begin
        @(posedge clk_in);
        if (uut.u_deframer.ch_sel !== exp_ch_sel) 
        begin  $display("Error: Channel select mismatch. Expected %h, got %h", exp_ch_sel, uut.u_deframer.ch_sel); error_count++;end
        
        if (uut.u_deframer.data !== exp_data) 
        begin     $display("Error: Data mismatch. Expected %h, got %h", exp_data, uut.u_deframer.data); error_count++;end
        
        if (uut.u_deframer.crc !== exp_crc) 
        begin     $display("Error: uut.u_deframer.crc mismatch. Expected %h, got %h", exp_crc, uut.u_deframer.crc); error_count++;end
        
        if (uut.u_deframer.data_valid !== exp_data_valid) 
        begin   $display("Error: Data valid mismatch. Expected %d, got %d", exp_data_valid, uut.u_deframer.data_valid);error_count++;end
        if (uut.u_deframer.ch_sel === exp_ch_sel && uut.u_deframer.data === exp_data && 
            uut.u_deframer.crc === exp_crc && uut.u_deframer.data_valid === exp_data_valid)
            $display("Check passed for channel %h", exp_ch_sel);
    end
endtask

task crc_check(
  input [7:0]ch_sel , 
  input [127:0]data , 
  input[4:0]valid_byte, 
  input [15:0]crc);

        @(posedge clk_in);
      if(data!=0 && valid_byte!=0)
      begin
        if(crc!=uut.u_crc_checker.crc_ccitt_128b(data,valid_byte))
          begin
           if(uut.u_crc_checker.crc_err != 1 | uut.u_crc_checker.crc_valid ==1)
           begin $display("Error: uut.u_crc_check.crc_err/crc_valid mismatch. Expected crc_err=1,crc_valid=0, got crc_err=%h, crc_valid=%h", uut.u_crc_checker.crc_err, uut.u_crc_checker.crc_valid); error_count++;end
          end
        else if(crc == uut.u_crc_checker.crc_ccitt_128b(data,valid_byte)) begin
         if(uut.u_crc_checker.ch_sel_out != ch_sel)
         begin $display("Error: uut.crc_check.ch_sel_out mismatch. Expected %h, got %h", ch_sel, uut.u_crc_checker.ch_sel_out); error_count++;end
         if(uut.u_crc_checker.data_crc_out != data)
         begin $display("Error: uut.crc_check.data_crc_out mismatch. Expected %h, got %h", data, uut.u_crc_checker.data_crc_out); error_count++;end
         if(uut.u_crc_checker.crc_valid != 1 | uut.u_crc_checker.crc_err != 0)
         begin $display("Error: uut.u_crc_check.crc_err/crc_valid mismatch. Expected crc_err=0,crc_valid=1, got crc_err=%h, crc_valid=%h", uut.u_crc_checker.crc_err, uut.u_crc_checker.crc_valid); error_count++;end

   end
 end
 else
   begin
     if(!(uut.u_crc_checker.crc_valid ==0 && uut.u_crc_checker.crc_err == 0))
         begin $display("Error: uut.u_crc_check.crc_err/crc_valid mismatch. Expected crc_err=0,crc_valid=0, got crc_err=%h, crc_valid=%h", uut.u_crc_checker.crc_err, uut.u_crc_checker.crc_valid); error_count++;end

   end
endtask

task automatic calculate_expected_gray;
    input  [135:0] binary_data;  // 8-bit ?? + 128-bit ??
    input  [127:0] gray_data;    // DUT ?? Gray ???
    output bit     compare_ok;   // ??????
  //  output int     error_count;  // ??? nibble ??

    integer i;
    reg [127:0] expected_gray;
    reg [3:0]   current_nibble;

    begin
        expected_gray = 128'b0;
        //error_count = 0;

        // 128-bit Payload ? binary_data[135:8] ??
        for (i = 0; i < 32; i = i + 1) begin
            current_nibble = binary_data[135 - i*4 -: 4];  // Big-endian nibble
            expected_gray[127 - i*4 -: 4] = current_nibble ^ (current_nibble >> 1); // ?????
        end

        // Bit-level ??
        compare_ok = (expected_gray === gray_data);
        if (!compare_ok) begin
            $error("? Gray code mismatch!");
            $display("Expected: %032h", expected_gray);
            $display("Actual:   %02h", gray_data);

            $display("data:   %032h", binary_data[135:8]);
            $display("ch_sel:   %032h", binary_data[7:0]);
            for (i = 0; i < 32; i = i + 1) begin
                if (expected_gray[127 - i*4 -: 4] !== gray_data[127 - i*4 -: 4]) begin
                    $display("  ? Nibble[%0d] Error: Expected=%h, Actual=%h",
                             i,
                             expected_gray[127 - i*4 -: 4],
                             gray_data[127 - i*4 -: 4]);
                    error_count++;
                end
            end
            $display("? Total mismatched nibbles: %0d", error_count);
        end else begin
            $display("? Gray code match: %032h", expected_gray);
        end
    end
endtask


task automatic verify_serial_output;
    input [7:0]  expected_channel;  // 预期通道选择（独热码）
    input [127:0] expected_gray;    // 已计算好的格雷码数据
begin
    error_count = 0;
    wait(uut.u_serial_output.current_state == uut.u_serial_output.SEND);

    for (int i = 0; i < 128; i++) begin
        @(posedge clk_out_s);

      //  exp_bit = expected_gray[i];
      //  act_bit = data_out_ch[0];  // 默认测试通道1

        if (uut.u_serial_output.data_vld_ch1 !== expected_channel) begin
            $error("Cycle %0d: Channel mismatch! Exp=%b Act=%b", i, expected_channel, uut.u_serial_output.data_vld_ch1);
            error_count++;
        end

        if (uut.u_serial_output.data_out_ch1 !== expected_gray[i]) begin
            $error("Cycle %0d: Bit mismatch! Exp=%b Act=%b", i, expected_gray[i], uut.u_serial_output.data_out_ch1);
            error_count++;
        end
    end

    if (error_count == 0)
        $display("Serial output verified successfully");
    else
        $display("Serial output failed with %0d errors", error_count);
end
endtask

task one_frame_transfer (
  input [7:0]ch_sel, 
  input [127:0]data , 
  input [4:0]valid_byte, 
  input [15:0]crc);

  send_frame(ch_sel, data,   valid_byte, crc);
	
	
    check_result(ch_sel, data,  valid_byte, crc); //check deframer
    if(uut.u_deframer.data_valid != 0 ) 
      crc_check(ch_sel,data,valid_byte,crc);   //check crc


    #100;//延时等数据
    // Read from FIFO to trigger output
    @(posedge clk_out);
    read_en = 1;
    @(posedge clk_out);
    read_en = 0;
   #1; 
	//Calculate expected Gray code
//	reg [127:0] gray_data;
    gray_data = uut.u_serial_output.gray_data; //调用gray_data 内部信号
	                                                                   
	//calculate_expected_gray({data,ch_sel}, gray_data , compare_ok);//
  #2;
  //verify_serial_output(ch_sel,gray_data);

endtask

//// uncomment this code if you want to generate waves
initial
begin
   $fsdbAutoSwitchDumpfile(1024, "top_tb.fsdb",0);
   $fsdbDumpfile("top_tb.fsdb");
   $fsdbDumpvars(0, top_tb, "+all");
end






endmodule

