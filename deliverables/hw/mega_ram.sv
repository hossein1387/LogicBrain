`default_nettype wire

module mega_ram
    #(
        parameter DATA_WIDTH           = 8,
        parameter DATA_ADDR_WIDTH      = 10,
        parameter NUM_OUTPUT_CLASSES   = 10,
        parameter INPUT_DATA_WIDTH_L1  = 256,
        parameter INPUT_DATA_WIDTH_L2  = 1024,
        parameter INPUT_DATA_WIDTH_L3  = 64,
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

        output logic           [DATA_WIDTH-1 : 0] ws_ram_r_data ,
        input  logic      [DATA_ADDR_WIDTH-1 : 0] ws_ram_r_addr ,
        input  logic                              ws_ram_r_wen  ,
        input  logic      [DATA_ADDR_WIDTH-1 : 0] ws_ram_w_addr ,
        input  logic           [DATA_WIDTH-1 : 0] ws_ram_w_data ,
        input  logic                              ws_ram_w_wen  ,

        output logic [WEIGHT_DATA_WIDTH_L1-1 : 0] weight_r_data_l1,
        input  logic [WEIGHT_ADDR_WIDTH_L1-1 : 0] weight_r_addr_l1,
        input  logic                              weight_r_ren_l1 ,
        input  logic [WEIGHT_DATA_WIDTH_L1-1 : 0] weight_w_data_l1,
        input  logic [WEIGHT_ADDR_WIDTH_L1-1 : 0] weight_w_addr_l1,
        input  logic                              weight_w_ren_l1 ,

        output logic   [BIAS_DATA_WIDTH_L1-1 : 0] bias_r_data_l1  ,
        input  logic   [BIAS_ADDR_WIDTH_L1-1 : 0] bias_r_addr_l1  ,
        input  logic                              bias_r_ren_l1   ,
        input  logic   [BIAS_DATA_WIDTH_L1-1 : 0] bias_w_data_l1  ,
        input  logic   [BIAS_ADDR_WIDTH_L1-1 : 0] bias_w_addr_l1  ,
        input  logic                              bias_w_ren_l1   ,

        output logic [WEIGHT_DATA_WIDTH_L2-1 : 0] weight_r_data_l2,
        input  logic [WEIGHT_ADDR_WIDTH_L2-1 : 0] weight_r_addr_l2,
        input  logic                              weight_r_ren_l2 ,
        input  logic [WEIGHT_DATA_WIDTH_L2-1 : 0] weight_w_data_l2,
        input  logic [WEIGHT_ADDR_WIDTH_L2-1 : 0] weight_w_addr_l2,
        input  logic                              weight_w_ren_l2 ,

        output logic   [BIAS_DATA_WIDTH_L2-1 : 0] bias_r_data_l2  ,
        input  logic   [BIAS_ADDR_WIDTH_L2-1 : 0] bias_r_addr_l2  ,
        input  logic                              bias_r_ren_l2   ,
        input  logic   [BIAS_DATA_WIDTH_L2-1 : 0] bias_w_data_l2  ,
        input  logic   [BIAS_ADDR_WIDTH_L2-1 : 0] bias_w_addr_l2  ,
        input  logic                              bias_w_ren_l2   ,

        output logic [WEIGHT_DATA_WIDTH_L3-1 : 0] weight_r_data_l3,
        input  logic [WEIGHT_ADDR_WIDTH_L3-1 : 0] weight_r_addr_l3,
        input  logic                              weight_r_ren_l3 ,
        input  logic [WEIGHT_DATA_WIDTH_L3-1 : 0] weight_w_data_l3,
        input  logic [WEIGHT_ADDR_WIDTH_L3-1 : 0] weight_w_addr_l3,
        input  logic                              weight_w_ren_l3 ,


        output logic   [BIAS_DATA_WIDTH_L3-1 : 0] bias_r_data_l3  ,
        input  logic   [BIAS_ADDR_WIDTH_L3-1 : 0] bias_r_addr_l3  ,
        input  logic                              bias_r_ren_l3   ,
        input  logic   [BIAS_DATA_WIDTH_L3-1 : 0] bias_w_data_l3  ,
        input  logic   [BIAS_ADDR_WIDTH_L3-1 : 0] bias_w_addr_l3  ,
        input  logic                              bias_w_ren_l3   

    );

    true_d2port_ram #(
                        .D_WIDTH    (DATA_WIDTH     ),
                        .ADDR_WIDTH (DATA_ADDR_WIDTH)
                    )
    image_ram_inst     (
                        .clk        (clk),
                        .we_a       (ws_ram_w_wen),
                        .data_a     (ws_ram_w_data),
                        .addr_a     (ws_ram_w_addr),
                        .we_b       (~ws_ram_r_wen),
                        .addr_b     (ws_ram_r_addr),
                        .db_out     (ws_ram_r_data)
                    );

    true_d2port_ram #(
                        .D_WIDTH    (WEIGHT_DATA_WIDTH_L1),
                        .ADDR_WIDTH (WEIGHT_ADDR_WIDTH_L1)
                    )
    w1_ram_inst     (
                        .clk        (clk),
                        .we_a       (weight_w_ren_l1),
                        .data_a     (weight_w_data_l1),
                        .addr_a     (weight_w_addr_l1),
                        .we_b       (~weight_r_ren_l1),
                        .addr_b     (weight_r_addr_l1),
                        .db_out     (weight_r_data_l1)
                    );

    true_d2port_ram #(
                        .D_WIDTH    (WEIGHT_DATA_WIDTH_L2),
                        .ADDR_WIDTH (WEIGHT_ADDR_WIDTH_L2)
                    )
    w2_ram_inst     (
                        .clk        (clk),
                        .we_a       (weight_w_ren_l2),
                        .data_a     (weight_w_data_l2),
                        .addr_a     (weight_w_addr_l2),
                        .we_b       (~weight_r_ren_l2),
                        .addr_b     (weight_r_addr_l2),
                        .db_out     (weight_r_data_l2)
                    );

    true_d2port_ram #(
                        .D_WIDTH    (WEIGHT_DATA_WIDTH_L3),
                        .ADDR_WIDTH (WEIGHT_ADDR_WIDTH_L3)
                    )
    w3_ram_inst     (
                        .clk        (clk),
                        .we_a       (weight_w_ren_l3),
                        .data_a     (weight_w_data_l3),
                        .addr_a     (weight_w_addr_l3),
                        .we_b       (~weight_r_ren_l3),
                        .addr_b     (weight_r_addr_l3),
                        .db_out     (weight_r_data_l3)
                    );

    true_d2port_ram #(
                        .D_WIDTH    (BIAS_DATA_WIDTH_L1),
                        .ADDR_WIDTH (BIAS_ADDR_WIDTH_L1)
                    )
    b1_ram_inst     (
                        .clk        (clk),
                        .we_a       (bias_w_ren_l1),
                        .data_a     (bias_w_data_l1),
                        .addr_a     (bias_w_addr_l1),
                        .we_b       (~bias_r_ren_l1),
                        .addr_b     (bias_r_addr_l1),
                        .db_out     (bias_r_data_l1)
                    );

    true_d2port_ram #(
                        .D_WIDTH    (BIAS_DATA_WIDTH_L2),
                        .ADDR_WIDTH (BIAS_ADDR_WIDTH_L2)
                    )
    b2_ram_inst     (
                        .clk        (clk),
                        .we_a       (bias_w_ren_l2),
                        .data_a     (bias_w_data_l2),
                        .addr_a     (bias_w_addr_l2),
                        .we_b       (~bias_r_ren_l2),
                        .addr_b     (bias_r_addr_l2),
                        .db_out     (bias_r_data_l2)
                    );


    true_d2port_ram #(
                        .D_WIDTH    (BIAS_DATA_WIDTH_L3),
                        .ADDR_WIDTH (BIAS_ADDR_WIDTH_L3)
                    )
    b3_ram_inst     (
                        .clk        (clk),
                        .we_a       (bias_w_ren_l3),
                        .data_a     (bias_w_data_l3),
                        .addr_a     (bias_w_addr_l3),
                        .we_b       (~bias_r_ren_l3),
                        .addr_b     (bias_r_addr_l3),
                        .db_out     (bias_r_data_l3)
                    );

endmodule // mega_ram