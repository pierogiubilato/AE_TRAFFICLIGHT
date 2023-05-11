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
module debounce_tb ();

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
    reg rIn;

    // DAta out.
    wire wOut;



    // ==========================================================================
    // ==                                 DUTs                                 ==
    // ==========================================================================

    // Instantiate the DUT
    debounce #(
        .C_CLK_FRQ(C_CLK_FRQ),
        .C_INTERVAL(C_BTN_INTERVAL)
    ) DUT (
        .rstb(rRstb), 
        .clk(rClk), 
        .in(rIn), 
        .out(wOut)
    );


    // Initialize Inputs
    initial begin
		$display ($time, " << Starting the Simulation >> ");
        rRstb = 1'b0;
		rClk = 1'b0;
        #200 rRstb = 1'b1;
        rIn = 1'b0;
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
		
		#40000 rIn = 1'b1;
		#900 rIn = 1'b0;		
		#200 rIn = 1'b1;	
		#2300 rIn = 1'b0;				
		#1800 rIn = 1'b1;
        #70000 rIn = 1'b0;
	    #9000 rIn = 1'b1;		
		#30000 rIn = 1'b0;
        #800 rIn = 1'b1;
		#300 rIn = 1'b0;		
		#700 rIn = 1'b1;
        #600 rIn = 1'b0;
	    #60000 rIn = 1'b1;		
        #2000 rIn = 1'b0;

	end

endmodule