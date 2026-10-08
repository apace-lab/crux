; ModuleID = 'complex.5787706881bbd3ee-cgu.0'
source_filename = "complex.5787706881bbd3ee-cgu.0"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx11.0.0"

%"core::fmt::rt::Argument<'_>" = type { %"core::fmt::rt::ArgumentType<'_>" }
%"core::fmt::rt::ArgumentType<'_>" = type { ptr, [1 x i64] }

@vtable.0 = private constant <{ [24 x i8], ptr, ptr, ptr }> <{ [24 x i8] c"\00\00\00\00\00\00\00\00\08\00\00\00\00\00\00\00\08\00\00\00\00\00\00\00", ptr @"_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17hf56b569549e9f832E", ptr @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h3f5d7f0eec85a035E", ptr @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h3f5d7f0eec85a035E" }>, align 8, !dbg !0
@0 = private unnamed_addr constant <{ [8 x i8], [8 x i8] }> <{ [8 x i8] zeroinitializer, [8 x i8] undef }>, align 8
@alloc_bff842021503b72610001d59b7750fc4 = private unnamed_addr constant <{ [10 x i8] }> <{ [10 x i8] c"complex.rs" }>, align 1
@alloc_17b2ef7f54ff32450a3a1b883ec8277f = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_bff842021503b72610001d59b7750fc4, [16 x i8] c"\0A\00\00\00\00\00\00\00\0C\00\00\00.\00\00\00" }>, align 8
@alloc_ba413b28931a21e86de0800d02475b9a = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_bff842021503b72610001d59b7750fc4, [16 x i8] c"\0A\00\00\00\00\00\00\00\11\00\00\000\00\00\00" }>, align 8
@alloc_3356c9023213d948f65e0e06b84a9e96 = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_bff842021503b72610001d59b7750fc4, [16 x i8] c"\0A\00\00\00\00\00\00\00\16\00\00\00)\00\00\00" }>, align 8
@alloc_cbfe328adbdac12b53d34418bfcee063 = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_bff842021503b72610001d59b7750fc4, [16 x i8] c"\0A\00\00\00\00\00\00\00\1C\00\00\00)\00\00\00" }>, align 8
@alloc_ab2f1013ea6b18eaad8d1ba8c124ed78 = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_bff842021503b72610001d59b7750fc4, [16 x i8] c"\0A\00\00\00\00\00\00\00&\00\00\00.\00\00\00" }>, align 8
@_ZN7complex2VT17h8693aa46dd739d92E = internal constant <{ ptr, ptr, ptr, ptr }> <{ ptr @_ZN7complex7clone_w17hdda8073de8df6721E, ptr @_ZN7complex4noop17h9534ba82ba052afdE, ptr @_ZN7complex4noop17h9534ba82ba052afdE, ptr @_ZN7complex4noop17h9534ba82ba052afdE }>, align 8, !dbg !24
@alloc_49a1e817e911805af64bbc7efb390101 = private unnamed_addr constant <{ [1 x i8] }> <{ [1 x i8] c"\0A" }>, align 1
@alloc_9771be2481f51be410bd2ac520d18601 = private unnamed_addr constant <{ ptr, [8 x i8], ptr, [8 x i8] }> <{ ptr inttoptr (i64 1 to ptr), [8 x i8] zeroinitializer, ptr @alloc_49a1e817e911805af64bbc7efb390101, [8 x i8] c"\01\00\00\00\00\00\00\00" }>, align 8

; std::rt::lang_start
; Function Attrs: uwtable
define hidden i64 @_ZN3std2rt10lang_start17hfbc1424e326a51c8E(ptr %main, i64 %argc, ptr %argv, i8 %sigpipe) unnamed_addr #0 !dbg !68 {
start:
  %sigpipe.dbg.spill = alloca [1 x i8], align 1
  %argv.dbg.spill = alloca [8 x i8], align 8
  %argc.dbg.spill = alloca [8 x i8], align 8
  %main.dbg.spill = alloca [8 x i8], align 8
  %_7 = alloca [8 x i8], align 8
  store ptr %main, ptr %main.dbg.spill, align 8
    #dbg_declare(ptr %main.dbg.spill, !76, !DIExpression(), !82)
  store i64 %argc, ptr %argc.dbg.spill, align 8
    #dbg_declare(ptr %argc.dbg.spill, !77, !DIExpression(), !83)
  store ptr %argv, ptr %argv.dbg.spill, align 8
    #dbg_declare(ptr %argv.dbg.spill, !78, !DIExpression(), !84)
  store i8 %sigpipe, ptr %sigpipe.dbg.spill, align 1
    #dbg_declare(ptr %sigpipe.dbg.spill, !79, !DIExpression(), !85)
  store ptr %main, ptr %_7, align 8, !dbg !86
; call std::rt::lang_start_internal
  %_0 = call i64 @_ZN3std2rt19lang_start_internal17h95cf27b851151b9cE(ptr align 1 %_7, ptr align 8 @vtable.0, i64 %argc, ptr %argv, i8 %sigpipe), !dbg !87
  ret i64 %_0, !dbg !88
}

; std::rt::lang_start::{{closure}}
; Function Attrs: inlinehint uwtable
define internal i32 @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h3f5d7f0eec85a035E"(ptr align 8 %_1) unnamed_addr #1 !dbg !89 {
start:
  %self.dbg.spill = alloca [1 x i8], align 1
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !95, !DIExpression(DW_OP_deref), !96)
  %_4 = load ptr, ptr %_1, align 8, !dbg !97
; call std::sys::backtrace::__rust_begin_short_backtrace
  call void @_ZN3std3sys9backtrace28__rust_begin_short_backtrace17h94d90f6d595e5bf6E(ptr %_4), !dbg !98
; call <() as std::process::Termination>::report
  %self = call i8 @"_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17ha2b1f0f1ec0820b7E"(), !dbg !98
  store i8 %self, ptr %self.dbg.spill, align 1, !dbg !98
    #dbg_declare(ptr %self.dbg.spill, !99, !DIExpression(), !118)
  %_0 = zext i8 %self to i32, !dbg !120
  ret i32 %_0, !dbg !128
}

; std::sys::backtrace::__rust_begin_short_backtrace
; Function Attrs: noinline uwtable
define internal void @_ZN3std3sys9backtrace28__rust_begin_short_backtrace17h94d90f6d595e5bf6E(ptr %f) unnamed_addr #2 !dbg !129 {
start:
  %dummy.dbg.spill = alloca [0 x i8], align 1
  %f.dbg.spill = alloca [8 x i8], align 8
  %result.dbg.spill = alloca [0 x i8], align 1
    #dbg_declare(ptr %result.dbg.spill, !136, !DIExpression(), !140)
  store ptr %f, ptr %f.dbg.spill, align 8
    #dbg_declare(ptr %f.dbg.spill, !135, !DIExpression(), !141)
    #dbg_declare(ptr %dummy.dbg.spill, !142, !DIExpression(), !149)
; call core::ops::function::FnOnce::call_once
  call void @_ZN4core3ops8function6FnOnce9call_once17h8bbb0c31bcb96c36E(ptr %f), !dbg !151
  call void asm sideeffect "", "~{memory}"(), !dbg !152, !srcloc !153
  ret void, !dbg !154
}

; core::fmt::rt::Argument::new_display
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3fmt2rt8Argument11new_display17hbbb6afbe72c84d49E(ptr sret([16 x i8]) align 8 %_0, ptr align 8 %x) unnamed_addr #1 !dbg !155 {
start:
  %x.dbg.spill = alloca [8 x i8], align 8
  %_3 = alloca [16 x i8], align 8
  store ptr %x, ptr %x.dbg.spill, align 8
    #dbg_declare(ptr %x.dbg.spill, !264, !DIExpression(), !265)
    #dbg_declare(ptr %x.dbg.spill, !266, !DIExpression(), !275)
    #dbg_declare(ptr %x.dbg.spill, !277, !DIExpression(), !288)
  store ptr %x, ptr %_3, align 8, !dbg !290
  %0 = getelementptr inbounds i8, ptr %_3, i64 8, !dbg !290
  store ptr @"_ZN4core3fmt3num3imp52_$LT$impl$u20$core..fmt..Display$u20$for$u20$u64$GT$3fmt17h339ac4429cb37bf0E", ptr %0, align 8, !dbg !290
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_0, ptr align 8 %_3, i64 16, i1 false), !dbg !291
  ret void, !dbg !292
}

; core::fmt::Arguments::new_v1
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3fmt9Arguments6new_v117h152d81e9b06b0e25E(ptr sret([48 x i8]) align 8 %_0, ptr align 8 %pieces, ptr align 8 %args) unnamed_addr #1 !dbg !293 {
start:
  %args.dbg.spill = alloca [8 x i8], align 8
  %pieces.dbg.spill = alloca [8 x i8], align 8
  store ptr %pieces, ptr %pieces.dbg.spill, align 8
    #dbg_declare(ptr %pieces.dbg.spill, !368, !DIExpression(), !370)
  store ptr %args, ptr %args.dbg.spill, align 8
    #dbg_declare(ptr %args.dbg.spill, !369, !DIExpression(), !371)
  store ptr %pieces, ptr %_0, align 8, !dbg !372
  %0 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !372
  store i64 2, ptr %0, align 8, !dbg !372
  %1 = load ptr, ptr @0, align 8, !dbg !372
  %2 = load i64, ptr getelementptr inbounds (i8, ptr @0, i64 8), align 8, !dbg !372
  %3 = getelementptr inbounds i8, ptr %_0, i64 32, !dbg !372
  store ptr %1, ptr %3, align 8, !dbg !372
  %4 = getelementptr inbounds i8, ptr %3, i64 8, !dbg !372
  store i64 %2, ptr %4, align 8, !dbg !372
  %5 = getelementptr inbounds i8, ptr %_0, i64 16, !dbg !372
  store ptr %args, ptr %5, align 8, !dbg !372
  %6 = getelementptr inbounds i8, ptr %5, i64 8, !dbg !372
  store i64 1, ptr %6, align 8, !dbg !372
  ret void, !dbg !373
}

; core::ops::function::FnOnce::call_once{{vtable.shim}}
; Function Attrs: inlinehint uwtable
define internal i32 @"_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17hf56b569549e9f832E"(ptr %_1) unnamed_addr #1 !dbg !374 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  %_2 = alloca [0 x i8], align 1
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !383, !DIExpression(), !388)
    #dbg_declare(ptr %_2, !384, !DIExpression(), !388)
  %0 = load ptr, ptr %_1, align 8, !dbg !388
; call core::ops::function::FnOnce::call_once
  %_0 = call i32 @_ZN4core3ops8function6FnOnce9call_once17he45845dfc4b46fd1E(ptr %0), !dbg !388
  ret i32 %_0, !dbg !388
}

; core::ops::function::FnOnce::call_once
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3ops8function6FnOnce9call_once17h8bbb0c31bcb96c36E(ptr %_1) unnamed_addr #1 !dbg !389 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  %_2 = alloca [0 x i8], align 1
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !391, !DIExpression(), !395)
    #dbg_declare(ptr %_2, !392, !DIExpression(), !395)
  call void %_1(), !dbg !395
  ret void, !dbg !395
}

; core::ops::function::FnOnce::call_once
; Function Attrs: inlinehint uwtable
define internal i32 @_ZN4core3ops8function6FnOnce9call_once17he45845dfc4b46fd1E(ptr %0) unnamed_addr #1 personality ptr @rust_eh_personality !dbg !396 {
start:
  %1 = alloca [16 x i8], align 8
  %_2 = alloca [0 x i8], align 1
  %_1 = alloca [8 x i8], align 8
  store ptr %0, ptr %_1, align 8
    #dbg_declare(ptr %_1, !400, !DIExpression(), !402)
    #dbg_declare(ptr %_2, !401, !DIExpression(), !402)
; invoke std::rt::lang_start::{{closure}}
  %_0 = invoke i32 @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h3f5d7f0eec85a035E"(ptr align 8 %_1)
          to label %bb1 unwind label %cleanup, !dbg !402

bb3:                                              ; preds = %cleanup
  %2 = load ptr, ptr %1, align 8, !dbg !402
  %3 = getelementptr inbounds i8, ptr %1, i64 8, !dbg !402
  %4 = load i32, ptr %3, align 8, !dbg !402
  %5 = insertvalue { ptr, i32 } poison, ptr %2, 0, !dbg !402
  %6 = insertvalue { ptr, i32 } %5, i32 %4, 1, !dbg !402
  resume { ptr, i32 } %6, !dbg !402

cleanup:                                          ; preds = %start
  %7 = landingpad { ptr, i32 }
          cleanup
  %8 = extractvalue { ptr, i32 } %7, 0
  %9 = extractvalue { ptr, i32 } %7, 1
  store ptr %8, ptr %1, align 8
  %10 = getelementptr inbounds i8, ptr %1, i64 8
  store i32 %9, ptr %10, align 8
  br label %bb3

bb1:                                              ; preds = %start
  ret i32 %_0, !dbg !402
}

; core::ptr::drop_in_place<core::task::wake::Waker>
; Function Attrs: uwtable
define internal void @"_ZN4core3ptr44drop_in_place$LT$core..task..wake..Waker$GT$17ha03ee6b39a1c10a5E"(ptr align 8 %_1) unnamed_addr #0 !dbg !403 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !412, !DIExpression(), !415)
; call <core::task::wake::Waker as core::ops::drop::Drop>::drop
  call void @"_ZN65_$LT$core..task..wake..Waker$u20$as$u20$core..ops..drop..Drop$GT$4drop17h4002d96cd0cf52c0E"(ptr align 8 %_1), !dbg !415
  ret void, !dbg !415
}

; core::ptr::drop_in_place<complex::find::{{closure}}>
; Function Attrs: uwtable
define internal void @"_ZN4core3ptr63drop_in_place$LT$complex..find..$u7b$$u7b$closure$u7d$$u7d$$GT$17h300c76df0795e4ffE"(ptr align 8 %_1) unnamed_addr #0 !dbg !416 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !493, !DIExpression(DW_OP_deref), !498)
  %0 = getelementptr inbounds i8, ptr %_1, i64 8, !dbg !499
  %1 = load i8, ptr %0, align 8, !dbg !499
  %_11 = zext i8 %1 to i32, !dbg !499
  %2 = icmp eq i32 %_11, 0, !dbg !499
  br i1 %2, label %bb2, label %bb4, !dbg !499

bb2:                                              ; preds = %start
  ret void, !dbg !499

bb4:                                              ; preds = %start
  ret void, !dbg !499
}

; core::ptr::drop_in_place<complex::to_json::{{closure}}>
; Function Attrs: uwtable
define internal void @"_ZN4core3ptr66drop_in_place$LT$complex..to_json..$u7b$$u7b$closure$u7d$$u7d$$GT$17hcd44afcccc964b77E"(ptr align 8 %_1) unnamed_addr #0 !dbg !500 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !529, !DIExpression(DW_OP_deref), !534)
  %0 = getelementptr inbounds i8, ptr %_1, i64 8, !dbg !535
  %1 = load i8, ptr %0, align 8, !dbg !535
  %_8 = zext i8 %1 to i32, !dbg !535
  %2 = icmp eq i32 %_8, 0, !dbg !535
  br i1 %2, label %bb2, label %bb4, !dbg !535

bb2:                                              ; preds = %start
  ret void, !dbg !535

bb4:                                              ; preds = %start
  ret void, !dbg !535
}

; core::ptr::drop_in_place<complex::get_cipher::{{closure}}>
; Function Attrs: uwtable
define internal void @"_ZN4core3ptr69drop_in_place$LT$complex..get_cipher..$u7b$$u7b$closure$u7d$$u7d$$GT$17h3cb4a8df9c9346ecE"(ptr align 8 %_1) unnamed_addr #0 personality ptr @rust_eh_personality !dbg !536 {
start:
  %0 = alloca [16 x i8], align 8
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !595, !DIExpression(DW_OP_deref), !628)
    #dbg_declare(ptr %_1.dbg.spill, !598, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 8), !629)
    #dbg_declare(ptr %_1.dbg.spill, !600, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 32), !630)
    #dbg_declare(ptr %_1.dbg.spill, !617, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 32), !631)
    #dbg_declare(ptr %_1.dbg.spill, !622, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 32), !632)
  %1 = getelementptr inbounds i8, ptr %_1, i64 24, !dbg !633
  %2 = load i8, ptr %1, align 8, !dbg !633
  %_67 = zext i8 %2 to i32, !dbg !633
  switch i32 %_67, label %bb29 [
    i32 0, label %bb23
    i32 3, label %bb26
    i32 4, label %bb27
    i32 5, label %bb28
  ], !dbg !633

bb29:                                             ; preds = %start
  ret void, !dbg !633

bb23:                                             ; preds = %start
  ret void, !dbg !633

bb26:                                             ; preds = %start
  %3 = getelementptr inbounds i8, ptr %_1, i64 32, !dbg !634
; invoke core::ptr::drop_in_place<complex::find::{{closure}}>
  invoke void @"_ZN4core3ptr63drop_in_place$LT$complex..find..$u7b$$u7b$closure$u7d$$u7d$$GT$17h300c76df0795e4ffE"(ptr align 8 %3)
          to label %bb8 unwind label %cleanup, !dbg !634

bb27:                                             ; preds = %start
  %4 = getelementptr inbounds i8, ptr %_1, i64 32, !dbg !635
; invoke core::ptr::drop_in_place<complex::is_accessible::{{closure}}>
  invoke void @"_ZN4core3ptr72drop_in_place$LT$complex..is_accessible..$u7b$$u7b$closure$u7d$$u7d$$GT$17h063ee76deceb8fb5E"(ptr align 8 %4)
          to label %bb5 unwind label %cleanup1, !dbg !635

bb28:                                             ; preds = %start
  %5 = getelementptr inbounds i8, ptr %_1, i64 32, !dbg !636
; invoke core::ptr::drop_in_place<complex::to_json::{{closure}}>
  invoke void @"_ZN4core3ptr66drop_in_place$LT$complex..to_json..$u7b$$u7b$closure$u7d$$u7d$$GT$17hcd44afcccc964b77E"(ptr align 8 %5)
          to label %bb2 unwind label %cleanup2, !dbg !636

bb18:                                             ; preds = %cleanup
  br label %bb20, !dbg !637

cleanup:                                          ; preds = %bb26
  %6 = landingpad { ptr, i32 }
          cleanup
  %7 = extractvalue { ptr, i32 } %6, 0
  %8 = extractvalue { ptr, i32 } %6, 1
  store ptr %7, ptr %0, align 8
  %9 = getelementptr inbounds i8, ptr %0, i64 8
  store i32 %8, ptr %9, align 8
  br label %bb18

bb8:                                              ; preds = %bb26
  br label %bb10, !dbg !637

bb10:                                             ; preds = %bb5, %bb8
  br label %bb11, !dbg !637

bb20:                                             ; preds = %bb16, %bb18
  br label %bb21, !dbg !637

bb16:                                             ; preds = %cleanup1
  br label %bb20, !dbg !638

cleanup1:                                         ; preds = %bb27
  %10 = landingpad { ptr, i32 }
          cleanup
  %11 = extractvalue { ptr, i32 } %10, 0
  %12 = extractvalue { ptr, i32 } %10, 1
  store ptr %11, ptr %0, align 8
  %13 = getelementptr inbounds i8, ptr %0, i64 8
  store i32 %12, ptr %13, align 8
  br label %bb16

bb5:                                              ; preds = %bb27
  br label %bb10, !dbg !638

bb11:                                             ; preds = %bb2, %bb10
  ret void, !dbg !633

bb21:                                             ; preds = %bb14, %bb20
  %14 = load ptr, ptr %0, align 8, !dbg !633
  %15 = getelementptr inbounds i8, ptr %0, i64 8, !dbg !633
  %16 = load i32, ptr %15, align 8, !dbg !633
  %17 = insertvalue { ptr, i32 } poison, ptr %14, 0, !dbg !633
  %18 = insertvalue { ptr, i32 } %17, i32 %16, 1, !dbg !633
  resume { ptr, i32 } %18, !dbg !633

bb14:                                             ; preds = %cleanup2
  br label %bb21, !dbg !637

cleanup2:                                         ; preds = %bb28
  %19 = landingpad { ptr, i32 }
          cleanup
  %20 = extractvalue { ptr, i32 } %19, 0
  %21 = extractvalue { ptr, i32 } %19, 1
  store ptr %20, ptr %0, align 8
  %22 = getelementptr inbounds i8, ptr %0, i64 8
  store i32 %21, ptr %22, align 8
  br label %bb14

bb2:                                              ; preds = %bb28
  br label %bb11, !dbg !637
}

; core::ptr::drop_in_place<complex::is_accessible::{{closure}}>
; Function Attrs: uwtable
define internal void @"_ZN4core3ptr72drop_in_place$LT$complex..is_accessible..$u7b$$u7b$closure$u7d$$u7d$$GT$17h063ee76deceb8fb5E"(ptr align 8 %_1) unnamed_addr #0 !dbg !639 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !645, !DIExpression(DW_OP_deref), !650)
  %0 = getelementptr inbounds i8, ptr %_1, i64 8, !dbg !651
  %1 = load i8, ptr %0, align 8, !dbg !651
  %_9 = zext i8 %1 to i32, !dbg !651
  %2 = icmp eq i32 %_9, 0, !dbg !651
  br i1 %2, label %bb2, label %bb4, !dbg !651

bb2:                                              ; preds = %start
  ret void, !dbg !651

bb4:                                              ; preds = %start
  ret void, !dbg !651
}

; core::ptr::drop_in_place<complex::get_cipher_leak::{{closure}}>
; Function Attrs: uwtable
define internal void @"_ZN4core3ptr74drop_in_place$LT$complex..get_cipher_leak..$u7b$$u7b$closure$u7d$$u7d$$GT$17h23235722836c3597E"(ptr align 8 %_1) unnamed_addr #0 personality ptr @rust_eh_personality !dbg !652 {
start:
  %0 = alloca [16 x i8], align 8
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !687, !DIExpression(DW_OP_deref), !702)
    #dbg_declare(ptr %_1.dbg.spill, !690, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 16), !703)
    #dbg_declare(ptr %_1.dbg.spill, !692, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 16), !704)
    #dbg_declare(ptr %_1.dbg.spill, !696, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 32), !705)
  %1 = getelementptr inbounds i8, ptr %_1, i64 8, !dbg !706
  %2 = load i8, ptr %1, align 8, !dbg !706
  %_46 = zext i8 %2 to i32, !dbg !706
  switch i32 %_46, label %bb21 [
    i32 0, label %bb16
    i32 3, label %bb19
    i32 4, label %bb20
  ], !dbg !706

bb21:                                             ; preds = %start
  ret void, !dbg !706

bb16:                                             ; preds = %start
  ret void, !dbg !706

bb19:                                             ; preds = %start
  %3 = getelementptr inbounds i8, ptr %_1, i64 16, !dbg !707
; invoke core::ptr::drop_in_place<complex::find::{{closure}}>
  invoke void @"_ZN4core3ptr63drop_in_place$LT$complex..find..$u7b$$u7b$closure$u7d$$u7d$$GT$17h300c76df0795e4ffE"(ptr align 8 %3)
          to label %bb5 unwind label %cleanup, !dbg !707

bb20:                                             ; preds = %start
  %4 = getelementptr inbounds i8, ptr %_1, i64 32, !dbg !708
; invoke core::ptr::drop_in_place<complex::to_json::{{closure}}>
  invoke void @"_ZN4core3ptr66drop_in_place$LT$complex..to_json..$u7b$$u7b$closure$u7d$$u7d$$GT$17hcd44afcccc964b77E"(ptr align 8 %4)
          to label %bb2 unwind label %cleanup1, !dbg !708

bb12:                                             ; preds = %cleanup
  br label %bb14, !dbg !709

cleanup:                                          ; preds = %bb19
  %5 = landingpad { ptr, i32 }
          cleanup
  %6 = extractvalue { ptr, i32 } %5, 0
  %7 = extractvalue { ptr, i32 } %5, 1
  store ptr %6, ptr %0, align 8
  %8 = getelementptr inbounds i8, ptr %0, i64 8
  store i32 %7, ptr %8, align 8
  br label %bb12

bb5:                                              ; preds = %bb19
  br label %bb7, !dbg !709

bb7:                                              ; preds = %bb2, %bb5
  ret void, !dbg !706

bb14:                                             ; preds = %bb10, %bb12
  %9 = load ptr, ptr %0, align 8, !dbg !706
  %10 = getelementptr inbounds i8, ptr %0, i64 8, !dbg !706
  %11 = load i32, ptr %10, align 8, !dbg !706
  %12 = insertvalue { ptr, i32 } poison, ptr %9, 0, !dbg !706
  %13 = insertvalue { ptr, i32 } %12, i32 %11, 1, !dbg !706
  resume { ptr, i32 } %13, !dbg !706

bb10:                                             ; preds = %cleanup1
  br label %bb14, !dbg !709

cleanup1:                                         ; preds = %bb20
  %14 = landingpad { ptr, i32 }
          cleanup
  %15 = extractvalue { ptr, i32 } %14, 0
  %16 = extractvalue { ptr, i32 } %14, 1
  store ptr %15, ptr %0, align 8
  %17 = getelementptr inbounds i8, ptr %0, i64 8
  store i32 %16, ptr %17, align 8
  br label %bb10

bb2:                                              ; preds = %bb20
  br label %bb7, !dbg !709
}

; core::ptr::drop_in_place<std::rt::lang_start<()>::{{closure}}>
; Function Attrs: inlinehint uwtable
define internal void @"_ZN4core3ptr85drop_in_place$LT$std..rt..lang_start$LT$$LP$$RP$$GT$..$u7b$$u7b$closure$u7d$$u7d$$GT$17hb4df91c0b8b08cbeE"(ptr align 8 %_1) unnamed_addr #1 !dbg !710 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !714, !DIExpression(), !717)
  ret void, !dbg !717
}

; core::hint::black_box
; Function Attrs: inlinehint uwtable
define internal i64 @_ZN4core4hint9black_box17hd3cf395c78131f8fE(i64 %dummy) unnamed_addr #1 !dbg !718 {
start:
  %0 = alloca [8 x i8], align 8
  %dummy.dbg.spill = alloca [8 x i8], align 8
  store i64 %dummy, ptr %dummy.dbg.spill, align 8
    #dbg_declare(ptr %dummy.dbg.spill, !722, !DIExpression(), !723)
  store i64 %dummy, ptr %0, align 8, !dbg !724
  call void asm sideeffect "", "r,~{memory}"(ptr %0), !dbg !724, !srcloc !153
  %_0 = load i64, ptr %0, align 8, !dbg !724
  ret i64 %_0, !dbg !725
}

; core::hint::black_box
; Function Attrs: inlinehint uwtable
define internal align 8 ptr @_ZN4core4hint9black_box17hf57882eb706180acE(ptr align 8 %dummy) unnamed_addr #1 !dbg !726 {
start:
  %0 = alloca [8 x i8], align 8
  %dummy.dbg.spill = alloca [8 x i8], align 8
  store ptr %dummy, ptr %dummy.dbg.spill, align 8
    #dbg_declare(ptr %dummy.dbg.spill, !730, !DIExpression(), !733)
  store ptr %dummy, ptr %0, align 8, !dbg !734
  call void asm sideeffect "", "r,~{memory}"(ptr %0), !dbg !734, !srcloc !153
  %_0 = load ptr, ptr %0, align 8, !dbg !734
  ret ptr %_0, !dbg !735
}

; core::task::wake::Waker::from_raw
; Function Attrs: inlinehint uwtable
define internal { ptr, ptr } @_ZN4core4task4wake5Waker8from_raw17h368bf203d158977aE(ptr align 8 %waker.0, ptr %waker.1) unnamed_addr #1 !dbg !736 {
start:
  %waker.dbg.spill = alloca [16 x i8], align 8
  store ptr %waker.0, ptr %waker.dbg.spill, align 8
  %0 = getelementptr inbounds i8, ptr %waker.dbg.spill, i64 8
  store ptr %waker.1, ptr %0, align 8
    #dbg_declare(ptr %waker.dbg.spill, !742, !DIExpression(), !743)
  %1 = insertvalue { ptr, ptr } poison, ptr %waker.0, 0, !dbg !744
  %2 = insertvalue { ptr, ptr } %1, ptr %waker.1, 1, !dbg !744
  ret { ptr, ptr } %2, !dbg !744
}

; core::task::wake::Context::from_waker
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core4task4wake7Context10from_waker17h322044d7ee0260aaE(ptr sret([32 x i8]) align 8 %_0, ptr align 8 %waker) unnamed_addr #1 !dbg !745 {
start:
  %waker.dbg.spill = alloca [8 x i8], align 8
  store ptr %waker, ptr %waker.dbg.spill, align 8
    #dbg_declare(ptr %waker.dbg.spill, !750, !DIExpression(), !751)
    #dbg_declare(ptr %waker.dbg.spill, !752, !DIExpression(), !765)
  store ptr %waker, ptr %_0, align 8, !dbg !767
  %0 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !767
  store ptr %waker, ptr %0, align 8, !dbg !767
  %1 = load ptr, ptr @0, align 8, !dbg !767
  %2 = load ptr, ptr getelementptr inbounds (i8, ptr @0, i64 8), align 8, !dbg !767
  %3 = getelementptr inbounds i8, ptr %_0, i64 16, !dbg !767
  store ptr %1, ptr %3, align 8, !dbg !767
  %4 = getelementptr inbounds i8, ptr %3, i64 8, !dbg !767
  store ptr %2, ptr %4, align 8, !dbg !767
  ret void, !dbg !773
}

; core::task::wake::RawWaker::new
; Function Attrs: inlinehint uwtable
define internal { ptr, ptr } @_ZN4core4task4wake8RawWaker3new17hfb3f559eb0c03964E(ptr %data, ptr align 8 %vtable) unnamed_addr #1 !dbg !774 {
start:
  %vtable.dbg.spill = alloca [8 x i8], align 8
  %data.dbg.spill = alloca [8 x i8], align 8
  store ptr %data, ptr %data.dbg.spill, align 8
    #dbg_declare(ptr %data.dbg.spill, !779, !DIExpression(), !781)
  store ptr %vtable, ptr %vtable.dbg.spill, align 8
    #dbg_declare(ptr %vtable.dbg.spill, !780, !DIExpression(), !782)
  %0 = insertvalue { ptr, ptr } poison, ptr %vtable, 0, !dbg !783
  %1 = insertvalue { ptr, ptr } %0, ptr %data, 1, !dbg !783
  ret { ptr, ptr } %1, !dbg !783
}

; <() as std::process::Termination>::report
; Function Attrs: inlinehint uwtable
define internal i8 @"_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17ha2b1f0f1ec0820b7E"() unnamed_addr #1 !dbg !784 {
start:
  %_1.dbg.spill = alloca [0 x i8], align 1
    #dbg_declare(ptr %_1.dbg.spill, !789, !DIExpression(), !790)
  ret i8 0, !dbg !791
}

; <F as core::future::into_future::IntoFuture>::into_future
; Function Attrs: uwtable
define internal void @"_ZN59_$LT$F$u20$as$u20$core..future..into_future..IntoFuture$GT$11into_future17h4749e41366c76841E"(ptr sret([16 x i8]) align 8 %_0, ptr align 8 %self) unnamed_addr #0 !dbg !792 {
start:
    #dbg_declare(ptr %self, !800, !DIExpression(), !803)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_0, ptr align 8 %self, i64 16, i1 false), !dbg !804
  ret void, !dbg !805
}

; <F as core::future::into_future::IntoFuture>::into_future
; Function Attrs: uwtable
define internal void @"_ZN59_$LT$F$u20$as$u20$core..future..into_future..IntoFuture$GT$11into_future17hdce4e288f9d68d49E"(ptr sret([16 x i8]) align 8 %_0, ptr align 8 %self) unnamed_addr #0 !dbg !806 {
start:
    #dbg_declare(ptr %self, !810, !DIExpression(), !813)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_0, ptr align 8 %self, i64 16, i1 false), !dbg !814
  ret void, !dbg !815
}

; <F as core::future::into_future::IntoFuture>::into_future
; Function Attrs: uwtable
define internal void @"_ZN59_$LT$F$u20$as$u20$core..future..into_future..IntoFuture$GT$11into_future17hf9b4fad8070ee57bE"(ptr sret([16 x i8]) align 8 %_0, ptr align 8 %self) unnamed_addr #0 !dbg !816 {
start:
    #dbg_declare(ptr %self, !820, !DIExpression(), !823)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_0, ptr align 8 %self, i64 16, i1 false), !dbg !824
  ret void, !dbg !825
}

