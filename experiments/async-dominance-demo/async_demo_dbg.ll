; ModuleID = 'async_demo.e4019b8fc89da6a0-cgu.0'
source_filename = "async_demo.e4019b8fc89da6a0-cgu.0"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx11.0.0"

%"core::fmt::rt::Argument<'_>" = type { %"core::fmt::rt::ArgumentType<'_>" }
%"core::fmt::rt::ArgumentType<'_>" = type { ptr, [1 x i64] }

@vtable.0 = private constant <{ [24 x i8], ptr, ptr, ptr }> <{ [24 x i8] c"\00\00\00\00\00\00\00\00\08\00\00\00\00\00\00\00\08\00\00\00\00\00\00\00", ptr @"_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h6c0bdd59af1e11d0E", ptr @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h1a80b0c598e554bdE", ptr @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h1a80b0c598e554bdE" }>, align 8, !dbg !0
@0 = private unnamed_addr constant <{ [8 x i8], [8 x i8] }> <{ [8 x i8] zeroinitializer, [8 x i8] undef }>, align 8
@alloc_9b4e9e43085ac0f53aeb180cd84a18a5 = private unnamed_addr constant <{ [13 x i8] }> <{ [13 x i8] c"async_demo.rs" }>, align 1
@alloc_0c60a0b639bba5d5bb27d6d85940911c = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_9b4e9e43085ac0f53aeb180cd84a18a5, [16 x i8] c"\0D\00\00\00\00\00\00\00\10\00\00\00.\00\00\00" }>, align 8
@alloc_96719ba215877693b51c89bc08a51cab = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_9b4e9e43085ac0f53aeb180cd84a18a5, [16 x i8] c"\0D\00\00\00\00\00\00\00\15\00\00\00+\00\00\00" }>, align 8
@alloc_3570fca4a3a20654e1fd5ca549d6abbe = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_9b4e9e43085ac0f53aeb180cd84a18a5, [16 x i8] c"\0D\00\00\00\00\00\00\00\1C\00\00\00+\00\00\00" }>, align 8
@alloc_0e7a629824c2ebe6fcd69a45c03fa5d5 = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_9b4e9e43085ac0f53aeb180cd84a18a5, [16 x i8] c"\0D\00\00\00\00\00\00\00%\00\00\00-\00\00\00" }>, align 8
@_ZN10async_demo2VT17h057c6809b0537861E = internal constant <{ ptr, ptr, ptr, ptr }> <{ ptr @_ZN10async_demo7clone_w17h237304af9c8bd529E, ptr @_ZN10async_demo4noop17h41a65d1e9ed40a73E, ptr @_ZN10async_demo4noop17h41a65d1e9ed40a73E, ptr @_ZN10async_demo4noop17h41a65d1e9ed40a73E }>, align 8, !dbg !24
@alloc_49a1e817e911805af64bbc7efb390101 = private unnamed_addr constant <{ [1 x i8] }> <{ [1 x i8] c"\0A" }>, align 1
@alloc_9771be2481f51be410bd2ac520d18601 = private unnamed_addr constant <{ ptr, [8 x i8], ptr, [8 x i8] }> <{ ptr inttoptr (i64 1 to ptr), [8 x i8] zeroinitializer, ptr @alloc_49a1e817e911805af64bbc7efb390101, [8 x i8] c"\01\00\00\00\00\00\00\00" }>, align 8

; std::rt::lang_start
; Function Attrs: uwtable
define hidden i64 @_ZN3std2rt10lang_start17hc3a208667dde6b6cE(ptr %main, i64 %argc, ptr %argv, i8 %sigpipe) unnamed_addr #0 !dbg !68 {
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
define internal i32 @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h1a80b0c598e554bdE"(ptr align 8 %_1) unnamed_addr #1 !dbg !89 {
start:
  %self.dbg.spill = alloca [1 x i8], align 1
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !95, !DIExpression(DW_OP_deref), !96)
  %_4 = load ptr, ptr %_1, align 8, !dbg !97
; call std::sys::backtrace::__rust_begin_short_backtrace
  call void @_ZN3std3sys9backtrace28__rust_begin_short_backtrace17hc83f88d1d2675206E(ptr %_4), !dbg !98
; call <() as std::process::Termination>::report
  %self = call i8 @"_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17h86c43eadf0bbce2fE"(), !dbg !98
  store i8 %self, ptr %self.dbg.spill, align 1, !dbg !98
    #dbg_declare(ptr %self.dbg.spill, !99, !DIExpression(), !118)
  %_0 = zext i8 %self to i32, !dbg !120
  ret i32 %_0, !dbg !128
}

; std::sys::backtrace::__rust_begin_short_backtrace
; Function Attrs: noinline uwtable
define internal void @_ZN3std3sys9backtrace28__rust_begin_short_backtrace17hc83f88d1d2675206E(ptr %f) unnamed_addr #2 !dbg !129 {
start:
  %dummy.dbg.spill = alloca [0 x i8], align 1
  %f.dbg.spill = alloca [8 x i8], align 8
  %result.dbg.spill = alloca [0 x i8], align 1
    #dbg_declare(ptr %result.dbg.spill, !136, !DIExpression(), !140)
  store ptr %f, ptr %f.dbg.spill, align 8
    #dbg_declare(ptr %f.dbg.spill, !135, !DIExpression(), !141)
    #dbg_declare(ptr %dummy.dbg.spill, !142, !DIExpression(), !149)
; call core::ops::function::FnOnce::call_once
  call void @_ZN4core3ops8function6FnOnce9call_once17he3bfffd33b8a6865E(ptr %f), !dbg !151
  call void asm sideeffect "", "~{memory}"(), !dbg !152, !srcloc !153
  ret void, !dbg !154
}

; core::fmt::rt::Argument::new_display
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3fmt2rt8Argument11new_display17h934768992fdcf840E(ptr sret([16 x i8]) align 8 %_0, ptr align 8 %x) unnamed_addr #1 !dbg !155 {
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
define internal void @_ZN4core3fmt9Arguments6new_v117h38409ea89cea9582E(ptr sret([48 x i8]) align 8 %_0, ptr align 8 %pieces, ptr align 8 %args) unnamed_addr #1 !dbg !293 {
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
define internal i32 @"_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h6c0bdd59af1e11d0E"(ptr %_1) unnamed_addr #1 !dbg !374 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  %_2 = alloca [0 x i8], align 1
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !383, !DIExpression(), !388)
    #dbg_declare(ptr %_2, !384, !DIExpression(), !388)
  %0 = load ptr, ptr %_1, align 8, !dbg !388
; call core::ops::function::FnOnce::call_once
  %_0 = call i32 @_ZN4core3ops8function6FnOnce9call_once17h1dfc07f73a005900E(ptr %0), !dbg !388
  ret i32 %_0, !dbg !388
}

; core::ops::function::FnOnce::call_once
; Function Attrs: inlinehint uwtable
define internal i32 @_ZN4core3ops8function6FnOnce9call_once17h1dfc07f73a005900E(ptr %0) unnamed_addr #1 personality ptr @rust_eh_personality !dbg !389 {
start:
  %1 = alloca [16 x i8], align 8
  %_2 = alloca [0 x i8], align 1
  %_1 = alloca [8 x i8], align 8
  store ptr %0, ptr %_1, align 8
    #dbg_declare(ptr %_1, !393, !DIExpression(), !395)
    #dbg_declare(ptr %_2, !394, !DIExpression(), !395)
; invoke std::rt::lang_start::{{closure}}
  %_0 = invoke i32 @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h1a80b0c598e554bdE"(ptr align 8 %_1)
          to label %bb1 unwind label %cleanup, !dbg !395

bb3:                                              ; preds = %cleanup
  %2 = load ptr, ptr %1, align 8, !dbg !395
  %3 = getelementptr inbounds i8, ptr %1, i64 8, !dbg !395
  %4 = load i32, ptr %3, align 8, !dbg !395
  %5 = insertvalue { ptr, i32 } poison, ptr %2, 0, !dbg !395
  %6 = insertvalue { ptr, i32 } %5, i32 %4, 1, !dbg !395
  resume { ptr, i32 } %6, !dbg !395

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
  ret i32 %_0, !dbg !395
}

; core::ops::function::FnOnce::call_once
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3ops8function6FnOnce9call_once17he3bfffd33b8a6865E(ptr %_1) unnamed_addr #1 !dbg !396 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  %_2 = alloca [0 x i8], align 1
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !398, !DIExpression(), !402)
    #dbg_declare(ptr %_2, !399, !DIExpression(), !402)
  call void %_1(), !dbg !402
  ret void, !dbg !402
}

; core::ptr::drop_in_place<core::task::wake::Waker>
; Function Attrs: uwtable
define internal void @"_ZN4core3ptr44drop_in_place$LT$core..task..wake..Waker$GT$17h4d1fa1153a381a05E"(ptr align 8 %_1) unnamed_addr #0 !dbg !403 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !412, !DIExpression(), !415)
; call <core::task::wake::Waker as core::ops::drop::Drop>::drop
  call void @"_ZN65_$LT$core..task..wake..Waker$u20$as$u20$core..ops..drop..Drop$GT$4drop17hb1138275daf8cdb4E"(ptr align 8 %_1), !dbg !415
  ret void, !dbg !415
}

; core::ptr::drop_in_place<async_demo::db_read::{{closure}}>
; Function Attrs: uwtable
define internal void @"_ZN4core3ptr69drop_in_place$LT$async_demo..db_read..$u7b$$u7b$closure$u7d$$u7d$$GT$17h7d9c75f079191aceE"(ptr align 8 %_1) unnamed_addr #0 !dbg !416 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !498, !DIExpression(DW_OP_deref), !503)
  %0 = getelementptr inbounds i8, ptr %_1, i64 8, !dbg !504
  %1 = load i8, ptr %0, align 8, !dbg !504
  %_8 = zext i8 %1 to i32, !dbg !504
  %2 = icmp eq i32 %_8, 0, !dbg !504
  br i1 %2, label %bb2, label %bb4, !dbg !504

bb2:                                              ; preds = %start
  ret void, !dbg !504

bb4:                                              ; preds = %start
  ret void, !dbg !504
}

; core::ptr::drop_in_place<async_demo::guarded::{{closure}}>
; Function Attrs: uwtable
define internal void @"_ZN4core3ptr69drop_in_place$LT$async_demo..guarded..$u7b$$u7b$closure$u7d$$u7d$$GT$17h29807675ee04bd5aE"(ptr align 8 %_1) unnamed_addr #0 personality ptr @rust_eh_personality !dbg !505 {
start:
  %0 = alloca [16 x i8], align 8
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !557, !DIExpression(DW_OP_deref), !571)
    #dbg_declare(ptr %_1.dbg.spill, !558, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 8), !572)
    #dbg_declare(ptr %_1.dbg.spill, !560, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 24), !573)
    #dbg_declare(ptr %_1.dbg.spill, !565, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 24), !574)
  %1 = getelementptr inbounds i8, ptr %_1, i64 16, !dbg !575
  %2 = load i8, ptr %1, align 8, !dbg !575
  %_42 = zext i8 %2 to i32, !dbg !575
  switch i32 %_42, label %bb21 [
    i32 0, label %bb16
    i32 3, label %bb19
    i32 4, label %bb20
  ], !dbg !575

bb21:                                             ; preds = %start
  ret void, !dbg !575

bb16:                                             ; preds = %start
  ret void, !dbg !575

bb19:                                             ; preds = %start
  %3 = getelementptr inbounds i8, ptr %_1, i64 24, !dbg !576
; invoke core::ptr::drop_in_place<async_demo::authorize::{{closure}}>
  invoke void @"_ZN4core3ptr71drop_in_place$LT$async_demo..authorize..$u7b$$u7b$closure$u7d$$u7d$$GT$17h162b842d851e2706E"(ptr align 8 %3)
          to label %bb5 unwind label %cleanup, !dbg !576

bb20:                                             ; preds = %start
  %4 = getelementptr inbounds i8, ptr %_1, i64 24, !dbg !577
; invoke core::ptr::drop_in_place<async_demo::db_read::{{closure}}>
  invoke void @"_ZN4core3ptr69drop_in_place$LT$async_demo..db_read..$u7b$$u7b$closure$u7d$$u7d$$GT$17h7d9c75f079191aceE"(ptr align 8 %4)
          to label %bb2 unwind label %cleanup1, !dbg !577

bb12:                                             ; preds = %cleanup
  br label %bb14, !dbg !578

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
  br label %bb7, !dbg !578

bb7:                                              ; preds = %bb2, %bb5
  ret void, !dbg !575

bb14:                                             ; preds = %bb10, %bb12
  %9 = load ptr, ptr %0, align 8, !dbg !575
  %10 = getelementptr inbounds i8, ptr %0, i64 8, !dbg !575
  %11 = load i32, ptr %10, align 8, !dbg !575
  %12 = insertvalue { ptr, i32 } poison, ptr %9, 0, !dbg !575
  %13 = insertvalue { ptr, i32 } %12, i32 %11, 1, !dbg !575
  resume { ptr, i32 } %13, !dbg !575

bb10:                                             ; preds = %cleanup1
  br label %bb14, !dbg !578

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
  br label %bb7, !dbg !578
}

; core::ptr::drop_in_place<async_demo::authorize::{{closure}}>
; Function Attrs: uwtable
define internal void @"_ZN4core3ptr71drop_in_place$LT$async_demo..authorize..$u7b$$u7b$closure$u7d$$u7d$$GT$17h162b842d851e2706E"(ptr align 8 %_1) unnamed_addr #0 !dbg !579 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !585, !DIExpression(DW_OP_deref), !590)
  %0 = getelementptr inbounds i8, ptr %_1, i64 8, !dbg !591
  %1 = load i8, ptr %0, align 8, !dbg !591
  %_9 = zext i8 %1 to i32, !dbg !591
  %2 = icmp eq i32 %_9, 0, !dbg !591
  br i1 %2, label %bb2, label %bb4, !dbg !591

bb2:                                              ; preds = %start
  ret void, !dbg !591

bb4:                                              ; preds = %start
  ret void, !dbg !591
}

; core::ptr::drop_in_place<async_demo::unguarded::{{closure}}>
; Function Attrs: uwtable
define internal void @"_ZN4core3ptr71drop_in_place$LT$async_demo..unguarded..$u7b$$u7b$closure$u7d$$u7d$$GT$17hd47c4069b6e3428cE"(ptr align 8 %_1) unnamed_addr #0 personality ptr @rust_eh_personality !dbg !592 {
start:
  %0 = alloca [16 x i8], align 8
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !621, !DIExpression(DW_OP_deref), !630)
    #dbg_declare(ptr %_1.dbg.spill, !624, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 8), !631)
  %1 = getelementptr inbounds i8, ptr %_1, i64 24, !dbg !632
  %2 = load i8, ptr %1, align 8, !dbg !632
  %_24 = zext i8 %2 to i32, !dbg !632
  switch i32 %_24, label %bb13 [
    i32 0, label %bb9
    i32 3, label %bb12
  ], !dbg !632

bb13:                                             ; preds = %start
  ret void, !dbg !632

bb9:                                              ; preds = %start
  ret void, !dbg !632

bb12:                                             ; preds = %start
  %3 = getelementptr inbounds i8, ptr %_1, i64 8, !dbg !633
; invoke core::ptr::drop_in_place<async_demo::db_read::{{closure}}>
  invoke void @"_ZN4core3ptr69drop_in_place$LT$async_demo..db_read..$u7b$$u7b$closure$u7d$$u7d$$GT$17h7d9c75f079191aceE"(ptr align 8 %3)
          to label %bb2 unwind label %cleanup, !dbg !633

bb6:                                              ; preds = %cleanup
  %4 = load ptr, ptr %0, align 8, !dbg !632
  %5 = getelementptr inbounds i8, ptr %0, i64 8, !dbg !632
  %6 = load i32, ptr %5, align 8, !dbg !632
  %7 = insertvalue { ptr, i32 } poison, ptr %4, 0, !dbg !632
  %8 = insertvalue { ptr, i32 } %7, i32 %6, 1, !dbg !632
  resume { ptr, i32 } %8, !dbg !632

cleanup:                                          ; preds = %bb12
  %9 = landingpad { ptr, i32 }
          cleanup
  %10 = extractvalue { ptr, i32 } %9, 0
  %11 = extractvalue { ptr, i32 } %9, 1
  store ptr %10, ptr %0, align 8
  %12 = getelementptr inbounds i8, ptr %0, i64 8
  store i32 %11, ptr %12, align 8
  br label %bb6

bb2:                                              ; preds = %bb12
  ret void, !dbg !632
}

; core::ptr::drop_in_place<std::rt::lang_start<()>::{{closure}}>
; Function Attrs: inlinehint uwtable
define internal void @"_ZN4core3ptr85drop_in_place$LT$std..rt..lang_start$LT$$LP$$RP$$GT$..$u7b$$u7b$closure$u7d$$u7d$$GT$17h41421d03cdbf9088E"(ptr align 8 %_1) unnamed_addr #1 !dbg !634 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !638, !DIExpression(), !641)
  ret void, !dbg !641
}

; core::hint::black_box
; Function Attrs: inlinehint uwtable
define internal align 8 ptr @_ZN4core4hint9black_box17h13e5c54c71dd8fc6E(ptr align 8 %dummy) unnamed_addr #1 !dbg !642 {
start:
  %0 = alloca [8 x i8], align 8
  %dummy.dbg.spill = alloca [8 x i8], align 8
  store ptr %dummy, ptr %dummy.dbg.spill, align 8
    #dbg_declare(ptr %dummy.dbg.spill, !646, !DIExpression(), !649)
  store ptr %dummy, ptr %0, align 8, !dbg !650
  call void asm sideeffect "", "r,~{memory}"(ptr %0), !dbg !650, !srcloc !153
  %_0 = load ptr, ptr %0, align 8, !dbg !650
  ret ptr %_0, !dbg !651
}

; core::hint::black_box
; Function Attrs: inlinehint uwtable
define internal i64 @_ZN4core4hint9black_box17h8f96ccdebaca3800E(i64 %dummy) unnamed_addr #1 !dbg !652 {
start:
  %0 = alloca [8 x i8], align 8
  %dummy.dbg.spill = alloca [8 x i8], align 8
  store i64 %dummy, ptr %dummy.dbg.spill, align 8
    #dbg_declare(ptr %dummy.dbg.spill, !656, !DIExpression(), !657)
  store i64 %dummy, ptr %0, align 8, !dbg !658
  call void asm sideeffect "", "r,~{memory}"(ptr %0), !dbg !658, !srcloc !153
  %_0 = load i64, ptr %0, align 8, !dbg !658
  ret i64 %_0, !dbg !659
}

; core::task::wake::Waker::from_raw
; Function Attrs: inlinehint uwtable
define internal { ptr, ptr } @_ZN4core4task4wake5Waker8from_raw17hfdc613e6f00adcadE(ptr align 8 %waker.0, ptr %waker.1) unnamed_addr #1 !dbg !660 {
start:
  %waker.dbg.spill = alloca [16 x i8], align 8
  store ptr %waker.0, ptr %waker.dbg.spill, align 8
  %0 = getelementptr inbounds i8, ptr %waker.dbg.spill, i64 8
  store ptr %waker.1, ptr %0, align 8
    #dbg_declare(ptr %waker.dbg.spill, !666, !DIExpression(), !667)
  %1 = insertvalue { ptr, ptr } poison, ptr %waker.0, 0, !dbg !668
  %2 = insertvalue { ptr, ptr } %1, ptr %waker.1, 1, !dbg !668
  ret { ptr, ptr } %2, !dbg !668
}

; core::task::wake::Context::from_waker
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core4task4wake7Context10from_waker17h4673ecefaeb55096E(ptr sret([32 x i8]) align 8 %_0, ptr align 8 %waker) unnamed_addr #1 !dbg !669 {
start:
  %waker.dbg.spill = alloca [8 x i8], align 8
  store ptr %waker, ptr %waker.dbg.spill, align 8
    #dbg_declare(ptr %waker.dbg.spill, !674, !DIExpression(), !675)
    #dbg_declare(ptr %waker.dbg.spill, !676, !DIExpression(), !689)
  store ptr %waker, ptr %_0, align 8, !dbg !691
  %0 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !691
  store ptr %waker, ptr %0, align 8, !dbg !691
  %1 = load ptr, ptr @0, align 8, !dbg !691
  %2 = load ptr, ptr getelementptr inbounds (i8, ptr @0, i64 8), align 8, !dbg !691
  %3 = getelementptr inbounds i8, ptr %_0, i64 16, !dbg !691
  store ptr %1, ptr %3, align 8, !dbg !691
  %4 = getelementptr inbounds i8, ptr %3, i64 8, !dbg !691
  store ptr %2, ptr %4, align 8, !dbg !691
  ret void, !dbg !697
}

; core::task::wake::RawWaker::new
; Function Attrs: inlinehint uwtable
define internal { ptr, ptr } @_ZN4core4task4wake8RawWaker3new17h97385b4012da4169E(ptr %data, ptr align 8 %vtable) unnamed_addr #1 !dbg !698 {
start:
  %vtable.dbg.spill = alloca [8 x i8], align 8
  %data.dbg.spill = alloca [8 x i8], align 8
  store ptr %data, ptr %data.dbg.spill, align 8
    #dbg_declare(ptr %data.dbg.spill, !703, !DIExpression(), !705)
  store ptr %vtable, ptr %vtable.dbg.spill, align 8
    #dbg_declare(ptr %vtable.dbg.spill, !704, !DIExpression(), !706)
  %0 = insertvalue { ptr, ptr } poison, ptr %vtable, 0, !dbg !707
  %1 = insertvalue { ptr, ptr } %0, ptr %data, 1, !dbg !707
  ret { ptr, ptr } %1, !dbg !707
}

