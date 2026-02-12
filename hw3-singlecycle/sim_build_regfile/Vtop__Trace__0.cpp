// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_fst_c.h"
#include "Vtop__Syms.h"


void Vtop___024root__trace_chg_0_sub_0(Vtop___024root* vlSelf, VerilatedFst::Buffer* bufp);

void Vtop___024root__trace_chg_0(void* voidSelf, VerilatedFst::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_chg_0\n"); );
    // Init
    Vtop___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtop___024root*>(voidSelf);
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vtop___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vtop___024root__trace_chg_0_sub_0(Vtop___024root* vlSelf, VerilatedFst::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_chg_0_sub_0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    bufp->chgCData(oldp+0,(vlSelfRef.rd),5);
    bufp->chgIData(oldp+1,(vlSelfRef.rd_data),32);
    bufp->chgCData(oldp+2,(vlSelfRef.rs1),5);
    bufp->chgIData(oldp+3,(vlSelfRef.rs1_data),32);
    bufp->chgCData(oldp+4,(vlSelfRef.rs2),5);
    bufp->chgIData(oldp+5,(vlSelfRef.rs2_data),32);
    bufp->chgBit(oldp+6,(vlSelfRef.clk));
    bufp->chgBit(oldp+7,(vlSelfRef.we));
    bufp->chgBit(oldp+8,(vlSelfRef.rst));
    bufp->chgCData(oldp+9,(vlSelfRef.RegFile__DOT__rd),5);
    bufp->chgIData(oldp+10,(vlSelfRef.RegFile__DOT__rd_data),32);
    bufp->chgCData(oldp+11,(vlSelfRef.RegFile__DOT__rs1),5);
    bufp->chgIData(oldp+12,(vlSelfRef.RegFile__DOT__rs1_data),32);
    bufp->chgCData(oldp+13,(vlSelfRef.RegFile__DOT__rs2),5);
    bufp->chgIData(oldp+14,(vlSelfRef.RegFile__DOT__rs2_data),32);
    bufp->chgBit(oldp+15,(vlSelfRef.RegFile__DOT__clk));
    bufp->chgBit(oldp+16,(vlSelfRef.RegFile__DOT__we));
    bufp->chgBit(oldp+17,(vlSelfRef.RegFile__DOT__rst));
    bufp->chgIData(oldp+18,(vlSelfRef.RegFile__DOT__regs[0]),32);
    bufp->chgIData(oldp+19,(vlSelfRef.RegFile__DOT__regs[1]),32);
    bufp->chgIData(oldp+20,(vlSelfRef.RegFile__DOT__regs[2]),32);
    bufp->chgIData(oldp+21,(vlSelfRef.RegFile__DOT__regs[3]),32);
    bufp->chgIData(oldp+22,(vlSelfRef.RegFile__DOT__regs[4]),32);
    bufp->chgIData(oldp+23,(vlSelfRef.RegFile__DOT__regs[5]),32);
    bufp->chgIData(oldp+24,(vlSelfRef.RegFile__DOT__regs[6]),32);
    bufp->chgIData(oldp+25,(vlSelfRef.RegFile__DOT__regs[7]),32);
    bufp->chgIData(oldp+26,(vlSelfRef.RegFile__DOT__regs[8]),32);
    bufp->chgIData(oldp+27,(vlSelfRef.RegFile__DOT__regs[9]),32);
    bufp->chgIData(oldp+28,(vlSelfRef.RegFile__DOT__regs[10]),32);
    bufp->chgIData(oldp+29,(vlSelfRef.RegFile__DOT__regs[11]),32);
    bufp->chgIData(oldp+30,(vlSelfRef.RegFile__DOT__regs[12]),32);
    bufp->chgIData(oldp+31,(vlSelfRef.RegFile__DOT__regs[13]),32);
    bufp->chgIData(oldp+32,(vlSelfRef.RegFile__DOT__regs[14]),32);
    bufp->chgIData(oldp+33,(vlSelfRef.RegFile__DOT__regs[15]),32);
    bufp->chgIData(oldp+34,(vlSelfRef.RegFile__DOT__regs[16]),32);
    bufp->chgIData(oldp+35,(vlSelfRef.RegFile__DOT__regs[17]),32);
    bufp->chgIData(oldp+36,(vlSelfRef.RegFile__DOT__regs[18]),32);
    bufp->chgIData(oldp+37,(vlSelfRef.RegFile__DOT__regs[19]),32);
    bufp->chgIData(oldp+38,(vlSelfRef.RegFile__DOT__regs[20]),32);
    bufp->chgIData(oldp+39,(vlSelfRef.RegFile__DOT__regs[21]),32);
    bufp->chgIData(oldp+40,(vlSelfRef.RegFile__DOT__regs[22]),32);
    bufp->chgIData(oldp+41,(vlSelfRef.RegFile__DOT__regs[23]),32);
    bufp->chgIData(oldp+42,(vlSelfRef.RegFile__DOT__regs[24]),32);
    bufp->chgIData(oldp+43,(vlSelfRef.RegFile__DOT__regs[25]),32);
    bufp->chgIData(oldp+44,(vlSelfRef.RegFile__DOT__regs[26]),32);
    bufp->chgIData(oldp+45,(vlSelfRef.RegFile__DOT__regs[27]),32);
    bufp->chgIData(oldp+46,(vlSelfRef.RegFile__DOT__regs[28]),32);
    bufp->chgIData(oldp+47,(vlSelfRef.RegFile__DOT__regs[29]),32);
    bufp->chgIData(oldp+48,(vlSelfRef.RegFile__DOT__regs[30]),32);
    bufp->chgIData(oldp+49,(vlSelfRef.RegFile__DOT__regs[31]),32);
    bufp->chgIData(oldp+50,(vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i),32);
}

void Vtop___024root__trace_cleanup(void* voidSelf, VerilatedFst* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_cleanup\n"); );
    // Init
    Vtop___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtop___024root*>(voidSelf);
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VlUnpacked<CData/*0:0*/, 1> __Vm_traceActivity;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        __Vm_traceActivity[__Vi0] = 0;
    }
    // Body
    vlSymsp->__Vm_activity = false;
    __Vm_traceActivity[0U] = 0U;
}
