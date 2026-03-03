module fsm_tb;
reg clk;
reg rst_n;
reg bag_placed, weight_ready, pay_confirm, remove_items, printer_ready, maintenance_mode;
reg [15:0] weight_digital;
reg [1:0] flight_class;
reg scale_overload, sensor_fault, printer_fault;
reg [15:0] limit_economy = 16'd15000; // 15.0 kg
reg [15:0] limit_business = 16'd25000; // 25.0 kg
reg [15:0] limit_first = 16'd35000; // 35.0 kg
reg [7:0] fee_per_kg = 8'd10;
wire read_weight_en, compare_weight_en, calc_fee_en;
wire prompt_fee_en, payment_en, print_tag_en, log_en;
wire reset_all, fault_signal, in_maintenance;
wire overweight_flag;
wire [15:0] fee_amount, final_weight;
wire [15:0] log_weight, log_fee;
wire log_valid;
fsm_controller uut_fsm (
.clk(clk), .rst_n(rst_n),
.bag_placed(bag_placed),
.weight_ready(weight_ready),
.weight_digital(weight_digital),
.flight_class(flight_class),
.pay_confirm(pay_confirm),
.remove_items(remove_items),
.printer_ready(printer_ready),
.maintenance_mode(maintenance_mode),
.overweight_flag(overweight_flag),
.scale_overload(scale_overload),
.sensor_fault(sensor_fault),
.printer_fault(printer_fault),
.read_weight_en(read_weight_en),
.compare_weight_en(compare_weight_en),
.calc_fee_en(calc_fee_en),
.prompt_fee_en(prompt_fee_en),
.payment_en(payment_en),
.print_tag_en(print_tag_en),
.log_en(log_en),
.reset_all(reset_all),
.fault_signal(fault_signal),
.in_maintenance(in_maintenance)
);

datapath uut_datapath (
.clk(clk), .rst_n(rst_n),
.read_weight_en(read_weight_en),
.compare_weight_en(compare_weight_en),
.calc_fee_en(calc_fee_en),
.log_en(log_en),
.weight_digital(weight_digital),
.flight_class(flight_class),
.limit_economy(limit_economy),
.limit_business(limit_business),
.limit_first(limit_first),
.fee_per_kg(fee_per_kg),
.overweight_flag(overweight_flag),
.fee_amount(fee_amount),
.final_weight(final_weight),
.log_weight(log_weight),
.log_fee(log_fee),
.log_valid(log_valid)
);
always #5 clk = ~clk;
task simulate_bag(
input [1:0] class_type,
input [15:0] weight,
input expect_overweight
);
begin
$display("----- Simulating bag: class=%b, weight=%d", class_type, weight);
bag_placed = 1; flight_class = class_type; weight_digital = weight;
#10;
weight_ready = 1;
#10;
weight_ready = 0;
bag_placed = 0;
if (expect_overweight) begin
pay_confirm = 1;
#20;
pay_confirm = 0;
end
printer_ready = 1;
#20;
printer_ready = 0;
#20;
end
endtask
initial begin
clk = 0;
rst_n = 0;
bag_placed = 0; weight_ready = 0; weight_digital = 0;
flight_class = 2'b00;
pay_confirm = 0; remove_items = 0; printer_ready = 0;
scale_overload = 0; sensor_fault = 0; printer_fault = 0;
maintenance_mode = 0;
#20 rst_n = 1;
simulate_bag(2'b00, 16'd14000, 0); // 14.0 kg
Baggage (fee required)
simulate_bag(2'b00, 16'd18000, 1); // 18.0 kg (3kg excess)
simulate_bag(2'b01, 16'd24000, 0); // 24.0 kg
maintenance_mode = 1;
#20;
maintenance_mode = 0;
#100;
$finish;
end
endmodule
