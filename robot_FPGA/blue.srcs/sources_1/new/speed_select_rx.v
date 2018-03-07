`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/06/30 16:29:02
// Design Name: 
// Module Name: speed_select_rx
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


module speed_select_rx(
    input clk,rst_n,bps_start,
    output clk_bps
    );
// `define BPS_PARA 5207;//9600波特率分频计数值
// `define BPS_PARA_2 2603;//计数一半时采样
    reg[13:0] cnt;//分频计数器
    reg clk_bps_r;//波特率时钟寄存器
    
    reg[2:0] uart_ctrl;//波特率选择寄存器
    
    always @(posedge clk or negedge rst_n)
     if(!rst_n)
      cnt<=14'd0;
     else if((cnt==5207)|| !bps_start)//判断计数是否达到1个脉宽
      cnt<=14'd0;
     else
      cnt<=cnt+1'b1;//波特率时钟启动
      
    always @(posedge clk or negedge rst_n) begin
     if(!rst_n)
      clk_bps_r<=1'b0;
     else if(cnt==2603)//当波特率计数到一半时,进行采样存储
      clk_bps_r<=1'b1;
     else
      clk_bps_r<=1'b0;
    end
    assign clk_bps = clk_bps_r;//将采样数据输出给uart_rx模块
endmodule