; <() as std::process::Termination>::report
; Function Attrs: inlinehint uwtable
define internal i8 @"_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17h86c43eadf0bbce2fE"() unnamed_addr #1 !dbg !708 {
start:
  %_1.dbg.spill = alloca [0 x i8], align 1
    #dbg_declare(ptr %_1.dbg.spill, !713, !DIExpression(), !714)
  ret i8 0, !dbg !715
}

; <F as core::future::into_future::IntoFuture>::into_future
; Function Attrs: uwtable
define internal void @"_ZN59_$LT$F$u20$as$u20$core..future..into_future..IntoFuture$GT$11into_future17h3a4cc5be54bf241aE"(ptr sret([16 x i8]) align 8 %_0, ptr align 8 %self) unnamed_addr #0 !dbg !716 {
start:
    #dbg_declare(ptr %self, !724, !DIExpression(), !727)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_0, ptr align 8 %self, i64 16, i1 false), !dbg !728
  ret void, !dbg !729
}

; <F as core::future::into_future::IntoFuture>::into_future
; Function Attrs: uwtable
define internal void @"_ZN59_$LT$F$u20$as$u20$core..future..into_future..IntoFuture$GT$11into_future17h96dac5933a798099E"(ptr sret([16 x i8]) align 8 %_0, ptr align 8 %self) unnamed_addr #0 !dbg !730 {
start:
    #dbg_declare(ptr %self, !734, !DIExpression(), !737)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_0, ptr align 8 %self, i64 16, i1 false), !dbg !738
  ret void, !dbg !739
}

; <&mut T as core::ops::deref::DerefMut>::deref_mut
; Function Attrs: uwtable
define internal align 8 ptr @"_ZN60_$LT$$RF$mut$u20$T$u20$as$u20$core..ops..deref..DerefMut$GT$9deref_mut17hd752dc04218d67fbE"(ptr align 8 %self) unnamed_addr #0 !dbg !740 {
start:
  %self.dbg.spill = alloca [8 x i8], align 8
  store ptr %self, ptr %self.dbg.spill, align 8
    #dbg_declare(ptr %self.dbg.spill, !749, !DIExpression(), !750)
  %_0 = load ptr, ptr %self, align 8, !dbg !751
  ret ptr %_0, !dbg !752
}

; <&mut T as core::ops::deref::DerefMut>::deref_mut
; Function Attrs: uwtable
define internal align 8 ptr @"_ZN60_$LT$$RF$mut$u20$T$u20$as$u20$core..ops..deref..DerefMut$GT$9deref_mut17he8d347e250f645d9E"(ptr align 8 %self) unnamed_addr #0 !dbg !753 {
start:
  %self.dbg.spill = alloca [8 x i8], align 8
  store ptr %self, ptr %self.dbg.spill, align 8
    #dbg_declare(ptr %self.dbg.spill, !759, !DIExpression(), !760)
  %_0 = load ptr, ptr %self, align 8, !dbg !761
  ret ptr %_0, !dbg !762
}

; <core::task::wake::Waker as core::ops::drop::Drop>::drop
; Function Attrs: inlinehint uwtable
define internal void @"_ZN65_$LT$core..task..wake..Waker$u20$as$u20$core..ops..drop..Drop$GT$4drop17hb1138275daf8cdb4E"(ptr align 8 %self) unnamed_addr #1 !dbg !763 {
start:
  %self.dbg.spill = alloca [8 x i8], align 8
  store ptr %self, ptr %self.dbg.spill, align 8
    #dbg_declare(ptr %self.dbg.spill, !769, !DIExpression(), !770)
  %_4 = load ptr, ptr %self, align 8, !dbg !771
  %0 = getelementptr inbounds i8, ptr %_4, i64 24, !dbg !771
  %_2 = load ptr, ptr %0, align 8, !dbg !771
  %1 = getelementptr inbounds i8, ptr %self, i64 8, !dbg !772
  %_3 = load ptr, ptr %1, align 8, !dbg !772
  call void %_2(ptr %_3), !dbg !771
  ret void, !dbg !773
}

; async_demo::authorize
; Function Attrs: noinline uwtable
define internal void @_ZN10async_demo9authorize17h390cf99f43c68df5E(ptr sret([16 x i8]) align 8 %_0, ptr align 8 %r) unnamed_addr #2 !dbg !774 {
start:
  %r.dbg.spill = alloca [8 x i8], align 8
  store ptr %r, ptr %r.dbg.spill, align 8
    #dbg_declare(ptr %r.dbg.spill, !778, !DIExpression(), !779)
  store ptr %r, ptr %_0, align 8, !dbg !780
  %0 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !780
  store i8 0, ptr %0, align 8, !dbg !780
  ret void, !dbg !781
}

; async_demo::authorize::{{closure}}
; Function Attrs: inlinehint uwtable
define internal i8 @"_ZN10async_demo9authorize28_$u7b$$u7b$closure$u7d$$u7d$17h5cfbb956889f0429E"(ptr align 8 %0, ptr align 8 %_task_context) unnamed_addr #1 personality ptr @rust_eh_personality !dbg !782 {
start:
  %1 = alloca [16 x i8], align 8
  %r.dbg.spill = alloca [8 x i8], align 8
  %_task_context.dbg.spill = alloca [8 x i8], align 8
  %_0 = alloca [1 x i8], align 1
  %_1 = alloca [8 x i8], align 8
  store ptr %0, ptr %_1, align 8
    #dbg_declare(ptr %_1, !808, !DIExpression(DW_OP_deref), !811)
  store ptr %_task_context, ptr %_task_context.dbg.spill, align 8
    #dbg_declare(ptr %_task_context.dbg.spill, !807, !DIExpression(), !812)
  %_8 = load ptr, ptr %_1, align 8, !dbg !812
  %2 = getelementptr inbounds i8, ptr %_8, i64 8, !dbg !812
  %3 = load i8, ptr %2, align 8, !dbg !812
  %_7 = zext i8 %3 to i32, !dbg !812
  switch i32 %_7, label %bb6 [
    i32 0, label %bb1
    i32 1, label %bb5.preheader
    i32 2, label %bb4.preheader
  ], !dbg !812

bb4.preheader:                                    ; preds = %start
  br label %bb4, !dbg !812

bb5.preheader:                                    ; preds = %start
  br label %bb5, !dbg !812

bb6:                                              ; preds = %start
  unreachable, !dbg !812

bb1:                                              ; preds = %start
  %_9 = load ptr, ptr %_1, align 8, !dbg !811
  %r = load ptr, ptr %_9, align 8, !dbg !811
  store ptr %r, ptr %r.dbg.spill, align 8, !dbg !811
    #dbg_declare(ptr %r.dbg.spill, !809, !DIExpression(), !813)
; invoke core::hint::black_box
  %_5 = invoke align 8 ptr @_ZN4core4hint9black_box17h13e5c54c71dd8fc6E(ptr align 8 %r)
          to label %bb2 unwind label %cleanup, !dbg !814

bb5:                                              ; preds = %bb5.preheader, %bb5
  br i1 false, label %bb5, label %panic, !dbg !812

bb4:                                              ; preds = %bb4.preheader, %bb4
  br i1 false, label %bb4, label %panic1, !dbg !812

bb3:                                              ; preds = %cleanup
  %_11 = load ptr, ptr %_1, align 8, !dbg !812
  %4 = getelementptr inbounds i8, ptr %_11, i64 8, !dbg !812
  store i8 2, ptr %4, align 8, !dbg !812
  %5 = load ptr, ptr %1, align 8, !dbg !812
  %6 = getelementptr inbounds i8, ptr %1, i64 8, !dbg !812
  %7 = load i32, ptr %6, align 8, !dbg !812
  %8 = insertvalue { ptr, i32 } poison, ptr %5, 0, !dbg !812
  %9 = insertvalue { ptr, i32 } %8, i32 %7, 1, !dbg !812
  resume { ptr, i32 } %9, !dbg !812

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
  %_4 = load i64, ptr %_5, align 8, !dbg !814
  %_6 = icmp ne i64 %_4, 0, !dbg !814
  %14 = zext i1 %_6 to i8, !dbg !815
  store i8 %14, ptr %_0, align 1, !dbg !815
  %_10 = load ptr, ptr %_1, align 8, !dbg !815
  %15 = getelementptr inbounds i8, ptr %_10, i64 8, !dbg !815
  store i8 1, ptr %15, align 8, !dbg !815
  %16 = load i8, ptr %_0, align 1, !dbg !815
  ret i8 %16, !dbg !815

panic:                                            ; preds = %bb5
; call core::panicking::panic_const::panic_const_async_fn_resumed
  call void @_ZN4core9panicking11panic_const28panic_const_async_fn_resumed17hc64df446eef3dbfcE(ptr align 8 @alloc_0c60a0b639bba5d5bb27d6d85940911c) #8, !dbg !812
  unreachable, !dbg !812

panic1:                                           ; preds = %bb4
; call core::panicking::panic_const::panic_const_async_fn_resumed_panic
  call void @_ZN4core9panicking11panic_const34panic_const_async_fn_resumed_panic17hbbd8ac004b7fd30aE(ptr align 8 @alloc_0c60a0b639bba5d5bb27d6d85940911c) #8, !dbg !812
  unreachable, !dbg !812
}

; async_demo::db_read
; Function Attrs: noinline uwtable
define internal void @_ZN10async_demo7db_read17hf2078ac86afadfa5E(ptr sret([16 x i8]) align 8 %_0, ptr align 8 %r) unnamed_addr #2 !dbg !816 {
start:
  %r.dbg.spill = alloca [8 x i8], align 8
  store ptr %r, ptr %r.dbg.spill, align 8
    #dbg_declare(ptr %r.dbg.spill, !820, !DIExpression(), !821)
  store ptr %r, ptr %_0, align 8, !dbg !822
  %0 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !822
  store i8 0, ptr %0, align 8, !dbg !822
  ret void, !dbg !823
}

; async_demo::db_read::{{closure}}
; Function Attrs: inlinehint uwtable
define internal { i64, i64 } @"_ZN10async_demo7db_read28_$u7b$$u7b$closure$u7d$$u7d$17h799c5ebab41127b1E"(ptr align 8 %0, ptr align 8 %_task_context) unnamed_addr #1 personality ptr @rust_eh_personality !dbg !824 {
start:
  %1 = alloca [16 x i8], align 8
  %r.dbg.spill = alloca [8 x i8], align 8
  %_task_context.dbg.spill = alloca [8 x i8], align 8
  %_0 = alloca [16 x i8], align 8
  %_1 = alloca [8 x i8], align 8
  store ptr %0, ptr %_1, align 8
    #dbg_declare(ptr %_1, !846, !DIExpression(DW_OP_deref), !849)
  store ptr %_task_context, ptr %_task_context.dbg.spill, align 8
    #dbg_declare(ptr %_task_context.dbg.spill, !845, !DIExpression(), !850)
  %_7 = load ptr, ptr %_1, align 8, !dbg !850
  %2 = getelementptr inbounds i8, ptr %_7, i64 8, !dbg !850
  %3 = load i8, ptr %2, align 8, !dbg !850
  %_6 = zext i8 %3 to i32, !dbg !850
  switch i32 %_6, label %bb6 [
    i32 0, label %bb1
    i32 1, label %bb5.preheader
    i32 2, label %bb4.preheader
  ], !dbg !850

bb4.preheader:                                    ; preds = %start
  br label %bb4, !dbg !850

bb5.preheader:                                    ; preds = %start
  br label %bb5, !dbg !850

bb6:                                              ; preds = %start
  unreachable, !dbg !850

bb1:                                              ; preds = %start
  %_8 = load ptr, ptr %_1, align 8, !dbg !849
  %r = load ptr, ptr %_8, align 8, !dbg !849
  store ptr %r, ptr %r.dbg.spill, align 8, !dbg !849
    #dbg_declare(ptr %r.dbg.spill, !847, !DIExpression(), !851)
; invoke core::hint::black_box
  %_4 = invoke align 8 ptr @_ZN4core4hint9black_box17h13e5c54c71dd8fc6E(ptr align 8 %r)
          to label %bb2 unwind label %cleanup, !dbg !852

bb5:                                              ; preds = %bb5.preheader, %bb5
  br i1 false, label %bb5, label %panic, !dbg !850

bb4:                                              ; preds = %bb4.preheader, %bb4
  br i1 false, label %bb4, label %panic1, !dbg !850

bb3:                                              ; preds = %cleanup
  %_10 = load ptr, ptr %_1, align 8, !dbg !850
  %4 = getelementptr inbounds i8, ptr %_10, i64 8, !dbg !850
  store i8 2, ptr %4, align 8, !dbg !850
  %5 = load ptr, ptr %1, align 8, !dbg !850
  %6 = getelementptr inbounds i8, ptr %1, i64 8, !dbg !850
  %7 = load i32, ptr %6, align 8, !dbg !850
  %8 = insertvalue { ptr, i32 } poison, ptr %5, 0, !dbg !850
  %9 = insertvalue { ptr, i32 } %8, i32 %7, 1, !dbg !850
  resume { ptr, i32 } %9, !dbg !850

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
  %14 = getelementptr inbounds i8, ptr %_4, i64 8, !dbg !852
  %_5 = load i64, ptr %14, align 8, !dbg !852
  %15 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !853
  store i64 %_5, ptr %15, align 8, !dbg !853
  store i64 0, ptr %_0, align 8, !dbg !853
  %_9 = load ptr, ptr %_1, align 8, !dbg !853
  %16 = getelementptr inbounds i8, ptr %_9, i64 8, !dbg !853
  store i8 1, ptr %16, align 8, !dbg !853
  %17 = load i64, ptr %_0, align 8, !dbg !853
  %18 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !853
  %19 = load i64, ptr %18, align 8, !dbg !853
  %20 = insertvalue { i64, i64 } poison, i64 %17, 0, !dbg !853
  %21 = insertvalue { i64, i64 } %20, i64 %19, 1, !dbg !853
  ret { i64, i64 } %21, !dbg !853

panic:                                            ; preds = %bb5
; call core::panicking::panic_const::panic_const_async_fn_resumed
  call void @_ZN4core9panicking11panic_const28panic_const_async_fn_resumed17hc64df446eef3dbfcE(ptr align 8 @alloc_96719ba215877693b51c89bc08a51cab) #8, !dbg !850
  unreachable, !dbg !850

panic1:                                           ; preds = %bb4
; call core::panicking::panic_const::panic_const_async_fn_resumed_panic
  call void @_ZN4core9panicking11panic_const34panic_const_async_fn_resumed_panic17hbbd8ac004b7fd30aE(ptr align 8 @alloc_96719ba215877693b51c89bc08a51cab) #8, !dbg !850
  unreachable, !dbg !850
}

; async_demo::guarded
; Function Attrs: noinline uwtable
define internal void @_ZN10async_demo7guarded17h35dc6076e8381621E(ptr sret([40 x i8]) align 8 %_0, ptr align 8 %r) unnamed_addr #2 !dbg !854 {
start:
  %r.dbg.spill = alloca [8 x i8], align 8
  store ptr %r, ptr %r.dbg.spill, align 8
    #dbg_declare(ptr %r.dbg.spill, !858, !DIExpression(), !859)
  store ptr %r, ptr %_0, align 8, !dbg !860
  %0 = getelementptr inbounds i8, ptr %_0, i64 16, !dbg !860
  store i8 0, ptr %0, align 8, !dbg !860
  ret void, !dbg !861
}

; async_demo::guarded::{{closure}}
; Function Attrs: inlinehint uwtable
define internal { i64, i64 } @"_ZN10async_demo7guarded28_$u7b$$u7b$closure$u7d$$u7d$17hb2c3441699a3e5e7E"(ptr align 8 %0, ptr align 8 %_2) unnamed_addr #1 personality ptr @rust_eh_personality !dbg !862 {
start:
  %pointer.dbg.spill.i6 = alloca [8 x i8], align 8
  %pointer.dbg.spill.i = alloca [8 x i8], align 8
  %result.dbg.spill5 = alloca [8 x i8], align 8
  %result.dbg.spill = alloca [1 x i8], align 1
  %1 = alloca [16 x i8], align 8
  %_2.dbg.spill = alloca [8 x i8], align 8
  %_task_context = alloca [8 x i8], align 8
  %_19 = alloca [8 x i8], align 8
  %_13 = alloca [16 x i8], align 8
  %_12 = alloca [16 x i8], align 8
  %_11 = alloca [16 x i8], align 8
  %_5 = alloca [1 x i8], align 1
  %_4 = alloca [16 x i8], align 8
  %_3 = alloca [16 x i8], align 8
  %_0 = alloca [16 x i8], align 8
  %_1 = alloca [8 x i8], align 8
  store ptr %0, ptr %_1, align 8
    #dbg_declare(ptr %_1, !872, !DIExpression(DW_OP_deref), !884)
    #dbg_declare(ptr %_1, !873, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 8), !885)
    #dbg_declare(ptr %_1, !875, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 24), !886)
    #dbg_declare(ptr %_1, !879, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 24), !887)
  store ptr %_2, ptr %_2.dbg.spill, align 8
    #dbg_declare(ptr %_2.dbg.spill, !883, !DIExpression(), !888)
    #dbg_declare(ptr %_task_context, !871, !DIExpression(), !888)
  %_22 = load ptr, ptr %_1, align 8, !dbg !888
  %2 = getelementptr inbounds i8, ptr %_22, i64 16, !dbg !888
  %3 = load i8, ptr %2, align 8, !dbg !888
  %_21 = zext i8 %3 to i32, !dbg !888
  switch i32 %_21, label %bb7 [
    i32 0, label %bb1
    i32 1, label %bb27.preheader
    i32 2, label %bb26.preheader
    i32 3, label %bb24
    i32 4, label %bb25
  ], !dbg !888

bb26.preheader:                                   ; preds = %start
  br label %bb26, !dbg !888

bb27.preheader:                                   ; preds = %start
  br label %bb27, !dbg !888

bb7:                                              ; preds = %start
  unreachable, !dbg !889

bb1:                                              ; preds = %start
  store ptr %_2, ptr %_task_context, align 8, !dbg !888
  %_23 = load ptr, ptr %_1, align 8, !dbg !884
  %_24 = load ptr, ptr %_1, align 8, !dbg !884
  %4 = getelementptr inbounds i8, ptr %_23, i64 8, !dbg !884
  %5 = load ptr, ptr %_24, align 8, !dbg !884
  store ptr %5, ptr %4, align 8, !dbg !884
  %_25 = load ptr, ptr %_1, align 8, !dbg !890
  %6 = getelementptr inbounds i8, ptr %_25, i64 8, !dbg !890
  %_26 = load ptr, ptr %6, align 8, !dbg !890
; invoke async_demo::authorize
  invoke void @_ZN10async_demo9authorize17h390cf99f43c68df5E(ptr sret([16 x i8]) align 8 %_4, ptr align 8 %_26)
          to label %bb2 unwind label %cleanup, !dbg !891

bb27:                                             ; preds = %bb27.preheader, %bb27
  br i1 false, label %bb27, label %panic, !dbg !888

bb26:                                             ; preds = %bb26.preheader, %bb26
  br i1 false, label %bb26, label %panic1, !dbg !888

bb24:                                             ; preds = %start
  store ptr %_2, ptr %_task_context, align 8, !dbg !892
  br label %bb4, !dbg !892

bb25:                                             ; preds = %start
  store ptr %_2, ptr %_task_context, align 8, !dbg !893
  br label %bb14, !dbg !893

bb23:                                             ; preds = %bb21, %bb22, %cleanup
  %_40 = load ptr, ptr %_1, align 8, !dbg !888
  %7 = getelementptr inbounds i8, ptr %_40, i64 16, !dbg !888
  store i8 2, ptr %7, align 8, !dbg !888
  %8 = load ptr, ptr %1, align 8, !dbg !888
  %9 = getelementptr inbounds i8, ptr %1, i64 8, !dbg !888
  %10 = load i32, ptr %9, align 8, !dbg !888
  %11 = insertvalue { ptr, i32 } poison, ptr %8, 0, !dbg !888
  %12 = insertvalue { ptr, i32 } %11, i32 %10, 1, !dbg !888
  resume { ptr, i32 } %12, !dbg !888

cleanup:                                          ; preds = %bb18, %bb12, %bb11, %bb9, %bb2, %bb1
  %13 = landingpad { ptr, i32 }
          cleanup
  %14 = extractvalue { ptr, i32 } %13, 0
  %15 = extractvalue { ptr, i32 } %13, 1
  store ptr %14, ptr %1, align 8
  %16 = getelementptr inbounds i8, ptr %1, i64 8
  store i32 %15, ptr %16, align 8
  br label %bb23

bb2:                                              ; preds = %bb1
; invoke <F as core::future::into_future::IntoFuture>::into_future
  invoke void @"_ZN59_$LT$F$u20$as$u20$core..future..into_future..IntoFuture$GT$11into_future17h96dac5933a798099E"(ptr sret([16 x i8]) align 8 %_3, ptr align 8 %_4)
          to label %bb3 unwind label %cleanup, !dbg !894

bb3:                                              ; preds = %bb2
  %_27 = load ptr, ptr %_1, align 8, !dbg !891
  %17 = getelementptr inbounds i8, ptr %_27, i64 24, !dbg !891
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %17, ptr align 8 %_3, i64 16, i1 false), !dbg !891
  br label %bb4, !dbg !892

bb4:                                              ; preds = %bb24, %bb3
  %_28 = load ptr, ptr %_1, align 8, !dbg !892
  %_7 = getelementptr inbounds i8, ptr %_28, i64 24, !dbg !892
  store ptr %_7, ptr %pointer.dbg.spill.i6, align 8
    #dbg_declare(ptr %pointer.dbg.spill.i6, !895, !DIExpression(), !902)
  br label %bb5, !dbg !904

