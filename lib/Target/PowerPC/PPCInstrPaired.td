//===-- PPCInstrPaired.td - The PowerPC Paired-Single Ext. -*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file describes the Paired-Single extension to the PowerPC instruction
// set.
//
//===----------------------------------------------------------------------===//

class PSForm_xo5<bits<5> xo, dag OOL, dag IOL, string asmstr, InstrItinClass itin> : I<4, OOL, IOL, asmstr, itin> {
  let Inst{26-30} = xo;
}

class PSForm_xo6<bits<6> xo, dag OOL, dag IOL, string asmstr, InstrItinClass itin> : I<4, OOL, IOL, asmstr, itin> {
  let Inst{25-30} = xo;
}

class PSForm_xo10<bits<10> xo, dag OOL, dag IOL, string asmstr, InstrItinClass itin> : I<4, OOL, IOL, asmstr, itin> {
  let Inst{21-30} = xo;
}

class PSQForm_d<bits<6> xo, dag OOL, dag IOL, string asmstr, InstrItinClass itin> : PSForm_xo6<xo, OOL, IOL, asmstr, itin> {
  bits<5> D;
  bits<5> A;
  bits<5> B;
  bits<1> W;
  bits<3> I;

  let Inst{6-10}  = D;
  let Inst{11-15} = A;
  let Inst{16-20} = B;
  let Inst{21}    = W;
  let Inst{22-24} = I;
  let Inst{31}    = 0;
}

class PSQForm_s<bits<6> xo, dag OOL, dag IOL, string asmstr, InstrItinClass itin> : PSForm_xo6<xo, OOL, IOL, asmstr, itin> {
  bits<5> S;
  bits<5> A;
  bits<5> B;
  bits<1> W;
  bits<3> I;

  let Inst{6-10}  = S;
  let Inst{11-15} = A;
  let Inst{16-20} = B;
  let Inst{21}    = W;
  let Inst{22-24} = I;
  let Inst{31}    = 0;
}

class PSForm_d0b0<bits<5> xo, dag OOL, dag IOL, string asmstr, InstrItinClass itin> : PSForm_xo5<xo, OOL, IOL, asmstr, itin> {
  bits<5> D;
  bits<5> B;

  let Inst{6-10}  = D;
  let Inst{11-15} = 0;
  let Inst{16-20} = B;
  let Inst{21-25} = 0;
}

class PSForm_dab0<bits<5> xo, dag OOL, dag IOL, string asmstr, InstrItinClass itin> : PSForm_xo5<xo, OOL, IOL, asmstr, itin> {
  bits<5> D;
  bits<5> A;
  bits<5> B;

  let Inst{6-10}  = D;
  let Inst{11-15} = A;
  let Inst{16-20} = B;
  let Inst{21-25} = 0;
}

class PSForm_d0bx<bits<10> xo, dag OOL, dag IOL, string asmstr, InstrItinClass itin> : PSForm_xo10<xo, OOL, IOL, asmstr, itin> {
  bits<5> D;
  bits<5> B;

  let Inst{6-10}  = D;
  let Inst{11-15} = 0;
  let Inst{16-20} = B;
}

class PSForm_da0c<bits<5> xo, dag OOL, dag IOL, string asmstr, InstrItinClass itin> : PSForm_xo5<xo, OOL, IOL, asmstr, itin> {
  bits<5> D;
  bits<5> A;
  bits<5> C;

  let Inst{6-10}  = D;
  let Inst{11-15} = A;
  let Inst{16-20} = 0;
  let Inst{21-25} = C;
}

class PSForm_dabx<bits<10> xo, dag OOL, dag IOL, string asmstr, InstrItinClass itin> : PSForm_xo10<xo, OOL, IOL, asmstr, itin> {
  bits<5> D;
  bits<5> A;
  bits<5> B;

  let Inst{6-10}  = D;
  let Inst{11-15} = A;
  let Inst{16-20} = B;
}

