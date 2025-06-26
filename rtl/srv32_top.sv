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

/* verilator lint_off MODDUP */
module srv32_top
    import vproc_pkg::*;
#(
    parameter RV32M = 1,
    parameter RV32E = 0,
    parameter RV32B = 0,
    parameter RV32C = 0,
    parameter USE_XIF_MEM = '1,
    
    parameter int unsigned MEM_W         = 32,            // memory bus width in bits
    parameter int unsigned VMEM_W        = 32,            // vector memory interface width in bits
    parameter vreg_type    VREG_TYPE     = VREG_GENERIC,
    parameter mul_type     MUL_TYPE      = MUL_GENERIC,
    parameter int unsigned ICACHE_SZ     = 0,             // instruction cache size in bytes
    parameter int unsigned ICACHE_LINE_W = 128,           // instruction cache line width in bits
    parameter int unsigned DCACHE_SZ     = 0,             // data cache size in bytes
    parameter int unsigned DCACHE_LINE_W = 512            // data cache line width in bits
) (
    input logic clk,
    input logic resetb,
    input  logic stall,
    
    output logic exception,

    // int logicerrupt
    input logic ir,

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
    
    // //CV XIF Signals
    // cv_xif.cpu_issue xif_issue_if,
    // cv_xif.cpu_register xif_reg_if,
    // cv_xif.cpu_commit xif_commit_if,
    // cv_xif.cpu_mem xif_mem_if,
    // cv_xif.cpu_mem_result xif_mem_result_if,
    // cv_xif.cpu_result xif_result_if    
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
  assign drresp      = 1'b1;  // FIXME dmem_rresp; <=================fix 
  assign drdata      = data_sel ? trdata : dmem_rdata;  // FIXME

  always @(posedge clk or negedge resetb) begin
    if (!resetb) data_sel <= 1'b0;
    else data_sel <= (draddr[31:28] == CLINT_BASE) ? 1'b1 : 1'b0;
  end

  // Vector Unit Interface
  localparam X_NUM_RS = 2;
  localparam X_ID_WIDTH = 3;
  localparam X_RFR_WIDTH = 32;
  localparam X_RFW_WIDTH = 32;
  localparam X_MISA = 0;
  
  cv_xif #(
      .X_NUM_RS   (X_NUM_RS),
      .X_ID_WIDTH (X_ID_WIDTH),
      .X_MEM_WIDTH(VMEM_W),
      .X_RFR_WIDTH(X_RFR_WIDTH),
      .X_RFW_WIDTH(X_RFW_WIDTH),
      .X_MISA     (X_MISA)
  ) srv32_xif ();

  vproc_xif #(
      .X_NUM_RS   (X_NUM_RS),
      .X_ID_WIDTH (X_ID_WIDTH),
      .X_MEM_WIDTH(VMEM_W),
      .X_RFR_WIDTH(X_RFR_WIDTH),
      .X_RFW_WIDTH(X_RFW_WIDTH),
      .X_MISA     (X_MISA)
  ) vcore_xif ();

  srv32_wrapper #(
      .RV32M(RV32M),
      .RV32E(RV32E),
      .RV32B(RV32B),
      .RV32C(RV32C)
  ) srv32_core (
      .clk   (clk),
      .resetb(resetb),

      .stall    (stall),
      .exception(exception),
      .timer_en (timer_en),

      .timer_irq(timer_irq),
      .sw_irq   (sw_irq),
      .interrupt(ir),

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
      .dmem_rdata (drdata),
      
      .xif_issue_if        (srv32_xif),
      .xif_commit_if       (srv32_xif),
      .xif_reg_if          (srv32_xif),
      .xif_mem_if          (srv32_xif),
      .xif_mem_result_if   (srv32_xif),
      .xif_result_if       (srv32_xif)
  );
  
  /////////////////////////////////////////////////////////////////////////////////
  /////CV_XIF Interfacing
  ////////////////////////////////////////////////////////////////////////////////
  
  
