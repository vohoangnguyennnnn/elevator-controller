`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/17/2026 06:22:28 PM
// Design Name: 
// Module Name: elevator_tb
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

module elevator_tb;

  // Parameters
  localparam FLOORS = 8;
  localparam POS_W  = 3;

  reg clk;
  reg rst;
  reg [FLOORS-1:0] floor_req;

  wire [POS_W-1:0] floor_pos;
  wire door_open;
  wire moving_up;
  wire moving_down;

  elevator dut (
    .clk(clk),
    .rst(rst),
    .floor_req(floor_req),
    .floor_pos(floor_pos),
    .door_open(door_open),
    .moving_up(moving_up),
    .moving_down(moving_down)
  );

  // Clock generation: 10ns period
  initial clk = 1'b0;
  always #5 clk = ~clk;

  // MONITOR: log trạng thái mỗi chu kỳ
  always @(posedge clk) begin
    if (!rst) begin
          $display("[%0t] pos=%0d | req=%b | door=%b | up=%b | dn=%b",
             $time,
             floor_pos,
             floor_req,
             door_open,
             moving_up,
             moving_down);
    end
  end

  // Task: wait N clock cycles
  task wait_cycles(input integer n);
    integer i;
    begin
      for (i = 0; i < n; i = i + 1)
        @(posedge clk);
    end
  endtask

  // Task: press one floor 
  task press_floor(input integer f);
    begin
      if (f < 0 || f >= FLOORS) begin
        $display("[%0t] ERROR: invalid floor index %0d", $time, f);
      end else begin
        @(negedge clk);
        floor_req = (1 << f);
        @(negedge clk);
        floor_req = {FLOORS{1'b0}};
      end
    end
  endtask

  // Test sequence
  initial begin
    // init
    floor_req = 0;
    rst = 1'b1;

    // hold reset
    wait_cycles(3);
    rst = 1'b0;

    // Case 1: press current floor
    press_floor(0);     // real floor = 1
    wait_cycles(10);

    // Case 2: go up
    press_floor(3);     // real floor = 4
    wait_cycles(20);

    // Case 3: go down
    press_floor(1);     // real floor = 2
    wait_cycles(20);

    // Case 4: multiple requests
    @(negedge clk);
    floor_req = (1<<2) | (1<<5); // real floors 3 & 6
    @(negedge clk);
    floor_req = 0;

    wait_cycles(40);

    $display("=== SIMULATION FINISHED ===");
    $finish;
  end

endmodule



