/*#############################################################################\
##                                                                            ##
##       APPLIED ELECTRONICS - Physics Department - University of Padova      ##
##                                                                            ## 
##       ---------------------------------------------------------------      ##
##                                                                            ##
##                           Traffic light example                            ##
##                                                                            ##
\#############################################################################*/


// Set timescale (default time unit if not otherwise specified).
`timescale 1ns / 1ps

// Define Module for Test Fixture
module light_tb ();

    // ==========================================================================
    // ==                               Parameters                             ==
    // ==========================================================================
    
    // Timing properties.
    parameter C_CLK_FRQ         = 100000000;    // Main clock frequency [Hz].
    parameter C_CLK_JTR         = 50;           // Main clock jitter [ps].
    localparam real C_CLK_PERIOD = 1E9 / C_CLK_FRQ;  // Master clock period [ns].
        
    // Button/switch properties.
    parameter C_BTN_INTERVAL    = 0.010;       // Interval before stable [ms].

    
    // ==========================================================================
    // ==                              Seeding                                 ==
    // ==========================================================================
    
    // Seeding for (repeatable) random number generation.
    static int seed = $urandom + 0;


    // ==========================================================================
    // ==                                Signals                               ==
    // ==========================================================================
            
    // Timing signal.
    reg rRstb;
    reg rClk;
    
    // Data in.
    reg [1:0] rSel;

    // Data out.
    wire [11:0] wOut;



    // ==========================================================================
    // ==                                 DUTs                                 ==
    // ==========================================================================

    // Instantiate the UUT
    light #(
        .C_COLOR("100 010 110 111")
    ) DUT (
        .rstb(rRstb),
        .clk(rClk),
        .inSel(rSel), 
        .outLED(wOut)
    );

    // Initialize Inputs
    initial begin
		$display ($time, " << Starting the Simulation >> ");
        rRstb = 1'b0;
		rClk = 1'b0;
        #200 rRstb = 1'b1;
        rSel = 2'b00;
    end

    // Main clock generation. This process generates a clock with period equal to 
    // C_CLK_PERIOD. It also add a pseudorandom jitter, normally distributed 
    // with mean 0 and standard deviation equal to 'kClockJitter'.  
    always begin
        #(0.001 * $dist_normal(seed, 1000.0 * C_CLK_PERIOD / 2, C_CLK_JTR));
        rClk = ! rClk;
    end  

    // Pseudosequence.
	always begin
		#2000 rSel = 2'b00;
		#1000 rSel = 2'b01;		
		#1000 rSel = 2'b10;	
		#1000 rSel = 2'b11;				
		#1000 rSel = 2'b00;
        #2000 rSel = 2'b01;
	    #2000 rSel = 2'b10;		
		#2000 rSel = 2'b11;
	end
endmodule