; <&mut T as core::ops::deref::DerefMut>::deref_mut
; Function Attrs: uwtable
define internal align 8 ptr @"_ZN60_$LT$$RF$mut$u20$T$u20$as$u20$core..ops..deref..DerefMut$GT$9deref_mut17h2947722b5e24665bE"(ptr align 8 %self) unnamed_addr #0 !dbg !826 {
start:
  %self.dbg.spill = alloca [8 x i8], align 8
  store ptr %self, ptr %self.dbg.spill, align 8
    #dbg_declare(ptr %self.dbg.spill, !835, !DIExpression(), !836)
  %_0 = load ptr, ptr %self, align 8, !dbg !837
  ret ptr %_0, !dbg !838
}

; <&mut T as core::ops::deref::DerefMut>::deref_mut
; Function Attrs: uwtable
define internal align 8 ptr @"_ZN60_$LT$$RF$mut$u20$T$u20$as$u20$core..ops..deref..DerefMut$GT$9deref_mut17h6db209943f744ab6E"(ptr align 8 %self) unnamed_addr #0 !dbg !839 {
start:
  %self.dbg.spill = alloca [8 x i8], align 8
  store ptr %self, ptr %self.dbg.spill, align 8
    #dbg_declare(ptr %self.dbg.spill, !845, !DIExpression(), !846)
  %_0 = load ptr, ptr %self, align 8, !dbg !847
  ret ptr %_0, !dbg !848
}

; <core::task::wake::Waker as core::ops::drop::Drop>::drop
; Function Attrs: inlinehint uwtable
define internal void @"_ZN65_$LT$core..task..wake..Waker$u20$as$u20$core..ops..drop..Drop$GT$4drop17h4002d96cd0cf52c0E"(ptr align 8 %self) unnamed_addr #1 !dbg !849 {
start:
  %self.dbg.spill = alloca [8 x i8], align 8
  store ptr %self, ptr %self.dbg.spill, align 8
    #dbg_declare(ptr %self.dbg.spill, !855, !DIExpression(), !856)
  %_4 = load ptr, ptr %self, align 8, !dbg !857
  %0 = getelementptr inbounds i8, ptr %_4, i64 24, !dbg !857
  %_2 = load ptr, ptr %0, align 8, !dbg !857
  %1 = getelementptr inbounds i8, ptr %self, i64 8, !dbg !858
  %_3 = load ptr, ptr %1, align 8, !dbg !858
  call void %_2(ptr %_3), !dbg !857
  ret void, !dbg !859
}

; complex::find
; Function Attrs: noinline uwtable
define internal void @_ZN7complex4find17haf8990b269cad525E(ptr sret([16 x i8]) align 8 %_0, i64 %id) unnamed_addr #2 !dbg !860 {
start:
  %id.dbg.spill = alloca [8 x i8], align 8
  store i64 %id, ptr %id.dbg.spill, align 8
    #dbg_declare(ptr %id.dbg.spill, !864, !DIExpression(), !865)
  store i64 %id, ptr %_0, align 8, !dbg !866
  %0 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !866
  store i8 0, ptr %0, align 8, !dbg !866
  ret void, !dbg !867
}

; complex::find::{{closure}}
; Function Attrs: inlinehint uwtable
define internal void @"_ZN7complex4find28_$u7b$$u7b$closure$u7d$$u7d$17hd3aa913d703a15e1E"(ptr sret([24 x i8]) align 8 %_0, ptr align 8 %0, ptr align 8 %_task_context) unnamed_addr #1 personality ptr @rust_eh_personality !dbg !868 {
start:
  %1 = alloca [16 x i8], align 8
  %id.dbg.spill = alloca [8 x i8], align 8
  %_task_context.dbg.spill = alloca [8 x i8], align 8
  %_6 = alloca [24 x i8], align 8
  %_1 = alloca [8 x i8], align 8
  store ptr %0, ptr %_1, align 8
    #dbg_declare(ptr %_1, !894, !DIExpression(DW_OP_deref), !897)
  store ptr %_task_context, ptr %_task_context.dbg.spill, align 8
    #dbg_declare(ptr %_task_context.dbg.spill, !893, !DIExpression(), !898)
  %_8 = load ptr, ptr %_1, align 8, !dbg !898
  %2 = getelementptr inbounds i8, ptr %_8, i64 8, !dbg !898
  %3 = load i8, ptr %2, align 8, !dbg !898
  %_7 = zext i8 %3 to i32, !dbg !898
  switch i32 %_7, label %bb9 [
    i32 0, label %bb1
    i32 1, label %bb8.preheader
    i32 2, label %bb7.preheader
  ], !dbg !898

bb7.preheader:                                    ; preds = %start
  br label %bb7, !dbg !898

bb8.preheader:                                    ; preds = %start
  br label %bb8, !dbg !898

bb9:                                              ; preds = %start
  unreachable, !dbg !898

bb1:                                              ; preds = %start
  %_9 = load ptr, ptr %_1, align 8, !dbg !897
  %id = load i64, ptr %_9, align 8, !dbg !897
  store i64 %id, ptr %id.dbg.spill, align 8, !dbg !897
    #dbg_declare(ptr %id.dbg.spill, !895, !DIExpression(), !899)
; invoke core::hint::black_box
  %_4 = invoke i64 @_ZN4core4hint9black_box17hd3cf395c78131f8fE(i64 %id)
          to label %bb2 unwind label %cleanup, !dbg !900

bb8:                                              ; preds = %bb8.preheader, %bb8
  br i1 false, label %bb8, label %panic, !dbg !898

bb7:                                              ; preds = %bb7.preheader, %bb7
  br i1 false, label %bb7, label %panic1, !dbg !898

bb6:                                              ; preds = %cleanup
  %_11 = load ptr, ptr %_1, align 8, !dbg !898
  %4 = getelementptr inbounds i8, ptr %_11, i64 8, !dbg !898
  store i8 2, ptr %4, align 8, !dbg !898
  %5 = load ptr, ptr %1, align 8, !dbg !898
  %6 = getelementptr inbounds i8, ptr %1, i64 8, !dbg !898
  %7 = load i32, ptr %6, align 8, !dbg !898
  %8 = insertvalue { ptr, i32 } poison, ptr %5, 0, !dbg !898
  %9 = insertvalue { ptr, i32 } %8, i32 %7, 1, !dbg !898
  resume { ptr, i32 } %9, !dbg !898

cleanup:                                          ; preds = %bb1
  %10 = landingpad { ptr, i32 }
          cleanup
  %11 = extractvalue { ptr, i32 } %10, 0
  %12 = extractvalue { ptr, i32 } %10, 1
  store ptr %11, ptr %1, align 8
  %13 = getelementptr inbounds i8, ptr %1, i64 8
  store i32 %12, ptr %13, align 8
  br label %bb6

bb2:                                              ; preds = %bb1
  %14 = icmp eq i64 %_4, 0, !dbg !900
  br i1 %14, label %bb3, label %bb4, !dbg !900

bb3:                                              ; preds = %bb2
  store i64 0, ptr %_6, align 8, !dbg !901
  br label %bb5, !dbg !902

bb4:                                              ; preds = %bb2
  %15 = getelementptr inbounds i8, ptr %_6, i64 8, !dbg !903
  store i64 %id, ptr %15, align 8, !dbg !903
  %16 = getelementptr inbounds i8, ptr %15, i64 8, !dbg !903
  store i64 7, ptr %16, align 8, !dbg !903
  store i64 1, ptr %_6, align 8, !dbg !903
  br label %bb5, !dbg !902

bb5:                                              ; preds = %bb4, %bb3
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_0, ptr align 8 %_6, i64 24, i1 false), !dbg !904
  %_10 = load ptr, ptr %_1, align 8, !dbg !904
  %17 = getelementptr inbounds i8, ptr %_10, i64 8, !dbg !904
  store i8 1, ptr %17, align 8, !dbg !904
  ret void, !dbg !904

panic:                                            ; preds = %bb8
; call core::panicking::panic_const::panic_const_async_fn_resumed
  call void @_ZN4core9panicking11panic_const28panic_const_async_fn_resumed17hc64df446eef3dbfcE(ptr align 8 @alloc_17b2ef7f54ff32450a3a1b883ec8277f) #8, !dbg !898
  unreachable, !dbg !898

panic1:                                           ; preds = %bb7
; call core::panicking::panic_const::panic_const_async_fn_resumed_panic
  call void @_ZN4core9panicking11panic_const34panic_const_async_fn_resumed_panic17hbbd8ac004b7fd30aE(ptr align 8 @alloc_17b2ef7f54ff32450a3a1b883ec8277f) #8, !dbg !898
  unreachable, !dbg !898
}

; complex::is_accessible
; Function Attrs: noinline uwtable
define internal void @_ZN7complex13is_accessible17h8024ac0a7b498c2bE(ptr sret([16 x i8]) align 8 %_0, ptr align 8 %c) unnamed_addr #2 !dbg !905 {
start:
  %c.dbg.spill = alloca [8 x i8], align 8
  store ptr %c, ptr %c.dbg.spill, align 8
    #dbg_declare(ptr %c.dbg.spill, !909, !DIExpression(), !910)
  store ptr %c, ptr %_0, align 8, !dbg !911
  %0 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !911
  store i8 0, ptr %0, align 8, !dbg !911
  ret void, !dbg !912
}

; complex::is_accessible::{{closure}}
; Function Attrs: inlinehint uwtable
define internal i8 @"_ZN7complex13is_accessible28_$u7b$$u7b$closure$u7d$$u7d$17h7f4e417166478207E"(ptr align 8 %0, ptr align 8 %_task_context) unnamed_addr #1 personality ptr @rust_eh_personality !dbg !913 {
start:
  %1 = alloca [16 x i8], align 8
  %c.dbg.spill = alloca [8 x i8], align 8
  %_task_context.dbg.spill = alloca [8 x i8], align 8
  %_0 = alloca [1 x i8], align 1
  %_1 = alloca [8 x i8], align 8
  store ptr %0, ptr %_1, align 8
    #dbg_declare(ptr %_1, !937, !DIExpression(DW_OP_deref), !940)
  store ptr %_task_context, ptr %_task_context.dbg.spill, align 8
    #dbg_declare(ptr %_task_context.dbg.spill, !936, !DIExpression(), !941)
  %_8 = load ptr, ptr %_1, align 8, !dbg !941
  %2 = getelementptr inbounds i8, ptr %_8, i64 8, !dbg !941
  %3 = load i8, ptr %2, align 8, !dbg !941
  %_7 = zext i8 %3 to i32, !dbg !941
  switch i32 %_7, label %bb6 [
    i32 0, label %bb1
    i32 1, label %bb5.preheader
    i32 2, label %bb4.preheader
  ], !dbg !941

bb4.preheader:                                    ; preds = %start
  br label %bb4, !dbg !941

bb5.preheader:                                    ; preds = %start
  br label %bb5, !dbg !941

bb6:                                              ; preds = %start
  unreachable, !dbg !941

bb1:                                              ; preds = %start
  %_9 = load ptr, ptr %_1, align 8, !dbg !940
  %c = load ptr, ptr %_9, align 8, !dbg !940
  store ptr %c, ptr %c.dbg.spill, align 8, !dbg !940
    #dbg_declare(ptr %c.dbg.spill, !938, !DIExpression(), !942)
; invoke core::hint::black_box
  %_5 = invoke align 8 ptr @_ZN4core4hint9black_box17hf57882eb706180acE(ptr align 8 %c)
          to label %bb2 unwind label %cleanup, !dbg !943

bb5:                                              ; preds = %bb5.preheader, %bb5
  br i1 false, label %bb5, label %panic, !dbg !941

bb4:                                              ; preds = %bb4.preheader, %bb4
  br i1 false, label %bb4, label %panic1, !dbg !941

bb3:                                              ; preds = %cleanup
  %_11 = load ptr, ptr %_1, align 8, !dbg !941
  %4 = getelementptr inbounds i8, ptr %_11, i64 8, !dbg !941
  store i8 2, ptr %4, align 8, !dbg !941
  %5 = load ptr, ptr %1, align 8, !dbg !941
  %6 = getelementptr inbounds i8, ptr %1, i64 8, !dbg !941
  %7 = load i32, ptr %6, align 8, !dbg !941
  %8 = insertvalue { ptr, i32 } poison, ptr %5, 0, !dbg !941
  %9 = insertvalue { ptr, i32 } %8, i32 %7, 1, !dbg !941
  resume { ptr, i32 } %9, !dbg !941

cleanup:                                          ; preds = %bb1
  %10 = landingpad { ptr, i32 }
          cleanup
  %11 = extractvalue { ptr, i32 } %10, 0
  %12 = extractvalue { ptr, i32 } %10, 1
  store ptr %11, ptr %1, align 8
  %13 = getelementptr inbounds i8, ptr %1, i64 8
  store i32 %12, ptr %13, align 8
  br label %bb3

bb2:                                              ; preds = %bb1
  %_4 = load i64, ptr %_5, align 8, !dbg !943
  %_6 = icmp ne i64 %_4, 0, !dbg !943
  %14 = zext i1 %_6 to i8, !dbg !944
  store i8 %14, ptr %_0, align 1, !dbg !944
  %_10 = load ptr, ptr %_1, align 8, !dbg !944
  %15 = getelementptr inbounds i8, ptr %_10, i64 8, !dbg !944
  store i8 1, ptr %15, align 8, !dbg !944
  %16 = load i8, ptr %_0, align 1, !dbg !944
  ret i8 %16, !dbg !944

panic:                                            ; preds = %bb5
; call core::panicking::panic_const::panic_const_async_fn_resumed
  call void @_ZN4core9panicking11panic_const28panic_const_async_fn_resumed17hc64df446eef3dbfcE(ptr align 8 @alloc_ba413b28931a21e86de0800d02475b9a) #8, !dbg !941
  unreachable, !dbg !941

panic1:                                           ; preds = %bb4
; call core::panicking::panic_const::panic_const_async_fn_resumed_panic
  call void @_ZN4core9panicking11panic_const34panic_const_async_fn_resumed_panic17hbbd8ac004b7fd30aE(ptr align 8 @alloc_ba413b28931a21e86de0800d02475b9a) #8, !dbg !941
  unreachable, !dbg !941
}

; complex::to_json
; Function Attrs: noinline uwtable
define internal void @_ZN7complex7to_json17h94dc01aa3ab612bfE(ptr sret([16 x i8]) align 8 %_0, ptr align 8 %c) unnamed_addr #2 !dbg !945 {
start:
  %c.dbg.spill = alloca [8 x i8], align 8
  store ptr %c, ptr %c.dbg.spill, align 8
    #dbg_declare(ptr %c.dbg.spill, !949, !DIExpression(), !950)
  store ptr %c, ptr %_0, align 8, !dbg !951
  %0 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !951
  store i8 0, ptr %0, align 8, !dbg !951
  ret void, !dbg !952
}

; complex::to_json::{{closure}}
; Function Attrs: inlinehint uwtable
define internal { i64, i64 } @"_ZN7complex7to_json28_$u7b$$u7b$closure$u7d$$u7d$17hacd03f5bf5fe9b3eE"(ptr align 8 %0, ptr align 8 %_task_context) unnamed_addr #1 personality ptr @rust_eh_personality !dbg !953 {
start:
  %1 = alloca [16 x i8], align 8
  %c.dbg.spill = alloca [8 x i8], align 8
  %_task_context.dbg.spill = alloca [8 x i8], align 8
  %_0 = alloca [16 x i8], align 8
  %_1 = alloca [8 x i8], align 8
  store ptr %0, ptr %_1, align 8
    #dbg_declare(ptr %_1, !975, !DIExpression(DW_OP_deref), !978)
  store ptr %_task_context, ptr %_task_context.dbg.spill, align 8
    #dbg_declare(ptr %_task_context.dbg.spill, !974, !DIExpression(), !979)
  %_7 = load ptr, ptr %_1, align 8, !dbg !979
  %2 = getelementptr inbounds i8, ptr %_7, i64 8, !dbg !979
  %3 = load i8, ptr %2, align 8, !dbg !979
  %_6 = zext i8 %3 to i32, !dbg !979
  switch i32 %_6, label %bb6 [
    i32 0, label %bb1
    i32 1, label %bb5.preheader
    i32 2, label %bb4.preheader
  ], !dbg !979

bb4.preheader:                                    ; preds = %start
  br label %bb4, !dbg !979

bb5.preheader:                                    ; preds = %start
  br label %bb5, !dbg !979

bb6:                                              ; preds = %start
  unreachable, !dbg !979

bb1:                                              ; preds = %start
  %_8 = load ptr, ptr %_1, align 8, !dbg !978
  %c = load ptr, ptr %_8, align 8, !dbg !978
  store ptr %c, ptr %c.dbg.spill, align 8, !dbg !978
    #dbg_declare(ptr %c.dbg.spill, !976, !DIExpression(), !980)
; invoke core::hint::black_box
  %_4 = invoke align 8 ptr @_ZN4core4hint9black_box17hf57882eb706180acE(ptr align 8 %c)
          to label %bb2 unwind label %cleanup, !dbg !981

bb5:                                              ; preds = %bb5.preheader, %bb5
  br i1 false, label %bb5, label %panic, !dbg !979

bb4:                                              ; preds = %bb4.preheader, %bb4
  br i1 false, label %bb4, label %panic1, !dbg !979

bb3:                                              ; preds = %cleanup
  %_10 = load ptr, ptr %_1, align 8, !dbg !979
  %4 = getelementptr inbounds i8, ptr %_10, i64 8, !dbg !979
  store i8 2, ptr %4, align 8, !dbg !979
  %5 = load ptr, ptr %1, align 8, !dbg !979
  %6 = getelementptr inbounds i8, ptr %1, i64 8, !dbg !979
  %7 = load i32, ptr %6, align 8, !dbg !979
  %8 = insertvalue { ptr, i32 } poison, ptr %5, 0, !dbg !979
  %9 = insertvalue { ptr, i32 } %8, i32 %7, 1, !dbg !979
  resume { ptr, i32 } %9, !dbg !979

cleanup:                                          ; preds = %bb1
  %10 = landingpad { ptr, i32 }
          cleanup
  %11 = extractvalue { ptr, i32 } %10, 0
  %12 = extractvalue { ptr, i32 } %10, 1
  store ptr %11, ptr %1, align 8
  %13 = getelementptr inbounds i8, ptr %1, i64 8
  store i32 %12, ptr %13, align 8
  br label %bb3

bb2:                                              ; preds = %bb1
  %14 = getelementptr inbounds i8, ptr %_4, i64 8, !dbg !981
  %_5 = load i64, ptr %14, align 8, !dbg !981
  %15 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !982
  store i64 %_5, ptr %15, align 8, !dbg !982
  store i64 0, ptr %_0, align 8, !dbg !982
  %_9 = load ptr, ptr %_1, align 8, !dbg !982
  %16 = getelementptr inbounds i8, ptr %_9, i64 8, !dbg !982
  store i8 1, ptr %16, align 8, !dbg !982
  %17 = load i64, ptr %_0, align 8, !dbg !982
  %18 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !982
  %19 = load i64, ptr %18, align 8, !dbg !982
  %20 = insertvalue { i64, i64 } poison, i64 %17, 0, !dbg !982
  %21 = insertvalue { i64, i64 } %20, i64 %19, 1, !dbg !982
  ret { i64, i64 } %21, !dbg !982

panic:                                            ; preds = %bb5
; call core::panicking::panic_const::panic_const_async_fn_resumed
  call void @_ZN4core9panicking11panic_const28panic_const_async_fn_resumed17hc64df446eef3dbfcE(ptr align 8 @alloc_3356c9023213d948f65e0e06b84a9e96) #8, !dbg !979
  unreachable, !dbg !979

panic1:                                           ; preds = %bb4
; call core::panicking::panic_const::panic_const_async_fn_resumed_panic
  call void @_ZN4core9panicking11panic_const34panic_const_async_fn_resumed_panic17hbbd8ac004b7fd30aE(ptr align 8 @alloc_3356c9023213d948f65e0e06b84a9e96) #8, !dbg !979
  unreachable, !dbg !979
}

; complex::get_cipher
; Function Attrs: noinline uwtable
define internal void @_ZN7complex10get_cipher17hea18acf247484af6E(ptr sret([48 x i8]) align 8 %_0, i64 %id) unnamed_addr #2 !dbg !983 {
start:
  %id.dbg.spill = alloca [8 x i8], align 8
  store i64 %id, ptr %id.dbg.spill, align 8
    #dbg_declare(ptr %id.dbg.spill, !987, !DIExpression(), !988)
  store i64 %id, ptr %_0, align 8, !dbg !989
  %0 = getelementptr inbounds i8, ptr %_0, i64 24, !dbg !989
  store i8 0, ptr %0, align 8, !dbg !989
  ret void, !dbg !990
}

; complex::get_cipher::{{closure}}
; Function Attrs: inlinehint uwtable
define internal { i64, i64 } @"_ZN7complex10get_cipher28_$u7b$$u7b$closure$u7d$$u7d$17h5d71340cd33ec17aE"(ptr align 8 %0, ptr align 8 %_2) unnamed_addr #1 personality ptr @rust_eh_personality !dbg !991 {
start:
  %pointer.dbg.spill.i9 = alloca [8 x i8], align 8
  %pointer.dbg.spill.i8 = alloca [8 x i8], align 8
  %pointer.dbg.spill.i = alloca [8 x i8], align 8
  %result.dbg.spill7 = alloca [8 x i8], align 8
  %result.dbg.spill = alloca [1 x i8], align 1
  %1 = alloca [16 x i8], align 8
  %id.dbg.spill = alloca [8 x i8], align 8
  %_2.dbg.spill = alloca [8 x i8], align 8
  %_task_context = alloca [8 x i8], align 8
  %_31 = alloca [8 x i8], align 8
  %_25 = alloca [16 x i8], align 8
  %_23 = alloca [16 x i8], align 8
  %_22 = alloca [16 x i8], align 8
  %_16 = alloca [1 x i8], align 1
  %_14 = alloca [16 x i8], align 8
  %_13 = alloca [16 x i8], align 8
  %result = alloca [24 x i8], align 8
  %_6 = alloca [24 x i8], align 8
  %_5 = alloca [16 x i8], align 8
  %_4 = alloca [16 x i8], align 8
  %_0 = alloca [16 x i8], align 8
  %_1 = alloca [8 x i8], align 8
  store ptr %0, ptr %_1, align 8
    #dbg_declare(ptr %_1, !1001, !DIExpression(DW_OP_deref), !1019)
    #dbg_declare(ptr %_1, !1004, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 8), !1020)
    #dbg_declare(ptr %_1, !1006, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 32), !1021)
    #dbg_declare(ptr %_1, !1010, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 32), !1022)
    #dbg_declare(ptr %_1, !1014, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 32), !1023)
  store ptr %_2, ptr %_2.dbg.spill, align 8
    #dbg_declare(ptr %_2.dbg.spill, !1018, !DIExpression(), !1024)
    #dbg_declare(ptr %result, !1008, !DIExpression(), !1025)
    #dbg_declare(ptr %_task_context, !1000, !DIExpression(), !1024)
  %_34 = load ptr, ptr %_1, align 8, !dbg !1024
  %2 = getelementptr inbounds i8, ptr %_34, i64 24, !dbg !1024
  %3 = load i8, ptr %2, align 8, !dbg !1024
  %_33 = zext i8 %3 to i32, !dbg !1024
  switch i32 %_33, label %bb7 [
    i32 0, label %bb1
    i32 1, label %bb39.preheader
    i32 2, label %bb38.preheader
    i32 3, label %bb35
    i32 4, label %bb36
    i32 5, label %bb37
  ], !dbg !1024

bb38.preheader:                                   ; preds = %start
  br label %bb38, !dbg !1024

bb39.preheader:                                   ; preds = %start
  br label %bb39, !dbg !1024

bb7:                                              ; preds = %start
  unreachable, !dbg !1026

bb1:                                              ; preds = %start
  store ptr %_2, ptr %_task_context, align 8, !dbg !1024
  %_35 = load ptr, ptr %_1, align 8, !dbg !1019
  %id = load i64, ptr %_35, align 8, !dbg !1019
  store i64 %id, ptr %id.dbg.spill, align 8, !dbg !1019
    #dbg_declare(ptr %id.dbg.spill, !1002, !DIExpression(), !1027)
; invoke complex::find
  invoke void @_ZN7complex4find17haf8990b269cad525E(ptr sret([16 x i8]) align 8 %_5, i64 %id)
          to label %bb2 unwind label %cleanup, !dbg !1028

bb39:                                             ; preds = %bb39.preheader, %bb39
  br i1 false, label %bb39, label %panic, !dbg !1024

bb38:                                             ; preds = %bb38.preheader, %bb38
  br i1 false, label %bb38, label %panic1, !dbg !1024

bb35:                                             ; preds = %start
  store ptr %_2, ptr %_task_context, align 8, !dbg !1029
  br label %bb4, !dbg !1029

bb36:                                             ; preds = %start
  store ptr %_2, ptr %_task_context, align 8, !dbg !1030
  br label %bb15, !dbg !1030

bb37:                                             ; preds = %start
  store ptr %_2, ptr %_task_context, align 8, !dbg !1031
  br label %bb25, !dbg !1031

bb34:                                             ; preds = %bb31, %bb32, %bb33, %cleanup
  %_55 = load ptr, ptr %_1, align 8, !dbg !1024
  %4 = getelementptr inbounds i8, ptr %_55, i64 24, !dbg !1024
  store i8 2, ptr %4, align 8, !dbg !1024
  %5 = load ptr, ptr %1, align 8, !dbg !1024
  %6 = getelementptr inbounds i8, ptr %1, i64 8, !dbg !1024
  %7 = load i32, ptr %6, align 8, !dbg !1024
  %8 = insertvalue { ptr, i32 } poison, ptr %5, 0, !dbg !1024
  %9 = insertvalue { ptr, i32 } %8, i32 %7, 1, !dbg !1024
  resume { ptr, i32 } %9, !dbg !1024

cleanup:                                          ; preds = %bb29, %bb23, %bb22, %bb19, %bb13, %bb11, %bb9, %bb2, %bb1
  %10 = landingpad { ptr, i32 }
          cleanup
  %11 = extractvalue { ptr, i32 } %10, 0
  %12 = extractvalue { ptr, i32 } %10, 1
  store ptr %11, ptr %1, align 8
  %13 = getelementptr inbounds i8, ptr %1, i64 8
  store i32 %12, ptr %13, align 8
  br label %bb34

bb2:                                              ; preds = %bb1
; invoke <F as core::future::into_future::IntoFuture>::into_future
  invoke void @"_ZN59_$LT$F$u20$as$u20$core..future..into_future..IntoFuture$GT$11into_future17hdce4e288f9d68d49E"(ptr sret([16 x i8]) align 8 %_4, ptr align 8 %_5)
          to label %bb3 unwind label %cleanup, !dbg !1032

bb3:                                              ; preds = %bb2
  %_36 = load ptr, ptr %_1, align 8, !dbg !1028
  %14 = getelementptr inbounds i8, ptr %_36, i64 32, !dbg !1028
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %14, ptr align 8 %_4, i64 16, i1 false), !dbg !1028
  br label %bb4, !dbg !1029

bb4:                                              ; preds = %bb35, %bb3
  %_37 = load ptr, ptr %_1, align 8, !dbg !1029
  %_8 = getelementptr inbounds i8, ptr %_37, i64 32, !dbg !1029
  store ptr %_8, ptr %pointer.dbg.spill.i8, align 8
    #dbg_declare(ptr %pointer.dbg.spill.i8, !1033, !DIExpression(), !1040)
  br label %bb5, !dbg !1042

panic:                                            ; preds = %bb39
; call core::panicking::panic_const::panic_const_async_fn_resumed
  call void @_ZN4core9panicking11panic_const28panic_const_async_fn_resumed17hc64df446eef3dbfcE(ptr align 8 @alloc_cbfe328adbdac12b53d34418bfcee063) #8, !dbg !1024
  unreachable, !dbg !1024

panic1:                                           ; preds = %bb38
; call core::panicking::panic_const::panic_const_async_fn_resumed_panic
  call void @_ZN4core9panicking11panic_const34panic_const_async_fn_resumed_panic17hbbd8ac004b7fd30aE(ptr align 8 @alloc_cbfe328adbdac12b53d34418bfcee063) #8, !dbg !1024
  unreachable, !dbg !1024

bb33:                                             ; preds = %cleanup2
  %_54 = load ptr, ptr %_1, align 8, !dbg !1043
  %15 = getelementptr inbounds i8, ptr %_54, i64 32, !dbg !1043
; invoke core::ptr::drop_in_place<complex::find::{{closure}}>
  invoke void @"_ZN4core3ptr63drop_in_place$LT$complex..find..$u7b$$u7b$closure$u7d$$u7d$$GT$17h300c76df0795e4ffE"(ptr align 8 %15) #9
          to label %bb34 unwind label %terminate, !dbg !1043

cleanup2:                                         ; preds = %bb5
  %16 = landingpad { ptr, i32 }
          cleanup
  %17 = extractvalue { ptr, i32 } %16, 0
  %18 = extractvalue { ptr, i32 } %16, 1
  store ptr %17, ptr %1, align 8
  %19 = getelementptr inbounds i8, ptr %1, i64 8
  store i32 %18, ptr %19, align 8
  br label %bb33

bb5:                                              ; preds = %bb4
  %_9 = load ptr, ptr %_task_context, align 8, !dbg !1029
; invoke complex::find::{{closure}}
  invoke void @"_ZN7complex4find28_$u7b$$u7b$closure$u7d$$u7d$17hd3aa913d703a15e1E"(ptr sret([24 x i8]) align 8 %_6, ptr align 8 %_8, ptr align 8 %_9)
          to label %bb6 unwind label %cleanup2, !dbg !1029

bb6:                                              ; preds = %bb5
  %20 = load i64, ptr %_6, align 8, !dbg !1029
  %21 = icmp eq i64 %20, 2, !dbg !1029
  %_10 = select i1 %21, i64 1, i64 0, !dbg !1029
  %22 = icmp eq i64 %_10, 0, !dbg !1029
  br i1 %22, label %bb9, label %bb8, !dbg !1029

bb9:                                              ; preds = %bb6
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %result, ptr align 8 %_6, i64 24, i1 false), !dbg !1021
  %_39 = load ptr, ptr %_1, align 8, !dbg !1043
  %23 = getelementptr inbounds i8, ptr %_39, i64 32, !dbg !1043
; invoke core::ptr::drop_in_place<complex::find::{{closure}}>
  invoke void @"_ZN4core3ptr63drop_in_place$LT$complex..find..$u7b$$u7b$closure$u7d$$u7d$$GT$17h300c76df0795e4ffE"(ptr align 8 %23)
          to label %bb10 unwind label %cleanup, !dbg !1043

bb8:                                              ; preds = %bb6
  store i64 1, ptr %_0, align 8, !dbg !1029
  %_38 = load ptr, ptr %_1, align 8, !dbg !1029
  %24 = getelementptr inbounds i8, ptr %_38, i64 24, !dbg !1029
  store i8 3, ptr %24, align 8, !dbg !1029
  %25 = load i64, ptr %_0, align 8, !dbg !1029
  %26 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !1029
  %27 = load i64, ptr %26, align 8, !dbg !1029
  %28 = insertvalue { i64, i64 } poison, i64 %25, 0, !dbg !1029
  %29 = insertvalue { i64, i64 } %28, i64 %27, 1, !dbg !1029
  ret { i64, i64 } %29, !dbg !1029

bb10:                                             ; preds = %bb9
  %_12 = load i64, ptr %result, align 8, !dbg !1028
  %30 = icmp eq i64 %_12, 1, !dbg !1044
  br i1 %30, label %bb11, label %bb12, !dbg !1044

bb11:                                             ; preds = %bb10
  %_40 = load ptr, ptr %_1, align 8, !dbg !1045
  %31 = getelementptr inbounds i8, ptr %_40, i64 8, !dbg !1045
  %32 = getelementptr inbounds i8, ptr %result, i64 8, !dbg !1045
  %33 = load i64, ptr %32, align 8, !dbg !1045
  %34 = getelementptr inbounds i8, ptr %32, i64 8, !dbg !1045
  %35 = load i64, ptr %34, align 8, !dbg !1045
  store i64 %33, ptr %31, align 8, !dbg !1045
  %36 = getelementptr inbounds i8, ptr %31, i64 8, !dbg !1045
  store i64 %35, ptr %36, align 8, !dbg !1045
  %_41 = load ptr, ptr %_1, align 8, !dbg !1046
  %_15 = getelementptr inbounds i8, ptr %_41, i64 8, !dbg !1046
