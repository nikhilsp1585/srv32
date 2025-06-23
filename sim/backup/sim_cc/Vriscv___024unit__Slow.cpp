// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vriscv.h for the primary calling header

#include "Vriscv___024unit.h"
#include "Vriscv__Syms.h"

#include "verilated_dpi.h"

//==========


void Vriscv___024unit___ctor_var_reset(Vriscv___024unit* vlSelf);

Vriscv___024unit::Vriscv___024unit(const char* _vcname__)
    : VerilatedModule(_vcname__)
 {
    // Reset structure values
    Vriscv___024unit___ctor_var_reset(this);
}

void Vriscv___024unit::__Vconfigure(Vriscv__Syms* _vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->vlSymsp = _vlSymsp;
}

Vriscv___024unit::~Vriscv___024unit() {
}

void Vriscv___024unit___ctor_var_reset(Vriscv___024unit* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+        Vriscv___024unit___ctor_var_reset\n"); );
}
