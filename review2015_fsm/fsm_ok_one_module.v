module top_module (
    input clk,
    input reset,      // Synchronous reset
    input data,
    output reg shift_ena,
    output reg counting,
    input done_counting,
    output reg done,
    input ack);
    
    localparam [2:0] RECV = 3'b000, SHIFT = 3'b001, COUNTING = 3'b010, DONE = 3'b011;
    reg [2:0] curr_state, next_state;
    
    reg [2:0] pattern;
    reg [2:0] counter;
    
    always @(posedge clk) begin
        if (reset || curr_state == DONE)
            pattern <= 3'b000;
        else
            pattern <= {pattern[1:0], data};        
    end
    
    always @(posedge clk) begin
        if (!shift_ena)
            counter <= 3'b000;
        else
            counter <= counter + 1'b1;
    end    
    
    always @(*) begin
        next_state = curr_state;
        case (curr_state)
            RECV: begin
                if (pattern == 3'b110 && data == 1)
                    next_state = SHIFT;
            end
            SHIFT: begin
                if (counter == 3)
                    next_state = COUNTING;
            end
            COUNTING: begin
                if (done_counting)
                    next_state = DONE;
            end
            DONE: begin
                if (ack)
                    next_state = RECV;
            end
            default:
                next_state = curr_state;
        endcase
    end
    
    always @(*) begin
        case (curr_state)
            RECV: begin
                shift_ena = 0;
                counting = 0;
                done = 0;
            end
            SHIFT: begin
                shift_ena = 1;
                counting = 0;
                done = 0;
            end
            COUNTING: begin
                shift_ena = 0;
                counting = 1;
                done = 0;    
            end
            DONE: begin
                shift_ena = 0;
                counting = 0;
                done = 1;
            end
            default: begin
                shift_ena = 0;
                counting = 0;
                done = 0;
            end
        endcase
    end

    always @(posedge clk) begin
        if (reset)
            curr_state = RECV;
        else
            curr_state = next_state;
    end
endmodule