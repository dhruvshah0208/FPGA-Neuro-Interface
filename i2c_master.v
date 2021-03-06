`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2021 07:21:58 PM
// Design Name: 
// Module Name: i2c_master
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


module i2c_master(
input clk,
input enable,
input resetn,
output SCL,
inout SDA,
output LDAC,
output error,
output done,
input [7:0] DAC_A_DATA_1,
input [7:0] DAC_B_DATA_1,
input [7:0] DAC_C_DATA_1,
input [7:0] DAC_D_DATA_1,
input [7:0] DAC_E_DATA_1,
input [7:0] DAC_F_DATA_1,
input [7:0] DAC_G_DATA_1,
input [7:0] DAC_H_DATA_1,

input [7:0] DAC_A_DATA_2,
input [7:0] DAC_B_DATA_2,
input [7:0] DAC_C_DATA_2,
input [7:0] DAC_D_DATA_2,
input [7:0] DAC_E_DATA_2,
input [7:0] DAC_F_DATA_2,
input [7:0] DAC_G_DATA_2,
input [7:0] DAC_H_DATA_2
);

reg LDAC_reg;
reg error_reg;
reg done_reg;
reg [2:0] c_state;
reg [2:0] n_state;
reg SCL_ready; // If this is 0 - leave SCL as high else SCL = clk
reg send_ready; // This is 1 when master takes control of SDA else 0
reg send_value; // Data that is to be sent on SDA
reg [3:0] counter_reg;
wire [3:0] counter_next;
reg [1:0] counter_reg_2;
wire [1:0] counter_reg_2_next;

reg [4:0] c_address_pointer;
reg [4:0] n_address_pointer;
reg ack_received,nack_received;

reg start_ready;
localparam START = 2'b00;
localparam WRITE= 2'b01;
localparam IDLE = 2'b10;
localparam STOP= 2'b11;

localparam Width = 32;
localparam Depth = 18;

reg [Width-1:0] register_bank [Depth-1:0];

localparam Address_DAC_1 = 8'b01010100; // Random Value - Change Later
localparam Address_DAC_2 = 8'b01010100; // Random Value - Change Later

// Command Bytes
localparam DAC_A_1 = 8'b00001000;
localparam DAC_B_1 = 8'b00001001; 
localparam DAC_C_1 = 8'b00001010; 
localparam DAC_D_1 = 8'b00001011; 
localparam DAC_E_1 = 8'b00001100; 
localparam DAC_F_1 = 8'b00001101; 
localparam DAC_G_1 = 8'b00001110; 
localparam DAC_H_1 = 8'b00001111; 
localparam DAC_A_2 = 8'b00001000;
localparam DAC_B_2 = 8'b00001001; 
localparam DAC_C_2 = 8'b00001010; 
localparam DAC_D_2 = 8'b00001011; 
localparam DAC_E_2 = 8'b00001100; 
localparam DAC_F_2 = 8'b00001101; 
localparam DAC_G_2 = 8'b00001110; 
localparam DAC_H_2 = 8'b00001111; 

always @(negedge resetn or posedge clk) begin
    // Initialize the register_bank
    if(!resetn) begin
        c_state <= IDLE;
        c_address_pointer = 16;
        register_bank[0] <=  {Address_DAC_1,DAC_A_1,4'b0000,DAC_A_DATA_1,4'b0000};
        register_bank[1] <=  {Address_DAC_1,DAC_B_1,4'b0000,DAC_B_DATA_1,4'b0000};
        register_bank[2] <=  {Address_DAC_1,DAC_C_1,4'b0000,DAC_C_DATA_1,4'b0000};
        register_bank[3] <=  {Address_DAC_1,DAC_D_1,4'b0000,DAC_D_DATA_1,4'b0000};
        register_bank[4] <=  {Address_DAC_1,DAC_E_1,4'b0000,DAC_E_DATA_1,4'b0000};
        register_bank[5] <=  {Address_DAC_1,DAC_F_1,4'b0000,DAC_F_DATA_1,4'b0000};
        register_bank[6] <=  {Address_DAC_1,DAC_G_1,4'b0000,DAC_G_DATA_1,4'b0000};
        register_bank[7] <=  {Address_DAC_1,DAC_H_1,4'b0000,DAC_H_DATA_1,4'b0000};    

        register_bank[8] <=  {Address_DAC_2,DAC_A_2,4'b0000,DAC_A_DATA_2,4'b0000};
        register_bank[9] <=  {Address_DAC_2,DAC_B_2,4'b0000,DAC_B_DATA_2,4'b0000};
        register_bank[10] <= {Address_DAC_2,DAC_C_2,4'b0000,DAC_C_DATA_2,4'b0000};
        register_bank[11] <= {Address_DAC_2,DAC_D_2,4'b0000,DAC_D_DATA_2,4'b0000};
        register_bank[12] <= {Address_DAC_2,DAC_E_2,4'b0000,DAC_E_DATA_2,4'b0000};
        register_bank[13] <= {Address_DAC_2,DAC_F_2,4'b0000,DAC_F_DATA_2,4'b0000};
        register_bank[14] <= {Address_DAC_2,DAC_G_2,4'b0000,DAC_G_DATA_2,4'b0000};
        register_bank[15] <= {Address_DAC_2,DAC_H_2,4'b0000,DAC_H_DATA_2,4'b0000};   
        
        register_bank[16] <= {Address_DAC_2,DAC_H_2,4'b0000,DAC_H_DATA_2,4'b0000}; // REVISIT - This has to be Power up sequence
//        register_bank[17] <= {Address_DAC_2,DAC_H_2,4'b0000,DAC_H_DATA_2,4'b0000}; // REVISIT - This has to be Power down sequence
    
    end
    
    else if (clk & enable) begin
        c_state <= n_state;
        if(n_state == START) begin
            c_address_pointer <= n_address_pointer;
            counter_reg <= 0;
            counter_reg_2 <= 0;                
        end   
        else if (n_state == WRITE) begin// REVISIT
            c_address_pointer <= n_address_pointer;
            counter_reg <= counter_next;
            counter_reg_2 <= counter_reg_2_next;
        
        end else begin
            counter_reg <= counter_next;
            counter_reg_2 <= counter_reg_2_next;
        end
    end
end   

assign counter_reg_2_next = (counter_reg == 0 & (c_state == START | c_state == STOP))? 0:
                            (counter_reg == 8) ? counter_reg_2 + 1:counter_reg_2;
assign counter_next =   (counter_reg == 0 & (c_state == START | c_state == STOP))? 0:
                        (counter_reg == 9) ?1:1+counter_reg;

always @(negedge clk) begin
if(!resetn) begin
    send_ready <= 0;
    start_ready <= 0; 
end
case(c_state) 
    START: begin
        send_ready <= 1; 
        send_value <= 0;
        start_ready <= 0;
    end
    STOP: begin
        send_ready <= 1; 
        send_value <= 1;
        start_ready <= 0;
    
    end
    WRITE: begin
        if(counter_reg < 8) begin
            send_ready <= 1;
            send_value <= register_bank[c_address_pointer][8*(4 - counter_reg_2) - counter_reg -1 ];
            start_ready <= 0;
        end        
        else if(counter_reg == 9 & counter_reg_2 == 0 & ack_received & c_address_pointer == 15) begin
            send_ready <= 1;
            send_value <= 0;
            start_ready <= 1;

        end
        else if(counter_reg == 9 & counter_reg_2 == 0 & ack_received) begin // This brings the SDA line to 1 in order to send the start condition in the next state
            send_ready <= 1;
            send_value <= 1;
            start_ready <= 1;
        end
        else if(counter_reg == 9 & nack_received) begin // This brings the SDA line to 0 in order to send the stop condition in the next state
            send_ready <= 1;
            send_value <= 0;
            start_ready <= 1;
        end
    
        else if(counter_reg == 9) begin
            send_ready <= 1;
            send_value <= register_bank[c_address_pointer][8*(4 - counter_reg_2)-1 ];
            start_ready <= 0;
        end
        else if(counter_reg == 8) begin
            send_ready <= 0;
        end
        else
            start_ready <= 0;
end

endcase

end

always @(posedge clk) begin
    if(c_state ==  WRITE & counter_reg == 8) begin
        send_ready <= 0;
        if(!SDA)
            ack_received <= 1;
        else
            nack_received <= 1;
    end 
    else begin
        ack_received <= 0;
        nack_received <= 0;
    end
end

always @* begin
// Default Values
n_address_pointer = c_address_pointer;
        
SCL_ready = 0;
if(!resetn) begin
    done_reg = 0;
    error_reg = 0; 
end
case(c_state)
    IDLE: begin
        if(enable) begin
            SCL_ready = 1;
            n_state = START;
            LDAC_reg = 1;
        end
    end 
    START: begin
        if(counter_reg == 0) begin    
            SCL_ready = 0;
            n_state = WRITE;    
        end    
    end
    STOP: begin
        if(counter_reg == 0)
            SCL_ready = 0;
    end
    
    WRITE: begin
        SCL_ready = 1;
        // Check ack received and proceed accordingly
        if(counter_reg == 9 & nack_received & start_ready) begin
            n_state = STOP;
            error_reg = 1;
        end
        
        // Update Address Pointer when second counter is at its end
        else if(counter_reg == 9 & counter_reg_2 == 0 & ack_received & start_ready) begin
            n_state = START;
            if(c_address_pointer == 16) // From Power Up to DATA 1
                n_address_pointer = 0;      
            else if(c_address_pointer >=0 & c_address_pointer <= 14) 
                n_address_pointer = c_address_pointer + 1;
            else if(c_address_pointer == 15) begin
                n_state = STOP;
                LDAC_reg = 0;       
                done_reg = 1;   
            end
        end
        
    end
endcase

end
assign SCL = (SCL_ready) ? clk:1;
assign SDA = (send_ready) ? send_value:1'bz; // IMPORTANT - CHANGE THIS BACK TO 'z later
assign LDAC = LDAC_reg;
assign done = done_reg;
assign error = error_reg;
endmodule