//==============================================================================
// Max pooling core
//
// This is a behavioral description of a Max Pooling core. This module performs
// maxpooling on the input image of any length. 
//
// @params:
// x_in: Input vector 
// y_out: Output vector contains the result of shift
//==============================================================================
`default_nettype none

module max_pool
    #(
    parameter INPUT_WIDTH  = 16,
    parameter OUTPUT_WIDTH = INPUT_WIDTH,
    parameter IMAGE_ROW_LEN= 32,
    parameter KERNEL_SIZE  = 3,
    parameter STRIDE       = 1
    )
    (
        input  wire clk,
        input  wire rst,
        input  wire new_image,
        input  wire [INPUT_WIDTH-1  : 0 ]x_in,
        output wire [OUTPUT_WIDTH-1 : 0 ]y_out,
        output wire output_valid,
        output reg  done,
        output wire busy
    );  
    localparam IMAGE_SIZE         = IMAGE_ROW_LEN*IMAGE_ROW_LEN;
    localparam PIPELINE_PIXEL_MAX = IMAGE_ROW_LEN*(KERNEL_SIZE-1) + KERNEL_SIZE;
`ifdef USING_KERNEL_2
    wire [INPUT_WIDTH-1 : 0 ] lbuf_out;
`else 
    wire [INPUT_WIDTH-1 : 0 ] lbuf_out  [KERNEL_SIZE-2:0];
`endif
    wire [INPUT_WIDTH-1 : 0 ] max_out;
    reg  [INPUT_WIDTH-1 : 0 ] x_buf     [KERNEL_SIZE*KERNEL_SIZE-1:0];

// Signals to detect image boundary
    wire                    pipeline_full;
    reg                     new_image_line;
    reg [31:0]              pixel_cnt, col_pixel_cnt, row_pixel_cnt;
// Signals to detect correct stride
    reg                     col_stride_ok;
    reg                     row_stride_ok;
    reg [31:0]              col_stride_cnt;
    reg [31:0]              row_stride_cnt;
//==================================================================================================
     array_max_find#(.INPUT_WIDTH(INPUT_WIDTH),
                     .NUM_ELEMENTS(KERNEL_SIZE*KERNEL_SIZE))
     array_max_find_inst(x_buf, max_out);
//==================================================================================================
// Circuit to instantiate line buffers based on the kernel size
`ifdef USING_KERNEL_2
     line_buffer #(.INPUT_WIDTH (INPUT_WIDTH ),
                   .DEPTH_SIZE  (IMAGE_ROW_LEN-KERNEL_SIZE))
     line_buffer_inst1(.clk(clk), .rst(rst), .x_in(x_buf[KERNEL_SIZE-1]), .y_out(lbuf_out));
`else 
    genvar lbf_cnt;
    generate
        // line buffer builder
        for ( lbf_cnt = 0; lbf_cnt < KERNEL_SIZE-1; lbf_cnt++) begin
            line_buffer #(.INPUT_WIDTH (INPUT_WIDTH ),
                          .DEPTH_SIZE  (IMAGE_ROW_LEN-KERNEL_SIZE))
            line_buffer_inst1(.clk(clk), .rst(rst), .x_in(x_buf[(lbf_cnt+1)*KERNEL_SIZE-1]), .y_out(lbuf_out[lbf_cnt]));
        end
    endgenerate
`endif

//==================================================================================================
// Circuit to buffer input
    always_ff @(posedge clk) begin
        if(~rst) begin
            for (int i=0; i< KERNEL_SIZE*KERNEL_SIZE; i++) begin
                x_buf[i] <= {OUTPUT_WIDTH{1'b0}};
            end
        end else begin
            //x_in_reg <= x_in;
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
            if(new_image==1'b1) begin
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
        end
        if(col_stride_cnt==col_pixel_cnt) begin
            if (col_stride_cnt + STRIDE > IMAGE_ROW_LEN) begin
                col_stride_cnt <= KERNEL_SIZE;
            end else begin
                col_stride_cnt <= col_stride_cnt + STRIDE;
            end
        end
        if (col_pixel_cnt == IMAGE_ROW_LEN) begin
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
        new_image_line<= (col_pixel_cnt == IMAGE_ROW_LEN)? 1'b1 : 1'b0;
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
    assign output_valid  = pipeline_full & col_stride_ok & row_stride_ok & (pixel_cnt<=IMAGE_SIZE+1);

    // Circuit to find maximum number in an array
    assign y_out = max_out;

endmodule


//==================================================================================================
// A module to find the maximum value within an array of size NUM_ELEMENTS
//==================================================================================================
module array_max_find 
    #(
    parameter INPUT_WIDTH  = 16,
    parameter OUTPUT_WIDTH = INPUT_WIDTH,
    parameter NUM_ELEMENTS = 9
    )
    (
    input  wire signed [INPUT_WIDTH-1 : 0 ] x_in[NUM_ELEMENTS-1:0],
    output wire signed [OUTPUT_WIDTH-1 : 0 ] y_out
    );
    logic signed [OUTPUT_WIDTH-1 : 0 ] arry_max_res[NUM_ELEMENTS-2:0];
    genvar ss_cnt;
    generate
        for ( ss_cnt = 1; ss_cnt < NUM_ELEMENTS-1; ss_cnt++) begin
            assign arry_max_res[ss_cnt] = (arry_max_res[ss_cnt-1] > x_in[ss_cnt+1]) ? arry_max_res[ss_cnt-1] : x_in[ss_cnt+1];
        end
    endgenerate

    assign arry_max_res[0] = (x_in[0] > x_in[1]) ? x_in[0] : x_in[1];
    assign y_out = arry_max_res[NUM_ELEMENTS-2];

endmodule
