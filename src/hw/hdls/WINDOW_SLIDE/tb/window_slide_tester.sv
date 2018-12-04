import utils::*;

module window_slide_tester;
//==================================================================================================
// Global Variables
    parameter IMAGE_ROW_LEN   = 200;
    parameter IMAGE_COL_LEN   = 60;
    parameter IMAGE_SIZE      = IMAGE_ROW_LEN * IMAGE_COL_LEN;
    parameter KERNEL_SIZE     = 16;
    parameter STRIDE          = 1;
    parameter DATA_ADDR_WIDTH =  $clog2(IMAGE_SIZE + 1);;
    parameter DATA_WIDTH      = 8;
    parameter OUTPUT_IMG      = "output_img.txt";
    parameter INPUT_IMG       = "input_img.txt";
    logic clk, rst, start, done, busy, valid;
    logic image[IMAGE_SIZE-1:0];
    logic y_out[KERNEL_SIZE*KERNEL_SIZE-1:0];
    bit self_test = 1'b0;
    logic slide = 1'b0;
    logic ram_in_wen;
    logic [DATA_ADDR_WIDTH-1 : 0] ram_in_addr;
    logic [DATA_WIDTH-1      : 0] ram_in_data;
    static print_verbosity verbosity = VERB_LOW;
    static integer input_f_id, output_f_id;
    window_slide_wrapper #  (
                                .DATA_WIDTH     (DATA_WIDTH     ),
                                .DATA_ADDR_WIDTH(DATA_ADDR_WIDTH),
                                .IMAGE_ROW_LEN  (IMAGE_ROW_LEN  ),
                                .IMAGE_COL_LEN  (IMAGE_COL_LEN  ),
                                .KERNEL_SIZE    (KERNEL_SIZE    ),
                                .STRIDE         (STRIDE         )
                            )
    window_slide_wrapper_inst(
                                .clk        (clk         ),
                                .rst        (rst         ),
                                .ram_in_addr(ram_in_addr ),
                                .ram_in_data(ram_in_data ),
                                .ram_in_wen (ram_in_wen  ),
                                .start      (start       ),
                                .slide      (slide       ),
                                .y_out      (y_out       ),
                                .valid      (valid        )
                            );
//==================================================================================================
// Reading binary file
//==================================================================================================
// Test Bench Main thread:
    initial begin
        ram_in_wen = 1'b0;
        ram_in_addr= 0;
        start = 1'b0;
        `print_banner("INFO", "Testing Sliding Window", verbosity)
        #1us;
        write_image_to_ws_ram();
        #10us;
        @(posedge clk);
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;
        @(posedge clk);
        #50us;
        for (int i = 0; i < 100000; i++) begin
            slide_ws();
        end
        #100us;
        //write_to_output();
        $finish();
    end

    initial begin
        static int out_cnt = 0;
        output_f_id = $fopen(OUTPUT_IMG, "w");
        while(1) begin
            @(posedge clk);
            if(valid==1'b1) begin
                // `test_print("INFO", $sformatf("[%2d] %p", out_cnt, y_out), VERB_LOW)
                $fwrite(output_f_id,"%p\n", y_out);
                out_cnt ++;
            end
        end
    end // initial

    task write_image_to_ws_ram();
        static string array_shape_str = "";
        static int unsigned elcnt =0;
        static int unsigned el_val = 0;
        input_f_id  = $fopen(INPUT_IMG, "w");
        ram_in_wen  = 1'b1;
        ram_in_addr = 0;
        `test_print("INFO", "Input Image", VERB_LOW)
        @(posedge clk);
        @(posedge clk);
        for (int rows=0; rows<IMAGE_ROW_LEN; rows++) begin
            for(int cols=0; cols<IMAGE_COL_LEN; cols++) begin
                image[elcnt] = (rows%2==0) ? 1'b1 : 1'b0;
                array_shape_str = {array_shape_str, $sformatf("%1h ", image[elcnt])};
                elcnt++;
                $fwrite(input_f_id,"%1d\n", ((rows%2==0) ? 1'b1 : 1'b0));
                ram_in_data = (rows%2==0) ? {DATA_WIDTH{1'b1}} : {DATA_WIDTH{1'b0}};//1'(image[elcnt]);
                @(posedge clk);
                ram_in_addr = ram_in_addr + 1;
            end
            `test_print("INFO", $sformatf("%s", array_shape_str), VERB_LOW)
            array_shape_str = "";
        end
        ram_in_wen = 1'b0;
    endtask

    task slide_ws();
        slide = 1'b1;
        @(posedge clk);
        slide = 1'b0;
        #10us;
        @(posedge clk);
    endtask

//==================================================================================================
// Simulation specific Threads
    initial begin
        $dumpfile("gcd_normal.vcd");
        $dumpvars(1);
    end

    initial begin 
        #50ns;
        clk = 1;
        rst = 1;
        #50ns;
        clk = 0;
        rst = 1;
        #50ns;
        clk = 1;
        rst = 0;
        #50ns;
        rst = 1;
        clk = 0;
        forever begin
          #50ns clk = !clk;
        end
    end

    initial begin
        #600ms;
        $display("Simulation took more than expected ( more than 600ms)");
        $finish();
    end

endmodule
