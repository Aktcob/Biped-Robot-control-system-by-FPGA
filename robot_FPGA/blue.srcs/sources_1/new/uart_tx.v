`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/06/30 16:36:30
// Design Name: 
// Module Name: uart_tx
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


module uart_tx(
        clk,
        rst_n,
        bps_start,
        clk_bps,
        rs232_tx,
        rx_data,
        rx_int
    );
 input clk;
    input rst_n;
    input clk_bps;//中间采样点
    input [7:0] rx_data;//接收数据寄存器
    input rx_int;//数据接收中断信号
    output rs232_tx;//发送数据信号
    output bps_start;//发送信号置位
    
    reg rx_int0,rx_int1,rx_int2;//信号寄存器,捕捉下降沿
    wire neg_rx_int;    //下降沿标志
    
    always @(posedge clk or negedge rst_n) begin
     if(!rst_n) begin
      rx_int0 <= 1'b0;
      rx_int1 <= 1'b0;
      rx_int2 <= 1'b0;
     end
     else begin
       rx_int0 <= rx_int;
       rx_int1 <= rx_int0;
       rx_int2 <= rx_int1;
     end
    end
 
     assign neg_rx_int = ~rx_int1 & rx_int2;//捕捉下沿
     
     reg [7:0] tx_data;//待发送数据
     reg bps_start_r;
     reg tx_en;//发送信号使能,高有效
     reg [3:0] num;
    
    always @(posedge clk or negedge rst_n) begin
     if(!rst_n) begin
      bps_start_r <= 1'bz;
      tx_en <= 1'b0;
      tx_data <= 8'd0;
     end
  else if(neg_rx_int) begin//当检测到下沿的时候,数据开始传送
      bps_start_r <= 1'b1;
      tx_data <= rx_data;
      tx_en <= 1'b1;
     end
     else if(num==4'd11) begin
      bps_start_r <= 1'b0;
      tx_en <= 1'b0;
     end 
    end
 assign bps_start = bps_start_r;
    
    reg rs232_tx_r;
    always @(posedge clk or negedge rst_n) begin
     if(!rst_n) begin
      num<=4'd0;
      rs232_tx_r <= 1'b1;
     end
     else if(tx_en) begin
      if(clk_bps) begin
       num<=num+1'b1;
       case(num)
       4'd0: rs232_tx_r <= 1'b0;//起始位
       4'd1: rs232_tx_r <= tx_data[0];//数据位 开始
       4'd2: rs232_tx_r <= tx_data[1];
       4'd3: rs232_tx_r <= tx_data[2];
       4'd4: rs232_tx_r <= tx_data[3];
       4'd5: rs232_tx_r <= tx_data[4];
       4'd6: rs232_tx_r <= tx_data[5];
       4'd7: rs232_tx_r <= tx_data[6];
       4'd8: rs232_tx_r <= tx_data[7];
       4'd9: rs232_tx_r <= 1'b1;//数据结束位,1位
       default: rs232_tx_r <= 1'b1;
     endcase
    end
    else if(num==4'd11)
     num<=4'd0;//发送完成,复位
   end
  end
  assign rs232_tx =rs232_tx_r;
endmodule
