module deframer (  

    input               clk_in,

    input               rst_n,

    input [15:0]        data_in,

    input               data_in_valid,

    

    output reg [127:0]  data,

    output reg [7:0]    ch_sel,

    output reg [15:0]   crc,

    output reg [4:0]    data_valid

);



typedef enum logic [3:0] {

    IDLE    = 4'd0,

    HEAD_1  = 4'd1,

    HEAD_2  = 4'd2,

    CH_SEL  = 4'd3,

    DATA    = 4'd4,

    TAIL_1  = 4'd5,

    TAIL_2  = 4'd6,

    DONE    = 4'd7,

    ERROR   = 4'd8

} state_t;



state_t current_state, next_state;





localparam TIMEOUT_MAX = 3'd5;

reg [15:0] data_buffer [0:8];   // ???? 9 ???? CRC?

reg [15:0] data_buffer_next [0:8];

reg [3:0]  data_count;

reg [4:0]  valid_bytes;

reg [7:0]    ch_sel_r;

reg [7:0]    ch_sel_r_next;

//reg [4:0]  payload_bytes;

reg [4:0]  payload_bytes_next;

reg        potential_tail;      // ??????TAIL??

reg        is_real_tail;        // ???????????????

reg	[2:0]	timeout_counter;

integer i;



// === payload_bytes_next ?????? ===

