/*#############################################################################\
##                                                                            ##
##       Applied Electronics - Physics Department - University of Padova      ##
##                                                                            ##
\#############################################################################*/


// Set timescale (default time unit if not otherwise specified).
`timescale 1ns / 1ps


/* Module to generate a fixed 100 MHz and a VARIABLE clock starting from an input 
   clock. Due to physical constraints of the MMCM block used, the input clock 
   must fit into the 20 MHz to 600 MHz range, and the output clock into the 
   4.68 MHz to 600 MHz range. Note that the output frequency will be approximated
   to the third decimal digit. It is STRONGLY suggested to synthetize exact clocks.
*/


module clockHrd
    // Parameters.
    # (
        parameter integer C_IN_FRQ = 100_000_000,     // Input clock frequency [Hz].
        parameter integer C_VAR_FRQ = 10_000_000     // Variable clock frequency [Hz].
    )
    
    // IO ports.
    (
        input rstn,                         // Input reset (active low).
        input clkIn,                        // Input clock.
        output locked,                      // Locked, goes high when the clock is ok.
        output clk100_0,                    // 100 MHz output clock.
        output clkVar_0                     // Variable output clock.
    );
    
    // Local parameters
    // ----------------
        
        // Transform the input clock frequency into period [ns]
        localparam C_PERIOD = (1E9 / C_IN_FRQ); 
        
        // Set the range of the synthetizable clocks. The output clock frewquency is equal to
        // C_OUT_FRQ = (C_IN_FRQ * C_MULT) / (C_DIV1 * C_DIV2). The minimum MMCM VCO frequency
        // is 600 MHz, ad is equal to (C_IN_FRQ * C_MULT / C_DIV1), which limits the multiplier
        // and divider setting to any combination like the following for the low frequency
        // regime where we operate.
        localparam integer C_MULT = 1200000000 / C_IN_FRQ;      // Range [2 - 64] 
        localparam integer C_DIV1 = 2;                          // Range [1 - 106].
        
        // Assuming the VCO is set to operate at 1200/2 = 600 MHz, here we divide to obrain the
        // variable output clock frequency.
        localparam real C_DIVVAR = 600000000.0 / C_VAR_FRQ;     // Range [0.000 - 128.000], used to set the variable clock.
        localparam integer C_DIV100 = 6;                        // Range [0 - 128], used to set the 100 MHz clock.
        
        
    // Local wiring
    // ------------
    
        wire clkFdbk;                   // Feedback loop for the MMCM module.
    
    
    // Hardware modules
    // ----------------
    
    
     
    // Artix/Kintex 7 family MMCM block instantiation (base) parameters.
    MMCME2_BASE #(
        
        // Clock properties.
        .CLKIN1_PERIOD(C_PERIOD),       // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
        .CLKFBOUT_MULT_F(C_MULT),       // Multiply value for all CLKOUT (2.000-64.000).
        .DIVCLK_DIVIDE(C_DIV1),         // Master division value (1-106)
        .CLKFBOUT_PHASE(0.0),           // Phase offset in degrees of CLKFB (-360.000-360.000).
        
        // Behaviour of the module.
        .BANDWIDTH("OPTIMIZED"),        // Jitter programming (OPTIMIZED, HIGH, LOW)
        .REF_JITTER1(0.0),              // Reference input jitter in UI (0.000-0.999).
        .CLKOUT4_CASCADE("FALSE"),      // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
        .STARTUP_WAIT("FALSE"),         // Delays DONE until MMCM is locked (FALSE, TRUE)
        
        // CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
        .CLKOUT0_DIVIDE_F(C_DIVVAR),    // Divide amount for CLKOUT0 (1.000-128.000).
        .CLKOUT1_DIVIDE(C_DIV100),      // Limited to 1-128, integer only.
        .CLKOUT2_DIVIDE(1),             // Limited to 1-128, integer only.
        .CLKOUT3_DIVIDE(1),             // Limited to 1-128, integer only.    
        .CLKOUT4_DIVIDE(1),             // Limited to 1-128, integer only.    
        .CLKOUT5_DIVIDE(1),             // Limited to 1-128, integer only.
        .CLKOUT6_DIVIDE(1),             // Limited to 1-128, integer only.
      
        // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
        .CLKOUT0_DUTY_CYCLE(0.5),
        .CLKOUT1_DUTY_CYCLE(0.5),
        .CLKOUT2_DUTY_CYCLE(0.5),
        .CLKOUT3_DUTY_CYCLE(0.5),
        .CLKOUT4_DUTY_CYCLE(0.5),
        .CLKOUT5_DUTY_CYCLE(0.5),
        .CLKOUT6_DUTY_CYCLE(0.5),
      
        // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
        .CLKOUT0_PHASE(0.0),
        .CLKOUT1_PHASE(0.0),
        .CLKOUT2_PHASE(0.0),
        .CLKOUT3_PHASE(0.0),
        .CLKOUT4_PHASE(0.0),
        .CLKOUT5_PHASE(0.0),
        .CLKOUT6_PHASE(0.0)
    )
    
    // Artix/Kintex 7 family MMCM block instantiation (base) ports.
    MMCME2_BASE_inst (
      
        // Clock Inputs: 1-bit (each) input: Clock input
        .CLKIN1(clkIn),                 // 1-bit input: Clock
              
        // Clock Outputs: 1-bit (each) output: User configurable clock outputs
        .CLKOUT0(clkVar_0),               // 1-bit output: CLKOUT0
        //.CLKOUT0B(CLKOUT0B),          // 1-bit output: Inverted CLKOUT0
        .CLKOUT1(clk100_0),              // 1-bit output: CLKOUT1
        //.CLKOUT1B(CLKOUT1B),          // 1-bit output: Inverted CLKOUT1
        //.CLKOUT2(CLKOUT2),            // 1-bit output: CLKOUT2
        //.CLKOUT2B(CLKOUT2B),          // 1-bit output: Inverted CLKOUT2
        //.CLKOUT3(CLKOUT3),            // 1-bit output: CLKOUT3
        //.CLKOUT3B(CLKOUT3B),          // 1-bit output: Inverted CLKOUT3
        //.CLKOUT4(CLKOUT4),            // 1-bit output: CLKOUT4
        //.CLKOUT5(CLKOUT5),            // 1-bit output: CLKOUT5
        //.CLKOUT6(CLKOUT6),            // 1-bit output: CLKOUT6
        
        // Feedback Clocks: 1-bit (each) output: Clock feedback ports
        .CLKFBOUT(clkFdbk),             // 1-bit output: Feedback clock
        //.CLKFBOUTB(CLKFBOUTB),        // 1-bit output: Inverted CLKFBOUT
        
        // Status Ports: 1-bit (each) output: MMCM status ports
        .LOCKED(locked),                // 1-bit output: LOCK
                
        // Control Ports: 1-bit (each) input: MMCM control ports
        .PWRDWN(0),                     // 1-bit input: Power-down
        .RST(!rstn),                    // 1-bit input: Reset
        
        // Feedback Clocks: 1-bit (each) input: Clock feedback ports
        .CLKFBIN(clkFdbk)               // 1-bit input: Feedback clock
   );
       
endmodule
