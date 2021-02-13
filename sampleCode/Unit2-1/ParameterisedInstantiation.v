CounterNbit #( //parameter redefinition list between module name and instance name
    .WIDTH    (5), //Change the width
    .INCREMENT(1)  //We can override a parameter with the same value if we want
    //.MAX_VALUE(31) <- We could also change the MAX_VALUE here if we wanted
    //but the default value will be recalculated for our new width automatically.
) ourCounter ( //instance name and port connection list as before
    .clock     (...),
    .reset     (...),
    .enable    (...),
    .countValue(...)
);