; invoke complex::is_accessible
  invoke void @_ZN7complex13is_accessible17h8024ac0a7b498c2bE(ptr sret([16 x i8]) align 8 %_14, ptr align 8 %_15)
          to label %bb13 unwind label %cleanup, !dbg !1047

bb12:                                             ; preds = %bb10
  store i64 0, ptr %_31, align 8, !dbg !1048
  br label %bb30, !dbg !1049

bb13:                                             ; preds = %bb11
; invoke <F as core::future::into_future::IntoFuture>::into_future
  invoke void @"_ZN59_$LT$F$u20$as$u20$core..future..into_future..IntoFuture$GT$11into_future17hf9b4fad8070ee57bE"(ptr sret([16 x i8]) align 8 %_13, ptr align 8 %_14)
          to label %bb14 unwind label %cleanup, !dbg !1050

bb14:                                             ; preds = %bb13
  %_42 = load ptr, ptr %_1, align 8, !dbg !1047
  %37 = getelementptr inbounds i8, ptr %_42, i64 32, !dbg !1047
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %37, ptr align 8 %_13, i64 16, i1 false), !dbg !1047
  br label %bb15, !dbg !1030

bb15:                                             ; preds = %bb36, %bb14
  %_43 = load ptr, ptr %_1, align 8, !dbg !1030
  %_18 = getelementptr inbounds i8, ptr %_43, i64 32, !dbg !1030
  store ptr %_18, ptr %pointer.dbg.spill.i, align 8
    #dbg_declare(ptr %pointer.dbg.spill.i, !1051, !DIExpression(), !1057)
  br label %bb16, !dbg !1059

bb30:                                             ; preds = %bb29, %bb21, %bb12
  %38 = load i64, ptr %_31, align 8, !dbg !1060
  %39 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !1060
  store i64 %38, ptr %39, align 8, !dbg !1060
  store i64 0, ptr %_0, align 8, !dbg !1060
  %_51 = load ptr, ptr %_1, align 8, !dbg !1060
  %40 = getelementptr inbounds i8, ptr %_51, i64 24, !dbg !1060
  store i8 1, ptr %40, align 8, !dbg !1060
  %41 = load i64, ptr %_0, align 8, !dbg !1060
  %42 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !1060
  %43 = load i64, ptr %42, align 8, !dbg !1060
  %44 = insertvalue { i64, i64 } poison, i64 %41, 0, !dbg !1060
  %45 = insertvalue { i64, i64 } %44, i64 %43, 1, !dbg !1060
  ret { i64, i64 } %45, !dbg !1060

terminate:                                        ; preds = %bb31, %bb32, %bb33
  %46 = landingpad { ptr, i32 }
          filter [0 x ptr] zeroinitializer
  %47 = extractvalue { ptr, i32 } %46, 0
  %48 = extractvalue { ptr, i32 } %46, 1
; call core::panicking::panic_in_cleanup
  call void @_ZN4core9panicking16panic_in_cleanup17hb960b8c5dea287d4E() #10, !dbg !1024
  unreachable, !dbg !1024

bb32:                                             ; preds = %cleanup3
  %_53 = load ptr, ptr %_1, align 8, !dbg !1061
  %49 = getelementptr inbounds i8, ptr %_53, i64 32, !dbg !1061
; invoke core::ptr::drop_in_place<complex::is_accessible::{{closure}}>
  invoke void @"_ZN4core3ptr72drop_in_place$LT$complex..is_accessible..$u7b$$u7b$closure$u7d$$u7d$$GT$17h063ee76deceb8fb5E"(ptr align 8 %49) #9
          to label %bb34 unwind label %terminate, !dbg !1061

cleanup3:                                         ; preds = %bb16
  %50 = landingpad { ptr, i32 }
          cleanup
  %51 = extractvalue { ptr, i32 } %50, 0
  %52 = extractvalue { ptr, i32 } %50, 1
  store ptr %51, ptr %1, align 8
  %53 = getelementptr inbounds i8, ptr %1, i64 8
  store i32 %52, ptr %53, align 8
  br label %bb32

bb16:                                             ; preds = %bb15
  %_19 = load ptr, ptr %_task_context, align 8, !dbg !1030
; invoke complex::is_accessible::{{closure}}
  %54 = invoke i8 @"_ZN7complex13is_accessible28_$u7b$$u7b$closure$u7d$$u7d$17h7f4e417166478207E"(ptr align 8 %_18, ptr align 8 %_19)
          to label %bb17 unwind label %cleanup3, !dbg !1030

bb17:                                             ; preds = %bb16
  store i8 %54, ptr %_16, align 1, !dbg !1030
  %55 = load i8, ptr %_16, align 1, !dbg !1030
  %56 = icmp eq i8 %55, 2, !dbg !1030
  %_20 = select i1 %56, i64 1, i64 0, !dbg !1030
  %57 = icmp eq i64 %_20, 0, !dbg !1030
  br i1 %57, label %bb19, label %bb18, !dbg !1030

bb19:                                             ; preds = %bb17
  %58 = load i8, ptr %_16, align 1, !dbg !1022
  %result4 = trunc i8 %58 to i1, !dbg !1022
  %59 = zext i1 %result4 to i8, !dbg !1022
  store i8 %59, ptr %result.dbg.spill, align 1, !dbg !1022
    #dbg_declare(ptr %result.dbg.spill, !1012, !DIExpression(), !1062)
  %_45 = load ptr, ptr %_1, align 8, !dbg !1061
  %60 = getelementptr inbounds i8, ptr %_45, i64 32, !dbg !1061
; invoke core::ptr::drop_in_place<complex::is_accessible::{{closure}}>
  invoke void @"_ZN4core3ptr72drop_in_place$LT$complex..is_accessible..$u7b$$u7b$closure$u7d$$u7d$$GT$17h063ee76deceb8fb5E"(ptr align 8 %60)
          to label %bb20 unwind label %cleanup, !dbg !1061

bb18:                                             ; preds = %bb17
  store i64 1, ptr %_0, align 8, !dbg !1030
  %_44 = load ptr, ptr %_1, align 8, !dbg !1030
  %61 = getelementptr inbounds i8, ptr %_44, i64 24, !dbg !1030
  store i8 4, ptr %61, align 8, !dbg !1030
  %62 = load i64, ptr %_0, align 8, !dbg !1030
  %63 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !1030
  %64 = load i64, ptr %63, align 8, !dbg !1030
  %65 = insertvalue { i64, i64 } poison, i64 %62, 0, !dbg !1030
  %66 = insertvalue { i64, i64 } %65, i64 %64, 1, !dbg !1030
  ret { i64, i64 } %66, !dbg !1030

bb20:                                             ; preds = %bb19
  br i1 %result4, label %bb22, label %bb21, !dbg !1047

bb21:                                             ; preds = %bb20
  store i64 0, ptr %_31, align 8, !dbg !1063
  br label %bb30, !dbg !1064

bb22:                                             ; preds = %bb20
  %_46 = load ptr, ptr %_1, align 8, !dbg !1065
  %_24 = getelementptr inbounds i8, ptr %_46, i64 8, !dbg !1065
; invoke complex::to_json
  invoke void @_ZN7complex7to_json17h94dc01aa3ab612bfE(ptr sret([16 x i8]) align 8 %_23, ptr align 8 %_24)
          to label %bb23 unwind label %cleanup, !dbg !1066

bb23:                                             ; preds = %bb22
; invoke <F as core::future::into_future::IntoFuture>::into_future
  invoke void @"_ZN59_$LT$F$u20$as$u20$core..future..into_future..IntoFuture$GT$11into_future17h4749e41366c76841E"(ptr sret([16 x i8]) align 8 %_22, ptr align 8 %_23)
          to label %bb24 unwind label %cleanup, !dbg !1067

bb24:                                             ; preds = %bb23
  %_47 = load ptr, ptr %_1, align 8, !dbg !1066
  %67 = getelementptr inbounds i8, ptr %_47, i64 32, !dbg !1066
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %67, ptr align 8 %_22, i64 16, i1 false), !dbg !1066
  br label %bb25, !dbg !1031

bb25:                                             ; preds = %bb37, %bb24
  %_48 = load ptr, ptr %_1, align 8, !dbg !1031
  %_27 = getelementptr inbounds i8, ptr %_48, i64 32, !dbg !1031
  store ptr %_27, ptr %pointer.dbg.spill.i9, align 8
    #dbg_declare(ptr %pointer.dbg.spill.i9, !1068, !DIExpression(), !1074)
  br label %bb26, !dbg !1076

bb31:                                             ; preds = %cleanup5
  %_52 = load ptr, ptr %_1, align 8, !dbg !1077
  %68 = getelementptr inbounds i8, ptr %_52, i64 32, !dbg !1077
; invoke core::ptr::drop_in_place<complex::to_json::{{closure}}>
  invoke void @"_ZN4core3ptr66drop_in_place$LT$complex..to_json..$u7b$$u7b$closure$u7d$$u7d$$GT$17hcd44afcccc964b77E"(ptr align 8 %68) #9
          to label %bb34 unwind label %terminate, !dbg !1077

cleanup5:                                         ; preds = %bb26
  %69 = landingpad { ptr, i32 }
          cleanup
  %70 = extractvalue { ptr, i32 } %69, 0
  %71 = extractvalue { ptr, i32 } %69, 1
  store ptr %70, ptr %1, align 8
  %72 = getelementptr inbounds i8, ptr %1, i64 8
  store i32 %71, ptr %72, align 8
  br label %bb31

bb26:                                             ; preds = %bb25
  %_28 = load ptr, ptr %_task_context, align 8, !dbg !1031
; invoke complex::to_json::{{closure}}
  %73 = invoke { i64, i64 } @"_ZN7complex7to_json28_$u7b$$u7b$closure$u7d$$u7d$17hacd03f5bf5fe9b3eE"(ptr align 8 %_27, ptr align 8 %_28)
          to label %bb27 unwind label %cleanup5, !dbg !1031

bb27:                                             ; preds = %bb26
  %74 = extractvalue { i64, i64 } %73, 0, !dbg !1031
  %75 = extractvalue { i64, i64 } %73, 1, !dbg !1031
  store i64 %74, ptr %_25, align 8, !dbg !1031
  %76 = getelementptr inbounds i8, ptr %_25, i64 8, !dbg !1031
  store i64 %75, ptr %76, align 8, !dbg !1031
  %_29 = load i64, ptr %_25, align 8, !dbg !1031
  %77 = icmp eq i64 %_29, 0, !dbg !1031
  br i1 %77, label %bb29, label %bb28, !dbg !1031

bb29:                                             ; preds = %bb27
  %78 = getelementptr inbounds i8, ptr %_25, i64 8, !dbg !1023
  %result6 = load i64, ptr %78, align 8, !dbg !1023
  store i64 %result6, ptr %result.dbg.spill7, align 8, !dbg !1023
    #dbg_declare(ptr %result.dbg.spill7, !1016, !DIExpression(), !1078)
  store i64 %result6, ptr %_31, align 8, !dbg !1078
  %_50 = load ptr, ptr %_1, align 8, !dbg !1077
  %79 = getelementptr inbounds i8, ptr %_50, i64 32, !dbg !1077
; invoke core::ptr::drop_in_place<complex::to_json::{{closure}}>
  invoke void @"_ZN4core3ptr66drop_in_place$LT$complex..to_json..$u7b$$u7b$closure$u7d$$u7d$$GT$17hcd44afcccc964b77E"(ptr align 8 %79)
          to label %bb30 unwind label %cleanup, !dbg !1077

bb28:                                             ; preds = %bb27
  store i64 1, ptr %_0, align 8, !dbg !1031
  %_49 = load ptr, ptr %_1, align 8, !dbg !1031
  %80 = getelementptr inbounds i8, ptr %_49, i64 24, !dbg !1031
  store i8 5, ptr %80, align 8, !dbg !1031
  %81 = load i64, ptr %_0, align 8, !dbg !1031
  %82 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !1031
  %83 = load i64, ptr %82, align 8, !dbg !1031
  %84 = insertvalue { i64, i64 } poison, i64 %81, 0, !dbg !1031
  %85 = insertvalue { i64, i64 } %84, i64 %83, 1, !dbg !1031
  ret { i64, i64 } %85, !dbg !1031
}

; complex::get_cipher_leak
; Function Attrs: noinline uwtable
define internal void @_ZN7complex15get_cipher_leak17h97d4073ba6d160ebE(ptr sret([48 x i8]) align 8 %_0, i64 %id) unnamed_addr #2 !dbg !1079 {
start:
  %id.dbg.spill = alloca [8 x i8], align 8
  store i64 %id, ptr %id.dbg.spill, align 8
    #dbg_declare(ptr %id.dbg.spill, !1083, !DIExpression(), !1084)
  store i64 %id, ptr %_0, align 8, !dbg !1085
  %0 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !1085
  store i8 0, ptr %0, align 8, !dbg !1085
  ret void, !dbg !1086
}

; complex::get_cipher_leak::{{closure}}
; Function Attrs: inlinehint uwtable
define internal { i64, i64 } @"_ZN7complex15get_cipher_leak28_$u7b$$u7b$closure$u7d$$u7d$17h103fd8bb17b8e4b5E"(ptr align 8 %0, ptr align 8 %_2) unnamed_addr #1 personality ptr @rust_eh_personality !dbg !1087 {
start:
  %pointer.dbg.spill.i5 = alloca [8 x i8], align 8
  %pointer.dbg.spill.i = alloca [8 x i8], align 8
  %result.dbg.spill = alloca [8 x i8], align 8
  %1 = alloca [16 x i8], align 8
  %id.dbg.spill = alloca [8 x i8], align 8
  %_2.dbg.spill = alloca [8 x i8], align 8
  %_task_context = alloca [8 x i8], align 8
  %_22 = alloca [8 x i8], align 8
  %_16 = alloca [16 x i8], align 8
  %_14 = alloca [16 x i8], align 8
  %_13 = alloca [16 x i8], align 8
  %result = alloca [24 x i8], align 8
  %_6 = alloca [24 x i8], align 8
  %_5 = alloca [16 x i8], align 8
  %_4 = alloca [16 x i8], align 8
  %_0 = alloca [16 x i8], align 8
  %_1 = alloca [8 x i8], align 8
  store ptr %0, ptr %_1, align 8
    #dbg_declare(ptr %_1, !1097, !DIExpression(DW_OP_deref), !1111)
    #dbg_declare(ptr %_1, !1100, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 16), !1112)
    #dbg_declare(ptr %_1, !1102, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 16), !1113)
    #dbg_declare(ptr %_1, !1106, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 32), !1114)
  store ptr %_2, ptr %_2.dbg.spill, align 8
    #dbg_declare(ptr %_2.dbg.spill, !1110, !DIExpression(), !1115)
    #dbg_declare(ptr %result, !1104, !DIExpression(), !1116)
    #dbg_declare(ptr %_task_context, !1096, !DIExpression(), !1115)
  %_25 = load ptr, ptr %_1, align 8, !dbg !1115
  %2 = getelementptr inbounds i8, ptr %_25, i64 8, !dbg !1115
  %3 = load i8, ptr %2, align 8, !dbg !1115
  %_24 = zext i8 %3 to i32, !dbg !1115
  switch i32 %_24, label %bb7 [
    i32 0, label %bb1
    i32 1, label %bb27.preheader
    i32 2, label %bb26.preheader
    i32 3, label %bb24
    i32 4, label %bb25
  ], !dbg !1115

bb26.preheader:                                   ; preds = %start
  br label %bb26, !dbg !1115

bb27.preheader:                                   ; preds = %start
  br label %bb27, !dbg !1115

bb7:                                              ; preds = %start
  unreachable, !dbg !1117

bb1:                                              ; preds = %start
  store ptr %_2, ptr %_task_context, align 8, !dbg !1115
  %_26 = load ptr, ptr %_1, align 8, !dbg !1111
  %id = load i64, ptr %_26, align 8, !dbg !1111
  store i64 %id, ptr %id.dbg.spill, align 8, !dbg !1111
    #dbg_declare(ptr %id.dbg.spill, !1098, !DIExpression(), !1118)
; invoke complex::find
  invoke void @_ZN7complex4find17haf8990b269cad525E(ptr sret([16 x i8]) align 8 %_5, i64 %id)
          to label %bb2 unwind label %cleanup, !dbg !1119

bb27:                                             ; preds = %bb27.preheader, %bb27
  br i1 false, label %bb27, label %panic, !dbg !1115

bb26:                                             ; preds = %bb26.preheader, %bb26
  br i1 false, label %bb26, label %panic1, !dbg !1115

bb24:                                             ; preds = %start
  store ptr %_2, ptr %_task_context, align 8, !dbg !1120
  br label %bb4, !dbg !1120

bb25:                                             ; preds = %start
  store ptr %_2, ptr %_task_context, align 8, !dbg !1121
  br label %bb15, !dbg !1121

bb23:                                             ; preds = %bb21, %bb22, %cleanup
  %_40 = load ptr, ptr %_1, align 8, !dbg !1115
  %4 = getelementptr inbounds i8, ptr %_40, i64 8, !dbg !1115
  store i8 2, ptr %4, align 8, !dbg !1115
  %5 = load ptr, ptr %1, align 8, !dbg !1115
  %6 = getelementptr inbounds i8, ptr %1, i64 8, !dbg !1115
  %7 = load i32, ptr %6, align 8, !dbg !1115
  %8 = insertvalue { ptr, i32 } poison, ptr %5, 0, !dbg !1115
  %9 = insertvalue { ptr, i32 } %8, i32 %7, 1, !dbg !1115
  resume { ptr, i32 } %9, !dbg !1115

cleanup:                                          ; preds = %bb19, %bb13, %bb11, %bb9, %bb2, %bb1
  %10 = landingpad { ptr, i32 }
          cleanup
  %11 = extractvalue { ptr, i32 } %10, 0
  %12 = extractvalue { ptr, i32 } %10, 1
  store ptr %11, ptr %1, align 8
  %13 = getelementptr inbounds i8, ptr %1, i64 8
  store i32 %12, ptr %13, align 8
  br label %bb23

bb2:                                              ; preds = %bb1
; invoke <F as core::future::into_future::IntoFuture>::into_future
  invoke void @"_ZN59_$LT$F$u20$as$u20$core..future..into_future..IntoFuture$GT$11into_future17hdce4e288f9d68d49E"(ptr sret([16 x i8]) align 8 %_4, ptr align 8 %_5)
          to label %bb3 unwind label %cleanup, !dbg !1122

bb3:                                              ; preds = %bb2
  %_27 = load ptr, ptr %_1, align 8, !dbg !1119
  %14 = getelementptr inbounds i8, ptr %_27, i64 16, !dbg !1119
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %14, ptr align 8 %_4, i64 16, i1 false), !dbg !1119
  br label %bb4, !dbg !1120

bb4:                                              ; preds = %bb24, %bb3
  %_28 = load ptr, ptr %_1, align 8, !dbg !1120
  %_8 = getelementptr inbounds i8, ptr %_28, i64 16, !dbg !1120
  store ptr %_8, ptr %pointer.dbg.spill.i, align 8
    #dbg_declare(ptr %pointer.dbg.spill.i, !1033, !DIExpression(), !1123)
  br label %bb5, !dbg !1125

panic:                                            ; preds = %bb27
; call core::panicking::panic_const::panic_const_async_fn_resumed
  call void @_ZN4core9panicking11panic_const28panic_const_async_fn_resumed17hc64df446eef3dbfcE(ptr align 8 @alloc_ab2f1013ea6b18eaad8d1ba8c124ed78) #8, !dbg !1115
  unreachable, !dbg !1115

panic1:                                           ; preds = %bb26
; call core::panicking::panic_const::panic_const_async_fn_resumed_panic
  call void @_ZN4core9panicking11panic_const34panic_const_async_fn_resumed_panic17hbbd8ac004b7fd30aE(ptr align 8 @alloc_ab2f1013ea6b18eaad8d1ba8c124ed78) #8, !dbg !1115
  unreachable, !dbg !1115

bb22:                                             ; preds = %cleanup2
  %_39 = load ptr, ptr %_1, align 8, !dbg !1126
  %15 = getelementptr inbounds i8, ptr %_39, i64 16, !dbg !1126
; invoke core::ptr::drop_in_place<complex::find::{{closure}}>
  invoke void @"_ZN4core3ptr63drop_in_place$LT$complex..find..$u7b$$u7b$closure$u7d$$u7d$$GT$17h300c76df0795e4ffE"(ptr align 8 %15) #9
          to label %bb23 unwind label %terminate, !dbg !1126

cleanup2:                                         ; preds = %bb5
  %16 = landingpad { ptr, i32 }
          cleanup
  %17 = extractvalue { ptr, i32 } %16, 0
  %18 = extractvalue { ptr, i32 } %16, 1
  store ptr %17, ptr %1, align 8
  %19 = getelementptr inbounds i8, ptr %1, i64 8
  store i32 %18, ptr %19, align 8
  br label %bb22

bb5:                                              ; preds = %bb4
  %_9 = load ptr, ptr %_task_context, align 8, !dbg !1120
; invoke complex::find::{{closure}}
  invoke void @"_ZN7complex4find28_$u7b$$u7b$closure$u7d$$u7d$17hd3aa913d703a15e1E"(ptr sret([24 x i8]) align 8 %_6, ptr align 8 %_8, ptr align 8 %_9)
          to label %bb6 unwind label %cleanup2, !dbg !1120

bb6:                                              ; preds = %bb5
  %20 = load i64, ptr %_6, align 8, !dbg !1120
  %21 = icmp eq i64 %20, 2, !dbg !1120
  %_10 = select i1 %21, i64 1, i64 0, !dbg !1120
  %22 = icmp eq i64 %_10, 0, !dbg !1120
  br i1 %22, label %bb9, label %bb8, !dbg !1120

bb9:                                              ; preds = %bb6
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %result, ptr align 8 %_6, i64 24, i1 false), !dbg !1113
  %_30 = load ptr, ptr %_1, align 8, !dbg !1126
  %23 = getelementptr inbounds i8, ptr %_30, i64 16, !dbg !1126
; invoke core::ptr::drop_in_place<complex::find::{{closure}}>
  invoke void @"_ZN4core3ptr63drop_in_place$LT$complex..find..$u7b$$u7b$closure$u7d$$u7d$$GT$17h300c76df0795e4ffE"(ptr align 8 %23)
          to label %bb10 unwind label %cleanup, !dbg !1126

bb8:                                              ; preds = %bb6
  store i64 1, ptr %_0, align 8, !dbg !1120
  %_29 = load ptr, ptr %_1, align 8, !dbg !1120
  %24 = getelementptr inbounds i8, ptr %_29, i64 8, !dbg !1120
  store i8 3, ptr %24, align 8, !dbg !1120
  %25 = load i64, ptr %_0, align 8, !dbg !1120
  %26 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !1120
  %27 = load i64, ptr %26, align 8, !dbg !1120
  %28 = insertvalue { i64, i64 } poison, i64 %25, 0, !dbg !1120
  %29 = insertvalue { i64, i64 } %28, i64 %27, 1, !dbg !1120
  ret { i64, i64 } %29, !dbg !1120

bb10:                                             ; preds = %bb9
  %_12 = load i64, ptr %result, align 8, !dbg !1119
  %30 = icmp eq i64 %_12, 1, !dbg !1127
  br i1 %30, label %bb11, label %bb12, !dbg !1127

bb11:                                             ; preds = %bb10
  %_31 = load ptr, ptr %_1, align 8, !dbg !1128
  %31 = getelementptr inbounds i8, ptr %_31, i64 16, !dbg !1128
  %32 = getelementptr inbounds i8, ptr %result, i64 8, !dbg !1128
  %33 = load i64, ptr %32, align 8, !dbg !1128
  %34 = getelementptr inbounds i8, ptr %32, i64 8, !dbg !1128
  %35 = load i64, ptr %34, align 8, !dbg !1128
  store i64 %33, ptr %31, align 8, !dbg !1128
  %36 = getelementptr inbounds i8, ptr %31, i64 8, !dbg !1128
  store i64 %35, ptr %36, align 8, !dbg !1128
  %_32 = load ptr, ptr %_1, align 8, !dbg !1129
  %_15 = getelementptr inbounds i8, ptr %_32, i64 16, !dbg !1129
; invoke complex::to_json
  invoke void @_ZN7complex7to_json17h94dc01aa3ab612bfE(ptr sret([16 x i8]) align 8 %_14, ptr align 8 %_15)
          to label %bb13 unwind label %cleanup, !dbg !1130

bb12:                                             ; preds = %bb10
  store i64 0, ptr %_22, align 8, !dbg !1131
  br label %bb20, !dbg !1132

bb13:                                             ; preds = %bb11
; invoke <F as core::future::into_future::IntoFuture>::into_future
  invoke void @"_ZN59_$LT$F$u20$as$u20$core..future..into_future..IntoFuture$GT$11into_future17h4749e41366c76841E"(ptr sret([16 x i8]) align 8 %_13, ptr align 8 %_14)
          to label %bb14 unwind label %cleanup, !dbg !1133

bb14:                                             ; preds = %bb13
  %_33 = load ptr, ptr %_1, align 8, !dbg !1130
  %37 = getelementptr inbounds i8, ptr %_33, i64 32, !dbg !1130
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %37, ptr align 8 %_13, i64 16, i1 false), !dbg !1130
  br label %bb15, !dbg !1121

bb15:                                             ; preds = %bb25, %bb14
  %_34 = load ptr, ptr %_1, align 8, !dbg !1121
  %_18 = getelementptr inbounds i8, ptr %_34, i64 32, !dbg !1121
  store ptr %_18, ptr %pointer.dbg.spill.i5, align 8
    #dbg_declare(ptr %pointer.dbg.spill.i5, !1068, !DIExpression(), !1134)
  br label %bb16, !dbg !1136

bb20:                                             ; preds = %bb19, %bb12
  %38 = load i64, ptr %_22, align 8, !dbg !1137
  %39 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !1137
  store i64 %38, ptr %39, align 8, !dbg !1137
  store i64 0, ptr %_0, align 8, !dbg !1137
  %_37 = load ptr, ptr %_1, align 8, !dbg !1137
  %40 = getelementptr inbounds i8, ptr %_37, i64 8, !dbg !1137
  store i8 1, ptr %40, align 8, !dbg !1137
  %41 = load i64, ptr %_0, align 8, !dbg !1137
  %42 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !1137
  %43 = load i64, ptr %42, align 8, !dbg !1137
  %44 = insertvalue { i64, i64 } poison, i64 %41, 0, !dbg !1137
  %45 = insertvalue { i64, i64 } %44, i64 %43, 1, !dbg !1137
  ret { i64, i64 } %45, !dbg !1137

terminate:                                        ; preds = %bb21, %bb22
  %46 = landingpad { ptr, i32 }
          filter [0 x ptr] zeroinitializer
  %47 = extractvalue { ptr, i32 } %46, 0
  %48 = extractvalue { ptr, i32 } %46, 1
; call core::panicking::panic_in_cleanup
  call void @_ZN4core9panicking16panic_in_cleanup17hb960b8c5dea287d4E() #10, !dbg !1115
  unreachable, !dbg !1115

bb21:                                             ; preds = %cleanup3
  %_38 = load ptr, ptr %_1, align 8, !dbg !1138
  %49 = getelementptr inbounds i8, ptr %_38, i64 32, !dbg !1138
; invoke core::ptr::drop_in_place<complex::to_json::{{closure}}>
  invoke void @"_ZN4core3ptr66drop_in_place$LT$complex..to_json..$u7b$$u7b$closure$u7d$$u7d$$GT$17hcd44afcccc964b77E"(ptr align 8 %49) #9
          to label %bb23 unwind label %terminate, !dbg !1138

cleanup3:                                         ; preds = %bb16
  %50 = landingpad { ptr, i32 }
          cleanup
  %51 = extractvalue { ptr, i32 } %50, 0
  %52 = extractvalue { ptr, i32 } %50, 1
  store ptr %51, ptr %1, align 8
  %53 = getelementptr inbounds i8, ptr %1, i64 8
  store i32 %52, ptr %53, align 8
  br label %bb21

bb16:                                             ; preds = %bb15
  %_19 = load ptr, ptr %_task_context, align 8, !dbg !1121
; invoke complex::to_json::{{closure}}
  %54 = invoke { i64, i64 } @"_ZN7complex7to_json28_$u7b$$u7b$closure$u7d$$u7d$17hacd03f5bf5fe9b3eE"(ptr align 8 %_18, ptr align 8 %_19)
          to label %bb17 unwind label %cleanup3, !dbg !1121

bb17:                                             ; preds = %bb16
  %55 = extractvalue { i64, i64 } %54, 0, !dbg !1121
  %56 = extractvalue { i64, i64 } %54, 1, !dbg !1121
  store i64 %55, ptr %_16, align 8, !dbg !1121
  %57 = getelementptr inbounds i8, ptr %_16, i64 8, !dbg !1121
  store i64 %56, ptr %57, align 8, !dbg !1121
  %_20 = load i64, ptr %_16, align 8, !dbg !1121
  %58 = icmp eq i64 %_20, 0, !dbg !1121
  br i1 %58, label %bb19, label %bb18, !dbg !1121

bb19:                                             ; preds = %bb17
  %59 = getelementptr inbounds i8, ptr %_16, i64 8, !dbg !1114
  %result4 = load i64, ptr %59, align 8, !dbg !1114
  store i64 %result4, ptr %result.dbg.spill, align 8, !dbg !1114
    #dbg_declare(ptr %result.dbg.spill, !1108, !DIExpression(), !1139)
  store i64 %result4, ptr %_22, align 8, !dbg !1139
  %_36 = load ptr, ptr %_1, align 8, !dbg !1138
  %60 = getelementptr inbounds i8, ptr %_36, i64 32, !dbg !1138
; invoke core::ptr::drop_in_place<complex::to_json::{{closure}}>
  invoke void @"_ZN4core3ptr66drop_in_place$LT$complex..to_json..$u7b$$u7b$closure$u7d$$u7d$$GT$17hcd44afcccc964b77E"(ptr align 8 %60)
          to label %bb20 unwind label %cleanup, !dbg !1138

bb18:                                             ; preds = %bb17
  store i64 1, ptr %_0, align 8, !dbg !1121
  %_35 = load ptr, ptr %_1, align 8, !dbg !1121
  %61 = getelementptr inbounds i8, ptr %_35, i64 8, !dbg !1121
  store i8 4, ptr %61, align 8, !dbg !1121
  %62 = load i64, ptr %_0, align 8, !dbg !1121
  %63 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !1121
  %64 = load i64, ptr %63, align 8, !dbg !1121
  %65 = insertvalue { i64, i64 } poison, i64 %62, 0, !dbg !1121
  %66 = insertvalue { i64, i64 } %65, i64 %64, 1, !dbg !1121
  ret { i64, i64 } %66, !dbg !1121
}

; complex::noop
; Function Attrs: uwtable
define internal void @_ZN7complex4noop17h9534ba82ba052afdE(ptr %_1) unnamed_addr #0 !dbg !1140 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !1142, !DIExpression(), !1143)
  ret void, !dbg !1144
}

; complex::clone_w
; Function Attrs: uwtable
define internal { ptr, ptr } @_ZN7complex7clone_w17hdda8073de8df6721E(ptr %_1) unnamed_addr #0 !dbg !1145 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !1147, !DIExpression(), !1148)
; call core::task::wake::RawWaker::new
  %0 = call { ptr, ptr } @_ZN4core4task4wake8RawWaker3new17hfb3f559eb0c03964E(ptr null, ptr align 8 @_ZN7complex2VT17h8693aa46dd739d92E), !dbg !1149
  %_0.0 = extractvalue { ptr, ptr } %0, 0, !dbg !1149
  %_0.1 = extractvalue { ptr, ptr } %0, 1, !dbg !1149
  %1 = insertvalue { ptr, ptr } poison, ptr %_0.0, 0, !dbg !1150
  %2 = insertvalue { ptr, ptr } %1, ptr %_0.1, 1, !dbg !1150
  ret { ptr, ptr } %2, !dbg !1150
}

; complex::block_on
; Function Attrs: uwtable
define internal i64 @_ZN7complex8block_on17h0336e71cdf6382bbE(ptr align 8 %f) unnamed_addr #0 personality ptr @rust_eh_personality !dbg !1151 {
start:
  %pointer.dbg.spill.i = alloca [8 x i8], align 8
  %self.dbg.spill.i = alloca [8 x i8], align 8
  %v.dbg.spill = alloca [8 x i8], align 8
  %0 = alloca [16 x i8], align 8
  %_11 = alloca [16 x i8], align 8
  %cx = alloca [32 x i8], align 8
  %w = alloca [16 x i8], align 8
  %_4 = alloca [48 x i8], align 8
  %f1 = alloca [8 x i8], align 8
    #dbg_declare(ptr %f, !1155, !DIExpression(), !1166)
    #dbg_declare(ptr %f1, !1156, !DIExpression(), !1167)
    #dbg_declare(ptr %w, !1158, !DIExpression(), !1168)
    #dbg_declare(ptr %cx, !1160, !DIExpression(), !1169)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_4, ptr align 8 %f, i64 48, i1 false), !dbg !1170
  store ptr %_4, ptr %f1, align 8, !dbg !1171
  br label %bb1, !dbg !1172

