`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/06/30 16:32:25
// Design Name: 
// Module Name: uart_rx
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


module uart_rx(
        clk,
        rst_n,
        bps_start,
        clk_bps,
        rs232_rx,
        rx_data,
        rx_int,
        led
    );
    input clk;   //ʱ��
    input rst_n;  //��λ
    input rs232_rx; //���������ź�
    input clk_bps;  //�ߵ�ƽʱΪ�����ź��м������
    output bps_start; //�����ź�ʱ,������ʱ���ź���λ
    output [7:0] rx_data;//�������ݼĴ���
    output rx_int;  //���������ж��ź�,���չ�����Ϊ��
    output reg [7:0]led;
    reg rs232_rx0,rs232_rx1,rs232_rx2,rs232_rx3;//�������ݼĴ���
    wire neg_rs232_rx;//��ʾ�����߽��յ�����
    
 always @(posedge clk or negedge rst_n) begin
     if(!rst_n) begin
      rs232_rx0 <= 1'b0;
      rs232_rx1 <= 1'b0;
      rs232_rx2 <= 1'b0;
      rs232_rx3 <= 1'b0;
     end
     
     else begin
      rs232_rx0 <= rs232_rx;
      rs232_rx1 <= rs232_rx0;
      rs232_rx2 <= rs232_rx1;
      rs232_rx3 <= rs232_rx2;
     end
    end
    assign neg_rs232_rx = rs232_rx3 & rs232_rx2 & ~rs232_rx1 & ~rs232_rx0;//���ڴ����ߵ����ر�־
    reg bps_start_r;
    reg [3:0] num;//��λ����
    reg rx_int;  //�����ж��ź�
    
 always @(posedge clk or negedge rst_n)
     if(!rst_n) begin
      bps_start_r <=1'bz;
      rx_int <= 1'b0;
     end
     else if(neg_rs232_rx) begin//
     bps_start_r <= 1'b1;  //��������,׼����������
      rx_int <= 1'b1;   //���������ж�ʹ��
     end
     else if(num==4'd12) begin //���������õ��ź�,
      bps_start_r <=1'b0;  //�������,�ı䲨������λ,�����´ν���
      rx_int <= 1'b0;   //�����źŹر�
     end
    
  assign bps_start = bps_start_r;
     
     reg [7:0] rx_data_r;//�������ݼĴ���
     reg [7:0] rx_temp_data;//��ǰ���ݼĴ���
     
     always @(posedge clk or negedge rst_n)
      if(!rst_n) begin
        rx_temp_data <= 8'd0;
        num <= 4'd0;
        rx_data_r <= 8'd0;
      end
      else if(rx_int) begin //�������ݴ���
       if(clk_bps) begin
        num <= num+1'b1;
        case(num)
        4'd1: rx_temp_data[0] <= rs232_rx;
        4'd2: rx_temp_data[1] <= rs232_rx;
        4'd3: rx_temp_data[2] <= rs232_rx;
        4'd4: rx_temp_data[3] <= rs232_rx;
        4'd5: rx_temp_data[4] <= rs232_rx;
        4'd6: rx_temp_data[5] <= rs232_rx;
        4'd7: rx_temp_data[6] <= rs232_rx;
        4'd8: rx_temp_data[7] <= rs232_rx;
        default: ;
      endcase
      led <= rx_temp_data;
     end
     else if(num==4'd12) begin
      num <= 4'd0;   //���ݽ������
      rx_data_r <= rx_temp_data;
     end          
    end
   assign rx_data = rx_data_r;
endmodule
