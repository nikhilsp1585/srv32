// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vriscv.h"
#include "Vriscv__Syms.h"
#include "verilated_fst_c.h"
#include "verilated_dpi.h"

//============================================================
// Constructors

Vriscv::Vriscv(VerilatedContext* _vcontextp__, const char* _vcname__)
    : vlSymsp{new Vriscv__Syms(_vcontextp__, _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , resetb{vlSymsp->TOP.resetb}
    , stall{vlSymsp->TOP.stall}
    , __PVT____024unit{vlSymsp->TOP.__PVT____024unit}
    , rootp{&(vlSymsp->TOP)}
{
}

Vriscv::Vriscv(const char* _vcname__)
    : Vriscv(nullptr, _vcname__)
{
}

//============================================================
// Destructor

Vriscv::~Vriscv() {
    delete vlSymsp;
}

//============================================================
// Evaluation loop

void Vriscv___024root___eval_initial(Vriscv___024root* vlSelf);
void Vriscv___024root___eval_settle(Vriscv___024root* vlSelf);
void Vriscv___024root___eval(Vriscv___024root* vlSelf);
QData Vriscv___024root___change_request(Vriscv___024root* vlSelf);
#ifdef VL_DEBUG
void Vriscv___024root___eval_debug_assertions(Vriscv___024root* vlSelf);
#endif  // VL_DEBUG
void Vriscv___024root___final(Vriscv___024root* vlSelf);

static void _eval_initial_loop(Vriscv__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    Vriscv___024root___eval_initial(&(vlSymsp->TOP));
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    vlSymsp->__Vm_activity = true;
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial loop\n"););
        Vriscv___024root___eval_settle(&(vlSymsp->TOP));
        Vriscv___024root___eval(&(vlSymsp->TOP));
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = Vriscv___024root___change_request(&(vlSymsp->TOP));
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("../rtl/../testbench/testbench.v", 40, "",
                "Verilated model didn't DC converge\n"
                "- See https://verilator.org/warn/DIDNOTCONVERGE");
        } else {
            __Vchange = Vriscv___024root___change_request(&(vlSymsp->TOP));
        }
    } while (VL_UNLIKELY(__Vchange));
}

void Vriscv::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vriscv::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vriscv___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    vlSymsp->__Vm_activity = true;
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Clock loop\n"););
        Vriscv___024root___eval(&(vlSymsp->TOP));
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = Vriscv___024root___change_request(&(vlSymsp->TOP));
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("../rtl/../testbench/testbench.v", 40, "",
                "Verilated model didn't converge\n"
                "- See https://verilator.org/warn/DIDNOTCONVERGE");
        } else {
            __Vchange = Vriscv___024root___change_request(&(vlSymsp->TOP));
        }
    } while (VL_UNLIKELY(__Vchange));
}

void Vriscv::eval_end_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+eval_end_step Vriscv::eval_end_step\n"); );
#ifdef VM_TRACE
    // Tracing
    if (VL_UNLIKELY(vlSymsp->__Vm_dumping)) vlSymsp->_traceDump();
#endif  // VM_TRACE
}

//============================================================
// Invoke final blocks

void Vriscv::final() {
    Vriscv___024root___final(&(vlSymsp->TOP));
}

//============================================================
// Utilities

VerilatedContext* Vriscv::contextp() const {
    return vlSymsp->_vm_contextp__;
}

const char* Vriscv::name() const {
    return vlSymsp->name();
}

//============================================================
// Trace configuration

void Vriscv___024root__traceInitTop(Vriscv___024root* vlSelf, VerilatedFst* tracep);

static void traceInit(void* voidSelf, VerilatedFst* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vriscv___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vriscv___024root*>(voidSelf);
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->module(vlSymsp->name());
    tracep->scopeEscape(' ');
    Vriscv___024root__traceInitTop(vlSelf, tracep);
    tracep->scopeEscape('.');
}

void Vriscv___024root__traceRegister(Vriscv___024root* vlSelf, VerilatedFst* tracep);

void Vriscv::trace(VerilatedFstC* tfp, int, int) {
    tfp->spTrace()->addInitCb(&traceInit, &(vlSymsp->TOP));
    Vriscv___024root__traceRegister(&(vlSymsp->TOP), tfp->spTrace());
}
