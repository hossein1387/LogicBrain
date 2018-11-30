`default_nettype wire

module neuralcore
    #(
        parameter DATA_WIDTH           = 8,
        parameter DATA_ADDR_WIDTH      = 10,
        parameter IMAGE_ROW_LEN        = 32,
        parameter IMAGE_COL_LEN        = 32,
        parameter KERNEL_SIZE          = 3,
        parameter STRIDE               = 1,
        parameter NUM_NEURONS_L1       = 1024,
        parameter NUM_NEURONS_L2       = 64,
        parameter NUM_NEURONS_L3       = 10,
        parameter NUM_OUTPUT_CLASSES   = 10,
        parameter INPUT_DATA_WIDTH_L1  = 256,
        parameter INPUT_DATA_WIDTH_L2  = 1024,
        parameter INPUT_DATA_WIDTH_L3  = 64,
        parameter OUTPUT_DATA_WIDTH    = 10,
        parameter WEIGHT_DATA_WIDTH    = 2,
        parameter WEIGHT_DATA_WIDTH_L1 = INPUT_DATA_WIDTH_L1*WEIGHT_DATA_WIDTH,
        parameter WEIGHT_DATA_WIDTH_L2 = INPUT_DATA_WIDTH_L2*WEIGHT_DATA_WIDTH,
        parameter WEIGHT_DATA_WIDTH_L3 = INPUT_DATA_WIDTH_L3*WEIGHT_DATA_WIDTH,
        parameter WEIGHT_ADDR_WIDTH_L1 = $clog2(INPUT_DATA_WIDTH_L1*INPUT_DATA_WIDTH_L2+1),
        parameter WEIGHT_ADDR_WIDTH_L2 = $clog2(INPUT_DATA_WIDTH_L2*INPUT_DATA_WIDTH_L3+1),
        parameter WEIGHT_ADDR_WIDTH_L3 = $clog2(INPUT_DATA_WIDTH_L3*NUM_OUTPUT_CLASSES+1),
        parameter BIAS_DATA_WIDTH      = 2,
        parameter BIAS_DATA_WIDTH_L1   = BIAS_DATA_WIDTH,
        parameter BIAS_DATA_WIDTH_L2   = BIAS_DATA_WIDTH,
        parameter BIAS_DATA_WIDTH_L3   = BIAS_DATA_WIDTH,
        parameter BIAS_ADDR_WIDTH_L1   = $clog2(INPUT_DATA_WIDTH_L2+1),
        parameter BIAS_ADDR_WIDTH_L2   = $clog2(INPUT_DATA_WIDTH_L3+1),
        parameter BIAS_ADDR_WIDTH_L3   = $clog2(NUM_OUTPUT_CLASSES+1)
    )
    (
        input  logic clk,
        input  logic rst,

        // Window Slider interface
        input  logic                              ws_start     ,
        output logic [DATA_ADDR_WIDTH-1 : 0]      ws_ram_r_addr,
        input  logic [DATA_WIDTH-1      : 0]      ws_ram_r_data,
        output logic                              ws_ram_r_wen ,

        // Controller Interface
        input  logic [WEIGHT_DATA_WIDTH_L1-1 : 0] weight_data_l1,
        output logic [WEIGHT_ADDR_WIDTH_L1-1 : 0] weight_addr_l1,
        output logic                              weight_ren_l1 ,
        input  logic [BIAS_DATA_WIDTH_L1-1   : 0] bias_data_l1  ,
        output logic [BIAS_ADDR_WIDTH_L1-1   : 0] bias_addr_l1  ,
        output logic                              bias_ren_l1   ,

        input  logic [WEIGHT_DATA_WIDTH_L2-1 : 0] weight_data_l2,
        output logic [WEIGHT_ADDR_WIDTH_L2-1 : 0] weight_addr_l2,
        output logic                              weight_ren_l2 ,
        input  logic [BIAS_DATA_WIDTH_L2-1   : 0] bias_data_l2  ,
        output logic [BIAS_ADDR_WIDTH_L2-1   : 0] bias_addr_l2  ,
        output logic bias_ren_l2   ,

        input  logic [WEIGHT_DATA_WIDTH_L3-1 : 0] weight_data_l3,
        output logic [WEIGHT_ADDR_WIDTH_L3-1 : 0] weight_addr_l3,
        output logic weight_ren_l3 ,
        input  logic [BIAS_DATA_WIDTH_L3-1   : 0] bias_data_l3  ,
        output logic [BIAS_ADDR_WIDTH_L3-1   : 0] bias_addr_l3  ,
        output logic bias_ren_l3   ,

        // CalculUnit Interface
        output logic [OUTPUT_DATA_WIDTH-1    : 0] calcOutput,
        output logic                              done
    );

    logic [KERNEL_SIZE*KERNEL_SIZE-1:0] image_window;
    logic ws_valid, valid_1, valid_2, valid_3;
    logic [WEIGHT_DATA_WIDTH_L1-1 : 0] weight_out_l1;
    logic [WEIGHT_DATA_WIDTH_L2-1 : 0] weight_out_l2;
    logic [WEIGHT_DATA_WIDTH_L3-1 : 0] weight_out_l3;
    logic   [BIAS_DATA_WIDTH_L1-1 : 0] bias_out_l1;
    logic   [BIAS_DATA_WIDTH_L2-1 : 0] bias_out_l2;
    logic   [BIAS_DATA_WIDTH_L3-1 : 0] bias_out_l3;


    window_slide_wrapper #  (
                                .DATA_WIDTH     (DATA_WIDTH     ),
                                .DATA_ADDR_WIDTH(DATA_ADDR_WIDTH),
                                .IMAGE_ROW_LEN  (IMAGE_ROW_LEN  ),
                                .IMAGE_COL_LEN  (IMAGE_COL_LEN  ),
                                .KERNEL_SIZE    (KERNEL_SIZE    ),
                                .STRIDE         (STRIDE         )
                            )
    window_slide_wrapper_inst(
                                .clk       (clk          ),
                                .rst       (rst          ),
                                .ram_r_addr(ws_ram_r_addr),
                                .ram_r_data(ws_ram_r_data),
                                .ram_r_wen (ws_ram_r_wen ),
                                .start     (ws_start     ),
                                .slide     (valid_3      ),
                                .y_out     (image_window ),
                                .valid     (ws_valid     )
                            );

    controller#(
                                .NUM_NEURONS_L1      (NUM_NEURONS_L1      ), 
                                .NUM_NEURONS_L2      (NUM_NEURONS_L2      ), 
                                .NUM_NEURONS_L3      (NUM_NEURONS_L3      ), 
                                .WEIGHT_DATA_WIDTH_L1(WEIGHT_DATA_WIDTH_L1), 
                                .WEIGHT_DATA_WIDTH_L2(WEIGHT_DATA_WIDTH_L2), 
                                .WEIGHT_DATA_WIDTH_L3(WEIGHT_DATA_WIDTH_L3), 
                                .WEIGHT_ADDR_WIDTH_L1(WEIGHT_ADDR_WIDTH_L1), 
                                .WEIGHT_ADDR_WIDTH_L2(WEIGHT_ADDR_WIDTH_L2), 
                                .WEIGHT_ADDR_WIDTH_L3(WEIGHT_ADDR_WIDTH_L3), 
                                .BIAS_DATA_WIDTH_L1  (BIAS_DATA_WIDTH_L1  ), 
                                .BIAS_DATA_WIDTH_L2  (BIAS_DATA_WIDTH_L2  ), 
                                .BIAS_DATA_WIDTH_L3  (BIAS_DATA_WIDTH_L3  ), 
                                .BIAS_ADDR_WIDTH_L1  (BIAS_ADDR_WIDTH_L1  ), 
                                .BIAS_ADDR_WIDTH_L2  (BIAS_ADDR_WIDTH_L2  ), 
                                .BIAS_ADDR_WIDTH_L3  (BIAS_ADDR_WIDTH_L3  ) 
                )
    controller_inst (
                                .clk           (clk            ),
                                .rst           (rst            ),
                                .start         (ws_valid       ),
                                .valid_1       (valid_1        ),
                                .valid_2       (valid_2        ),
                                .weight_data_l1(weight_data_l1 ),
                                .weight_addr_l1(weight_addr_l1 ),
                                .weight_ren_l1 (weight_ren_l1  ),
                                .weight_out_l1 (weight_out_l1  ),
                                .bias_data_l1  (bias_data_l1   ),
                                .bias_addr_l1  (bias_addr_l1   ),
                                .bias_ren_l1   (bias_ren_l1    ),
                                .bias_out_l1   (bias_out_l1    ),
                                .weight_data_l2(weight_data_l2 ),
                                .weight_addr_l2(weight_addr_l2 ),
                                .weight_ren_l2 (weight_ren_l2  ),
                                .weight_out_l2 (weight_out_l2  ),
                                .bias_data_l2  (bias_data_l2   ),
                                .bias_addr_l2  (bias_addr_l2   ),
                                .bias_ren_l2   (bias_ren_l2    ),
                                .bias_out_l2   (bias_out_l2    ),
                                .weight_data_l3(weight_data_l3 ),
                                .weight_addr_l3(weight_addr_l3 ),
                                .weight_ren_l3 (weight_ren_l3  ),
                                .weight_out_l3 (weight_out_l3  ),
                                .bias_data_l3  (bias_data_l3   ),
                                .bias_addr_l3  (bias_addr_l3   ),
                                .bias_ren_l3   (bias_ren_l3    ),
                                .bias_out_l3   (bias_out_l3    )
                    );
    CalculatorUnit CalculatorUnit_inst
                    (
                                .clk           (clk          ),
                                .reset         (~rst         ),
                                .start         (ws_valid     ),
                                .I1            (image_window ),
                                .W1            (weight_out_l1),
                                .b1            (bias_out_l1  ),
                                .W2            (weight_out_l2),
                                .b2            (bias_out_l2  ),
                                .W3            (weight_out_l3),
                                .b3            (bias_out_l3  ),
                                .valid_1       (valid_1      ),
                                .valid_2       (valid_2      ),
                                .valid_3       (valid_3      ),
                                .calcOutput    (calcOutput   )
                    );

    assign done = valid_3;

endmodule
