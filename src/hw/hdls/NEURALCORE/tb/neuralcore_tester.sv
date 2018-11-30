import utils::*;
`include "weight.svh"

module neuralcore_tester;
//==================================================================================================
// Global Variables
    localparam CLOCK_SPEED          = 50; // 10MHZ
    localparam IMAGE_ROW_LEN        = 200;
    localparam IMAGE_COL_LEN        = 60;
    localparam IMAGE_SIZE           = IMAGE_ROW_LEN*IMAGE_COL_LEN;
    localparam DATA_WIDTH           = 8;
    localparam DATA_ADDR_WIDTH      = $clog2(IMAGE_SIZE+1);
    localparam KERNEL_SIZE          = 16;
    localparam STRIDE               = 1;
    localparam NUM_NEURONS_L1       = 1024;
    localparam NUM_NEURONS_L2       = 64;
    localparam NUM_NEURONS_L3       = 10;
    localparam NUM_OUTPUT_CLASSES   = 10;
    localparam INPUT_DATA_WIDTH_L1  = 256;
    localparam INPUT_DATA_WIDTH_L2  = 1024;
    localparam INPUT_DATA_WIDTH_L3  = 64;
    localparam OUTPUT_DATA_WIDTH    = 10;
    localparam WEIGHT_DATA_WIDTH    = 2;
    localparam WEIGHT_DATA_WIDTH_L1 = INPUT_DATA_WIDTH_L1*WEIGHT_DATA_WIDTH;
    localparam WEIGHT_DATA_WIDTH_L2 = INPUT_DATA_WIDTH_L2*WEIGHT_DATA_WIDTH;
    localparam WEIGHT_DATA_WIDTH_L3 = INPUT_DATA_WIDTH_L3*WEIGHT_DATA_WIDTH;
    localparam WEIGHT_ADDR_WIDTH_L1 = $clog2(INPUT_DATA_WIDTH_L2+1);
    localparam WEIGHT_ADDR_WIDTH_L2 = $clog2(INPUT_DATA_WIDTH_L3+1);
    localparam WEIGHT_ADDR_WIDTH_L3 = $clog2(NUM_OUTPUT_CLASSES+1);
    localparam BIAS_DATA_WIDTH      = 2;
    localparam BIAS_DATA_WIDTH_L1   = BIAS_DATA_WIDTH;
    localparam BIAS_DATA_WIDTH_L2   = BIAS_DATA_WIDTH;
    localparam BIAS_DATA_WIDTH_L3   = BIAS_DATA_WIDTH;
    localparam BIAS_ADDR_WIDTH_L1   = $clog2(INPUT_DATA_WIDTH_L2+1);
    localparam BIAS_ADDR_WIDTH_L2   = $clog2(INPUT_DATA_WIDTH_L3+1);
    localparam BIAS_ADDR_WIDTH_L3   = $clog2(NUM_OUTPUT_CLASSES+1);
    localparam INPUT_IMG            = "input_img.txt";
    localparam OUTPUT_VALUES        = "output_values.txt";

    static int out_cnt  = 0;

    logic                              clk           ;
    logic                              rst           ;
    logic                              ws_start      ;

    logic      [DATA_ADDR_WIDTH-1 : 0] ws_ram_r_addr ;
    logic           [DATA_WIDTH-1 : 0] ws_ram_r_data ;
    logic                              ws_ram_r_wen  ;
    logic      [DATA_ADDR_WIDTH-1 : 0] ws_ram_w_addr ;
    logic           [DATA_WIDTH-1 : 0] ws_ram_w_data ;
    logic                              ws_ram_w_wen  ;

    logic [WEIGHT_DATA_WIDTH_L1-1 : 0] weight_r_data_l1;
    logic [WEIGHT_ADDR_WIDTH_L1-1 : 0] weight_r_addr_l1;
    logic                              weight_r_ren_l1 ;
    logic [WEIGHT_DATA_WIDTH_L1-1 : 0] weight_w_data_l1;
    logic [WEIGHT_ADDR_WIDTH_L1-1 : 0] weight_w_addr_l1;
    logic                              weight_w_ren_l1 ;

    logic   [BIAS_DATA_WIDTH_L1-1 : 0] bias_r_data_l1  ;
    logic   [BIAS_ADDR_WIDTH_L1-1 : 0] bias_r_addr_l1  ;
    logic                              bias_r_ren_l1   ;
    logic   [BIAS_DATA_WIDTH_L1-1 : 0] bias_w_data_l1  ;
    logic   [BIAS_ADDR_WIDTH_L1-1 : 0] bias_w_addr_l1  ;
    logic                              bias_w_ren_l1   ;

    logic [WEIGHT_DATA_WIDTH_L2-1 : 0] weight_r_data_l2;
    logic [WEIGHT_ADDR_WIDTH_L2-1 : 0] weight_r_addr_l2;
    logic                              weight_r_ren_l2 ;
    logic [WEIGHT_DATA_WIDTH_L2-1 : 0] weight_w_data_l2;
    logic [WEIGHT_ADDR_WIDTH_L2-1 : 0] weight_w_addr_l2;
    logic                              weight_w_ren_l2 ;

    logic   [BIAS_DATA_WIDTH_L2-1 : 0] bias_r_data_l2  ;
    logic   [BIAS_ADDR_WIDTH_L2-1 : 0] bias_r_addr_l2  ;
    logic                              bias_r_ren_l2   ;
    logic   [BIAS_DATA_WIDTH_L2-1 : 0] bias_w_data_l2  ;
    logic   [BIAS_ADDR_WIDTH_L2-1 : 0] bias_w_addr_l2  ;
    logic                              bias_w_ren_l2   ;

    logic [WEIGHT_DATA_WIDTH_L3-1 : 0] weight_r_data_l3;
    logic [WEIGHT_ADDR_WIDTH_L3-1 : 0] weight_r_addr_l3;
    logic                              weight_r_ren_l3 ;
    logic [WEIGHT_DATA_WIDTH_L3-1 : 0] weight_w_data_l3;
    logic [WEIGHT_ADDR_WIDTH_L3-1 : 0] weight_w_addr_l3;
    logic                              weight_w_ren_l3 ;


    logic   [BIAS_DATA_WIDTH_L3-1 : 0] bias_r_data_l3  ;
    logic   [BIAS_ADDR_WIDTH_L3-1 : 0] bias_r_addr_l3  ;
    logic                              bias_r_ren_l3   ;
    logic   [BIAS_DATA_WIDTH_L3-1 : 0] bias_w_data_l3  ;
    logic   [BIAS_ADDR_WIDTH_L3-1 : 0] bias_w_addr_l3  ;
    logic                              bias_w_ren_l3   ;

    logic    [OUTPUT_DATA_WIDTH-1 : 0] calcOutput      ;
    logic                              done            ;

    neuralcore # (
        .DATA_WIDTH          (DATA_WIDTH          ),
        .DATA_ADDR_WIDTH     (DATA_ADDR_WIDTH     ),
        .IMAGE_ROW_LEN       (IMAGE_ROW_LEN       ),
        .IMAGE_COL_LEN       (IMAGE_COL_LEN       ),
        .KERNEL_SIZE         (KERNEL_SIZE         ),
        .STRIDE              (STRIDE              ),
        .NUM_NEURONS_L1      (NUM_NEURONS_L1      ),
        .NUM_NEURONS_L2      (NUM_NEURONS_L2      ),
        .NUM_NEURONS_L3      (NUM_NEURONS_L3      ),
        .NUM_OUTPUT_CLASSES  (NUM_OUTPUT_CLASSES  ),
        .INPUT_DATA_WIDTH_L1 (INPUT_DATA_WIDTH_L1 ),
        .INPUT_DATA_WIDTH_L2 (INPUT_DATA_WIDTH_L2 ),
        .INPUT_DATA_WIDTH_L3 (INPUT_DATA_WIDTH_L3 ),
        .OUTPUT_DATA_WIDTH   (OUTPUT_DATA_WIDTH   ),
        .WEIGHT_DATA_WIDTH   (WEIGHT_DATA_WIDTH   ),
        .WEIGHT_DATA_WIDTH_L1(WEIGHT_DATA_WIDTH_L1),
        .WEIGHT_DATA_WIDTH_L2(WEIGHT_DATA_WIDTH_L2),
        .WEIGHT_DATA_WIDTH_L3(WEIGHT_DATA_WIDTH_L3),
        .WEIGHT_ADDR_WIDTH_L1(WEIGHT_ADDR_WIDTH_L1),
        .WEIGHT_ADDR_WIDTH_L2(WEIGHT_ADDR_WIDTH_L2),
        .WEIGHT_ADDR_WIDTH_L3(WEIGHT_ADDR_WIDTH_L3),
        .BIAS_DATA_WIDTH     (BIAS_DATA_WIDTH     ),
        .BIAS_DATA_WIDTH_L1  (BIAS_DATA_WIDTH_L1  ),
        .BIAS_DATA_WIDTH_L2  (BIAS_DATA_WIDTH_L2  ),
        .BIAS_DATA_WIDTH_L3  (BIAS_DATA_WIDTH_L3  ),
        .BIAS_ADDR_WIDTH_L1  (BIAS_ADDR_WIDTH_L1  ),
        .BIAS_ADDR_WIDTH_L2  (BIAS_ADDR_WIDTH_L2  ),
        .BIAS_ADDR_WIDTH_L3  (BIAS_ADDR_WIDTH_L3  )
    )
    neuralcore_inst
    (
        .clk           (clk             ),
        .rst           (rst             ),
        .ws_start      (ws_start        ),
        .ws_ram_r_addr (ws_ram_r_addr   ),
        .ws_ram_r_data (ws_ram_r_data   ),
        .ws_ram_r_wen  (ws_ram_r_wen    ),
        .weight_data_l1(weight_r_data_l1),
        .weight_addr_l1(weight_r_addr_l1),
        .weight_ren_l1 (weight_r_ren_l1 ),
        .bias_data_l1  (bias_r_data_l1  ),
        .bias_addr_l1  (bias_r_addr_l1  ),
        .bias_ren_l1   (bias_r_ren_l1   ),
        .weight_data_l2(weight_r_data_l2),
        .weight_addr_l2(weight_r_addr_l2),
        .weight_ren_l2 (weight_r_ren_l2 ),
        .bias_data_l2  (bias_r_data_l2  ),
        .bias_addr_l2  (bias_r_addr_l2  ),
        .bias_ren_l2   (bias_r_ren_l2   ),
        .weight_data_l3(weight_r_data_l3),
        .weight_addr_l3(weight_r_addr_l3),
        .weight_ren_l3 (weight_r_ren_l3 ),
        .bias_data_l3  (bias_r_data_l3  ),
        .bias_addr_l3  (bias_r_addr_l3  ),
        .bias_ren_l3   (bias_r_ren_l3   ),
        .calcOutput    (calcOutput      ),
        .done          (done            )
    );
    mega_ram #(
            .DATA_WIDTH          (DATA_WIDTH           ),
            .DATA_ADDR_WIDTH     (DATA_ADDR_WIDTH      ),
            .NUM_OUTPUT_CLASSES  (NUM_OUTPUT_CLASSES   ),
            .INPUT_DATA_WIDTH_L1 (INPUT_DATA_WIDTH_L1  ),
            .INPUT_DATA_WIDTH_L2 (INPUT_DATA_WIDTH_L2  ),
            .INPUT_DATA_WIDTH_L3 (INPUT_DATA_WIDTH_L3  ),
            .WEIGHT_DATA_WIDTH   (WEIGHT_DATA_WIDTH    ),
            .WEIGHT_DATA_WIDTH_L1(WEIGHT_DATA_WIDTH_L1 ),
            .WEIGHT_DATA_WIDTH_L2(WEIGHT_DATA_WIDTH_L2 ),
            .WEIGHT_DATA_WIDTH_L3(WEIGHT_DATA_WIDTH_L3 ),
            .WEIGHT_ADDR_WIDTH_L1(WEIGHT_ADDR_WIDTH_L1 ),
            .WEIGHT_ADDR_WIDTH_L2(WEIGHT_ADDR_WIDTH_L2 ),
            .WEIGHT_ADDR_WIDTH_L3(WEIGHT_ADDR_WIDTH_L3 ),
            .BIAS_DATA_WIDTH     (BIAS_DATA_WIDTH      ),
            .BIAS_DATA_WIDTH_L1  (BIAS_DATA_WIDTH_L1   ),
            .BIAS_DATA_WIDTH_L2  (BIAS_DATA_WIDTH_L2   ),
            .BIAS_DATA_WIDTH_L3  (BIAS_DATA_WIDTH_L3   ),
            .BIAS_ADDR_WIDTH_L1  (BIAS_ADDR_WIDTH_L1   ),
            .BIAS_ADDR_WIDTH_L2  (BIAS_ADDR_WIDTH_L2   ),
            .BIAS_ADDR_WIDTH_L3  (BIAS_ADDR_WIDTH_L3   )
            )
    mega_ram_inst
            (
            .clk             (clk              ),
            .rst             (rst              ),
            .ws_ram_r_addr   (ws_ram_r_addr    ),
            .ws_ram_r_data   (ws_ram_r_data    ),
            .ws_ram_r_wen    (ws_ram_r_wen     ),
            .ws_ram_w_addr   (ws_ram_w_addr    ),
            .ws_ram_w_data   (ws_ram_w_data    ),
            .ws_ram_w_wen    (ws_ram_w_wen     ),
            .weight_r_data_l1(weight_r_data_l1 ),
            .weight_r_addr_l1(weight_r_addr_l1 ),
            .weight_r_ren_l1 (weight_r_ren_l1  ),
            .weight_w_data_l1(weight_w_data_l1 ),
            .weight_w_addr_l1(weight_w_addr_l1 ),
            .weight_w_ren_l1 (weight_w_ren_l1  ),
            .bias_r_data_l1  (bias_r_data_l1   ),
            .bias_r_addr_l1  (bias_r_addr_l1   ),
            .bias_r_ren_l1   (bias_r_ren_l1    ),
            .bias_w_data_l1  (bias_w_data_l1   ),
            .bias_w_addr_l1  (bias_w_addr_l1   ),
            .bias_w_ren_l1   (bias_w_ren_l1    ),
            .weight_r_data_l2(weight_r_data_l2 ),
            .weight_r_addr_l2(weight_r_addr_l2 ),
            .weight_r_ren_l2 (weight_r_ren_l2  ),
            .weight_w_data_l2(weight_w_data_l2 ),
            .weight_w_addr_l2(weight_w_addr_l2 ),
            .weight_w_ren_l2 (weight_w_ren_l2  ),
            .bias_r_data_l2  (bias_r_data_l2   ),
            .bias_r_addr_l2  (bias_r_addr_l2   ),
            .bias_r_ren_l2   (bias_r_ren_l2    ),
            .bias_w_data_l2  (bias_w_data_l2   ),
            .bias_w_addr_l2  (bias_w_addr_l2   ),
            .bias_w_ren_l2   (bias_w_ren_l2    ),
            .weight_r_data_l3(weight_r_data_l3 ),
            .weight_r_addr_l3(weight_r_addr_l3 ),
            .weight_r_ren_l3 (weight_r_ren_l3  ),
            .weight_w_data_l3(weight_w_data_l3 ),
            .weight_w_addr_l3(weight_w_addr_l3 ),
            .weight_w_ren_l3 (weight_w_ren_l3  ),
            .bias_r_data_l3  (bias_r_data_l3   ),
            .bias_r_addr_l3  (bias_r_addr_l3   ),
            .bias_r_ren_l3   (bias_r_ren_l3    ),
            .bias_w_data_l3  (bias_w_data_l3   ),
            .bias_w_addr_l3  (bias_w_addr_l3   ),
            .bias_w_ren_l3   (bias_w_ren_l3    ) 
        );
//==================================================================================================
// Read Outputs
//==================================================================================================
    initial begin
        static int file_id  = 0;
        file_id = $fopen(OUTPUT_VALUES, "w");
        while(1) begin
            @(posedge done)
            `test_print("INFO", $sformatf("[%4d] out=%b", out_cnt, calcOutput), VERB_LOW)
            $fwrite(file_id,"%b\n", calcOutput);
            out_cnt += 1;
        end
    end

