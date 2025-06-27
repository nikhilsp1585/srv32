// Issue Interface
        output                            issue_valid,                    // Issue request valid
        input                             issue_ready,                    // Issue request ready
        // x_issue_req_t
        output [31:0]                     issue_req_instr,                // Offloaded instruction
        output [1:0]                      issue_req_mode,                 // Effective Privilege level, as used for load and store instructions.
        output [X_ID_WIDTH-1:0]           issue_req_id,                   // Identification of the offloaded instruction
        // x_issue_resp_t
        input                             issue_resp_accept,              // Is the offloaded instruction (id) accepted by the coprocessor?
        input [X_DUALWRITE:0]             issue_resp_writeregflags,       // Will the coprocessor perform a writeback in the core to rd?
        input [X_NUM_RS+X_DUALREAD-1:0]   issue_resp_readerflags,         // Will the coprocessor perform require specific registers to be read?
        input                             issue_resp_loadstore,           // Is the offloaded instruction a load/store instruction?
   
    // Register Interface
        output                            register_valid,                 // Register request valid. 
        input                             register_ready,                 // Register request ready.
        // x_register_t
        output [X_ID_WIDTH-1:0]           register_id,                    // Identification of the offloaded instruction.
        output [X_RFR_WIDTH*X_NUM_RS-1:0] register_rs,                    // Register file source 
        output [X_NUM_RS+X_DUALREAD-1:0]  register_rs_valid,              // Validity of the register file source operand(s).
        
    // Commit Interface
        output                            commit_valid,                   //Commit request valid.
        //x_commit_t
        output [X_ID_WIDTH-1:0]           commit_id,                      // Identification of the offloaded instruction. 
        output                            commit_kill,                    // Shall an offloaded instruction be killed?
    
    // Memory (request/response) Interface
        input                             mem_valid,                      // Memory (request/response) valid. 
        output                            mem_ready,                      // Memory (request/response) ready.
        // x_mem_req_t
        input [X_ID_WIDTH-1:0]            mem_req_id,                     // Identification of the offloaded instruction
        input [31:0]                      mem_req_addr,                   // Virtual address of the memory transaction
        input [1:0]                       mem_req_mode,                   // Privilege level
        input                             mem_req_we,                     // Write enable of the memory transaction
        input [2:0]                       mem_req_size,                   // Size of the memory transaction.
        input [X_MEM_WIDTH/8-1:0]         mem_req_be,                     // Byte enables for memory transaction.
        input [1:0]                       mem_req_attr,                   // Memory transaction attributes.
        input [X_MEM_WIDTH-1:0]           mem_req_wdata,                  // Write data of a store memory transaction
        input                             mem_req_last,                   // Is this the last memory transaction for the offloaded instruction?
        input                             mem_req_spec,                   // Is the memory transaction speculative?
        // x_mem_resp_t
        output                            mem_resp_exc,                   // Did the memory request cause a synchronous exception?
        output [5:0]                      mem_resp_excode,                // Exception code.
        output                            mem_resp_dbg,                   // Did the memory request cause a debug trigger match with ``mcontrol.timing`` = 0?

        
    // Memory Result Interface
        output                            mem_result_valid,               // Memory result valid.
        // x_mem_result_t
        output [X_ID_WIDTH-1:0]           mem_result_id,                  // Identification of the offloaded instruction.
        output [X_MEM_WIDTH-1:0]          mem_result_rdata,               // Read data of a read memory transaction. Only used for reads.
        output                            mem_result_err,                 // Did the instruction cause a bus error?
        output                            mem_result_dbg,                 // Did the read data cause a debug trigger match with ``mcontrol.timing`` = 0?
        
    // Result Interface   
        input                             result_valid,                   // Result request valid.
        output                            result_ready,                   // Result request ready.
        // x_result_t
        input [X_ID_WIDTH-1:0]            result_id,                      // Identification of the offloaded instruction
        input [X_RFW_WIDTH-1:0]           result_data,                    // Register file write data value(s)
        input [4:0]                       result_rd,                      // Register file destination address(es)
        input [X_DUALWRITE:0]             result_we,                      // Register file write enable(s)
        input                             result_exc,                     // Did the instruction cause a synchronous exception?
        input [5:0]                       result_excode,                  // Exception code
        input                             result_dbg,                     // Did the instruction cause a debug trigger match with ``mcontrol.timing`` = 0?
        input                             result_err,                     // Did the instruction cause a bus error?