panic:                                            ; preds = %bb27
; call core::panicking::panic_const::panic_const_async_fn_resumed
  call void @_ZN4core9panicking11panic_const28panic_const_async_fn_resumed17hc64df446eef3dbfcE(ptr align 8 @alloc_3570fca4a3a20654e1fd5ca549d6abbe) #8, !dbg !888
  unreachable, !dbg !888

panic1:                                           ; preds = %bb26
; call core::panicking::panic_const::panic_const_async_fn_resumed_panic
  call void @_ZN4core9panicking11panic_const34panic_const_async_fn_resumed_panic17hbbd8ac004b7fd30aE(ptr align 8 @alloc_3570fca4a3a20654e1fd5ca549d6abbe) #8, !dbg !888
  unreachable, !dbg !888

bb22:                                             ; preds = %cleanup2
  %_39 = load ptr, ptr %_1, align 8, !dbg !905
  %18 = getelementptr inbounds i8, ptr %_39, i64 24, !dbg !905
; invoke core::ptr::drop_in_place<async_demo::authorize::{{closure}}>
  invoke void @"_ZN4core3ptr71drop_in_place$LT$async_demo..authorize..$u7b$$u7b$closure$u7d$$u7d$$GT$17h162b842d851e2706E"(ptr align 8 %18) #9
          to label %bb23 unwind label %terminate, !dbg !905

cleanup2:                                         ; preds = %bb5
  %19 = landingpad { ptr, i32 }
          cleanup
  %20 = extractvalue { ptr, i32 } %19, 0
  %21 = extractvalue { ptr, i32 } %19, 1
  store ptr %20, ptr %1, align 8
  %22 = getelementptr inbounds i8, ptr %1, i64 8
  store i32 %21, ptr %22, align 8
  br label %bb22

bb5:                                              ; preds = %bb4
  %_8 = load ptr, ptr %_task_context, align 8, !dbg !892
; invoke async_demo::authorize::{{closure}}
  %23 = invoke i8 @"_ZN10async_demo9authorize28_$u7b$$u7b$closure$u7d$$u7d$17h5cfbb956889f0429E"(ptr align 8 %_7, ptr align 8 %_8)
          to label %bb6 unwind label %cleanup2, !dbg !892

bb6:                                              ; preds = %bb5
  store i8 %23, ptr %_5, align 1, !dbg !892
  %24 = load i8, ptr %_5, align 1, !dbg !892
  %25 = icmp eq i8 %24, 2, !dbg !892
  %_9 = select i1 %25, i64 1, i64 0, !dbg !892
  %26 = icmp eq i64 %_9, 0, !dbg !892
  br i1 %26, label %bb9, label %bb8, !dbg !892

bb9:                                              ; preds = %bb6
  %27 = load i8, ptr %_5, align 1, !dbg !886
  %result = trunc i8 %27 to i1, !dbg !886
  %28 = zext i1 %result to i8, !dbg !886
  store i8 %28, ptr %result.dbg.spill, align 1, !dbg !886
    #dbg_declare(ptr %result.dbg.spill, !877, !DIExpression(), !906)
  %_30 = load ptr, ptr %_1, align 8, !dbg !905
  %29 = getelementptr inbounds i8, ptr %_30, i64 24, !dbg !905
; invoke core::ptr::drop_in_place<async_demo::authorize::{{closure}}>
  invoke void @"_ZN4core3ptr71drop_in_place$LT$async_demo..authorize..$u7b$$u7b$closure$u7d$$u7d$$GT$17h162b842d851e2706E"(ptr align 8 %29)
          to label %bb10 unwind label %cleanup, !dbg !905

bb8:                                              ; preds = %bb6
  store i64 1, ptr %_0, align 8, !dbg !892
  %_29 = load ptr, ptr %_1, align 8, !dbg !892
  %30 = getelementptr inbounds i8, ptr %_29, i64 16, !dbg !892
  store i8 3, ptr %30, align 8, !dbg !892
  %31 = load i64, ptr %_0, align 8, !dbg !892
  %32 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !892
  %33 = load i64, ptr %32, align 8, !dbg !892
  %34 = insertvalue { i64, i64 } poison, i64 %31, 0, !dbg !892
  %35 = insertvalue { i64, i64 } %34, i64 %33, 1, !dbg !892
  ret { i64, i64 } %35, !dbg !892

bb10:                                             ; preds = %bb9
  br i1 %result, label %bb11, label %bb19, !dbg !891

bb19:                                             ; preds = %bb10
  store i64 0, ptr %_19, align 8, !dbg !907
  br label %bb20, !dbg !908

bb11:                                             ; preds = %bb10
  %_31 = load ptr, ptr %_1, align 8, !dbg !909
  %36 = getelementptr inbounds i8, ptr %_31, i64 8, !dbg !909
  %_32 = load ptr, ptr %36, align 8, !dbg !909
; invoke async_demo::db_read
  invoke void @_ZN10async_demo7db_read17hf2078ac86afadfa5E(ptr sret([16 x i8]) align 8 %_12, ptr align 8 %_32)
          to label %bb12 unwind label %cleanup, !dbg !910

bb20:                                             ; preds = %bb18, %bb19
  %37 = load i64, ptr %_19, align 8, !dbg !911
  %38 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !911
  store i64 %37, ptr %38, align 8, !dbg !911
  store i64 0, ptr %_0, align 8, !dbg !911
  %_37 = load ptr, ptr %_1, align 8, !dbg !911
  %39 = getelementptr inbounds i8, ptr %_37, i64 16, !dbg !911
  store i8 1, ptr %39, align 8, !dbg !911
  %40 = load i64, ptr %_0, align 8, !dbg !911
  %41 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !911
  %42 = load i64, ptr %41, align 8, !dbg !911
  %43 = insertvalue { i64, i64 } poison, i64 %40, 0, !dbg !911
  %44 = insertvalue { i64, i64 } %43, i64 %42, 1, !dbg !911
  ret { i64, i64 } %44, !dbg !911

bb12:                                             ; preds = %bb11
; invoke <F as core::future::into_future::IntoFuture>::into_future
  invoke void @"_ZN59_$LT$F$u20$as$u20$core..future..into_future..IntoFuture$GT$11into_future17h3a4cc5be54bf241aE"(ptr sret([16 x i8]) align 8 %_11, ptr align 8 %_12)
          to label %bb13 unwind label %cleanup, !dbg !912

bb13:                                             ; preds = %bb12
  %_33 = load ptr, ptr %_1, align 8, !dbg !910
  %45 = getelementptr inbounds i8, ptr %_33, i64 24, !dbg !910
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %45, ptr align 8 %_11, i64 16, i1 false), !dbg !910
  br label %bb14, !dbg !893

bb14:                                             ; preds = %bb25, %bb13
  %_34 = load ptr, ptr %_1, align 8, !dbg !893
  %_15 = getelementptr inbounds i8, ptr %_34, i64 24, !dbg !893
  store ptr %_15, ptr %pointer.dbg.spill.i, align 8
    #dbg_declare(ptr %pointer.dbg.spill.i, !913, !DIExpression(), !919)
  br label %bb15, !dbg !921

terminate:                                        ; preds = %bb21, %bb22
  %46 = landingpad { ptr, i32 }
          filter [0 x ptr] zeroinitializer
  %47 = extractvalue { ptr, i32 } %46, 0
  %48 = extractvalue { ptr, i32 } %46, 1
; call core::panicking::panic_in_cleanup
  call void @_ZN4core9panicking16panic_in_cleanup17hb960b8c5dea287d4E() #10, !dbg !888
  unreachable, !dbg !888

bb21:                                             ; preds = %cleanup3
  %_38 = load ptr, ptr %_1, align 8, !dbg !922
  %49 = getelementptr inbounds i8, ptr %_38, i64 24, !dbg !922
; invoke core::ptr::drop_in_place<async_demo::db_read::{{closure}}>
  invoke void @"_ZN4core3ptr69drop_in_place$LT$async_demo..db_read..$u7b$$u7b$closure$u7d$$u7d$$GT$17h7d9c75f079191aceE"(ptr align 8 %49) #9
          to label %bb23 unwind label %terminate, !dbg !922

cleanup3:                                         ; preds = %bb15
  %50 = landingpad { ptr, i32 }
          cleanup
  %51 = extractvalue { ptr, i32 } %50, 0
  %52 = extractvalue { ptr, i32 } %50, 1
  store ptr %51, ptr %1, align 8
  %53 = getelementptr inbounds i8, ptr %1, i64 8
  store i32 %52, ptr %53, align 8
  br label %bb21

bb15:                                             ; preds = %bb14
  %_16 = load ptr, ptr %_task_context, align 8, !dbg !893
; invoke async_demo::db_read::{{closure}}
  %54 = invoke { i64, i64 } @"_ZN10async_demo7db_read28_$u7b$$u7b$closure$u7d$$u7d$17h799c5ebab41127b1E"(ptr align 8 %_15, ptr align 8 %_16)
          to label %bb16 unwind label %cleanup3, !dbg !893

bb16:                                             ; preds = %bb15
  %55 = extractvalue { i64, i64 } %54, 0, !dbg !893
  %56 = extractvalue { i64, i64 } %54, 1, !dbg !893
  store i64 %55, ptr %_13, align 8, !dbg !893
  %57 = getelementptr inbounds i8, ptr %_13, i64 8, !dbg !893
  store i64 %56, ptr %57, align 8, !dbg !893
  %_17 = load i64, ptr %_13, align 8, !dbg !893
  %58 = icmp eq i64 %_17, 0, !dbg !893
  br i1 %58, label %bb18, label %bb17, !dbg !893

bb18:                                             ; preds = %bb16
  %59 = getelementptr inbounds i8, ptr %_13, i64 8, !dbg !887
  %result4 = load i64, ptr %59, align 8, !dbg !887
  store i64 %result4, ptr %result.dbg.spill5, align 8, !dbg !887
    #dbg_declare(ptr %result.dbg.spill5, !881, !DIExpression(), !923)
  store i64 %result4, ptr %_19, align 8, !dbg !923
  %_36 = load ptr, ptr %_1, align 8, !dbg !922
  %60 = getelementptr inbounds i8, ptr %_36, i64 24, !dbg !922
; invoke core::ptr::drop_in_place<async_demo::db_read::{{closure}}>
  invoke void @"_ZN4core3ptr69drop_in_place$LT$async_demo..db_read..$u7b$$u7b$closure$u7d$$u7d$$GT$17h7d9c75f079191aceE"(ptr align 8 %60)
          to label %bb20 unwind label %cleanup, !dbg !922

bb17:                                             ; preds = %bb16
  store i64 1, ptr %_0, align 8, !dbg !893
  %_35 = load ptr, ptr %_1, align 8, !dbg !893
  %61 = getelementptr inbounds i8, ptr %_35, i64 16, !dbg !893
  store i8 4, ptr %61, align 8, !dbg !893
  %62 = load i64, ptr %_0, align 8, !dbg !893
  %63 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !893
  %64 = load i64, ptr %63, align 8, !dbg !893
  %65 = insertvalue { i64, i64 } poison, i64 %62, 0, !dbg !893
  %66 = insertvalue { i64, i64 } %65, i64 %64, 1, !dbg !893
  ret { i64, i64 } %66, !dbg !893
}

; async_demo::unguarded
; Function Attrs: noinline uwtable
define internal void @_ZN10async_demo9unguarded17h35b9685ebed6fe46E(ptr sret([32 x i8]) align 8 %_0, ptr align 8 %r) unnamed_addr #2 !dbg !924 {
start:
  %r.dbg.spill = alloca [8 x i8], align 8
  store ptr %r, ptr %r.dbg.spill, align 8
    #dbg_declare(ptr %r.dbg.spill, !928, !DIExpression(), !929)
  store ptr %r, ptr %_0, align 8, !dbg !930
  %0 = getelementptr inbounds i8, ptr %_0, i64 24, !dbg !930
  store i8 0, ptr %0, align 8, !dbg !930
  ret void, !dbg !931
}

; async_demo::unguarded::{{closure}}
; Function Attrs: inlinehint uwtable
define internal { i64, i64 } @"_ZN10async_demo9unguarded28_$u7b$$u7b$closure$u7d$$u7d$17h60bd849f302abbb0E"(ptr align 8 %0, ptr align 8 %_2) unnamed_addr #1 personality ptr @rust_eh_personality !dbg !932 {
start:
  %pointer.dbg.spill.i = alloca [8 x i8], align 8
  %result.dbg.spill = alloca [8 x i8], align 8
  %1 = alloca [16 x i8], align 8
  %r.dbg.spill = alloca [8 x i8], align 8
  %_2.dbg.spill = alloca [8 x i8], align 8
  %_task_context = alloca [8 x i8], align 8
  %_6 = alloca [16 x i8], align 8
  %_5 = alloca [16 x i8], align 8
  %_4 = alloca [16 x i8], align 8
  %_0 = alloca [16 x i8], align 8
  %_1 = alloca [8 x i8], align 8
  store ptr %0, ptr %_1, align 8
    #dbg_declare(ptr %_1, !942, !DIExpression(DW_OP_deref), !950)
    #dbg_declare(ptr %_1, !945, !DIExpression(DW_OP_deref, DW_OP_plus_uconst, 8), !951)
  store ptr %_2, ptr %_2.dbg.spill, align 8
    #dbg_declare(ptr %_2.dbg.spill, !949, !DIExpression(), !952)
    #dbg_declare(ptr %_task_context, !941, !DIExpression(), !952)
  %_14 = load ptr, ptr %_1, align 8, !dbg !952
  %2 = getelementptr inbounds i8, ptr %_14, i64 24, !dbg !952
  %3 = load i8, ptr %2, align 8, !dbg !952
  %_13 = zext i8 %3 to i32, !dbg !952
  switch i32 %_13, label %bb7 [
    i32 0, label %bb1
    i32 1, label %bb15.preheader
    i32 2, label %bb14.preheader
    i32 3, label %bb13
  ], !dbg !952

bb14.preheader:                                   ; preds = %start
  br label %bb14, !dbg !952

bb15.preheader:                                   ; preds = %start
  br label %bb15, !dbg !952

bb7:                                              ; preds = %start
  unreachable, !dbg !953

bb1:                                              ; preds = %start
  store ptr %_2, ptr %_task_context, align 8, !dbg !952
  %_15 = load ptr, ptr %_1, align 8, !dbg !950
  %r = load ptr, ptr %_15, align 8, !dbg !950
  store ptr %r, ptr %r.dbg.spill, align 8, !dbg !950
    #dbg_declare(ptr %r.dbg.spill, !943, !DIExpression(), !954)
; invoke async_demo::db_read
  invoke void @_ZN10async_demo7db_read17hf2078ac86afadfa5E(ptr sret([16 x i8]) align 8 %_5, ptr align 8 %r)
          to label %bb2 unwind label %cleanup, !dbg !955

bb15:                                             ; preds = %bb15.preheader, %bb15
  br i1 false, label %bb15, label %panic, !dbg !952

bb14:                                             ; preds = %bb14.preheader, %bb14
  br i1 false, label %bb14, label %panic1, !dbg !952

bb13:                                             ; preds = %start
  store ptr %_2, ptr %_task_context, align 8, !dbg !956
  br label %bb4, !dbg !956

bb12:                                             ; preds = %bb11, %cleanup
  %_22 = load ptr, ptr %_1, align 8, !dbg !952
  %4 = getelementptr inbounds i8, ptr %_22, i64 24, !dbg !952
  store i8 2, ptr %4, align 8, !dbg !952
  %5 = load ptr, ptr %1, align 8, !dbg !952
  %6 = getelementptr inbounds i8, ptr %1, i64 8, !dbg !952
  %7 = load i32, ptr %6, align 8, !dbg !952
  %8 = insertvalue { ptr, i32 } poison, ptr %5, 0, !dbg !952
  %9 = insertvalue { ptr, i32 } %8, i32 %7, 1, !dbg !952
  resume { ptr, i32 } %9, !dbg !952

cleanup:                                          ; preds = %bb9, %bb2, %bb1
  %10 = landingpad { ptr, i32 }
          cleanup
  %11 = extractvalue { ptr, i32 } %10, 0
  %12 = extractvalue { ptr, i32 } %10, 1
  store ptr %11, ptr %1, align 8
  %13 = getelementptr inbounds i8, ptr %1, i64 8
  store i32 %12, ptr %13, align 8
  br label %bb12

bb2:                                              ; preds = %bb1
; invoke <F as core::future::into_future::IntoFuture>::into_future
  invoke void @"_ZN59_$LT$F$u20$as$u20$core..future..into_future..IntoFuture$GT$11into_future17h3a4cc5be54bf241aE"(ptr sret([16 x i8]) align 8 %_4, ptr align 8 %_5)
          to label %bb3 unwind label %cleanup, !dbg !957

bb3:                                              ; preds = %bb2
  %_16 = load ptr, ptr %_1, align 8, !dbg !955
  %14 = getelementptr inbounds i8, ptr %_16, i64 8, !dbg !955
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %14, ptr align 8 %_4, i64 16, i1 false), !dbg !955
  br label %bb4, !dbg !956

bb4:                                              ; preds = %bb13, %bb3
  %_17 = load ptr, ptr %_1, align 8, !dbg !956
  %_8 = getelementptr inbounds i8, ptr %_17, i64 8, !dbg !956
  store ptr %_8, ptr %pointer.dbg.spill.i, align 8
    #dbg_declare(ptr %pointer.dbg.spill.i, !913, !DIExpression(), !958)
  br label %bb5, !dbg !960

panic:                                            ; preds = %bb15
; call core::panicking::panic_const::panic_const_async_fn_resumed
  call void @_ZN4core9panicking11panic_const28panic_const_async_fn_resumed17hc64df446eef3dbfcE(ptr align 8 @alloc_0e7a629824c2ebe6fcd69a45c03fa5d5) #8, !dbg !952
  unreachable, !dbg !952

panic1:                                           ; preds = %bb14
; call core::panicking::panic_const::panic_const_async_fn_resumed_panic
  call void @_ZN4core9panicking11panic_const34panic_const_async_fn_resumed_panic17hbbd8ac004b7fd30aE(ptr align 8 @alloc_0e7a629824c2ebe6fcd69a45c03fa5d5) #8, !dbg !952
  unreachable, !dbg !952

bb11:                                             ; preds = %cleanup2
  %_21 = load ptr, ptr %_1, align 8, !dbg !961
  %15 = getelementptr inbounds i8, ptr %_21, i64 8, !dbg !961
; invoke core::ptr::drop_in_place<async_demo::db_read::{{closure}}>
  invoke void @"_ZN4core3ptr69drop_in_place$LT$async_demo..db_read..$u7b$$u7b$closure$u7d$$u7d$$GT$17h7d9c75f079191aceE"(ptr align 8 %15) #9
          to label %bb12 unwind label %terminate, !dbg !961

cleanup2:                                         ; preds = %bb5
  %16 = landingpad { ptr, i32 }
          cleanup
  %17 = extractvalue { ptr, i32 } %16, 0
  %18 = extractvalue { ptr, i32 } %16, 1
  store ptr %17, ptr %1, align 8
  %19 = getelementptr inbounds i8, ptr %1, i64 8
  store i32 %18, ptr %19, align 8
  br label %bb11

bb5:                                              ; preds = %bb4
  %_9 = load ptr, ptr %_task_context, align 8, !dbg !956
; invoke async_demo::db_read::{{closure}}
  %20 = invoke { i64, i64 } @"_ZN10async_demo7db_read28_$u7b$$u7b$closure$u7d$$u7d$17h799c5ebab41127b1E"(ptr align 8 %_8, ptr align 8 %_9)
          to label %bb6 unwind label %cleanup2, !dbg !956

bb6:                                              ; preds = %bb5
  %21 = extractvalue { i64, i64 } %20, 0, !dbg !956
  %22 = extractvalue { i64, i64 } %20, 1, !dbg !956
  store i64 %21, ptr %_6, align 8, !dbg !956
  %23 = getelementptr inbounds i8, ptr %_6, i64 8, !dbg !956
  store i64 %22, ptr %23, align 8, !dbg !956
  %_10 = load i64, ptr %_6, align 8, !dbg !956
  %24 = icmp eq i64 %_10, 0, !dbg !956
  br i1 %24, label %bb9, label %bb8, !dbg !956

bb9:                                              ; preds = %bb6
  %25 = getelementptr inbounds i8, ptr %_6, i64 8, !dbg !951
  %result = load i64, ptr %25, align 8, !dbg !951
  store i64 %result, ptr %result.dbg.spill, align 8, !dbg !951
    #dbg_declare(ptr %result.dbg.spill, !947, !DIExpression(), !962)
  %_19 = load ptr, ptr %_1, align 8, !dbg !961
  %26 = getelementptr inbounds i8, ptr %_19, i64 8, !dbg !961
; invoke core::ptr::drop_in_place<async_demo::db_read::{{closure}}>
  invoke void @"_ZN4core3ptr69drop_in_place$LT$async_demo..db_read..$u7b$$u7b$closure$u7d$$u7d$$GT$17h7d9c75f079191aceE"(ptr align 8 %26)
          to label %bb10 unwind label %cleanup, !dbg !961

bb8:                                              ; preds = %bb6
  store i64 1, ptr %_0, align 8, !dbg !956
  %_18 = load ptr, ptr %_1, align 8, !dbg !956
  %27 = getelementptr inbounds i8, ptr %_18, i64 24, !dbg !956
  store i8 3, ptr %27, align 8, !dbg !956
  %28 = load i64, ptr %_0, align 8, !dbg !956
  %29 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !956
  %30 = load i64, ptr %29, align 8, !dbg !956
  %31 = insertvalue { i64, i64 } poison, i64 %28, 0, !dbg !956
  %32 = insertvalue { i64, i64 } %31, i64 %30, 1, !dbg !956
  ret { i64, i64 } %32, !dbg !956

