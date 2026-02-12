// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtop.h for the primary calling header

#include "Vtop__pch.h"
#include "Vtop___024root.h"

void Vtop___024root___ico_sequent__TOP__0(Vtop___024root* vlSelf);

void Vtop___024root___eval_ico(Vtop___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_ico\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VicoTriggered.word(0U))) {
        Vtop___024root___ico_sequent__TOP__0(vlSelf);
    }
}

VL_INLINE_OPT void Vtop___024root___ico_sequent__TOP__0(Vtop___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___ico_sequent__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.RegFile__DOT__rd = vlSelfRef.rd;
    vlSelfRef.RegFile__DOT__rd_data = vlSelfRef.rd_data;
    vlSelfRef.RegFile__DOT__rs1 = vlSelfRef.rs1;
    vlSelfRef.RegFile__DOT__rs2 = vlSelfRef.rs2;
    vlSelfRef.RegFile__DOT__clk = vlSelfRef.clk;
    vlSelfRef.RegFile__DOT__we = vlSelfRef.we;
    vlSelfRef.RegFile__DOT__rst = vlSelfRef.rst;
    vlSelfRef.RegFile__DOT__rs1_data = ((0U == (IData)(vlSelfRef.rs1))
                                         ? 0U : vlSelfRef.RegFile__DOT__regs
                                        [vlSelfRef.rs1]);
    vlSelfRef.RegFile__DOT__rs2_data = ((0U == (IData)(vlSelfRef.rs2))
                                         ? 0U : vlSelfRef.RegFile__DOT__regs
                                        [vlSelfRef.rs2]);
    vlSelfRef.rs1_data = vlSelfRef.RegFile__DOT__rs1_data;
    vlSelfRef.rs2_data = vlSelfRef.RegFile__DOT__rs2_data;
}

void Vtop___024root___eval_triggers__ico(Vtop___024root* vlSelf);

bool Vtop___024root___eval_phase__ico(Vtop___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_phase__ico\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VicoExecute;
    // Body
    Vtop___024root___eval_triggers__ico(vlSelf);
    __VicoExecute = vlSelfRef.__VicoTriggered.any();
    if (__VicoExecute) {
        Vtop___024root___eval_ico(vlSelf);
    }
    return (__VicoExecute);
}

void Vtop___024root___eval_act(Vtop___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

void Vtop___024root___nba_sequent__TOP__0(Vtop___024root* vlSelf);

void Vtop___024root___eval_nba(Vtop___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_nba\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vtop___024root___nba_sequent__TOP__0(vlSelf);
    }
}

VL_INLINE_OPT void Vtop___024root___nba_sequent__TOP__0(Vtop___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___nba_sequent__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VdlySet__RegFile__DOT__regs__v0;
    __VdlySet__RegFile__DOT__regs__v0 = 0;
    IData/*31:0*/ __VdlyVal__RegFile__DOT__regs__v32;
    __VdlyVal__RegFile__DOT__regs__v32 = 0;
    CData/*4:0*/ __VdlyDim0__RegFile__DOT__regs__v32;
    __VdlyDim0__RegFile__DOT__regs__v32 = 0;
    CData/*0:0*/ __VdlySet__RegFile__DOT__regs__v32;
    __VdlySet__RegFile__DOT__regs__v32 = 0;
    // Body
    __VdlySet__RegFile__DOT__regs__v0 = 0U;
    __VdlySet__RegFile__DOT__regs__v32 = 0U;
    if (vlSelfRef.rst) {
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 1U;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 2U;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 3U;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 4U;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 5U;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 6U;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 7U;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 8U;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 9U;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0xaU;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0xbU;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0xcU;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0xdU;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0xeU;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0xfU;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0x10U;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0x11U;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0x12U;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0x13U;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0x14U;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0x15U;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0x16U;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0x17U;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0x18U;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0x19U;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0x1aU;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0x1bU;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0x1cU;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0x1dU;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0x1eU;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0x1fU;
        vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i = 0x20U;
        __VdlySet__RegFile__DOT__regs__v0 = 1U;
    } else if (((IData)(vlSelfRef.we) & (0U != (IData)(vlSelfRef.rd)))) {
        __VdlyVal__RegFile__DOT__regs__v32 = vlSelfRef.rd_data;
        __VdlyDim0__RegFile__DOT__regs__v32 = vlSelfRef.rd;
        __VdlySet__RegFile__DOT__regs__v32 = 1U;
    }
    if (__VdlySet__RegFile__DOT__regs__v0) {
        vlSelfRef.RegFile__DOT__regs[0U] = 0U;
        vlSelfRef.RegFile__DOT__regs[1U] = 0U;
        vlSelfRef.RegFile__DOT__regs[2U] = 0U;
        vlSelfRef.RegFile__DOT__regs[3U] = 0U;
        vlSelfRef.RegFile__DOT__regs[4U] = 0U;
        vlSelfRef.RegFile__DOT__regs[5U] = 0U;
        vlSelfRef.RegFile__DOT__regs[6U] = 0U;
        vlSelfRef.RegFile__DOT__regs[7U] = 0U;
        vlSelfRef.RegFile__DOT__regs[8U] = 0U;
        vlSelfRef.RegFile__DOT__regs[9U] = 0U;
        vlSelfRef.RegFile__DOT__regs[0xaU] = 0U;
        vlSelfRef.RegFile__DOT__regs[0xbU] = 0U;
        vlSelfRef.RegFile__DOT__regs[0xcU] = 0U;
        vlSelfRef.RegFile__DOT__regs[0xdU] = 0U;
        vlSelfRef.RegFile__DOT__regs[0xeU] = 0U;
        vlSelfRef.RegFile__DOT__regs[0xfU] = 0U;
        vlSelfRef.RegFile__DOT__regs[0x10U] = 0U;
        vlSelfRef.RegFile__DOT__regs[0x11U] = 0U;
        vlSelfRef.RegFile__DOT__regs[0x12U] = 0U;
        vlSelfRef.RegFile__DOT__regs[0x13U] = 0U;
        vlSelfRef.RegFile__DOT__regs[0x14U] = 0U;
        vlSelfRef.RegFile__DOT__regs[0x15U] = 0U;
        vlSelfRef.RegFile__DOT__regs[0x16U] = 0U;
        vlSelfRef.RegFile__DOT__regs[0x17U] = 0U;
        vlSelfRef.RegFile__DOT__regs[0x18U] = 0U;
        vlSelfRef.RegFile__DOT__regs[0x19U] = 0U;
        vlSelfRef.RegFile__DOT__regs[0x1aU] = 0U;
        vlSelfRef.RegFile__DOT__regs[0x1bU] = 0U;
        vlSelfRef.RegFile__DOT__regs[0x1cU] = 0U;
        vlSelfRef.RegFile__DOT__regs[0x1dU] = 0U;
        vlSelfRef.RegFile__DOT__regs[0x1eU] = 0U;
        vlSelfRef.RegFile__DOT__regs[0x1fU] = 0U;
    }
    if (__VdlySet__RegFile__DOT__regs__v32) {
        vlSelfRef.RegFile__DOT__regs[__VdlyDim0__RegFile__DOT__regs__v32] 
            = __VdlyVal__RegFile__DOT__regs__v32;
    }
    vlSelfRef.RegFile__DOT__rs1_data = ((0U == (IData)(vlSelfRef.rs1))
                                         ? 0U : vlSelfRef.RegFile__DOT__regs
                                        [vlSelfRef.rs1]);
    vlSelfRef.RegFile__DOT__rs2_data = ((0U == (IData)(vlSelfRef.rs2))
                                         ? 0U : vlSelfRef.RegFile__DOT__regs
                                        [vlSelfRef.rs2]);
    vlSelfRef.rs1_data = vlSelfRef.RegFile__DOT__rs1_data;
    vlSelfRef.rs2_data = vlSelfRef.RegFile__DOT__rs2_data;
}

