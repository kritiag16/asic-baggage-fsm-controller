module fsm_controller (
input clk,
input rst_n,
input bag_placed,
input weight_ready,
input [15:0] weight_digital,
input [1:0] flight_class,
input pay_confirm,
input remove_items,
input printer_ready,
input maintenance_mode,
input overweight_flag,
input scale_overload,
input sensor_fault,
input printer_fault,
output reg read_weight_en,
output reg compare_weight_en,
output reg calc_fee_en,
output reg prompt_fee_en,
output reg payment_en,
output reg print_tag_en,
output reg log_en,
output reg reset_all,
output reg fault_signal,
output reg in_maintenance
);
parameter IDLE = 4'd0;
parameter WAIT_FOR_BAG = 4'd1;
parameter READ_WEIGHT = 4'd2;
parameter CHECK_WEIGHT = 4'd3;
parameter PROMPT_FEE = 4'd4;
parameter WAIT_PAYMENT = 4'd5;
parameter PRINT_TAG = 4'd6;
parameter COMPLETE = 4'd7;
parameter ERROR_STATE = 4'd8;
parameter MAINTENANCE = 4'd9;
reg [3:0] current_state, next_state;
always @(posedge clk or negedge rst_n) begin
if (!rst_n)
current_state <= IDLE;
else
current_state <= next_state;
end
always @(*) begin
read_weight_en = 0;
compare_weight_en = 0;
calc_fee_en = 0;
prompt_fee_en = 0;
payment_en = 0;
print_tag_en = 0;
log_en = 0;
reset_all = 0;
fault_signal = 0;
in_maintenance = 0;
case (current_state)
IDLE: begin
if (maintenance_mode)
next_state = MAINTENANCE;
else
next_state = WAIT_FOR_BAG;
end
WAIT_FOR_BAG: begin
if (bag_placed)
next_state = READ_WEIGHT;
else
next_state = WAIT_FOR_BAG;
end
READ_WEIGHT: begin
read_weight_en = 1;
if (weight_ready)
next_state = CHECK_WEIGHT;
else
next_state = READ_WEIGHT;
end
CHECK_WEIGHT: begin
compare_weight_en = 1;
if (scale_overload || sensor_fault || printer_fault)
next_state = ERROR_STATE;
else if (overweight_flag)
next_state = PROMPT_FEE;
else
next_state = PRINT_TAG;
end
PROMPT_FEE: begin
prompt_fee_en = 1;
if (pay_confirm)
next_state = WAIT_PAYMENT;
else if (remove_items)
next_state = WAIT_FOR_BAG;
else
next_state = PROMPT_FEE;
end
WAIT_PAYMENT: begin
payment_en = 1;
if (pay_confirm)
next_state = PRINT_TAG;
else
next_state = WAIT_PAYMENT;
end
PRINT_TAG: begin
print_tag_en = 1;
log_en = 1;
if (printer_ready)
next_state = COMPLETE;
else
next_state = PRINT_TAG;
end
COMPLETE: begin
reset_all = 1;
next_state = IDLE;
end
ERROR_STATE: begin
fault_signal = 1;
next_state = MAINTENANCE;
end
MAINTENANCE: begin
in_maintenance = 1;
if (!maintenance_mode)
next_state = IDLE;
else
next_state = MAINTENANCE;
end
default: begin
next_state = IDLE;
end
endcase
end
endmodule
