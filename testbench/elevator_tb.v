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

  // clock generation
  initial clk = 0;
  always #5 clk = ~clk;   // 10ns period

  // wait N cycles clock
  task wait_cycles(input integer n);
    integer i;
    begin
      for (i = 0; i < n; i = i + 1)
        @(posedge clk);
    end
  endtask

  // press one floor
  task press_floor(input integer f);
    begin
      @(negedge clk);
      floor_req = (1 << f);
      @(negedge clk);
      floor_req = 0;
    end
  endtask

  initial begin
    // init
    floor_req = 0;
    rst = 1;
    wait_cycles(3);
    rst = 0;

    // press current floor
    press_floor(0);
    wait_cycles(10);

    // go up
    press_floor(3);
    wait_cycles(20);

    // go down
    press_floor(1);
    wait_cycles(20);

    // multiple requests
    @(negedge clk);
    floor_req = (1<<2) | (1<<5);
    @(negedge clk);
    floor_req = 0;

    wait_cycles(40);

    $finish;
  end

endmodule


