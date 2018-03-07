`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/07/11 10:06:00
// Design Name: 
// Module Name: state
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


module state(
    input clk,Rst_n,Rs232_rx,echo,
    output Rs232_tx,trig,
    output [7:0]LED,
    output [7:0]data,
    output [3:0]sel,
    output wire pwm1,pwm2,pwm3,pwm4,pwm5,pwm6,pwm7,pwm8
    );
    reg [7:0]data_reg;
    wire [23:0]distance;
    
    reg en_forward;      //前进使能
    reg en_back;         //后退使能
    reg en_keepdistance; //保持距离使能
    reg en_welcome;      //欢迎使能
    reg en_kick;         //踢腿运动 
    reg en_slide;         //滑步运动
    
    reg [32:0]count=0;  //计数器1用来 
    reg flag=0;   //位数切换标志
    reg out_of_distance=0;   //距离过远标志
    reg in_distance=0;       //距离过近标志
    parameter T1S=20000000; //2s更新一次状态 200 000 000     
    
    always@(posedge clk)
    begin
      count<=count+1;
      if(count==T1S) 
          begin 
          count<=0; 
              if(flag==0)
                  begin
                  flag<=1;
                  case(distance[15:12])
                  4'b0000:data_reg<=8'b00110000;
                  4'b0001:data_reg<=8'b00110001;
                  4'b0010:data_reg<=8'b00110010;
                  4'b0011:data_reg<=8'b00110011;
                  4'b0100:data_reg<=8'b00110100;
                  4'b0101:data_reg<=8'b00110101;
                  4'b0110:data_reg<=8'b00110110;
                  4'b0111:data_reg<=8'b00110111;
                  4'b1000:data_reg<=8'b00111000;
                  4'b1001:data_reg<=8'b00111001;
                  4'b1010:data_reg<=8'b00111010;
                  4'b1011:data_reg<=8'b00111011;
                  4'b1100:data_reg<=8'b00111100;
                  4'b1101:data_reg<=8'b00111101;
                  4'b1110:data_reg<=8'b00111110;
                  4'b1111:data_reg<=8'b00111111;
                  default  data_reg<=8'b00110000;
                  endcase  
                  end  
              else
                  begin
                  flag<=0;
                  case(distance[19:16])
                  4'b0000:data_reg<=8'b00110000;
                  4'b0001:data_reg<=8'b00110001;
                  4'b0010:data_reg<=8'b00110010;
                  4'b0011:data_reg<=8'b00110011;
                  4'b0100:data_reg<=8'b00110100;
                  4'b0101:data_reg<=8'b00110101;
                  4'b0110:data_reg<=8'b00110110;
                  4'b0111:data_reg<=8'b00110111;
                  4'b1000:data_reg<=8'b00111000;
                  4'b1001:data_reg<=8'b00111001;
                  4'b1010:data_reg<=8'b00111010;
                  4'b1011:data_reg<=8'b00111011;
                  4'b1100:data_reg<=8'b00111100;
                  4'b1101:data_reg<=8'b00111101;
                  4'b1110:data_reg<=8'b00111110;
                  4'b1111:data_reg<=8'b00111111;
                  default  data_reg<=8'b00110000;
                  endcase                   
                  end
          end
    end
    
    always@(posedge clk)
    begin
        if(distance[19:12]>4'b00110000)  out_of_distance<=1;
        else out_of_distance<=0;
        if(distance[19:12]<4'b00001100)  in_distance<=1;
        else in_distance<=0;
        
        if(LED[0]==1&&LED[1]==0&&LED[2]==0) en_forward<=1'b1;
                                       else en_forward<=1'b0;
        if(LED[0]==0&&LED[1]==1&&LED[2]==0) en_back<=1'b1;
                                       else en_back<=1'b0;
        if(LED[0]==1&&LED[1]==1&&LED[2]==0) en_keepdistance<=1'b1;
                                       else en_keepdistance<=1'b0;
        if(LED[0]==0&&LED[1]==0&&LED[2]==1) en_welcome<=1'b1;
                                       else en_welcome<=1'b0;
        if(LED[0]==1&&LED[1]==0&&LED[2]==1) en_kick<=1'b1;
                                       else en_kick<=1'b0; 
        if(LED[0]==0&&LED[1]==1&&LED[2]==1) en_slide<=1'b1;
                                       else en_slide<=1'b0;
    end
    
    //控制模块
    forward Forward(.CLK(clk),.en_forward(en_forward),.en_back(en_back),
                    .en_keepdistance(en_keepdistance),.out_of_distance(out_of_distance),.in_distance(in_distance),
                    .en_welcome(en_welcome),
                    .en_kick(en_kick),
                    .en_slide(en_slide),
        .pwm1(pwm1),.pwm2(pwm2),.pwm3(pwm3),.pwm4(pwm4),.pwm5(pwm5),.pwm6(pwm6));
        
     //蓝牙模块   
    uart_top blue(.CLK(clk),.rst_n(Rst_n),.rs232_rx(Rs232_rx),.rs232_tx(Rs232_tx),.led(LED),.data_in(data_reg));
    
    //超声波模块
    sonic csb(.clk(clk),.rst_n(Rst_n),.trig(trig),.echo(echo),.sel(sel),.data(data),.distance(distance));
endmodule
