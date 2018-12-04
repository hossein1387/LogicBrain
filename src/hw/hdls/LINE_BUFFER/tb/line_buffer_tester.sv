import utils::*;

module line_buffer_tester;
//==================================================================================================
// Global Variables
    parameter INPUT_WIDTH  = 16;
    parameter DEPTH_SIZE   = 10;
    parameter NUM_ELEMENTS = 10;
    print_verbosity verbosity = VERB_LOW;
    logic clk, rst;

    logic x_in_vec [NUM_ELEMENTS-1:0];
    logic x_in;
    logic y_out;
    line_buffer #(.DEPTH_SIZE(DEPTH_SIZE))
        line_buffer_inst(.clk(clk), .rst(rst), .x_in(x_in), .y_out(y_out));
        
//==================================================================================================
// Test Bench Main thread:
    initial begin
        static string array_str = "Input Array: ";
        static int unsigned step_cnt = 0;
        `print_banner("INFO", "Testing Line Buffer", verbosity)
        for (int i=0; i<NUM_ELEMENTS; i++) begin
            x_in_vec[i] = $urandom_range(0, 2**(INPUT_WIDTH)-1);
            array_str = {array_str, $sformatf("%h,", x_in_vec[i])};
        end
        `test_print("INFO", array_str, VERB_HIGH)
        for (int i=0; i<2*(DEPTH_SIZE+NUM_ELEMENTS); i++) begin
            @(posedge clk);
            x_in = x_in_vec[i];
            `test_print("INFO", $sformatf("%4t x_in=%h, y=%h", $time(), x_in, y_out), VERB_HIGH)
            if(step_cnt>=DEPTH_SIZE) begin
                //y_out_q.push_back(y_out);
            end
            step_cnt++;
        end
        for(int i=0; i<NUM_ELEMENTS; i++) begin
            if(y_out_q[i]==x_in_vec[i]) begin
               test_stat.pass_cnt++;
            end else begin
               `test_print("ERROR", $sformatf("Expected=%0h   Actual=%0h", x_in_vec[i], y_out_q[i]), verbosity)
               test_stat.fail_cnt++;
            end
        end
        //print_result(test_stat, verbosity);
        $finish();
    end 

//==================================================================================================
// Simulation specific Threads
    //initial begin
    //    $dumpfile("gcd_normal.vcd");
    //    $dumpvars(1);
    //end

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
        #1000ms;
        $display("Simulation took more than expected ( more than 600ms)");
        $finish();
    end

endmodule
