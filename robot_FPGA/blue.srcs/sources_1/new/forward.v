`timescale 1ns / 1ps

module forward(
    input CLK,en_forward,en_back,
    input en_keepdistance,out_of_distance,in_distance,
    input en_welcome,en_kick,en_slide,
    output wire pwm1,pwm2,pwm3,pwm4,pwm5,pwm6   //1245��С�ȣ�36����
    );
    
    reg [2:0]state;    //������״̬
    reg change_flag;   //״̬�л���־
    reg change_flag_reg;   //״̬�л���־�Ĵ���
    reg change_flag2;   //״̬�л���־
    reg change_flag_reg2;   //״̬�л���־�Ĵ���
    
    reg out_of_distance_reg;
    reg in_distance_reg;      
    
    reg forward_over;        //ǰ��������ɱ�־
    reg back_over;          //���˶�����ɱ�־
    reg keepdistance_over;     //���ֳ��ද����ɱ�־
    reg welcome_over;         //��ӭ������ɱ�־
    reg kick_over;           //���ȶ�����ɱ�־
    reg slide_over;           //����������ɱ�־
    reg over;                  //��ʼ��
    
    reg [32:0]count1=0;  //������1����
    parameter T2S=3000000; //2s����һ��״̬ 200000000
 
//�����������
//  ռ�ձȶ�Ӧ
    reg [7:0]duty1=8'd75;    //pwm1ռ�ձ�
    reg [7:0]duty2=8'd75;    //pwm2ռ�ձ�
    reg [7:0]duty3=8'd75;    //pwm3ռ�ձ�   
    reg [7:0]duty4=8'd75;    //pwm4ռ�ձ�
    reg [7:0]duty5=8'd75;    //pwm5ռ�ձ�
    reg [7:0]duty6=8'd75;    //pwm6ռ�ձ�   
    //������״̬
    parameter stand_up =3'b000,        //����
                r_dev =  3'b001,        //����
                move_l = 3'b010,       //��������
                l_dev =  3'b011,        //����
                move_r = 3'b100,        //��������
                restore =3'b101,        //��ԭ
                stop  =  3'b110,        //ֹͣ
                Null =   3'b111;        //ɶʱ����

//��Ƶ  2s����һ�Σ��ı������״̬
     always@(posedge CLK)
        begin
           count1<=count1+1;
           if(count1==T2S) 
               begin 
               count1<=0;       
               change_flag<=~change_flag;
               if(change_flag==1)  change_flag2<=~change_flag2;   //��Ƶ
               end
        end
        
     
always@(posedge CLK) 
     if(en_forward==1)      //ǰ��ǰ��ǰ��ǰ��ǰ��ǰ��ǰ��ǰ��ǰ��ǰ��ǰ��ǰ��
        begin  
            if(back_over==1||keepdistance_over==1||welcome_over==1||kick_over==1||slide_over==1||over==1) 
                begin
                back_over<=0;
                keepdistance_over<=0;
                welcome_over<=0;
                kick_over<=0;
                slide_over<=0;
                over<=0;
                state<=stand_up;
                end
            if(state==stand_up)                      //վ��
            begin         
                if(change_flag==1)
                    begin
                    state<=r_dev;
                    duty1<=8'd75;
                    duty2<=8'd75;
                    duty3<=8'd75;
                    duty4<=8'd75;
                    duty5<=8'd75;
                    duty6<=8'd75;
                    change_flag_reg<=change_flag;
                    end
              end
            else if(state==r_dev)           //����
            begin
             if(change_flag==~change_flag_reg)
                 begin
                 if(duty3<8'd91) duty3<=duty3+1'd1;
                 if(duty6<8'd93) duty6<=duty6+1'd1;
                 else state<=move_l;
                 change_flag_reg<=change_flag;
                 end
             end
             else if(state==move_l)    //������
             begin
                 if(change_flag==~change_flag_reg)
                 begin  
                 if(duty3>8'd80) duty3<=duty3-1'd1;
                 if(duty4>8'd50)  duty4<=duty4-1'd1;
                 if(duty5<8'd100) duty5<=duty5+1'd1;
                 change_flag_reg<=change_flag;
                 if(duty4<8'd51) state<=stop;
                 end
             end
             else if(state==stop)
             begin
                 if(change_flag==~change_flag_reg)
                 begin                   
                 if(duty3>8'd75)  duty3<=duty3-1'd1;               
                 if(duty4<8'd75)  duty4<=duty4+1'd1;
                 if(duty5>8'd75)  duty5<=duty5-1'd1;
                 else state<=l_dev;
                 if(duty6>8'd75)  duty6<=duty6-1'd1;
                 change_flag_reg<=change_flag;    
                 end             
             end
             else if(state==l_dev)        //����
             begin
                 if(change_flag==~change_flag_reg)
                 begin  
                 if(duty6>8'd58)  duty6<=duty6-1'd1;                                 
                 else state<=move_r;
                 if(duty3>8'd60)  duty3<=duty3-1'd1;
                 change_flag_reg<=change_flag;    
                 end
             end
             else if(state==move_r)        //������
             begin
                 if(change_flag==~change_flag_reg)
                 begin
                 if(duty1<8'd100) duty1<=duty1+1'd1;
                 if(duty2>8'd50)  duty2<=duty2-1'd1;
                 if(duty6<8'd70)  duty6<=duty6+1'd1;
                 change_flag_reg<=change_flag;
                 if(duty1>8'd99) state<=restore;
                 end
             end
             else if(state==restore)   //��ԭ
             begin
                 if(change_flag==~change_flag_reg)
                 begin
                 if(duty1>8'd75) duty1<=duty1-1'd1;
                 if(duty2<8'd75) duty2<=duty2+1'd1;
                 if(duty3<8'd75) duty3<=duty3+1'd1;
                 if(duty6<8'd75) duty6<=duty6+1'd1;
                 change_flag_reg<=change_flag;
                 if(duty1==8'd75)  forward_over<=1;
                 end
             end
         end                    
  //**********************ǰ��over*********************************        
  
  //*********************����***********************************       
     else if(en_back==1)        
            begin  
                if(forward_over==1||keepdistance_over==1||welcome_over==1||kick_over==1||slide_over==1||over==1) 
                    begin
                    forward_over<=0;
                    keepdistance_over<=0;
                    welcome_over<=0;
                    kick_over<=0;
                    slide_over<=0;
                    over<=0;
                    state<=stand_up;
                    end
            if(state==stand_up)                      //վ��
                    begin         
                        if(change_flag==1)
                            begin
                            state<=r_dev;
                            duty1<=8'd75;
                            duty2<=8'd75;
                            duty3<=8'd75;
                            duty4<=8'd75;
                            duty5<=8'd75;
                            duty6<=8'd75;
                            change_flag_reg<=change_flag;
                            end
                      end
                    else if(state==r_dev)           //����
                    begin
                     if(change_flag==~change_flag_reg)
                         begin
                         if(duty3<8'd91) duty3<=duty3+1'd1;
                         if(duty6<8'd93) duty6<=duty6+1'd1;
                         else state<=move_l;
                         change_flag_reg<=change_flag;
                         end
                     end
                     else if(state==move_l)    //������
                     begin
                         if(change_flag==~change_flag_reg)
                         begin  
                         if(duty3>8'd80) duty3<=duty3-1'd1;
                         if(duty5>8'd50)  duty5<=duty5-1'd1;
                         if(duty4<8'd100) duty4<=duty4+1'd1;
                         change_flag_reg<=change_flag;
                         if(duty5<8'd51) state<=stop;
                         end
                     end
                     else if(state==stop)
                     begin
                         if(change_flag==~change_flag_reg)
                         begin                   
                         if(duty3>8'd75)  duty3<=duty3-1'd1;               
                         if(duty4>8'd75)  duty4<=duty4-1'd1;
                         if(duty5<8'd75)  duty5<=duty5+1'd1;
                         else state<=l_dev;
                         if(duty6>8'd75)  duty6<=duty6-1'd1;
                         change_flag_reg<=change_flag;    
                         end             
                     end
                     else if(state==l_dev)        //����
                     begin
                         if(change_flag==~change_flag_reg)
                         begin  
                         if(duty6>8'd58)  duty6<=duty6-1'd1;                                 
                         else state<=move_r;
                         if(duty3>8'd60)  duty3<=duty3-1'd1;
                         change_flag_reg<=change_flag;    
                         end
                     end
                     else if(state==move_r)        //������
                     begin
                         if(change_flag==~change_flag_reg)
                         begin
                         if(duty2<8'd100) duty2<=duty2+1'd1;
                         if(duty1>8'd50)  duty1<=duty1-1'd1;
                         if(duty6<8'd70)  duty6<=duty6+1'd1;
                         change_flag_reg<=change_flag;
                         if(duty2>8'd99) state<=restore;
                         end
                     end
                     else if(state==restore)   //��ԭ
                     begin
                         if(change_flag==~change_flag_reg)
                         begin
                         if(duty1<8'd75) duty1<=duty1+1'd1;
                         if(duty2>8'd75) duty2<=duty2-1'd1;
                         if(duty3<8'd75) duty3<=duty3+1'd1;
                         if(duty6<8'd75) duty6<=duty6+1'd1;
                         change_flag_reg<=change_flag;
                         if(duty1==8'd75) back_over<=1;
                         end
                     end
             end         
  //*********************����over***********************************         
  
//*********************���ֳ���**************************************        
  else if(en_keepdistance==1)
    begin
    if(forward_over==1||back_over==1||welcome_over==1||kick_over==1) 
           begin
           forward_over<=0;
           back_over<=0;
           welcome_over<=0;
           kick_over<=0;
           keepdistance_over<=1;
           state<=stand_up;
           end 
      if(out_of_distance==1)
       begin
            if(state==stand_up)                      //վ��
       begin         
           if(change_flag==1)
               begin
               state<=r_dev;
               duty1<=8'd75;
               duty2<=8'd75;
               duty3<=8'd75;
               duty4<=8'd75;
               duty5<=8'd75;
               duty6<=8'd75;
               change_flag_reg<=change_flag;
               end
         end
       else if(state==r_dev)           //����
       begin
        if(change_flag==~change_flag_reg)
            begin
            if(duty3<8'd91) duty3<=duty3+1'd1;
            if(duty6<8'd93) duty6<=duty6+1'd1;
            else state<=move_l;
            change_flag_reg<=change_flag;
            end
        end
        else if(state==move_l)    //������
        begin
            if(change_flag==~change_flag_reg)
            begin  
            if(duty3>8'd80) duty3<=duty3-1'd1;
            if(duty4>8'd50)  duty4<=duty4-1'd1;
            if(duty5<8'd100) duty5<=duty5+1'd1;
            change_flag_reg<=change_flag;
            if(duty4<8'd51) state<=stop;
            end
        end
        else if(state==stop)
        begin
            if(change_flag==~change_flag_reg)
            begin                   
            if(duty3>8'd75)  duty3<=duty3-1'd1;               
            if(duty4<8'd75)  duty4<=duty4+1'd1;
            if(duty5>8'd75)  duty5<=duty5-1'd1;
            else state<=l_dev;
            if(duty6>8'd75)  duty6<=duty6-1'd1;
            change_flag_reg<=change_flag;    
            end             
        end
        else if(state==l_dev)        //����
        begin
            if(change_flag==~change_flag_reg)
            begin  
            if(duty6>8'd58)  duty6<=duty6-1'd1;                                 
            else state<=move_r;
            if(duty3>8'd60)  duty3<=duty3-1'd1;
            change_flag_reg<=change_flag;    
            end
        end
        else if(state==move_r)        //������
        begin
            if(change_flag==~change_flag_reg)
            begin
            if(duty1<8'd100) duty1<=duty1+1'd1;
            if(duty2>8'd50)  duty2<=duty2-1'd1;
            if(duty6<8'd70)  duty6<=duty6+1'd1;
            change_flag_reg<=change_flag;
            if(duty1>8'd99) state<=restore;
            end
        end
        else if(state==restore)   //��ԭ
        begin
            if(change_flag==~change_flag_reg)
            begin
            if(duty1>8'd75) duty1<=duty1-1'd1;
            if(duty2<8'd75) duty2<=duty2+1'd1;
            if(duty3<8'd75) duty3<=duty3+1'd1;
            if(duty6<8'd75) duty6<=duty6+1'd1;
            change_flag_reg<=change_flag;
            if(duty1==8'd75)  state<=stand_up;
            end
        end       
       end     
      if(in_distance==1) 
       begin
            if(state==stand_up)                      //վ��
               begin         
                   if(change_flag==1)
                       begin
                       state<=r_dev;
                       duty1<=8'd75;
                       duty2<=8'd75;
                       duty3<=8'd75;
                       duty4<=8'd75;
                       duty5<=8'd75;
                       duty6<=8'd75;
                       change_flag_reg<=change_flag;
                       end
                 end
               else if(state==r_dev)           //����
               begin
                if(change_flag==~change_flag_reg)
                    begin
                    if(duty3<8'd91) duty3<=duty3+1'd1;
                    if(duty6<8'd93) duty6<=duty6+1'd1;
                    else state<=move_l;
                    change_flag_reg<=change_flag;
                    end
                end
                else if(state==move_l)    //������
                begin
                    if(change_flag==~change_flag_reg)
                    begin  
                    if(duty3>8'd80) duty3<=duty3-1'd1;
                    if(duty5>8'd50)  duty5<=duty5-1'd1;
                    if(duty4<8'd100) duty4<=duty4+1'd1;
                    change_flag_reg<=change_flag;
                    if(duty5<8'd51) state<=stop;
                    end
                end
                else if(state==stop)
                begin
                    if(change_flag==~change_flag_reg)
                    begin                   
                    if(duty3>8'd75)  duty3<=duty3-1'd1;               
                    if(duty4>8'd75)  duty4<=duty4-1'd1;
                    if(duty5<8'd75)  duty5<=duty5+1'd1;
                    else state<=l_dev;
                    if(duty6>8'd75)  duty6<=duty6-1'd1;
                    change_flag_reg<=change_flag;    
                    end             
                end
                else if(state==l_dev)        //����
                begin
                    if(change_flag==~change_flag_reg)
                    begin  
                    if(duty6>8'd58)  duty6<=duty6-1'd1;                                 
                    else state<=move_r;
                    if(duty3>8'd60)  duty3<=duty3-1'd1;
                    change_flag_reg<=change_flag;    
                    end
                end
                else if(state==move_r)        //������
                begin
                    if(change_flag==~change_flag_reg)
                    begin
                    if(duty2<8'd100) duty2<=duty2+1'd1;
                    if(duty1>8'd50)  duty1<=duty1-1'd1;
                    if(duty6<8'd70)  duty6<=duty6+1'd1;
                    change_flag_reg<=change_flag;
                    if(duty2>8'd99) state<=restore;
                    end
                end
                else if(state==restore)   //��ԭ
                begin
                    if(change_flag==~change_flag_reg)
                    begin
                    if(duty1<8'd75) duty1<=duty1+1'd1;
                    if(duty2>8'd75) duty2<=duty2-1'd1;
                    if(duty3<8'd75) duty3<=duty3+1'd1;
                    if(duty6<8'd75) duty6<=duty6+1'd1;
                    change_flag_reg<=change_flag;
                    if(duty1==8'd75)  state<=stand_up;
                    end
                end    
       end  
    end
 //*******************************���ֳ���over****************************
 
 //******************************��ӭ����****************************
 else if(en_welcome==1)
    begin
        if(forward_over==1||back_over==1||keepdistance_over==1||kick_over==1||slide_over==1||over==1) 
           begin
           forward_over<=0;
           back_over<=0;
           keepdistance_over<=0;
           kick_over<=0;
           slide_over<=0;
           over<=0;
           state<=stand_up;
           end 
        if(state==stand_up)
        begin
           if(change_flag==~change_flag_reg)
            begin
            if(duty3<8'd100) duty3<=duty3+1'd1;
            if(duty6>8'd50) duty6<=duty6-1'd1;
            else state<=r_dev;
            change_flag_reg<=change_flag;
            end
        end
        else if(state==r_dev)
            begin
               if(change_flag==~change_flag_reg)
                begin
                if(duty3>8'd50) duty3<=duty3-1'd1;
                if(duty6<8'd100) duty6<=duty6+1'd1;
                else state<=move_l;
                change_flag_reg<=change_flag;
                end
            end
       else if(state==move_l)
        begin
           if(change_flag2==~change_flag_reg2)
            begin
            if(duty3<8'd75) duty3<=duty3+1'd1;
            if(duty6>8'd75) duty6<=duty6-1'd1;
            else state<=l_dev;
            if(duty1>8'd65) duty1<=duty1-1'd1;
            if(duty2>8'd65) duty2<=duty2-1'd1;
            if(duty4<8'd85) duty4<=duty4+1'd1;
            if(duty5<8'd85) duty5<=duty5+1'd1;
            change_flag_reg2<=change_flag2;
            end
        end  
        else if(state==l_dev)
         begin
            if(change_flag2==~change_flag_reg2)
             begin
             if(duty1<8'd75) duty1<=duty1+1'd1;
             if(duty2<8'd75) duty2<=duty2+1'd1;
             if(duty4>8'd75) duty4<=duty4-1'd1;
             if(duty5>8'd75) duty5<=duty5-1'd1;
             else state<=move_r;
             change_flag_reg2<=change_flag2;
             end
         end  
        else if(state==move_r)
          begin
             if(change_flag2==~change_flag_reg2)
              begin
              if(duty1<8'd75) duty1<=duty1+1'd1;
              if(duty2<8'd75) duty2<=duty2+1'd1;
              if(duty4>8'd75) duty4<=duty4-1'd1;
              if(duty5>8'd75) duty5<=duty5-1'd1;
              else state<=restore;
              change_flag_reg2<=change_flag2;
              end
          end    
          else if(state==restore)
            begin
               if(change_flag2==~change_flag_reg2)
                begin
                if(duty1>8'd65) duty1<=duty1-1'd1;
                if(duty2>8'd65) duty2<=duty2-1'd1;
                if(duty4<8'd85) duty4<=duty4+1'd1;
                if(duty5<8'd85) duty5<=duty5+1'd1;
                else state<=stop;
                change_flag_reg2<=change_flag2;
                end
            end  
            else if(state==stop)
              begin
                 if(change_flag2==~change_flag_reg2)
                  begin
                  if(duty1<8'd75) duty1<=duty1+1'd1;
                  if(duty2<8'd75) duty2<=duty2+1'd1;
                  if(duty4>8'd75) duty4<=duty4-1'd1;
                  if(duty5>8'd75) duty5<=duty5-1'd1;
                  else welcome_over<=1;
                  change_flag_reg2<=change_flag2;
                  end
              end  
    end 
//******************************��ӭ����over****************************

//******************************���ȶ���****************************
 else if(en_kick==1)
   begin
       if(forward_over==1||back_over==1||keepdistance_over==1||welcome_over==1||slide_over==1||over==1) 
          begin
          forward_over<=0;
          back_over<=0;
          keepdistance_over<=0;
          welcome_over<=0;
          slide_over<=0;
          over<=0;
          state<=stand_up;
          end 
        if(state==stand_up)
          begin
             if(change_flag==~change_flag_reg)
              begin
              if(duty3<8'd91) duty3<=duty3+1'd1;
              if(duty6<8'd93) duty6<=duty6+1'd1;
              else state<=r_dev;
              change_flag_reg<=change_flag;
              end
          end
        else if(state==r_dev)
              begin
                 if(change_flag2==~change_flag_reg2)
                  begin
                  if(duty3>8'd75) duty3<=duty3-1'd1;
                  else state<=move_l;
                  if(duty1<8'd85) duty1<=duty1+1'd1;
                  if(duty2<8'd85) duty2<=duty2+1'd1;
                  if(duty4<8'd85) duty4<=duty4+1'd1;
                  if(duty5<8'd85) duty5<=duty5+1'd1;   
                  change_flag_reg2<=change_flag2;
                  end
              end
        else if(state==move_l)
               begin
                  if(change_flag2==~change_flag_reg2)
                   begin
                   if(duty1>8'd65) duty1<=duty1-1'd1;
                   if(duty2>8'd65) duty2<=duty2-1'd1;
                   if(duty4>8'd65) duty4<=duty4-1'd1;
                   if(duty5>8'd65) duty5<=duty5-1'd1;  
                   else state<=l_dev;
                   change_flag_reg2<=change_flag2;
                   end
               end   
        else if(state==l_dev)
                begin
                   if(change_flag2==~change_flag_reg2)
                    begin
                    if(duty1<8'd75) duty1<=duty1+1'd1;
                    if(duty2<8'd75) duty2<=duty2+1'd1;
                    if(duty4<8'd75) duty4<=duty4+1'd1;
                    if(duty5<8'd75) duty5<=duty5+1'd1; 
                    if(duty5>8'd70)
                        begin
                        if(duty3<8'd100) duty3<=duty3+1'd1;
                        else state<=move_r;
                        end
                    change_flag_reg2<=change_flag2;
                    end
                end    
        else if(state==move_r)
                        begin
                           if(change_flag2==~change_flag_reg2)
                            begin                             
                            if(duty3>8'd75) duty3<=duty3-1'd1;
                            else kick_over<=1;
                            if(duty6>8'd75) duty6<=duty6-1'd1;    
                            change_flag_reg2<=change_flag2;
                            end
                        end                          
    end   
//******************************���ȶ���over****************************   
   
////******************************ֹͣ����**************************** 
// else if(en_slide==1)
//  begin
//      if(forward_over==1||back_over==1||keepdistance_over==1||welcome_over==1||kick_over==1) 
//         begin
//         forward_over<=0;
//         back_over<=0;
//         keepdistance_over<=0;
//         welcome_over<=0;
//         kick_over<=0;
//         state<=stand_up;
//         end 
//         if(state==stand_up)
//         begin
//             if(change_flag2==~change_flag_reg2)
//             begin                               
//             change_flag_reg2<=change_flag2;
//             if(duty1>8'd75) duty1<=duty1-1'd1;
//             else if(duty1<8'd74) duty1<=duty1+1'd1;
//             if(duty2>8'd75) duty2<=duty2-1'd1;
//             else if(duty2<8'd74) duty2<=duty2+1'd1;
//             if(duty3>8'd75) duty3<=duty3-1'd1;
//             else if(duty3<8'd74) duty3<=duty3+1'd1;
//             if(duty4>8'd75) duty4<=duty4-1'd1;
//             else if(duty4<8'd74) duty4<=duty4+1'd1;
//             if(duty5>8'd75) duty5<=duty5-1'd1;
//             else if(duty5<8'd74) duty5<=duty5+1'd1;
//             if(duty6>8'd75) duty6<=duty6-1'd1;
//             else if(duty6<8'd74) duty6<=duty6+1'd1;
//             if(duty1==8'd75&&duty2==8'd75&&duty3==8'd75&&duty4==8'd75&&duty5==8'd75&&duty6==8'd75)
//                 begin
//                 over<=1;
//                 state<=Null;
//                 end
//             end 
//         end                            
//  end                   
////******************************ֹͣ����over**************************** 
   
         pwm PWM1(.clk(CLK),.duty(duty1),.pwm_out(pwm1));
         pwm PWM2(.clk(CLK),.duty(duty2),.pwm_out(pwm2));
         pwm PWM3(.clk(CLK),.duty(duty3),.pwm_out(pwm3));
         pwm PWM4(.clk(CLK),.duty(duty4),.pwm_out(pwm4));
         pwm PWM5(.clk(CLK),.duty(duty5),.pwm_out(pwm5));
         pwm PWM6(.clk(CLK),.duty(duty6),.pwm_out(pwm6));
endmodule

