/*
 * Avalon-MM Reset
 * ------------------------------------------------------
 * By: Thomas Carpenter
 * For: University of Leeds
 * Date: 10th March 2018 (or earlier)
 *
 * Module Description:
 * -------------------
 *
 * This module generates a reset signal controlled by an Avalon-MM
 * interface.
 *
 */

module avmm_reset_hw #(
    parameter ACTIVE_LOW_OUT = 0
)(
    input         clock,
    input         reset,
    
    input         write,
    input  [31:0] writedata,
    input         chipsel,
    
    output        user_reset
);


reg reset_gen;

always @ (posedge clock or posedge reset) begin
    if (reset) begin
        reset_gen <= 1'b0;
    end else if (write && chipsel) begin
        reset_gen <= writedata[0];
    end
end


generate if (ACTIVE_LOW_OUT != 0) begin
    assign user_reset =  reset_gen;
end else begin
    assign user_reset = !reset_gen;
end endgenerate

endmodule
