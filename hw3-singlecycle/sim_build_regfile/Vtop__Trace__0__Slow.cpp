// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_fst_c.h"
#include "Vtop__Syms.h"


VL_ATTR_COLD void Vtop___024root__trace_init_sub__TOP__0(Vtop___024root* vlSelf, VerilatedFst* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_init_sub__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->declBus(c+1,0,"rd",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+2,0,"rd_data",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+3,0,"rs1",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+4,0,"rs1_data",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+5,0,"rs2",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+6,0,"rs2_data",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+7,0,"clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+8,0,"we",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+9,0,"rst",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("RegFile", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+10,0,"rd",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+11,0,"rd_data",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+12,0,"rs1",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+13,0,"rs1_data",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+14,0,"rs2",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+15,0,"rs2_data",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+16,0,"clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+17,0,"we",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+18,0,"rst",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+52,0,"NumRegs",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INT, false,-1, 31,0);
    tracep->pushPrefix("regs", VerilatedTracePrefixType::ARRAY_UNPACKED);
    for (int i = 0; i < 32; ++i) {
        tracep->declBus(c+19+i*1,0,"",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, true,(i+0), 31,0);
    }
    tracep->popPrefix();
    tracep->pushPrefix("unnamedblk1", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+51,0,"i",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::INTEGER, false,-1, 31,0);
    tracep->popPrefix();
    tracep->popPrefix();
}