// //  assign sdata_req = '0;
  assign vcore_xif.issue_valid = srv32_xif.issue_valid;
  assign srv32_xif.issue_ready = vcore_xif.issue_ready;

  assign vcore_xif.issue_req.id = srv32_xif.issue_req.id;
  assign vcore_xif.issue_req.instr = srv32_xif.issue_req.instr;
  assign vcore_xif.issue_req.mode = srv32_xif.issue_req.mode;

  assign srv32_xif.issue_resp.accept = vcore_xif.issue_resp.accept;
  assign srv32_xif.issue_resp.writeback = vcore_xif.issue_resp.writeback;
  assign srv32_xif.issue_resp.loadstore = vcore_xif.issue_resp.loadstore;
  assign srv32_xif.issue_resp.exc = vcore_xif.issue_resp.exc;
  //test
  assign srv32_xif.issue_resp.dualwrite = vcore_xif.issue_resp.dualwrite;
  assign srv32_xif.issue_resp.dualread = vcore_xif.issue_resp.dualread;

  assign vcore_xif.issue_valid = srv32_xif.register_valid; // register_valid = issue_valid (cpu)
  assign srv32_xif.register_ready = vcore_xif.issue_ready; //register_ready = issue_ready (cpu)
  assign vcore_xif.issue_req.rs = srv32_xif.register.rs;  //change to register if or add in issue if
  assign vcore_xif.issue_req.rs_valid = srv32_xif.register.rs_valid;

  assign vcore_xif.commit_valid = srv32_xif.commit_valid;
  assign vcore_xif.commit.id = srv32_xif.commit.id;
  assign vcore_xif.commit.commit_kill = srv32_xif.commit.commit_kill;

  assign srv32_xif.result_valid = vcore_xif.result_valid;
  assign vcore_xif.result_ready = srv32_xif.result_ready;
  assign srv32_xif.result.id = vcore_xif.result.id;
  assign srv32_xif.result.data = vcore_xif.result.data;
  assign srv32_xif.result.rd = vcore_xif.result.rd;
  assign srv32_xif.result.we = vcore_xif.result.we;
  assign srv32_xif.result.exc = vcore_xif.result.exc;
  assign srv32_xif.result.exccode = vcore_xif.result.exccode;
  assign srv32_xif.result.err = vcore_xif.result.err;
  assign srv32_xif.result.dbg = vcore_xif.result.dbg;
  
  if (USE_XIF_MEM) begin
    assign srv32_xif.mem_valid        = vcore_xif.mem_valid;
    assign vcore_xif.mem_ready        = srv32_xif.mem_ready;
    assign srv32_xif.mem_req.id       = vcore_xif.mem_req.id;
    assign srv32_xif.mem_req.addr     = vcore_xif.mem_req.addr;
    assign srv32_xif.mem_req.mode     = vcore_xif.mem_req.mode;
    assign srv32_xif.mem_req.we       = vcore_xif.mem_req.we;
    assign srv32_xif.mem_req.size     = vcore_xif.mem_req.size;
    assign srv32_xif.mem_req.be       = vcore_xif.mem_req.be;
    assign srv32_xif.mem_req.attr     = vcore_xif.mem_req.attr;
    assign srv32_xif.mem_req.wdata    = vcore_xif.mem_req.wdata;
    assign srv32_xif.mem_req.last     = vcore_xif.mem_req.last;
    assign srv32_xif.mem_req.spec     = vcore_xif.mem_req.spec;
    assign vcore_xif.mem_resp.exc     = srv32_xif.mem_resp.exc;
    assign vcore_xif.mem_resp.exccode = srv32_xif.mem_resp.exccode;
    assign vcore_xif.mem_resp.dbg     = srv32_xif.mem_resp.dbg;
    assign vcore_xif.mem_result_valid = srv32_xif.mem_result_valid;
    assign vcore_xif.mem_result.id    = srv32_xif.mem_result.id;
    assign vcore_xif.mem_result.rdata = srv32_xif.mem_result.rdata;
    assign vcore_xif.mem_result.err   = srv32_xif.mem_result.err;
    assign vcore_xif.mem_result.dbg   = srv32_xif.mem_result.dbg;
  end
  
  ///////////////////////////////////////////////////////////////////////////
  //// Vicuna Vector Core Integration
  //////////////////////////////////////////////////////////////////////////
  
  // Vector CSR read/write conversion
  logic [31:0] csr_vtype;
  logic [31:0] csr_vl;
  logic [31:0] csr_vlenb;
  logic [31:0] csr_vstart_rd;
  logic [31:0] csr_vstart_wr;
  logic        csr_vstart_wren;
  logic        csr_vxsat_rd;
  logic        csr_vxsat_wr;
  logic        csr_vxsat_wren;
  logic [ 1:0] csr_vxrm_rd;
  logic [ 1:0] csr_vxrm_wr;
  logic        csr_vxrm_wren;
  logic [31:0] pend_vreg_wr_map_o;
  logic vect_pending_load;
  logic vect_pending_store;
  
  localparam bit [VLSU_FLAGS_W-1:0] VLSU_FLAGS = (VLSU_FLAGS_W'(1) << VLSU_ALIGNED_UNITSTRIDE);

  localparam bit [BUF_FLAGS_W -1:0] BUF_FLAGS  = (BUF_FLAGS_W'(1) << BUF_DEQUEUE  ) |
                                                   (BUF_FLAGS_W'(1) << BUF_VREG_PEND);
  
  vproc_core #(
      .XIF_ID_W      (X_ID_WIDTH),
      .XIF_MEM_W     (VMEM_W),
      .VREG_TYPE     (VREG_TYPE),
      .MUL_TYPE      (MUL_TYPE),
      .VLSU_FLAGS    (VLSU_FLAGS),
      .BUF_FLAGS     (BUF_FLAGS),
      .DONT_CARE_ZERO(1'b0),
      .ASYNC_RESET   (1'b0)
  ) v_core (
      .clk_i (clk),
      .rst_ni(resetb),

      .xif_issue_if (vcore_xif),
      .xif_commit_if(vcore_xif),
      .xif_mem_if   (vcore_xif),
      .xif_memres_if(vcore_xif),
      .xif_result_if(vcore_xif),

      .pending_load_o (vect_pending_load),
      .pending_store_o(vect_pending_store),

      .csr_vtype_o     (csr_vtype),
      .csr_vl_o        (csr_vl),
      .csr_vlenb_o     (csr_vlenb),
      .csr_vstart_o    (csr_vstart_rd),
      .csr_vstart_i    (csr_vstart_wr),
      .csr_vstart_set_i(csr_vstart_wren),
      .csr_vxrm_o      (csr_vxrm_rd),
      .csr_vxrm_i      (csr_vxrm_wr),
      .csr_vxrm_set_i  (csr_vxrm_wren),
      .csr_vxsat_o     (csr_vxsat_rd),
      .csr_vxsat_i     (csr_vxsat_wr),
      .csr_vxsat_set_i (csr_vxsat_wren),

      .pend_vreg_wr_map_o(pend_vreg_wr_map_o)
  );

  //////////////////////////////////////////////////////////////////////////////////  
  //CLINT INTERRUPT CONTROLLER INTEGRATION
  ////////////////////////////////////////////////////////////////////////////////////
  
  
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
