module pattern (
    input clk,
    input reset,
    input data,
    output reg found);
    
    reg [2:0] counter;
    
    always @(*) begin
        if (counter == 3'b110 && data == 1)
            found = 1;
        else
            found = 0;
    end
    
    always @(posedge clk) begin
        if (reset) begin
            counter <= 3'b000;
        end else begin
            counter <= {counter[1:0], data};
        end
    end
endmodule

module counter (
    input clk,
    input reset,
    input start,
    output reg shift_ena,
    output reg done);

    reg [2:0] count;

    localparam [1:0] IDLE = 2'b00, BEGIN = 2'b01, END = 2'b10;
    reg [1:0] curr_state, next_state;
    
    always @(*) begin
        next_state = curr_state;
        case (curr_state)
            IDLE: begin
                if (start)
                    next_state = BEGIN;
            end
            BEGIN: begin
                if (count == 3)
                    next_state = END;
            end
            END: begin
                next_state = IDLE;    
            end
            default: begin
                next_state = curr_state;
            end
        endcase
    end
    
    always @(*) begin
        case (curr_state)
            IDLE: begin
                shift_ena = 0;
                done = 0;
            end
            BEGIN: begin
                shift_ena = 1;
                done = 0;
                if (next_state == END)
                    done = 1;
            end
            END: begin
                shift_ena = 0;
                done = 1;
            end
            default: begin
                shift_ena = 0;
                done = 0;
            end
        endcase
    end
    
    always @(posedge clk) begin
        if (reset) 
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end
    
    always @(posedge clk) begin
        if (start) begin
            count <= 0;
        end else begin
            count <= count + 1'b1;            
        end
    end
endmodule

module stop_single (
    input clk,
    input reset,
    input start,
    input stop,
    output reg single,
    output reg done);
    
    localparam [1:0] IDLE = 2'b00, BEGIN = 2'b01, END = 2'b10;
    reg [1:0] curr_state, next_state;
    
    always @(*) begin
        next_state = curr_state;
        case (curr_state)
            IDLE: begin
                if (start)
                    next_state = BEGIN;
            end
            BEGIN: begin
                if (stop)
                    next_state = END;
            end
            END: begin
                next_state = IDLE;    
            end
            default: begin
                next_state = curr_state;    
            end
        endcase
    end
    
    always @(*) begin
        case (curr_state)
            IDLE: begin
                single = 0;
                done = 0;
            end
            BEGIN: begin
                single = 1;
                done = 0;
                if (next_state == END)
                    done = 1;
            end
            END: begin
                single = 0;
                done = 1;
            end
        endcase
    end
    
    always @(posedge clk) begin
        if (reset) 
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end

endmodule

module top_module (
    input clk,
    input reset,      // Synchronous reset
    input data,
    output shift_ena,
    output counting,
    input done_counting,
    output done,
    input ack);
    
    wire found;
    pattern pattern_obj (
        .clk(clk),
        .reset(reset || shift_ena || counting || done),
        .data(data),
        .found(found)
    );
    
    wire counter_done;
    counter counter_obj (
        .clk(clk),
        .reset(reset),
        .start(found),
        .shift_ena(shift_ena),
        .done(counter_done)
    );
    
    wire single_done1;
    stop_single stop_single_obj1 (
        .clk(clk),
        .reset(reset),
        .start(counter_done),
        .stop(done_counting),
        .single(counting),
        .done(single_done1)
    );
    
    wire single_done2;
    stop_single stop_single_obj2 (
        .clk(clk),
        .reset(reset),
        .start(single_done1),
        .stop(ack),
        .single(done),
        .done(single_done2)
    );    
endmodule

