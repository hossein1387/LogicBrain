`default_nettype wire

module controller
    #(
        parameter NUM_NEURONS_L1       = 1024,
        parameter NUM_NEURONS_L2       = 64,
        parameter NUM_NEURONS_L3       = 10,
        parameter WEIGHT_DATA_WIDTH_L1 = 512,
        parameter WEIGHT_DATA_WIDTH_L2 = 2048,
        parameter WEIGHT_DATA_WIDTH_L3 = 128,
        parameter WEIGHT_ADDR_WIDTH_L1 = 10,
        parameter WEIGHT_ADDR_WIDTH_L2 = 10,
        parameter WEIGHT_ADDR_WIDTH_L3 = 10,
        parameter BIAS_DATA_WIDTH_L1   = 2,
        parameter BIAS_DATA_WIDTH_L2   = 2,
        parameter BIAS_DATA_WIDTH_L3   = 2,
        parameter BIAS_ADDR_WIDTH_L1   = 10,
        parameter BIAS_ADDR_WIDTH_L2   = 10,
        parameter BIAS_ADDR_WIDTH_L3   = 10
    )
    (
        input  logic clk,
        input  logic rst,
        input  logic start,
        input  logic valid_1,
        input  logic valid_2,

        // Layer1
        // Weight
        input  logic [WEIGHT_DATA_WIDTH_L1-1 : 0] weight_data_l1,
        output logic [WEIGHT_ADDR_WIDTH_L1-1 : 0] weight_addr_l1,
        output logic                              weight_ren_l1,
        output logic [WEIGHT_DATA_WIDTH_L1-1 : 0] weight_out_l1,
        // Weight
        input  logic   [BIAS_DATA_WIDTH_L1-1 : 0] bias_data_l1,
        output logic   [BIAS_ADDR_WIDTH_L1-1 : 0] bias_addr_l1,
        output logic                              bias_ren_l1,
        output logic   [BIAS_DATA_WIDTH_L1-1 : 0] bias_out_l1,

        // Layer2
        // Weight
        input  logic [WEIGHT_DATA_WIDTH_L2-1 : 0] weight_data_l2,
        output logic [WEIGHT_ADDR_WIDTH_L2-1 : 0] weight_addr_l2,
        output logic                              weight_ren_l2,
        output logic [WEIGHT_DATA_WIDTH_L2-1 : 0] weight_out_l2,
        // Weight
        input  logic   [BIAS_DATA_WIDTH_L2-1 : 0] bias_data_l2,
        output logic   [BIAS_ADDR_WIDTH_L2-1 : 0] bias_addr_l2,
        output logic                              bias_ren_l2,
        output logic   [BIAS_DATA_WIDTH_L2-1 : 0] bias_out_l2,

        // Layer3
        // Weight
        input  logic [WEIGHT_DATA_WIDTH_L3-1 : 0] weight_data_l3,
        output logic [WEIGHT_ADDR_WIDTH_L3-1 : 0] weight_addr_l3,
        output logic                              weight_ren_l3,
        output logic [WEIGHT_DATA_WIDTH_L3-1 : 0] weight_out_l3,
        // Weight
        input  logic   [BIAS_DATA_WIDTH_L3-1 : 0] bias_data_l3,
        output logic   [BIAS_ADDR_WIDTH_L3-1 : 0] bias_addr_l3,
        output logic                              bias_ren_l3,
        output logic   [BIAS_DATA_WIDTH_L3-1 : 0] bias_out_l3
    );


    // ASM variables
    typedef enum logic[5:0] {IDLE, CALC_L1, CALC_L2, CALC_L3} trans_state_t;
    trans_state_t next_state;
    logic [31:0] neuron_cnt = 0;

    always_ff @(posedge clk) begin
        if(~rst) begin
            neuron_cnt    <= 0;
            next_state    <= IDLE;
            bias_ren_l1   <= 1'b0;
            bias_ren_l2   <= 1'b0;
            bias_ren_l3   <= 1'b0;
            weight_ren_l1 <= 1'b0;
            weight_ren_l2 <= 1'b0;
            weight_ren_l3 <= 1'b0;
            weight_addr_l1<= 0;
            weight_addr_l2<= 0;
            weight_addr_l3<= 0;
            bias_addr_l1  <= 0;
            bias_addr_l2  <= 0;
            bias_addr_l3  <= 0;
        end else begin
            case (next_state)
                IDLE : begin
                    if(start==1'b1) begin
                        next_state    <= CALC_L1;
                        neuron_cnt    <= 0;
                        bias_ren_l1   <= 1'b1;
                        weight_ren_l1 <= 1'b1;
                        bias_addr_l1  <= 0;
                        weight_addr_l1<= 0;
                    end else if (valid_1 == 1'b1) begin
                        next_state    <= CALC_L2;
                        neuron_cnt    <= 0;
                        bias_ren_l2   <= 1'b1;
                        weight_ren_l2 <= 1'b1;
                        bias_addr_l2  <= 0;
                        weight_addr_l2<= 0;
                    end else if (valid_2 == 1'b1) begin
                        next_state    <= CALC_L3;
                        neuron_cnt    <= 0;
                        bias_ren_l3   <= 1'b1;
                        weight_ren_l3 <= 1'b1;
                        bias_addr_l3  <= 0;
                        weight_addr_l3<= 0;
                    end else begin
                        next_state <= IDLE;
                    end
                end
                CALC_L1 : begin
                    if(neuron_cnt>NUM_NEURONS_L1) begin
                        next_state    <= IDLE;
                        bias_ren_l1   <= 1'b0;
                        weight_ren_l1 <= 1'b0;
                        bias_addr_l1  <= 0;
                        weight_addr_l1<= 0;
                        neuron_cnt    <= 0;
                    end else begin
                        next_state    <= CALC_L1;
                        bias_addr_l1  <= bias_addr_l1 + 1;
                        weight_addr_l1<= weight_addr_l1 + 1;
                        neuron_cnt    <= neuron_cnt + 1;
                    end
                end
                CALC_L2: begin
                    if(neuron_cnt>NUM_NEURONS_L2) begin
                        next_state    <= IDLE;
                        bias_ren_l2   <= 1'b0;
                        weight_ren_l2 <= 1'b0;
                        bias_addr_l2  <= 0;
                        weight_addr_l2<= 0;
                        neuron_cnt    <= 0;
                    end else begin
                        next_state <= CALC_L2;
                        bias_addr_l2  <= bias_addr_l2 + 1;
                        weight_addr_l2<= weight_addr_l2 + 1;
                        neuron_cnt    <= neuron_cnt + 1;
                    end
                end
                CALC_L3 : begin
                    if(neuron_cnt>NUM_NEURONS_L3) begin
                        next_state    <= IDLE;
                        bias_ren_l3   <= 1'b0;
                        weight_ren_l3 <= 1'b0;
                        bias_addr_l3  <= 0;
                        weight_addr_l3<= 0;
                        neuron_cnt    <= 0;
                    end else begin
                        next_state    <= CALC_L3;
                        bias_addr_l3  <= bias_addr_l3 + 1;
                        weight_addr_l3<= weight_addr_l3 + 1;
                        neuron_cnt    <= neuron_cnt + 1;
                    end
                end
                default: begin
                    neuron_cnt    <= 0;
                    next_state    <= IDLE;
                    bias_ren_l1   <= 1'b0;
                    bias_ren_l2   <= 1'b0;
                    bias_ren_l3   <= 1'b0;
                    weight_ren_l1 <= 1'b0;
                    weight_ren_l2 <= 1'b0;
                    weight_ren_l3 <= 1'b0;
                    weight_addr_l1<= 0;
                    weight_addr_l2<= 0;
                    weight_addr_l3<= 0;
                    bias_addr_l1  <= 0;
                    bias_addr_l2  <= 0;
                    bias_addr_l3  <= 0;
                end
            endcase
        end
    end

    assign bias_out_l1 = bias_data_l1;
    assign bias_out_l2 = bias_data_l2;
    assign bias_out_l3 = bias_data_l3;

    assign weight_out_l1 = weight_data_l1;
    assign weight_out_l2 = weight_data_l2;
    assign weight_out_l3 = weight_data_l3;
endmodule
