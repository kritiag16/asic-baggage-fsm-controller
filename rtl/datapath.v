module datapath (
input clk,
input rst_n,
input read_weight_en,
input compare_weight_en,
input calc_fee_en,
input log_en,
input [15:0] weight_digital, output from scale
input [1:0] flight_class, // 00: Economy, 01: Business, 10: First
input [15:0] limit_economy,
input [15:0] limit_business,
input [15:0] limit_first,
input [7:0] fee_per_kg,
output reg overweight_flag,
output reg [15:0] fee_amount,
output reg [15:0] final_weight,
output reg [15:0] log_weight,
output reg [15:0] log_fee,
output reg log_valid
);
reg [15:0] current_limit;
reg [15:0] weight_reg;
reg [15:0] excess_weight;
always @(posedge clk or negedge rst_n) begin
if (!rst_n)
weight_reg <= 0;
else if (read_weight_en)
weight_reg <= weight_digital;
end
always @(*) begin
case (flight_class)
2'b00: current_limit = limit_economy;
2'b01: current_limit = limit_business;
2'b10: current_limit = limit_first;
default: current_limit = limit_economy;
endcase
end
always @(posedge clk or negedge rst_n) begin
if (!rst_n)
overweight_flag <= 0;
else if (compare_weight_en)
overweight_flag <= (weight_reg > current_limit);
end
always @(posedge clk or negedge rst_n) begin
if (!rst_n) begin
fee_amount <= 0;
excess_weight <= 0;
end else if (calc_fee_en) begin
if (weight_reg > current_limit) begin
excess_weight <= weight_reg - current_limit;
fee_amount <= (weight_reg - current_limit) * fee_per_kg;
end else begin
excess_weight <= 0;
fee_amount <= 0;
end
end
end
always @(posedge clk or negedge rst_n) begin
if (!rst_n) begin
final_weight <= 0;
log_weight <= 0;
log_fee <= 0;
log_valid <= 0;
end else if (log_en) begin
final_weight <= weight_reg;
log_weight <= weight_reg;
log_fee <= fee_amount;
log_valid <= 1;
end else begin
log_valid <= 0;
end
end
endmodule