always @(*) begin

    if (valid_bytes >= 5'd2)

        payload_bytes_next = valid_bytes - 5'd2;  // ??2???CRC 

    else

        payload_bytes_next = 5'd0;

end





always @(*) begin

	ch_sel_r_next = ch_sel_r;

	if(current_state == HEAD_2 && data_in_valid)

	ch_sel_r_next = data_in[15:8];

end



always @(posedge clk_in or negedge rst_n ) begin

	if(!rst_n)begin

		ch_sel_r <= 8'b0;

		for ( i = 0;i < 9; i=i+1)

		data_buffer_next[i] <= 16'b0;

	end else begin

		ch_sel_r <= ch_sel_r_next;

		for (i = 0; i < 9;i=i+1)

		data_buffer[i] <= data_buffer_next[i];

end

end



//integer i;

always @(*) begin

	for ( i = 0; i<9;i = i+ 1)

	data_buffer_next[i] = data_buffer[i];	

	if (current_state == CH_SEL && data_in_valid && data_in != 16'h0e0e) begin

	    data_buffer_next[0] = data_in;

	end

	if(current_state == DATA && data_in_valid && data_in != 16'h0e0e && data_count < 9) begin

	    data_buffer_next[data_count] = data_in;

	end

	//TAIL_1:weishuju+data

	if (current_state == TAIL_1 && data_in_valid && data_in != 16'h0e0e && data_count <= 7) begin

	    data_buffer_next[data_count] = 16'h0e0e;

	    data_buffer_next[data_count + 1] = data_in;

	end

end





always @(*) begin

    // 默认值（防止 latch）

    data = 128'd0;

    crc = 16'd0;

    ch_sel = 8'd0;

    data_valid = 5'd0;



    if (current_state == TAIL_2 && is_real_tail) begin

        data_valid = payload_bytes_next + 2;

        ch_sel = ch_sel_r;

        crc = data_buffer[data_count];



        case (data_count)

            8: data = {data_buffer[7], data_buffer[6], data_buffer[5], data_buffer[4], 
                       data_buffer[3], data_buffer[2], data_buffer[1], data_buffer[0]};
            7: data = {16'b0,data_buffer[6], data_buffer[5], data_buffer[4], data_buffer[3],
                       data_buffer[2], data_buffer[1], data_buffer[0]};
            6: data = {32'b0,data_buffer[5], data_buffer[4], data_buffer[3], data_buffer[2],
                       data_buffer[1], data_buffer[0]};
            5: data = {48'b0,data_buffer[4], data_buffer[3], data_buffer[2], data_buffer[1],
                       data_buffer[0]};
            4: data = {64'b0,data_buffer[3], data_buffer[2], data_buffer[1], data_buffer[0]};
            3: data = {80'b0,data_buffer[2], data_buffer[1], data_buffer[0]};
            2: data = {96'b0,data_buffer[1], data_buffer[0]};
            1: data = {112'b0,data_buffer[0]};

            default: data = 128'b0;

        endcase

    end

end

	









// === ????? ===

always @(posedge clk_in or negedge rst_n) begin

    if (!rst_n) begin

        current_state <= IDLE;

        potential_tail <= 1'b0;

        is_real_tail <= 1'b0;

		timeout_counter <= 3'd0;

    end else begin

        current_state <= next_state;

		//???????

        if (current_state != next_state) begin

            // ??????????

            timeout_counter <= 3'd0;

        end else if (!data_in_valid && (current_state inside {HEAD_1, HEAD_2, CH_SEL, DATA, TAIL_1, TAIL_2})) begin

            // ???????????????????????

            if (timeout_counter < TIMEOUT_MAX)

                timeout_counter <= timeout_counter + 1;

        end		

        

        // ????

        if (next_state == IDLE) begin

            potential_tail <= 1'b0;

            is_real_tail <= 1'b0;

        end

        

        // ?DATA?????0E0E???potential_tail

	potential_tail <= (current_state == DATA) && data_in_valid &&( data_in == 16'h0e0e);

            

        // ?TAIL_2??????????

	is_real_tail <= (next_state ==TAIL_2) && (data_count >= 4'd1) && (data_count <= 4'd8);

    end

end

// === ?????? ===

always @(*) begin

    case (current_state)

        IDLE: begin

            next_state = (data_in_valid && data_in == 16'he0e0) ? HEAD_1 : IDLE;

        end



        HEAD_1: begin

			if (timeout_counter == 3'd5)

				next_state = IDLE;

			else

            next_state = (data_in_valid && data_in == 16'he0e0) ? HEAD_2 : IDLE;

        end



        HEAD_2: begin

			if (timeout_counter == 3'd5)

				next_state = IDLE;

            next_state = (data_in_valid && (^data_in[15:8]) == 1'b1) ? CH_SEL : IDLE;

        end



        CH_SEL: begin

			if (timeout_counter == 3'd5)

				next_state = IDLE; 

            next_state = data_in_valid ? ((data_in == 16'h0e0e) ? TAIL_1 : DATA) : CH_SEL;

        end



        DATA: begin

		   if (timeout_counter == 3'd5)

                next_state = IDLE;

           else if (data_in_valid) begin

                if (data_in == 16'h0e0e)

                    next_state = TAIL_1;  // ??????TAIL??

                else

                    next_state = DATA;

            end else begin

                next_state = DATA;

            end

        end



        TAIL_1: begin

		   if (timeout_counter == 3'd5)

				next_state = IDLE;

           else if (data_in_valid) begin

                if (data_in == 16'h0e0e)

                    next_state = TAIL_2;  // ??????TAIL

                else

                    next_state = DATA;    // ??TAIL??????0E0E???

            end else begin

                next_state = TAIL_1;

            end

        end



        TAIL_2: begin



            // ???????????????payload_bytes_next

   //         if (is_real_tail && (data_count < 5'd1 || data_count > 5'd8))

	   if(is_real_tail) begin 	     

           next_state = DONE;

           end else begin

                next_state = IDLE;

        	end

	end



        DONE: begin

            next_state = IDLE;

        end



        default: begin

            next_state = IDLE;

        end

    endcase

end



// === ????????? ===

always @(posedge clk_in or negedge rst_n) begin

    if (!rst_n) begin

        data <= 128'b0;

        ch_sel <= 8'b0;

	ch_sel_r <= 8'b0;

        crc <= 16'b0;

        data_valid <= 5'd0;

        valid_bytes <= 5'd0;

 //      payload_bytes <= 5'd0;

        data_count <= 4'd0;

        for (integer i = 0; i < 9; i = i + 1)

            data_buffer[i] <= 16'b0;

    end else begin

        case (current_state)

            IDLE: begin

                data_valid <= 5'd0;

                valid_bytes <= 5'd0;

    //            payload_bytes <= 5'd0;

                data_count <= 4'd0;

				data <= 128'd0;

            end

            CH_SEL: begin

                if (data_in_valid && data_in != 16'h0e0e) begin

                     data_count <= 4'd1;

                    valid_bytes <= 5'd2;

                end else if (data_in_valid && data_in == 16'h0e0e) begin

                    valid_bytes <= 5'd0;

                end

            end

            DATA: begin

                if (data_in_valid && data_in != 16'h0e0e && data_count < 9) begin

                    data_count <= data_count + 1;

                    valid_bytes <= valid_bytes + 2;

                end

            end





            DONE: begin

           //     data_valid <= payload_bytes;

                data_count <= 4'd0;

                valid_bytes <= 5'd0;

                data_valid <= 5'd0;

		data <=  128'b0;

            end



        endcase

    end

end



endmodule




