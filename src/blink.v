module blink (
    input clk,
    output reg led
);
    reg [23:0] counter = 0;
    always @(posedge clk) begin
        counter <= counter + 1;
        if (counter == 24'd13_500_000) begin
            counter <= 0;
            led <= ~led;
        end
    end
endmodule
