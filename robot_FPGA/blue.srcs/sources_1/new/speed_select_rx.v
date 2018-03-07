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
// `define BPS_PARA 5207;//9600�����ʷ�Ƶ����ֵ
// `define BPS_PARA_2 2603;//����һ��ʱ����
    reg[13:0] cnt;//��Ƶ������
    reg clk_bps_r;//������ʱ�ӼĴ���
    
    reg[2:0] uart_ctrl;//������ѡ��Ĵ���
    
    always @(posedge clk or negedge rst_n)
     if(!rst_n)
      cnt<=14'd0;
     else if((cnt==5207)|| !bps_start)//�жϼ����Ƿ�ﵽ1������
      cnt<=14'd0;
     else
      cnt<=cnt+1'b1;//������ʱ������
      
    always @(posedge clk or negedge rst_n) begin
     if(!rst_n)
      clk_bps_r<=1'b0;
     else if(cnt==2603)//�������ʼ�����һ��ʱ,���в����洢
      clk_bps_r<=1'b1;
     else
      clk_bps_r<=1'b0;
    end
    assign clk_bps = clk_bps_r;//���������������uart_rxģ��
endmodule
