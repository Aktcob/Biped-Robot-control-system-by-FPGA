`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:59:12 11/09/2015 
// Design Name: 
// Module Name:    sonic 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module sonic(clk,rst_n,trig,echo,sel,data,distance);
input clk,rst_n,echo;
output trig;
output [7:0]data;
output [3:0]sel;
output distance;
wire [23:0]distance;

sonic_detect   i1(.clk(clk_out),
						.rst_n(rst_n),
						.distance(distance),
						.trig(trig),
						.echo(echo)
						);
						
smg_ip_model   i2(.clk(clk_out),
						.data(distance[23:8]),
						.sm_wei(sel),
						.sm_duan(data)
						);
clk_wiz_0 instance_name
                                           (
                                           // Clock in ports
                                            .clk_in1(clk),      // input clk_in1
                                            // Clock out ports
                                            .clk_out1(clk_out));    // output clk_out1   
endmodule
