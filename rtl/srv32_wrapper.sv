`timescale 1ns / 1ps
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
    parameter RV32C = 0,
    parameter X_NUM_RS = 2, 
    parameter X_ID_WIDTH = 4,  
    parameter X_RFR_WIDTH = 32,
    parameter X_RFW_WIDTH = 32,
    parameter logic [25:0] X_MISA = '0,  
    parameter X_DUALREAD = 0,  
    parameter X_DUALWRITE = 0,  
    parameter X_ISSUE_REGISTER_SPLIT = 0, 
    parameter X_MEM_WIDTH = 32
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
    input  logic [31:0] dmem_rdata,

    // cv_xif signals
    cv_xif.cpu_issue xif_issue_if,
    cv_xif.cpu_register xif_reg_if,
    cv_xif.cpu_commit xif_commit_if,
    cv_xif.cpu_mem xif_mem_if,
    cv_xif.cpu_mem_result xif_mem_result_if,
    cv_xif.cpu_result xif_result_if
);

  // Issue Interface
  logic                                         issue_valid;
  logic                                         issue_ready;
  logic [                   31:0]               issue_req_instr;
  logic [                    1:0]               issue_req_mode;
  logic [         X_ID_WIDTH-1:0]               issue_req_id;
  logic                                         issue_resp_accept;
  logic [          X_DUALWRITE:0]               issue_resp_writeback;
  // logic [X_NUM_RS+X_DUALREAD-1:0] issue_resp_readerflags; // optional
  logic                                         issue_resp_loadstore;
  logic                                         dualwrite;
  logic [                    2:0]               dualread;
  logic                                         exc;

  // Register Interface
  logic                                         register_valid;
  logic                                         register_ready;
  logic [         X_ID_WIDTH-1:0]               register_id;
  logic [        X_RFR_WIDTH-1:0][X_NUM_RS-1:0] register_rs;
  logic [X_NUM_RS+X_DUALREAD-1:0]               register_rs_valid;

  // Commit Interface
  logic                                         commit_valid;
  logic [         X_ID_WIDTH-1:0]               commit_id;
  logic                                         commit_kill;

  // Memory Interface
  logic                                         mem_valid;
  logic                                         mem_ready;
  logic [         X_ID_WIDTH-1:0]               mem_req_id;
  logic [                   31:0]               mem_req_addr;
  logic [                    1:0]               mem_req_mode;
  logic                                         mem_req_we;
  logic [                    2:0]               mem_req_size;
  logic [      X_MEM_WIDTH/8-1:0]               mem_req_be;
  logic [                    1:0]               mem_req_attr;
  logic [        X_MEM_WIDTH-1:0]               mem_req_wdata;
  logic                                         mem_req_last;
  logic                                         mem_req_spec;

  logic                                         mem_resp_exc;
  logic [                    5:0]               mem_resp_excode;
  logic                                         mem_resp_dbg;

  // Memory Result Interface
  logic                                         mem_result_valid;
  logic [         X_ID_WIDTH-1:0]               mem_result_id;
  logic [        X_MEM_WIDTH-1:0]               mem_result_rdata;
  logic                                         mem_result_err;
  logic                                         mem_result_dbg;

  // Result Interface
  logic                                         result_valid;
  logic                                         result_ready;
  logic [         X_ID_WIDTH-1:0]               result_id;
  logic [        X_RFW_WIDTH-1:0]               result_data;
  logic [                    4:0]               result_rd;
  logic [          X_DUALWRITE:0]               result_we;
  logic                                         result_exc;
  logic [                    5:0]               result_excode;
  logic                                         result_dbg;
  logic                                         result_err;

  srv32_core #(
      .RV32M(RV32M),
      .RV32E(RV32E),
      .RV32B(RV32B),
      .RV32C(RV32C)
  ) srv32 (
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

      .dmem_wready(dmem_wready),
      .dmem_wvalid(dmem_wvalid),
      .dmem_waddr (dmem_waddr),
      .dmem_wdata (dmem_wdata),
      .dmem_wstrb (dmem_wstrb),

      .dmem_rready(dmem_rready),
      .dmem_rvalid(dmem_rvalid),
      .dmem_raddr (dmem_raddr),
      .dmem_rresp (dmem_rresp),
      .dmem_rdata (dmem_rdata),

      //CV XIF Signals
      // Issue Interface
      .xif_issue_valid         (issue_valid),
      .xif_issue_ready         (issue_ready),
      .xif_issue_req_instr     (issue_req_instr),
      .xif_issue_req_mode      (issue_req_mode),
      .xif_issue_req_id        (issue_req_id),
      .xif_issue_resp_accept   (issue_resp_accept),
      .xif_issue_resp_writeback(issue_resp_writeback),
      // .issue_resp_readerflags(issue_resp_readerflags),??
      .xif_issue_resp_loadstore(issue_resp_loadstore),
      .xif_dualwrite           (dualwrite),
      .xif_dualread            (dualread),
      .xif_exc                 (exc),

      // Register Interface
      .xif_register_valid   (register_valid),
      .xif_register_ready   (register_ready),
      .xif_register_id      (register_id),
      .xif_register_rs      (register_rs),
      .xif_register_rs_valid(register_rs_valid),

      // Commit Interface
      .xif_commit_valid(commit_valid),
      .xif_commit_id   (commit_id),
      .xif_commit_kill (commit_kill),

      // Memory Request/Response Interface
      .xif_mem_valid      (mem_valid),
      .xif_mem_ready      (mem_ready),
      .xif_mem_req_id     (mem_req_id),
      .xif_mem_req_addr   (mem_req_addr),
      .xif_mem_req_mode   (mem_req_mode),
      .xif_mem_req_we     (mem_req_we),
      .xif_mem_req_size   (mem_req_size),
      .xif_mem_req_be     (mem_req_be),
      .xif_mem_req_attr   (mem_req_attr),
      .xif_mem_req_wdata  (mem_req_wdata),
      .xif_mem_req_last   (mem_req_last),
      .xif_mem_req_spec   (mem_req_spec),
      .xif_mem_resp_exc   (mem_resp_exc),
      .xif_mem_resp_excode(mem_resp_excode),
      .xif_mem_resp_dbg   (mem_resp_dbg),

      // Memory Result Interface
      .xif_mem_result_valid(mem_result_valid),
      .xif_mem_result_id   (mem_result_id),
      .xif_mem_result_rdata(mem_result_rdata),
      .xif_mem_result_err  (mem_result_err),
      .xif_mem_result_dbg  (mem_result_dbg),

      // Result Interface
      .xif_result_valid (result_valid),
      .xif_result_ready (result_ready),
      .xif_result_id    (result_id),
      .xif_result_data  (result_data),
      .xif_result_rd    (result_rd),
      .xif_result_we    (result_we),
      .xif_result_exc   (result_exc),
      .xif_result_excode(result_excode),
      .xif_result_dbg   (result_dbg),
      .xif_result_err   (result_err)
  );

  //Assigning Issue interface signals
  assign xif_issue_if.issue_valid = issue_valid;
  assign issue_ready = xif_issue_if.issue_ready;
  assign xif_issue_if.issue_req.instr = issue_req_instr;
  assign xif_issue_if.issue_req.mode = issue_req_mode;
  assign xif_issue_if.issue_req.id = issue_req_id;
  assign issue_resp_accept = xif_issue_if.issue_resp.accept;
  assign issue_resp_writeback = xif_issue_if.issue_resp.writeback;
  // assign issue_resp_readerflags = xif_issue_if.issue_resp.register_read; // ??
  assign issue_resp_loadstore = xif_issue_if.issue_resp.loadstore;
  assign dualwrite = xif_issue_if.issue_resp.dualwrite;
  assign dualread = xif_issue_if.issue_resp.dualread;
  assign exc = xif_issue_if.issue_resp.exc;

  //Assigning Register interface signals
  assign xif_reg_if.register_valid = register_valid;
  assign register_ready = xif_reg_if.register_ready;
  assign xif_reg_if.register.id = register_id;
  assign xif_reg_if.register.rs = register_rs;

  //Assigning Commit interface signals
  assign xif_commit_if.commit_valid = commit_valid;
  assign xif_commit_if.commit.id = commit_id;
  assign xif_commit_if.commit.commit_kill = commit_kill;

  //Assigning Memory interface signals
  assign mem_valid = xif_mem_if.mem_valid;
  assign xif_mem_if.mem_ready = mem_ready;
  assign mem_req_id = xif_mem_if.mem_req.id;
  assign mem_req_addr = xif_mem_if.mem_req.addr;
  assign mem_req_mode = xif_mem_if.mem_req.mode;
  assign mem_req_we = xif_mem_if.mem_req.we;
  assign mem_req_size = xif_mem_if.mem_req.size;
  assign mem_req_be = xif_mem_if.mem_req.be;
  assign mem_req_attr = xif_mem_if.mem_req.attr;
  assign mem_req_wdata = xif_mem_if.mem_req.wdata;
  assign mem_req_last = xif_mem_if.mem_req.last;
  assign mem_req_spec = xif_mem_if.mem_req.spec;
  assign xif_mem_if.mem_resp.exc = mem_resp_exc;
  assign xif_mem_if.mem_resp.exccode = mem_resp_excode;
  assign xif_mem_if.mem_resp.dbg = mem_resp_dbg;

  //Assigning Memoery result inteface signals
  assign xif_mem_result_if.mem_result_valid = mem_result_valid; // result ready will be provided implicitly    assign xif_mem_result_if.mem_result.id = mem_result_id;
  assign xif_mem_result_if.mem_result.rdata = mem_result_rdata;
  assign xif_mem_result_if.mem_result.err = mem_result_err;
  assign xif_mem_result_if.mem_result.dbg = mem_result_dbg;

  //Assigning Result interface signals
  assign result_valid = xif_result_if.result_valid;
  assign xif_result_if.result_ready = result_ready;
  assign result_id = xif_result_if.result.id;
  assign result_data = xif_result_if.result.data;
  assign result_rd = xif_result_if.result.rd;
  assign result_we = xif_result_if.result.we;
  assign result_exc = xif_result_if.result.exc;
  assign result_excode = xif_result_if.result.exccode;
  assign result_dbg = xif_result_if.result.dbg;
  assign result_err = xif_result_if.result.err;

endmodule