VL_ATTR_COLD void Vtop___024root__trace_init_top(Vtop___024root* vlSelf, VerilatedFst* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_init_top\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtop___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void Vtop___024root__trace_const_0(void* voidSelf, VerilatedFst::Buffer* bufp);
VL_ATTR_COLD void Vtop___024root__trace_full_0(void* voidSelf, VerilatedFst::Buffer* bufp);
void Vtop___024root__trace_chg_0(void* voidSelf, VerilatedFst::Buffer* bufp);
void Vtop___024root__trace_cleanup(void* voidSelf, VerilatedFst* /*unused*/);

VL_ATTR_COLD void Vtop___024root__trace_register(Vtop___024root* vlSelf, VerilatedFst* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_register\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    tracep->addConstCb(&Vtop___024root__trace_const_0, 0U, vlSelf);
    tracep->addFullCb(&Vtop___024root__trace_full_0, 0U, vlSelf);
    tracep->addChgCb(&Vtop___024root__trace_chg_0, 0U, vlSelf);
    tracep->addCleanupCb(&Vtop___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void Vtop___024root__trace_const_0_sub_0(Vtop___024root* vlSelf, VerilatedFst::Buffer* bufp);

VL_ATTR_COLD void Vtop___024root__trace_const_0(void* voidSelf, VerilatedFst::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_const_0\n"); );
    // Init
    Vtop___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtop___024root*>(voidSelf);
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Vtop___024root__trace_const_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vtop___024root__trace_const_0_sub_0(Vtop___024root* vlSelf, VerilatedFst::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_const_0_sub_0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullIData(oldp+52,(0x20U),32);
}

VL_ATTR_COLD void Vtop___024root__trace_full_0_sub_0(Vtop___024root* vlSelf, VerilatedFst::Buffer* bufp);

VL_ATTR_COLD void Vtop___024root__trace_full_0(void* voidSelf, VerilatedFst::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_full_0\n"); );
    // Init
    Vtop___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtop___024root*>(voidSelf);
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Vtop___024root__trace_full_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vtop___024root__trace_full_0_sub_0(Vtop___024root* vlSelf, VerilatedFst::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_full_0_sub_0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullCData(oldp+1,(vlSelfRef.rd),5);
    bufp->fullIData(oldp+2,(vlSelfRef.rd_data),32);
    bufp->fullCData(oldp+3,(vlSelfRef.rs1),5);
    bufp->fullIData(oldp+4,(vlSelfRef.rs1_data),32);
    bufp->fullCData(oldp+5,(vlSelfRef.rs2),5);
    bufp->fullIData(oldp+6,(vlSelfRef.rs2_data),32);
    bufp->fullBit(oldp+7,(vlSelfRef.clk));
    bufp->fullBit(oldp+8,(vlSelfRef.we));
    bufp->fullBit(oldp+9,(vlSelfRef.rst));
    bufp->fullCData(oldp+10,(vlSelfRef.RegFile__DOT__rd),5);
    bufp->fullIData(oldp+11,(vlSelfRef.RegFile__DOT__rd_data),32);
    bufp->fullCData(oldp+12,(vlSelfRef.RegFile__DOT__rs1),5);
    bufp->fullIData(oldp+13,(vlSelfRef.RegFile__DOT__rs1_data),32);
    bufp->fullCData(oldp+14,(vlSelfRef.RegFile__DOT__rs2),5);
    bufp->fullIData(oldp+15,(vlSelfRef.RegFile__DOT__rs2_data),32);
    bufp->fullBit(oldp+16,(vlSelfRef.RegFile__DOT__clk));
    bufp->fullBit(oldp+17,(vlSelfRef.RegFile__DOT__we));
    bufp->fullBit(oldp+18,(vlSelfRef.RegFile__DOT__rst));
    bufp->fullIData(oldp+19,(vlSelfRef.RegFile__DOT__regs[0]),32);
    bufp->fullIData(oldp+20,(vlSelfRef.RegFile__DOT__regs[1]),32);
    bufp->fullIData(oldp+21,(vlSelfRef.RegFile__DOT__regs[2]),32);
    bufp->fullIData(oldp+22,(vlSelfRef.RegFile__DOT__regs[3]),32);
    bufp->fullIData(oldp+23,(vlSelfRef.RegFile__DOT__regs[4]),32);
    bufp->fullIData(oldp+24,(vlSelfRef.RegFile__DOT__regs[5]),32);
    bufp->fullIData(oldp+25,(vlSelfRef.RegFile__DOT__regs[6]),32);
    bufp->fullIData(oldp+26,(vlSelfRef.RegFile__DOT__regs[7]),32);
    bufp->fullIData(oldp+27,(vlSelfRef.RegFile__DOT__regs[8]),32);
    bufp->fullIData(oldp+28,(vlSelfRef.RegFile__DOT__regs[9]),32);
    bufp->fullIData(oldp+29,(vlSelfRef.RegFile__DOT__regs[10]),32);
    bufp->fullIData(oldp+30,(vlSelfRef.RegFile__DOT__regs[11]),32);
    bufp->fullIData(oldp+31,(vlSelfRef.RegFile__DOT__regs[12]),32);
    bufp->fullIData(oldp+32,(vlSelfRef.RegFile__DOT__regs[13]),32);
    bufp->fullIData(oldp+33,(vlSelfRef.RegFile__DOT__regs[14]),32);
    bufp->fullIData(oldp+34,(vlSelfRef.RegFile__DOT__regs[15]),32);
    bufp->fullIData(oldp+35,(vlSelfRef.RegFile__DOT__regs[16]),32);
    bufp->fullIData(oldp+36,(vlSelfRef.RegFile__DOT__regs[17]),32);
    bufp->fullIData(oldp+37,(vlSelfRef.RegFile__DOT__regs[18]),32);
    bufp->fullIData(oldp+38,(vlSelfRef.RegFile__DOT__regs[19]),32);
    bufp->fullIData(oldp+39,(vlSelfRef.RegFile__DOT__regs[20]),32);
    bufp->fullIData(oldp+40,(vlSelfRef.RegFile__DOT__regs[21]),32);
    bufp->fullIData(oldp+41,(vlSelfRef.RegFile__DOT__regs[22]),32);
    bufp->fullIData(oldp+42,(vlSelfRef.RegFile__DOT__regs[23]),32);
    bufp->fullIData(oldp+43,(vlSelfRef.RegFile__DOT__regs[24]),32);
    bufp->fullIData(oldp+44,(vlSelfRef.RegFile__DOT__regs[25]),32);
    bufp->fullIData(oldp+45,(vlSelfRef.RegFile__DOT__regs[26]),32);
    bufp->fullIData(oldp+46,(vlSelfRef.RegFile__DOT__regs[27]),32);
    bufp->fullIData(oldp+47,(vlSelfRef.RegFile__DOT__regs[28]),32);
    bufp->fullIData(oldp+48,(vlSelfRef.RegFile__DOT__regs[29]),32);
    bufp->fullIData(oldp+49,(vlSelfRef.RegFile__DOT__regs[30]),32);
    bufp->fullIData(oldp+50,(vlSelfRef.RegFile__DOT__regs[31]),32);
    bufp->fullIData(oldp+51,(vlSelfRef.RegFile__DOT__unnamedblk1__DOT__i),32);
}