bb10:                                             ; preds = %bb9
  %33 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !963
  store i64 %result, ptr %33, align 8, !dbg !963
  store i64 0, ptr %_0, align 8, !dbg !963
  %_20 = load ptr, ptr %_1, align 8, !dbg !963
  %34 = getelementptr inbounds i8, ptr %_20, i64 24, !dbg !963
  store i8 1, ptr %34, align 8, !dbg !963
  %35 = load i64, ptr %_0, align 8, !dbg !963
  %36 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !963
  %37 = load i64, ptr %36, align 8, !dbg !963
  %38 = insertvalue { i64, i64 } poison, i64 %35, 0, !dbg !963
  %39 = insertvalue { i64, i64 } %38, i64 %37, 1, !dbg !963
  ret { i64, i64 } %39, !dbg !963

terminate:                                        ; preds = %bb11
  %40 = landingpad { ptr, i32 }
          filter [0 x ptr] zeroinitializer
  %41 = extractvalue { ptr, i32 } %40, 0
  %42 = extractvalue { ptr, i32 } %40, 1
; call core::panicking::panic_in_cleanup
  call void @_ZN4core9panicking16panic_in_cleanup17hb960b8c5dea287d4E() #10, !dbg !952
  unreachable, !dbg !952
}

; async_demo::noop
; Function Attrs: uwtable
define internal void @_ZN10async_demo4noop17h41a65d1e9ed40a73E(ptr %_1) unnamed_addr #0 !dbg !964 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !966, !DIExpression(), !967)
  ret void, !dbg !968
}

; async_demo::clone_w
; Function Attrs: uwtable
define internal { ptr, ptr } @_ZN10async_demo7clone_w17h237304af9c8bd529E(ptr %_1) unnamed_addr #0 !dbg !969 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !971, !DIExpression(), !972)
; call core::task::wake::RawWaker::new
  %0 = call { ptr, ptr } @_ZN4core4task4wake8RawWaker3new17h97385b4012da4169E(ptr null, ptr align 8 @_ZN10async_demo2VT17h057c6809b0537861E), !dbg !973
  %_0.0 = extractvalue { ptr, ptr } %0, 0, !dbg !973
  %_0.1 = extractvalue { ptr, ptr } %0, 1, !dbg !973
  %1 = insertvalue { ptr, ptr } poison, ptr %_0.0, 0, !dbg !974
  %2 = insertvalue { ptr, ptr } %1, ptr %_0.1, 1, !dbg !974
  ret { ptr, ptr } %2, !dbg !974
}

; async_demo::block_on
; Function Attrs: uwtable
define internal i64 @_ZN10async_demo8block_on17h4fd05f61446baf56E(ptr align 8 %f) unnamed_addr #0 personality ptr @rust_eh_personality !dbg !975 {
start:
  %pointer.dbg.spill.i = alloca [8 x i8], align 8
  %self.dbg.spill.i = alloca [8 x i8], align 8
  %v.dbg.spill = alloca [8 x i8], align 8
  %0 = alloca [16 x i8], align 8
  %_11 = alloca [16 x i8], align 8
  %cx = alloca [32 x i8], align 8
  %w = alloca [16 x i8], align 8
  %_4 = alloca [32 x i8], align 8
  %f1 = alloca [8 x i8], align 8
    #dbg_declare(ptr %f, !979, !DIExpression(), !990)
    #dbg_declare(ptr %f1, !980, !DIExpression(), !991)
    #dbg_declare(ptr %w, !982, !DIExpression(), !992)
    #dbg_declare(ptr %cx, !984, !DIExpression(), !993)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_4, ptr align 8 %f, i64 32, i1 false), !dbg !994
  store ptr %_4, ptr %f1, align 8, !dbg !995
  br label %bb1, !dbg !996

bb12:                                             ; preds = %bb11, %cleanup
; invoke core::ptr::drop_in_place<async_demo::unguarded::{{closure}}>
  invoke void @"_ZN4core3ptr71drop_in_place$LT$async_demo..unguarded..$u7b$$u7b$closure$u7d$$u7d$$GT$17hd47c4069b6e3428cE"(ptr align 8 %_4) #9
          to label %bb13 unwind label %terminate, !dbg !1001

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
  %5 = invoke { ptr, ptr } @_ZN4core4task4wake8RawWaker3new17h97385b4012da4169E(ptr null, ptr align 8 @_ZN10async_demo2VT17h057c6809b0537861E)
          to label %bb2 unwind label %cleanup, !dbg !1002

bb2:                                              ; preds = %bb1
  %_6.0 = extractvalue { ptr, ptr } %5, 0, !dbg !1002
  %_6.1 = extractvalue { ptr, ptr } %5, 1, !dbg !1002
; invoke core::task::wake::Waker::from_raw
  %6 = invoke { ptr, ptr } @_ZN4core4task4wake5Waker8from_raw17hfdc613e6f00adcadE(ptr align 8 %_6.0, ptr %_6.1)
          to label %bb3 unwind label %cleanup, !dbg !1003

bb3:                                              ; preds = %bb2
  %7 = extractvalue { ptr, ptr } %6, 0, !dbg !1003
  %8 = extractvalue { ptr, ptr } %6, 1, !dbg !1003
  store ptr %7, ptr %w, align 8, !dbg !1003
  %9 = getelementptr inbounds i8, ptr %w, i64 8, !dbg !1003
  store ptr %8, ptr %9, align 8, !dbg !1003
; invoke core::task::wake::Context::from_waker
  invoke void @_ZN4core4task4wake7Context10from_waker17h4673ecefaeb55096E(ptr sret([32 x i8]) align 8 %cx, ptr align 8 %w)
          to label %bb15 unwind label %cleanup2.loopexit.split-lp, !dbg !1004

bb11:                                             ; preds = %cleanup2
; invoke core::ptr::drop_in_place<core::task::wake::Waker>
  invoke void @"_ZN4core3ptr44drop_in_place$LT$core..task..wake..Waker$GT$17h4d1fa1153a381a05E"(ptr align 8 %w) #9
          to label %bb12 unwind label %terminate, !dbg !1005

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
  br label %bb4, !dbg !1004

bb4:                                              ; preds = %bb8, %bb15
  store ptr %f1, ptr %self.dbg.spill.i, align 8
    #dbg_declare(ptr %self.dbg.spill.i, !1006, !DIExpression(), !1013)
; invoke <&mut T as core::ops::deref::DerefMut>::deref_mut
  %pointer.i3 = invoke align 8 ptr @"_ZN60_$LT$$RF$mut$u20$T$u20$as$u20$core..ops..deref..DerefMut$GT$9deref_mut17he8d347e250f645d9E"(ptr align 8 %f1)
          to label %"_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17h7000f358e1f079fbE.exit" unwind label %cleanup2.loopexit, !dbg !1015

"_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17h7000f358e1f079fbE.exit": ; preds = %bb4
  store ptr %pointer.i3, ptr %pointer.dbg.spill.i, align 8, !dbg !1015
    #dbg_declare(ptr %pointer.dbg.spill.i, !1016, !DIExpression(), !1022)
  br label %bb5, !dbg !1024

bb5:                                              ; preds = %"_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17h7000f358e1f079fbE.exit"
; invoke async_demo::unguarded::{{closure}}
  %13 = invoke { i64, i64 } @"_ZN10async_demo9unguarded28_$u7b$$u7b$closure$u7d$$u7d$17h60bd849f302abbb0E"(ptr align 8 %pointer.i3, ptr align 8 %cx)
          to label %bb6 unwind label %cleanup2.loopexit, !dbg !1025

bb6:                                              ; preds = %bb5
  %14 = extractvalue { i64, i64 } %13, 0, !dbg !1025
  %15 = extractvalue { i64, i64 } %13, 1, !dbg !1025
  store i64 %14, ptr %_11, align 8, !dbg !1025
  %16 = getelementptr inbounds i8, ptr %_11, i64 8, !dbg !1025
  store i64 %15, ptr %16, align 8, !dbg !1025
  %_15 = load i64, ptr %_11, align 8, !dbg !1025
  %17 = icmp eq i64 %_15, 0, !dbg !1026
  br i1 %17, label %bb7, label %bb8, !dbg !1026

bb7:                                              ; preds = %bb6
  %18 = getelementptr inbounds i8, ptr %_11, i64 8, !dbg !1027
  %v = load i64, ptr %18, align 8, !dbg !1027
  store i64 %v, ptr %v.dbg.spill, align 8, !dbg !1027
    #dbg_declare(ptr %v.dbg.spill, !986, !DIExpression(), !1027)
; invoke core::ptr::drop_in_place<core::task::wake::Waker>
  invoke void @"_ZN4core3ptr44drop_in_place$LT$core..task..wake..Waker$GT$17h4d1fa1153a381a05E"(ptr align 8 %w)
          to label %bb9 unwind label %cleanup, !dbg !1005

bb8:                                              ; preds = %bb6
  br label %bb4, !dbg !1028

bb9:                                              ; preds = %bb7
; call core::ptr::drop_in_place<async_demo::unguarded::{{closure}}>
  call void @"_ZN4core3ptr71drop_in_place$LT$async_demo..unguarded..$u7b$$u7b$closure$u7d$$u7d$$GT$17hd47c4069b6e3428cE"(ptr align 8 %_4), !dbg !1001
  ret i64 %v, !dbg !1029

bb14:                                             ; No predecessors!
  unreachable, !dbg !1030

terminate:                                        ; preds = %bb12, %bb11
  %19 = landingpad { ptr, i32 }
          filter [0 x ptr] zeroinitializer
  %20 = extractvalue { ptr, i32 } %19, 0
  %21 = extractvalue { ptr, i32 } %19, 1
; call core::panicking::panic_in_cleanup
  call void @_ZN4core9panicking16panic_in_cleanup17hb960b8c5dea287d4E() #10, !dbg !1030
  unreachable, !dbg !1030

bb13:                                             ; preds = %bb12
  %22 = load ptr, ptr %0, align 8, !dbg !1030
  %23 = getelementptr inbounds i8, ptr %0, i64 8, !dbg !1030
  %24 = load i32, ptr %23, align 8, !dbg !1030
  %25 = insertvalue { ptr, i32 } poison, ptr %22, 0, !dbg !1030
  %26 = insertvalue { ptr, i32 } %25, i32 %24, 1, !dbg !1030
  resume { ptr, i32 } %26, !dbg !1030
}

; async_demo::block_on
; Function Attrs: uwtable
define internal i64 @_ZN10async_demo8block_on17he3c4265f92fcd2d4E(ptr align 8 %f) unnamed_addr #0 personality ptr @rust_eh_personality !dbg !1031 {
start:
  %pointer.dbg.spill.i = alloca [8 x i8], align 8
  %self.dbg.spill.i = alloca [8 x i8], align 8
  %v.dbg.spill = alloca [8 x i8], align 8
  %0 = alloca [16 x i8], align 8
  %_11 = alloca [16 x i8], align 8
  %cx = alloca [32 x i8], align 8
  %w = alloca [16 x i8], align 8
  %_4 = alloca [40 x i8], align 8
  %f1 = alloca [8 x i8], align 8
    #dbg_declare(ptr %f, !1035, !DIExpression(), !1046)
    #dbg_declare(ptr %f1, !1036, !DIExpression(), !1047)
    #dbg_declare(ptr %w, !1038, !DIExpression(), !1048)
    #dbg_declare(ptr %cx, !1040, !DIExpression(), !1049)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_4, ptr align 8 %f, i64 40, i1 false), !dbg !1050
  store ptr %_4, ptr %f1, align 8, !dbg !1051
  br label %bb1, !dbg !1052

bb12:                                             ; preds = %bb11, %cleanup
; invoke core::ptr::drop_in_place<async_demo::guarded::{{closure}}>
  invoke void @"_ZN4core3ptr69drop_in_place$LT$async_demo..guarded..$u7b$$u7b$closure$u7d$$u7d$$GT$17h29807675ee04bd5aE"(ptr align 8 %_4) #9
          to label %bb13 unwind label %terminate, !dbg !1054

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
  %5 = invoke { ptr, ptr } @_ZN4core4task4wake8RawWaker3new17h97385b4012da4169E(ptr null, ptr align 8 @_ZN10async_demo2VT17h057c6809b0537861E)
          to label %bb2 unwind label %cleanup, !dbg !1055

bb2:                                              ; preds = %bb1
  %_6.0 = extractvalue { ptr, ptr } %5, 0, !dbg !1055
  %_6.1 = extractvalue { ptr, ptr } %5, 1, !dbg !1055
; invoke core::task::wake::Waker::from_raw
  %6 = invoke { ptr, ptr } @_ZN4core4task4wake5Waker8from_raw17hfdc613e6f00adcadE(ptr align 8 %_6.0, ptr %_6.1)
          to label %bb3 unwind label %cleanup, !dbg !1056

bb3:                                              ; preds = %bb2
  %7 = extractvalue { ptr, ptr } %6, 0, !dbg !1056
  %8 = extractvalue { ptr, ptr } %6, 1, !dbg !1056
  store ptr %7, ptr %w, align 8, !dbg !1056
  %9 = getelementptr inbounds i8, ptr %w, i64 8, !dbg !1056
  store ptr %8, ptr %9, align 8, !dbg !1056
; invoke core::task::wake::Context::from_waker
  invoke void @_ZN4core4task4wake7Context10from_waker17h4673ecefaeb55096E(ptr sret([32 x i8]) align 8 %cx, ptr align 8 %w)
          to label %bb15 unwind label %cleanup2.loopexit.split-lp, !dbg !1057

bb11:                                             ; preds = %cleanup2
; invoke core::ptr::drop_in_place<core::task::wake::Waker>
  invoke void @"_ZN4core3ptr44drop_in_place$LT$core..task..wake..Waker$GT$17h4d1fa1153a381a05E"(ptr align 8 %w) #9
          to label %bb12 unwind label %terminate, !dbg !1058

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
  br label %bb4, !dbg !1057

bb4:                                              ; preds = %bb8, %bb15
  store ptr %f1, ptr %self.dbg.spill.i, align 8
    #dbg_declare(ptr %self.dbg.spill.i, !1059, !DIExpression(), !1066)
; invoke <&mut T as core::ops::deref::DerefMut>::deref_mut
  %pointer.i3 = invoke align 8 ptr @"_ZN60_$LT$$RF$mut$u20$T$u20$as$u20$core..ops..deref..DerefMut$GT$9deref_mut17hd752dc04218d67fbE"(ptr align 8 %f1)
          to label %"_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17hb37273d40e1ca6d5E.exit" unwind label %cleanup2.loopexit, !dbg !1068

"_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17hb37273d40e1ca6d5E.exit": ; preds = %bb4
  store ptr %pointer.i3, ptr %pointer.dbg.spill.i, align 8, !dbg !1068
    #dbg_declare(ptr %pointer.dbg.spill.i, !1069, !DIExpression(), !1075)
  br label %bb5, !dbg !1077

bb5:                                              ; preds = %"_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17hb37273d40e1ca6d5E.exit"
; invoke async_demo::guarded::{{closure}}
  %13 = invoke { i64, i64 } @"_ZN10async_demo7guarded28_$u7b$$u7b$closure$u7d$$u7d$17hb2c3441699a3e5e7E"(ptr align 8 %pointer.i3, ptr align 8 %cx)
          to label %bb6 unwind label %cleanup2.loopexit, !dbg !1078

bb6:                                              ; preds = %bb5
  %14 = extractvalue { i64, i64 } %13, 0, !dbg !1078
  %15 = extractvalue { i64, i64 } %13, 1, !dbg !1078
  store i64 %14, ptr %_11, align 8, !dbg !1078
  %16 = getelementptr inbounds i8, ptr %_11, i64 8, !dbg !1078
  store i64 %15, ptr %16, align 8, !dbg !1078
  %_15 = load i64, ptr %_11, align 8, !dbg !1078
  %17 = icmp eq i64 %_15, 0, !dbg !1079
  br i1 %17, label %bb7, label %bb8, !dbg !1079

bb7:                                              ; preds = %bb6
  %18 = getelementptr inbounds i8, ptr %_11, i64 8, !dbg !1080
  %v = load i64, ptr %18, align 8, !dbg !1080
  store i64 %v, ptr %v.dbg.spill, align 8, !dbg !1080
    #dbg_declare(ptr %v.dbg.spill, !1042, !DIExpression(), !1080)
; invoke core::ptr::drop_in_place<core::task::wake::Waker>
  invoke void @"_ZN4core3ptr44drop_in_place$LT$core..task..wake..Waker$GT$17h4d1fa1153a381a05E"(ptr align 8 %w)
          to label %bb9 unwind label %cleanup, !dbg !1058

bb8:                                              ; preds = %bb6
  br label %bb4, !dbg !1081

bb9:                                              ; preds = %bb7
; call core::ptr::drop_in_place<async_demo::guarded::{{closure}}>
  call void @"_ZN4core3ptr69drop_in_place$LT$async_demo..guarded..$u7b$$u7b$closure$u7d$$u7d$$GT$17h29807675ee04bd5aE"(ptr align 8 %_4), !dbg !1054
  ret i64 %v, !dbg !1082

bb14:                                             ; No predecessors!
  unreachable, !dbg !1083

terminate:                                        ; preds = %bb12, %bb11
  %19 = landingpad { ptr, i32 }
          filter [0 x ptr] zeroinitializer
  %20 = extractvalue { ptr, i32 } %19, 0
  %21 = extractvalue { ptr, i32 } %19, 1
; call core::panicking::panic_in_cleanup
  call void @_ZN4core9panicking16panic_in_cleanup17hb960b8c5dea287d4E() #10, !dbg !1083
  unreachable, !dbg !1083

bb13:                                             ; preds = %bb12
  %22 = load ptr, ptr %0, align 8, !dbg !1083
  %23 = getelementptr inbounds i8, ptr %0, i64 8, !dbg !1083
  %24 = load i32, ptr %23, align 8, !dbg !1083
  %25 = insertvalue { ptr, i32 } poison, ptr %22, 0, !dbg !1083
  %26 = insertvalue { ptr, i32 } %25, i32 %24, 1, !dbg !1083
  resume { ptr, i32 } %26, !dbg !1083
}

; async_demo::main
; Function Attrs: uwtable
define internal void @_ZN10async_demo4main17hd479f7dc0ca3a29fE() unnamed_addr #0 !dbg !1084 {
start:
  %_26 = alloca [32 x i8], align 8
  %_25 = alloca [8 x i8], align 8
  %_23 = alloca [16 x i8], align 8
  %_22 = alloca [16 x i8], align 8
  %_19 = alloca [48 x i8], align 8
  %_15 = alloca [40 x i8], align 8
  %_14 = alloca [8 x i8], align 8
  %_12 = alloca [16 x i8], align 8
  %_11 = alloca [16 x i8], align 8
  %_8 = alloca [48 x i8], align 8
  %b = alloca [16 x i8], align 8
  %a = alloca [16 x i8], align 8
    #dbg_declare(ptr %a, !1086, !DIExpression(), !1090)
    #dbg_declare(ptr %b, !1088, !DIExpression(), !1091)
; call core::hint::black_box
  %_2 = call i64 @_ZN4core4hint9black_box17h8f96ccdebaca3800E(i64 1), !dbg !1092
; call core::hint::black_box
  %_3 = call i64 @_ZN4core4hint9black_box17h8f96ccdebaca3800E(i64 10), !dbg !1093
  store i64 %_2, ptr %a, align 8, !dbg !1094
  %0 = getelementptr inbounds i8, ptr %a, i64 8, !dbg !1094
  store i64 %_3, ptr %0, align 8, !dbg !1094
; call core::hint::black_box
  %_5 = call i64 @_ZN4core4hint9black_box17h8f96ccdebaca3800E(i64 2), !dbg !1095
; call core::hint::black_box
  %_6 = call i64 @_ZN4core4hint9black_box17h8f96ccdebaca3800E(i64 20), !dbg !1096
  store i64 %_5, ptr %b, align 8, !dbg !1097
  %1 = getelementptr inbounds i8, ptr %b, i64 8, !dbg !1097
  store i64 %_6, ptr %1, align 8, !dbg !1097
; call core::hint::black_box
  %_16 = call align 8 ptr @_ZN4core4hint9black_box17h13e5c54c71dd8fc6E(ptr align 8 %a), !dbg !1098
; call async_demo::guarded
  call void @_ZN10async_demo7guarded17h35dc6076e8381621E(ptr sret([40 x i8]) align 8 %_15, ptr align 8 %_16), !dbg !1099
; call async_demo::block_on
  %2 = call i64 @_ZN10async_demo8block_on17he3c4265f92fcd2d4E(ptr align 8 %_15), !dbg !1100
  store i64 %2, ptr %_14, align 8, !dbg !1100
; call core::fmt::rt::Argument::new_display
  call void @_ZN4core3fmt2rt8Argument11new_display17h934768992fdcf840E(ptr sret([16 x i8]) align 8 %_12, ptr align 8 %_14), !dbg !1101
  %3 = getelementptr inbounds %"core::fmt::rt::Argument<'_>", ptr %_11, i64 0, !dbg !1101
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %3, ptr align 8 %_12, i64 16, i1 false), !dbg !1101
; call core::fmt::Arguments::new_v1
  call void @_ZN4core3fmt9Arguments6new_v117h38409ea89cea9582E(ptr sret([48 x i8]) align 8 %_8, ptr align 8 @alloc_9771be2481f51be410bd2ac520d18601, ptr align 8 %_11), !dbg !1101
