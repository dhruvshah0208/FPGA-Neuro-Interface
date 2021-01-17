`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2021 03:51:33 PM
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


module test();
wire SCL;
wire SDA;
reg SDA_reg;
reg resetn;
reg clk,enable;
wire LDAC,done,error;
// Change these values accordingly later
localparam t_high = 10;
localparam t_low = 10;
localparam t_wait_start_stop = t_high/2;   
localparam t_wait_send = t_high/2;
localparam t_wait = 25;
integer i;   
// CLK generation
    initial begin
        clk = 0;
        forever begin
            #t_low clk = 1;
            #t_high clk = 0;
        end
    end
// Tasks    
    task I2C_start; begin
        wait(SCL == 0) SDA_reg = 1;
        wait(SCL == 1) #t_wait_start_stop SDA_reg = 0;
        wait(SCL == 0);
    end    
    endtask
    
    task I2C_stop; begin
        wait(SCL == 0) SDA_reg = 0;
        wait(SCL == 1) #t_wait_start_stop SDA_reg = 1;
    end    
    endtask
 
    task I2C_send;
        input [7:0] data_send;
        begin
        for(i = 7;i >=0;i=i-1) begin
            wait(SCL == 0) #t_wait_send SDA_reg = data_send[i];
            @(negedge SCL);
        end
        end
    endtask

    task I2C_receive;
    output [7:0] data_receive;
        begin
        SDA_reg = 8'bzzzzzzzz;
        for(i = 7;i >=0;i=i-1) begin
            @(posedge SCL) data_receive[i] = SDA;
        end
        end
    endtask
    
    task send_ACK;
        begin
            wait(SCL == 0) #t_wait_send SDA_reg = 0;
            @(negedge SCL);
        end
    endtask
    task send_NACK;
        begin
            wait(SCL == 0) #t_wait_send SDA_reg = 1;
            @(negedge SCL);
        end
    endtask

    task receive_ACK;
    output received_ACK;
        begin
        SDA_reg = 8'bzzzzzzzz;
        @(negedge SCL) received_ACK = !SDA;
    end
    endtask
// Start Stop Detectors

reg start_reg,stop_reg;
wire start,stop;

always @(negedge SDA or negedge SCL ) begin // START CONDITION
    if (SCL == 1)
        start_reg <= 1;
    else
        start_reg <= 0; 
end
always @(posedge SDA or negedge SCL ) begin // STOP CONDITION
    if (SCL == 1)
        stop_reg <= 1;
    else
        stop_reg <= 0; 
end

assign start = (start_reg & resetn) ? SCL : 0;
assign stop  = (stop_reg & resetn)  ? SCL : 0;    


reg [7:0] received;

// Master instantiation

i2cmaster master (clk,enable,resetn,SCL,SDA,LDAC,error,done);

// Sequential Instructions
    initial begin
    resetn = 1;enable = 0;
    SDA_reg = 8'bzzzzzzzz;
    #t_low resetn = 0;
    #t_wait resetn = 1;
    #(2*t_low) enable = 1;
    // Wait for Start

    wait(start == 1) I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_NACK();
    SDA_reg = 8'bzzzzzzzz;
    #(5*t_low) resetn = 0;
    #t_wait resetn = 1;
        

    wait(start == 1) I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    SDA_reg = 8'bzzzzzzzz;

    wait(start == 1) I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    SDA_reg = 8'bzzzzzzzz;

    wait(start == 1) I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    SDA_reg = 8'bzzzzzzzz;

    wait(start == 1) I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    SDA_reg = 8'bzzzzzzzz;
    wait(start == 1) I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    SDA_reg = 8'bzzzzzzzz;

    wait(start == 1) I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    SDA_reg = 8'bzzzzzzzz;

    wait(start == 1) I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    SDA_reg = 8'bzzzzzzzz;

    wait(start == 1) I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    SDA_reg = 8'bzzzzzzzz;
    wait(start == 1) I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    SDA_reg = 8'bzzzzzzzz;

    wait(start == 1) I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    SDA_reg = 8'bzzzzzzzz;

    wait(start == 1) I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    SDA_reg = 8'bzzzzzzzz;

    wait(start == 1) I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    SDA_reg = 8'bzzzzzzzz;
    wait(start == 1) I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    SDA_reg = 8'bzzzzzzzz;

    wait(start == 1) I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    SDA_reg = 8'bzzzzzzzz;

    wait(start == 1) I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    SDA_reg = 8'bzzzzzzzz;

    wait(start == 1) I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    SDA_reg = 8'bzzzzzzzz;

    wait(start == 1) I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    I2C_receive(received);
    send_ACK();
    SDA_reg = 8'bzzzzzzzz;

    end

//assign statements
assign SDA = SDA_reg;

endmodule
