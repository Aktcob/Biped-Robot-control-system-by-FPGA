`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:01:23 11/09/2015 
// Design Name: 
// Module Name:    sonic_detect 
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
module sonic_detect(clk,rst_n,trig,echo,distance);
input clk,rst_n;
input echo;  //from sonic  power
output trig;  //to sonic  power
output [23:0]distance;
reg [23:0]distance_reg;
//produce trig  signal
//period 60ms
reg test;

reg [21:0]cnt_period;
always @(posedge clk )
begin
	if(!rst_n)
		begin
			cnt_period<=0;
		end
	else  if(cnt_period==22'd3000000)
				begin
					cnt_period<=0;
				end
			else	
				cnt_period<=cnt_period+1'b1;
end

assign trig=((cnt_period>=22'd100)&(cnt_period<=22'd599))?1:0;

//detect echo  signal,compute the distance
wire start,finish;
reg [23:0]cnt;  //compute by the max distance,max time
reg echo_reg1,echo_reg2;
assign start=echo_reg1&~echo_reg2;   //posedge
assign finish=~echo_reg1&echo_reg2;	 //negedge
always @(posedge clk)
begin
	if(!rst_n)
		begin
			echo_reg1<=0;
			echo_reg2<=0;
		end
	else
		begin
			echo_reg1<=echo;
			echo_reg2<=echo_reg1;
		end
end
parameter idle=2'b00;
parameter state1=2'b01;
parameter state2=2'b10;
reg [1:0]state;
always @(posedge clk)
begin
	if(!rst_n)
		begin	
			state<=idle;
			cnt<=0;
		end
	else	
		begin
			case(state)
			idle: 	begin
							if(start)
								state<=state1;
							else
								state<=idle;
						end
			state1:	begin
							if(finish)
								state<=state2;
							else
								begin
									cnt<=cnt+1'b1;
									state<=state1;
								end
						end
			state2:  begin
							cnt<=0;
							distance_reg<=cnt;
							state<=idle;
						end
			default: state<=idle;
			endcase
		end
end
	
assign distance=distance_reg;
endmodule
