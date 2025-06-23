`timescale 1ns / 1ps
// Copyright © 2020 Kuoping Hsu
// Three pipeline stage RV32IM RISCV processor
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// ============================================================
// RISC-V top module
// ============================================================


module top #(
    parameter RV32M = 1,
    parameter RV32E = 0,
    parameter RV32B = 0,
    parameter RV32C = 0
) (
    input logic clk,
    input logic resetb,

    input  logic stall,
    output logic exception,

    // int logicerrupt
    input logic interrupt,

    // int logicerface of instruction RAM
    output logic        imem_ready,
    input  logic        imem_valid,
    output logic [31:0] imem_addr,
    input  logic        imem_rresp,
    input  logic [31:0] imem_rdata,

    // int logicerface of data RAM
    output logic        dmem_wready,
    input  logic        dmem_wvalid,
    output logic [31:0] dmem_waddr,
    output logic [31:0] dmem_wdata,
    output logic [ 3:0] dmem_wstrb,

    output logic        dmem_rready,
    input  logic        dmem_rvalid,
    output logic [31:0] dmem_raddr,
    input  logic        dmem_rresp,
    input  logic [31:0] dmem_rdata,

    output logic ex_irq
);

  `include "opcode.vh"

  wire        timer_irq;
  wire        timer_en;

  wire        twready;
  wire        twvalid;
  wire [31:0] twaddr;
  wire [31:0] twdata;
  wire [ 3:0] twstrb;

  wire        trready;
  wire        trvalid;
  wire [31:0] traddr;
  wire        trresp;
  wire [31:0] trdata;

  wire        dwready;
  wire        dwvalid;
  wire [31:0] dwaddr;
  wire [31:0] dwdata;
  wire [ 3:0] dwstrb;

  wire        drready;
  wire        drvalid;
  wire [31:0] draddr;
  wire        drresp;
  wire [31:0] drdata;
  reg         data_sel;
  wire        sw_irq;

  assign dmem_wready = dwready && (dwaddr[31:28] != CLINT_BASE);
  assign dwvalid     = (dwaddr[31:28] == CLINT_BASE) ? twvalid : dmem_wvalid;
  assign dmem_waddr  = dwaddr;
  assign dmem_wdata  = dwdata;
  assign dmem_wstrb  = dwstrb;

  assign dmem_rready = drready && (draddr[31:28] != CLINT_BASE);
  assign drvalid     = (draddr[31:28] == CLINT_BASE) ? trvalid : dmem_rvalid;
  assign dmem_raddr  = draddr;
  assign drresp      = 1'b1;  // FIXME dmem_rresp;
  assign drdata      = data_sel ? trdata : dmem_rdata;  // FIXME

  always @(posedge clk or negedge resetb) begin
    if (!resetb) data_sel <= 1'b0;
    else data_sel <= (draddr[31:28] == CLINT_BASE) ? 1'b1 : 1'b0;
  end

  srv32_wrapper #(
      .RV32M(RV32M),
      .RV32E(RV32E),
      .RV32B(RV32B),
      .RV32C(RV32C)
  ) u_core (
      .clk   (clk),
      .resetb(resetb),

      .stall    (stall),
      .exception(exception),
      .timer_en (timer_en),

      .timer_irq(timer_irq),
      .sw_irq   (sw_irq),
      .interrupt(interrupt),

      .imem_ready(imem_ready),
      .imem_valid(imem_valid),
      .imem_addr (imem_addr),
      .imem_rresp(imem_rresp),
      .imem_rdata(imem_rdata),

      .dmem_wready(dwready),
      .dmem_wvalid(dwvalid),
      .dmem_waddr (dwaddr),
      .dmem_wdata (dwdata),
      .dmem_wstrb (dwstrb),

      .dmem_rready(drready),
      .dmem_rvalid(drvalid),
      .dmem_raddr (draddr),
      .dmem_rresp (drresp),
      .dmem_rdata (drdata)
  );

  assign twready = dwready && (dwaddr[31:28] == CLINT_BASE);
  assign twaddr  = dwaddr;
  assign twdata  = dwdata;
  assign twstrb  = dwstrb;

  assign trready = drready && (draddr[31:28] == CLINT_BASE);
  assign traddr  = draddr;

  clint_wrapper #(
      .RV32M(RV32M),
      .RV32E(RV32E),
      .RV32B(RV32B),
      .RV32C(RV32C)
  ) clint (
      .clk     (clk),
      .resetb  (resetb),
      .timer_en(timer_en),

      .wready(twready),
      .wvalid(twvalid),
      .waddr (twaddr),
      .wdata (twdata),
      .wstrb (twstrb),

      .rready(trready),
      .rvalid(trvalid),
      .raddr (traddr),
      .rresp (trresp),
      .rdata (trdata),

      .timer_irq(timer_irq),
      .sw_irq   (sw_irq),
      .ex_irq   (ex_irq)
  );

endmodule