bb12:                                             ; preds = %bb11, %cleanup
; invoke core::ptr::drop_in_place<complex::get_cipher::{{closure}}>
  invoke void @"_ZN4core3ptr69drop_in_place$LT$complex..get_cipher..$u7b$$u7b$closure$u7d$$u7d$$GT$17h3cb4a8df9c9346ecE"(ptr align 8 %_4) #9
          to label %bb13 unwind label %terminate, !dbg !1177

cleanup:                                          ; preds = %bb7, %bb2, %bb1
  %1 = landingpad { ptr, i32 }
          cleanup
  %2 = extractvalue { ptr, i32 } %1, 0
  %3 = extractvalue { ptr, i32 } %1, 1
  store ptr %2, ptr %0, align 8
  %4 = getelementptr inbounds i8, ptr %0, i64 8
  store i32 %3, ptr %4, align 8
  br label %bb12

bb1:                                              ; preds = %start
; invoke core::task::wake::RawWaker::new
  %5 = invoke { ptr, ptr } @_ZN4core4task4wake8RawWaker3new17hfb3f559eb0c03964E(ptr null, ptr align 8 @_ZN7complex2VT17h8693aa46dd739d92E)
          to label %bb2 unwind label %cleanup, !dbg !1178

bb2:                                              ; preds = %bb1
  %_6.0 = extractvalue { ptr, ptr } %5, 0, !dbg !1178
  %_6.1 = extractvalue { ptr, ptr } %5, 1, !dbg !1178
; invoke core::task::wake::Waker::from_raw
  %6 = invoke { ptr, ptr } @_ZN4core4task4wake5Waker8from_raw17h368bf203d158977aE(ptr align 8 %_6.0, ptr %_6.1)
          to label %bb3 unwind label %cleanup, !dbg !1179

bb3:                                              ; preds = %bb2
  %7 = extractvalue { ptr, ptr } %6, 0, !dbg !1179
  %8 = extractvalue { ptr, ptr } %6, 1, !dbg !1179
  store ptr %7, ptr %w, align 8, !dbg !1179
  %9 = getelementptr inbounds i8, ptr %w, i64 8, !dbg !1179
  store ptr %8, ptr %9, align 8, !dbg !1179
; invoke core::task::wake::Context::from_waker
  invoke void @_ZN4core4task4wake7Context10from_waker17h322044d7ee0260aaE(ptr sret([32 x i8]) align 8 %cx, ptr align 8 %w)
          to label %bb15 unwind label %cleanup2.loopexit.split-lp, !dbg !1180

bb11:                                             ; preds = %cleanup2
; invoke core::ptr::drop_in_place<core::task::wake::Waker>
  invoke void @"_ZN4core3ptr44drop_in_place$LT$core..task..wake..Waker$GT$17ha03ee6b39a1c10a5E"(ptr align 8 %w) #9
          to label %bb12 unwind label %terminate, !dbg !1181

cleanup2.loopexit:                                ; preds = %bb5, %bb4
  %lpad.loopexit = landingpad { ptr, i32 }
          cleanup
  br label %cleanup2

cleanup2.loopexit.split-lp:                       ; preds = %bb3
  %lpad.loopexit.split-lp = landingpad { ptr, i32 }
          cleanup
  br label %cleanup2

cleanup2:                                         ; preds = %cleanup2.loopexit.split-lp, %cleanup2.loopexit
  %lpad.phi = phi { ptr, i32 } [ %lpad.loopexit, %cleanup2.loopexit ], [ %lpad.loopexit.split-lp, %cleanup2.loopexit.split-lp ]
  %10 = extractvalue { ptr, i32 } %lpad.phi, 0
  %11 = extractvalue { ptr, i32 } %lpad.phi, 1
  store ptr %10, ptr %0, align 8
  %12 = getelementptr inbounds i8, ptr %0, i64 8
  store i32 %11, ptr %12, align 8
  br label %bb11

bb15:                                             ; preds = %bb3
  br label %bb4, !dbg !1180

bb4:                                              ; preds = %bb8, %bb15
  store ptr %f1, ptr %self.dbg.spill.i, align 8
    #dbg_declare(ptr %self.dbg.spill.i, !1182, !DIExpression(), !1189)
; invoke <&mut T as core::ops::deref::DerefMut>::deref_mut
  %pointer.i3 = invoke align 8 ptr @"_ZN60_$LT$$RF$mut$u20$T$u20$as$u20$core..ops..deref..DerefMut$GT$9deref_mut17h6db209943f744ab6E"(ptr align 8 %f1)
          to label %"_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17hd5a28efdfa7ea858E.exit" unwind label %cleanup2.loopexit, !dbg !1191

"_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17hd5a28efdfa7ea858E.exit": ; preds = %bb4
  store ptr %pointer.i3, ptr %pointer.dbg.spill.i, align 8, !dbg !1191
    #dbg_declare(ptr %pointer.dbg.spill.i, !1192, !DIExpression(), !1198)
  br label %bb5, !dbg !1200

bb5:                                              ; preds = %"_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17hd5a28efdfa7ea858E.exit"
; invoke complex::get_cipher::{{closure}}
  %13 = invoke { i64, i64 } @"_ZN7complex10get_cipher28_$u7b$$u7b$closure$u7d$$u7d$17h5d71340cd33ec17aE"(ptr align 8 %pointer.i3, ptr align 8 %cx)
          to label %bb6 unwind label %cleanup2.loopexit, !dbg !1201

bb6:                                              ; preds = %bb5
  %14 = extractvalue { i64, i64 } %13, 0, !dbg !1201
  %15 = extractvalue { i64, i64 } %13, 1, !dbg !1201
  store i64 %14, ptr %_11, align 8, !dbg !1201
  %16 = getelementptr inbounds i8, ptr %_11, i64 8, !dbg !1201
  store i64 %15, ptr %16, align 8, !dbg !1201
  %_15 = load i64, ptr %_11, align 8, !dbg !1201
  %17 = icmp eq i64 %_15, 0, !dbg !1202
  br i1 %17, label %bb7, label %bb8, !dbg !1202

bb7:                                              ; preds = %bb6
  %18 = getelementptr inbounds i8, ptr %_11, i64 8, !dbg !1203
  %v = load i64, ptr %18, align 8, !dbg !1203
  store i64 %v, ptr %v.dbg.spill, align 8, !dbg !1203
    #dbg_declare(ptr %v.dbg.spill, !1162, !DIExpression(), !1203)
; invoke core::ptr::drop_in_place<core::task::wake::Waker>
  invoke void @"_ZN4core3ptr44drop_in_place$LT$core..task..wake..Waker$GT$17ha03ee6b39a1c10a5E"(ptr align 8 %w)
          to label %bb9 unwind label %cleanup, !dbg !1181

bb8:                                              ; preds = %bb6
  br label %bb4, !dbg !1204

bb9:                                              ; preds = %bb7
; call core::ptr::drop_in_place<complex::get_cipher::{{closure}}>
  call void @"_ZN4core3ptr69drop_in_place$LT$complex..get_cipher..$u7b$$u7b$closure$u7d$$u7d$$GT$17h3cb4a8df9c9346ecE"(ptr align 8 %_4), !dbg !1177
  ret i64 %v, !dbg !1205

bb14:                                             ; No predecessors!
  unreachable, !dbg !1206

terminate:                                        ; preds = %bb12, %bb11
  %19 = landingpad { ptr, i32 }
          filter [0 x ptr] zeroinitializer
  %20 = extractvalue { ptr, i32 } %19, 0
  %21 = extractvalue { ptr, i32 } %19, 1
; call core::panicking::panic_in_cleanup
  call void @_ZN4core9panicking16panic_in_cleanup17hb960b8c5dea287d4E() #10, !dbg !1206
  unreachable, !dbg !1206

bb13:                                             ; preds = %bb12
  %22 = load ptr, ptr %0, align 8, !dbg !1206
  %23 = getelementptr inbounds i8, ptr %0, i64 8, !dbg !1206
  %24 = load i32, ptr %23, align 8, !dbg !1206
  %25 = insertvalue { ptr, i32 } poison, ptr %22, 0, !dbg !1206
  %26 = insertvalue { ptr, i32 } %25, i32 %24, 1, !dbg !1206
  resume { ptr, i32 } %26, !dbg !1206
}

; complex::block_on
; Function Attrs: uwtable
define internal i64 @_ZN7complex8block_on17h7b4f6a4b2b363256E(ptr align 8 %f) unnamed_addr #0 personality ptr @rust_eh_personality !dbg !1207 {
start:
  %pointer.dbg.spill.i = alloca [8 x i8], align 8
  %self.dbg.spill.i = alloca [8 x i8], align 8
  %v.dbg.spill = alloca [8 x i8], align 8
  %0 = alloca [16 x i8], align 8
  %_11 = alloca [16 x i8], align 8
  %cx = alloca [32 x i8], align 8
  %w = alloca [16 x i8], align 8
  %_4 = alloca [48 x i8], align 8
  %f1 = alloca [8 x i8], align 8
    #dbg_declare(ptr %f, !1211, !DIExpression(), !1222)
    #dbg_declare(ptr %f1, !1212, !DIExpression(), !1223)
    #dbg_declare(ptr %w, !1214, !DIExpression(), !1224)
    #dbg_declare(ptr %cx, !1216, !DIExpression(), !1225)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_4, ptr align 8 %f, i64 48, i1 false), !dbg !1226
  store ptr %_4, ptr %f1, align 8, !dbg !1227
  br label %bb1, !dbg !1228

bb12:                                             ; preds = %bb11, %cleanup
; invoke core::ptr::drop_in_place<complex::get_cipher_leak::{{closure}}>
  invoke void @"_ZN4core3ptr74drop_in_place$LT$complex..get_cipher_leak..$u7b$$u7b$closure$u7d$$u7d$$GT$17h23235722836c3597E"(ptr align 8 %_4) #9
          to label %bb13 unwind label %terminate, !dbg !1230

cleanup:                                          ; preds = %bb7, %bb2, %bb1
  %1 = landingpad { ptr, i32 }
          cleanup
  %2 = extractvalue { ptr, i32 } %1, 0
  %3 = extractvalue { ptr, i32 } %1, 1
  store ptr %2, ptr %0, align 8
  %4 = getelementptr inbounds i8, ptr %0, i64 8
  store i32 %3, ptr %4, align 8
  br label %bb12

bb1:                                              ; preds = %start
; invoke core::task::wake::RawWaker::new
  %5 = invoke { ptr, ptr } @_ZN4core4task4wake8RawWaker3new17hfb3f559eb0c03964E(ptr null, ptr align 8 @_ZN7complex2VT17h8693aa46dd739d92E)
          to label %bb2 unwind label %cleanup, !dbg !1231

bb2:                                              ; preds = %bb1
  %_6.0 = extractvalue { ptr, ptr } %5, 0, !dbg !1231
  %_6.1 = extractvalue { ptr, ptr } %5, 1, !dbg !1231
; invoke core::task::wake::Waker::from_raw
  %6 = invoke { ptr, ptr } @_ZN4core4task4wake5Waker8from_raw17h368bf203d158977aE(ptr align 8 %_6.0, ptr %_6.1)
          to label %bb3 unwind label %cleanup, !dbg !1232

bb3:                                              ; preds = %bb2
  %7 = extractvalue { ptr, ptr } %6, 0, !dbg !1232
  %8 = extractvalue { ptr, ptr } %6, 1, !dbg !1232
  store ptr %7, ptr %w, align 8, !dbg !1232
  %9 = getelementptr inbounds i8, ptr %w, i64 8, !dbg !1232
  store ptr %8, ptr %9, align 8, !dbg !1232
; invoke core::task::wake::Context::from_waker
  invoke void @_ZN4core4task4wake7Context10from_waker17h322044d7ee0260aaE(ptr sret([32 x i8]) align 8 %cx, ptr align 8 %w)
          to label %bb15 unwind label %cleanup2.loopexit.split-lp, !dbg !1233

bb11:                                             ; preds = %cleanup2
; invoke core::ptr::drop_in_place<core::task::wake::Waker>
  invoke void @"_ZN4core3ptr44drop_in_place$LT$core..task..wake..Waker$GT$17ha03ee6b39a1c10a5E"(ptr align 8 %w) #9
          to label %bb12 unwind label %terminate, !dbg !1234

cleanup2.loopexit:                                ; preds = %bb5, %bb4
  %lpad.loopexit = landingpad { ptr, i32 }
          cleanup
  br label %cleanup2

cleanup2.loopexit.split-lp:                       ; preds = %bb3
  %lpad.loopexit.split-lp = landingpad { ptr, i32 }
          cleanup
  br label %cleanup2

cleanup2:                                         ; preds = %cleanup2.loopexit.split-lp, %cleanup2.loopexit
  %lpad.phi = phi { ptr, i32 } [ %lpad.loopexit, %cleanup2.loopexit ], [ %lpad.loopexit.split-lp, %cleanup2.loopexit.split-lp ]
  %10 = extractvalue { ptr, i32 } %lpad.phi, 0
  %11 = extractvalue { ptr, i32 } %lpad.phi, 1
  store ptr %10, ptr %0, align 8
  %12 = getelementptr inbounds i8, ptr %0, i64 8
  store i32 %11, ptr %12, align 8
  br label %bb11

bb15:                                             ; preds = %bb3
  br label %bb4, !dbg !1233

bb4:                                              ; preds = %bb8, %bb15
  store ptr %f1, ptr %self.dbg.spill.i, align 8
    #dbg_declare(ptr %self.dbg.spill.i, !1235, !DIExpression(), !1242)
; invoke <&mut T as core::ops::deref::DerefMut>::deref_mut
  %pointer.i3 = invoke align 8 ptr @"_ZN60_$LT$$RF$mut$u20$T$u20$as$u20$core..ops..deref..DerefMut$GT$9deref_mut17h2947722b5e24665bE"(ptr align 8 %f1)
          to label %"_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17h862ccf0b8adeb29cE.exit" unwind label %cleanup2.loopexit, !dbg !1244

"_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17h862ccf0b8adeb29cE.exit": ; preds = %bb4
  store ptr %pointer.i3, ptr %pointer.dbg.spill.i, align 8, !dbg !1244
    #dbg_declare(ptr %pointer.dbg.spill.i, !1245, !DIExpression(), !1251)
  br label %bb5, !dbg !1253

bb5:                                              ; preds = %"_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17h862ccf0b8adeb29cE.exit"
; invoke complex::get_cipher_leak::{{closure}}
  %13 = invoke { i64, i64 } @"_ZN7complex15get_cipher_leak28_$u7b$$u7b$closure$u7d$$u7d$17h103fd8bb17b8e4b5E"(ptr align 8 %pointer.i3, ptr align 8 %cx)
          to label %bb6 unwind label %cleanup2.loopexit, !dbg !1254

bb6:                                              ; preds = %bb5
  %14 = extractvalue { i64, i64 } %13, 0, !dbg !1254
  %15 = extractvalue { i64, i64 } %13, 1, !dbg !1254
  store i64 %14, ptr %_11, align 8, !dbg !1254
  %16 = getelementptr inbounds i8, ptr %_11, i64 8, !dbg !1254
  store i64 %15, ptr %16, align 8, !dbg !1254
  %_15 = load i64, ptr %_11, align 8, !dbg !1254
  %17 = icmp eq i64 %_15, 0, !dbg !1255
  br i1 %17, label %bb7, label %bb8, !dbg !1255

bb7:                                              ; preds = %bb6
  %18 = getelementptr inbounds i8, ptr %_11, i64 8, !dbg !1256
  %v = load i64, ptr %18, align 8, !dbg !1256
  store i64 %v, ptr %v.dbg.spill, align 8, !dbg !1256
    #dbg_declare(ptr %v.dbg.spill, !1218, !DIExpression(), !1256)
; invoke core::ptr::drop_in_place<core::task::wake::Waker>
  invoke void @"_ZN4core3ptr44drop_in_place$LT$core..task..wake..Waker$GT$17ha03ee6b39a1c10a5E"(ptr align 8 %w)
          to label %bb9 unwind label %cleanup, !dbg !1234

bb8:                                              ; preds = %bb6
  br label %bb4, !dbg !1257

bb9:                                              ; preds = %bb7
; call core::ptr::drop_in_place<complex::get_cipher_leak::{{closure}}>
  call void @"_ZN4core3ptr74drop_in_place$LT$complex..get_cipher_leak..$u7b$$u7b$closure$u7d$$u7d$$GT$17h23235722836c3597E"(ptr align 8 %_4), !dbg !1230
  ret i64 %v, !dbg !1258

bb14:                                             ; No predecessors!
  unreachable, !dbg !1259

terminate:                                        ; preds = %bb12, %bb11
  %19 = landingpad { ptr, i32 }
          filter [0 x ptr] zeroinitializer
  %20 = extractvalue { ptr, i32 } %19, 0
  %21 = extractvalue { ptr, i32 } %19, 1
; call core::panicking::panic_in_cleanup
  call void @_ZN4core9panicking16panic_in_cleanup17hb960b8c5dea287d4E() #10, !dbg !1259
  unreachable, !dbg !1259

bb13:                                             ; preds = %bb12
  %22 = load ptr, ptr %0, align 8, !dbg !1259
  %23 = getelementptr inbounds i8, ptr %0, i64 8, !dbg !1259
  %24 = load i32, ptr %23, align 8, !dbg !1259
  %25 = insertvalue { ptr, i32 } poison, ptr %22, 0, !dbg !1259
  %26 = insertvalue { ptr, i32 } %25, i32 %24, 1, !dbg !1259
  resume { ptr, i32 } %26, !dbg !1259
}

; complex::main
; Function Attrs: uwtable
define internal void @_ZN7complex4main17h4d065abd446a5f7fE() unnamed_addr #0 !dbg !1260 {
start:
  %_19 = alloca [48 x i8], align 8
  %_18 = alloca [8 x i8], align 8
  %_16 = alloca [16 x i8], align 8
  %_15 = alloca [16 x i8], align 8
  %_12 = alloca [48 x i8], align 8
  %_9 = alloca [48 x i8], align 8
  %_8 = alloca [8 x i8], align 8
  %_6 = alloca [16 x i8], align 8
  %_5 = alloca [16 x i8], align 8
  %_2 = alloca [48 x i8], align 8
; call core::hint::black_box
  %_10 = call i64 @_ZN4core4hint9black_box17hd3cf395c78131f8fE(i64 1), !dbg !1261
; call complex::get_cipher
  call void @_ZN7complex10get_cipher17hea18acf247484af6E(ptr sret([48 x i8]) align 8 %_9, i64 %_10), !dbg !1262
; call complex::block_on
  %0 = call i64 @_ZN7complex8block_on17h0336e71cdf6382bbE(ptr align 8 %_9), !dbg !1263
  store i64 %0, ptr %_8, align 8, !dbg !1263
; call core::fmt::rt::Argument::new_display
  call void @_ZN4core3fmt2rt8Argument11new_display17hbbb6afbe72c84d49E(ptr sret([16 x i8]) align 8 %_6, ptr align 8 %_8), !dbg !1264
  %1 = getelementptr inbounds %"core::fmt::rt::Argument<'_>", ptr %_5, i64 0, !dbg !1264
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %1, ptr align 8 %_6, i64 16, i1 false), !dbg !1264
; call core::fmt::Arguments::new_v1
  call void @_ZN4core3fmt9Arguments6new_v117h152d81e9b06b0e25E(ptr sret([48 x i8]) align 8 %_2, ptr align 8 @alloc_9771be2481f51be410bd2ac520d18601, ptr align 8 %_5), !dbg !1264
; call std::io::stdio::_print
  call void @_ZN3std2io5stdio6_print17h6200d46cef53dee1E(ptr align 8 %_2), !dbg !1264
; call core::hint::black_box
  %_20 = call i64 @_ZN4core4hint9black_box17hd3cf395c78131f8fE(i64 2), !dbg !1265
; call complex::get_cipher_leak
  call void @_ZN7complex15get_cipher_leak17h97d4073ba6d160ebE(ptr sret([48 x i8]) align 8 %_19, i64 %_20), !dbg !1266
; call complex::block_on
  %2 = call i64 @_ZN7complex8block_on17h7b4f6a4b2b363256E(ptr align 8 %_19), !dbg !1267
  store i64 %2, ptr %_18, align 8, !dbg !1267
; call core::fmt::rt::Argument::new_display
  call void @_ZN4core3fmt2rt8Argument11new_display17hbbb6afbe72c84d49E(ptr sret([16 x i8]) align 8 %_16, ptr align 8 %_18), !dbg !1268
  %3 = getelementptr inbounds %"core::fmt::rt::Argument<'_>", ptr %_15, i64 0, !dbg !1268
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %3, ptr align 8 %_16, i64 16, i1 false), !dbg !1268
; call core::fmt::Arguments::new_v1
  call void @_ZN4core3fmt9Arguments6new_v117h152d81e9b06b0e25E(ptr sret([48 x i8]) align 8 %_12, ptr align 8 @alloc_9771be2481f51be410bd2ac520d18601, ptr align 8 %_15), !dbg !1268
; call std::io::stdio::_print
  call void @_ZN3std2io5stdio6_print17h6200d46cef53dee1E(ptr align 8 %_12), !dbg !1268
  ret void, !dbg !1269
}

; std::rt::lang_start_internal
; Function Attrs: uwtable
declare i64 @_ZN3std2rt19lang_start_internal17h95cf27b851151b9cE(ptr align 1, ptr align 8, i64, ptr, i8) unnamed_addr #0

; core::fmt::num::imp::<impl core::fmt::Display for u64>::fmt
; Function Attrs: uwtable
declare zeroext i1 @"_ZN4core3fmt3num3imp52_$LT$impl$u20$core..fmt..Display$u20$for$u20$u64$GT$3fmt17h339ac4429cb37bf0E"(ptr align 8, ptr align 8) unnamed_addr #0

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #3

; Function Attrs: nounwind uwtable
declare i32 @rust_eh_personality(i32, i32, i64, ptr, ptr) unnamed_addr #4

; core::panicking::panic_const::panic_const_async_fn_resumed
; Function Attrs: cold noinline noreturn uwtable
declare void @_ZN4core9panicking11panic_const28panic_const_async_fn_resumed17hc64df446eef3dbfcE(ptr align 8) unnamed_addr #5

; core::panicking::panic_const::panic_const_async_fn_resumed_panic
; Function Attrs: cold noinline noreturn uwtable
declare void @_ZN4core9panicking11panic_const34panic_const_async_fn_resumed_panic17hbbd8ac004b7fd30aE(ptr align 8) unnamed_addr #5

; core::panicking::panic_in_cleanup
; Function Attrs: cold minsize noinline noreturn nounwind optsize uwtable
declare void @_ZN4core9panicking16panic_in_cleanup17hb960b8c5dea287d4E() unnamed_addr #6

; std::io::stdio::_print
; Function Attrs: uwtable
declare void @_ZN3std2io5stdio6_print17h6200d46cef53dee1E(ptr align 8) unnamed_addr #0

define i32 @main(i32 %0, ptr %1) unnamed_addr #7 {
top:
  %2 = sext i32 %0 to i64
; call std::rt::lang_start
  %3 = call i64 @_ZN3std2rt10lang_start17hfbc1424e326a51c8E(ptr @_ZN7complex4main17h4d065abd446a5f7fE, i64 %2, ptr %1, i8 0)
  %4 = trunc i64 %3 to i32
  ret i32 %4
}

attributes #0 = { uwtable "frame-pointer"="non-leaf" "probe-stack"="inline-asm" "target-cpu"="apple-m1" }
attributes #1 = { inlinehint uwtable "frame-pointer"="non-leaf" "probe-stack"="inline-asm" "target-cpu"="apple-m1" }
attributes #2 = { noinline uwtable "frame-pointer"="non-leaf" "probe-stack"="inline-asm" "target-cpu"="apple-m1" }
attributes #3 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { nounwind uwtable "frame-pointer"="non-leaf" "probe-stack"="inline-asm" "target-cpu"="apple-m1" }
attributes #5 = { cold noinline noreturn uwtable "frame-pointer"="non-leaf" "probe-stack"="inline-asm" "target-cpu"="apple-m1" }
attributes #6 = { cold minsize noinline noreturn nounwind optsize uwtable "frame-pointer"="non-leaf" "probe-stack"="inline-asm" "target-cpu"="apple-m1" }
attributes #7 = { "frame-pointer"="non-leaf" "target-cpu"="apple-m1" }
attributes #8 = { noreturn }
attributes #9 = { cold }
attributes #10 = { cold noreturn nounwind }

