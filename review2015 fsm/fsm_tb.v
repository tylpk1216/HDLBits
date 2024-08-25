`timescale 1ns/1ns

`include "fsm_ok_one_module.v"
//`include "fsm_error.v"
//`include "fsm_ok_two_submodule.v"

module test_tb;
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, test_tb);
    end
    
    reg clk;
    reg reset;
    reg data;
    reg done_counting;
    reg ack;
    
    wire shift_ena;
    wire counting;
    wire done;
        
    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end
    
    initial begin
        reset = 1;
        data = 0;
        done_counting = 1;
        ack = 0;
        
        #10;
        reset <= 0;
        data <= 1;
        #10;
        data <= 0;
        #20;
        data <= 1;
        #20;
        data <= 0;
        #10;
        data <= 1;
        #10;
        data <= 0;
        
        // fake signal
        #40;
        done_counting <= 0;
        ack <= 1;
        
        #40;
        ack <= 0;
        done_counting <= 1;
        #10;
        done_counting <= 0;
        #30;
        ack <= 1;
        #10;
        ack <= 0;
        
        #10;
        $finish;
    end
    
    top_module dut (
        .clk(clk),
        .reset(reset),
        .data(data),
        .shift_ena(shift_ena),
        .counting(counting),
        .done_counting(done_counting),
        .done(done),
        .ack(ack)
    );
    
endmodule    
