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
    input [7:0]duty,   //0-100ռ�ձ�
    output reg pwm_out
    );
     //�������20ms��ռ�ձ�0.5ms~2.5ms��Ӧ��0~180��
     reg [32:0]count=0;
     parameter T20MS=2000000,T20US=2000;   //����20ms
     always@(posedge clk)
     begin
        count<=count+1;
        if(count==T20MS) count<=0;
        pwm_out=(count< (duty*T20US) )?1:0;  //pwm
     end
endmodule