class PSForm_4<bits<5> xo, dag OOL, dag IOL, string asmstr, InstrItinClass itin> : PSForm_xo5<xo, OOL, IOL, asmstr, itin> {
  bits<5> D;
  bits<5> A;
  bits<5> B;
  bits<5> C;

  let Inst{6-10}  = D;
  let Inst{11-15} = A;
  let Inst{16-20} = B;
  let Inst{21-25} = C;
}

class PSForm_d0abx<bits<10> xo, dag OOL, dag IOL, string asmstr, InstrItinClass itin> : PSForm_xo10<xo, OOL, IOL, asmstr, itin> {
  bits<3> crfD;
  bits<5> A;
  bits<5> B;

  let Inst{6-8}   = crfD;
  let Inst{9-10}  = 0;
  let Inst{11-15} = A;
  let Inst{16-20} = B;
}

def HasPaired : Predicate<"PPCSubTarget.hasPaired()">;
let Predicates = [HasPaired] in {

def PSQ_LX     : PSQForm_d<6,  (outs f4rc:$frD), (ins gprc:$rA, gprc:$rB, u1imm:$W, u3imm:$I), "psq_lx $frD, $rA, $rB, $W, $I", NoItinerary>;
def PSQ_LUX    : PSQForm_d<38, (outs f4rc:$frD), (ins gprc:$rA, gprc:$rB, u1imm:$W, u3imm:$I), "psq_lux $frD, $rA, $rB, $W, $I", NoItinerary>;
def PSQ_STX    : PSQForm_s<7,  (outs), (ins f4rc:$frS, gprc:$rA, gprc:$rB, u1imm:$W, u3imm:$I), "psq_stx $frS, $rA, $rB, $W, $I", NoItinerary>;
def PSQ_STUX   : PSQForm_s<39, (outs), (ins f4rc:$frS, gprc:$rA, gprc:$rB, u1imm:$W, u3imm:$I), "psq_stux $frS, $rA, $rB, $W, $I", NoItinerary>;

def PS_RES     : PSForm_d0b0<24,  (outs f4rc:$frD), (ins f4rc:$frB), "ps_res $frD, $frB", NoItinerary>;
def PS_RSQRTE  : PSForm_d0b0<26,  (outs f4rc:$frD), (ins f4rc:$frB), "ps_rsqrte $frD, $frB", NoItinerary>;
def PS_NEG     : PSForm_d0bx<40,  (outs f4rc:$frD), (ins f4rc:$frB), "ps_neg $frD, $frB", NoItinerary>;
def PS_MR      : PSForm_d0bx<72,  (outs f4rc:$frD), (ins f4rc:$frB), "ps_mr $frD, $frB", NoItinerary>;
def PS_NABS    : PSForm_d0bx<136, (outs f4rc:$frD), (ins f4rc:$frB), "ps_nabs $frD, $frB", NoItinerary>;
def PS_ABS     : PSForm_d0bx<264, (outs f4rc:$frD), (ins f4rc:$frB), "ps_abs $frD, $frB", NoItinerary>;

def PS_DIV     : PSForm_dab0<18, (outs f4rc:$frD), (ins f4rc:$frA, f4rc:$frB), "ps_div $frD, $frA, $frB", NoItinerary>;
def PS_SUB     : PSForm_dab0<20, (outs f4rc:$frD), (ins f4rc:$frA, f4rc:$frB), "ps_sub $frD, $frA, $frB", NoItinerary>;
def PS_ADD     : PSForm_dab0<21, (outs f4rc:$frD), (ins f4rc:$frA, f4rc:$frB), "ps_add $frD, $frA, $frB", NoItinerary>;

def PS_MERGE00 : PSForm_dabx<528, (outs f4rc:$frD), (ins f4rc:$frA, f4rc:$frB), "ps_merge00 $frD, $frA, $frB", NoItinerary>;
def PS_MERGE01 : PSForm_dabx<560, (outs f4rc:$frD), (ins f4rc:$frA, f4rc:$frB), "ps_merge01 $frD, $frA, $frB", NoItinerary>;
def PS_MERGE10 : PSForm_dabx<592, (outs f4rc:$frD), (ins f4rc:$frA, f4rc:$frB), "ps_merge10 $frD, $frA, $frB", NoItinerary>;
def PS_MERGE11 : PSForm_dabx<624, (outs f4rc:$frD), (ins f4rc:$frA, f4rc:$frB), "ps_merge11 $frD, $frA, $frB", NoItinerary>;

def PS_MULS0   : PSForm_da0c<12, (outs f4rc:$frD), (ins f4rc:$frA, f4rc:$frC), "ps_muls0 $frD, $frA, $frC", NoItinerary>;
def PS_MULS1   : PSForm_da0c<13, (outs f4rc:$frD), (ins f4rc:$frA, f4rc:$frC), "ps_muls1 $frD, $frA, $frC", NoItinerary>;
def PS_MUL     : PSForm_da0c<25, (outs f4rc:$frD), (ins f4rc:$frA, f4rc:$frC), "ps_mul $frD, $frA, $frC", NoItinerary>;

def PS_CMPU0   : PSForm_d0abx<0,  (outs crrc:$crfD), (ins f4rc:$frA, f4rc:$frB), "ps_cmpu0 $crfD, $frA, $frB", NoItinerary>;
def PS_CMPO0   : PSForm_d0abx<32, (outs crrc:$crfD), (ins f4rc:$frA, f4rc:$frB), "ps_cmpo0 $crfD, $frA, $frB", NoItinerary>;
def PS_CMPU1   : PSForm_d0abx<64, (outs crrc:$crfD), (ins f4rc:$frA, f4rc:$frB), "ps_cmpu1 $crfD, $frA, $frB", NoItinerary>;
def PS_CMPO1   : PSForm_d0abx<96, (outs crrc:$crfD), (ins f4rc:$frA, f4rc:$frB), "ps_cmpo1 $crfD, $frA, $frB", NoItinerary>;

def PS_SUM0    : PSForm_4<10, (outs f4rc:$frD), (ins f4rc:$frA, f4rc:$frB, f4rc:$frC), "ps_sum0 $frD, $frA, $frC, $frB", NoItinerary>;
def PS_SUM1    : PSForm_4<11, (outs f4rc:$frD), (ins f4rc:$frA, f4rc:$frB, f4rc:$frC), "ps_sum1 $frD, $frA, $frC, $frB", NoItinerary>;
def PS_MADDS0  : PSForm_4<14, (outs f4rc:$frD), (ins f4rc:$frA, f4rc:$frB, f4rc:$frC), "ps_madds0 $frD, $frA, $frC, $frB", NoItinerary>;
def PS_MADDS1  : PSForm_4<15, (outs f4rc:$frD), (ins f4rc:$frA, f4rc:$frB, f4rc:$frC), "ps_madds1 $frD, $frA, $frC, $frB", NoItinerary>;
def PS_SEL     : PSForm_4<23, (outs f4rc:$frD), (ins f4rc:$frA, f4rc:$frB, f4rc:$frC), "ps_sel $frD, $frA, $frC, $frB", NoItinerary>;
def PS_MSUB    : PSForm_4<28, (outs f4rc:$frD), (ins f4rc:$frA, f4rc:$frB, f4rc:$frC), "ps_msub $frD, $frA, $frC, $frB", NoItinerary>;
def PS_MADD    : PSForm_4<29, (outs f4rc:$frD), (ins f4rc:$frA, f4rc:$frB, f4rc:$frC), "ps_madd $frD, $frA, $frC, $frB", NoItinerary>;
def PS_MNSUB   : PSForm_4<30, (outs f4rc:$frD), (ins f4rc:$frA, f4rc:$frB, f4rc:$frC), "ps_nmsub $frD, $frA, $frC, $frB", NoItinerary>;
def PS_MNADD   : PSForm_4<31, (outs f4rc:$frD), (ins f4rc:$frA, f4rc:$frB, f4rc:$frC), "ps_nmadd $frD, $frA, $frC, $frB", NoItinerary>;

} // HasPaired
