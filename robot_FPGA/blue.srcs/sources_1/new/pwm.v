`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/05/15 20:40:48
// Design Name: 
// Module Name: pwm
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


module pwm(
    input clk,
    input [7:0]duty,   //0-100占空比
    output reg pwm_out
    );
     //舵机周期20ms，占空比0.5ms~2.5ms对应的0~180度
     reg [32:0]count=0;
     parameter T20MS=2000000,T20US=2000;   //周期20ms
     always@(posedge clk)
     begin
        count<=count+1;
        if(count==T20MS) count<=0;
        pwm_out=(count< (duty*T20US) )?1:0;  //pwm
     end
endmodule
