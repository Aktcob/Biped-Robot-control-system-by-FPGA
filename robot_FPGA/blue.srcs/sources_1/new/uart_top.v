`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/06/30 16:03:32
// Design Name: 
// Module Name: uart_top
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


module uart_top(
    input CLK,rst_n,rs232_rx,
    input [7:0]data_in,
    output rs232_tx,
    output [7:0] led
    );
    wire bps_start1,bps_start2;//
    wire clk_bps1,clk_bps2;
    wire [7:0] rx_data;   //接收数据存储器,用来存储接收到的数据,直到下一个数据接收
    wire rx_int;     //接收数据中断信号,接收过程中一直为高
    
       
    reg [32:0]count=0;  //计数器1用来 
    reg clk_2s;       //定时器
    parameter T1S=100000000; //2s更新一次状态 200 000 000 
    
    always@(posedge CLK)
    begin
      count<=count+1;
      if(count==T1S) 
          begin 
          count<=0; 
          clk_2s<=~clk_2s;      
          end
    end
    
//////////////////////////////////子模块端口申明///////////////////////////////////
    speed_select_rx     speed_rx(   //数据接收波特率选择模块
             .clk(clk_out),
             .rst_n(rst_n),
             .bps_start(bps_start1),
             .clk_bps(clk_bps1)
             );
            
    uart_rx    uart_rx(    //数据接收模块
             .clk(clk_out),
             .rst_n(rst_n),
             .bps_start(bps_start1),
             .clk_bps(clk_bps1),
             .rs232_rx(rs232_rx),
             .rx_data(rx_data),
             .rx_int(rx_int),
             .led(led)
            );
speed_select_rx  speed_tx(   //数据发送波特率控制模块
                     .clk(clk_out),
                     .rst_n(rst_n),
                     .bps_start(bps_start2),
                     .clk_bps(clk_bps2)         
                     );
                     
      uart_tx    uart_tx(
                     .clk(clk_out),
                     .rst_n(rst_n),
                     .bps_start(bps_start2),
                     .clk_bps(clk_bps2),
                     .rs232_tx(rs232_tx),
                     .rx_data(data_in),
                     .rx_int(clk_2s)        
                    );
                    
  clk_wiz_0 instance_name
                     (
                     // Clock in ports
                      .clk_in1(CLK),      // input clk_in1
                      // Clock out ports
                      .clk_out1(clk_out));    // output clk_out1                   
endmodule