; call std::io::stdio::_print
  call void @_ZN3std2io5stdio6_print17h6200d46cef53dee1E(ptr align 8 %_8), !dbg !1101
; call core::hint::black_box
  %_27 = call align 8 ptr @_ZN4core4hint9black_box17h13e5c54c71dd8fc6E(ptr align 8 %b), !dbg !1102
; call async_demo::unguarded
  call void @_ZN10async_demo9unguarded17h35b9685ebed6fe46E(ptr sret([32 x i8]) align 8 %_26, ptr align 8 %_27), !dbg !1103
; call async_demo::block_on
  %4 = call i64 @_ZN10async_demo8block_on17h4fd05f61446baf56E(ptr align 8 %_26), !dbg !1104
  store i64 %4, ptr %_25, align 8, !dbg !1104
; call core::fmt::rt::Argument::new_display
  call void @_ZN4core3fmt2rt8Argument11new_display17h934768992fdcf840E(ptr sret([16 x i8]) align 8 %_23, ptr align 8 %_25), !dbg !1105
  %5 = getelementptr inbounds %"core::fmt::rt::Argument<'_>", ptr %_22, i64 0, !dbg !1105
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %5, ptr align 8 %_23, i64 16, i1 false), !dbg !1105
; call core::fmt::Arguments::new_v1
  call void @_ZN4core3fmt9Arguments6new_v117h38409ea89cea9582E(ptr sret([48 x i8]) align 8 %_19, ptr align 8 @alloc_9771be2481f51be410bd2ac520d18601, ptr align 8 %_22), !dbg !1105
