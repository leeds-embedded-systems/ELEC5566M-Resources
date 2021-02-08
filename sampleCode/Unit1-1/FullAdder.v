module Adder1Bit ( /*!\tikzmark{fa_moddefstart}!*/
    // Declare input and output ports
    input  a,
    input  b,
    input  cin,
    output cout,
    output s
);  /*!\tikzmark{fa_moddefend}!*/
    // Declare several single-bit wires that we can  /*!\tikzmark{fa_startwire}!*/
    // use to interconnect the gates.
    wire link1,link2,link3;  /*!\tikzmark{fa_endwire}!*/
    // Instantiate gates to calculate sum output  /*!\tikzmark{fa_startprim}!*/
    xor(link1,a,b);
    xor(s,link1,cin);
    // Instantiate gates to calculate carry (cout) output /*!\tikzmark{fa_codeedge}!*/
    and(link2,a,b);
    and(link3,cin,link1);
    or (cout,link2,link3);  /*!\tikzmark{fa_endprim}!*/
/*!\tikzmark{fa_endmodstart}!*/
endmodule // End of module /*!\tikzmark{fa_endmodend}!*/
