// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vtop__pch.h"
#include "Vtop.h"
#include "Vtop___024root.h"
#include "Vtop___024unit.h"

// FUNCTIONS
Vtop__Syms::~Vtop__Syms()
{

    // Tear down scope hierarchy
    __Vhier.remove(0, &__Vscope_RegFile);
    __Vhier.remove(&__Vscope_RegFile, &__Vscope_RegFile__unnamedblk1);

}

Vtop__Syms::Vtop__Syms(VerilatedContext* contextp, const char* namep, Vtop* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    // Setup module instances
    , TOP{this, namep}
{
        // Check resources
        Verilated::stackCheck(39);
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-9);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
    // Setup each module's pointer back to symbol table (for public functions)
    TOP.__Vconfigure(true);
    // Setup scopes
    __Vscope_RegFile.configure(this, name(), "RegFile", "RegFile", "RegFile", -9, VerilatedScope::SCOPE_MODULE);
    __Vscope_RegFile__unnamedblk1.configure(this, name(), "RegFile.unnamedblk1", "unnamedblk1", "<null>", -9, VerilatedScope::SCOPE_OTHER);
    __Vscope_TOP.configure(this, name(), "TOP", "TOP", "<null>", 0, VerilatedScope::SCOPE_OTHER);

    // Set up scope hierarchy
    __Vhier.add(0, &__Vscope_RegFile);
    __Vhier.add(&__Vscope_RegFile, &__Vscope_RegFile__unnamedblk1);

    // Setup export functions
    for (int __Vfinal = 0; __Vfinal < 2; ++__Vfinal) {
        __Vscope_RegFile.varInsert(__Vfinal,"NumRegs", const_cast<void*>(static_cast<const void*>(&(TOP.RegFile__DOT__NumRegs))), true, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW|VLVF_DPI_CLAY,1 ,31,0);
        __Vscope_RegFile.varInsert(__Vfinal,"clk", &(TOP.RegFile__DOT__clk), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_RegFile.varInsert(__Vfinal,"rd", &(TOP.RegFile__DOT__rd), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,4,0);
        __Vscope_RegFile.varInsert(__Vfinal,"rd_data", &(TOP.RegFile__DOT__rd_data), false, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW,1 ,31,0);
        __Vscope_RegFile.varInsert(__Vfinal,"regs", &(TOP.RegFile__DOT__regs), false, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW,2 ,31,0 ,0,31);
        __Vscope_RegFile.varInsert(__Vfinal,"rs1", &(TOP.RegFile__DOT__rs1), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,4,0);
        __Vscope_RegFile.varInsert(__Vfinal,"rs1_data", &(TOP.RegFile__DOT__rs1_data), false, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW,1 ,31,0);
        __Vscope_RegFile.varInsert(__Vfinal,"rs2", &(TOP.RegFile__DOT__rs2), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,4,0);
        __Vscope_RegFile.varInsert(__Vfinal,"rs2_data", &(TOP.RegFile__DOT__rs2_data), false, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW,1 ,31,0);
        __Vscope_RegFile.varInsert(__Vfinal,"rst", &(TOP.RegFile__DOT__rst), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_RegFile.varInsert(__Vfinal,"we", &(TOP.RegFile__DOT__we), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_RegFile__unnamedblk1.varInsert(__Vfinal,"i", &(TOP.RegFile__DOT__unnamedblk1__DOT__i), false, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW,1 ,31,0);
        __Vscope_TOP.varInsert(__Vfinal,"clk", &(TOP.clk), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,0);
        __Vscope_TOP.varInsert(__Vfinal,"rd", &(TOP.rd), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,1 ,4,0);
        __Vscope_TOP.varInsert(__Vfinal,"rd_data", &(TOP.rd_data), false, VLVT_UINT32,VLVD_IN|VLVF_PUB_RW,1 ,31,0);
        __Vscope_TOP.varInsert(__Vfinal,"rs1", &(TOP.rs1), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,1 ,4,0);
        __Vscope_TOP.varInsert(__Vfinal,"rs1_data", &(TOP.rs1_data), false, VLVT_UINT32,VLVD_OUT|VLVF_PUB_RW,1 ,31,0);
        __Vscope_TOP.varInsert(__Vfinal,"rs2", &(TOP.rs2), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,1 ,4,0);
        __Vscope_TOP.varInsert(__Vfinal,"rs2_data", &(TOP.rs2_data), false, VLVT_UINT32,VLVD_OUT|VLVF_PUB_RW,1 ,31,0);
        __Vscope_TOP.varInsert(__Vfinal,"rst", &(TOP.rst), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,0);
        __Vscope_TOP.varInsert(__Vfinal,"we", &(TOP.we), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,0);
    }
}
