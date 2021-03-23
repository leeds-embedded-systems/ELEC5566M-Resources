/*
 * LT24 Functional Model
 * ------------------------
 * By: Thomas Carpenter
 * For: University of Leeds
 * Date: 29th December 2017
 *
 * Short Description
 * -----------------
 * This module is designed to simulate the LT24 display.
 *
 * A "Functional Model" is HDL code that represents the
 * behaviour of an external piece of hardware. It is not
 * intended to be synthesised for an FPGA, but rather to
 * be used in a simulator.
 *
 */
 
`timescale 1 ns/100 ps

module LT24FunctionalModel #(
    parameter WIDTH = 240,
    parameter HEIGHT = 320
)(
    // LT24 Interface
    input             LT24Wr_n,
    input             LT24Rd_n,
    input             LT24CS_n,
    input             LT24RS,
    input             LT24Reset_n,
    input [     15:0] LT24Data,
    input             LT24LCDOn
    
);

reg [ 7:0] command;
reg [ 2:0] payloadCntr;

reg [15:0] xPtr;
reg [15:0] yPtr;
reg [15:0] pixelColour;
reg        pixelWrite;

reg [ 7:0] mAddrCtl;
reg [15:0] xMin;
reg [15:0] xMax;
reg [15:0] yMin;
reg [15:0] yMax;




function nextPixel;
    input returnVal;
begin
    xPtr = xPtr + 16'b1;                  //Increment XPtr
    if (xPtr > xMax) begin
        xPtr = xMin;                      //Wrap XPtr if now larger than XMax
        nextPixel = nextYPtr(returnVal);  //And update Y pointer.
    end else begin
        nextPixel = returnVal;
    end
end endfunction

function nextYPtr;
    input returnVal;
begin
    yPtr = yPtr + 16'b1;            //Increment YPtr
    if (yPtr > yMax) begin
        yPtr = yMin;                //Wrap YPtr if now larger than YMax
    end
    nextYPtr = returnVal;
end endfunction

function [15:0] rgbOrder;
    input [15:0] rawPixel;
    integer i, j;
begin
    if (mAddrCtl[3]) begin
        //If in reverse order (BGR)
        for (i = 0; i < 16; i = i + 1) begin
            j = 15 - i;
            rgbOrder[j] = rawPixel[i];
        end
    end else begin
        //Otherwise default order (RGB)
        rgbOrder = rawPixel;
    end
end endfunction

always @ (posedge LT24Wr_n or negedge LT24Reset_n) begin
    if (!LT24Reset_n) begin
        //Commands
        command             = 16'b0;               //NoP
        payloadCntr         =  3'b0;
        //Pointers
        xPtr                = 16'b0;
        yPtr                = 16'b0;
        pixelColour         = 16'b0;
        pixelWrite          =  1'b0;
        //Properties
        mAddrCtl            =  8'b0;
        xMin                = 16'b0;
        xMax                = 16'b0;
        yMin                = 16'b0;
        yMax                = 16'b0;
    end else begin
        pixelWrite          = 1'b0;                 //Assume not a pixel.
        if (!LT24RS) begin
            //If a command
            command         = LT24Data[7:0];       //Update the current command
            payloadCntr     = 3'b0;                //Reset the payload counter
        end else begin
            //Otherwise command payload
            case (command)
                8'h36: begin //MADCLT
                    mAddrCtl = LT24Data[7:0];
                end
                8'h2A: begin //CASET
                    case(payloadCntr)
                        0: xMin[15:8] = LT24Data[7:0];  //High Min X
                        1: xMin[ 7:0] = LT24Data[7:0];  //Low Min X
                        2: xMax[15:8] = LT24Data[7:0];  //High Max X
                        3: xMax[ 7:0] = LT24Data[7:0];  //Low Max X 
                    endcase
                    xPtr = xMin;
                end
                8'h2B: begin //PASET
                    case(payloadCntr)
                        0: yMin[15:8] = LT24Data[7:0];  //High Min Y
                        1: yMin[ 7:0] = LT24Data[7:0];  //Low Min Y
                        2: yMax[15:8] = LT24Data[7:0];  //High Max Y
                        3: yMax[ 7:0] = LT24Data[7:0];  //Low Max Y
                    endcase
                    yPtr = yMin;
                end
                8'h2C: begin //Pixel
                    pixelColour = rgbOrder(LT24Data[15:0]);           //Pixel Colour (reordered per mAddrCtl[3])
                    pixelWrite  = 1'b1;
                end
                default: begin
                    //Do nothing
                end
            endcase
            payloadCntr = payloadCntr + 3'b1;  //Increment the payload counter
        end
    end
end

//Map x/y pointers to memory address.
wire [15:0] xAddrRaw = (mAddrCtl[5] ? yPtr : xPtr) % WIDTH[15:0];
wire [15:0] yAddrRaw = (mAddrCtl[5] ? xPtr : yPtr) % HEIGHT[15:0];
wire [15:0] xAddr =  mAddrCtl[6] ? xAddrRaw : ( WIDTH[15:0] - xAddrRaw - 16'b1);
wire [15:0] yAddr = !mAddrCtl[7] ? yAddrRaw : (HEIGHT[15:0] - yAddrRaw - 16'b1);

reg [4:0] gram_r [HEIGHT-1:0][WIDTH-1:0];
reg [5:0] gram_g [HEIGHT-1:0][WIDTH-1:0];
reg [4:0] gram_b [HEIGHT-1:0][WIDTH-1:0];

integer i, j;
always @ (negedge LT24Wr_n or negedge LT24Reset_n) begin
    if (!LT24Reset_n) begin
        for (i = 0; i < HEIGHT; i = i + 1) begin
            for (j = 0; j < WIDTH; j = j + 1) begin
                gram_r[i][j] = 5'b0;
                gram_g[i][j] = 6'b0;
                gram_b[i][j] = 5'b0;
            end
        end
    end else if (pixelWrite) begin
        gram_r[yAddr][xAddr] = pixelColour[ 4: 0];
        gram_g[yAddr][xAddr] = pixelColour[10: 5];
        gram_b[yAddr][xAddr] = pixelColour[15:11];
        pixelWrite = nextPixel(1'b0); //Update X (and maybe Y) pointer
        $display("%d ns\tPixel (%d,%d) = RGB {%d,%d,%d}",$time,xAddr,yAddr,gram_r[yAddr][xAddr],gram_g[yAddr][xAddr],gram_b[yAddr][xAddr]);
    end
end

endmodule

