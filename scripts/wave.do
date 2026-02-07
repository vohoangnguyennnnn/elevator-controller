onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /elevator_tb/clk
add wave -noupdate /elevator_tb/rst
add wave -noupdate /elevator_tb/floor_req
add wave -noupdate /elevator_tb/floor_pos
add wave -noupdate /elevator_tb/door_open
add wave -noupdate /elevator_tb/moving_up
add wave -noupdate /elevator_tb/moving_down
add wave -noupdate /elevator_tb/wait_cycles/n
add wave -noupdate /elevator_tb/wait_cycles/i
add wave -noupdate /elevator_tb/press_floor/f
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {964147 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1013250 ps}