!llvm.module.flags = !{!48, !49, !50, !51}
!llvm.ident = !{!52}
!llvm.dbg.cu = !{!53}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "<std::rt::lang_start::{closure_env#0}<()> as core::ops::function::Fn<()>>::{vtable}", scope: null, file: !2, type: !3, isLocal: true, isDefinition: true)
!2 = !DIFile(filename: "<unknown>", directory: "")
!3 = !DICompositeType(tag: DW_TAG_structure_type, name: "<std::rt::lang_start::{closure_env#0}<()> as core::ops::function::Fn<()>>::{vtable_type}", file: !2, size: 384, align: 64, flags: DIFlagArtificial, elements: !4, vtableHolder: !14, templateParams: !23, identifier: "66b0c2e9a6a04752d656cd13e8d96781")
!4 = !{!5, !8, !10, !11, !12, !13}
!5 = !DIDerivedType(tag: DW_TAG_member, name: "drop_in_place", scope: !3, file: !2, baseType: !6, size: 64, align: 64)
!6 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*const ()", baseType: !7, size: 64, align: 64, dwarfAddressSpace: 0)
!7 = !DIBasicType(name: "()", encoding: DW_ATE_unsigned)
!8 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !3, file: !2, baseType: !9, size: 64, align: 64, offset: 64)
!9 = !DIBasicType(name: "usize", size: 64, encoding: DW_ATE_unsigned)
!10 = !DIDerivedType(tag: DW_TAG_member, name: "align", scope: !3, file: !2, baseType: !9, size: 64, align: 64, offset: 128)
!11 = !DIDerivedType(tag: DW_TAG_member, name: "__method3", scope: !3, file: !2, baseType: !6, size: 64, align: 64, offset: 192)
!12 = !DIDerivedType(tag: DW_TAG_member, name: "__method4", scope: !3, file: !2, baseType: !6, size: 64, align: 64, offset: 256)
!13 = !DIDerivedType(tag: DW_TAG_member, name: "__method5", scope: !3, file: !2, baseType: !6, size: 64, align: 64, offset: 320)
!14 = !DICompositeType(tag: DW_TAG_structure_type, name: "{closure_env#0}<()>", scope: !15, file: !2, size: 64, align: 64, elements: !18, templateParams: !23, identifier: "2167dfa41cc870f64e2952629535c392")
!15 = !DINamespace(name: "lang_start", scope: !16)
!16 = !DINamespace(name: "rt", scope: !17)
!17 = !DINamespace(name: "std", scope: null)
!18 = !{!19}
!19 = !DIDerivedType(tag: DW_TAG_member, name: "main", scope: !14, file: !2, baseType: !20, size: 64, align: 64)
!20 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "fn()", baseType: !21, size: 64, align: 64, dwarfAddressSpace: 0)
!21 = !DISubroutineType(types: !22)
!22 = !{null}
!23 = !{}
!24 = !DIGlobalVariableExpression(var: !25, expr: !DIExpression())
!25 = distinct !DIGlobalVariable(name: "VT", linkageName: "_ZN7complex2VT17h8693aa46dd739d92E", scope: !26, file: !27, line: 45, type: !28, isLocal: true, isDefinition: true, align: 64)
!26 = !DINamespace(name: "complex", scope: null)
!27 = !DIFile(filename: "complex.rs", directory: "/Users/sanjib/codes/apace_lab/soap_afg_2026/repositories/AFG/afg_prototype/experiments/async-complex-demo", checksumkind: CSK_MD5, checksum: "30265d8269918e3f56ca2c2155cdc54a")
!28 = !DICompositeType(tag: DW_TAG_structure_type, name: "RawWakerVTable", scope: !29, file: !2, size: 256, align: 64, flags: DIFlagPublic, elements: !32, templateParams: !23, identifier: "c5f7e2a630b45c8b5a53ef30db6a99a6")
!29 = !DINamespace(name: "wake", scope: !30)
!30 = !DINamespace(name: "task", scope: !31)
!31 = !DINamespace(name: "core", scope: null)
!32 = !{!33, !42, !46, !47}
!33 = !DIDerivedType(tag: DW_TAG_member, name: "clone", scope: !28, file: !2, baseType: !34, size: 64, align: 64, flags: DIFlagPrivate)
!34 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "unsafe fn(*const ()) -> core::task::wake::RawWaker", baseType: !35, size: 64, align: 64, dwarfAddressSpace: 0)
!35 = !DISubroutineType(types: !36)
!36 = !{!37, !6}
!37 = !DICompositeType(tag: DW_TAG_structure_type, name: "RawWaker", scope: !29, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !38, templateParams: !23, identifier: "7c7121cf967aff50e7393a305db99833")
!38 = !{!39, !40}
!39 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !37, file: !2, baseType: !6, size: 64, align: 64, offset: 64, flags: DIFlagPrivate)
!40 = !DIDerivedType(tag: DW_TAG_member, name: "vtable", scope: !37, file: !2, baseType: !41, size: 64, align: 64, flags: DIFlagPrivate)
!41 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&core::task::wake::RawWakerVTable", baseType: !28, size: 64, align: 64, dwarfAddressSpace: 0)
!42 = !DIDerivedType(tag: DW_TAG_member, name: "wake", scope: !28, file: !2, baseType: !43, size: 64, align: 64, offset: 64, flags: DIFlagPrivate)
!43 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "unsafe fn(*const ())", baseType: !44, size: 64, align: 64, dwarfAddressSpace: 0)
!44 = !DISubroutineType(types: !45)
!45 = !{null, !6}
!46 = !DIDerivedType(tag: DW_TAG_member, name: "wake_by_ref", scope: !28, file: !2, baseType: !43, size: 64, align: 64, offset: 128, flags: DIFlagPrivate)
!47 = !DIDerivedType(tag: DW_TAG_member, name: "drop", scope: !28, file: !2, baseType: !43, size: 64, align: 64, offset: 192, flags: DIFlagPrivate)
!48 = !{i32 8, !"PIC Level", i32 2}
!49 = !{i32 7, !"PIE Level", i32 2}
!50 = !{i32 7, !"Dwarf Version", i32 4}
!51 = !{i32 2, !"Debug Info Version", i32 3}
!52 = !{!"rustc version 1.86.0 (05f9846f8 2025-03-31)"}
!53 = distinct !DICompileUnit(language: DW_LANG_Rust, file: !54, producer: "clang LLVM (rustc version 1.86.0 (05f9846f8 2025-03-31))", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !55, globals: !67, splitDebugInlining: false, nameTableKind: None)
!54 = !DIFile(filename: "complex.rs/@/complex.5787706881bbd3ee-cgu.0", directory: "/Users/sanjib/codes/apace_lab/soap_afg_2026/repositories/AFG/afg_prototype/experiments/async-complex-demo")
!55 = !{!56, !63}
!56 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "Alignment", scope: !57, file: !2, baseType: !58, size: 8, align: 8, flags: DIFlagEnumClass, elements: !59)
!57 = !DINamespace(name: "fmt", scope: !31)
!58 = !DIBasicType(name: "u8", size: 8, encoding: DW_ATE_unsigned)
!59 = !{!60, !61, !62}
!60 = !DIEnumerator(name: "Left", value: 0, isUnsigned: true)
!61 = !DIEnumerator(name: "Right", value: 1, isUnsigned: true)
!62 = !DIEnumerator(name: "Center", value: 2, isUnsigned: true)
!63 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "Alignment", scope: !64, file: !2, baseType: !58, size: 8, align: 8, flags: DIFlagEnumClass, elements: !65)
!64 = !DINamespace(name: "rt", scope: !57)
!65 = !{!60, !61, !62, !66}
!66 = !DIEnumerator(name: "Unknown", value: 3, isUnsigned: true)
!67 = !{!0, !24}
!68 = distinct !DISubprogram(name: "lang_start<()>", linkageName: "_ZN3std2rt10lang_start17hfbc1424e326a51c8E", scope: !16, file: !69, line: 192, type: !70, scopeLine: 192, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !80, retainedNodes: !75)
!69 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/std/src/rt.rs", directory: "", checksumkind: CSK_MD5, checksum: "5ed61ab28987f8860d5842313c6741b3")
!70 = !DISubroutineType(types: !71)
!71 = !{!72, !20, !72, !73, !58}
!72 = !DIBasicType(name: "isize", size: 64, encoding: DW_ATE_signed)
!73 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*const *const u8", baseType: !74, size: 64, align: 64, dwarfAddressSpace: 0)
!74 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*const u8", baseType: !58, size: 64, align: 64, dwarfAddressSpace: 0)
!75 = !{!76, !77, !78, !79}
!76 = !DILocalVariable(name: "main", arg: 1, scope: !68, file: !69, line: 193, type: !20)
!77 = !DILocalVariable(name: "argc", arg: 2, scope: !68, file: !69, line: 194, type: !72)
!78 = !DILocalVariable(name: "argv", arg: 3, scope: !68, file: !69, line: 195, type: !73)
!79 = !DILocalVariable(name: "sigpipe", arg: 4, scope: !68, file: !69, line: 196, type: !58)
!80 = !{!81}
!81 = !DITemplateTypeParameter(name: "T", type: !7)
!82 = !DILocation(line: 193, column: 5, scope: !68)
!83 = !DILocation(line: 194, column: 5, scope: !68)
!84 = !DILocation(line: 195, column: 5, scope: !68)
!85 = !DILocation(line: 196, column: 5, scope: !68)
!86 = !DILocation(line: 199, column: 10, scope: !68)
!87 = !DILocation(line: 198, column: 5, scope: !68)
!88 = !DILocation(line: 204, column: 2, scope: !68)
!89 = distinct !DISubprogram(name: "{closure#0}<()>", linkageName: "_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h3f5d7f0eec85a035E", scope: !15, file: !69, line: 199, type: !90, scopeLine: 199, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !80, retainedNodes: !94)
!90 = !DISubroutineType(types: !91)
!91 = !{!92, !93}
!92 = !DIBasicType(name: "i32", size: 32, encoding: DW_ATE_signed)
!93 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&std::rt::lang_start::{closure_env#0}<()>", baseType: !14, size: 64, align: 64, dwarfAddressSpace: 0)
!94 = !{!95}
!95 = !DILocalVariable(name: "main", scope: !89, file: !69, line: 193, type: !20, align: 64)
!96 = !DILocation(line: 193, column: 5, scope: !89)
!97 = !DILocation(line: 199, column: 70, scope: !89)
!98 = !DILocation(line: 199, column: 18, scope: !89)
!99 = !DILocalVariable(name: "self", arg: 1, scope: !100, file: !101, line: 2060, type: !102)
!100 = distinct !DISubprogram(name: "to_i32", linkageName: "_ZN3std7process8ExitCode6to_i3217h9f651cf1eeabb156E", scope: !102, file: !101, line: 2060, type: !114, scopeLine: 2060, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, declaration: !116, retainedNodes: !117)
!101 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/std/src/process.rs", directory: "", checksumkind: CSK_MD5, checksum: "09b44bf6e4bf5afa11f0c8ce942ef3a7")
!102 = !DICompositeType(tag: DW_TAG_structure_type, name: "ExitCode", scope: !103, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !104, templateParams: !23, identifier: "341afe2df648aa4bace9fb75ede0934e")
!103 = !DINamespace(name: "process", scope: !17)
!104 = !{!105}
!105 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !102, file: !2, baseType: !106, size: 8, align: 8, flags: DIFlagPrivate)
!106 = !DICompositeType(tag: DW_TAG_structure_type, name: "ExitCode", scope: !107, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !112, templateParams: !23, identifier: "93d9edbbd2a7a81ad68d79f01998a178")
!107 = !DINamespace(name: "process_common", scope: !108)
!108 = !DINamespace(name: "process", scope: !109)
!109 = !DINamespace(name: "unix", scope: !110)
!110 = !DINamespace(name: "pal", scope: !111)
!111 = !DINamespace(name: "sys", scope: !17)
!112 = !{!113}
!113 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !106, file: !2, baseType: !58, size: 8, align: 8, flags: DIFlagPrivate)
!114 = !DISubroutineType(types: !115)
!115 = !{!92, !102}
!116 = !DISubprogram(name: "to_i32", linkageName: "_ZN3std7process8ExitCode6to_i3217h9f651cf1eeabb156E", scope: !102, file: !101, line: 2060, type: !114, scopeLine: 2060, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!117 = !{!99}
!118 = !DILocation(line: 2060, column: 19, scope: !100, inlinedAt: !119)
!119 = !DILocation(line: 199, column: 85, scope: !89)
!120 = !DILocation(line: 636, column: 9, scope: !121, inlinedAt: !127)
!121 = distinct !DISubprogram(name: "as_i32", linkageName: "_ZN3std3sys3pal4unix7process14process_common8ExitCode6as_i3217hcebfbfd9d61f39faE", scope: !106, file: !122, line: 635, type: !123, scopeLine: 635, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, declaration: !126)
!122 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/std/src/sys/pal/unix/process/process_common.rs", directory: "", checksumkind: CSK_MD5, checksum: "7107dec5baaefd58adc486b058fd5a71")
!123 = !DISubroutineType(types: !124)
!124 = !{!92, !125}
!125 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&std::sys::pal::unix::process::process_common::ExitCode", baseType: !106, size: 64, align: 64, dwarfAddressSpace: 0)
!126 = !DISubprogram(name: "as_i32", linkageName: "_ZN3std3sys3pal4unix7process14process_common8ExitCode6as_i3217hcebfbfd9d61f39faE", scope: !106, file: !122, line: 635, type: !123, scopeLine: 635, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!127 = !DILocation(line: 2061, column: 16, scope: !100, inlinedAt: !119)
!128 = !DILocation(line: 199, column: 93, scope: !89)
!129 = distinct !DISubprogram(name: "__rust_begin_short_backtrace<fn(), ()>", linkageName: "_ZN3std3sys9backtrace28__rust_begin_short_backtrace17h94d90f6d595e5bf6E", scope: !131, file: !130, line: 148, type: !132, scopeLine: 148, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !138, retainedNodes: !134)
!130 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/std/src/sys/backtrace.rs", directory: "", checksumkind: CSK_MD5, checksum: "9e30c70624c3cf40238860e740bd696f")
!131 = !DINamespace(name: "backtrace", scope: !111)
!132 = !DISubroutineType(types: !133)
!133 = !{null, !20}
!134 = !{!135, !136}
!135 = !DILocalVariable(name: "f", arg: 1, scope: !129, file: !130, line: 148, type: !20)
!136 = !DILocalVariable(name: "result", scope: !137, file: !130, line: 152, type: !7, align: 8)
!137 = distinct !DILexicalBlock(scope: !129, file: !130, line: 152, column: 5)
!138 = !{!139, !81}
!139 = !DITemplateTypeParameter(name: "F", type: !20)
!140 = !DILocation(line: 152, column: 9, scope: !137)
!141 = !DILocation(line: 148, column: 43, scope: !129)
!142 = !DILocalVariable(name: "dummy", scope: !143, file: !144, line: 476, type: !7, align: 8)
!143 = distinct !DISubprogram(name: "black_box<()>", linkageName: "_ZN4core4hint9black_box17had7debecf997a372E", scope: !145, file: !144, line: 476, type: !146, scopeLine: 476, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !80, retainedNodes: !148)
!144 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/hint.rs", directory: "", checksumkind: CSK_MD5, checksum: "4d6fc217f737459a7201759c6559d6c1")
!145 = !DINamespace(name: "hint", scope: !31)
!146 = !DISubroutineType(types: !147)
!147 = !{null, !7}
!148 = !{!142}
!149 = !DILocation(line: 476, column: 27, scope: !143, inlinedAt: !150)
!150 = !DILocation(line: 155, column: 5, scope: !137)
!151 = !DILocation(line: 152, column: 18, scope: !129)
!152 = !DILocation(line: 477, column: 5, scope: !143, inlinedAt: !150)
!153 = !{i64 5278639362064578}
!154 = !DILocation(line: 158, column: 2, scope: !129)
!155 = distinct !DISubprogram(name: "new_display<u64>", linkageName: "_ZN4core3fmt2rt8Argument11new_display17hbbb6afbe72c84d49E", scope: !157, file: !156, line: 113, type: !257, scopeLine: 113, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !261, declaration: !260, retainedNodes: !263)
!156 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/fmt/rt.rs", directory: "", checksumkind: CSK_MD5, checksum: "03cc435a170c7724e037ef722264e101")
!157 = !DICompositeType(tag: DW_TAG_structure_type, name: "Argument", scope: !64, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !158, templateParams: !23, identifier: "a664b527b69c03545f8bc05bdc2a7f06")
!158 = !{!159}
!159 = !DIDerivedType(tag: DW_TAG_member, name: "ty", scope: !157, file: !2, baseType: !160, size: 128, align: 64, flags: DIFlagPrivate)
!160 = !DICompositeType(tag: DW_TAG_structure_type, name: "ArgumentType", scope: !64, file: !2, size: 128, align: 64, flags: DIFlagPrivate, elements: !161, templateParams: !23, identifier: "6251445db8f9510fd4be5cc1b840f8f4")
!161 = !{!162}
!162 = !DICompositeType(tag: DW_TAG_variant_part, scope: !160, file: !2, size: 128, align: 64, elements: !163, templateParams: !23, identifier: "5c92422e0be9a7b32f4f7de4ef9137d2", discriminator: !256)
!163 = !{!164, !252}
!164 = !DIDerivedType(tag: DW_TAG_member, name: "Placeholder", scope: !162, file: !2, baseType: !165, size: 128, align: 64)
!165 = !DICompositeType(tag: DW_TAG_structure_type, name: "Placeholder", scope: !160, file: !2, size: 128, align: 64, flags: DIFlagPrivate, elements: !166, templateParams: !23, identifier: "20e6221e04bdfd7d1fcb39a3790c6e33")
!166 = !{!167, !173, !246}
!167 = !DIDerivedType(tag: DW_TAG_member, name: "value", scope: !165, file: !2, baseType: !168, size: 64, align: 64, flags: DIFlagPrivate)
!168 = !DICompositeType(tag: DW_TAG_structure_type, name: "NonNull<()>", scope: !169, file: !2, size: 64, align: 64, flags: DIFlagPublic, elements: !171, templateParams: !80, identifier: "cf5c1ba45dbb550b74727209a45e522f")
!169 = !DINamespace(name: "non_null", scope: !170)
!170 = !DINamespace(name: "ptr", scope: !31)
!171 = !{!172}
!172 = !DIDerivedType(tag: DW_TAG_member, name: "pointer", scope: !168, file: !2, baseType: !6, size: 64, align: 64, flags: DIFlagPrivate)
!173 = !DIDerivedType(tag: DW_TAG_member, name: "formatter", scope: !165, file: !2, baseType: !174, size: 64, align: 64, offset: 64, flags: DIFlagPrivate)
!174 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "unsafe fn(core::ptr::non_null::NonNull<()>, &mut core::fmt::Formatter) -> core::result::Result<(), core::fmt::Error>", baseType: !175, size: 64, align: 64, dwarfAddressSpace: 0)
!175 = !DISubroutineType(types: !176)
!176 = !{!177, !168, !194}
!177 = !DICompositeType(tag: DW_TAG_structure_type, name: "Result<(), core::fmt::Error>", scope: !178, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !179, templateParams: !23, identifier: "c5a7ad530f7adf62d2fecbcc7362b6f7")
!178 = !DINamespace(name: "result", scope: !31)
!179 = !{!180}
!180 = !DICompositeType(tag: DW_TAG_variant_part, scope: !177, file: !2, size: 8, align: 8, elements: !181, templateParams: !23, identifier: "ac779e5943fbf99477fa03a0b0bc4e54", discriminator: !193)
!181 = !{!182, !189}
!182 = !DIDerivedType(tag: DW_TAG_member, name: "Ok", scope: !180, file: !2, baseType: !183, size: 8, align: 8, extraData: i8 0)
!183 = !DICompositeType(tag: DW_TAG_structure_type, name: "Ok", scope: !177, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !184, templateParams: !186, identifier: "97f51036cf4af0b1e783eb2f4e594c6")
!184 = !{!185}
!185 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !183, file: !2, baseType: !7, align: 8, offset: 8, flags: DIFlagPublic)
!186 = !{!81, !187}
!187 = !DITemplateTypeParameter(name: "E", type: !188)
!188 = !DICompositeType(tag: DW_TAG_structure_type, name: "Error", scope: !57, file: !2, align: 8, flags: DIFlagPublic, elements: !23, identifier: "20e3adf778d4de669c6748e62a470a70")
!189 = !DIDerivedType(tag: DW_TAG_member, name: "Err", scope: !180, file: !2, baseType: !190, size: 8, align: 8, extraData: i8 1)
!190 = !DICompositeType(tag: DW_TAG_structure_type, name: "Err", scope: !177, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !191, templateParams: !186, identifier: "41728e5f243f1d8b9681f4bd5ba681de")
!191 = !{!192}
!192 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !190, file: !2, baseType: !188, align: 8, offset: 8, flags: DIFlagPublic)
!193 = !DIDerivedType(tag: DW_TAG_member, scope: !177, file: !2, baseType: !58, size: 8, align: 8, flags: DIFlagArtificial)
!194 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut core::fmt::Formatter", baseType: !195, size: 64, align: 64, dwarfAddressSpace: 0)
!195 = !DICompositeType(tag: DW_TAG_structure_type, name: "Formatter", scope: !57, file: !2, size: 512, align: 64, flags: DIFlagPublic, elements: !196, templateParams: !23, identifier: "52755d1a359ac843f3ec4fcaa35d3f")
!196 = !{!197, !235}
!197 = !DIDerivedType(tag: DW_TAG_member, name: "options", scope: !195, file: !2, baseType: !198, size: 384, align: 64, flags: DIFlagPrivate)
!198 = !DICompositeType(tag: DW_TAG_structure_type, name: "FormattingOptions", scope: !57, file: !2, size: 384, align: 64, flags: DIFlagPublic, elements: !199, templateParams: !23, identifier: "7dbfe1d703871c54b07bd54d02647d8")
!199 = !{!200, !202, !204, !219, !234}
!200 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !198, file: !2, baseType: !201, size: 32, align: 32, offset: 288, flags: DIFlagPrivate)
!201 = !DIBasicType(name: "u32", size: 32, encoding: DW_ATE_unsigned)
!202 = !DIDerivedType(tag: DW_TAG_member, name: "fill", scope: !198, file: !2, baseType: !203, size: 32, align: 32, offset: 256, flags: DIFlagPrivate)
!203 = !DIBasicType(name: "char", size: 32, encoding: DW_ATE_UTF)
!204 = !DIDerivedType(tag: DW_TAG_member, name: "align", scope: !198, file: !2, baseType: !205, size: 8, align: 8, offset: 320, flags: DIFlagPrivate)
!205 = !DICompositeType(tag: DW_TAG_structure_type, name: "Option<core::fmt::Alignment>", scope: !206, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !207, templateParams: !23, identifier: "187967e034abadf554783ea9627f2c4c")
!206 = !DINamespace(name: "option", scope: !31)
!207 = !{!208}
!208 = !DICompositeType(tag: DW_TAG_variant_part, scope: !205, file: !2, size: 8, align: 8, elements: !209, templateParams: !23, identifier: "cb055755af32967a2c89ea484bc45b19", discriminator: !218)
!209 = !{!210, !214}
!210 = !DIDerivedType(tag: DW_TAG_member, name: "None", scope: !208, file: !2, baseType: !211, size: 8, align: 8, extraData: i8 3)
!211 = !DICompositeType(tag: DW_TAG_structure_type, name: "None", scope: !205, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !23, templateParams: !212, identifier: "d4d2ab0f9d5d0342724ccea6249b16cd")
!212 = !{!213}
!213 = !DITemplateTypeParameter(name: "T", type: !56)
!214 = !DIDerivedType(tag: DW_TAG_member, name: "Some", scope: !208, file: !2, baseType: !215, size: 8, align: 8)
!215 = !DICompositeType(tag: DW_TAG_structure_type, name: "Some", scope: !205, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !216, templateParams: !212, identifier: "4457b62b678dcd564d38c3283bcd3c06")
!216 = !{!217}
!217 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !215, file: !2, baseType: !56, size: 8, align: 8, flags: DIFlagPublic)
!218 = !DIDerivedType(tag: DW_TAG_member, scope: !205, file: !2, baseType: !58, size: 8, align: 8, flags: DIFlagArtificial)
!219 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !198, file: !2, baseType: !220, size: 128, align: 64, flags: DIFlagPrivate)
!220 = !DICompositeType(tag: DW_TAG_structure_type, name: "Option<usize>", scope: !206, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !221, templateParams: !23, identifier: "8045954f929eb45a5528fd8a14b4f02d")
!221 = !{!222}
!222 = !DICompositeType(tag: DW_TAG_variant_part, scope: !220, file: !2, size: 128, align: 64, elements: !223, templateParams: !23, identifier: "2fdae1f8d2eb65dff6da1604f1815b04", discriminator: !232)
!223 = !{!224, !228}
!224 = !DIDerivedType(tag: DW_TAG_member, name: "None", scope: !222, file: !2, baseType: !225, size: 128, align: 64, extraData: i64 0)
!225 = !DICompositeType(tag: DW_TAG_structure_type, name: "None", scope: !220, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !23, templateParams: !226, identifier: "5e26e76789ea6e1bf656dfc0884a24bd")
!226 = !{!227}
!227 = !DITemplateTypeParameter(name: "T", type: !9)
!228 = !DIDerivedType(tag: DW_TAG_member, name: "Some", scope: !222, file: !2, baseType: !229, size: 128, align: 64, extraData: i64 1)
!229 = !DICompositeType(tag: DW_TAG_structure_type, name: "Some", scope: !220, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !230, templateParams: !226, identifier: "f4e093de6b7b2d9cbf46b7d59706431")
!230 = !{!231}
!231 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !229, file: !2, baseType: !9, size: 64, align: 64, offset: 64, flags: DIFlagPublic)
!232 = !DIDerivedType(tag: DW_TAG_member, scope: !220, file: !2, baseType: !233, size: 64, align: 64, flags: DIFlagArtificial)
!233 = !DIBasicType(name: "u64", size: 64, encoding: DW_ATE_unsigned)
!234 = !DIDerivedType(tag: DW_TAG_member, name: "precision", scope: !198, file: !2, baseType: !220, size: 128, align: 64, offset: 128, flags: DIFlagPrivate)
!235 = !DIDerivedType(tag: DW_TAG_member, name: "buf", scope: !195, file: !2, baseType: !236, size: 128, align: 64, offset: 384, flags: DIFlagPrivate)
!236 = !DICompositeType(tag: DW_TAG_structure_type, name: "&mut dyn core::fmt::Write", file: !2, size: 128, align: 64, elements: !237, templateParams: !23, identifier: "98297a6fbd62117e7da99e38e823d6ab")
!237 = !{!238, !241}
!238 = !DIDerivedType(tag: DW_TAG_member, name: "pointer", scope: !236, file: !2, baseType: !239, size: 64, align: 64)
!239 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !240, size: 64, align: 64, dwarfAddressSpace: 0)
!240 = !DICompositeType(tag: DW_TAG_structure_type, name: "dyn core::fmt::Write", file: !2, align: 8, elements: !23, identifier: "21d5e048ae7c921567058459068d0b4d")
!241 = !DIDerivedType(tag: DW_TAG_member, name: "vtable", scope: !236, file: !2, baseType: !242, size: 64, align: 64, offset: 64)
!242 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&[usize; 6]", baseType: !243, size: 64, align: 64, dwarfAddressSpace: 0)
!243 = !DICompositeType(tag: DW_TAG_array_type, baseType: !9, size: 384, align: 64, elements: !244)
!244 = !{!245}
!245 = !DISubrange(count: 6, lowerBound: 0)
!246 = !DIDerivedType(tag: DW_TAG_member, name: "_lifetime", scope: !165, file: !2, baseType: !247, align: 8, offset: 128, flags: DIFlagPrivate)
!247 = !DICompositeType(tag: DW_TAG_structure_type, name: "PhantomData<&()>", scope: !248, file: !2, align: 8, flags: DIFlagPublic, elements: !23, templateParams: !249, identifier: "f7ebfa6b21c1c02d5aa8b8770d0b11ef")
!248 = !DINamespace(name: "marker", scope: !31)
!249 = !{!250}
!250 = !DITemplateTypeParameter(name: "T", type: !251)
!251 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&()", baseType: !7, size: 64, align: 64, dwarfAddressSpace: 0)
!252 = !DIDerivedType(tag: DW_TAG_member, name: "Count", scope: !162, file: !2, baseType: !253, size: 128, align: 64, extraData: i64 0)
!253 = !DICompositeType(tag: DW_TAG_structure_type, name: "Count", scope: !160, file: !2, size: 128, align: 64, flags: DIFlagPrivate, elements: !254, templateParams: !23, identifier: "f6a8f247f1ab86955db6fdbdb79b3fa7")
!254 = !{!255}
!255 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !253, file: !2, baseType: !9, size: 64, align: 64, offset: 64, flags: DIFlagPrivate)
!256 = !DIDerivedType(tag: DW_TAG_member, scope: !160, file: !2, baseType: !233, size: 64, align: 64, flags: DIFlagArtificial)
!257 = !DISubroutineType(types: !258)
!258 = !{!157, !259}
!259 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&u64", baseType: !233, size: 64, align: 64, dwarfAddressSpace: 0)
!260 = !DISubprogram(name: "new_display<u64>", linkageName: "_ZN4core3fmt2rt8Argument11new_display17hbbb6afbe72c84d49E", scope: !157, file: !156, line: 113, type: !257, scopeLine: 113, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !261)
!261 = !{!262}
!262 = !DITemplateTypeParameter(name: "T", type: !233)
!263 = !{!264}
!264 = !DILocalVariable(name: "x", arg: 1, scope: !155, file: !156, line: 113, type: !259)
!265 = !DILocation(line: 113, column: 36, scope: !155)
!266 = !DILocalVariable(name: "x", arg: 1, scope: !267, file: !156, line: 99, type: !259)
!267 = distinct !DISubprogram(name: "new<u64>", linkageName: "_ZN4core3fmt2rt8Argument3new17h47d892a2dc960199E", scope: !157, file: !156, line: 99, type: !268, scopeLine: 99, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !261, declaration: !273, retainedNodes: !274)
!268 = !DISubroutineType(types: !269)
!269 = !{!157, !259, !270}
!270 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "fn(&u64, &mut core::fmt::Formatter) -> core::result::Result<(), core::fmt::Error>", baseType: !271, size: 64, align: 64, dwarfAddressSpace: 0)
!271 = !DISubroutineType(types: !272)
!272 = !{!177, !259, !194}
!273 = !DISubprogram(name: "new<u64>", linkageName: "_ZN4core3fmt2rt8Argument3new17h47d892a2dc960199E", scope: !157, file: !156, line: 99, type: !268, scopeLine: 99, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !261)
!274 = !{!266}
!275 = !DILocation(line: 99, column: 25, scope: !267, inlinedAt: !276)
!276 = !DILocation(line: 114, column: 9, scope: !155)
!277 = !DILocalVariable(name: "r", arg: 1, scope: !278, file: !279, line: 268, type: !259)
!278 = distinct !DISubprogram(name: "from_ref<u64>", linkageName: "_ZN4core3ptr8non_null16NonNull$LT$T$GT$8from_ref17he384c5a4d3ba7fb5E", scope: !280, file: !279, line: 268, type: !284, scopeLine: 268, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !261, declaration: !286, retainedNodes: !287)
!279 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/ptr/non_null.rs", directory: "", checksumkind: CSK_MD5, checksum: "f45049b8fe718e09b04e14006dd7e8d3")
!280 = !DICompositeType(tag: DW_TAG_structure_type, name: "NonNull<u64>", scope: !169, file: !2, size: 64, align: 64, flags: DIFlagPublic, elements: !281, templateParams: !261, identifier: "f0315fbb7066bb2768a6e4ebf06aee69")
!281 = !{!282}
!282 = !DIDerivedType(tag: DW_TAG_member, name: "pointer", scope: !280, file: !2, baseType: !283, size: 64, align: 64, flags: DIFlagPrivate)
!283 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*const u64", baseType: !233, size: 64, align: 64, dwarfAddressSpace: 0)
!284 = !DISubroutineType(types: !285)
!285 = !{!280, !259}
!286 = !DISubprogram(name: "from_ref<u64>", linkageName: "_ZN4core3ptr8non_null16NonNull$LT$T$GT$8from_ref17he384c5a4d3ba7fb5E", scope: !280, file: !279, line: 268, type: !284, scopeLine: 268, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !261)
!287 = !{!277}
!288 = !DILocation(line: 268, column: 27, scope: !278, inlinedAt: !289)
!289 = !DILocation(line: 104, column: 24, scope: !267, inlinedAt: !276)
!290 = !DILocation(line: 103, column: 17, scope: !267, inlinedAt: !276)
!291 = !DILocation(line: 100, column: 9, scope: !267, inlinedAt: !276)
!292 = !DILocation(line: 115, column: 6, scope: !155)
!293 = distinct !DISubprogram(name: "new_v1<2, 1>", linkageName: "_ZN4core3fmt9Arguments6new_v117h152d81e9b06b0e25E", scope: !295, file: !294, line: 608, type: !356, scopeLine: 608, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, declaration: !366, retainedNodes: !367)
!294 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/fmt/mod.rs", directory: "", checksumkind: CSK_MD5, checksum: "622ef1b3b6e3beca6d52f42f40384739")
!295 = !DICompositeType(tag: DW_TAG_structure_type, name: "Arguments", scope: !57, file: !2, size: 384, align: 64, flags: DIFlagPublic, elements: !296, templateParams: !23, identifier: "dddafec8d5877f1396e365b41f9d97e0")
!296 = !{!297, !308, !350}
!297 = !DIDerivedType(tag: DW_TAG_member, name: "pieces", scope: !295, file: !2, baseType: !298, size: 128, align: 64, flags: DIFlagPrivate)
!298 = !DICompositeType(tag: DW_TAG_structure_type, name: "&[&str]", file: !2, size: 128, align: 64, elements: !299, templateParams: !23, identifier: "4e66b00a376d6af5b8765440fb2839f")
!299 = !{!300, !307}
!300 = !DIDerivedType(tag: DW_TAG_member, name: "data_ptr", scope: !298, file: !2, baseType: !301, size: 64, align: 64)
!301 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !302, size: 64, align: 64, dwarfAddressSpace: 0)
!302 = !DICompositeType(tag: DW_TAG_structure_type, name: "&str", file: !2, size: 128, align: 64, elements: !303, templateParams: !23, identifier: "9277eecd40495f85161460476aacc992")
!303 = !{!304, !306}
!304 = !DIDerivedType(tag: DW_TAG_member, name: "data_ptr", scope: !302, file: !2, baseType: !305, size: 64, align: 64)
!305 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !58, size: 64, align: 64, dwarfAddressSpace: 0)
!306 = !DIDerivedType(tag: DW_TAG_member, name: "length", scope: !302, file: !2, baseType: !9, size: 64, align: 64, offset: 64)
!307 = !DIDerivedType(tag: DW_TAG_member, name: "length", scope: !298, file: !2, baseType: !9, size: 64, align: 64, offset: 64)
!308 = !DIDerivedType(tag: DW_TAG_member, name: "fmt", scope: !295, file: !2, baseType: !309, size: 128, align: 64, offset: 256, flags: DIFlagPrivate)
!309 = !DICompositeType(tag: DW_TAG_structure_type, name: "Option<&[core::fmt::rt::Placeholder]>", scope: !206, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !310, templateParams: !23, identifier: "1e413fbc1716d1313bc5a6473de47705")
!310 = !{!311}
!311 = !DICompositeType(tag: DW_TAG_variant_part, scope: !309, file: !2, size: 128, align: 64, elements: !312, templateParams: !23, identifier: "9f08d569bfdf661b7c43becc63b66f17", discriminator: !349)
!312 = !{!313, !345}
!313 = !DIDerivedType(tag: DW_TAG_member, name: "None", scope: !311, file: !2, baseType: !314, size: 128, align: 64, extraData: i64 0)
!314 = !DICompositeType(tag: DW_TAG_structure_type, name: "None", scope: !309, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !23, templateParams: !315, identifier: "51381d817c48247dc57111932f86b1da")
!315 = !{!316}
!316 = !DITemplateTypeParameter(name: "T", type: !317)
!317 = !DICompositeType(tag: DW_TAG_structure_type, name: "&[core::fmt::rt::Placeholder]", file: !2, size: 128, align: 64, elements: !318, templateParams: !23, identifier: "797a5e35b920879820f0bb337aac7839")
!318 = !{!319, !344}
!319 = !DIDerivedType(tag: DW_TAG_member, name: "data_ptr", scope: !317, file: !2, baseType: !320, size: 64, align: 64)
!320 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !321, size: 64, align: 64, dwarfAddressSpace: 0)
!321 = !DICompositeType(tag: DW_TAG_structure_type, name: "Placeholder", scope: !64, file: !2, size: 448, align: 64, flags: DIFlagPublic, elements: !322, templateParams: !23, identifier: "9154d1af9bcc2ef75e3aff1bc2fa3dcd")
!322 = !{!323, !324, !325, !326, !327, !343}
!323 = !DIDerivedType(tag: DW_TAG_member, name: "position", scope: !321, file: !2, baseType: !9, size: 64, align: 64, offset: 256, flags: DIFlagPublic)
!324 = !DIDerivedType(tag: DW_TAG_member, name: "fill", scope: !321, file: !2, baseType: !203, size: 32, align: 32, offset: 320, flags: DIFlagPublic)
!325 = !DIDerivedType(tag: DW_TAG_member, name: "align", scope: !321, file: !2, baseType: !63, size: 8, align: 8, offset: 384, flags: DIFlagPublic)
!326 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !321, file: !2, baseType: !201, size: 32, align: 32, offset: 352, flags: DIFlagPublic)
!327 = !DIDerivedType(tag: DW_TAG_member, name: "precision", scope: !321, file: !2, baseType: !328, size: 128, align: 64, flags: DIFlagPublic)
!328 = !DICompositeType(tag: DW_TAG_structure_type, name: "Count", scope: !64, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !329, templateParams: !23, identifier: "e26a82e73433e407a87f263dd77def32")
!329 = !{!330}
!330 = !DICompositeType(tag: DW_TAG_variant_part, scope: !328, file: !2, size: 128, align: 64, elements: !331, templateParams: !23, identifier: "77e32cf5833c5f3e6cd3e97392cd8af3", discriminator: !342)
!331 = !{!332, !336, !340}
!332 = !DIDerivedType(tag: DW_TAG_member, name: "Is", scope: !330, file: !2, baseType: !333, size: 128, align: 64, extraData: i64 0)
!333 = !DICompositeType(tag: DW_TAG_structure_type, name: "Is", scope: !328, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !334, templateParams: !23, identifier: "5116bec7d245076f68fc64938e054ffc")
!334 = !{!335}
!335 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !333, file: !2, baseType: !9, size: 64, align: 64, offset: 64, flags: DIFlagPublic)
!336 = !DIDerivedType(tag: DW_TAG_member, name: "Param", scope: !330, file: !2, baseType: !337, size: 128, align: 64, extraData: i64 1)
!337 = !DICompositeType(tag: DW_TAG_structure_type, name: "Param", scope: !328, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !338, templateParams: !23, identifier: "621a25d2838569fdd07983f37e504800")
!338 = !{!339}
!339 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !337, file: !2, baseType: !9, size: 64, align: 64, offset: 64, flags: DIFlagPublic)
!340 = !DIDerivedType(tag: DW_TAG_member, name: "Implied", scope: !330, file: !2, baseType: !341, size: 128, align: 64, extraData: i64 2)
!341 = !DICompositeType(tag: DW_TAG_structure_type, name: "Implied", scope: !328, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !23, identifier: "2d4685281a55fa2636628f64f3a88ce7")
!342 = !DIDerivedType(tag: DW_TAG_member, scope: !328, file: !2, baseType: !233, size: 64, align: 64, flags: DIFlagArtificial)
!343 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !321, file: !2, baseType: !328, size: 128, align: 64, offset: 128, flags: DIFlagPublic)
!344 = !DIDerivedType(tag: DW_TAG_member, name: "length", scope: !317, file: !2, baseType: !9, size: 64, align: 64, offset: 64)
!345 = !DIDerivedType(tag: DW_TAG_member, name: "Some", scope: !311, file: !2, baseType: !346, size: 128, align: 64)
!346 = !DICompositeType(tag: DW_TAG_structure_type, name: "Some", scope: !309, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !347, templateParams: !315, identifier: "b9092a96320a352152f63d8bb09d833")
!347 = !{!348}
!348 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !346, file: !2, baseType: !317, size: 128, align: 64, flags: DIFlagPublic)
!349 = !DIDerivedType(tag: DW_TAG_member, scope: !309, file: !2, baseType: !233, size: 64, align: 64, flags: DIFlagArtificial)
!350 = !DIDerivedType(tag: DW_TAG_member, name: "args", scope: !295, file: !2, baseType: !351, size: 128, align: 64, offset: 128, flags: DIFlagPrivate)
!351 = !DICompositeType(tag: DW_TAG_structure_type, name: "&[core::fmt::rt::Argument]", file: !2, size: 128, align: 64, elements: !352, templateParams: !23, identifier: "6334efd1704d5b576a75bbdae36749de")
!352 = !{!353, !355}
!353 = !DIDerivedType(tag: DW_TAG_member, name: "data_ptr", scope: !351, file: !2, baseType: !354, size: 64, align: 64)
!354 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !157, size: 64, align: 64, dwarfAddressSpace: 0)
!355 = !DIDerivedType(tag: DW_TAG_member, name: "length", scope: !351, file: !2, baseType: !9, size: 64, align: 64, offset: 64)
!356 = !DISubroutineType(types: !357)
!357 = !{!295, !358, !362}
!358 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&[&str; 2]", baseType: !359, size: 64, align: 64, dwarfAddressSpace: 0)
!359 = !DICompositeType(tag: DW_TAG_array_type, baseType: !302, size: 256, align: 64, elements: !360)
!360 = !{!361}
!361 = !DISubrange(count: 2, lowerBound: 0)
!362 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&[core::fmt::rt::Argument; 1]", baseType: !363, size: 64, align: 64, dwarfAddressSpace: 0)
!363 = !DICompositeType(tag: DW_TAG_array_type, baseType: !157, size: 128, align: 64, elements: !364)
!364 = !{!365}
!365 = !DISubrange(count: 1, lowerBound: 0)
!366 = !DISubprogram(name: "new_v1<2, 1>", linkageName: "_ZN4core3fmt9Arguments6new_v117h152d81e9b06b0e25E", scope: !295, file: !294, line: 608, type: !356, scopeLine: 608, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!367 = !{!368, !369}
!368 = !DILocalVariable(name: "pieces", arg: 1, scope: !293, file: !294, line: 609, type: !358)
!369 = !DILocalVariable(name: "args", arg: 2, scope: !293, file: !294, line: 610, type: !362)
!370 = !DILocation(line: 609, column: 9, scope: !293)
!371 = !DILocation(line: 610, column: 9, scope: !293)
!372 = !DILocation(line: 613, column: 9, scope: !293)
!373 = !DILocation(line: 614, column: 6, scope: !293)
!374 = distinct !DISubprogram(name: "call_once<std::rt::lang_start::{closure_env#0}<()>, ()>", linkageName: "_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17hf56b569549e9f832E", scope: !376, file: !375, line: 250, type: !379, scopeLine: 250, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !385, retainedNodes: !382)
!375 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/ops/function.rs", directory: "", checksumkind: CSK_MD5, checksum: "27f40bbdeb6cc525c0d0d7cf434d92c4")
!376 = !DINamespace(name: "FnOnce", scope: !377)
!377 = !DINamespace(name: "function", scope: !378)
!378 = !DINamespace(name: "ops", scope: !31)
!379 = !DISubroutineType(types: !380)
!380 = !{!92, !381}
!381 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*mut std::rt::lang_start::{closure_env#0}<()>", baseType: !14, size: 64, align: 64, dwarfAddressSpace: 0)
!382 = !{!383, !384}
!383 = !DILocalVariable(arg: 1, scope: !374, file: !375, line: 250, type: !381)
!384 = !DILocalVariable(arg: 2, scope: !374, file: !375, line: 250, type: !7)
!385 = !{!386, !387}
!386 = !DITemplateTypeParameter(name: "Self", type: !14)
!387 = !DITemplateTypeParameter(name: "Args", type: !7)
!388 = !DILocation(line: 250, column: 5, scope: !374)
!389 = distinct !DISubprogram(name: "call_once<fn(), ()>", linkageName: "_ZN4core3ops8function6FnOnce9call_once17h8bbb0c31bcb96c36E", scope: !376, file: !375, line: 250, type: !132, scopeLine: 250, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !393, retainedNodes: !390)
!390 = !{!391, !392}
!391 = !DILocalVariable(arg: 1, scope: !389, file: !375, line: 250, type: !20)
!392 = !DILocalVariable(arg: 2, scope: !389, file: !375, line: 250, type: !7)
!393 = !{!394, !387}
!394 = !DITemplateTypeParameter(name: "Self", type: !20)
!395 = !DILocation(line: 250, column: 5, scope: !389)
!396 = distinct !DISubprogram(name: "call_once<std::rt::lang_start::{closure_env#0}<()>, ()>", linkageName: "_ZN4core3ops8function6FnOnce9call_once17he45845dfc4b46fd1E", scope: !376, file: !375, line: 250, type: !397, scopeLine: 250, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !385, retainedNodes: !399)
!397 = !DISubroutineType(types: !398)
!398 = !{!92, !14}
!399 = !{!400, !401}
!400 = !DILocalVariable(arg: 1, scope: !396, file: !375, line: 250, type: !14)
!401 = !DILocalVariable(arg: 2, scope: !396, file: !375, line: 250, type: !7)
!402 = !DILocation(line: 250, column: 5, scope: !396)
!403 = distinct !DISubprogram(name: "drop_in_place<core::task::wake::Waker>", linkageName: "_ZN4core3ptr44drop_in_place$LT$core..task..wake..Waker$GT$17ha03ee6b39a1c10a5E", scope: !170, file: !404, line: 523, type: !405, scopeLine: 523, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !413, retainedNodes: !411)
!404 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/ptr/mod.rs", directory: "", checksumkind: CSK_MD5, checksum: "e9c4ba6bc13274cb82fe40874c88ba3f")
!405 = !DISubroutineType(types: !406)
!406 = !{null, !407}
!407 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*mut core::task::wake::Waker", baseType: !408, size: 64, align: 64, dwarfAddressSpace: 0)
!408 = !DICompositeType(tag: DW_TAG_structure_type, name: "Waker", scope: !29, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !409, templateParams: !23, identifier: "15546cde1d59b7dd64fbefa9b69f4bc9")
!409 = !{!410}
!410 = !DIDerivedType(tag: DW_TAG_member, name: "waker", scope: !408, file: !2, baseType: !37, size: 128, align: 64, flags: DIFlagPrivate)
!411 = !{!412}
!412 = !DILocalVariable(arg: 1, scope: !403, file: !404, line: 523, type: !407)
!413 = !{!414}
!414 = !DITemplateTypeParameter(name: "T", type: !408)
!415 = !DILocation(line: 523, column: 1, scope: !403)
!416 = distinct !DISubprogram(name: "drop_in_place<complex::find::{async_fn_env#0}>", linkageName: "_ZN4core3ptr63drop_in_place$LT$complex..find..$u7b$$u7b$closure$u7d$$u7d$$GT$17h300c76df0795e4ffE", scope: !170, file: !404, line: 523, type: !417, scopeLine: 523, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !496, retainedNodes: !438)
!417 = !DISubroutineType(types: !418)
!418 = !{null, !419}
!419 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*mut complex::find::{async_fn_env#0}", baseType: !420, size: 64, align: 64, dwarfAddressSpace: 0)
!420 = !DICompositeType(tag: DW_TAG_structure_type, name: "{async_fn_env#0}", scope: !421, file: !2, size: 128, align: 64, elements: !422, templateParams: !23, identifier: "7bef657c00be2c23acc782d036ae4024")
!421 = !DINamespace(name: "find", scope: !26)
!422 = !{!423}
!423 = !DICompositeType(tag: DW_TAG_variant_part, scope: !420, file: !2, size: 128, align: 64, elements: !424, templateParams: !23, identifier: "f898f41e251926a24d95277368149025", discriminator: !437)
!424 = !{!425, !429, !433}
!425 = !DIDerivedType(tag: DW_TAG_member, name: "0", scope: !423, file: !27, line: 12, baseType: !426, size: 128, align: 64, extraData: i8 0)
!426 = !DICompositeType(tag: DW_TAG_structure_type, name: "Unresumed", scope: !420, file: !2, size: 128, align: 64, elements: !427, templateParams: !23, identifier: "640cebcc2428242c92d770c15080c355")
!427 = !{!428}
!428 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !426, file: !2, baseType: !233, size: 64, align: 64)
!429 = !DIDerivedType(tag: DW_TAG_member, name: "1", scope: !423, file: !27, line: 14, baseType: !430, size: 128, align: 64, extraData: i8 1)
!430 = !DICompositeType(tag: DW_TAG_structure_type, name: "Returned", scope: !420, file: !2, size: 128, align: 64, elements: !431, templateParams: !23, identifier: "856511f35d2e9084cb0fa973248729d")
!431 = !{!432}
!432 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !430, file: !2, baseType: !233, size: 64, align: 64)
!433 = !DIDerivedType(tag: DW_TAG_member, name: "2", scope: !423, file: !27, line: 14, baseType: !434, size: 128, align: 64, extraData: i8 2)
!434 = !DICompositeType(tag: DW_TAG_structure_type, name: "Panicked", scope: !420, file: !2, size: 128, align: 64, elements: !435, templateParams: !23, identifier: "23cc7a6ce038ec80af2f46a307dc8e1f")
!435 = !{!436}
!436 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !434, file: !2, baseType: !233, size: 64, align: 64)
!437 = !DIDerivedType(tag: DW_TAG_member, name: "__state", scope: !420, file: !2, baseType: !58, size: 8, align: 8, offset: 64, flags: DIFlagArtificial)
!438 = !{!439, !493, !494}
!439 = !DILocalVariable(name: "_task_context", scope: !416, file: !27, line: 12, type: !440, align: 64)
!440 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut core::task::wake::Context", baseType: !441, size: 64, align: 64, dwarfAddressSpace: 0)
!441 = !DICompositeType(tag: DW_TAG_structure_type, name: "Context", scope: !29, file: !2, size: 256, align: 64, flags: DIFlagPublic, elements: !442, templateParams: !23, identifier: "5f4b5cdd9973f32ba36879e96e44e62c")
!442 = !{!443, !445, !450, !481, !488}
!443 = !DIDerivedType(tag: DW_TAG_member, name: "waker", scope: !441, file: !2, baseType: !444, size: 64, align: 64, flags: DIFlagPrivate)
!444 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&core::task::wake::Waker", baseType: !408, size: 64, align: 64, dwarfAddressSpace: 0)
!445 = !DIDerivedType(tag: DW_TAG_member, name: "local_waker", scope: !441, file: !2, baseType: !446, size: 64, align: 64, offset: 64, flags: DIFlagPrivate)
!446 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&core::task::wake::LocalWaker", baseType: !447, size: 64, align: 64, dwarfAddressSpace: 0)
!447 = !DICompositeType(tag: DW_TAG_structure_type, name: "LocalWaker", scope: !29, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !448, templateParams: !23, identifier: "55ba0586d91a66a8c4d5295c2a05a07f")
!448 = !{!449}
!449 = !DIDerivedType(tag: DW_TAG_member, name: "waker", scope: !447, file: !2, baseType: !37, size: 128, align: 64, flags: DIFlagPrivate)
!450 = !DIDerivedType(tag: DW_TAG_member, name: "ext", scope: !441, file: !2, baseType: !451, size: 128, align: 64, offset: 128, flags: DIFlagPrivate)
!451 = !DICompositeType(tag: DW_TAG_structure_type, name: "AssertUnwindSafe<core::task::wake::ExtData>", scope: !452, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !454, templateParams: !479, identifier: "3ab915a54d9402cf04748efb8a1a38d")
!452 = !DINamespace(name: "unwind_safe", scope: !453)
!453 = !DINamespace(name: "panic", scope: !31)
!454 = !{!455}
!455 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !451, file: !2, baseType: !456, size: 128, align: 64, flags: DIFlagPublic)
!456 = !DICompositeType(tag: DW_TAG_structure_type, name: "ExtData", scope: !29, file: !2, size: 128, align: 64, flags: DIFlagPrivate, elements: !457, templateParams: !23, identifier: "3151400636dbb550d1179560d475fb7b")
!457 = !{!458}
!458 = !DICompositeType(tag: DW_TAG_variant_part, scope: !456, file: !2, size: 128, align: 64, elements: !459, templateParams: !23, identifier: "ae003c5eec8f31bcfedef7ca9e3e403b", discriminator: !478)
!459 = !{!460, !474}
!460 = !DIDerivedType(tag: DW_TAG_member, name: "Some", scope: !458, file: !2, baseType: !461, size: 128, align: 64)
!461 = !DICompositeType(tag: DW_TAG_structure_type, name: "Some", scope: !456, file: !2, size: 128, align: 64, flags: DIFlagPrivate, elements: !462, templateParams: !23, identifier: "caca0d8422ecf9bd10bd4379d017c8a6")
!462 = !{!463}
!463 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !461, file: !2, baseType: !464, size: 128, align: 64, flags: DIFlagPrivate)
!464 = !DICompositeType(tag: DW_TAG_structure_type, name: "&mut dyn core::any::Any", file: !2, size: 128, align: 64, elements: !465, templateParams: !23, identifier: "d858f69fa2f7180e88665e32f850f0ff")
!465 = !{!466, !469}
!466 = !DIDerivedType(tag: DW_TAG_member, name: "pointer", scope: !464, file: !2, baseType: !467, size: 64, align: 64)
!467 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !468, size: 64, align: 64, dwarfAddressSpace: 0)
!468 = !DICompositeType(tag: DW_TAG_structure_type, name: "dyn core::any::Any", file: !2, align: 8, elements: !23, identifier: "c95144c9f0ec102da8273af1dc5f0479")
!469 = !DIDerivedType(tag: DW_TAG_member, name: "vtable", scope: !464, file: !2, baseType: !470, size: 64, align: 64, offset: 64)
!470 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&[usize; 4]", baseType: !471, size: 64, align: 64, dwarfAddressSpace: 0)
!471 = !DICompositeType(tag: DW_TAG_array_type, baseType: !9, size: 256, align: 64, elements: !472)
!472 = !{!473}
!473 = !DISubrange(count: 4, lowerBound: 0)
!474 = !DIDerivedType(tag: DW_TAG_member, name: "None", scope: !458, file: !2, baseType: !475, size: 128, align: 64, extraData: i64 0)
!475 = !DICompositeType(tag: DW_TAG_structure_type, name: "None", scope: !456, file: !2, size: 128, align: 64, flags: DIFlagPrivate, elements: !476, templateParams: !23, identifier: "6d10cbe44bdd8287d99a04d5cb830055")
!476 = !{!477}
!477 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !475, file: !2, baseType: !7, align: 8, flags: DIFlagPrivate)
!478 = !DIDerivedType(tag: DW_TAG_member, scope: !456, file: !2, baseType: !233, size: 64, align: 64, flags: DIFlagArtificial)
!479 = !{!480}
!480 = !DITemplateTypeParameter(name: "T", type: !456)
!481 = !DIDerivedType(tag: DW_TAG_member, name: "_marker", scope: !441, file: !2, baseType: !482, align: 8, offset: 256, flags: DIFlagPrivate)
!482 = !DICompositeType(tag: DW_TAG_structure_type, name: "PhantomData<fn(&()) -> &()>", scope: !248, file: !2, align: 8, flags: DIFlagPublic, elements: !23, templateParams: !483, identifier: "aa85cd4bea5f0b2e1ac5e24c3b1d7ec")
!483 = !{!484}
!484 = !DITemplateTypeParameter(name: "T", type: !485)
!485 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "fn(&()) -> &()", baseType: !486, size: 64, align: 64, dwarfAddressSpace: 0)
!486 = !DISubroutineType(types: !487)
!487 = !{!251, !251}
!488 = !DIDerivedType(tag: DW_TAG_member, name: "_marker2", scope: !441, file: !2, baseType: !489, align: 8, offset: 256, flags: DIFlagPrivate)
!489 = !DICompositeType(tag: DW_TAG_structure_type, name: "PhantomData<*mut ()>", scope: !248, file: !2, align: 8, flags: DIFlagPublic, elements: !23, templateParams: !490, identifier: "c165d6d88d2658ef9dad4545d253cff5")
!490 = !{!491}
!491 = !DITemplateTypeParameter(name: "T", type: !492)
!492 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*mut ()", baseType: !7, size: 64, align: 64, dwarfAddressSpace: 0)
!493 = !DILocalVariable(name: "id", scope: !416, file: !27, line: 12, type: !233, align: 64)
!494 = !DILocalVariable(name: "id", scope: !495, file: !27, line: 12, type: !233, align: 64)
!495 = distinct !DILexicalBlock(scope: !416, file: !27, line: 12, column: 46)
!496 = !{!497}
!497 = !DITemplateTypeParameter(name: "T", type: !420)
!498 = !DILocation(line: 12, column: 19, scope: !416)
!499 = !DILocation(line: 12, column: 46, scope: !416)
!500 = distinct !DISubprogram(name: "drop_in_place<complex::to_json::{async_fn_env#0}>", linkageName: "_ZN4core3ptr66drop_in_place$LT$complex..to_json..$u7b$$u7b$closure$u7d$$u7d$$GT$17hcd44afcccc964b77E", scope: !170, file: !404, line: 523, type: !501, scopeLine: 523, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !532, retainedNodes: !527)
!501 = !DISubroutineType(types: !502)
!502 = !{null, !503}
!503 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*mut complex::to_json::{async_fn_env#0}", baseType: !504, size: 64, align: 64, dwarfAddressSpace: 0)
!504 = !DICompositeType(tag: DW_TAG_structure_type, name: "{async_fn_env#0}", scope: !505, file: !2, size: 128, align: 64, elements: !506, templateParams: !23, identifier: "fbef95f2ec97f1ff3a6695115ceaec8e")
!505 = !DINamespace(name: "to_json", scope: !26)
!506 = !{!507}
!507 = !DICompositeType(tag: DW_TAG_variant_part, scope: !504, file: !2, size: 128, align: 64, elements: !508, templateParams: !23, identifier: "e7f0510f3cb15c8bed85270d1450c194", discriminator: !526)
!508 = !{!509, !518, !522}
!509 = !DIDerivedType(tag: DW_TAG_member, name: "0", scope: !507, file: !27, line: 22, baseType: !510, size: 128, align: 64, extraData: i8 0)
!510 = !DICompositeType(tag: DW_TAG_structure_type, name: "Unresumed", scope: !504, file: !2, size: 128, align: 64, elements: !511, templateParams: !23, identifier: "5f7d68df09b4fa8ffb6a33a06097d142")
!511 = !{!512}
!512 = !DIDerivedType(tag: DW_TAG_member, name: "c", scope: !510, file: !2, baseType: !513, size: 64, align: 64)
!513 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&complex::Cipher", baseType: !514, size: 64, align: 64, dwarfAddressSpace: 0)
!514 = !DICompositeType(tag: DW_TAG_structure_type, name: "Cipher", scope: !26, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !515, templateParams: !23, identifier: "343bfec3ea644583d3c38c18f4d25775")
!515 = !{!516, !517}
!516 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !514, file: !2, baseType: !233, size: 64, align: 64, flags: DIFlagPublic)
!517 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !514, file: !2, baseType: !233, size: 64, align: 64, offset: 64, flags: DIFlagPublic)
!518 = !DIDerivedType(tag: DW_TAG_member, name: "1", scope: !507, file: !27, line: 24, baseType: !519, size: 128, align: 64, extraData: i8 1)
!519 = !DICompositeType(tag: DW_TAG_structure_type, name: "Returned", scope: !504, file: !2, size: 128, align: 64, elements: !520, templateParams: !23, identifier: "55c7b51aaf66dd319c08c08e88e6746e")
!520 = !{!521}
!521 = !DIDerivedType(tag: DW_TAG_member, name: "c", scope: !519, file: !2, baseType: !513, size: 64, align: 64)
!522 = !DIDerivedType(tag: DW_TAG_member, name: "2", scope: !507, file: !27, line: 24, baseType: !523, size: 128, align: 64, extraData: i8 2)
!523 = !DICompositeType(tag: DW_TAG_structure_type, name: "Panicked", scope: !504, file: !2, size: 128, align: 64, elements: !524, templateParams: !23, identifier: "706dc478d770f9c3c77e118cb2b0c90f")
!524 = !{!525}
!525 = !DIDerivedType(tag: DW_TAG_member, name: "c", scope: !523, file: !2, baseType: !513, size: 64, align: 64)
!526 = !DIDerivedType(tag: DW_TAG_member, name: "__state", scope: !504, file: !2, baseType: !58, size: 8, align: 8, offset: 64, flags: DIFlagArtificial)
!527 = !{!528, !529, !530}
!528 = !DILocalVariable(name: "_task_context", scope: !500, file: !27, line: 22, type: !440, align: 64)
!529 = !DILocalVariable(name: "c", scope: !500, file: !27, line: 22, type: !513, align: 64)
!530 = !DILocalVariable(name: "c", scope: !531, file: !27, line: 22, type: !513, align: 64)
!531 = distinct !DILexicalBlock(scope: !500, file: !27, line: 22, column: 41)
!532 = !{!533}
!533 = !DITemplateTypeParameter(name: "T", type: !504)
!534 = !DILocation(line: 22, column: 22, scope: !500)
!535 = !DILocation(line: 22, column: 41, scope: !500)
!536 = distinct !DISubprogram(name: "drop_in_place<complex::get_cipher::{async_fn_env#0}>", linkageName: "_ZN4core3ptr69drop_in_place$LT$complex..get_cipher..$u7b$$u7b$closure$u7d$$u7d$$GT$17h3cb4a8df9c9346ecE", scope: !170, file: !404, line: 523, type: !537, scopeLine: 523, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !626, retainedNodes: !593)
!537 = !DISubroutineType(types: !538)
!538 = !{null, !539}
!539 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*mut complex::get_cipher::{async_fn_env#0}", baseType: !540, size: 64, align: 64, dwarfAddressSpace: 0)
!540 = !DICompositeType(tag: DW_TAG_structure_type, name: "{async_fn_env#0}", scope: !541, file: !2, size: 384, align: 64, elements: !542, templateParams: !23, identifier: "16c669dde396720a8dc4b6d380f0a198")
!541 = !DINamespace(name: "get_cipher", scope: !26)
!542 = !{!543}
!543 = !DICompositeType(tag: DW_TAG_variant_part, scope: !540, file: !2, size: 384, align: 64, elements: !544, templateParams: !23, identifier: "2037def909b4c328fe43ebfa59e8b298", discriminator: !592)
!544 = !{!545, !549, !553, !557, !562, !586}
!545 = !DIDerivedType(tag: DW_TAG_member, name: "0", scope: !543, file: !27, line: 28, baseType: !546, size: 384, align: 64, extraData: i8 0)
!546 = !DICompositeType(tag: DW_TAG_structure_type, name: "Unresumed", scope: !540, file: !2, size: 384, align: 64, elements: !547, templateParams: !23, identifier: "570c715f1b19422cf6e4568fcdbf97ca")
!547 = !{!548}
!548 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !546, file: !2, baseType: !233, size: 64, align: 64)
!549 = !DIDerivedType(tag: DW_TAG_member, name: "1", scope: !543, file: !27, line: 34, baseType: !550, size: 384, align: 64, extraData: i8 1)
!550 = !DICompositeType(tag: DW_TAG_structure_type, name: "Returned", scope: !540, file: !2, size: 384, align: 64, elements: !551, templateParams: !23, identifier: "5deb8e33cd99a0cc33bf7959e1321b1")
!551 = !{!552}
!552 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !550, file: !2, baseType: !233, size: 64, align: 64)
!553 = !DIDerivedType(tag: DW_TAG_member, name: "2", scope: !543, file: !27, line: 34, baseType: !554, size: 384, align: 64, extraData: i8 2)
!554 = !DICompositeType(tag: DW_TAG_structure_type, name: "Panicked", scope: !540, file: !2, size: 384, align: 64, elements: !555, templateParams: !23, identifier: "9f632d70ea7788fa429345f5ec1190f3")
!555 = !{!556}
!556 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !554, file: !2, baseType: !233, size: 64, align: 64)
!557 = !DIDerivedType(tag: DW_TAG_member, name: "3", scope: !543, file: !27, line: 29, baseType: !558, size: 384, align: 64, extraData: i8 3)
!558 = !DICompositeType(tag: DW_TAG_structure_type, name: "Suspend0", scope: !540, file: !2, size: 384, align: 64, elements: !559, templateParams: !23, identifier: "8e45ef21641eb7dee4f1126f2c8a8a8c")
!559 = !{!560, !561}
!560 = !DIDerivedType(tag: DW_TAG_member, name: "__awaitee", scope: !558, file: !2, baseType: !420, size: 128, align: 64, offset: 256)
!561 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !558, file: !2, baseType: !233, size: 64, align: 64)
!562 = !DIDerivedType(tag: DW_TAG_member, name: "4", scope: !543, file: !27, line: 30, baseType: !563, size: 384, align: 64, extraData: i8 4)
!563 = !DICompositeType(tag: DW_TAG_structure_type, name: "Suspend1", scope: !540, file: !2, size: 384, align: 64, elements: !564, templateParams: !23, identifier: "7f4290bb253ff03d98d6f53edb70671a")
!564 = !{!565, !566, !585}
!565 = !DIDerivedType(tag: DW_TAG_member, name: "c", scope: !563, file: !2, baseType: !514, size: 128, align: 64, offset: 64)
!566 = !DIDerivedType(tag: DW_TAG_member, name: "__awaitee", scope: !563, file: !2, baseType: !567, size: 128, align: 64, offset: 256)
!567 = !DICompositeType(tag: DW_TAG_structure_type, name: "{async_fn_env#0}", scope: !568, file: !2, size: 128, align: 64, elements: !569, templateParams: !23, identifier: "174af1eac5dd414a694d7ed57fe32431")
!568 = !DINamespace(name: "is_accessible", scope: !26)
!569 = !{!570}
!570 = !DICompositeType(tag: DW_TAG_variant_part, scope: !567, file: !2, size: 128, align: 64, elements: !571, templateParams: !23, identifier: "4384b117abacf0f4669606c013bcb6b6", discriminator: !584)
!571 = !{!572, !576, !580}
!572 = !DIDerivedType(tag: DW_TAG_member, name: "0", scope: !570, file: !27, line: 17, baseType: !573, size: 128, align: 64, extraData: i8 0)
!573 = !DICompositeType(tag: DW_TAG_structure_type, name: "Unresumed", scope: !567, file: !2, size: 128, align: 64, elements: !574, templateParams: !23, identifier: "38ecdebb1e159bacd447719a43a1d0")
!574 = !{!575}
!575 = !DIDerivedType(tag: DW_TAG_member, name: "c", scope: !573, file: !2, baseType: !513, size: 64, align: 64)
!576 = !DIDerivedType(tag: DW_TAG_member, name: "1", scope: !570, file: !27, line: 19, baseType: !577, size: 128, align: 64, extraData: i8 1)
!577 = !DICompositeType(tag: DW_TAG_structure_type, name: "Returned", scope: !567, file: !2, size: 128, align: 64, elements: !578, templateParams: !23, identifier: "34a876530758be2c16f977cdb240c279")
!578 = !{!579}
!579 = !DIDerivedType(tag: DW_TAG_member, name: "c", scope: !577, file: !2, baseType: !513, size: 64, align: 64)
!580 = !DIDerivedType(tag: DW_TAG_member, name: "2", scope: !570, file: !27, line: 19, baseType: !581, size: 128, align: 64, extraData: i8 2)
!581 = !DICompositeType(tag: DW_TAG_structure_type, name: "Panicked", scope: !567, file: !2, size: 128, align: 64, elements: !582, templateParams: !23, identifier: "49b033141fccf156c74897a0f7dbbc80")
!582 = !{!583}
!583 = !DIDerivedType(tag: DW_TAG_member, name: "c", scope: !581, file: !2, baseType: !513, size: 64, align: 64)
!584 = !DIDerivedType(tag: DW_TAG_member, name: "__state", scope: !567, file: !2, baseType: !58, size: 8, align: 8, offset: 64, flags: DIFlagArtificial)
!585 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !563, file: !2, baseType: !233, size: 64, align: 64)
!586 = !DIDerivedType(tag: DW_TAG_member, name: "5", scope: !543, file: !27, line: 33, baseType: !587, size: 384, align: 64, extraData: i8 5)
!587 = !DICompositeType(tag: DW_TAG_structure_type, name: "Suspend2", scope: !540, file: !2, size: 384, align: 64, elements: !588, templateParams: !23, identifier: "9cb64d3b211254e8749686f13325f6aa")
!588 = !{!589, !590, !591}
!589 = !DIDerivedType(tag: DW_TAG_member, name: "c", scope: !587, file: !2, baseType: !514, size: 128, align: 64, offset: 64)
!590 = !DIDerivedType(tag: DW_TAG_member, name: "__awaitee", scope: !587, file: !2, baseType: !504, size: 128, align: 64, offset: 256)
!591 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !587, file: !2, baseType: !233, size: 64, align: 64)
!592 = !DIDerivedType(tag: DW_TAG_member, name: "__state", scope: !540, file: !2, baseType: !58, size: 8, align: 8, offset: 192, flags: DIFlagArtificial)
!593 = !{!594, !595, !596, !598, !600, !602, !617, !619, !622, !624}
!594 = !DILocalVariable(name: "_task_context", scope: !536, file: !27, line: 28, type: !440, align: 64)
!595 = !DILocalVariable(name: "id", scope: !536, file: !27, line: 28, type: !233, align: 64)
!596 = !DILocalVariable(name: "id", scope: !597, file: !27, line: 28, type: !233, align: 64)
!597 = distinct !DILexicalBlock(scope: !536, file: !27, line: 28, column: 41)
!598 = !DILocalVariable(name: "c", scope: !599, file: !27, line: 29, type: !514, align: 64)
!599 = distinct !DILexicalBlock(scope: !597, file: !27, line: 29, column: 5)
!600 = !DILocalVariable(name: "__awaitee", scope: !601, file: !27, line: 29, type: !420, align: 64)
!601 = distinct !DILexicalBlock(scope: !597, file: !27, line: 29, column: 28)
!602 = !DILocalVariable(name: "result", scope: !603, file: !27, line: 29, type: !604, align: 64)
!603 = distinct !DILexicalBlock(scope: !601, file: !27, line: 29, column: 19)
!604 = !DICompositeType(tag: DW_TAG_structure_type, name: "Option<complex::Cipher>", scope: !206, file: !2, size: 192, align: 64, flags: DIFlagPublic, elements: !605, templateParams: !23, identifier: "412d1b1f1b50d7e8263ff2e6f1cd0387")
!605 = !{!606}
!606 = !DICompositeType(tag: DW_TAG_variant_part, scope: !604, file: !2, size: 192, align: 64, elements: !607, templateParams: !23, identifier: "5e54b4c968721924c189289001640e46", discriminator: !616)
!607 = !{!608, !612}
!608 = !DIDerivedType(tag: DW_TAG_member, name: "None", scope: !606, file: !2, baseType: !609, size: 192, align: 64, extraData: i64 0)
!609 = !DICompositeType(tag: DW_TAG_structure_type, name: "None", scope: !604, file: !2, size: 192, align: 64, flags: DIFlagPublic, elements: !23, templateParams: !610, identifier: "579e71d3951f56680019f3dff5c324d")
!610 = !{!611}
!611 = !DITemplateTypeParameter(name: "T", type: !514)
!612 = !DIDerivedType(tag: DW_TAG_member, name: "Some", scope: !606, file: !2, baseType: !613, size: 192, align: 64, extraData: i64 1)
!613 = !DICompositeType(tag: DW_TAG_structure_type, name: "Some", scope: !604, file: !2, size: 192, align: 64, flags: DIFlagPublic, elements: !614, templateParams: !610, identifier: "f5c885df5f9a6566e63c53aa4a8b7e1f")
!614 = !{!615}
!615 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !613, file: !2, baseType: !514, size: 128, align: 64, offset: 64, flags: DIFlagPublic)
!616 = !DIDerivedType(tag: DW_TAG_member, scope: !604, file: !2, baseType: !233, size: 64, align: 64, flags: DIFlagArtificial)
!617 = !DILocalVariable(name: "__awaitee", scope: !618, file: !27, line: 30, type: !567, align: 64)
!618 = distinct !DILexicalBlock(scope: !599, file: !27, line: 30, column: 27)
!619 = !DILocalVariable(name: "result", scope: !620, file: !27, line: 30, type: !621, align: 8)
!620 = distinct !DILexicalBlock(scope: !618, file: !27, line: 30, column: 9)
!621 = !DIBasicType(name: "bool", size: 8, encoding: DW_ATE_boolean)
!622 = !DILocalVariable(name: "__awaitee", scope: !623, file: !27, line: 33, type: !504, align: 64)
!623 = distinct !DILexicalBlock(scope: !599, file: !27, line: 33, column: 17)
!624 = !DILocalVariable(name: "result", scope: !625, file: !27, line: 33, type: !233, align: 64)
!625 = distinct !DILexicalBlock(scope: !623, file: !27, line: 33, column: 5)
!626 = !{!627}
!627 = !DITemplateTypeParameter(name: "T", type: !540)
!628 = !DILocation(line: 28, column: 25, scope: !536)
!629 = !DILocation(line: 29, column: 14, scope: !599)
!630 = !DILocation(line: 29, column: 19, scope: !601)
!631 = !DILocation(line: 30, column: 9, scope: !618)
!632 = !DILocation(line: 33, column: 5, scope: !623)
!633 = !DILocation(line: 28, column: 41, scope: !536)
!634 = !DILocation(line: 29, column: 32, scope: !597)
!635 = !DILocation(line: 30, column: 31, scope: !599)
!636 = !DILocation(line: 33, column: 21, scope: !599)
!637 = !DILocation(line: 0, scope: !597)
!638 = !DILocation(line: 0, scope: !599)
!639 = distinct !DISubprogram(name: "drop_in_place<complex::is_accessible::{async_fn_env#0}>", linkageName: "_ZN4core3ptr72drop_in_place$LT$complex..is_accessible..$u7b$$u7b$closure$u7d$$u7d$$GT$17h063ee76deceb8fb5E", scope: !170, file: !404, line: 523, type: !640, scopeLine: 523, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !648, retainedNodes: !643)
!640 = !DISubroutineType(types: !641)
!641 = !{null, !642}
!642 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*mut complex::is_accessible::{async_fn_env#0}", baseType: !567, size: 64, align: 64, dwarfAddressSpace: 0)
!643 = !{!644, !645, !646}
!644 = !DILocalVariable(name: "_task_context", scope: !639, file: !27, line: 17, type: !440, align: 64)
!645 = !DILocalVariable(name: "c", scope: !639, file: !27, line: 17, type: !513, align: 64)
!646 = !DILocalVariable(name: "c", scope: !647, file: !27, line: 17, type: !513, align: 64)
!647 = distinct !DILexicalBlock(scope: !639, file: !27, line: 17, column: 48)
!648 = !{!649}
!649 = !DITemplateTypeParameter(name: "T", type: !567)
!650 = !DILocation(line: 17, column: 28, scope: !639)
!651 = !DILocation(line: 17, column: 48, scope: !639)
!652 = distinct !DISubprogram(name: "drop_in_place<complex::get_cipher_leak::{async_fn_env#0}>", linkageName: "_ZN4core3ptr74drop_in_place$LT$complex..get_cipher_leak..$u7b$$u7b$closure$u7d$$u7d$$GT$17h23235722836c3597E", scope: !170, file: !404, line: 523, type: !653, scopeLine: 523, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !700, retainedNodes: !685)
!653 = !DISubroutineType(types: !654)
!654 = !{null, !655}
!655 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*mut complex::get_cipher_leak::{async_fn_env#0}", baseType: !656, size: 64, align: 64, dwarfAddressSpace: 0)
!656 = !DICompositeType(tag: DW_TAG_structure_type, name: "{async_fn_env#0}", scope: !657, file: !2, size: 384, align: 64, elements: !658, templateParams: !23, identifier: "f0af2b0b0c85308c2f60e92bed668256")
!657 = !DINamespace(name: "get_cipher_leak", scope: !26)
!658 = !{!659}
!659 = !DICompositeType(tag: DW_TAG_variant_part, scope: !656, file: !2, size: 384, align: 64, elements: !660, templateParams: !23, identifier: "aafec200cc33b6537efd15de63699dd8", discriminator: !684)
!660 = !{!661, !665, !669, !673, !678}
!661 = !DIDerivedType(tag: DW_TAG_member, name: "0", scope: !659, file: !27, line: 38, baseType: !662, size: 384, align: 64, extraData: i8 0)
!662 = !DICompositeType(tag: DW_TAG_structure_type, name: "Unresumed", scope: !656, file: !2, size: 384, align: 64, elements: !663, templateParams: !23, identifier: "4205822924c24f4ff58b56eea523819f")
!663 = !{!664}
!664 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !662, file: !2, baseType: !233, size: 64, align: 64)
!665 = !DIDerivedType(tag: DW_TAG_member, name: "1", scope: !659, file: !27, line: 41, baseType: !666, size: 384, align: 64, extraData: i8 1)
!666 = !DICompositeType(tag: DW_TAG_structure_type, name: "Returned", scope: !656, file: !2, size: 384, align: 64, elements: !667, templateParams: !23, identifier: "b184dc297c56ac992fd22359c0911c48")
!667 = !{!668}
!668 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !666, file: !2, baseType: !233, size: 64, align: 64)
!669 = !DIDerivedType(tag: DW_TAG_member, name: "2", scope: !659, file: !27, line: 41, baseType: !670, size: 384, align: 64, extraData: i8 2)
!670 = !DICompositeType(tag: DW_TAG_structure_type, name: "Panicked", scope: !656, file: !2, size: 384, align: 64, elements: !671, templateParams: !23, identifier: "132dd8e68b8afa968cc8abc7d4f3e63")
!671 = !{!672}
!672 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !670, file: !2, baseType: !233, size: 64, align: 64)
!673 = !DIDerivedType(tag: DW_TAG_member, name: "3", scope: !659, file: !27, line: 39, baseType: !674, size: 384, align: 64, extraData: i8 3)
!674 = !DICompositeType(tag: DW_TAG_structure_type, name: "Suspend0", scope: !656, file: !2, size: 384, align: 64, elements: !675, templateParams: !23, identifier: "a99a4119a115bf297394a1a89d1dfa37")
!675 = !{!676, !677}
!676 = !DIDerivedType(tag: DW_TAG_member, name: "__awaitee", scope: !674, file: !2, baseType: !420, size: 128, align: 64, offset: 128)
!677 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !674, file: !2, baseType: !233, size: 64, align: 64)
!678 = !DIDerivedType(tag: DW_TAG_member, name: "4", scope: !659, file: !27, line: 40, baseType: !679, size: 384, align: 64, extraData: i8 4)
!679 = !DICompositeType(tag: DW_TAG_structure_type, name: "Suspend1", scope: !656, file: !2, size: 384, align: 64, elements: !680, templateParams: !23, identifier: "936f86c0be9f10e69318633873a17ccb")
!680 = !{!681, !682, !683}
!681 = !DIDerivedType(tag: DW_TAG_member, name: "c", scope: !679, file: !2, baseType: !514, size: 128, align: 64, offset: 128)
!682 = !DIDerivedType(tag: DW_TAG_member, name: "__awaitee", scope: !679, file: !2, baseType: !504, size: 128, align: 64, offset: 256)
!683 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !679, file: !2, baseType: !233, size: 64, align: 64)
!684 = !DIDerivedType(tag: DW_TAG_member, name: "__state", scope: !656, file: !2, baseType: !58, size: 8, align: 8, offset: 64, flags: DIFlagArtificial)
!685 = !{!686, !687, !688, !690, !692, !694, !696, !698}
!686 = !DILocalVariable(name: "_task_context", scope: !652, file: !27, line: 38, type: !440, align: 64)
!687 = !DILocalVariable(name: "id", scope: !652, file: !27, line: 38, type: !233, align: 64)
!688 = !DILocalVariable(name: "id", scope: !689, file: !27, line: 38, type: !233, align: 64)
!689 = distinct !DILexicalBlock(scope: !652, file: !27, line: 38, column: 46)
!690 = !DILocalVariable(name: "c", scope: !691, file: !27, line: 39, type: !514, align: 64)
!691 = distinct !DILexicalBlock(scope: !689, file: !27, line: 39, column: 5)
!692 = !DILocalVariable(name: "__awaitee", scope: !693, file: !27, line: 39, type: !420, align: 64)
!693 = distinct !DILexicalBlock(scope: !689, file: !27, line: 39, column: 28)
!694 = !DILocalVariable(name: "result", scope: !695, file: !27, line: 39, type: !604, align: 64)
!695 = distinct !DILexicalBlock(scope: !693, file: !27, line: 39, column: 19)
!696 = !DILocalVariable(name: "__awaitee", scope: !697, file: !27, line: 40, type: !504, align: 64)
!697 = distinct !DILexicalBlock(scope: !691, file: !27, line: 40, column: 17)
!698 = !DILocalVariable(name: "result", scope: !699, file: !27, line: 40, type: !233, align: 64)
!699 = distinct !DILexicalBlock(scope: !697, file: !27, line: 40, column: 5)
!700 = !{!701}
!701 = !DITemplateTypeParameter(name: "T", type: !656)
!702 = !DILocation(line: 38, column: 30, scope: !652)
!703 = !DILocation(line: 39, column: 14, scope: !691)
!704 = !DILocation(line: 39, column: 19, scope: !693)
!705 = !DILocation(line: 40, column: 5, scope: !697)
!706 = !DILocation(line: 38, column: 46, scope: !652)
!707 = !DILocation(line: 39, column: 32, scope: !689)
!708 = !DILocation(line: 40, column: 21, scope: !691)
!709 = !DILocation(line: 0, scope: !689)
!710 = distinct !DISubprogram(name: "drop_in_place<std::rt::lang_start::{closure_env#0}<()>>", linkageName: "_ZN4core3ptr85drop_in_place$LT$std..rt..lang_start$LT$$LP$$RP$$GT$..$u7b$$u7b$closure$u7d$$u7d$$GT$17hb4df91c0b8b08cbeE", scope: !170, file: !404, line: 523, type: !711, scopeLine: 523, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !715, retainedNodes: !713)
!711 = !DISubroutineType(types: !712)
!712 = !{null, !381}
!713 = !{!714}
!714 = !DILocalVariable(arg: 1, scope: !710, file: !404, line: 523, type: !381)
!715 = !{!716}
!716 = !DITemplateTypeParameter(name: "T", type: !14)
!717 = !DILocation(line: 523, column: 1, scope: !710)
!718 = distinct !DISubprogram(name: "black_box<u64>", linkageName: "_ZN4core4hint9black_box17hd3cf395c78131f8fE", scope: !145, file: !144, line: 476, type: !719, scopeLine: 476, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !261, retainedNodes: !721)
!719 = !DISubroutineType(types: !720)
!720 = !{!233, !233}
!721 = !{!722}
!722 = !DILocalVariable(name: "dummy", arg: 1, scope: !718, file: !144, line: 476, type: !233)
!723 = !DILocation(line: 476, column: 27, scope: !718)
!724 = !DILocation(line: 477, column: 5, scope: !718)
!725 = !DILocation(line: 478, column: 2, scope: !718)
!726 = distinct !DISubprogram(name: "black_box<&complex::Cipher>", linkageName: "_ZN4core4hint9black_box17hf57882eb706180acE", scope: !145, file: !144, line: 476, type: !727, scopeLine: 476, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !731, retainedNodes: !729)
!727 = !DISubroutineType(types: !728)
!728 = !{!513, !513}
!729 = !{!730}
!730 = !DILocalVariable(name: "dummy", arg: 1, scope: !726, file: !144, line: 476, type: !513)
!731 = !{!732}
!732 = !DITemplateTypeParameter(name: "T", type: !513)
!733 = !DILocation(line: 476, column: 27, scope: !726)
!734 = !DILocation(line: 477, column: 5, scope: !726)
!735 = !DILocation(line: 478, column: 2, scope: !726)
!736 = distinct !DISubprogram(name: "from_raw", linkageName: "_ZN4core4task4wake5Waker8from_raw17h368bf203d158977aE", scope: !408, file: !737, line: 534, type: !738, scopeLine: 534, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, declaration: !740, retainedNodes: !741)
!737 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/task/wake.rs", directory: "", checksumkind: CSK_MD5, checksum: "61f0703b7bd87b7ffe527ee51645eb72")
!738 = !DISubroutineType(types: !739)
!739 = !{!408, !37}
!740 = !DISubprogram(name: "from_raw", linkageName: "_ZN4core4task4wake5Waker8from_raw17h368bf203d158977aE", scope: !408, file: !737, line: 534, type: !738, scopeLine: 534, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!741 = !{!742}
!742 = !DILocalVariable(name: "waker", arg: 1, scope: !736, file: !737, line: 534, type: !37)
!743 = !DILocation(line: 534, column: 34, scope: !736)
!744 = !DILocation(line: 536, column: 6, scope: !736)
!745 = distinct !DISubprogram(name: "from_waker", linkageName: "_ZN4core4task4wake7Context10from_waker17h322044d7ee0260aaE", scope: !441, file: !737, line: 240, type: !746, scopeLine: 240, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, declaration: !748, retainedNodes: !749)
!746 = !DISubroutineType(types: !747)
!747 = !{!441, !444}
!748 = !DISubprogram(name: "from_waker", linkageName: "_ZN4core4task4wake7Context10from_waker17h322044d7ee0260aaE", scope: !441, file: !737, line: 240, type: !746, scopeLine: 240, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!749 = !{!750}
!750 = !DILocalVariable(name: "waker", arg: 1, scope: !745, file: !737, line: 240, type: !444)
!751 = !DILocation(line: 240, column: 29, scope: !745)
!752 = !DILocalVariable(name: "waker", arg: 1, scope: !753, file: !737, line: 321, type: !444)
!753 = distinct !DISubprogram(name: "from_waker", linkageName: "_ZN4core4task4wake14ContextBuilder10from_waker17h886fdbb822b0ed43E", scope: !754, file: !737, line: 321, type: !761, scopeLine: 321, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, declaration: !763, retainedNodes: !764)
!754 = !DICompositeType(tag: DW_TAG_structure_type, name: "ContextBuilder", scope: !29, file: !2, size: 256, align: 64, flags: DIFlagPublic, elements: !755, templateParams: !23, identifier: "5671c3b1231ff74621a8f6459aeaf2d1")
!755 = !{!756, !757, !758, !759, !760}
!756 = !DIDerivedType(tag: DW_TAG_member, name: "waker", scope: !754, file: !2, baseType: !444, size: 64, align: 64, flags: DIFlagPrivate)
!757 = !DIDerivedType(tag: DW_TAG_member, name: "local_waker", scope: !754, file: !2, baseType: !446, size: 64, align: 64, offset: 64, flags: DIFlagPrivate)
!758 = !DIDerivedType(tag: DW_TAG_member, name: "ext", scope: !754, file: !2, baseType: !456, size: 128, align: 64, offset: 128, flags: DIFlagPrivate)
!759 = !DIDerivedType(tag: DW_TAG_member, name: "_marker", scope: !754, file: !2, baseType: !482, align: 8, offset: 256, flags: DIFlagPrivate)
!760 = !DIDerivedType(tag: DW_TAG_member, name: "_marker2", scope: !754, file: !2, baseType: !489, align: 8, offset: 256, flags: DIFlagPrivate)
!761 = !DISubroutineType(types: !762)
!762 = !{!754, !444}
!763 = !DISubprogram(name: "from_waker", linkageName: "_ZN4core4task4wake14ContextBuilder10from_waker17h886fdbb822b0ed43E", scope: !754, file: !737, line: 321, type: !761, scopeLine: 321, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!764 = !{!752}
!765 = !DILocation(line: 321, column: 29, scope: !753, inlinedAt: !766)
!766 = !DILocation(line: 241, column: 9, scope: !745)
!767 = !DILocation(line: 376, column: 9, scope: !768, inlinedAt: !772)
!768 = distinct !DISubprogram(name: "build", linkageName: "_ZN4core4task4wake14ContextBuilder5build17ha418bf24f0bad93fE", scope: !754, file: !737, line: 374, type: !769, scopeLine: 374, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, declaration: !771)
!769 = !DISubroutineType(types: !770)
!770 = !{!441, !754}
!771 = !DISubprogram(name: "build", linkageName: "_ZN4core4task4wake14ContextBuilder5build17ha418bf24f0bad93fE", scope: !754, file: !737, line: 374, type: !769, scopeLine: 374, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!772 = !DILocation(line: 241, column: 43, scope: !745)
!773 = !DILocation(line: 242, column: 6, scope: !745)
!774 = distinct !DISubprogram(name: "new", linkageName: "_ZN4core4task4wake8RawWaker3new17hfb3f559eb0c03964E", scope: !37, file: !737, line: 59, type: !775, scopeLine: 59, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, declaration: !777, retainedNodes: !778)
!775 = !DISubroutineType(types: !776)
!776 = !{!37, !6, !41}
!777 = !DISubprogram(name: "new", linkageName: "_ZN4core4task4wake8RawWaker3new17hfb3f559eb0c03964E", scope: !37, file: !737, line: 59, type: !775, scopeLine: 59, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!778 = !{!779, !780}
!779 = !DILocalVariable(name: "data", arg: 1, scope: !774, file: !737, line: 59, type: !6)
!780 = !DILocalVariable(name: "vtable", arg: 2, scope: !774, file: !737, line: 59, type: !41)
!781 = !DILocation(line: 59, column: 22, scope: !774)
!782 = !DILocation(line: 59, column: 39, scope: !774)
!783 = !DILocation(line: 61, column: 6, scope: !774)
!784 = distinct !DISubprogram(name: "report", linkageName: "_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17ha2b1f0f1ec0820b7E", scope: !785, file: !101, line: 2427, type: !786, scopeLine: 2427, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !788)
!785 = !DINamespace(name: "{impl#57}", scope: !103)
!786 = !DISubroutineType(types: !787)
!787 = !{!102, !7}
!788 = !{!789}
!789 = !DILocalVariable(arg: 1, scope: !784, file: !101, line: 2427, type: !7)
!790 = !DILocation(line: 2427, column: 15, scope: !784)
!791 = !DILocation(line: 2429, column: 6, scope: !784)
!792 = distinct !DISubprogram(name: "into_future<complex::to_json::{async_fn_env#0}>", linkageName: "_ZN59_$LT$F$u20$as$u20$core..future..into_future..IntoFuture$GT$11into_future17h4749e41366c76841E", scope: !794, file: !793, line: 142, type: !797, scopeLine: 142, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !801, retainedNodes: !799)
!793 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/future/into_future.rs", directory: "", checksumkind: CSK_MD5, checksum: "c74955e5f3ef6c9ab8ab8241c074cbd7")
!794 = !DINamespace(name: "{impl#0}", scope: !795)
!795 = !DINamespace(name: "into_future", scope: !796)
!796 = !DINamespace(name: "future", scope: !31)
!797 = !DISubroutineType(types: !798)
!798 = !{!504, !504}
!799 = !{!800}
!800 = !DILocalVariable(name: "self", arg: 1, scope: !792, file: !793, line: 142, type: !504)
!801 = !{!802}
!802 = !DITemplateTypeParameter(name: "F", type: !504)
!803 = !DILocation(line: 142, column: 20, scope: !792)
!804 = !DILocation(line: 143, column: 9, scope: !792)
!805 = !DILocation(line: 144, column: 6, scope: !792)
!806 = distinct !DISubprogram(name: "into_future<complex::find::{async_fn_env#0}>", linkageName: "_ZN59_$LT$F$u20$as$u20$core..future..into_future..IntoFuture$GT$11into_future17hdce4e288f9d68d49E", scope: !794, file: !793, line: 142, type: !807, scopeLine: 142, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !811, retainedNodes: !809)
!807 = !DISubroutineType(types: !808)
!808 = !{!420, !420}
!809 = !{!810}
!810 = !DILocalVariable(name: "self", arg: 1, scope: !806, file: !793, line: 142, type: !420)
!811 = !{!812}
!812 = !DITemplateTypeParameter(name: "F", type: !420)
!813 = !DILocation(line: 142, column: 20, scope: !806)
!814 = !DILocation(line: 143, column: 9, scope: !806)
!815 = !DILocation(line: 144, column: 6, scope: !806)
!816 = distinct !DISubprogram(name: "into_future<complex::is_accessible::{async_fn_env#0}>", linkageName: "_ZN59_$LT$F$u20$as$u20$core..future..into_future..IntoFuture$GT$11into_future17hf9b4fad8070ee57bE", scope: !794, file: !793, line: 142, type: !817, scopeLine: 142, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !821, retainedNodes: !819)
!817 = !DISubroutineType(types: !818)
!818 = !{!567, !567}
!819 = !{!820}
!820 = !DILocalVariable(name: "self", arg: 1, scope: !816, file: !793, line: 142, type: !567)
!821 = !{!822}
!822 = !DITemplateTypeParameter(name: "F", type: !567)
!823 = !DILocation(line: 142, column: 20, scope: !816)
!824 = !DILocation(line: 143, column: 9, scope: !816)
!825 = !DILocation(line: 144, column: 6, scope: !816)
!826 = distinct !DISubprogram(name: "deref_mut<complex::get_cipher_leak::{async_fn_env#0}>", linkageName: "_ZN60_$LT$$RF$mut$u20$T$u20$as$u20$core..ops..deref..DerefMut$GT$9deref_mut17h2947722b5e24665bE", scope: !828, file: !827, line: 277, type: !830, scopeLine: 277, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !700, retainedNodes: !834)
!827 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/ops/deref.rs", directory: "", checksumkind: CSK_MD5, checksum: "1c671aaacd25f5a7e18e63389e18f8d7")
!828 = !DINamespace(name: "{impl#3}", scope: !829)
!829 = !DINamespace(name: "deref", scope: !378)
!830 = !DISubroutineType(types: !831)
!831 = !{!832, !833}
!832 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut complex::get_cipher_leak::{async_fn_env#0}", baseType: !656, size: 64, align: 64, dwarfAddressSpace: 0)
!833 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut &mut complex::get_cipher_leak::{async_fn_env#0}", baseType: !832, size: 64, align: 64, dwarfAddressSpace: 0)
!834 = !{!835}
!835 = !DILocalVariable(name: "self", arg: 1, scope: !826, file: !827, line: 277, type: !833)
!836 = !DILocation(line: 277, column: 18, scope: !826)
!837 = !DILocation(line: 278, column: 9, scope: !826)
!838 = !DILocation(line: 279, column: 6, scope: !826)
!839 = distinct !DISubprogram(name: "deref_mut<complex::get_cipher::{async_fn_env#0}>", linkageName: "_ZN60_$LT$$RF$mut$u20$T$u20$as$u20$core..ops..deref..DerefMut$GT$9deref_mut17h6db209943f744ab6E", scope: !828, file: !827, line: 277, type: !840, scopeLine: 277, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !626, retainedNodes: !844)
!840 = !DISubroutineType(types: !841)
!841 = !{!842, !843}
!842 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut complex::get_cipher::{async_fn_env#0}", baseType: !540, size: 64, align: 64, dwarfAddressSpace: 0)
!843 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut &mut complex::get_cipher::{async_fn_env#0}", baseType: !842, size: 64, align: 64, dwarfAddressSpace: 0)
!844 = !{!845}
!845 = !DILocalVariable(name: "self", arg: 1, scope: !839, file: !827, line: 277, type: !843)
!846 = !DILocation(line: 277, column: 18, scope: !839)
!847 = !DILocation(line: 278, column: 9, scope: !839)
!848 = !DILocation(line: 279, column: 6, scope: !839)
!849 = distinct !DISubprogram(name: "drop", linkageName: "_ZN65_$LT$core..task..wake..Waker$u20$as$u20$core..ops..drop..Drop$GT$4drop17h4002d96cd0cf52c0E", scope: !850, file: !737, line: 650, type: !851, scopeLine: 650, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !854)
!850 = !DINamespace(name: "{impl#10}", scope: !29)
!851 = !DISubroutineType(types: !852)
!852 = !{null, !853}
!853 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut core::task::wake::Waker", baseType: !408, size: 64, align: 64, dwarfAddressSpace: 0)
!854 = !{!855}
!855 = !DILocalVariable(name: "self", arg: 1, scope: !849, file: !737, line: 650, type: !853)
!856 = !DILocation(line: 650, column: 13, scope: !849)
!857 = !DILocation(line: 654, column: 18, scope: !849)
!858 = !DILocation(line: 654, column: 43, scope: !849)
!859 = !DILocation(line: 655, column: 6, scope: !849)
!860 = distinct !DISubprogram(name: "find", linkageName: "_ZN7complex4find17haf8990b269cad525E", scope: !26, file: !27, line: 12, type: !861, scopeLine: 12, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !863)
!861 = !DISubroutineType(types: !862)
!862 = !{!420, !233}
!863 = !{!864}
!864 = !DILocalVariable(name: "id", arg: 1, scope: !860, file: !27, line: 12, type: !233)
!865 = !DILocation(line: 12, column: 19, scope: !860)
!866 = !DILocation(line: 12, column: 46, scope: !860)
!867 = !DILocation(line: 14, column: 2, scope: !860)
!868 = distinct !DISubprogram(name: "{async_fn#0}", linkageName: "_ZN7complex4find28_$u7b$$u7b$closure$u7d$$u7d$17hd3aa913d703a15e1E", scope: !421, file: !27, line: 12, type: !869, scopeLine: 12, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !892)
!869 = !DISubroutineType(types: !870)
!870 = !{!871, !885, !440}
!871 = !DICompositeType(tag: DW_TAG_structure_type, name: "Poll<core::option::Option<complex::Cipher>>", scope: !872, file: !2, size: 192, align: 64, flags: DIFlagPublic, elements: !873, templateParams: !23, identifier: "f55b473c1cc93a5e68abcadcb87b0206")
!872 = !DINamespace(name: "poll", scope: !30)
!873 = !{!874}
!874 = !DICompositeType(tag: DW_TAG_variant_part, scope: !871, file: !2, size: 192, align: 64, elements: !875, templateParams: !23, identifier: "d9a0ed00463674fcd6146f7a69b4f430", discriminator: !884)
!875 = !{!876, !882}
!876 = !DIDerivedType(tag: DW_TAG_member, name: "Ready", scope: !874, file: !2, baseType: !877, size: 192, align: 64)
!877 = !DICompositeType(tag: DW_TAG_structure_type, name: "Ready", scope: !871, file: !2, size: 192, align: 64, flags: DIFlagPublic, elements: !878, templateParams: !880, identifier: "17195d683de60d601bdf84633d458500")
!878 = !{!879}
!879 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !877, file: !2, baseType: !604, size: 192, align: 64, flags: DIFlagPublic)
!880 = !{!881}
!881 = !DITemplateTypeParameter(name: "T", type: !604)
!882 = !DIDerivedType(tag: DW_TAG_member, name: "Pending", scope: !874, file: !2, baseType: !883, size: 192, align: 64, extraData: i64 2)
!883 = !DICompositeType(tag: DW_TAG_structure_type, name: "Pending", scope: !871, file: !2, size: 192, align: 64, flags: DIFlagPublic, elements: !23, templateParams: !880, identifier: "2498f0a71f4d39d980ef7e6a1a807f2e")
!884 = !DIDerivedType(tag: DW_TAG_member, scope: !871, file: !2, baseType: !233, size: 64, align: 64, flags: DIFlagArtificial)
!885 = !DICompositeType(tag: DW_TAG_structure_type, name: "Pin<&mut complex::find::{async_fn_env#0}>", scope: !886, file: !2, size: 64, align: 64, flags: DIFlagPublic, elements: !887, templateParams: !890, identifier: "a2cbb7c56452476631d02f14ff9a38dc")
!886 = !DINamespace(name: "pin", scope: !31)
!887 = !{!888}
!888 = !DIDerivedType(tag: DW_TAG_member, name: "__pointer", scope: !885, file: !2, baseType: !889, size: 64, align: 64, flags: DIFlagPublic)
!889 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut complex::find::{async_fn_env#0}", baseType: !420, size: 64, align: 64, dwarfAddressSpace: 0)
!890 = !{!891}
!891 = !DITemplateTypeParameter(name: "Ptr", type: !889)
!892 = !{!893, !894, !895}
!893 = !DILocalVariable(name: "_task_context", scope: !868, file: !27, line: 12, type: !440, align: 64)
!894 = !DILocalVariable(name: "id", scope: !868, file: !27, line: 12, type: !233, align: 64)
!895 = !DILocalVariable(name: "id", scope: !896, file: !27, line: 12, type: !233, align: 64)
!896 = distinct !DILexicalBlock(scope: !868, file: !27, line: 12, column: 46)
!897 = !DILocation(line: 12, column: 19, scope: !868)
!898 = !DILocation(line: 12, column: 46, scope: !868)
!899 = !DILocation(line: 12, column: 19, scope: !896)
!900 = !DILocation(line: 13, column: 8, scope: !896)
!901 = !DILocation(line: 13, column: 40, scope: !896)
!902 = !DILocation(line: 13, column: 5, scope: !896)
!903 = !DILocation(line: 13, column: 54, scope: !896)
!904 = !DILocation(line: 14, column: 2, scope: !868)
!905 = distinct !DISubprogram(name: "is_accessible", linkageName: "_ZN7complex13is_accessible17h8024ac0a7b498c2bE", scope: !26, file: !27, line: 17, type: !906, scopeLine: 17, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !908)
!906 = !DISubroutineType(types: !907)
!907 = !{!567, !513}
!908 = !{!909}
!909 = !DILocalVariable(name: "c", arg: 1, scope: !905, file: !27, line: 17, type: !513)
!910 = !DILocation(line: 17, column: 28, scope: !905)
!911 = !DILocation(line: 17, column: 48, scope: !905)
!912 = !DILocation(line: 19, column: 2, scope: !905)
!913 = distinct !DISubprogram(name: "{async_fn#0}", linkageName: "_ZN7complex13is_accessible28_$u7b$$u7b$closure$u7d$$u7d$17h7f4e417166478207E", scope: !568, file: !27, line: 17, type: !914, scopeLine: 17, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !935)
!914 = !DISubroutineType(types: !915)
!915 = !{!916, !929, !440}
!916 = !DICompositeType(tag: DW_TAG_structure_type, name: "Poll<bool>", scope: !872, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !917, templateParams: !23, identifier: "cff26969140a0063f2fdc29137cfcfc9")
!917 = !{!918}
!918 = !DICompositeType(tag: DW_TAG_variant_part, scope: !916, file: !2, size: 8, align: 8, elements: !919, templateParams: !23, identifier: "e060d9a19f60bf1f7b1c064bf35a3dc3", discriminator: !928)
!919 = !{!920, !926}
!920 = !DIDerivedType(tag: DW_TAG_member, name: "Ready", scope: !918, file: !2, baseType: !921, size: 8, align: 8)
!921 = !DICompositeType(tag: DW_TAG_structure_type, name: "Ready", scope: !916, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !922, templateParams: !924, identifier: "47780e447b0c39a22675c1eb0e4c0249")
!922 = !{!923}
!923 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !921, file: !2, baseType: !621, size: 8, align: 8, flags: DIFlagPublic)
!924 = !{!925}
!925 = !DITemplateTypeParameter(name: "T", type: !621)
!926 = !DIDerivedType(tag: DW_TAG_member, name: "Pending", scope: !918, file: !2, baseType: !927, size: 8, align: 8, extraData: i8 2)
!927 = !DICompositeType(tag: DW_TAG_structure_type, name: "Pending", scope: !916, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !23, templateParams: !924, identifier: "193ac986d0a34434f947c9f13b7c9455")
!928 = !DIDerivedType(tag: DW_TAG_member, scope: !916, file: !2, baseType: !58, size: 8, align: 8, flags: DIFlagArtificial)
!929 = !DICompositeType(tag: DW_TAG_structure_type, name: "Pin<&mut complex::is_accessible::{async_fn_env#0}>", scope: !886, file: !2, size: 64, align: 64, flags: DIFlagPublic, elements: !930, templateParams: !933, identifier: "715c961904b4d992d403505e6aa024b8")
!930 = !{!931}
!931 = !DIDerivedType(tag: DW_TAG_member, name: "__pointer", scope: !929, file: !2, baseType: !932, size: 64, align: 64, flags: DIFlagPublic)
!932 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut complex::is_accessible::{async_fn_env#0}", baseType: !567, size: 64, align: 64, dwarfAddressSpace: 0)
!933 = !{!934}
!934 = !DITemplateTypeParameter(name: "Ptr", type: !932)
!935 = !{!936, !937, !938}
!936 = !DILocalVariable(name: "_task_context", scope: !913, file: !27, line: 17, type: !440, align: 64)
!937 = !DILocalVariable(name: "c", scope: !913, file: !27, line: 17, type: !513, align: 64)
!938 = !DILocalVariable(name: "c", scope: !939, file: !27, line: 17, type: !513, align: 64)
!939 = distinct !DILexicalBlock(scope: !913, file: !27, line: 17, column: 48)
!940 = !DILocation(line: 17, column: 28, scope: !913)
!941 = !DILocation(line: 17, column: 48, scope: !913)
!942 = !DILocation(line: 17, column: 28, scope: !939)
!943 = !DILocation(line: 18, column: 5, scope: !939)
!944 = !DILocation(line: 19, column: 2, scope: !913)
!945 = distinct !DISubprogram(name: "to_json", linkageName: "_ZN7complex7to_json17h94dc01aa3ab612bfE", scope: !26, file: !27, line: 22, type: !946, scopeLine: 22, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !948)
!946 = !DISubroutineType(types: !947)
!947 = !{!504, !513}
!948 = !{!949}
!949 = !DILocalVariable(name: "c", arg: 1, scope: !945, file: !27, line: 22, type: !513)
!950 = !DILocation(line: 22, column: 22, scope: !945)
!951 = !DILocation(line: 22, column: 41, scope: !945)
!952 = !DILocation(line: 24, column: 2, scope: !945)
!953 = distinct !DISubprogram(name: "{async_fn#0}", linkageName: "_ZN7complex7to_json28_$u7b$$u7b$closure$u7d$$u7d$17hacd03f5bf5fe9b3eE", scope: !505, file: !27, line: 22, type: !954, scopeLine: 22, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !973)
!954 = !DISubroutineType(types: !955)
!955 = !{!956, !967, !440}
!956 = !DICompositeType(tag: DW_TAG_structure_type, name: "Poll<u64>", scope: !872, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !957, templateParams: !23, identifier: "fd7ca46c7b46b12265346e23d6f8122f")
!957 = !{!958}
!958 = !DICompositeType(tag: DW_TAG_variant_part, scope: !956, file: !2, size: 128, align: 64, elements: !959, templateParams: !23, identifier: "63d10a44c466772f33dc7f31428bf819", discriminator: !966)
!959 = !{!960, !964}
!960 = !DIDerivedType(tag: DW_TAG_member, name: "Ready", scope: !958, file: !2, baseType: !961, size: 128, align: 64, extraData: i64 0)
!961 = !DICompositeType(tag: DW_TAG_structure_type, name: "Ready", scope: !956, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !962, templateParams: !261, identifier: "418916aa3b6039b73b6dc1b90401a67a")
!962 = !{!963}
!963 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !961, file: !2, baseType: !233, size: 64, align: 64, offset: 64, flags: DIFlagPublic)
!964 = !DIDerivedType(tag: DW_TAG_member, name: "Pending", scope: !958, file: !2, baseType: !965, size: 128, align: 64, extraData: i64 1)
!965 = !DICompositeType(tag: DW_TAG_structure_type, name: "Pending", scope: !956, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !23, templateParams: !261, identifier: "bca0f410ead09e2cce9615d35019729b")
!966 = !DIDerivedType(tag: DW_TAG_member, scope: !956, file: !2, baseType: !233, size: 64, align: 64, flags: DIFlagArtificial)
!967 = !DICompositeType(tag: DW_TAG_structure_type, name: "Pin<&mut complex::to_json::{async_fn_env#0}>", scope: !886, file: !2, size: 64, align: 64, flags: DIFlagPublic, elements: !968, templateParams: !971, identifier: "312aab3abb106e527d2f4f27d721d946")
!968 = !{!969}
!969 = !DIDerivedType(tag: DW_TAG_member, name: "__pointer", scope: !967, file: !2, baseType: !970, size: 64, align: 64, flags: DIFlagPublic)
!970 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut complex::to_json::{async_fn_env#0}", baseType: !504, size: 64, align: 64, dwarfAddressSpace: 0)
!971 = !{!972}
!972 = !DITemplateTypeParameter(name: "Ptr", type: !970)
!973 = !{!974, !975, !976}
!974 = !DILocalVariable(name: "_task_context", scope: !953, file: !27, line: 22, type: !440, align: 64)
!975 = !DILocalVariable(name: "c", scope: !953, file: !27, line: 22, type: !513, align: 64)
!976 = !DILocalVariable(name: "c", scope: !977, file: !27, line: 22, type: !513, align: 64)
!977 = distinct !DILexicalBlock(scope: !953, file: !27, line: 22, column: 41)
!978 = !DILocation(line: 22, column: 22, scope: !953)
!979 = !DILocation(line: 22, column: 41, scope: !953)
!980 = !DILocation(line: 22, column: 22, scope: !977)
!981 = !DILocation(line: 23, column: 5, scope: !977)
!982 = !DILocation(line: 24, column: 2, scope: !953)
!983 = distinct !DISubprogram(name: "get_cipher", linkageName: "_ZN7complex10get_cipher17hea18acf247484af6E", scope: !26, file: !27, line: 28, type: !984, scopeLine: 28, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !986)
!984 = !DISubroutineType(types: !985)
!985 = !{!540, !233}
!986 = !{!987}
!987 = !DILocalVariable(name: "id", arg: 1, scope: !983, file: !27, line: 28, type: !233)
!988 = !DILocation(line: 28, column: 25, scope: !983)
!989 = !DILocation(line: 28, column: 41, scope: !983)
!990 = !DILocation(line: 34, column: 2, scope: !983)
!991 = distinct !DISubprogram(name: "{async_fn#0}", linkageName: "_ZN7complex10get_cipher28_$u7b$$u7b$closure$u7d$$u7d$17h5d71340cd33ec17aE", scope: !541, file: !27, line: 28, type: !992, scopeLine: 28, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !999)
!992 = !DISubroutineType(types: !993)
!993 = !{!956, !994, !440}
!994 = !DICompositeType(tag: DW_TAG_structure_type, name: "Pin<&mut complex::get_cipher::{async_fn_env#0}>", scope: !886, file: !2, size: 64, align: 64, flags: DIFlagPublic, elements: !995, templateParams: !997, identifier: "79e14b434564cb0306435bf1d873c70")
!995 = !{!996}
!996 = !DIDerivedType(tag: DW_TAG_member, name: "__pointer", scope: !994, file: !2, baseType: !842, size: 64, align: 64, flags: DIFlagPublic)
!997 = !{!998}
!998 = !DITemplateTypeParameter(name: "Ptr", type: !842)
!999 = !{!1000, !1001, !1002, !1004, !1006, !1008, !1010, !1012, !1014, !1016, !1018}
!1000 = !DILocalVariable(name: "_task_context", scope: !991, file: !27, line: 28, type: !440, align: 64)
!1001 = !DILocalVariable(name: "id", scope: !991, file: !27, line: 28, type: !233, align: 64)
!1002 = !DILocalVariable(name: "id", scope: !1003, file: !27, line: 28, type: !233, align: 64)
!1003 = distinct !DILexicalBlock(scope: !991, file: !27, line: 28, column: 41)
!1004 = !DILocalVariable(name: "c", scope: !1005, file: !27, line: 29, type: !514, align: 64)
!1005 = distinct !DILexicalBlock(scope: !1003, file: !27, line: 29, column: 5)
!1006 = !DILocalVariable(name: "__awaitee", scope: !1007, file: !27, line: 29, type: !420, align: 64)
!1007 = distinct !DILexicalBlock(scope: !1003, file: !27, line: 29, column: 28)
!1008 = !DILocalVariable(name: "result", scope: !1009, file: !27, line: 29, type: !604, align: 64)
!1009 = distinct !DILexicalBlock(scope: !1007, file: !27, line: 29, column: 19)
!1010 = !DILocalVariable(name: "__awaitee", scope: !1011, file: !27, line: 30, type: !567, align: 64)
!1011 = distinct !DILexicalBlock(scope: !1005, file: !27, line: 30, column: 27)
!1012 = !DILocalVariable(name: "result", scope: !1013, file: !27, line: 30, type: !621, align: 8)
!1013 = distinct !DILexicalBlock(scope: !1011, file: !27, line: 30, column: 9)
!1014 = !DILocalVariable(name: "__awaitee", scope: !1015, file: !27, line: 33, type: !504, align: 64)
!1015 = distinct !DILexicalBlock(scope: !1005, file: !27, line: 33, column: 17)
!1016 = !DILocalVariable(name: "result", scope: !1017, file: !27, line: 33, type: !233, align: 64)
!1017 = distinct !DILexicalBlock(scope: !1015, file: !27, line: 33, column: 5)
!1018 = !DILocalVariable(arg: 2, scope: !991, file: !27, line: 28, type: !440)
!1019 = !DILocation(line: 28, column: 25, scope: !991)
!1020 = !DILocation(line: 29, column: 14, scope: !1005)
!1021 = !DILocation(line: 29, column: 19, scope: !1007)
!1022 = !DILocation(line: 30, column: 9, scope: !1011)
!1023 = !DILocation(line: 33, column: 5, scope: !1015)
!1024 = !DILocation(line: 28, column: 41, scope: !991)
!1025 = !DILocation(line: 29, column: 19, scope: !1009)
!1026 = !DILocation(line: 0, scope: !991)
!1027 = !DILocation(line: 28, column: 25, scope: !1003)
!1028 = !DILocation(line: 29, column: 19, scope: !1003)
!1029 = !DILocation(line: 29, column: 28, scope: !1007)
!1030 = !DILocation(line: 30, column: 27, scope: !1011)
!1031 = !DILocation(line: 33, column: 17, scope: !1015)
!1032 = !DILocation(line: 29, column: 28, scope: !1003)
!1033 = !DILocalVariable(name: "pointer", arg: 1, scope: !1034, file: !1035, line: 1357, type: !889)
!1034 = distinct !DISubprogram(name: "new_unchecked<&mut complex::find::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$13new_unchecked17h7b6a09eb71c8d6b6E", scope: !885, file: !1035, line: 1357, type: !1036, scopeLine: 1357, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !890, declaration: !1038, retainedNodes: !1039)
!1035 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/pin.rs", directory: "", checksumkind: CSK_MD5, checksum: "188547841d616971e1bd37e3195159d3")
!1036 = !DISubroutineType(types: !1037)
!1037 = !{!885, !889}
!1038 = !DISubprogram(name: "new_unchecked<&mut complex::find::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$13new_unchecked17h7b6a09eb71c8d6b6E", scope: !885, file: !1035, line: 1357, type: !1036, scopeLine: 1357, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !890)
!1039 = !{!1033}
!1040 = !DILocation(line: 1357, column: 39, scope: !1034, inlinedAt: !1041)
!1041 = distinct !DILocation(line: 29, column: 28, scope: !1007)
!1042 = !DILocation(line: 1359, column: 6, scope: !1034, inlinedAt: !1041)
!1043 = !DILocation(line: 29, column: 32, scope: !1003)
!1044 = !DILocation(line: 29, column: 9, scope: !1003)
!1045 = !DILocation(line: 29, column: 14, scope: !1003)
!1046 = !DILocation(line: 30, column: 23, scope: !1005)
!1047 = !DILocation(line: 30, column: 9, scope: !1005)
!1048 = !DILocation(line: 29, column: 48, scope: !1003)
!1049 = !DILocation(line: 29, column: 41, scope: !1003)
!1050 = !DILocation(line: 30, column: 27, scope: !1005)
!1051 = !DILocalVariable(name: "pointer", arg: 1, scope: !1052, file: !1035, line: 1357, type: !932)
!1052 = distinct !DISubprogram(name: "new_unchecked<&mut complex::is_accessible::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$13new_unchecked17h27973a5e33067893E", scope: !929, file: !1035, line: 1357, type: !1053, scopeLine: 1357, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !933, declaration: !1055, retainedNodes: !1056)
!1053 = !DISubroutineType(types: !1054)
!1054 = !{!929, !932}
!1055 = !DISubprogram(name: "new_unchecked<&mut complex::is_accessible::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$13new_unchecked17h27973a5e33067893E", scope: !929, file: !1035, line: 1357, type: !1053, scopeLine: 1357, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !933)
!1056 = !{!1051}
!1057 = !DILocation(line: 1357, column: 39, scope: !1052, inlinedAt: !1058)
!1058 = distinct !DILocation(line: 30, column: 27, scope: !1011)
!1059 = !DILocation(line: 1359, column: 6, scope: !1052, inlinedAt: !1058)
!1060 = !DILocation(line: 34, column: 2, scope: !991)
!1061 = !DILocation(line: 30, column: 31, scope: !1005)
!1062 = !DILocation(line: 30, column: 9, scope: !1013)
!1063 = !DILocation(line: 31, column: 16, scope: !1005)
!1064 = !DILocation(line: 0, scope: !1003)
!1065 = !DILocation(line: 33, column: 13, scope: !1005)
!1066 = !DILocation(line: 33, column: 5, scope: !1005)
!1067 = !DILocation(line: 33, column: 17, scope: !1005)
!1068 = !DILocalVariable(name: "pointer", arg: 1, scope: !1069, file: !1035, line: 1357, type: !970)
!1069 = distinct !DISubprogram(name: "new_unchecked<&mut complex::to_json::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$13new_unchecked17h93f53621b793b619E", scope: !967, file: !1035, line: 1357, type: !1070, scopeLine: 1357, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !971, declaration: !1072, retainedNodes: !1073)
!1070 = !DISubroutineType(types: !1071)
!1071 = !{!967, !970}
!1072 = !DISubprogram(name: "new_unchecked<&mut complex::to_json::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$13new_unchecked17h93f53621b793b619E", scope: !967, file: !1035, line: 1357, type: !1070, scopeLine: 1357, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !971)
!1073 = !{!1068}
!1074 = !DILocation(line: 1357, column: 39, scope: !1069, inlinedAt: !1075)
!1075 = distinct !DILocation(line: 33, column: 17, scope: !1015)
!1076 = !DILocation(line: 1359, column: 6, scope: !1069, inlinedAt: !1075)
!1077 = !DILocation(line: 33, column: 21, scope: !1005)
!1078 = !DILocation(line: 33, column: 5, scope: !1017)
!1079 = distinct !DISubprogram(name: "get_cipher_leak", linkageName: "_ZN7complex15get_cipher_leak17h97d4073ba6d160ebE", scope: !26, file: !27, line: 38, type: !1080, scopeLine: 38, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !1082)
!1080 = !DISubroutineType(types: !1081)
!1081 = !{!656, !233}
!1082 = !{!1083}
!1083 = !DILocalVariable(name: "id", arg: 1, scope: !1079, file: !27, line: 38, type: !233)
!1084 = !DILocation(line: 38, column: 30, scope: !1079)
!1085 = !DILocation(line: 38, column: 46, scope: !1079)
!1086 = !DILocation(line: 41, column: 2, scope: !1079)
!1087 = distinct !DISubprogram(name: "{async_fn#0}", linkageName: "_ZN7complex15get_cipher_leak28_$u7b$$u7b$closure$u7d$$u7d$17h103fd8bb17b8e4b5E", scope: !657, file: !27, line: 38, type: !1088, scopeLine: 38, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !1095)
!1088 = !DISubroutineType(types: !1089)
!1089 = !{!956, !1090, !440}
!1090 = !DICompositeType(tag: DW_TAG_structure_type, name: "Pin<&mut complex::get_cipher_leak::{async_fn_env#0}>", scope: !886, file: !2, size: 64, align: 64, flags: DIFlagPublic, elements: !1091, templateParams: !1093, identifier: "7915fc35d0ec0f55bb037c04b92435c9")
!1091 = !{!1092}
!1092 = !DIDerivedType(tag: DW_TAG_member, name: "__pointer", scope: !1090, file: !2, baseType: !832, size: 64, align: 64, flags: DIFlagPublic)
!1093 = !{!1094}
!1094 = !DITemplateTypeParameter(name: "Ptr", type: !832)
!1095 = !{!1096, !1097, !1098, !1100, !1102, !1104, !1106, !1108, !1110}
!1096 = !DILocalVariable(name: "_task_context", scope: !1087, file: !27, line: 38, type: !440, align: 64)
!1097 = !DILocalVariable(name: "id", scope: !1087, file: !27, line: 38, type: !233, align: 64)
!1098 = !DILocalVariable(name: "id", scope: !1099, file: !27, line: 38, type: !233, align: 64)
!1099 = distinct !DILexicalBlock(scope: !1087, file: !27, line: 38, column: 46)
!1100 = !DILocalVariable(name: "c", scope: !1101, file: !27, line: 39, type: !514, align: 64)
!1101 = distinct !DILexicalBlock(scope: !1099, file: !27, line: 39, column: 5)
!1102 = !DILocalVariable(name: "__awaitee", scope: !1103, file: !27, line: 39, type: !420, align: 64)
!1103 = distinct !DILexicalBlock(scope: !1099, file: !27, line: 39, column: 28)
!1104 = !DILocalVariable(name: "result", scope: !1105, file: !27, line: 39, type: !604, align: 64)
!1105 = distinct !DILexicalBlock(scope: !1103, file: !27, line: 39, column: 19)
!1106 = !DILocalVariable(name: "__awaitee", scope: !1107, file: !27, line: 40, type: !504, align: 64)
!1107 = distinct !DILexicalBlock(scope: !1101, file: !27, line: 40, column: 17)
!1108 = !DILocalVariable(name: "result", scope: !1109, file: !27, line: 40, type: !233, align: 64)
!1109 = distinct !DILexicalBlock(scope: !1107, file: !27, line: 40, column: 5)
!1110 = !DILocalVariable(arg: 2, scope: !1087, file: !27, line: 38, type: !440)
!1111 = !DILocation(line: 38, column: 30, scope: !1087)
!1112 = !DILocation(line: 39, column: 14, scope: !1101)
!1113 = !DILocation(line: 39, column: 19, scope: !1103)
!1114 = !DILocation(line: 40, column: 5, scope: !1107)
!1115 = !DILocation(line: 38, column: 46, scope: !1087)
!1116 = !DILocation(line: 39, column: 19, scope: !1105)
!1117 = !DILocation(line: 0, scope: !1087)
!1118 = !DILocation(line: 38, column: 30, scope: !1099)
!1119 = !DILocation(line: 39, column: 19, scope: !1099)
!1120 = !DILocation(line: 39, column: 28, scope: !1103)
!1121 = !DILocation(line: 40, column: 17, scope: !1107)
!1122 = !DILocation(line: 39, column: 28, scope: !1099)
!1123 = !DILocation(line: 1357, column: 39, scope: !1034, inlinedAt: !1124)
!1124 = distinct !DILocation(line: 39, column: 28, scope: !1103)
!1125 = !DILocation(line: 1359, column: 6, scope: !1034, inlinedAt: !1124)
!1126 = !DILocation(line: 39, column: 32, scope: !1099)
!1127 = !DILocation(line: 39, column: 9, scope: !1099)
!1128 = !DILocation(line: 39, column: 14, scope: !1099)
!1129 = !DILocation(line: 40, column: 13, scope: !1101)
!1130 = !DILocation(line: 40, column: 5, scope: !1101)
!1131 = !DILocation(line: 39, column: 48, scope: !1099)
!1132 = !DILocation(line: 41, column: 1, scope: !1087)
!1133 = !DILocation(line: 40, column: 17, scope: !1101)
!1134 = !DILocation(line: 1357, column: 39, scope: !1069, inlinedAt: !1135)
!1135 = distinct !DILocation(line: 40, column: 17, scope: !1107)
!1136 = !DILocation(line: 1359, column: 6, scope: !1069, inlinedAt: !1135)
!1137 = !DILocation(line: 41, column: 2, scope: !1087)
!1138 = !DILocation(line: 40, column: 21, scope: !1101)
!1139 = !DILocation(line: 40, column: 5, scope: !1109)
!1140 = distinct !DISubprogram(name: "noop", linkageName: "_ZN7complex4noop17h9534ba82ba052afdE", scope: !26, file: !27, line: 43, type: !44, scopeLine: 43, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !1141)
!1141 = !{!1142}
!1142 = !DILocalVariable(arg: 1, scope: !1140, file: !27, line: 43, type: !6)
!1143 = !DILocation(line: 43, column: 9, scope: !1140)
!1144 = !DILocation(line: 43, column: 25, scope: !1140)
!1145 = distinct !DISubprogram(name: "clone_w", linkageName: "_ZN7complex7clone_w17hdda8073de8df6721E", scope: !26, file: !27, line: 44, type: !35, scopeLine: 44, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !1146)
!1146 = !{!1147}
!1147 = !DILocalVariable(arg: 1, scope: !1145, file: !27, line: 44, type: !6)
!1148 = !DILocation(line: 44, column: 12, scope: !1145)
!1149 = !DILocation(line: 44, column: 40, scope: !1145)
!1150 = !DILocation(line: 44, column: 78, scope: !1145)
!1151 = distinct !DISubprogram(name: "block_on<complex::get_cipher::{async_fn_env#0}>", linkageName: "_ZN7complex8block_on17h0336e71cdf6382bbE", scope: !26, file: !27, line: 46, type: !1152, scopeLine: 46, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !1164, retainedNodes: !1154)
!1152 = !DISubroutineType(types: !1153)
!1153 = !{!233, !540}
!1154 = !{!1155, !1156, !1158, !1160, !1162}
!1155 = !DILocalVariable(name: "f", arg: 1, scope: !1151, file: !27, line: 46, type: !540)
!1156 = !DILocalVariable(name: "f", scope: !1157, file: !27, line: 47, type: !994, align: 64)
!1157 = distinct !DILexicalBlock(scope: !1151, file: !27, line: 47, column: 5)
!1158 = !DILocalVariable(name: "w", scope: !1159, file: !27, line: 48, type: !408, align: 64)
!1159 = distinct !DILexicalBlock(scope: !1157, file: !27, line: 48, column: 5)
!1160 = !DILocalVariable(name: "cx", scope: !1161, file: !27, line: 49, type: !441, align: 64)
!1161 = distinct !DILexicalBlock(scope: !1159, file: !27, line: 49, column: 5)
!1162 = !DILocalVariable(name: "v", scope: !1163, file: !27, line: 50, type: !233, align: 64)
!1163 = distinct !DILexicalBlock(scope: !1161, file: !27, line: 50, column: 61)
!1164 = !{!1165}
!1165 = !DITemplateTypeParameter(name: "F", type: !540)
!1166 = !DILocation(line: 46, column: 24, scope: !1151)
!1167 = !DILocation(line: 47, column: 9, scope: !1157)
!1168 = !DILocation(line: 48, column: 9, scope: !1159)
!1169 = !DILocation(line: 49, column: 9, scope: !1161)
!1170 = !DILocation(line: 47, column: 22, scope: !1151)
!1171 = !DILocation(line: 47, column: 17, scope: !1151)
!1172 = !DILocation(line: 554, column: 2, scope: !1173, inlinedAt: !1176)
!1173 = distinct !DISubprogram(name: "null<()>", linkageName: "_ZN4core3ptr4null17ha047f93298e62516E", scope: !170, file: !404, line: 552, type: !1174, scopeLine: 552, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !80)
!1174 = !DISubroutineType(types: !1175)
!1175 = !{!6}
!1176 = distinct !DILocation(line: 48, column: 52, scope: !1157)
!1177 = !DILocation(line: 51, column: 1, scope: !1151)
!1178 = !DILocation(line: 48, column: 38, scope: !1157)
!1179 = !DILocation(line: 48, column: 22, scope: !1157)
!1180 = !DILocation(line: 49, column: 18, scope: !1159)
!1181 = !DILocation(line: 51, column: 1, scope: !1157)
!1182 = !DILocalVariable(name: "self", arg: 1, scope: !1183, file: !1035, line: 1414, type: !1186)
!1183 = distinct !DISubprogram(name: "as_mut<&mut complex::get_cipher::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17hd5a28efdfa7ea858E", scope: !994, file: !1035, line: 1414, type: !1184, scopeLine: 1414, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !997, declaration: !1187, retainedNodes: !1188)
!1184 = !DISubroutineType(types: !1185)
!1185 = !{!994, !1186}
!1186 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut core::pin::Pin<&mut complex::get_cipher::{async_fn_env#0}>", baseType: !994, size: 64, align: 64, dwarfAddressSpace: 0)
!1187 = !DISubprogram(name: "as_mut<&mut complex::get_cipher::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17hd5a28efdfa7ea858E", scope: !994, file: !1035, line: 1414, type: !1184, scopeLine: 1414, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !997)
!1188 = !{!1182}
!1189 = !DILocation(line: 1414, column: 19, scope: !1183, inlinedAt: !1190)
!1190 = distinct !DILocation(line: 50, column: 36, scope: !1163)
!1191 = !DILocation(line: 1416, column: 42, scope: !1183, inlinedAt: !1190)
!1192 = !DILocalVariable(name: "pointer", arg: 1, scope: !1193, file: !1035, line: 1357, type: !842)
!1193 = distinct !DISubprogram(name: "new_unchecked<&mut complex::get_cipher::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$13new_unchecked17hc61d7629ad8e0323E", scope: !994, file: !1035, line: 1357, type: !1194, scopeLine: 1357, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !997, declaration: !1196, retainedNodes: !1197)
!1194 = !DISubroutineType(types: !1195)
!1195 = !{!994, !842}
!1196 = !DISubprogram(name: "new_unchecked<&mut complex::get_cipher::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$13new_unchecked17hc61d7629ad8e0323E", scope: !994, file: !1035, line: 1357, type: !1194, scopeLine: 1357, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !997)
!1197 = !{!1192}
!1198 = !DILocation(line: 1357, column: 39, scope: !1193, inlinedAt: !1199)
!1199 = distinct !DILocation(line: 1416, column: 18, scope: !1183, inlinedAt: !1190)
!1200 = !DILocation(line: 1417, column: 6, scope: !1183, inlinedAt: !1190)
!1201 = !DILocation(line: 50, column: 36, scope: !1163)
!1202 = !DILocation(line: 50, column: 19, scope: !1163)
!1203 = !DILocation(line: 50, column: 31, scope: !1163)
!1204 = !DILocation(line: 50, column: 75, scope: !1161)
!1205 = !DILocation(line: 51, column: 2, scope: !1151)
!1206 = !DILocation(line: 46, column: 1, scope: !1151)
!1207 = distinct !DISubprogram(name: "block_on<complex::get_cipher_leak::{async_fn_env#0}>", linkageName: "_ZN7complex8block_on17h7b4f6a4b2b363256E", scope: !26, file: !27, line: 46, type: !1208, scopeLine: 46, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !1220, retainedNodes: !1210)
!1208 = !DISubroutineType(types: !1209)
!1209 = !{!233, !656}
!1210 = !{!1211, !1212, !1214, !1216, !1218}
!1211 = !DILocalVariable(name: "f", arg: 1, scope: !1207, file: !27, line: 46, type: !656)
!1212 = !DILocalVariable(name: "f", scope: !1213, file: !27, line: 47, type: !1090, align: 64)
!1213 = distinct !DILexicalBlock(scope: !1207, file: !27, line: 47, column: 5)
!1214 = !DILocalVariable(name: "w", scope: !1215, file: !27, line: 48, type: !408, align: 64)
!1215 = distinct !DILexicalBlock(scope: !1213, file: !27, line: 48, column: 5)
!1216 = !DILocalVariable(name: "cx", scope: !1217, file: !27, line: 49, type: !441, align: 64)
!1217 = distinct !DILexicalBlock(scope: !1215, file: !27, line: 49, column: 5)
!1218 = !DILocalVariable(name: "v", scope: !1219, file: !27, line: 50, type: !233, align: 64)
!1219 = distinct !DILexicalBlock(scope: !1217, file: !27, line: 50, column: 61)
!1220 = !{!1221}
!1221 = !DITemplateTypeParameter(name: "F", type: !656)
!1222 = !DILocation(line: 46, column: 24, scope: !1207)
!1223 = !DILocation(line: 47, column: 9, scope: !1213)
!1224 = !DILocation(line: 48, column: 9, scope: !1215)
!1225 = !DILocation(line: 49, column: 9, scope: !1217)
!1226 = !DILocation(line: 47, column: 22, scope: !1207)
!1227 = !DILocation(line: 47, column: 17, scope: !1207)
!1228 = !DILocation(line: 554, column: 2, scope: !1173, inlinedAt: !1229)
!1229 = distinct !DILocation(line: 48, column: 52, scope: !1213)
!1230 = !DILocation(line: 51, column: 1, scope: !1207)
!1231 = !DILocation(line: 48, column: 38, scope: !1213)
!1232 = !DILocation(line: 48, column: 22, scope: !1213)
!1233 = !DILocation(line: 49, column: 18, scope: !1215)
!1234 = !DILocation(line: 51, column: 1, scope: !1213)
!1235 = !DILocalVariable(name: "self", arg: 1, scope: !1236, file: !1035, line: 1414, type: !1239)
!1236 = distinct !DISubprogram(name: "as_mut<&mut complex::get_cipher_leak::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17h862ccf0b8adeb29cE", scope: !1090, file: !1035, line: 1414, type: !1237, scopeLine: 1414, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !1093, declaration: !1240, retainedNodes: !1241)
!1237 = !DISubroutineType(types: !1238)
!1238 = !{!1090, !1239}
!1239 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut core::pin::Pin<&mut complex::get_cipher_leak::{async_fn_env#0}>", baseType: !1090, size: 64, align: 64, dwarfAddressSpace: 0)
!1240 = !DISubprogram(name: "as_mut<&mut complex::get_cipher_leak::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17h862ccf0b8adeb29cE", scope: !1090, file: !1035, line: 1414, type: !1237, scopeLine: 1414, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !1093)
!1241 = !{!1235}
!1242 = !DILocation(line: 1414, column: 19, scope: !1236, inlinedAt: !1243)
!1243 = distinct !DILocation(line: 50, column: 36, scope: !1219)
!1244 = !DILocation(line: 1416, column: 42, scope: !1236, inlinedAt: !1243)
!1245 = !DILocalVariable(name: "pointer", arg: 1, scope: !1246, file: !1035, line: 1357, type: !832)
!1246 = distinct !DISubprogram(name: "new_unchecked<&mut complex::get_cipher_leak::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$13new_unchecked17hc0c1afa45eb18bb4E", scope: !1090, file: !1035, line: 1357, type: !1247, scopeLine: 1357, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !1093, declaration: !1249, retainedNodes: !1250)
!1247 = !DISubroutineType(types: !1248)
!1248 = !{!1090, !832}
!1249 = !DISubprogram(name: "new_unchecked<&mut complex::get_cipher_leak::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$13new_unchecked17hc0c1afa45eb18bb4E", scope: !1090, file: !1035, line: 1357, type: !1247, scopeLine: 1357, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !1093)
!1250 = !{!1245}
!1251 = !DILocation(line: 1357, column: 39, scope: !1246, inlinedAt: !1252)
!1252 = distinct !DILocation(line: 1416, column: 18, scope: !1236, inlinedAt: !1243)
!1253 = !DILocation(line: 1417, column: 6, scope: !1236, inlinedAt: !1243)
!1254 = !DILocation(line: 50, column: 36, scope: !1219)
!1255 = !DILocation(line: 50, column: 19, scope: !1219)
!1256 = !DILocation(line: 50, column: 31, scope: !1219)
!1257 = !DILocation(line: 50, column: 75, scope: !1217)
!1258 = !DILocation(line: 51, column: 2, scope: !1207)
!1259 = !DILocation(line: 46, column: 1, scope: !1207)
!1260 = distinct !DISubprogram(name: "main", linkageName: "_ZN7complex4main17h4d065abd446a5f7fE", scope: !26, file: !27, line: 53, type: !21, scopeLine: 53, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagMainSubprogram, unit: !53, templateParams: !23)
!1261 = !DILocation(line: 54, column: 40, scope: !1260)
!1262 = !DILocation(line: 54, column: 29, scope: !1260)
!1263 = !DILocation(line: 54, column: 20, scope: !1260)
!1264 = !DILocation(line: 54, column: 5, scope: !1260)
!1265 = !DILocation(line: 55, column: 45, scope: !1260)
!1266 = !DILocation(line: 55, column: 29, scope: !1260)
!1267 = !DILocation(line: 55, column: 20, scope: !1260)
!1268 = !DILocation(line: 55, column: 5, scope: !1260)
!1269 = !DILocation(line: 56, column: 2, scope: !1260)
