module window_slide_wrapper
    #(
        parameter DATA_WIDTH      = 8,
        parameter DATA_ADDR_WIDTH = 10,
        parameter IMAGE_ROW_LEN   = 32,
        parameter IMAGE_COL_LEN   = 32,
        parameter KERNEL_SIZE     = 3,
        parameter STRIDE          = 1
    )
    (
        // clock and reset
        input  logic clk,
        input  logic rst,
        // ram interface
        output logic [DATA_ADDR_WIDTH-1 : 0] ram_r_addr,
        input  logic [DATA_WIDTH-1      : 0] ram_r_data,
        output logic ram_r_wen,
        // control signals
        input  logic start,
        input  logic slide,
        //output signals
        output logic y_out[KERNEL_SIZE*KERNEL_SIZE-1:0],
        output logic valid
    );  
    logic pipeline_full, ws_clk, busy, ws_done, ws_valid, done;
    // logic ws_clk_en;
    // RAM control signals

    // ASM variables
    typedef enum logic[5:0] {IDLE, CLOCK_WS, WAIT_FOR_PIPELINE_FULL, WAIT_FOR_SLIDE, WAIT_FOR_VALID} trans_state_t;
    trans_state_t next_state, ret_state;

    window_slide #  (    
                        .IMAGE_ROW_LEN(IMAGE_ROW_LEN),
                        .IMAGE_COL_LEN(IMAGE_COL_LEN),
                        .KERNEL_SIZE  (KERNEL_SIZE  ),
                        .STRIDE       (STRIDE       )
                    )
    window_slide_inst( .clk(ws_clk),
                       .rst(rst),
                       .start(start),
                       .x_in(ram_r_data[0]),
                       .y_out(y_out),
                       .valid_w(ws_valid),
                       .done(ws_done),
                       .pipeline_full(pipeline_full),
                       .busy(busy));


    always_ff @(posedge clk) begin
        if(~rst) begin
            next_state   <= IDLE;
            ws_clk       <= 1'b0;
            ram_r_addr <= 0;
            ram_r_wen  <= 1'b0;
            done         <= 1'b0;
        end else begin
            case (next_state)
                IDLE : begin
                    if(start==1) begin
                        next_state   <= WAIT_FOR_PIPELINE_FULL;
                        ram_r_wen    <= 1'b1;
                        ram_r_addr   <= 0;
                        ws_clk       <= 1'b1;
                    end else begin
                        next_state <= IDLE;
                    end
                    done        <= 1'b0;
                end
                WAIT_FOR_PIPELINE_FULL : begin
                    if(pipeline_full==1'b1) begin
                        next_state <= CLOCK_WS;
                        ret_state  <= WAIT_FOR_SLIDE;
                        ws_clk     <= 1'b0;
                        done       <= 1'b1;
                    end else begin
                        ret_state   <= WAIT_FOR_PIPELINE_FULL;
                        next_state  <= CLOCK_WS;
                        ws_clk      <= 1'b0;
                    end
                end
                CLOCK_WS: begin
                    next_state  <= ret_state;
                    ws_clk      <= 1'b1;
                    ram_r_addr  <= ram_r_addr + 1;
                end
                WAIT_FOR_SLIDE : begin
                    if (ws_done==1'b1) begin
                        next_state <= IDLE;
                        ws_clk     <= 1'b0;
                        ram_r_addr <= 0;
                        ram_r_wen  <= 1'b0;
                    end else begin
                        if(slide==1'b1) begin
                            next_state <= WAIT_FOR_VALID;
                            ws_clk     <= 1'b0;
                        end else begin
                            ret_state  <= WAIT_FOR_SLIDE;
                            ws_clk     <= 1'b0;
                        end
                    end
                    done        <= 1'b0;
                end
                WAIT_FOR_VALID : begin
                    if(ws_valid==1'b1) begin
                        ret_state   <= WAIT_FOR_SLIDE;
                        next_state  <= CLOCK_WS;
                        ws_clk      <= 1'b0;
                        done        <= 1'b1;
                    end else begin
                        ret_state   <= WAIT_FOR_VALID;
                        next_state  <= CLOCK_WS;
                        ws_clk      <= 1'b0;
                        done        <= 1'b0;
                    end
                end
            endcase
        end
    end

    // always_ff @(posedge clk) begin
    //     $display("state=%d, start=%d\n", next_state, start);
    // end
    assign valid = clk & ws_clk & done;

endmodule
