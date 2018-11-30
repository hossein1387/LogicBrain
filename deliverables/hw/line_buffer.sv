module line_buffer
    #(
        parameter DEPTH_SIZE   = 256
    )
    (
        input  wire clk,
        input  wire rst,
        input  wire x_in,
        output wire y_out
    );
    reg buffer [DEPTH_SIZE-1:0];
    always @(posedge clk) begin 
        if(~rst) begin
            for (int i=0; i<DEPTH_SIZE; i++)begin
                buffer[i] <=  1'b0;
            end
        end else begin
                for (int i=0; i<DEPTH_SIZE-1; i++) begin
                    buffer[i+1] <= buffer[i];
                end
                buffer[0] <= x_in;
        end // end else
    end
    // Assign output value
    assign y_out = buffer[DEPTH_SIZE-1];

endmodule 