void Vtop___024root___eval_triggers__act(Vtop___024root* vlSelf);

bool Vtop___024root___eval_phase__act(Vtop___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_phase__act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    VlTriggerVec<1> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    Vtop___024root___eval_triggers__act(vlSelf);
    __VactExecute = vlSelfRef.__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelfRef.__VactTriggered, vlSelfRef.__VnbaTriggered);
        vlSelfRef.__VnbaTriggered.thisOr(vlSelfRef.__VactTriggered);
        Vtop___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Vtop___024root___eval_phase__nba(Vtop___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_phase__nba\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelfRef.__VnbaTriggered.any();
    if (__VnbaExecute) {
        Vtop___024root___eval_nba(vlSelf);
        vlSelfRef.__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__ico(Vtop___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__nba(Vtop___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__act(Vtop___024root* vlSelf);
#endif  // VL_DEBUG

void Vtop___024root___eval(Vtop___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ __VicoIterCount;
    CData/*0:0*/ __VicoContinue;
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    __VicoIterCount = 0U;
    vlSelfRef.__VicoFirstIteration = 1U;
    __VicoContinue = 1U;
    while (__VicoContinue) {
        if (VL_UNLIKELY((0x64U < __VicoIterCount))) {
#ifdef VL_DEBUG
            Vtop___024root___dump_triggers__ico(vlSelf);
#endif
            VL_FATAL_MT("/workspaces/cis5710-homework/hw3-singlecycle/DatapathSingleCycle.sv", 16, "", "Input combinational region did not converge.");
        }
        __VicoIterCount = ((IData)(1U) + __VicoIterCount);
        __VicoContinue = 0U;
        if (Vtop___024root___eval_phase__ico(vlSelf)) {
            __VicoContinue = 1U;
        }
        vlSelfRef.__VicoFirstIteration = 0U;
    }
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        if (VL_UNLIKELY((0x64U < __VnbaIterCount))) {
#ifdef VL_DEBUG
            Vtop___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("/workspaces/cis5710-homework/hw3-singlecycle/DatapathSingleCycle.sv", 16, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelfRef.__VactIterCount = 0U;
        vlSelfRef.__VactContinue = 1U;
        while (vlSelfRef.__VactContinue) {
            if (VL_UNLIKELY((0x64U < vlSelfRef.__VactIterCount))) {
#ifdef VL_DEBUG
                Vtop___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("/workspaces/cis5710-homework/hw3-singlecycle/DatapathSingleCycle.sv", 16, "", "Active region did not converge.");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
            vlSelfRef.__VactContinue = 0U;
            if (Vtop___024root___eval_phase__act(vlSelf)) {
                vlSelfRef.__VactContinue = 1U;
            }
        }
        if (Vtop___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void Vtop___024root___eval_debug_assertions(Vtop___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_debug_assertions\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (VL_UNLIKELY((vlSelfRef.rd & 0xe0U))) {
        Verilated::overWidthError("rd");}
    if (VL_UNLIKELY((vlSelfRef.rs1 & 0xe0U))) {
        Verilated::overWidthError("rs1");}
    if (VL_UNLIKELY((vlSelfRef.rs2 & 0xe0U))) {
        Verilated::overWidthError("rs2");}
    if (VL_UNLIKELY((vlSelfRef.clk & 0xfeU))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY((vlSelfRef.we & 0xfeU))) {
        Verilated::overWidthError("we");}
    if (VL_UNLIKELY((vlSelfRef.rst & 0xfeU))) {
        Verilated::overWidthError("rst");}
}
#endif  // VL_DEBUG
