// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vriscv.h for the primary calling header

#ifndef VERILATED_VRISCV___024UNIT_H_
#define VERILATED_VRISCV___024UNIT_H_  // guard

#include "verilated_heavy.h"

//==========

class Vriscv__Syms;
class Vriscv_VerilatedFst;


//----------

VL_MODULE(Vriscv___024unit) {
  public:

    // INTERNAL VARIABLES
    Vriscv__Syms* vlSymsp;  // Symbol table

    // CONSTRUCTORS
  private:
    VL_UNCOPYABLE(Vriscv___024unit);  ///< Copying not allowed
  public:
    Vriscv___024unit(const char* name);
    ~Vriscv___024unit();

    // INTERNAL METHODS
    void __Vconfigure(Vriscv__Syms* symsp, bool first);
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

//----------


#endif  // guard
