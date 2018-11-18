import utils::*;

module window_slide_tester;
//==================================================================================================
// Global Variables
    parameter IMAGE_ROW_LEN = 10;
    parameter IMAGE_COL_LEN = 20;
    parameter IMAGE_SIZE    = IMAGE_ROW_LEN * IMAGE_COL_LEN;
    parameter KERNEL_SIZE   = 3;
    parameter STRIDE        = 1;
    logic clk, rst, new_image, done, busy, valid_ws;
    logic image[IMAGE_SIZE-1:0];
    logic x_in;
    logic y_out[KERNEL_SIZE*KERNEL_SIZE-1:0];
    bit self_test = 1'b0;
    logic slide = 1'b0;
    static print_verbosity verbosity = VERB_LOW;

    window_slide #  (    
                        .IMAGE_ROW_LEN(IMAGE_ROW_LEN),
                        .IMAGE_COL_LEN(IMAGE_COL_LEN),
                        .KERNEL_SIZE  (KERNEL_SIZE  ),
                        .STRIDE       (STRIDE       )
                    )
    window_slide_inst( .clk(clk),
                       .rst(rst),
                       .new_image(new_image),
                       .x_in(x_in),
                       .slide(slide),
                       .y_out(y_out),
                       .valid_ws(valid_ws),
                       .done(done),
                       .busy(busy));
//==================================================================================================
// Reading binary file
//==================================================================================================
// Test Bench Main thread:
    initial begin
        static string array_shape_str = "";
        static int unsigned elcnt =0;
        static int unsigned el_val = 0;
        `print_banner("INFO", "Testing Sliding Window", verbosity)
        `test_print("INFO", "Input Image", VERB_LOW)
        for (int rows=0; rows<IMAGE_ROW_LEN; rows++) begin
            for(int cols=0; cols<IMAGE_COL_LEN; cols++) begin
                image[elcnt] = (rows%2==0) ? 1'b1 : 1'b0;
                array_shape_str = {array_shape_str, $sformatf("%1h ", image[elcnt])};
                elcnt++;
            end
            `test_print("INFO", $sformatf("%s", array_shape_str), VERB_LOW)
            array_shape_str = "";
        end
        #10us;
        @(posedge clk);
        @(posedge clk);
        new_image = 1'b1;
        for (int i=0; i<IMAGE_SIZE; i++) begin
            x_in = image[i];
            @(posedge clk);
            new_image = 1'b0;
        end
        @(posedge clk);
        x_in = 1'b0;
        @(posedge clk);
        #10us;
        //write_to_output();
        $finish();
    end

    initial begin
        static int out_cnt = 0;
        while(1) begin
            @(posedge clk);
            if(valid_ws==1'b1) begin
                `test_print("INFO", $sformatf("[%2d] %p", out_cnt, y_out), VERB_LOW)
                out_cnt ++;
            end
        end
    end // initial

//==================================================================================================
// Simulation specific Threads
    initial begin
        $dumpfile("gcd_normal.vcd");
        $dumpvars(1);
    end

    initial begin 
        clk = 0;
        rst = 1;
        #50ns;
        rst = 0;
        #50ns;
        rst = 1;
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
