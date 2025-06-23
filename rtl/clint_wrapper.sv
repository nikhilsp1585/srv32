`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/21/2025 04:06:48 PM
// Design Name: 
// Module Name: clint_wrapper
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


module clint_wrapper #(
    parameter RV32M = 1,
    parameter RV32E = 0,
    parameter RV32B = 0,
    parameter RV32C = 0
) (
    input logic clk,
    input logic resetb,
    input       timer_en,           //this is driven by srv32_wrapper also not defined as logic

    input  logic        wready,
    output logic        wvalid,
    input  logic [31:0] waddr,
    input  logic [31:0] wdata,
    input  logic [ 3:0] wstrb,

    input  logic        rready,
    output logic        rvalid,
    input  logic [31:0] raddr,
    output logic        rresp,
    output logic [31:0] rdata,

    output logic timer_irq,
    output logic sw_irq,
    output logic ex_irq
);


  clint #(
      .RV32M(RV32M),
      .RV32E(RV32E),
      .RV32B(RV32B),
      .RV32C(RV32C)
  ) clint (
      .clk     (clk),
      .resetb  (resetb),
      .timer_en(timer_en),

      .wready(wready),
      .wvalid(wvalid),
      .waddr (waddr),
      .wdata (wdata),
      .wstrb (wstrb),

      .rready(rready),
      .rvalid(rvalid),
      .raddr (raddr),
      .rresp (rresp),
      .rdata (rdata),

      .timer_irq(timer_irq),
      .sw_irq   (sw_irq),
      .ex_irq   (ex_irq)
  );
endmodule