; call std::io::stdio::_print
  call void @_ZN3std2io5stdio6_print17h6200d46cef53dee1E(ptr align 8 %_19), !dbg !1105
  ret void, !dbg !1106
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
  %3 = call i64 @_ZN3std2rt10lang_start17hc3a208667dde6b6cE(ptr @_ZN10async_demo4main17hd479f7dc0ca3a29fE, i64 %2, ptr %1, i8 0)
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
!25 = distinct !DIGlobalVariable(name: "VT", linkageName: "_ZN10async_demo2VT17h057c6809b0537861E", scope: !26, file: !27, line: 45, type: !28, isLocal: true, isDefinition: true, align: 64)
!26 = !DINamespace(name: "async_demo", scope: null)
!27 = !DIFile(filename: "async_demo.rs", directory: "/Users/sanjib/codes/apace_lab/soap_afg_2026/repositories/AFG/afg_prototype/experiments/async-dominance-demo", checksumkind: CSK_MD5, checksum: "d340a0ad10b4ffff8efdf4b56bde942c")
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
!54 = !DIFile(filename: "async_demo.rs/@/async_demo.e4019b8fc89da6a0-cgu.0", directory: "/Users/sanjib/codes/apace_lab/soap_afg_2026/repositories/AFG/afg_prototype/experiments/async-dominance-demo")
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
!68 = distinct !DISubprogram(name: "lang_start<()>", linkageName: "_ZN3std2rt10lang_start17hc3a208667dde6b6cE", scope: !16, file: !69, line: 192, type: !70, scopeLine: 192, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !80, retainedNodes: !75)
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
!89 = distinct !DISubprogram(name: "{closure#0}<()>", linkageName: "_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h1a80b0c598e554bdE", scope: !15, file: !69, line: 199, type: !90, scopeLine: 199, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !80, retainedNodes: !94)
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
!100 = distinct !DISubprogram(name: "to_i32", linkageName: "_ZN3std7process8ExitCode6to_i3217h980bc4d242e7c7c7E", scope: !102, file: !101, line: 2060, type: !114, scopeLine: 2060, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, declaration: !116, retainedNodes: !117)
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
!116 = !DISubprogram(name: "to_i32", linkageName: "_ZN3std7process8ExitCode6to_i3217h980bc4d242e7c7c7E", scope: !102, file: !101, line: 2060, type: !114, scopeLine: 2060, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!117 = !{!99}
!118 = !DILocation(line: 2060, column: 19, scope: !100, inlinedAt: !119)
!119 = !DILocation(line: 199, column: 85, scope: !89)
!120 = !DILocation(line: 636, column: 9, scope: !121, inlinedAt: !127)
!121 = distinct !DISubprogram(name: "as_i32", linkageName: "_ZN3std3sys3pal4unix7process14process_common8ExitCode6as_i3217h82d5cf5191933bbbE", scope: !106, file: !122, line: 635, type: !123, scopeLine: 635, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, declaration: !126)
!122 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/std/src/sys/pal/unix/process/process_common.rs", directory: "", checksumkind: CSK_MD5, checksum: "7107dec5baaefd58adc486b058fd5a71")
!123 = !DISubroutineType(types: !124)
!124 = !{!92, !125}
!125 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&std::sys::pal::unix::process::process_common::ExitCode", baseType: !106, size: 64, align: 64, dwarfAddressSpace: 0)
!126 = !DISubprogram(name: "as_i32", linkageName: "_ZN3std3sys3pal4unix7process14process_common8ExitCode6as_i3217h82d5cf5191933bbbE", scope: !106, file: !122, line: 635, type: !123, scopeLine: 635, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!127 = !DILocation(line: 2061, column: 16, scope: !100, inlinedAt: !119)
!128 = !DILocation(line: 199, column: 93, scope: !89)
!129 = distinct !DISubprogram(name: "__rust_begin_short_backtrace<fn(), ()>", linkageName: "_ZN3std3sys9backtrace28__rust_begin_short_backtrace17hc83f88d1d2675206E", scope: !131, file: !130, line: 148, type: !132, scopeLine: 148, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !138, retainedNodes: !134)
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
!143 = distinct !DISubprogram(name: "black_box<()>", linkageName: "_ZN4core4hint9black_box17hc13ecc66c998934eE", scope: !145, file: !144, line: 476, type: !146, scopeLine: 476, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !80, retainedNodes: !148)
!144 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/hint.rs", directory: "", checksumkind: CSK_MD5, checksum: "4d6fc217f737459a7201759c6559d6c1")
!145 = !DINamespace(name: "hint", scope: !31)
!146 = !DISubroutineType(types: !147)
!147 = !{null, !7}
!148 = !{!142}
!149 = !DILocation(line: 476, column: 27, scope: !143, inlinedAt: !150)
!150 = !DILocation(line: 155, column: 5, scope: !137)
!151 = !DILocation(line: 152, column: 18, scope: !129)
!152 = !DILocation(line: 477, column: 5, scope: !143, inlinedAt: !150)
!153 = !{i64 5278866995331319}
!154 = !DILocation(line: 158, column: 2, scope: !129)
!155 = distinct !DISubprogram(name: "new_display<u64>", linkageName: "_ZN4core3fmt2rt8Argument11new_display17h934768992fdcf840E", scope: !157, file: !156, line: 113, type: !257, scopeLine: 113, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !261, declaration: !260, retainedNodes: !263)
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
!260 = !DISubprogram(name: "new_display<u64>", linkageName: "_ZN4core3fmt2rt8Argument11new_display17h934768992fdcf840E", scope: !157, file: !156, line: 113, type: !257, scopeLine: 113, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !261)
!261 = !{!262}
!262 = !DITemplateTypeParameter(name: "T", type: !233)
!263 = !{!264}
!264 = !DILocalVariable(name: "x", arg: 1, scope: !155, file: !156, line: 113, type: !259)
!265 = !DILocation(line: 113, column: 36, scope: !155)
!266 = !DILocalVariable(name: "x", arg: 1, scope: !267, file: !156, line: 99, type: !259)
!267 = distinct !DISubprogram(name: "new<u64>", linkageName: "_ZN4core3fmt2rt8Argument3new17hba2c9784b289f453E", scope: !157, file: !156, line: 99, type: !268, scopeLine: 99, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !261, declaration: !273, retainedNodes: !274)
!268 = !DISubroutineType(types: !269)
!269 = !{!157, !259, !270}
!270 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "fn(&u64, &mut core::fmt::Formatter) -> core::result::Result<(), core::fmt::Error>", baseType: !271, size: 64, align: 64, dwarfAddressSpace: 0)
!271 = !DISubroutineType(types: !272)
!272 = !{!177, !259, !194}
!273 = !DISubprogram(name: "new<u64>", linkageName: "_ZN4core3fmt2rt8Argument3new17hba2c9784b289f453E", scope: !157, file: !156, line: 99, type: !268, scopeLine: 99, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !261)
!274 = !{!266}
!275 = !DILocation(line: 99, column: 25, scope: !267, inlinedAt: !276)
!276 = !DILocation(line: 114, column: 9, scope: !155)
!277 = !DILocalVariable(name: "r", arg: 1, scope: !278, file: !279, line: 268, type: !259)
!278 = distinct !DISubprogram(name: "from_ref<u64>", linkageName: "_ZN4core3ptr8non_null16NonNull$LT$T$GT$8from_ref17h689fcf4ce9d3dbceE", scope: !280, file: !279, line: 268, type: !284, scopeLine: 268, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !261, declaration: !286, retainedNodes: !287)
!279 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/ptr/non_null.rs", directory: "", checksumkind: CSK_MD5, checksum: "f45049b8fe718e09b04e14006dd7e8d3")
!280 = !DICompositeType(tag: DW_TAG_structure_type, name: "NonNull<u64>", scope: !169, file: !2, size: 64, align: 64, flags: DIFlagPublic, elements: !281, templateParams: !261, identifier: "f0315fbb7066bb2768a6e4ebf06aee69")
!281 = !{!282}
!282 = !DIDerivedType(tag: DW_TAG_member, name: "pointer", scope: !280, file: !2, baseType: !283, size: 64, align: 64, flags: DIFlagPrivate)
!283 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*const u64", baseType: !233, size: 64, align: 64, dwarfAddressSpace: 0)
!284 = !DISubroutineType(types: !285)
!285 = !{!280, !259}
!286 = !DISubprogram(name: "from_ref<u64>", linkageName: "_ZN4core3ptr8non_null16NonNull$LT$T$GT$8from_ref17h689fcf4ce9d3dbceE", scope: !280, file: !279, line: 268, type: !284, scopeLine: 268, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !261)
!287 = !{!277}
!288 = !DILocation(line: 268, column: 27, scope: !278, inlinedAt: !289)
!289 = !DILocation(line: 104, column: 24, scope: !267, inlinedAt: !276)
!290 = !DILocation(line: 103, column: 17, scope: !267, inlinedAt: !276)
!291 = !DILocation(line: 100, column: 9, scope: !267, inlinedAt: !276)
!292 = !DILocation(line: 115, column: 6, scope: !155)
!293 = distinct !DISubprogram(name: "new_v1<2, 1>", linkageName: "_ZN4core3fmt9Arguments6new_v117h38409ea89cea9582E", scope: !295, file: !294, line: 608, type: !356, scopeLine: 608, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, declaration: !366, retainedNodes: !367)
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
!366 = !DISubprogram(name: "new_v1<2, 1>", linkageName: "_ZN4core3fmt9Arguments6new_v117h38409ea89cea9582E", scope: !295, file: !294, line: 608, type: !356, scopeLine: 608, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!367 = !{!368, !369}
!368 = !DILocalVariable(name: "pieces", arg: 1, scope: !293, file: !294, line: 609, type: !358)
!369 = !DILocalVariable(name: "args", arg: 2, scope: !293, file: !294, line: 610, type: !362)
!370 = !DILocation(line: 609, column: 9, scope: !293)
!371 = !DILocation(line: 610, column: 9, scope: !293)
!372 = !DILocation(line: 613, column: 9, scope: !293)
!373 = !DILocation(line: 614, column: 6, scope: !293)
!374 = distinct !DISubprogram(name: "call_once<std::rt::lang_start::{closure_env#0}<()>, ()>", linkageName: "_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h6c0bdd59af1e11d0E", scope: !376, file: !375, line: 250, type: !379, scopeLine: 250, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !385, retainedNodes: !382)
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
!389 = distinct !DISubprogram(name: "call_once<std::rt::lang_start::{closure_env#0}<()>, ()>", linkageName: "_ZN4core3ops8function6FnOnce9call_once17h1dfc07f73a005900E", scope: !376, file: !375, line: 250, type: !390, scopeLine: 250, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !385, retainedNodes: !392)
!390 = !DISubroutineType(types: !391)
!391 = !{!92, !14}
!392 = !{!393, !394}
!393 = !DILocalVariable(arg: 1, scope: !389, file: !375, line: 250, type: !14)
!394 = !DILocalVariable(arg: 2, scope: !389, file: !375, line: 250, type: !7)
!395 = !DILocation(line: 250, column: 5, scope: !389)
!396 = distinct !DISubprogram(name: "call_once<fn(), ()>", linkageName: "_ZN4core3ops8function6FnOnce9call_once17he3bfffd33b8a6865E", scope: !376, file: !375, line: 250, type: !132, scopeLine: 250, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !400, retainedNodes: !397)
!397 = !{!398, !399}
!398 = !DILocalVariable(arg: 1, scope: !396, file: !375, line: 250, type: !20)
!399 = !DILocalVariable(arg: 2, scope: !396, file: !375, line: 250, type: !7)
!400 = !{!401, !387}
!401 = !DITemplateTypeParameter(name: "Self", type: !20)
!402 = !DILocation(line: 250, column: 5, scope: !396)
!403 = distinct !DISubprogram(name: "drop_in_place<core::task::wake::Waker>", linkageName: "_ZN4core3ptr44drop_in_place$LT$core..task..wake..Waker$GT$17h4d1fa1153a381a05E", scope: !170, file: !404, line: 523, type: !405, scopeLine: 523, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !413, retainedNodes: !411)
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
!416 = distinct !DISubprogram(name: "drop_in_place<async_demo::db_read::{async_fn_env#0}>", linkageName: "_ZN4core3ptr69drop_in_place$LT$async_demo..db_read..$u7b$$u7b$closure$u7d$$u7d$$GT$17h7d9c75f079191aceE", scope: !170, file: !404, line: 523, type: !417, scopeLine: 523, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !501, retainedNodes: !443)
!417 = !DISubroutineType(types: !418)
!418 = !{null, !419}
!419 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*mut async_demo::db_read::{async_fn_env#0}", baseType: !420, size: 64, align: 64, dwarfAddressSpace: 0)
!420 = !DICompositeType(tag: DW_TAG_structure_type, name: "{async_fn_env#0}", scope: !421, file: !2, size: 128, align: 64, elements: !422, templateParams: !23, identifier: "5cbc05eaefdc9a1a888a9ef302f1d55b")
!421 = !DINamespace(name: "db_read", scope: !26)
!422 = !{!423}
!423 = !DICompositeType(tag: DW_TAG_variant_part, scope: !420, file: !2, size: 128, align: 64, elements: !424, templateParams: !23, identifier: "4dfde12019a7e38b86eb230cdfadb0d2", discriminator: !442)
!424 = !{!425, !434, !438}
!425 = !DIDerivedType(tag: DW_TAG_member, name: "0", scope: !423, file: !27, line: 21, baseType: !426, size: 128, align: 64, extraData: i8 0)
!426 = !DICompositeType(tag: DW_TAG_structure_type, name: "Unresumed", scope: !420, file: !2, size: 128, align: 64, elements: !427, templateParams: !23, identifier: "22910010f10ce49fd556135dcff100dc")
!427 = !{!428}
!428 = !DIDerivedType(tag: DW_TAG_member, name: "r", scope: !426, file: !2, baseType: !429, size: 64, align: 64)
!429 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&async_demo::Resource", baseType: !430, size: 64, align: 64, dwarfAddressSpace: 0)
!430 = !DICompositeType(tag: DW_TAG_structure_type, name: "Resource", scope: !26, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !431, templateParams: !23, identifier: "afa87766786681be2cd8003cd209c93a")
!431 = !{!432, !433}
!432 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !430, file: !2, baseType: !233, size: 64, align: 64, flags: DIFlagPublic)
!433 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !430, file: !2, baseType: !233, size: 64, align: 64, offset: 64, flags: DIFlagPublic)
!434 = !DIDerivedType(tag: DW_TAG_member, name: "1", scope: !423, file: !27, line: 23, baseType: !435, size: 128, align: 64, extraData: i8 1)
!435 = !DICompositeType(tag: DW_TAG_structure_type, name: "Returned", scope: !420, file: !2, size: 128, align: 64, elements: !436, templateParams: !23, identifier: "6d85d883377a70dc78dcb602a7750b80")
!436 = !{!437}
!437 = !DIDerivedType(tag: DW_TAG_member, name: "r", scope: !435, file: !2, baseType: !429, size: 64, align: 64)
!438 = !DIDerivedType(tag: DW_TAG_member, name: "2", scope: !423, file: !27, line: 23, baseType: !439, size: 128, align: 64, extraData: i8 2)
!439 = !DICompositeType(tag: DW_TAG_structure_type, name: "Panicked", scope: !420, file: !2, size: 128, align: 64, elements: !440, templateParams: !23, identifier: "de8f1027638e9c4284d6d589a267a142")
!440 = !{!441}
!441 = !DIDerivedType(tag: DW_TAG_member, name: "r", scope: !439, file: !2, baseType: !429, size: 64, align: 64)
!442 = !DIDerivedType(tag: DW_TAG_member, name: "__state", scope: !420, file: !2, baseType: !58, size: 8, align: 8, offset: 64, flags: DIFlagArtificial)
!443 = !{!444, !498, !499}
!444 = !DILocalVariable(name: "_task_context", scope: !416, file: !27, line: 21, type: !445, align: 64)
!445 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut core::task::wake::Context", baseType: !446, size: 64, align: 64, dwarfAddressSpace: 0)
!446 = !DICompositeType(tag: DW_TAG_structure_type, name: "Context", scope: !29, file: !2, size: 256, align: 64, flags: DIFlagPublic, elements: !447, templateParams: !23, identifier: "5f4b5cdd9973f32ba36879e96e44e62c")
!447 = !{!448, !450, !455, !486, !493}
!448 = !DIDerivedType(tag: DW_TAG_member, name: "waker", scope: !446, file: !2, baseType: !449, size: 64, align: 64, flags: DIFlagPrivate)
!449 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&core::task::wake::Waker", baseType: !408, size: 64, align: 64, dwarfAddressSpace: 0)
!450 = !DIDerivedType(tag: DW_TAG_member, name: "local_waker", scope: !446, file: !2, baseType: !451, size: 64, align: 64, offset: 64, flags: DIFlagPrivate)
!451 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&core::task::wake::LocalWaker", baseType: !452, size: 64, align: 64, dwarfAddressSpace: 0)
!452 = !DICompositeType(tag: DW_TAG_structure_type, name: "LocalWaker", scope: !29, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !453, templateParams: !23, identifier: "55ba0586d91a66a8c4d5295c2a05a07f")
!453 = !{!454}
!454 = !DIDerivedType(tag: DW_TAG_member, name: "waker", scope: !452, file: !2, baseType: !37, size: 128, align: 64, flags: DIFlagPrivate)
!455 = !DIDerivedType(tag: DW_TAG_member, name: "ext", scope: !446, file: !2, baseType: !456, size: 128, align: 64, offset: 128, flags: DIFlagPrivate)
!456 = !DICompositeType(tag: DW_TAG_structure_type, name: "AssertUnwindSafe<core::task::wake::ExtData>", scope: !457, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !459, templateParams: !484, identifier: "3ab915a54d9402cf04748efb8a1a38d")
!457 = !DINamespace(name: "unwind_safe", scope: !458)
!458 = !DINamespace(name: "panic", scope: !31)
!459 = !{!460}
!460 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !456, file: !2, baseType: !461, size: 128, align: 64, flags: DIFlagPublic)
!461 = !DICompositeType(tag: DW_TAG_structure_type, name: "ExtData", scope: !29, file: !2, size: 128, align: 64, flags: DIFlagPrivate, elements: !462, templateParams: !23, identifier: "3151400636dbb550d1179560d475fb7b")
!462 = !{!463}
!463 = !DICompositeType(tag: DW_TAG_variant_part, scope: !461, file: !2, size: 128, align: 64, elements: !464, templateParams: !23, identifier: "ae003c5eec8f31bcfedef7ca9e3e403b", discriminator: !483)
!464 = !{!465, !479}
!465 = !DIDerivedType(tag: DW_TAG_member, name: "Some", scope: !463, file: !2, baseType: !466, size: 128, align: 64)
!466 = !DICompositeType(tag: DW_TAG_structure_type, name: "Some", scope: !461, file: !2, size: 128, align: 64, flags: DIFlagPrivate, elements: !467, templateParams: !23, identifier: "caca0d8422ecf9bd10bd4379d017c8a6")
!467 = !{!468}
!468 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !466, file: !2, baseType: !469, size: 128, align: 64, flags: DIFlagPrivate)
!469 = !DICompositeType(tag: DW_TAG_structure_type, name: "&mut dyn core::any::Any", file: !2, size: 128, align: 64, elements: !470, templateParams: !23, identifier: "d858f69fa2f7180e88665e32f850f0ff")
!470 = !{!471, !474}
!471 = !DIDerivedType(tag: DW_TAG_member, name: "pointer", scope: !469, file: !2, baseType: !472, size: 64, align: 64)
!472 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !473, size: 64, align: 64, dwarfAddressSpace: 0)
!473 = !DICompositeType(tag: DW_TAG_structure_type, name: "dyn core::any::Any", file: !2, align: 8, elements: !23, identifier: "c95144c9f0ec102da8273af1dc5f0479")
!474 = !DIDerivedType(tag: DW_TAG_member, name: "vtable", scope: !469, file: !2, baseType: !475, size: 64, align: 64, offset: 64)
!475 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&[usize; 4]", baseType: !476, size: 64, align: 64, dwarfAddressSpace: 0)
!476 = !DICompositeType(tag: DW_TAG_array_type, baseType: !9, size: 256, align: 64, elements: !477)
!477 = !{!478}
!478 = !DISubrange(count: 4, lowerBound: 0)
!479 = !DIDerivedType(tag: DW_TAG_member, name: "None", scope: !463, file: !2, baseType: !480, size: 128, align: 64, extraData: i64 0)
!480 = !DICompositeType(tag: DW_TAG_structure_type, name: "None", scope: !461, file: !2, size: 128, align: 64, flags: DIFlagPrivate, elements: !481, templateParams: !23, identifier: "6d10cbe44bdd8287d99a04d5cb830055")
!481 = !{!482}
!482 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !480, file: !2, baseType: !7, align: 8, flags: DIFlagPrivate)
!483 = !DIDerivedType(tag: DW_TAG_member, scope: !461, file: !2, baseType: !233, size: 64, align: 64, flags: DIFlagArtificial)
!484 = !{!485}
!485 = !DITemplateTypeParameter(name: "T", type: !461)
!486 = !DIDerivedType(tag: DW_TAG_member, name: "_marker", scope: !446, file: !2, baseType: !487, align: 8, offset: 256, flags: DIFlagPrivate)
!487 = !DICompositeType(tag: DW_TAG_structure_type, name: "PhantomData<fn(&()) -> &()>", scope: !248, file: !2, align: 8, flags: DIFlagPublic, elements: !23, templateParams: !488, identifier: "aa85cd4bea5f0b2e1ac5e24c3b1d7ec")
!488 = !{!489}
!489 = !DITemplateTypeParameter(name: "T", type: !490)
!490 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "fn(&()) -> &()", baseType: !491, size: 64, align: 64, dwarfAddressSpace: 0)
!491 = !DISubroutineType(types: !492)
!492 = !{!251, !251}
!493 = !DIDerivedType(tag: DW_TAG_member, name: "_marker2", scope: !446, file: !2, baseType: !494, align: 8, offset: 256, flags: DIFlagPrivate)
!494 = !DICompositeType(tag: DW_TAG_structure_type, name: "PhantomData<*mut ()>", scope: !248, file: !2, align: 8, flags: DIFlagPublic, elements: !23, templateParams: !495, identifier: "c165d6d88d2658ef9dad4545d253cff5")
!495 = !{!496}
!496 = !DITemplateTypeParameter(name: "T", type: !497)
!497 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*mut ()", baseType: !7, size: 64, align: 64, dwarfAddressSpace: 0)
!498 = !DILocalVariable(name: "r", scope: !416, file: !27, line: 21, type: !429, align: 64)
!499 = !DILocalVariable(name: "r", scope: !500, file: !27, line: 21, type: !429, align: 64)
!500 = distinct !DILexicalBlock(scope: !416, file: !27, line: 21, column: 43)
!501 = !{!502}
!502 = !DITemplateTypeParameter(name: "T", type: !420)
!503 = !DILocation(line: 21, column: 22, scope: !416)
!504 = !DILocation(line: 21, column: 43, scope: !416)
!505 = distinct !DISubprogram(name: "drop_in_place<async_demo::guarded::{async_fn_env#0}>", linkageName: "_ZN4core3ptr69drop_in_place$LT$async_demo..guarded..$u7b$$u7b$closure$u7d$$u7d$$GT$17h29807675ee04bd5aE", scope: !170, file: !404, line: 523, type: !506, scopeLine: 523, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !569, retainedNodes: !555)
!506 = !DISubroutineType(types: !507)
!507 = !{null, !508}
!508 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*mut async_demo::guarded::{async_fn_env#0}", baseType: !509, size: 64, align: 64, dwarfAddressSpace: 0)
!509 = !DICompositeType(tag: DW_TAG_structure_type, name: "{async_fn_env#0}", scope: !510, file: !2, size: 320, align: 64, elements: !511, templateParams: !23, identifier: "6e9c7b3924d938215734d4962a5daa50")
!510 = !DINamespace(name: "guarded", scope: !26)
!511 = !{!512}
!512 = !DICompositeType(tag: DW_TAG_variant_part, scope: !509, file: !2, size: 320, align: 64, elements: !513, templateParams: !23, identifier: "1c1daba0767fff5cab55f786a7b0ef28", discriminator: !554)
!513 = !{!514, !518, !522, !526, !549}
!514 = !DIDerivedType(tag: DW_TAG_member, name: "0", scope: !512, file: !27, line: 28, baseType: !515, size: 320, align: 64, extraData: i8 0)
!515 = !DICompositeType(tag: DW_TAG_structure_type, name: "Unresumed", scope: !509, file: !2, size: 320, align: 64, elements: !516, templateParams: !23, identifier: "f67fbead3deb75402ae4fd4483e411e2")
!516 = !{!517}
!517 = !DIDerivedType(tag: DW_TAG_member, name: "r", scope: !515, file: !2, baseType: !429, size: 64, align: 64)
!518 = !DIDerivedType(tag: DW_TAG_member, name: "1", scope: !512, file: !27, line: 34, baseType: !519, size: 320, align: 64, extraData: i8 1)
!519 = !DICompositeType(tag: DW_TAG_structure_type, name: "Returned", scope: !509, file: !2, size: 320, align: 64, elements: !520, templateParams: !23, identifier: "2b91edb8d7476893bfe099258457fda7")
!520 = !{!521}
!521 = !DIDerivedType(tag: DW_TAG_member, name: "r", scope: !519, file: !2, baseType: !429, size: 64, align: 64)
!522 = !DIDerivedType(tag: DW_TAG_member, name: "2", scope: !512, file: !27, line: 34, baseType: !523, size: 320, align: 64, extraData: i8 2)
!523 = !DICompositeType(tag: DW_TAG_structure_type, name: "Panicked", scope: !509, file: !2, size: 320, align: 64, elements: !524, templateParams: !23, identifier: "5b986e12f39305d78c82e54214d25f7c")
!524 = !{!525}
!525 = !DIDerivedType(tag: DW_TAG_member, name: "r", scope: !523, file: !2, baseType: !429, size: 64, align: 64)
!526 = !DIDerivedType(tag: DW_TAG_member, name: "3", scope: !512, file: !27, line: 29, baseType: !527, size: 320, align: 64, extraData: i8 3)
!527 = !DICompositeType(tag: DW_TAG_structure_type, name: "Suspend0", scope: !509, file: !2, size: 320, align: 64, elements: !528, templateParams: !23, identifier: "6b5e2fa9dcbc2abd323bc8ace365ebe3")
!528 = !{!529, !530, !529}
!529 = !DIDerivedType(tag: DW_TAG_member, name: "r", scope: !527, file: !2, baseType: !429, size: 64, align: 64, offset: 64)
!530 = !DIDerivedType(tag: DW_TAG_member, name: "__awaitee", scope: !527, file: !2, baseType: !531, size: 128, align: 64, offset: 192)
!531 = !DICompositeType(tag: DW_TAG_structure_type, name: "{async_fn_env#0}", scope: !532, file: !2, size: 128, align: 64, elements: !533, templateParams: !23, identifier: "2ae86695b7360077598bffb78ed62e5f")
!532 = !DINamespace(name: "authorize", scope: !26)
!533 = !{!534}
!534 = !DICompositeType(tag: DW_TAG_variant_part, scope: !531, file: !2, size: 128, align: 64, elements: !535, templateParams: !23, identifier: "370197270e9e7a8e4dfe673cc1d276d8", discriminator: !548)
!535 = !{!536, !540, !544}
!536 = !DIDerivedType(tag: DW_TAG_member, name: "0", scope: !534, file: !27, line: 16, baseType: !537, size: 128, align: 64, extraData: i8 0)
!537 = !DICompositeType(tag: DW_TAG_structure_type, name: "Unresumed", scope: !531, file: !2, size: 128, align: 64, elements: !538, templateParams: !23, identifier: "74ff370dc1b965b15d22bf5de678d101")
!538 = !{!539}
!539 = !DIDerivedType(tag: DW_TAG_member, name: "r", scope: !537, file: !2, baseType: !429, size: 64, align: 64)
!540 = !DIDerivedType(tag: DW_TAG_member, name: "1", scope: !534, file: !27, line: 18, baseType: !541, size: 128, align: 64, extraData: i8 1)
!541 = !DICompositeType(tag: DW_TAG_structure_type, name: "Returned", scope: !531, file: !2, size: 128, align: 64, elements: !542, templateParams: !23, identifier: "e20d0e48a663e4f7960a60a2f5598f5a")
!542 = !{!543}
!543 = !DIDerivedType(tag: DW_TAG_member, name: "r", scope: !541, file: !2, baseType: !429, size: 64, align: 64)
!544 = !DIDerivedType(tag: DW_TAG_member, name: "2", scope: !534, file: !27, line: 18, baseType: !545, size: 128, align: 64, extraData: i8 2)
!545 = !DICompositeType(tag: DW_TAG_structure_type, name: "Panicked", scope: !531, file: !2, size: 128, align: 64, elements: !546, templateParams: !23, identifier: "dc8ee629c14c76b99b682e7703308283")
!546 = !{!547}
!547 = !DIDerivedType(tag: DW_TAG_member, name: "r", scope: !545, file: !2, baseType: !429, size: 64, align: 64)
!548 = !DIDerivedType(tag: DW_TAG_member, name: "__state", scope: !531, file: !2, baseType: !58, size: 8, align: 8, offset: 64, flags: DIFlagArtificial)
!549 = !DIDerivedType(tag: DW_TAG_member, name: "4", scope: !512, file: !27, line: 30, baseType: !550, size: 320, align: 64, extraData: i8 4)
!550 = !DICompositeType(tag: DW_TAG_structure_type, name: "Suspend1", scope: !509, file: !2, size: 320, align: 64, elements: !551, templateParams: !23, identifier: "5bbaa9f5bec9cfa1b6aaf40e6f1c38f0")
!551 = !{!552, !553}
!552 = !DIDerivedType(tag: DW_TAG_member, name: "__awaitee", scope: !550, file: !2, baseType: !420, size: 128, align: 64, offset: 192)
!553 = !DIDerivedType(tag: DW_TAG_member, name: "r", scope: !550, file: !2, baseType: !429, size: 64, align: 64)
!554 = !DIDerivedType(tag: DW_TAG_member, name: "__state", scope: !509, file: !2, baseType: !58, size: 8, align: 8, offset: 128, flags: DIFlagArtificial)
!555 = !{!556, !557, !558, !560, !562, !565, !567}
!556 = !DILocalVariable(name: "_task_context", scope: !505, file: !27, line: 28, type: !445, align: 64)
!557 = !DILocalVariable(name: "r", scope: !505, file: !27, line: 28, type: !429, align: 64)
!558 = !DILocalVariable(name: "r", scope: !559, file: !27, line: 28, type: !429, align: 64)
!559 = distinct !DILexicalBlock(scope: !505, file: !27, line: 28, column: 43)
!560 = !DILocalVariable(name: "__awaitee", scope: !561, file: !27, line: 29, type: !531, align: 64)
!561 = distinct !DILexicalBlock(scope: !559, file: !27, line: 29, column: 21)
!562 = !DILocalVariable(name: "result", scope: !563, file: !27, line: 29, type: !564, align: 8)
!563 = distinct !DILexicalBlock(scope: !561, file: !27, line: 29, column: 8)
!564 = !DIBasicType(name: "bool", size: 8, encoding: DW_ATE_boolean)
!565 = !DILocalVariable(name: "__awaitee", scope: !566, file: !27, line: 30, type: !420, align: 64)
!566 = distinct !DILexicalBlock(scope: !559, file: !27, line: 30, column: 20)
!567 = !DILocalVariable(name: "result", scope: !568, file: !27, line: 30, type: !233, align: 64)
!568 = distinct !DILexicalBlock(scope: !566, file: !27, line: 30, column: 9)
!569 = !{!570}
!570 = !DITemplateTypeParameter(name: "T", type: !509)
!571 = !DILocation(line: 28, column: 22, scope: !505)
!572 = !DILocation(line: 28, column: 22, scope: !559)
!573 = !DILocation(line: 29, column: 8, scope: !561)
!574 = !DILocation(line: 30, column: 9, scope: !566)
!575 = !DILocation(line: 28, column: 43, scope: !505)
!576 = !DILocation(line: 29, column: 25, scope: !559)
!577 = !DILocation(line: 30, column: 24, scope: !559)
!578 = !DILocation(line: 0, scope: !559)
!579 = distinct !DISubprogram(name: "drop_in_place<async_demo::authorize::{async_fn_env#0}>", linkageName: "_ZN4core3ptr71drop_in_place$LT$async_demo..authorize..$u7b$$u7b$closure$u7d$$u7d$$GT$17h162b842d851e2706E", scope: !170, file: !404, line: 523, type: !580, scopeLine: 523, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !588, retainedNodes: !583)
!580 = !DISubroutineType(types: !581)
!581 = !{null, !582}
!582 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*mut async_demo::authorize::{async_fn_env#0}", baseType: !531, size: 64, align: 64, dwarfAddressSpace: 0)
!583 = !{!584, !585, !586}
!584 = !DILocalVariable(name: "_task_context", scope: !579, file: !27, line: 16, type: !445, align: 64)
!585 = !DILocalVariable(name: "r", scope: !579, file: !27, line: 16, type: !429, align: 64)
!586 = !DILocalVariable(name: "r", scope: !587, file: !27, line: 16, type: !429, align: 64)
!587 = distinct !DILexicalBlock(scope: !579, file: !27, line: 16, column: 46)
!588 = !{!589}
!589 = !DITemplateTypeParameter(name: "T", type: !531)
!590 = !DILocation(line: 16, column: 24, scope: !579)
!591 = !DILocation(line: 16, column: 46, scope: !579)
!592 = distinct !DISubprogram(name: "drop_in_place<async_demo::unguarded::{async_fn_env#0}>", linkageName: "_ZN4core3ptr71drop_in_place$LT$async_demo..unguarded..$u7b$$u7b$closure$u7d$$u7d$$GT$17hd47c4069b6e3428cE", scope: !170, file: !404, line: 523, type: !593, scopeLine: 523, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !628, retainedNodes: !619)
!593 = !DISubroutineType(types: !594)
!594 = !{null, !595}
!595 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*mut async_demo::unguarded::{async_fn_env#0}", baseType: !596, size: 64, align: 64, dwarfAddressSpace: 0)
!596 = !DICompositeType(tag: DW_TAG_structure_type, name: "{async_fn_env#0}", scope: !597, file: !2, size: 256, align: 64, elements: !598, templateParams: !23, identifier: "32e92aa6e99202009a9df12146ba35e8")
!597 = !DINamespace(name: "unguarded", scope: !26)
!598 = !{!599}
!599 = !DICompositeType(tag: DW_TAG_variant_part, scope: !596, file: !2, size: 256, align: 64, elements: !600, templateParams: !23, identifier: "62ed494123b77c947b66f6f1faf30d19", discriminator: !618)
!600 = !{!601, !605, !609, !613}
!601 = !DIDerivedType(tag: DW_TAG_member, name: "0", scope: !599, file: !27, line: 37, baseType: !602, size: 256, align: 64, extraData: i8 0)
!602 = !DICompositeType(tag: DW_TAG_structure_type, name: "Unresumed", scope: !596, file: !2, size: 256, align: 64, elements: !603, templateParams: !23, identifier: "d0cd7d9e4d119e433d1910a89c4c8a82")
!603 = !{!604}
!604 = !DIDerivedType(tag: DW_TAG_member, name: "r", scope: !602, file: !2, baseType: !429, size: 64, align: 64)
!605 = !DIDerivedType(tag: DW_TAG_member, name: "1", scope: !599, file: !27, line: 39, baseType: !606, size: 256, align: 64, extraData: i8 1)
!606 = !DICompositeType(tag: DW_TAG_structure_type, name: "Returned", scope: !596, file: !2, size: 256, align: 64, elements: !607, templateParams: !23, identifier: "644fa48cc22bc7f3ef912913690d7e7a")
!607 = !{!608}
!608 = !DIDerivedType(tag: DW_TAG_member, name: "r", scope: !606, file: !2, baseType: !429, size: 64, align: 64)
!609 = !DIDerivedType(tag: DW_TAG_member, name: "2", scope: !599, file: !27, line: 39, baseType: !610, size: 256, align: 64, extraData: i8 2)
!610 = !DICompositeType(tag: DW_TAG_structure_type, name: "Panicked", scope: !596, file: !2, size: 256, align: 64, elements: !611, templateParams: !23, identifier: "9c8716e9061e1e1417052314f797eba6")
!611 = !{!612}
!612 = !DIDerivedType(tag: DW_TAG_member, name: "r", scope: !610, file: !2, baseType: !429, size: 64, align: 64)
!613 = !DIDerivedType(tag: DW_TAG_member, name: "3", scope: !599, file: !27, line: 38, baseType: !614, size: 256, align: 64, extraData: i8 3)
!614 = !DICompositeType(tag: DW_TAG_structure_type, name: "Suspend0", scope: !596, file: !2, size: 256, align: 64, elements: !615, templateParams: !23, identifier: "3782fa2ec17bc99a411d942270f75cca")
!615 = !{!616, !617}
!616 = !DIDerivedType(tag: DW_TAG_member, name: "__awaitee", scope: !614, file: !2, baseType: !420, size: 128, align: 64, offset: 64)
!617 = !DIDerivedType(tag: DW_TAG_member, name: "r", scope: !614, file: !2, baseType: !429, size: 64, align: 64)
!618 = !DIDerivedType(tag: DW_TAG_member, name: "__state", scope: !596, file: !2, baseType: !58, size: 8, align: 8, offset: 192, flags: DIFlagArtificial)
!619 = !{!620, !621, !622, !624, !626}
!620 = !DILocalVariable(name: "_task_context", scope: !592, file: !27, line: 37, type: !445, align: 64)
!621 = !DILocalVariable(name: "r", scope: !592, file: !27, line: 37, type: !429, align: 64)
!622 = !DILocalVariable(name: "r", scope: !623, file: !27, line: 37, type: !429, align: 64)
!623 = distinct !DILexicalBlock(scope: !592, file: !27, line: 37, column: 45)
!624 = !DILocalVariable(name: "__awaitee", scope: !625, file: !27, line: 38, type: !420, align: 64)
!625 = distinct !DILexicalBlock(scope: !623, file: !27, line: 38, column: 16)
!626 = !DILocalVariable(name: "result", scope: !627, file: !27, line: 38, type: !233, align: 64)
!627 = distinct !DILexicalBlock(scope: !625, file: !27, line: 38, column: 5)
!628 = !{!629}
!629 = !DITemplateTypeParameter(name: "T", type: !596)
!630 = !DILocation(line: 37, column: 24, scope: !592)
!631 = !DILocation(line: 38, column: 5, scope: !625)
!632 = !DILocation(line: 37, column: 45, scope: !592)
!633 = !DILocation(line: 38, column: 20, scope: !623)
!634 = distinct !DISubprogram(name: "drop_in_place<std::rt::lang_start::{closure_env#0}<()>>", linkageName: "_ZN4core3ptr85drop_in_place$LT$std..rt..lang_start$LT$$LP$$RP$$GT$..$u7b$$u7b$closure$u7d$$u7d$$GT$17h41421d03cdbf9088E", scope: !170, file: !404, line: 523, type: !635, scopeLine: 523, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !639, retainedNodes: !637)
!635 = !DISubroutineType(types: !636)
!636 = !{null, !381}
!637 = !{!638}
!638 = !DILocalVariable(arg: 1, scope: !634, file: !404, line: 523, type: !381)
!639 = !{!640}
!640 = !DITemplateTypeParameter(name: "T", type: !14)
!641 = !DILocation(line: 523, column: 1, scope: !634)
!642 = distinct !DISubprogram(name: "black_box<&async_demo::Resource>", linkageName: "_ZN4core4hint9black_box17h13e5c54c71dd8fc6E", scope: !145, file: !144, line: 476, type: !643, scopeLine: 476, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !647, retainedNodes: !645)
!643 = !DISubroutineType(types: !644)
!644 = !{!429, !429}
!645 = !{!646}
!646 = !DILocalVariable(name: "dummy", arg: 1, scope: !642, file: !144, line: 476, type: !429)
!647 = !{!648}
!648 = !DITemplateTypeParameter(name: "T", type: !429)
!649 = !DILocation(line: 476, column: 27, scope: !642)
!650 = !DILocation(line: 477, column: 5, scope: !642)
!651 = !DILocation(line: 478, column: 2, scope: !642)
!652 = distinct !DISubprogram(name: "black_box<u64>", linkageName: "_ZN4core4hint9black_box17h8f96ccdebaca3800E", scope: !145, file: !144, line: 476, type: !653, scopeLine: 476, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !261, retainedNodes: !655)
!653 = !DISubroutineType(types: !654)
!654 = !{!233, !233}
!655 = !{!656}
!656 = !DILocalVariable(name: "dummy", arg: 1, scope: !652, file: !144, line: 476, type: !233)
!657 = !DILocation(line: 476, column: 27, scope: !652)
!658 = !DILocation(line: 477, column: 5, scope: !652)
!659 = !DILocation(line: 478, column: 2, scope: !652)
!660 = distinct !DISubprogram(name: "from_raw", linkageName: "_ZN4core4task4wake5Waker8from_raw17hfdc613e6f00adcadE", scope: !408, file: !661, line: 534, type: !662, scopeLine: 534, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, declaration: !664, retainedNodes: !665)
!661 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/task/wake.rs", directory: "", checksumkind: CSK_MD5, checksum: "61f0703b7bd87b7ffe527ee51645eb72")
!662 = !DISubroutineType(types: !663)
!663 = !{!408, !37}
!664 = !DISubprogram(name: "from_raw", linkageName: "_ZN4core4task4wake5Waker8from_raw17hfdc613e6f00adcadE", scope: !408, file: !661, line: 534, type: !662, scopeLine: 534, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!665 = !{!666}
!666 = !DILocalVariable(name: "waker", arg: 1, scope: !660, file: !661, line: 534, type: !37)
!667 = !DILocation(line: 534, column: 34, scope: !660)
!668 = !DILocation(line: 536, column: 6, scope: !660)
!669 = distinct !DISubprogram(name: "from_waker", linkageName: "_ZN4core4task4wake7Context10from_waker17h4673ecefaeb55096E", scope: !446, file: !661, line: 240, type: !670, scopeLine: 240, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, declaration: !672, retainedNodes: !673)
!670 = !DISubroutineType(types: !671)
!671 = !{!446, !449}
!672 = !DISubprogram(name: "from_waker", linkageName: "_ZN4core4task4wake7Context10from_waker17h4673ecefaeb55096E", scope: !446, file: !661, line: 240, type: !670, scopeLine: 240, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!673 = !{!674}
!674 = !DILocalVariable(name: "waker", arg: 1, scope: !669, file: !661, line: 240, type: !449)
!675 = !DILocation(line: 240, column: 29, scope: !669)
!676 = !DILocalVariable(name: "waker", arg: 1, scope: !677, file: !661, line: 321, type: !449)
!677 = distinct !DISubprogram(name: "from_waker", linkageName: "_ZN4core4task4wake14ContextBuilder10from_waker17he19996313818e9e7E", scope: !678, file: !661, line: 321, type: !685, scopeLine: 321, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, declaration: !687, retainedNodes: !688)
!678 = !DICompositeType(tag: DW_TAG_structure_type, name: "ContextBuilder", scope: !29, file: !2, size: 256, align: 64, flags: DIFlagPublic, elements: !679, templateParams: !23, identifier: "5671c3b1231ff74621a8f6459aeaf2d1")
!679 = !{!680, !681, !682, !683, !684}
!680 = !DIDerivedType(tag: DW_TAG_member, name: "waker", scope: !678, file: !2, baseType: !449, size: 64, align: 64, flags: DIFlagPrivate)
!681 = !DIDerivedType(tag: DW_TAG_member, name: "local_waker", scope: !678, file: !2, baseType: !451, size: 64, align: 64, offset: 64, flags: DIFlagPrivate)
!682 = !DIDerivedType(tag: DW_TAG_member, name: "ext", scope: !678, file: !2, baseType: !461, size: 128, align: 64, offset: 128, flags: DIFlagPrivate)
!683 = !DIDerivedType(tag: DW_TAG_member, name: "_marker", scope: !678, file: !2, baseType: !487, align: 8, offset: 256, flags: DIFlagPrivate)
!684 = !DIDerivedType(tag: DW_TAG_member, name: "_marker2", scope: !678, file: !2, baseType: !494, align: 8, offset: 256, flags: DIFlagPrivate)
!685 = !DISubroutineType(types: !686)
!686 = !{!678, !449}
!687 = !DISubprogram(name: "from_waker", linkageName: "_ZN4core4task4wake14ContextBuilder10from_waker17he19996313818e9e7E", scope: !678, file: !661, line: 321, type: !685, scopeLine: 321, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!688 = !{!676}
!689 = !DILocation(line: 321, column: 29, scope: !677, inlinedAt: !690)
!690 = !DILocation(line: 241, column: 9, scope: !669)
!691 = !DILocation(line: 376, column: 9, scope: !692, inlinedAt: !696)
!692 = distinct !DISubprogram(name: "build", linkageName: "_ZN4core4task4wake14ContextBuilder5build17he2626af7b5f667e1E", scope: !678, file: !661, line: 374, type: !693, scopeLine: 374, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, declaration: !695)
!693 = !DISubroutineType(types: !694)
!694 = !{!446, !678}
!695 = !DISubprogram(name: "build", linkageName: "_ZN4core4task4wake14ContextBuilder5build17he2626af7b5f667e1E", scope: !678, file: !661, line: 374, type: !693, scopeLine: 374, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!696 = !DILocation(line: 241, column: 43, scope: !669)
!697 = !DILocation(line: 242, column: 6, scope: !669)
!698 = distinct !DISubprogram(name: "new", linkageName: "_ZN4core4task4wake8RawWaker3new17h97385b4012da4169E", scope: !37, file: !661, line: 59, type: !699, scopeLine: 59, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, declaration: !701, retainedNodes: !702)
!699 = !DISubroutineType(types: !700)
!700 = !{!37, !6, !41}
!701 = !DISubprogram(name: "new", linkageName: "_ZN4core4task4wake8RawWaker3new17h97385b4012da4169E", scope: !37, file: !661, line: 59, type: !699, scopeLine: 59, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!702 = !{!703, !704}
!703 = !DILocalVariable(name: "data", arg: 1, scope: !698, file: !661, line: 59, type: !6)
!704 = !DILocalVariable(name: "vtable", arg: 2, scope: !698, file: !661, line: 59, type: !41)
!705 = !DILocation(line: 59, column: 22, scope: !698)
!706 = !DILocation(line: 59, column: 39, scope: !698)
!707 = !DILocation(line: 61, column: 6, scope: !698)
!708 = distinct !DISubprogram(name: "report", linkageName: "_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17h86c43eadf0bbce2fE", scope: !709, file: !101, line: 2427, type: !710, scopeLine: 2427, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !712)
!709 = !DINamespace(name: "{impl#57}", scope: !103)
!710 = !DISubroutineType(types: !711)
!711 = !{!102, !7}
!712 = !{!713}
!713 = !DILocalVariable(arg: 1, scope: !708, file: !101, line: 2427, type: !7)
!714 = !DILocation(line: 2427, column: 15, scope: !708)
!715 = !DILocation(line: 2429, column: 6, scope: !708)
!716 = distinct !DISubprogram(name: "into_future<async_demo::db_read::{async_fn_env#0}>", linkageName: "_ZN59_$LT$F$u20$as$u20$core..future..into_future..IntoFuture$GT$11into_future17h3a4cc5be54bf241aE", scope: !718, file: !717, line: 142, type: !721, scopeLine: 142, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !725, retainedNodes: !723)
!717 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/future/into_future.rs", directory: "", checksumkind: CSK_MD5, checksum: "c74955e5f3ef6c9ab8ab8241c074cbd7")
!718 = !DINamespace(name: "{impl#0}", scope: !719)
!719 = !DINamespace(name: "into_future", scope: !720)
!720 = !DINamespace(name: "future", scope: !31)
!721 = !DISubroutineType(types: !722)
!722 = !{!420, !420}
!723 = !{!724}
!724 = !DILocalVariable(name: "self", arg: 1, scope: !716, file: !717, line: 142, type: !420)
!725 = !{!726}
!726 = !DITemplateTypeParameter(name: "F", type: !420)
!727 = !DILocation(line: 142, column: 20, scope: !716)
!728 = !DILocation(line: 143, column: 9, scope: !716)
!729 = !DILocation(line: 144, column: 6, scope: !716)
!730 = distinct !DISubprogram(name: "into_future<async_demo::authorize::{async_fn_env#0}>", linkageName: "_ZN59_$LT$F$u20$as$u20$core..future..into_future..IntoFuture$GT$11into_future17h96dac5933a798099E", scope: !718, file: !717, line: 142, type: !731, scopeLine: 142, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !735, retainedNodes: !733)
!731 = !DISubroutineType(types: !732)
!732 = !{!531, !531}
!733 = !{!734}
!734 = !DILocalVariable(name: "self", arg: 1, scope: !730, file: !717, line: 142, type: !531)
!735 = !{!736}
!736 = !DITemplateTypeParameter(name: "F", type: !531)
!737 = !DILocation(line: 142, column: 20, scope: !730)
!738 = !DILocation(line: 143, column: 9, scope: !730)
!739 = !DILocation(line: 144, column: 6, scope: !730)
!740 = distinct !DISubprogram(name: "deref_mut<async_demo::guarded::{async_fn_env#0}>", linkageName: "_ZN60_$LT$$RF$mut$u20$T$u20$as$u20$core..ops..deref..DerefMut$GT$9deref_mut17hd752dc04218d67fbE", scope: !742, file: !741, line: 277, type: !744, scopeLine: 277, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !569, retainedNodes: !748)
!741 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/ops/deref.rs", directory: "", checksumkind: CSK_MD5, checksum: "1c671aaacd25f5a7e18e63389e18f8d7")
!742 = !DINamespace(name: "{impl#3}", scope: !743)
!743 = !DINamespace(name: "deref", scope: !378)
!744 = !DISubroutineType(types: !745)
!745 = !{!746, !747}
!746 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut async_demo::guarded::{async_fn_env#0}", baseType: !509, size: 64, align: 64, dwarfAddressSpace: 0)
!747 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut &mut async_demo::guarded::{async_fn_env#0}", baseType: !746, size: 64, align: 64, dwarfAddressSpace: 0)
!748 = !{!749}
!749 = !DILocalVariable(name: "self", arg: 1, scope: !740, file: !741, line: 277, type: !747)
!750 = !DILocation(line: 277, column: 18, scope: !740)
!751 = !DILocation(line: 278, column: 9, scope: !740)
!752 = !DILocation(line: 279, column: 6, scope: !740)
!753 = distinct !DISubprogram(name: "deref_mut<async_demo::unguarded::{async_fn_env#0}>", linkageName: "_ZN60_$LT$$RF$mut$u20$T$u20$as$u20$core..ops..deref..DerefMut$GT$9deref_mut17he8d347e250f645d9E", scope: !742, file: !741, line: 277, type: !754, scopeLine: 277, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !628, retainedNodes: !758)
!754 = !DISubroutineType(types: !755)
!755 = !{!756, !757}
!756 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut async_demo::unguarded::{async_fn_env#0}", baseType: !596, size: 64, align: 64, dwarfAddressSpace: 0)
!757 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut &mut async_demo::unguarded::{async_fn_env#0}", baseType: !756, size: 64, align: 64, dwarfAddressSpace: 0)
!758 = !{!759}
!759 = !DILocalVariable(name: "self", arg: 1, scope: !753, file: !741, line: 277, type: !757)
!760 = !DILocation(line: 277, column: 18, scope: !753)
!761 = !DILocation(line: 278, column: 9, scope: !753)
!762 = !DILocation(line: 279, column: 6, scope: !753)
!763 = distinct !DISubprogram(name: "drop", linkageName: "_ZN65_$LT$core..task..wake..Waker$u20$as$u20$core..ops..drop..Drop$GT$4drop17hb1138275daf8cdb4E", scope: !764, file: !661, line: 650, type: !765, scopeLine: 650, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !768)
!764 = !DINamespace(name: "{impl#10}", scope: !29)
!765 = !DISubroutineType(types: !766)
!766 = !{null, !767}
!767 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut core::task::wake::Waker", baseType: !408, size: 64, align: 64, dwarfAddressSpace: 0)
!768 = !{!769}
!769 = !DILocalVariable(name: "self", arg: 1, scope: !763, file: !661, line: 650, type: !767)
!770 = !DILocation(line: 650, column: 13, scope: !763)
!771 = !DILocation(line: 654, column: 18, scope: !763)
!772 = !DILocation(line: 654, column: 43, scope: !763)
!773 = !DILocation(line: 655, column: 6, scope: !763)
!774 = distinct !DISubprogram(name: "authorize", linkageName: "_ZN10async_demo9authorize17h390cf99f43c68df5E", scope: !26, file: !27, line: 16, type: !775, scopeLine: 16, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !777)
!775 = !DISubroutineType(types: !776)
!776 = !{!531, !429}
!777 = !{!778}
!778 = !DILocalVariable(name: "r", arg: 1, scope: !774, file: !27, line: 16, type: !429)
!779 = !DILocation(line: 16, column: 24, scope: !774)
!780 = !DILocation(line: 16, column: 46, scope: !774)
!781 = !DILocation(line: 18, column: 2, scope: !774)
!782 = distinct !DISubprogram(name: "{async_fn#0}", linkageName: "_ZN10async_demo9authorize28_$u7b$$u7b$closure$u7d$$u7d$17h5cfbb956889f0429E", scope: !532, file: !27, line: 16, type: !783, scopeLine: 16, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !806)
!783 = !DISubroutineType(types: !784)
!784 = !{!785, !799, !445}
!785 = !DICompositeType(tag: DW_TAG_structure_type, name: "Poll<bool>", scope: !786, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !787, templateParams: !23, identifier: "cff26969140a0063f2fdc29137cfcfc9")
!786 = !DINamespace(name: "poll", scope: !30)
!787 = !{!788}
!788 = !DICompositeType(tag: DW_TAG_variant_part, scope: !785, file: !2, size: 8, align: 8, elements: !789, templateParams: !23, identifier: "e060d9a19f60bf1f7b1c064bf35a3dc3", discriminator: !798)
!789 = !{!790, !796}
!790 = !DIDerivedType(tag: DW_TAG_member, name: "Ready", scope: !788, file: !2, baseType: !791, size: 8, align: 8)
!791 = !DICompositeType(tag: DW_TAG_structure_type, name: "Ready", scope: !785, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !792, templateParams: !794, identifier: "47780e447b0c39a22675c1eb0e4c0249")
!792 = !{!793}
!793 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !791, file: !2, baseType: !564, size: 8, align: 8, flags: DIFlagPublic)
!794 = !{!795}
!795 = !DITemplateTypeParameter(name: "T", type: !564)
!796 = !DIDerivedType(tag: DW_TAG_member, name: "Pending", scope: !788, file: !2, baseType: !797, size: 8, align: 8, extraData: i8 2)
!797 = !DICompositeType(tag: DW_TAG_structure_type, name: "Pending", scope: !785, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !23, templateParams: !794, identifier: "193ac986d0a34434f947c9f13b7c9455")
!798 = !DIDerivedType(tag: DW_TAG_member, scope: !785, file: !2, baseType: !58, size: 8, align: 8, flags: DIFlagArtificial)
!799 = !DICompositeType(tag: DW_TAG_structure_type, name: "Pin<&mut async_demo::authorize::{async_fn_env#0}>", scope: !800, file: !2, size: 64, align: 64, flags: DIFlagPublic, elements: !801, templateParams: !804, identifier: "1a514891281e7d22acc724eb226f0b12")
!800 = !DINamespace(name: "pin", scope: !31)
!801 = !{!802}
!802 = !DIDerivedType(tag: DW_TAG_member, name: "__pointer", scope: !799, file: !2, baseType: !803, size: 64, align: 64, flags: DIFlagPublic)
!803 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut async_demo::authorize::{async_fn_env#0}", baseType: !531, size: 64, align: 64, dwarfAddressSpace: 0)
!804 = !{!805}
!805 = !DITemplateTypeParameter(name: "Ptr", type: !803)
!806 = !{!807, !808, !809}
!807 = !DILocalVariable(name: "_task_context", scope: !782, file: !27, line: 16, type: !445, align: 64)
!808 = !DILocalVariable(name: "r", scope: !782, file: !27, line: 16, type: !429, align: 64)
!809 = !DILocalVariable(name: "r", scope: !810, file: !27, line: 16, type: !429, align: 64)
!810 = distinct !DILexicalBlock(scope: !782, file: !27, line: 16, column: 46)
!811 = !DILocation(line: 16, column: 24, scope: !782)
!812 = !DILocation(line: 16, column: 46, scope: !782)
!813 = !DILocation(line: 16, column: 24, scope: !810)
!814 = !DILocation(line: 17, column: 5, scope: !810)
!815 = !DILocation(line: 18, column: 2, scope: !782)
!816 = distinct !DISubprogram(name: "db_read", linkageName: "_ZN10async_demo7db_read17hf2078ac86afadfa5E", scope: !26, file: !27, line: 21, type: !817, scopeLine: 21, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !819)
!817 = !DISubroutineType(types: !818)
!818 = !{!420, !429}
!819 = !{!820}
!820 = !DILocalVariable(name: "r", arg: 1, scope: !816, file: !27, line: 21, type: !429)
!821 = !DILocation(line: 21, column: 22, scope: !816)
!822 = !DILocation(line: 21, column: 43, scope: !816)
!823 = !DILocation(line: 23, column: 2, scope: !816)
!824 = distinct !DISubprogram(name: "{async_fn#0}", linkageName: "_ZN10async_demo7db_read28_$u7b$$u7b$closure$u7d$$u7d$17h799c5ebab41127b1E", scope: !421, file: !27, line: 21, type: !825, scopeLine: 21, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !844)
!825 = !DISubroutineType(types: !826)
!826 = !{!827, !838, !445}
!827 = !DICompositeType(tag: DW_TAG_structure_type, name: "Poll<u64>", scope: !786, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !828, templateParams: !23, identifier: "fd7ca46c7b46b12265346e23d6f8122f")
!828 = !{!829}
!829 = !DICompositeType(tag: DW_TAG_variant_part, scope: !827, file: !2, size: 128, align: 64, elements: !830, templateParams: !23, identifier: "63d10a44c466772f33dc7f31428bf819", discriminator: !837)
!830 = !{!831, !835}
!831 = !DIDerivedType(tag: DW_TAG_member, name: "Ready", scope: !829, file: !2, baseType: !832, size: 128, align: 64, extraData: i64 0)
!832 = !DICompositeType(tag: DW_TAG_structure_type, name: "Ready", scope: !827, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !833, templateParams: !261, identifier: "418916aa3b6039b73b6dc1b90401a67a")
!833 = !{!834}
!834 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !832, file: !2, baseType: !233, size: 64, align: 64, offset: 64, flags: DIFlagPublic)
!835 = !DIDerivedType(tag: DW_TAG_member, name: "Pending", scope: !829, file: !2, baseType: !836, size: 128, align: 64, extraData: i64 1)
!836 = !DICompositeType(tag: DW_TAG_structure_type, name: "Pending", scope: !827, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !23, templateParams: !261, identifier: "bca0f410ead09e2cce9615d35019729b")
!837 = !DIDerivedType(tag: DW_TAG_member, scope: !827, file: !2, baseType: !233, size: 64, align: 64, flags: DIFlagArtificial)
!838 = !DICompositeType(tag: DW_TAG_structure_type, name: "Pin<&mut async_demo::db_read::{async_fn_env#0}>", scope: !800, file: !2, size: 64, align: 64, flags: DIFlagPublic, elements: !839, templateParams: !842, identifier: "317a85bb0669bbc426606d78e3306df2")
!839 = !{!840}
!840 = !DIDerivedType(tag: DW_TAG_member, name: "__pointer", scope: !838, file: !2, baseType: !841, size: 64, align: 64, flags: DIFlagPublic)
!841 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut async_demo::db_read::{async_fn_env#0}", baseType: !420, size: 64, align: 64, dwarfAddressSpace: 0)
!842 = !{!843}
!843 = !DITemplateTypeParameter(name: "Ptr", type: !841)
!844 = !{!845, !846, !847}
!845 = !DILocalVariable(name: "_task_context", scope: !824, file: !27, line: 21, type: !445, align: 64)
!846 = !DILocalVariable(name: "r", scope: !824, file: !27, line: 21, type: !429, align: 64)
!847 = !DILocalVariable(name: "r", scope: !848, file: !27, line: 21, type: !429, align: 64)
!848 = distinct !DILexicalBlock(scope: !824, file: !27, line: 21, column: 43)
!849 = !DILocation(line: 21, column: 22, scope: !824)
!850 = !DILocation(line: 21, column: 43, scope: !824)
!851 = !DILocation(line: 21, column: 22, scope: !848)
!852 = !DILocation(line: 22, column: 5, scope: !848)
!853 = !DILocation(line: 23, column: 2, scope: !824)
!854 = distinct !DISubprogram(name: "guarded", linkageName: "_ZN10async_demo7guarded17h35dc6076e8381621E", scope: !26, file: !27, line: 28, type: !855, scopeLine: 28, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !857)
!855 = !DISubroutineType(types: !856)
!856 = !{!509, !429}
!857 = !{!858}
!858 = !DILocalVariable(name: "r", arg: 1, scope: !854, file: !27, line: 28, type: !429)
!859 = !DILocation(line: 28, column: 22, scope: !854)
!860 = !DILocation(line: 28, column: 43, scope: !854)
!861 = !DILocation(line: 34, column: 2, scope: !854)
!862 = distinct !DISubprogram(name: "{async_fn#0}", linkageName: "_ZN10async_demo7guarded28_$u7b$$u7b$closure$u7d$$u7d$17hb2c3441699a3e5e7E", scope: !510, file: !27, line: 28, type: !863, scopeLine: 28, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !870)
!863 = !DISubroutineType(types: !864)
!864 = !{!827, !865, !445}
!865 = !DICompositeType(tag: DW_TAG_structure_type, name: "Pin<&mut async_demo::guarded::{async_fn_env#0}>", scope: !800, file: !2, size: 64, align: 64, flags: DIFlagPublic, elements: !866, templateParams: !868, identifier: "1879abf2acc5a354dd0202441094ab88")
!866 = !{!867}
!867 = !DIDerivedType(tag: DW_TAG_member, name: "__pointer", scope: !865, file: !2, baseType: !746, size: 64, align: 64, flags: DIFlagPublic)
!868 = !{!869}
!869 = !DITemplateTypeParameter(name: "Ptr", type: !746)
!870 = !{!871, !872, !873, !875, !877, !879, !881, !883}
!871 = !DILocalVariable(name: "_task_context", scope: !862, file: !27, line: 28, type: !445, align: 64)
!872 = !DILocalVariable(name: "r", scope: !862, file: !27, line: 28, type: !429, align: 64)
!873 = !DILocalVariable(name: "r", scope: !874, file: !27, line: 28, type: !429, align: 64)
!874 = distinct !DILexicalBlock(scope: !862, file: !27, line: 28, column: 43)
!875 = !DILocalVariable(name: "__awaitee", scope: !876, file: !27, line: 29, type: !531, align: 64)
!876 = distinct !DILexicalBlock(scope: !874, file: !27, line: 29, column: 21)
!877 = !DILocalVariable(name: "result", scope: !878, file: !27, line: 29, type: !564, align: 8)
!878 = distinct !DILexicalBlock(scope: !876, file: !27, line: 29, column: 8)
!879 = !DILocalVariable(name: "__awaitee", scope: !880, file: !27, line: 30, type: !420, align: 64)
!880 = distinct !DILexicalBlock(scope: !874, file: !27, line: 30, column: 20)
!881 = !DILocalVariable(name: "result", scope: !882, file: !27, line: 30, type: !233, align: 64)
!882 = distinct !DILexicalBlock(scope: !880, file: !27, line: 30, column: 9)
!883 = !DILocalVariable(arg: 2, scope: !862, file: !27, line: 28, type: !445)
!884 = !DILocation(line: 28, column: 22, scope: !862)
!885 = !DILocation(line: 28, column: 22, scope: !874)
!886 = !DILocation(line: 29, column: 8, scope: !876)
!887 = !DILocation(line: 30, column: 9, scope: !880)
!888 = !DILocation(line: 28, column: 43, scope: !862)
!889 = !DILocation(line: 0, scope: !862)
!890 = !DILocation(line: 29, column: 18, scope: !874)
!891 = !DILocation(line: 29, column: 8, scope: !874)
!892 = !DILocation(line: 29, column: 21, scope: !876)
!893 = !DILocation(line: 30, column: 20, scope: !880)
!894 = !DILocation(line: 29, column: 21, scope: !874)
!895 = !DILocalVariable(name: "pointer", arg: 1, scope: !896, file: !897, line: 1357, type: !803)
!896 = distinct !DISubprogram(name: "new_unchecked<&mut async_demo::authorize::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$13new_unchecked17hba5fded44fa3b13cE", scope: !799, file: !897, line: 1357, type: !898, scopeLine: 1357, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !804, declaration: !900, retainedNodes: !901)
!897 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/pin.rs", directory: "", checksumkind: CSK_MD5, checksum: "188547841d616971e1bd37e3195159d3")
!898 = !DISubroutineType(types: !899)
!899 = !{!799, !803}
!900 = !DISubprogram(name: "new_unchecked<&mut async_demo::authorize::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$13new_unchecked17hba5fded44fa3b13cE", scope: !799, file: !897, line: 1357, type: !898, scopeLine: 1357, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !804)
!901 = !{!895}
!902 = !DILocation(line: 1357, column: 39, scope: !896, inlinedAt: !903)
!903 = distinct !DILocation(line: 29, column: 21, scope: !876)
!904 = !DILocation(line: 1359, column: 6, scope: !896, inlinedAt: !903)
!905 = !DILocation(line: 29, column: 25, scope: !874)
!906 = !DILocation(line: 29, column: 8, scope: !878)
!907 = !DILocation(line: 32, column: 9, scope: !874)
!908 = !DILocation(line: 29, column: 5, scope: !874)
!909 = !DILocation(line: 30, column: 17, scope: !874)
!910 = !DILocation(line: 30, column: 9, scope: !874)
!911 = !DILocation(line: 34, column: 2, scope: !862)
!912 = !DILocation(line: 30, column: 20, scope: !874)
!913 = !DILocalVariable(name: "pointer", arg: 1, scope: !914, file: !897, line: 1357, type: !841)
!914 = distinct !DISubprogram(name: "new_unchecked<&mut async_demo::db_read::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$13new_unchecked17h393b9d4a9ae27644E", scope: !838, file: !897, line: 1357, type: !915, scopeLine: 1357, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !842, declaration: !917, retainedNodes: !918)
!915 = !DISubroutineType(types: !916)
!916 = !{!838, !841}
!917 = !DISubprogram(name: "new_unchecked<&mut async_demo::db_read::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$13new_unchecked17h393b9d4a9ae27644E", scope: !838, file: !897, line: 1357, type: !915, scopeLine: 1357, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !842)
!918 = !{!913}
!919 = !DILocation(line: 1357, column: 39, scope: !914, inlinedAt: !920)
!920 = distinct !DILocation(line: 30, column: 20, scope: !880)
!921 = !DILocation(line: 1359, column: 6, scope: !914, inlinedAt: !920)
!922 = !DILocation(line: 30, column: 24, scope: !874)
!923 = !DILocation(line: 30, column: 9, scope: !882)
!924 = distinct !DISubprogram(name: "unguarded", linkageName: "_ZN10async_demo9unguarded17h35b9685ebed6fe46E", scope: !26, file: !27, line: 37, type: !925, scopeLine: 37, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !927)
!925 = !DISubroutineType(types: !926)
!926 = !{!596, !429}
!927 = !{!928}
!928 = !DILocalVariable(name: "r", arg: 1, scope: !924, file: !27, line: 37, type: !429)
!929 = !DILocation(line: 37, column: 24, scope: !924)
!930 = !DILocation(line: 37, column: 45, scope: !924)
!931 = !DILocation(line: 39, column: 2, scope: !924)
!932 = distinct !DISubprogram(name: "{async_fn#0}", linkageName: "_ZN10async_demo9unguarded28_$u7b$$u7b$closure$u7d$$u7d$17h60bd849f302abbb0E", scope: !597, file: !27, line: 37, type: !933, scopeLine: 37, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !940)
!933 = !DISubroutineType(types: !934)
!934 = !{!827, !935, !445}
!935 = !DICompositeType(tag: DW_TAG_structure_type, name: "Pin<&mut async_demo::unguarded::{async_fn_env#0}>", scope: !800, file: !2, size: 64, align: 64, flags: DIFlagPublic, elements: !936, templateParams: !938, identifier: "f195bcd84cd69c80a24ec271f897b00a")
!936 = !{!937}
!937 = !DIDerivedType(tag: DW_TAG_member, name: "__pointer", scope: !935, file: !2, baseType: !756, size: 64, align: 64, flags: DIFlagPublic)
!938 = !{!939}
!939 = !DITemplateTypeParameter(name: "Ptr", type: !756)
!940 = !{!941, !942, !943, !945, !947, !949}
!941 = !DILocalVariable(name: "_task_context", scope: !932, file: !27, line: 37, type: !445, align: 64)
!942 = !DILocalVariable(name: "r", scope: !932, file: !27, line: 37, type: !429, align: 64)
!943 = !DILocalVariable(name: "r", scope: !944, file: !27, line: 37, type: !429, align: 64)
!944 = distinct !DILexicalBlock(scope: !932, file: !27, line: 37, column: 45)
!945 = !DILocalVariable(name: "__awaitee", scope: !946, file: !27, line: 38, type: !420, align: 64)
!946 = distinct !DILexicalBlock(scope: !944, file: !27, line: 38, column: 16)
!947 = !DILocalVariable(name: "result", scope: !948, file: !27, line: 38, type: !233, align: 64)
!948 = distinct !DILexicalBlock(scope: !946, file: !27, line: 38, column: 5)
!949 = !DILocalVariable(arg: 2, scope: !932, file: !27, line: 37, type: !445)
!950 = !DILocation(line: 37, column: 24, scope: !932)
!951 = !DILocation(line: 38, column: 5, scope: !946)
!952 = !DILocation(line: 37, column: 45, scope: !932)
!953 = !DILocation(line: 0, scope: !932)
!954 = !DILocation(line: 37, column: 24, scope: !944)
!955 = !DILocation(line: 38, column: 5, scope: !944)
!956 = !DILocation(line: 38, column: 16, scope: !946)
!957 = !DILocation(line: 38, column: 16, scope: !944)
!958 = !DILocation(line: 1357, column: 39, scope: !914, inlinedAt: !959)
!959 = distinct !DILocation(line: 38, column: 16, scope: !946)
!960 = !DILocation(line: 1359, column: 6, scope: !914, inlinedAt: !959)
!961 = !DILocation(line: 38, column: 20, scope: !944)
!962 = !DILocation(line: 38, column: 5, scope: !948)
!963 = !DILocation(line: 39, column: 2, scope: !932)
!964 = distinct !DISubprogram(name: "noop", linkageName: "_ZN10async_demo4noop17h41a65d1e9ed40a73E", scope: !26, file: !27, line: 41, type: !44, scopeLine: 41, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !965)
!965 = !{!966}
!966 = !DILocalVariable(arg: 1, scope: !964, file: !27, line: 41, type: !6)
!967 = !DILocation(line: 41, column: 9, scope: !964)
!968 = !DILocation(line: 41, column: 25, scope: !964)
!969 = distinct !DISubprogram(name: "clone_w", linkageName: "_ZN10async_demo7clone_w17h237304af9c8bd529E", scope: !26, file: !27, line: 42, type: !35, scopeLine: 42, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !23, retainedNodes: !970)
!970 = !{!971}
!971 = !DILocalVariable(arg: 1, scope: !969, file: !27, line: 42, type: !6)
!972 = !DILocation(line: 42, column: 12, scope: !969)
!973 = !DILocation(line: 43, column: 5, scope: !969)
!974 = !DILocation(line: 44, column: 2, scope: !969)
!975 = distinct !DISubprogram(name: "block_on<async_demo::unguarded::{async_fn_env#0}>", linkageName: "_ZN10async_demo8block_on17h4fd05f61446baf56E", scope: !26, file: !27, line: 47, type: !976, scopeLine: 47, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !988, retainedNodes: !978)
!976 = !DISubroutineType(types: !977)
!977 = !{!233, !596}
!978 = !{!979, !980, !982, !984, !986}
!979 = !DILocalVariable(name: "f", arg: 1, scope: !975, file: !27, line: 47, type: !596)
!980 = !DILocalVariable(name: "f", scope: !981, file: !27, line: 48, type: !935, align: 64)
!981 = distinct !DILexicalBlock(scope: !975, file: !27, line: 48, column: 5)
!982 = !DILocalVariable(name: "w", scope: !983, file: !27, line: 49, type: !408, align: 64)
!983 = distinct !DILexicalBlock(scope: !981, file: !27, line: 49, column: 5)
!984 = !DILocalVariable(name: "cx", scope: !985, file: !27, line: 50, type: !446, align: 64)
!985 = distinct !DILexicalBlock(scope: !983, file: !27, line: 50, column: 5)
!986 = !DILocalVariable(name: "v", scope: !987, file: !27, line: 52, type: !233, align: 64)
!987 = distinct !DILexicalBlock(scope: !985, file: !27, line: 52, column: 58)
!988 = !{!989}
!989 = !DITemplateTypeParameter(name: "F", type: !596)
!990 = !DILocation(line: 47, column: 24, scope: !975)
!991 = !DILocation(line: 48, column: 9, scope: !981)
!992 = !DILocation(line: 49, column: 9, scope: !983)
!993 = !DILocation(line: 50, column: 9, scope: !985)
!994 = !DILocation(line: 48, column: 22, scope: !975)
!995 = !DILocation(line: 48, column: 17, scope: !975)
!996 = !DILocation(line: 554, column: 2, scope: !997, inlinedAt: !1000)
!997 = distinct !DISubprogram(name: "null<()>", linkageName: "_ZN4core3ptr4null17h073031a671654807E", scope: !170, file: !404, line: 552, type: !998, scopeLine: 552, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !80)
!998 = !DISubroutineType(types: !999)
!999 = !{!6}
!1000 = distinct !DILocation(line: 49, column: 52, scope: !981)
!1001 = !DILocation(line: 56, column: 1, scope: !975)
!1002 = !DILocation(line: 49, column: 38, scope: !981)
!1003 = !DILocation(line: 49, column: 22, scope: !981)
!1004 = !DILocation(line: 50, column: 18, scope: !983)
!1005 = !DILocation(line: 56, column: 1, scope: !981)
!1006 = !DILocalVariable(name: "self", arg: 1, scope: !1007, file: !897, line: 1414, type: !1010)
!1007 = distinct !DISubprogram(name: "as_mut<&mut async_demo::unguarded::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17h7000f358e1f079fbE", scope: !935, file: !897, line: 1414, type: !1008, scopeLine: 1414, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !938, declaration: !1011, retainedNodes: !1012)
!1008 = !DISubroutineType(types: !1009)
!1009 = !{!935, !1010}
!1010 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut core::pin::Pin<&mut async_demo::unguarded::{async_fn_env#0}>", baseType: !935, size: 64, align: 64, dwarfAddressSpace: 0)
!1011 = !DISubprogram(name: "as_mut<&mut async_demo::unguarded::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17h7000f358e1f079fbE", scope: !935, file: !897, line: 1414, type: !1008, scopeLine: 1414, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !938)
!1012 = !{!1006}
!1013 = !DILocation(line: 1414, column: 19, scope: !1007, inlinedAt: !1014)
!1014 = distinct !DILocation(line: 52, column: 33, scope: !987)
!1015 = !DILocation(line: 1416, column: 42, scope: !1007, inlinedAt: !1014)
!1016 = !DILocalVariable(name: "pointer", arg: 1, scope: !1017, file: !897, line: 1357, type: !756)
!1017 = distinct !DISubprogram(name: "new_unchecked<&mut async_demo::unguarded::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$13new_unchecked17h81d3bdd8e6048744E", scope: !935, file: !897, line: 1357, type: !1018, scopeLine: 1357, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !938, declaration: !1020, retainedNodes: !1021)
!1018 = !DISubroutineType(types: !1019)
!1019 = !{!935, !756}
!1020 = !DISubprogram(name: "new_unchecked<&mut async_demo::unguarded::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$13new_unchecked17h81d3bdd8e6048744E", scope: !935, file: !897, line: 1357, type: !1018, scopeLine: 1357, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !938)
!1021 = !{!1016}
!1022 = !DILocation(line: 1357, column: 39, scope: !1017, inlinedAt: !1023)
!1023 = distinct !DILocation(line: 1416, column: 18, scope: !1007, inlinedAt: !1014)
!1024 = !DILocation(line: 1417, column: 6, scope: !1007, inlinedAt: !1014)
!1025 = !DILocation(line: 52, column: 33, scope: !987)
!1026 = !DILocation(line: 52, column: 16, scope: !987)
!1027 = !DILocation(line: 52, column: 28, scope: !987)
!1028 = !DILocation(line: 55, column: 5, scope: !985)
!1029 = !DILocation(line: 56, column: 2, scope: !975)
!1030 = !DILocation(line: 47, column: 1, scope: !975)
!1031 = distinct !DISubprogram(name: "block_on<async_demo::guarded::{async_fn_env#0}>", linkageName: "_ZN10async_demo8block_on17he3c4265f92fcd2d4E", scope: !26, file: !27, line: 47, type: !1032, scopeLine: 47, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !1044, retainedNodes: !1034)
!1032 = !DISubroutineType(types: !1033)
!1033 = !{!233, !509}
!1034 = !{!1035, !1036, !1038, !1040, !1042}
!1035 = !DILocalVariable(name: "f", arg: 1, scope: !1031, file: !27, line: 47, type: !509)
!1036 = !DILocalVariable(name: "f", scope: !1037, file: !27, line: 48, type: !865, align: 64)
!1037 = distinct !DILexicalBlock(scope: !1031, file: !27, line: 48, column: 5)
!1038 = !DILocalVariable(name: "w", scope: !1039, file: !27, line: 49, type: !408, align: 64)
!1039 = distinct !DILexicalBlock(scope: !1037, file: !27, line: 49, column: 5)
!1040 = !DILocalVariable(name: "cx", scope: !1041, file: !27, line: 50, type: !446, align: 64)
!1041 = distinct !DILexicalBlock(scope: !1039, file: !27, line: 50, column: 5)
!1042 = !DILocalVariable(name: "v", scope: !1043, file: !27, line: 52, type: !233, align: 64)
!1043 = distinct !DILexicalBlock(scope: !1041, file: !27, line: 52, column: 58)
!1044 = !{!1045}
!1045 = !DITemplateTypeParameter(name: "F", type: !509)
!1046 = !DILocation(line: 47, column: 24, scope: !1031)
!1047 = !DILocation(line: 48, column: 9, scope: !1037)
!1048 = !DILocation(line: 49, column: 9, scope: !1039)
!1049 = !DILocation(line: 50, column: 9, scope: !1041)
!1050 = !DILocation(line: 48, column: 22, scope: !1031)
!1051 = !DILocation(line: 48, column: 17, scope: !1031)
!1052 = !DILocation(line: 554, column: 2, scope: !997, inlinedAt: !1053)
!1053 = distinct !DILocation(line: 49, column: 52, scope: !1037)
!1054 = !DILocation(line: 56, column: 1, scope: !1031)
!1055 = !DILocation(line: 49, column: 38, scope: !1037)
!1056 = !DILocation(line: 49, column: 22, scope: !1037)
!1057 = !DILocation(line: 50, column: 18, scope: !1039)
!1058 = !DILocation(line: 56, column: 1, scope: !1037)
!1059 = !DILocalVariable(name: "self", arg: 1, scope: !1060, file: !897, line: 1414, type: !1063)
!1060 = distinct !DISubprogram(name: "as_mut<&mut async_demo::guarded::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17hb37273d40e1ca6d5E", scope: !865, file: !897, line: 1414, type: !1061, scopeLine: 1414, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !868, declaration: !1064, retainedNodes: !1065)
!1061 = !DISubroutineType(types: !1062)
!1062 = !{!865, !1063}
!1063 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut core::pin::Pin<&mut async_demo::guarded::{async_fn_env#0}>", baseType: !865, size: 64, align: 64, dwarfAddressSpace: 0)
!1064 = !DISubprogram(name: "as_mut<&mut async_demo::guarded::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$6as_mut17hb37273d40e1ca6d5E", scope: !865, file: !897, line: 1414, type: !1061, scopeLine: 1414, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !868)
!1065 = !{!1059}
!1066 = !DILocation(line: 1414, column: 19, scope: !1060, inlinedAt: !1067)
!1067 = distinct !DILocation(line: 52, column: 33, scope: !1043)
!1068 = !DILocation(line: 1416, column: 42, scope: !1060, inlinedAt: !1067)
!1069 = !DILocalVariable(name: "pointer", arg: 1, scope: !1070, file: !897, line: 1357, type: !746)
!1070 = distinct !DISubprogram(name: "new_unchecked<&mut async_demo::guarded::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$13new_unchecked17hbcabbf15edd23a61E", scope: !865, file: !897, line: 1357, type: !1071, scopeLine: 1357, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !53, templateParams: !868, declaration: !1073, retainedNodes: !1074)
!1071 = !DISubroutineType(types: !1072)
!1072 = !{!865, !746}
!1073 = !DISubprogram(name: "new_unchecked<&mut async_demo::guarded::{async_fn_env#0}>", linkageName: "_ZN4core3pin14Pin$LT$Ptr$GT$13new_unchecked17hbcabbf15edd23a61E", scope: !865, file: !897, line: 1357, type: !1071, scopeLine: 1357, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !868)
!1074 = !{!1069}
!1075 = !DILocation(line: 1357, column: 39, scope: !1070, inlinedAt: !1076)
!1076 = distinct !DILocation(line: 1416, column: 18, scope: !1060, inlinedAt: !1067)
!1077 = !DILocation(line: 1417, column: 6, scope: !1060, inlinedAt: !1067)
!1078 = !DILocation(line: 52, column: 33, scope: !1043)
!1079 = !DILocation(line: 52, column: 16, scope: !1043)
!1080 = !DILocation(line: 52, column: 28, scope: !1043)
!1081 = !DILocation(line: 55, column: 5, scope: !1041)
!1082 = !DILocation(line: 56, column: 2, scope: !1031)
!1083 = !DILocation(line: 47, column: 1, scope: !1031)
!1084 = distinct !DISubprogram(name: "main", linkageName: "_ZN10async_demo4main17hd479f7dc0ca3a29fE", scope: !26, file: !27, line: 58, type: !21, scopeLine: 58, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagMainSubprogram, unit: !53, templateParams: !23, retainedNodes: !1085)
!1085 = !{!1086, !1088}
!1086 = !DILocalVariable(name: "a", scope: !1087, file: !27, line: 59, type: !430, align: 64)
!1087 = distinct !DILexicalBlock(scope: !1084, file: !27, line: 59, column: 5)
!1088 = !DILocalVariable(name: "b", scope: !1089, file: !27, line: 60, type: !430, align: 64)
!1089 = distinct !DILexicalBlock(scope: !1087, file: !27, line: 60, column: 5)
!1090 = !DILocation(line: 59, column: 9, scope: !1087)
!1091 = !DILocation(line: 60, column: 9, scope: !1089)
!1092 = !DILocation(line: 59, column: 28, scope: !1084)
!1093 = !DILocation(line: 59, column: 59, scope: !1084)
!1094 = !DILocation(line: 59, column: 13, scope: !1084)
!1095 = !DILocation(line: 60, column: 28, scope: !1087)
!1096 = !DILocation(line: 60, column: 59, scope: !1087)
!1097 = !DILocation(line: 60, column: 13, scope: !1087)
!1098 = !DILocation(line: 61, column: 37, scope: !1089)
!1099 = !DILocation(line: 61, column: 29, scope: !1089)
!1100 = !DILocation(line: 61, column: 20, scope: !1089)
!1101 = !DILocation(line: 61, column: 5, scope: !1089)
!1102 = !DILocation(line: 62, column: 39, scope: !1089)
!1103 = !DILocation(line: 62, column: 29, scope: !1089)
!1104 = !DILocation(line: 62, column: 20, scope: !1089)
!1105 = !DILocation(line: 62, column: 5, scope: !1089)
!1106 = !DILocation(line: 63, column: 2, scope: !1084)
