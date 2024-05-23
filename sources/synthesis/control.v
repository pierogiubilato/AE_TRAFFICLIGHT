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
    parameter C_INT_WALK = 100 	        // Pedestrian ineterval [blinks].
 )(	
	// Timing.
	input rstb,                        // Reset (bar).  
	input clk,                         // Clock.
	input blink,                       // Timebase from external blinker.
	
	// External inputs.
	input inMode,                      // Pedestrian (1) / traffic (0) priority selector.
	input inTraffic,                   // Traffic sensor.
	input inPedestrian,                // Pedestrian button.
	
	output outPedLatch,                // Status of the pedestrian latch.
	output reg[1 : 0] outLight         // Output light selection.
);


   	// =========================================================================
    // ==                Local parameters, Registers and wires                ==
    // =========================================================================
    
    // SM states names.
    localparam sRed         = 2'b00;
    localparam sGreen       = 2'b01;
    localparam sYellow      = 2'b10;
    localparam sWalk        = 2'b11;

    // SM outputs. Here they are completely redundant, just
    // to show an example of pre-coding.
    localparam sRedOut      = 2'b00;
    localparam sGreenOut    = 2'b01;
    localparam sYellowOut   = 2'b10;
    localparam sWalkOut     = 2'b11;

    // SM state ragister.
    reg [1:0] rState = sRed;    // Safest state to start a semaphore!
    reg [1:0] rStateOld;        // Old state, used to generate the counter reset signal.
    
    // SM next state logic. THIS WILL NOT generate an actual Flip-Flop!
    reg [1:0] lStateNext;       // Next state register, does not require initialization.
    wire wStateJump;            // Signals state(S) transitions.
        
    // Interval timer register.
    reg [7:0] rTimer;           // BEWARE: vector must contain the biggest interval.
    
    // Pedestrian button register.
    reg rPedestrian = 1'b0;     // Pedestrian signal latch.



	// =========================================================================
    // ==                        Synchronous processes                        ==
    // =========================================================================

    
	// State machine main synchronous process. Transfer 'lStateNext' into 'rState'
	// The sensitivity list contains only "edged" events; the tool will infer the
	// reset condition from the first "if".
    always @(negedge rstb, posedge clk) begin
        
        // Reset (bar).
        if (rstb == 1'b0) begin
            rState <= sRed;
            rStateOld <= sRed;
            
        // State transition.
        end else begin
            
            // Store next state.
            rState <= lStateNext;
            
            // Store the current state (used by the counter to 
            // self-reset on state-change).
            rStateOld <= rState;
        end
    end
    
    // State machine synchronous output (here for example, redundant
    // for this specific application. In this case, the sensitivity 
    // list contains only asynchronous (no official clocks) signals.
    always @(rstb, rState) begin
        
        // Reset (bar).
        if (rstb == 1'b0) begin
            outLight <= sRedOut;
        end else begin
            case (rState)
                sRed: begin outLight <= sRedOut; end
                sGreen: begin outLight <= sGreenOut; end
                sYellow: begin outLight <= sYellowOut; end
                sWalk: begin outLight <= sWalkOut; end
            endcase            
        end
    end
    
    // Interval counter. It counts at every 'blink' positive edge transition.
    // It resets on 'rstb' and at every state transition. LOOK at the sensitivity
    // list: only "EDGED" events are used, otherwise the tool will not
    // correctly synthetize ot. (For simulation there are no issues).
    always @(negedge rstb, posedge wStateJump, posedge blink) begin
        
        // Master reset (bar).
        if (rstb == 1'b0) begin
            rTimer <= 0;
        
        // Reset because of a state jump.
        end else if(wStateJump == 1'b1) begin
            rTimer <= 0;
        
        // Increase the timer.
        end else begin
            rTimer <= rTimer + 1;
        end
    end
    
    // Pedestrian button LATCH. Stores the last value of the pedestrian button,
    // unless we are in reset or already in the pedestrian state, in which case
    // the value is reset to zero. 
    always @ (negedge rstb, posedge clk) begin
        
        // Reset (bar).
        if (rstb == 1'b0 || rState == sWalk) begin
            rPedestrian <= 1'b0;
        end else begin
            
            // Switch to '1' if the input is '1'.
            if (inPedestrian == 1'b1) begin
                rPedestrian <= 1'b1;
            end else begin    
                rPedestrian <= rPedestrian;
            end
        end
    end
    
    
    // =========================================================================
    // ==                      Asynchronous assignments                       ==
    // =========================================================================

	// State jump signal. It stays high for 1 clock cycle every time the state
	// changes. It is used to reset the counter at every state transition.
	assign wStateJump = (rState != rStateOld) ? 1'b1 : 1'b0;
	
	// Just show the status of the pedestrian latch.
	assign outPedLatch = rPedestrian;
		
	// State machine async process. Update the next state considering the present 
	// state ('rState') and the other conditions ('inMode', 'inPedestrian', 
	// 'inTraffic'). 
	// WARNING: this is a purely combinatorial process, no D-FF involved. Even
	// if 'lStateNext' is defined as register (reg), the tool will infer a simple
	// combinatorial path.
    always @(rState, rTimer, inMode, rPedestrian) begin
        
        // Select among states.
        case (rState)
            
            // Red.
            sRed: begin
                
                // The pedestrian has priority in 'inMode = 1', and shortens the red interval.
                if (rPedestrian == 1'b1 & inMode == 1'b1) begin
                    lStateNext <= sWalk;        // Force transition to walk.
                                    
                // Otherwise, just wait for the red interval to expire.
                end else begin
                    if (rTimer >= C_INT_RED) begin
                        
                        // Jump to èdestrian if the crosswalk has been boocked.
                        if (rPedestrian == 1'b1) begin
                            lStateNext <= sWalk;    // Jump to walk.
                        end else begin
                            lStateNext <= sGreen;   // Jump to green.
                        end        
                    end else begin
                        lStateNext <= sRed;     // Stay on red until tRed expires.
                    end
                end
            end
            
            // Green.
            sGreen: begin
                
                // The pedestrian has priority in 'inMode = 1', and shortens the green interval.
                if (rPedestrian == 1'b1 & inMode == 1'b1) begin
                    lStateNext <= sYellow;      // Force transition to yellow.
                
                // Otherwise, just wait for the green interval to expire.
                end else begin
                    if (rTimer >= C_INT_GREEN) begin
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
                    lStateNext <= sRed;
                end else begin    
                    lStateNext <= sYellow;      
                end
            end
                
            // Pedestrian.
            sWalk: begin
 
                // Jump only at the end of the pedestrian interval, and always to red for safety.
                if (rTimer >= C_INT_WALK) begin
                    lStateNext <= sRed;   // Timer expired, jump to red.
                end else begin    
                    lStateNext <= sWalk;  // Wait for interval to expire..
                end
            end
            
            // Default (recovery from errors).
            default: begin
               lStateNext <= sRed;
            end
        endcase
    end
    
endmodule


