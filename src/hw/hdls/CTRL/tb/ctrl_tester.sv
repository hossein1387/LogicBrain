
module ctrl_tester (
    input clk,    // Clock
    input rst_n  // Asynchronous reset active low
);

ctrl ctrl_inst
            (
                .clk(clk),
                .rst_n(rst_n)
            );

initial begin
    $display("this is a test");
    $finish;
end // initial

endmodule