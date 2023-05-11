/*#############################################################################\
##                                                                            ##
##       APPLIED ELECTRONICS - Physics Department - University of Padova      ##
##                                                                            ## 
##       ---------------------------------------------------------------      ##
##                                                                            ##
##                           Traffic light example                            ##
##                                                                            ##
\#############################################################################*/

// INFO
// The control module implements the State Machine prforming the traffic light
// operations.


// -----------------------------------------------------------------------------
// --                                PARAMETERS                               --
// -----------------------------------------------------------------------------
//
// C_CLK_FRQ:       frequency of the clock in [cycles per second] {100000000}. 
// C_INTERVAL:      the time interval the signal must be stable to pass through
//					and reach the fabric. [ms] {10}.


// -----------------------------------------------------------------------------
// --                                I/O PORTS                                --
// -----------------------------------------------------------------------------
//
// rstb:                INPUT, synchronous reset, ACTIVE LOW. 
// clk:                 INPUT, master clock.
// inMode:              INPUT, pedestrian mode (0 = vehicles priority, 1 = pedestrian priority).
// inPedestrian:        INPUT, pedestrian crossing.
// inTraffic:           INPUT, traffic status (0=empty road, 1=vehicles on road).
// outLight [1 : 0]:    OUTPUT: selected light

// Tool timescale.
`timescale 1 ns / 1 ps

// Behavioural.
module control #(
    
    // Intervals. BEWARE: the ranges must fit within the 'rTimer' range!
    parameter C_INT_RED = 200, 	        // Red ineterval [blinks].
    parameter C_INT_GREEN = 200, 	    // Green ineterval [blinks].
    parameter C_INT_YELLOW = 20, 	    // Yellow ineterval [blinks].
    parameter C_INT_PEDESTRIAN = 100 	// Pedestrian ineterval [blinks].
 )(	
	// Timing.
	input rstb,                        // Reset (bar).  
	input clk,                         // Clock.
	input blink,                       // Timebase from external blinker.
	
	// External inputs.
	input inMode,                      // Pedestrian (1) / traffic (0) priority selector.
	input inTraffic,                   // Traffic sensor.
	input inPedestrian,                // Pedestrian button.
	output reg[1 : 0] outLight         // Output light selection.
);


   	// =========================================================================
    // ==                Local parameters, Registers and wires                ==
    // =========================================================================
    
    // SM states names.
    localparam sRed         = 2'b00;
    localparam sGreen       = 2'b01;
    localparam sYellow      = 2'b10;
    localparam sPedestrian  = 2'b11;

    // SM outputs.
    localparam sRedOut          = 2'b00;
    localparam sGreenOut        = 2'b01;
    localparam sYellowOut       = 2'b10;
    localparam sPedestrianOut   = 2'b11;

    // SM state ragister.
    reg [1:0] rState = sRed;    // Safest state to start a semaphore!
    
    // SM next state logic. THIS WILL NOT generate an actual Flip-Flop!
    reg [1:0] lStateNext;       // Next state register, does not require initialization.
    
    // Interval timer register.
    reg [7:0] rTimer;           // BEWARE: vector must contain the biggest interval.
    reg rStateJump = 1'b0;      // Latch to record states transitions.    
    
    // Pedestrian button register.
    reg rPedestrian = 1'b0;     // Pedestrian signal latch.



	// =========================================================================
    // ==                        Synchronous processes                        ==
    // =========================================================================

	// State machine main synchronous process. Transfer 'lStateNext' into 'rState'
    always @(rstb, posedge clk, rTimer) begin
        
        // Reset (bar).
        if (rstb == 1'b0) begin
            rState <= sRed;
            outLight <= 2'b00;
        
        // State transition.
        end else begin
            
            // Store next state.
            rState <= lStateNext;
            
            // Latch if there has been a state transition.
            // This is necessary only to synchronize the interval counter,
            // not for the state machine itself.
            if (rState != lStateNext) begin 
                rStateJump <= 1'b1;
            end else begin
                if (rTimer == 0) begin
                    rStateJump <= 1'b0;
                end
            end
        end
    end
    
    // State machine synchronous output.
    always @(rstb, rState) begin
        
        // Reset (bar).
        if (rstb == 1'b0) begin
            outLight <= sRedOut;
        end else begin
            case (rState)
                sRed: begin outLight <= sRedOut; end
                sGreen: begin outLight <= sGreenOut; end
                sYellow: begin outLight <= sYellowOut; end
                sPedestrian: begin outLight <= sPedestrianOut; end
            endcase            
        end
    end
    
    // Interval counter. It counts at every 'blink' positive edge transition.
    // It resets on 'rstb' and at every state transition.
    always @(rstb, posedge blink) begin
        
        // Reset (bar) the timer.
        if (rstb == 1'b0 | rStateJump == 1'b1) begin
            rTimer <= 0;
        end else begin
            rTimer <= rTimer + 1;
        end
    end
    
    // Pedestrian button latch. Stores the last value of the pedestrian button,
    // unless we are in reset or already in the pedestrian state, in which case
    // the value is reset to zero. 
    always @(rstb, posedge clk, rState, posedge inPedestrian) begin
        
        // Reset (bar).
        if (rstb == 1'b0 || rState == sPedestrian) begin
            rPedestrian <= 1'b0;
        end else begin
            rPedestrian <= rPedestrian | inPedestrian;
        end
    end
    
    
    // =========================================================================
    // ==                      Asynchronous assignments                       ==
    // =========================================================================

	
	// State machine async process. Update the next state considering the present 
	// state ('rState') and the other conditions ('inMode', 'inPedestrian', 
	// 'inTraffic'). 
	// WARNING: this is a purely combinatorial process, no D-FF involved. Even
	// if 'lStateNext' is defined as register (reg), the tool will infer a simple
	// combinatorial path.
    always @(rState, rTimer, inMode, inPedestrian, inTraffic) begin
        
        // Select among states.
        case (rState)
            
            // Red.
            sRed: begin
                // The pedestrian has priority in 'inMode = 1', and shortens the red interval.
                if (inPedestrian == 1'b1 & inMode == 1'b1) begin
                    lStateNext <= sPedestrian;  // Force transition to pedestrian.
                                    
                // Otherwise, just wait for the red interval to expire.
                end else begin
                    if (rTimer >= C_INT_RED) begin
                        lStateNext <= sGreen;   // Jump only if tRed expired.
                    end else begin
                        lStateNext <= sRed;     // Stay on red until tRed expires.
                    end
                end
            end
            
            // Green.
            sGreen: begin
                
                // The pedestrian has priority in 'inMode = 1', and shortens the green interval.
                if (inPedestrian == 1'b1 & inMode == 1'b1) begin
                    lStateNext <= sYellow;      // Force transition to yellow.
                
                // Otherwise, just wait for the green interval to expire.
                end else begin
                    if (rTimer >= C_INT_GREEN & rStateJump == 1'b0) begin
                        lStateNext <= sYellow;  // No pedestrian priority, jump only if tGreen expired.
                    end else begin
                        lStateNext <= sGreen;   // Stay on green until tGreen expires.
                    end
                end
            end
                
            // Yellow.
            sYellow: begin
                
                // Jump only at the end of the yellow interval, always to red.
                if (rTimer >= C_INT_YELLOW) begin
                    lStateNext <= sRed;         // There is a pedestrian, jump to pedestrian.
                end else begin    
                    lStateNext <= sYellow;      // There is NO pedestrian, jump to red.
                end
            end
                
            // Pedestrian.
            sPedestrian: begin
 
                // Jump only at the end of the pedestrian interval, and always to red for safety.
                if (rTimer >= C_INT_PEDESTRIAN) begin
                    lStateNext <= sRed;         // Timer expired, jump to red.
                end else begin    
                    lStateNext <= sPedestrian;  // Wait for interval to expire..
                end
            end
            
            // Default (recovery from errors).
            default: begin
               lStateNext <= sRed;
            end
        endcase
    end
    
endmodule


