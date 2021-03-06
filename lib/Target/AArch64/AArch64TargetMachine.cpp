//===-- AArch64TargetMachine.cpp - Define TargetMachine for AArch64 -------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the implementation of the AArch64TargetMachine
// methods. Principally just setting up the passes needed to generate correct
// code on this architecture.
//
//===----------------------------------------------------------------------===//

#include "AArch64.h"
#include "AArch64TargetMachine.h"
#include "MCTargetDesc/AArch64MCTargetDesc.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/PassManager.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Transforms/Scalar.h"

using namespace llvm;

extern "C" void LLVMInitializeAArch64Target() {
  RegisterTargetMachine<AArch64leTargetMachine> X(TheAArch64leTarget);
  RegisterTargetMachine<AArch64beTargetMachine> Y(TheAArch64beTarget);
}

AArch64TargetMachine::AArch64TargetMachine(const Target &T, StringRef TT,
                                           StringRef CPU, StringRef FS,
                                           const TargetOptions &Options,
                                           Reloc::Model RM, CodeModel::Model CM,
                                           CodeGenOpt::Level OL,
                                           bool LittleEndian)
  : LLVMTargetMachine(T, TT, CPU, FS, Options, RM, CM, OL),
    Subtarget(TT, CPU, FS, LittleEndian),
    InstrInfo(Subtarget),
    DL(LittleEndian ?
       "e-m:e-i64:64-i128:128-n32:64-S128" :
       "E-m:e-i64:64-i128:128-n32:64-S128"),
    TLInfo(*this),
    TSInfo(*this),
    FrameLowering(Subtarget) {
  initAsmInfo();
}

void AArch64leTargetMachine::anchor() { }

AArch64leTargetMachine::
AArch64leTargetMachine(const Target &T, StringRef TT,
                       StringRef CPU, StringRef FS, const TargetOptions &Options,
                       Reloc::Model RM, CodeModel::Model CM,
                       CodeGenOpt::Level OL)
  : AArch64TargetMachine(T, TT, CPU, FS, Options, RM, CM, OL, true) {}

void AArch64beTargetMachine::anchor() { }

AArch64beTargetMachine::
AArch64beTargetMachine(const Target &T, StringRef TT,
                       StringRef CPU, StringRef FS, const TargetOptions &Options,
                       Reloc::Model RM, CodeModel::Model CM,
                       CodeGenOpt::Level OL)
  : AArch64TargetMachine(T, TT, CPU, FS, Options, RM, CM, OL, false) {}

void AArch64TargetMachine::addAnalysisPasses(PassManagerBase &PM) {
  // Add first the target-independent BasicTTI pass, then our AArch64 pass. This
  // allows the AArch64 pass to delegate to the target independent layer when
  // appropriate.
  PM.add(createBasicTargetTransformInfoPass(this));
  PM.add(createAArch64TargetTransformInfoPass(this));
}

namespace {
/// AArch64 Code Generator Pass Configuration Options.
class AArch64PassConfig : public TargetPassConfig {
public:
  AArch64PassConfig(AArch64TargetMachine *TM, PassManagerBase &PM)
    : TargetPassConfig(TM, PM) {}

  AArch64TargetMachine &getAArch64TargetMachine() const {
    return getTM<AArch64TargetMachine>();
  }

  const AArch64Subtarget &getAArch64Subtarget() const {
    return *getAArch64TargetMachine().getSubtargetImpl();
  }

  bool addPreISel() override;
  virtual bool addInstSelector();
  virtual bool addPreEmitPass();
};
} // namespace

bool AArch64PassConfig::addPreISel() {
  if (TM->getOptLevel() != CodeGenOpt::None)
    addPass(createGlobalMergePass(TM));

  return false;
}

TargetPassConfig *AArch64TargetMachine::createPassConfig(PassManagerBase &PM) {
  return new AArch64PassConfig(this, PM);
}

bool AArch64PassConfig::addPreEmitPass() {
  addPass(&UnpackMachineBundlesID);
  addPass(createAArch64BranchFixupPass());
  return true;
}

bool AArch64PassConfig::addInstSelector() {
  addPass(createAArch64ISelDAG(getAArch64TargetMachine(), getOptLevel()));

  // For ELF, cleanup any local-dynamic TLS accesses.
  if (getAArch64Subtarget().isTargetELF() && getOptLevel() != CodeGenOpt::None)
    addPass(createAArch64CleanupLocalDynamicTLSPass());

  return false;
}
