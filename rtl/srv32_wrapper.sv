`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIITD
// Engineer: NIKHIL PATEL
// 
// Create Date: 06/21/2025 03:33:46 PM
// Design Name: 
// Module Name: srv32_wrapper
// Project Name: SRV32_V_EXTENSION
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


module srv32_wrapper #(
    parameter RV32M = 1,
    parameter RV32E = 0,
    parameter RV32B = 0,
    parameter RV32C = 0
) (
    input clk,
    input resetb,

    input logic stall,
    output logic exception,
    output     timer_en,        //not defined as logic, cause it is driven by both this module and the clint in top module

    // interrupt
    input timer_irq,
    input sw_irq,
    input interrupt,

    // interface of instruction RAM
    output logic        imem_ready,
    input  logic        imem_valid,
    output logic [31:0] imem_addr,
    input  logic        imem_rresp,
    input  logic [31:0] imem_rdata,

    // interface of data RAM
    output logic        dmem_wready,
    input  logic        dmem_wvalid,
    output logic [31:0] dmem_waddr,
    output logic [31:0] dmem_wdata,
    output logic [ 3:0] dmem_wstrb,

    output logic        dmem_rready,
    input  logic        dmem_rvalid,
    output logic [31:0] dmem_raddr,
    input  logic        dmem_rresp,
    input  logic [31:0] dmem_rdata

    //cv_xif signals
);

    srv32_core #(
        .RV32M (RV32M),
        .RV32E (RV32E),
        .RV32B (RV32B),
        .RV32C (RV32C)
    ) srv32_core (
        .clk                (clk),
        .resetb             (resetb),

        .stall              (stall),
        .exception          (exception),
        .timer_en           (timer_en),

        .timer_irq          (timer_irq),
        .sw_irq             (sw_irq),
        .interrupt          (interrupt),

        .imem_ready         (imem_ready),
        .imem_valid         (imem_valid),
        .imem_addr          (imem_addr),
        .imem_rresp         (imem_rresp),
        .imem_rdata         (imem_rdata),

        .dmem_wready        (dmem_wready),
        .dmem_wvalid        (dmem_wvalid),
        .dmem_waddr         (dmem_waddr),
        .dmem_wdata         (dmem_wdata),
        .dmem_wstrb         (dmem_wstrb),

        .dmem_rready        (dmem_rready),
        .dmem_rvalid        (dmem_rvalid),
        .dmem_raddr         (dmem_raddr),
        .dmem_rresp         (dmem_rresp),
        .dmem_rdata         (dmem_rdata)
    );


endmodule
