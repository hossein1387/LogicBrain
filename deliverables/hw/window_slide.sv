`default_nettype wire

module window_slide
    #(
    parameter IMAGE_ROW_LEN= 32,
    parameter IMAGE_COL_LEN= 32,
    parameter KERNEL_SIZE  = 3,
    parameter STRIDE       = 1
    )
    (
        input  logic clk,
        input  logic rst,
        input  logic start,
        input  logic x_in,
        output logic [KERNEL_SIZE*KERNEL_SIZE-1:0] y_out,
        output logic valid_w,
        output logic done,
        output logic pipeline_full,
        output logic busy
    );  
    localparam IMAGE_SIZE         = IMAGE_ROW_LEN*IMAGE_COL_LEN;
    localparam PIPELINE_PIXEL_MAX = IMAGE_COL_LEN*(KERNEL_SIZE-1) + KERNEL_SIZE;
`ifdef USING_KERNEL_2
    wire lbuf_out;
`else 
    wire lbuf_out  [KERNEL_SIZE-2:0];
`endif
    reg  [KERNEL_SIZE*KERNEL_SIZE-1:0] x_buf;

// Signals to detect image boundary
    reg                     new_image_line;
    reg [31:0]              pixel_cnt, col_pixel_cnt, row_pixel_cnt;
// Signals to detect correct stride
    reg                     col_stride_ok;
    reg                     row_stride_ok;
    reg [31:0]              col_stride_cnt;
    reg [31:0]              row_stride_cnt;
//==================================================================================================
// Circuit to instantiate line buffers based on the kernel size
`ifdef USING_KERNEL_2
     line_buffer #( .DEPTH_SIZE  (IMAGE_COL_LEN-KERNEL_SIZE))
     line_buffer_inst(.clk(clk), .rst(rst), .x_in(x_buf[KERNEL_SIZE-1]), .y_out(lbuf_out));
`else 
    genvar lbf_cnt;
    generate
        // line buffer builder
        for ( lbf_cnt = 0; lbf_cnt < KERNEL_SIZE-1; lbf_cnt++) begin : line_buffer_element
            line_buffer #( .DEPTH_SIZE  (IMAGE_COL_LEN-KERNEL_SIZE))
            line_buffer_inst(.clk(clk), .rst(rst), .x_in(x_buf[(lbf_cnt+1)*KERNEL_SIZE-1]), .y_out(lbuf_out[lbf_cnt]));
        end
    endgenerate
`endif

//==================================================================================================
// Circuit to buffer input
    always_ff @(posedge clk) begin
        if(~rst) begin
            for (int i=0; i< KERNEL_SIZE*KERNEL_SIZE; i++) begin
                x_buf[i] <= 1'b0;
            end
        end else begin
`ifdef USING_KERNEL_2
            x_buf[0] <= x_in;
            for (int col=1; col< KERNEL_SIZE; col++) begin
                x_buf[col] <= x_buf[col-1];
            end
            x_buf[KERNEL_SIZE] <= lbuf_out;
            for (int col=1; col< KERNEL_SIZE; col++) begin
                x_buf[KERNEL_SIZE+col] <= x_buf[KERNEL_SIZE+col-1];
            end
`else
            x_buf[0] <= x_in;
            for (int col=1; col< KERNEL_SIZE; col++) begin
                x_buf[col] <= x_buf[col-1];
            end
            for (int k_cnt=0; k_cnt<KERNEL_SIZE-1; k_cnt++) begin
                x_buf[(k_cnt+1)*KERNEL_SIZE] <= lbuf_out[k_cnt];
                for (int col=1; col< KERNEL_SIZE; col++) begin
                    x_buf[(k_cnt+1)*KERNEL_SIZE+col] <= x_buf[(k_cnt+1)*KERNEL_SIZE+col-1];
                end
            end
`endif
        end
    end

//==================================================================================================
// Circuit to detect image boundary
    always_ff @(posedge clk or negedge rst) begin
        if(~rst) begin
            pixel_cnt <= {32{1'b1}};
            col_pixel_cnt <= 32'b1;
            row_pixel_cnt <= 32'b1;
            row_stride_cnt <= KERNEL_SIZE;
            col_stride_cnt <= KERNEL_SIZE;
        end else begin
            if(start==1'b1) begin
                pixel_cnt <= 32'b1;
            end else begin
                if(pixel_cnt + 1 < IMAGE_SIZE + 1 && pixel_cnt<{32{1'b1}}) begin
                    pixel_cnt     <= pixel_cnt + 1;
                    col_pixel_cnt <= col_pixel_cnt + 1;
                end else begin
                    pixel_cnt <= {32{1'b1}};
                    col_pixel_cnt <= 32'b1;
                    row_pixel_cnt <= 32'b1;
                    row_stride_cnt <= KERNEL_SIZE;
                    col_stride_cnt <= KERNEL_SIZE;
                end
            end
			  if(col_stride_cnt==col_pixel_cnt) begin
					if (col_stride_cnt + STRIDE > IMAGE_COL_LEN) begin
						 col_stride_cnt <= KERNEL_SIZE;
					end else begin
						 col_stride_cnt <= col_stride_cnt + STRIDE;
					end
			  end
			  if (col_pixel_cnt == IMAGE_COL_LEN) begin
					col_pixel_cnt  <= 32'b1;
					row_pixel_cnt  <= row_pixel_cnt + 1;
					if(row_stride_cnt==row_pixel_cnt) begin
						 row_stride_cnt <= row_stride_cnt + STRIDE;
					end
					if (row_pixel_cnt == IMAGE_ROW_LEN ) begin
						 row_pixel_cnt <= 32'b1;
					end
			  end
			  done          <= (pixel_cnt==IMAGE_SIZE) ? 1'b1 : 1'b0;
			  new_image_line<= (col_pixel_cnt == IMAGE_COL_LEN)? 1'b1 : 1'b0;
        end
    end


//==================================================================================================
// Circuit to detect correct strides
    assign row_stride_ok = (row_stride_cnt==row_pixel_cnt) ? 1'b1 : 1'b0;
    assign col_stride_ok = (col_stride_cnt==col_pixel_cnt) ? 1'b1 : 1'b0;

    // Signal to detect if accelerator is busy or not
    assign busy          = (pixel_cnt>0 && pixel_cnt<{32{1'b1}}) ? 1'b1 : 1'b0;
    // Detecting if pipeline is full or not
    assign pipeline_full = ((pixel_cnt>PIPELINE_PIXEL_MAX-1) & (pixel_cnt<=IMAGE_SIZE+1))? 1'b1 : 1'b0;
    // Circuit for signaling when output is valid
    assign valid_w  = pipeline_full & col_stride_ok & row_stride_ok & (pixel_cnt<=IMAGE_SIZE+1);

    assign y_out = x_buf;
endmodule