//==================================================================================================
// Reading binary file
//==================================================================================================
// Test Bench Main thread:
    initial begin
        `print_banner("INFO", "Testing Neural Core", VERB_LOW)
        ws_start = 1'b0;
        #1us;
        load_image();
        load_weights_l1();
        load_bias_l1();
        load_weights_l2();
        load_bias_l2();
        load_weights_l3();
        load_bias_l3();
        @(posedge clk); 
        ws_start = 1'b1;
        @(posedge clk); 
        ws_start = 1'b0;
        #10us;
        @(posedge clk);
        #50us;
        // for (int i = 0; i < 100000; i++) begin
        //     slide_ws();
        // end
        #12000ms;
        //write_to_output();
        $finish();
    end

    task load_image();
        static integer file_id;
        static int val  = 0;
        file_id = $fopen(INPUT_IMG,"r");
        @(posedge clk);
        ws_ram_w_wen = 1'b1;
        ws_ram_w_addr  = 0;
        `test_print("INFO", $sformatf("Loading %s image into image ram", INPUT_IMG), VERB_LOW)
        while (! $feof(file_id)) begin 
            $fscanf(file_id,"%d\n",val);
            ws_ram_w_data = DATA_WIDTH'(val);
            `test_print("INFO", $sformatf("Writing %1d to image_ram[%4h]", ws_ram_w_data, ws_ram_w_addr), VERB_HIGH)
            @(posedge clk);
            ws_ram_w_addr  += 1;
        end
        `test_print("INFO", $sformatf("Loaded %0d pixels into image ram", ws_ram_w_addr), VERB_LOW)
        //once reading and writing is finished, close the file.
        $fclose(file_id);
    endtask

    task load_weights_l1();
        @(posedge clk);
        weight_w_ren_l1 = 1'b1;
        weight_w_addr_l1  = 0;
        @(posedge clk);
        for (int i=0; i<NUM_NEURONS_L1; i++) begin
            weight_w_data_l1 = weight_l1[i];
            `test_print("INFO", $sformatf("Loading w_l1[%0d]=%p ", weight_w_addr_l1, weight_w_data_l1), VERB_HIGH)
            @(posedge clk);
            weight_w_addr_l1  += 1;
        end
        `test_print("INFO", $sformatf("Loaded %0d weights into weight ram L%1d", weight_w_addr_l1, 1), VERB_LOW)
    endtask

    task load_bias_l1();
        @(posedge clk);
        bias_w_ren_l1 = 1'b1;
        bias_w_addr_l1  = 0;
        @(posedge clk);
        for (int i=0; i<NUM_NEURONS_L1; i++) begin
            bias_w_data_l1 = bias_l1[i];
            @(posedge clk);
            bias_w_addr_l1  += 1;
        end
        `test_print("INFO", $sformatf("Loaded %0d biases into bias ram L%1d", bias_w_addr_l1, 1), VERB_LOW)
    endtask


    task load_weights_l2();
        @(posedge clk);
        weight_w_ren_l2 = 1'b1;
        weight_w_addr_l2  = 0;
        @(posedge clk);
        for (int i=0; i<NUM_NEURONS_L2; i++) begin
            weight_w_data_l2 = weight_l2[i];
            @(posedge clk);
            weight_w_addr_l2  += 1;
        end
        `test_print("INFO", $sformatf("Loaded %0d weights into weight ram L%1d", weight_w_addr_l2, 2), VERB_LOW)
    endtask

    task load_bias_l2();
        @(posedge clk);
        bias_w_ren_l2 = 1'b1;
        bias_w_addr_l2  = 0;
        @(posedge clk);
        for (int i=0; i<NUM_NEURONS_L2; i++) begin
            bias_w_data_l2 = bias_l2[i];
            @(posedge clk);
            bias_w_addr_l2  += 1;
        end
        `test_print("INFO", $sformatf("Loaded %0d biases into bias ram L%1d", bias_w_addr_l2, 2), VERB_LOW)
    endtask

    task load_weights_l3();
        @(posedge clk);
        weight_w_ren_l3 = 1'b1;
        weight_w_addr_l3  = 0;
        @(posedge clk);
        for (int i=0; i<NUM_NEURONS_L3; i++) begin
            weight_w_data_l3 = weight_l3[i];
            @(posedge clk);
            weight_w_addr_l3  += 1;
        end
        `test_print("INFO", $sformatf("Loaded %0d weights into weight ram L%1d", weight_w_addr_l3, 3), VERB_LOW)
    endtask

    task load_bias_l3();
        @(posedge clk);
        bias_w_ren_l3 = 1'b1;
        bias_w_addr_l3  = 0;
        @(posedge clk);
        for (int i=0; i<NUM_NEURONS_L3; i++) begin
            bias_w_data_l3 = bias_l3[i];
            @(posedge clk);
            bias_w_addr_l3  += 1;
        end
        `test_print("INFO", $sformatf("Loaded %0d biases into bias ram L%1d", bias_w_addr_l3, 3), VERB_LOW)
    endtask
//==================================================================================================
// Simulation specific Threads
    initial begin
        $dumpfile("gcd_normal.vcd");
        $dumpvars(1);
    end

    initial begin 
        #((CLOCK_SPEED)*1ns);
        clk = 1;
        rst = 1;
        #((CLOCK_SPEED)*1ns);
        clk = 0;
        rst = 1;
        #((CLOCK_SPEED)*1ns);
        clk = 1;
        rst = 0;
        #((CLOCK_SPEED)*1ns);
        rst = 1;
        clk = 0;
        forever begin
            #((CLOCK_SPEED)*1ns) clk = !clk;
        end
    end

    initial begin
        #2000ms;
        `print_banner("INFO", $sformatf("Hardware Generated %0d outputs", out_cnt), VERB_LOW)
        $display("Simulation took more than expected ( more than 600ms)");
        $finish();
    end

endmodule
