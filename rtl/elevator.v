`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2026 04:34:38 PM
// Design Name: 
// Module Name: elevator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module elevator #(
    parameter integer FLOORS = 8 ,
    parameter integer POS_W = 3,
    parameter integer DOOR_OPEN = 5
    )(
    input wire clk,
    input wire rst,
    input wire [FLOORS-1:0] floor_req,   // bitmask floor requests
    output reg [POS_W-1:0] floor_pos,    // current floor
    output reg door_open,
    output reg moving_up,
    output reg moving_down
    );
    
    // STATE
    localparam [2:0] STATE_IDLE = 3'd0;
    localparam [2:0] STATE_UP = 3'd1;
    localparam [2:0] STATE_DOWN = 3'd2;
    localparam [2:0] STATE_STOP = 3'd3;
    localparam [2:0] STATE_DOOR = 3'd4;
    
    reg [2:0] state_q, state_d;
    reg [FLOORS-1:0] req_pending_q, req_pending_d;
    reg dir_up_q, dir_up_d;
    reg [POS_W-1:0] floor_pos_d;
    
    //funtion counter 
    function integer clog2;
        input integer value;
        integer v;
            begin
                v = value - 1;
                clog2 = 0;
                while (v>0) begin
                    clog2 = clog2 +1;
                    v = v >> 1;
                end
            end
        endfunction
        
    //  door open time
    localparam integer DOOR_CNT = (DOOR_OPEN <= 1) ? 1 : clog2(DOOR_OPEN);
    
    reg [DOOR_CNT-1:0] door_cnt_q, door_cnt_d;
    
    // Scan direction elevator
    function [1:0] scan_above_below;
        input [FLOORS-1:0] pending;
        input [POS_W-1:0] current;
        integer i;
        reg req_above;
        reg req_below;
        begin
            req_above = 1'b0;
            req_below = 1'b0;
            for (i = 0;i < FLOORS;i = i + 1) begin
                if ((i > current) && (pending[i])) req_above = 1'b1;
                if ((i < current) && (pending[i])) req_below = 1'b1;
            end
            scan_above_below = {req_above,req_below};
        end
    endfunction
    
    //decode function scan_above_below
    reg req_above;
    reg req_below;
    reg [1:0] scan_dir;
    
    reg [POS_W-1:0] next_pos;
    
    //  Combinational logic
    always @(*) begin
    // Defaults
    state_d = state_q;
    door_cnt_d = door_cnt_q;
    dir_up_d = dir_up_q;
    floor_pos_d = floor_pos;
    next_pos = floor_pos;
    
    req_pending_d = req_pending_q | floor_req;
    
    if (state_q == STATE_DOOR) begin
        if(floor_pos < FLOORS) 
            req_pending_d[floor_pos] = 1'b0;
    end
    
    scan_dir = scan_above_below(req_pending_d,floor_pos);
    req_above = scan_dir[1];
    req_below = scan_dir[0];
    
    case (state_q)
        STATE_IDLE: begin
            door_cnt_d = {DOOR_CNT{1'b0}};

                // request at current floor -> open door
                if ((floor_pos < FLOORS) && req_pending_d[floor_pos]) begin
                    state_d    = STATE_DOOR;
                    door_cnt_d = {DOOR_CNT{1'b0}};
                end
                else if (req_above && !req_below) begin
                    state_d  = STATE_UP;
                    dir_up_d = 1'b1;
                end
                else if (!req_above && req_below) begin
                    state_d  = STATE_DOWN;
                    dir_up_d = 1'b0;
                end
                else if (req_above && req_below) begin
                    state_d = (dir_up_q) ? STATE_UP : STATE_DOWN;
                end
                else begin
                    state_d = STATE_IDLE;
                end
            end

            // UP STATE
            STATE_UP: begin
                // move up one floor per cycle
                if (floor_pos < (FLOORS-1)) begin
                    next_pos   = floor_pos + {{(POS_W-1){1'b0}},1'b1};
                    floor_pos_d = next_pos;

                    // If arrive at the FLOOR and are instructed to immediately enter the STOP state
                    if ((next_pos < FLOORS) && req_pending_d[next_pos]) begin
                        state_d  = STATE_STOP;
                        dir_up_d = 1'b1;
                    end
                end else begin
                    state_d = STATE_IDLE;   // already at top floor
                end
            end

            // DOWN STATE
            STATE_DOWN: begin
                // move down one floor per cycle, if not at bottom
                if (floor_pos > 0) begin
                    next_pos    = floor_pos - {{(POS_W-1){1'b0}},1'b1};
                    floor_pos_d = next_pos;

                    if ((next_pos < FLOORS) && req_pending_d[next_pos]) begin
                        state_d  = STATE_STOP;
                        dir_up_d = 1'b0;
                    end
                end else begin
                    state_d = STATE_IDLE;   // already at bottom floor
                end
            end

            // STOP STATE
            STATE_STOP: begin
                door_cnt_d = {DOOR_CNT{1'b0}};
                if ((floor_pos < FLOORS) && req_pending_d[floor_pos])
                    state_d = STATE_DOOR;
                else
                    state_d = STATE_IDLE;
            end

            // OPEN DOOR STATE
            STATE_DOOR: begin
                if (DOOR_OPEN <= 1) begin   // case special
                    // special case: 1 cycle open
                    door_cnt_d = {DOOR_CNT{1'b0}};

                    // choose next direction based on remaining pending
                    if (req_above && !req_below) begin
                        state_d  = STATE_UP;  dir_up_d = 1'b1;
                    end else if (!req_above && req_below) begin
                        state_d  = STATE_DOWN;  dir_up_d = 1'b0;
                    end else if (req_above && req_below) begin
                        state_d = (dir_up_q) ? STATE_UP : STATE_DOWN;
                    end else begin
                        state_d = STATE_IDLE;
                    end
                end
                else begin
                    // normal counter mode
                    if (door_cnt_q >= (DOOR_OPEN-1)) begin
                        door_cnt_d = {DOOR_CNT{1'b0}};

                        if (req_above && !req_below) begin
                            state_d  = STATE_UP;  dir_up_d = 1'b1;
                        end else if (!req_above && req_below) begin
                            state_d  = STATE_DOWN;  dir_up_d = 1'b0;
                        end else if (req_above && req_below) begin
                            state_d = (dir_up_q) ? STATE_UP : STATE_DOWN;
                        end else begin
                            state_d = STATE_IDLE;
                        end
                    end
                    else begin
                        door_cnt_d = door_cnt_q + {{(DOOR_CNT-1){1'b0}},1'b1};
                    end
                end
            end

            default: begin
                state_d = STATE_IDLE;
            end
        endcase
    end
    
    // Sequential logic
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            state_q <= STATE_IDLE;
            req_pending_q <= {FLOORS{1'b0}};
            floor_pos <= {POS_W{1'b0}};
            door_cnt_q    <= {DOOR_CNT{1'b0}};
            dir_up_q      <= 1'b1;
        end
        else begin
            state_q <= state_d;
            req_pending_q <= req_pending_d;
            floor_pos <= floor_pos_d;
            door_cnt_q <= door_cnt_d;
            dir_up_q <= dir_up_d;
        end
    end
    
    //  Outputs
    always @(*) begin
        door_open = (state_q == STATE_DOOR);
        moving_up = (state_q == STATE_UP);
        moving_down = (state_q == STATE_DOWN);
    end
endmodule