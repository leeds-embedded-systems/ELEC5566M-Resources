//State Definitions
localparam A_STATE = 2'b00;
localparam B_STATE = 2'b01;
...

//Verilog Case Statement Structure for State Machine
always @ (posedge clock or posedge reset) begin
    if (reset) begin
        stateVariable <= A_STATE;
    end else begin
        case(stateVariable)
            A_STATE: begin
                // define state A behaviour 
                ...
            end
            B_STATE: begin
                // define state B behaviour
                ...
            end
            ...
        endcase
    end
end
