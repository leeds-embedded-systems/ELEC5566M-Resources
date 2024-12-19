/*
 * N-Bit Counter
 * =============
 *
 * Parameterised N-Bit counter with selectable increment, width, and maximum value.
 * 
 * A count enable signal (enable) is provided which when high will allow the counter to increment
 * on each rising clock (clock) edge.
 *
 * An asynchronous reset (reset) signal sets the counter to zero when asserted.
 *
 * A synchronous reset (zero) signal sets the counter value to zero on the next rising clock edge
 * where the counter is enabled.
 *
 * The counter can be prevented from automatically overflowing by setting the AUTO_RESET parameter
 * to 0. In this case the counter will stop at max value and require manual reset. The overflow output
 * will be set once the counter reaches the maximum value and either overflows or latches.
 *
 * If the number of counter values (MAX_VALUE+1) is not a multiple of the INCREMENT value,
 * the counter will overflow to zero on the last multiple of increment <= MAX_VALUE.
 * For example if the MAX_VALUE is set to 10, and the increment to 3, the counter will count
 * the sequence:  0,3,6,9,0,3,6,9,0   as 9 is the last multiple of INCREMENT <= 10.
 *
 */

module counter_hw #(
    parameter WIDTH       = 10,           //Default to 10bits wide 
    parameter INCREMENT   = 1,            //Amount to increment counter by each cycle
    parameter INVERT_MSB  = 0,            //If true, will convert 0 to (2^N)-1 range to a -2^(N-1) to 2^(N-1)-1 range by inverting MSB.
    parameter AUTO_RESET  = 1,            //Automatically reset at MAX_VALUE. If 0, we stop when reaching top, requiring reset.
    parameter HAS_ENABLE  = 1,            //If set to 0, enable signal will be ignored and will count every clock cycle
    parameter HAS_ZERO    = 1,            //If set to 0, zero signal will be ignored.
    parameter BUFFER_ZERO = 0,            //If non-zero, will add BUFFER_ZERO cycles of pipelining to the zero input signal.
    parameter ZERO_VARDPT = 0,            //If set to 1, then adds an extra variable length pipeline to the zero input signal.
    parameter ZERO_VARCNT = 0,            //Set to 0 if var depth unused, or max depth for variable
    parameter ZERO_VARBIT = 1,            //Set to 1 if var depth unused, or $clog2(ZERO_VARCNT+1) for variable
    parameter ZERO_EDGE   = 0,            //If set to 1, then adds an edge detector to the zero signal.
    parameter ZERO_VALUE  = 0,            //Value set when the zero signal asserted or during reset.
    parameter OVF_ON_ZERO = 0,            //If true, assert overflow when zeroing.
    parameter OVF_ON_RST  = OVF_ON_ZERO,  //If true, assert overflow when resetting.
    parameter MIN_VALUE   = ZERO_VALUE,   //Minimum value set when the counter overflows
    parameter MAX_VALUE   = (2**WIDTH)-1, //e.g. Maximum value default is 2^WIDTH - 1
    parameter VAR_MAX     = 0             //If set to 1, then variable `maxValue` will be used instead of fixed `MAX_VALUE`.
)(
    input                    clock, 
    input                    reset,
    input                    enable,
    input                    zero,
    input  [ZERO_VARBIT-1:0] zeroDepth,   // Used only if ZERO_VARDPT == 1
    input      [  WIDTH-1:0] maxValue,
    output reg               overflow,
    output     [  WIDTH-1:0] countValue,
    output                   one         //This always outputs 1. It's existence is for the benefit of Qsys for a "valid" signal.
);

wire zeroInt;
generate if (HAS_ZERO) begin
    // Has a zeroing signal. Might be edge sensitive
    if (ZERO_EDGE) begin
        // Rising edge triggers zero
        edge_detector_hw #(
            .RISING_EDGE(1),
            .FALLING_EDGE(0),
            .BUFFER_INPUT(BUFFER_ZERO),
            .BUFFER_OUTPUT(ZERO_VARCNT),
            .VAR_DEPTH(ZERO_VARDPT),
            .DEPTH_BITS(ZERO_VARBIT)
        ) zeroEdge (    
            .clock (clock    ),
            .reset (reset    ),
            .inEdge(zero     ),
            .depth (zeroDepth),
            .qout  (zeroInt  )
        );
    end else begin
        // Zero whenever requested
        wire zeroBuf;
        dff_hw #(
            .DEPTH(BUFFER_ZERO),
            .USE_RESET(1)
        ) zeroBufferIn (
            .clock(clock  ),
            .reset(reset  ),
            .din  (zero   ),
            .qout (zeroBuf)
        );
        dff_hw #(
            .DEPTH(ZERO_VARCNT),
            .USE_RESET(1),
            .VAR_DEPTH(ZERO_VARDPT),
            .DEPTH_BITS(ZERO_VARBIT)
        ) zeroBuffer (
            .clock(clock    ),
            .reset(reset    ),
            .depth(zeroDepth),
            .din  (zeroBuf  ),
            .qout (zeroInt  )
        );
    end
end else begin
    // No zeroing signal
    assign zeroInt = 1'b0;
end endgenerate

assign one = 1'b1;

wire [WIDTH-1:0] countMax;
assign countMax = (VAR_MAX ? maxValue : (MAX_VALUE[WIDTH-1:0] - INCREMENT[WIDTH-1:0] + 1'b1));

reg  [WIDTH-1:0] counter;
always @ (posedge clock or posedge reset) begin
    if (reset) begin
        //Async Reset
        counter          <= ZERO_VALUE[WIDTH-1:0];
        overflow         <= (OVF_ON_RST != 0);
    end else if (zeroInt) begin
        //Synchronous Reset
        counter          <= ZERO_VALUE[WIDTH-1:0];
        overflow         <= (OVF_ON_ZERO != 0);
    end else if (!HAS_ENABLE || enable) begin
        //Count if enabled
        if (counter < countMax) begin
            //If count value is less than maximum
            counter      <= counter + INCREMENT[WIDTH-1:0];   //Increment the counter
            overflow     <= 1'b0;                             //Not overflowing.
        end else begin
            //Otherwise at the top
            overflow     <= 1'b1;                             //Counter overflowing.
            if (AUTO_RESET) begin
                //If auto-reset on overflow is allowed
                counter  <= MIN_VALUE[WIDTH-1:0];             //Reset the counter automatically
            end
        end
    end
end

// Assign the counter value to the output. Invert the MSB if required.
assign countValue[WIDTH-2:0] = counter[WIDTH-2:0];
assign countValue[WIDTH-1  ] = INVERT_MSB ? !counter[WIDTH-1] : counter[WIDTH-1];

endmodule
