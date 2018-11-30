
//==================================================================================================
// Dual port RAM
//==================================================================================================

module true_d2port_ram
    #(
        parameter D_WIDTH    = 8, 
        parameter ADDR_WIDTH = 5
    )
    (
        input wire                    clk,
// Port A
        input wire                    we_a,
        input wire [D_WIDTH-1:0]      data_a, 
        input wire [ADDR_WIDTH-1:0]   addr_a, 
//        output reg [D_WIDTH-1:0]      da_out,
// Port B
        input wire                    we_b,
//        input wire [D_WIDTH-1:0]      data_b, 
        input  wire [ADDR_WIDTH-1:0]  addr_b, 
        output reg [D_WIDTH-1:0]      db_out
    );
    // Declare the RAM variable
    reg [D_WIDTH-1:0] ram[(1 << ADDR_WIDTH) - 1:0];
    
    // Port A
    always @ (posedge clk) begin
        if (we_a) begin
            ram[addr_a] <= data_a;
//            da_out <= data_a;
//        end else begin
//            da_out <= ram[addr_a];
        end
    end
    
    // Port B
    always @ (addr_b or we_b) begin
        if (~we_b) begin
//            ram[addr_b] <= data_b;
//            db_out <= data_b;
//        end else begin
            db_out <= ram[addr_b];
        end
    end

endmodule
