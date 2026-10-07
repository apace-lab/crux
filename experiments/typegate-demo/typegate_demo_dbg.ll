; ModuleID = 'typegate_demo.5e6a099dc21d582d-cgu.0'
source_filename = "typegate_demo.5e6a099dc21d582d-cgu.0"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx11.0.0"

%"core::fmt::rt::Argument<'_>" = type { %"core::fmt::rt::ArgumentType<'_>" }
%"core::fmt::rt::ArgumentType<'_>" = type { ptr, [1 x i64] }

@vtable.0 = private constant <{ [24 x i8], ptr, ptr, ptr }> <{ [24 x i8] c"\00\00\00\00\00\00\00\00\08\00\00\00\00\00\00\00\08\00\00\00\00\00\00\00", ptr @"_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h01c75b192465ab24E", ptr @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h7cf1e36b6bd10a01E", ptr @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h7cf1e36b6bd10a01E" }>, align 8, !dbg !0
@0 = private unnamed_addr constant <{ [8 x i8], [8 x i8] }> <{ [8 x i8] zeroinitializer, [8 x i8] undef }>, align 8
@alloc_49a1e817e911805af64bbc7efb390101 = private unnamed_addr constant <{ [1 x i8] }> <{ [1 x i8] c"\0A" }>, align 1
@alloc_9771be2481f51be410bd2ac520d18601 = private unnamed_addr constant <{ ptr, [8 x i8], ptr, [8 x i8] }> <{ ptr inttoptr (i64 1 to ptr), [8 x i8] zeroinitializer, ptr @alloc_49a1e817e911805af64bbc7efb390101, [8 x i8] c"\01\00\00\00\00\00\00\00" }>, align 8

; std::rt::lang_start
; Function Attrs: uwtable
define hidden i64 @_ZN3std2rt10lang_start17hbd80991e398338c5E(ptr %main, i64 %argc, ptr %argv, i8 %sigpipe) unnamed_addr #0 !dbg !45 {
start:
  %sigpipe.dbg.spill = alloca [1 x i8], align 1
  %argv.dbg.spill = alloca [8 x i8], align 8
  %argc.dbg.spill = alloca [8 x i8], align 8
  %main.dbg.spill = alloca [8 x i8], align 8
  %_7 = alloca [8 x i8], align 8
  store ptr %main, ptr %main.dbg.spill, align 8
    #dbg_declare(ptr %main.dbg.spill, !53, !DIExpression(), !59)
  store i64 %argc, ptr %argc.dbg.spill, align 8
    #dbg_declare(ptr %argc.dbg.spill, !54, !DIExpression(), !60)
  store ptr %argv, ptr %argv.dbg.spill, align 8
    #dbg_declare(ptr %argv.dbg.spill, !55, !DIExpression(), !61)
  store i8 %sigpipe, ptr %sigpipe.dbg.spill, align 1
    #dbg_declare(ptr %sigpipe.dbg.spill, !56, !DIExpression(), !62)
  store ptr %main, ptr %_7, align 8, !dbg !63
; call std::rt::lang_start_internal
  %_0 = call i64 @_ZN3std2rt19lang_start_internal17h95cf27b851151b9cE(ptr align 1 %_7, ptr align 8 @vtable.0, i64 %argc, ptr %argv, i8 %sigpipe), !dbg !64
  ret i64 %_0, !dbg !65
}

; std::rt::lang_start::{{closure}}
; Function Attrs: inlinehint uwtable
define internal i32 @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h7cf1e36b6bd10a01E"(ptr align 8 %_1) unnamed_addr #1 !dbg !66 {
start:
  %self.dbg.spill = alloca [1 x i8], align 1
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !72, !DIExpression(DW_OP_deref), !73)
  %_4 = load ptr, ptr %_1, align 8, !dbg !74
; call std::sys::backtrace::__rust_begin_short_backtrace
  call void @_ZN3std3sys9backtrace28__rust_begin_short_backtrace17he5abbf7b33347f31E(ptr %_4), !dbg !75
; call <() as std::process::Termination>::report
  %self = call i8 @"_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17ha173b8a5cd1687e2E"(), !dbg !75
  store i8 %self, ptr %self.dbg.spill, align 1, !dbg !75
    #dbg_declare(ptr %self.dbg.spill, !76, !DIExpression(), !95)
  %_0 = zext i8 %self to i32, !dbg !97
  ret i32 %_0, !dbg !105
}

; std::sys::backtrace::__rust_begin_short_backtrace
; Function Attrs: noinline uwtable
define internal void @_ZN3std3sys9backtrace28__rust_begin_short_backtrace17he5abbf7b33347f31E(ptr %f) unnamed_addr #2 !dbg !106 {
start:
  %dummy.dbg.spill = alloca [0 x i8], align 1
  %f.dbg.spill = alloca [8 x i8], align 8
  %result.dbg.spill = alloca [0 x i8], align 1
    #dbg_declare(ptr %result.dbg.spill, !113, !DIExpression(), !117)
  store ptr %f, ptr %f.dbg.spill, align 8
    #dbg_declare(ptr %f.dbg.spill, !112, !DIExpression(), !118)
    #dbg_declare(ptr %dummy.dbg.spill, !119, !DIExpression(), !126)
; call core::ops::function::FnOnce::call_once
  call void @_ZN4core3ops8function6FnOnce9call_once17h6adfa9c64bd4cda4E(ptr %f), !dbg !128
  call void asm sideeffect "", "~{memory}"(), !dbg !129, !srcloc !130
  ret void, !dbg !131
}

; core::fmt::rt::Argument::new_display
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3fmt2rt8Argument11new_display17hf1046c42d0dbd6c6E(ptr sret([16 x i8]) align 8 %_0, ptr align 8 %x) unnamed_addr #1 !dbg !132 {
start:
  %x.dbg.spill = alloca [8 x i8], align 8
  %_3 = alloca [16 x i8], align 8
  store ptr %x, ptr %x.dbg.spill, align 8
    #dbg_declare(ptr %x.dbg.spill, !241, !DIExpression(), !242)
    #dbg_declare(ptr %x.dbg.spill, !243, !DIExpression(), !252)
    #dbg_declare(ptr %x.dbg.spill, !254, !DIExpression(), !265)
  store ptr %x, ptr %_3, align 8, !dbg !267
  %0 = getelementptr inbounds i8, ptr %_3, i64 8, !dbg !267
  store ptr @"_ZN4core3fmt3num3imp52_$LT$impl$u20$core..fmt..Display$u20$for$u20$u64$GT$3fmt17h339ac4429cb37bf0E", ptr %0, align 8, !dbg !267
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_0, ptr align 8 %_3, i64 16, i1 false), !dbg !268
  ret void, !dbg !269
}

; core::fmt::Arguments::new_v1
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3fmt9Arguments6new_v117h6101c022456de8fbE(ptr sret([48 x i8]) align 8 %_0, ptr align 8 %pieces, ptr align 8 %args) unnamed_addr #1 !dbg !270 {
start:
  %args.dbg.spill = alloca [8 x i8], align 8
  %pieces.dbg.spill = alloca [8 x i8], align 8
  store ptr %pieces, ptr %pieces.dbg.spill, align 8
    #dbg_declare(ptr %pieces.dbg.spill, !345, !DIExpression(), !347)
  store ptr %args, ptr %args.dbg.spill, align 8
    #dbg_declare(ptr %args.dbg.spill, !346, !DIExpression(), !348)
  store ptr %pieces, ptr %_0, align 8, !dbg !349
  %0 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !349
  store i64 2, ptr %0, align 8, !dbg !349
  %1 = load ptr, ptr @0, align 8, !dbg !349
  %2 = load i64, ptr getelementptr inbounds (i8, ptr @0, i64 8), align 8, !dbg !349
  %3 = getelementptr inbounds i8, ptr %_0, i64 32, !dbg !349
  store ptr %1, ptr %3, align 8, !dbg !349
  %4 = getelementptr inbounds i8, ptr %3, i64 8, !dbg !349
  store i64 %2, ptr %4, align 8, !dbg !349
  %5 = getelementptr inbounds i8, ptr %_0, i64 16, !dbg !349
  store ptr %args, ptr %5, align 8, !dbg !349
  %6 = getelementptr inbounds i8, ptr %5, i64 8, !dbg !349
  store i64 1, ptr %6, align 8, !dbg !349
  ret void, !dbg !350
}

; core::ops::function::FnOnce::call_once{{vtable.shim}}
; Function Attrs: inlinehint uwtable
define internal i32 @"_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h01c75b192465ab24E"(ptr %_1) unnamed_addr #1 !dbg !351 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  %_2 = alloca [0 x i8], align 1
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !360, !DIExpression(), !365)
    #dbg_declare(ptr %_2, !361, !DIExpression(), !365)
  %0 = load ptr, ptr %_1, align 8, !dbg !365
; call core::ops::function::FnOnce::call_once
  %_0 = call i32 @_ZN4core3ops8function6FnOnce9call_once17h1fd4289948593c7cE(ptr %0), !dbg !365
  ret i32 %_0, !dbg !365
}

; core::ops::function::FnOnce::call_once
; Function Attrs: inlinehint uwtable
define internal i32 @_ZN4core3ops8function6FnOnce9call_once17h1fd4289948593c7cE(ptr %0) unnamed_addr #1 personality ptr @rust_eh_personality !dbg !366 {
start:
  %1 = alloca [16 x i8], align 8
  %_2 = alloca [0 x i8], align 1
  %_1 = alloca [8 x i8], align 8
  store ptr %0, ptr %_1, align 8
    #dbg_declare(ptr %_1, !370, !DIExpression(), !372)
    #dbg_declare(ptr %_2, !371, !DIExpression(), !372)
; invoke std::rt::lang_start::{{closure}}
  %_0 = invoke i32 @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h7cf1e36b6bd10a01E"(ptr align 8 %_1)
          to label %bb1 unwind label %cleanup, !dbg !372

bb3:                                              ; preds = %cleanup
  %2 = load ptr, ptr %1, align 8, !dbg !372
  %3 = getelementptr inbounds i8, ptr %1, i64 8, !dbg !372
  %4 = load i32, ptr %3, align 8, !dbg !372
  %5 = insertvalue { ptr, i32 } poison, ptr %2, 0, !dbg !372
  %6 = insertvalue { ptr, i32 } %5, i32 %4, 1, !dbg !372
  resume { ptr, i32 } %6, !dbg !372

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
  ret i32 %_0, !dbg !372
}

; core::ops::function::FnOnce::call_once
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3ops8function6FnOnce9call_once17h6adfa9c64bd4cda4E(ptr %_1) unnamed_addr #1 !dbg !373 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  %_2 = alloca [0 x i8], align 1
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !375, !DIExpression(), !379)
    #dbg_declare(ptr %_2, !376, !DIExpression(), !379)
  call void %_1(), !dbg !379
  ret void, !dbg !379
}

; core::ptr::drop_in_place<std::rt::lang_start<()>::{{closure}}>
; Function Attrs: inlinehint uwtable
define internal void @"_ZN4core3ptr85drop_in_place$LT$std..rt..lang_start$LT$$LP$$RP$$GT$..$u7b$$u7b$closure$u7d$$u7d$$GT$17hb11962db33b9a3cdE"(ptr align 8 %_1) unnamed_addr #1 !dbg !380 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !385, !DIExpression(), !388)
  ret void, !dbg !388
}

; core::hint::black_box
; Function Attrs: inlinehint uwtable
define internal align 8 ptr @_ZN4core4hint9black_box17h21508f630dc30fdcE(ptr align 8 %dummy) unnamed_addr #1 !dbg !389 {
start:
  %0 = alloca [8 x i8], align 8
  %dummy.dbg.spill = alloca [8 x i8], align 8
  store ptr %dummy, ptr %dummy.dbg.spill, align 8
    #dbg_declare(ptr %dummy.dbg.spill, !398, !DIExpression(), !401)
  store ptr %dummy, ptr %0, align 8, !dbg !402
  call void asm sideeffect "", "r,~{memory}"(ptr %0), !dbg !402, !srcloc !130
  %_0 = load ptr, ptr %0, align 8, !dbg !402
  ret ptr %_0, !dbg !403
}

; core::hint::black_box
; Function Attrs: inlinehint uwtable
define internal i64 @_ZN4core4hint9black_box17h2ec950dafec18a79E(i64 %dummy) unnamed_addr #1 !dbg !404 {
start:
  %0 = alloca [8 x i8], align 8
  %dummy.dbg.spill = alloca [8 x i8], align 8
  store i64 %dummy, ptr %dummy.dbg.spill, align 8
    #dbg_declare(ptr %dummy.dbg.spill, !408, !DIExpression(), !409)
  store i64 %dummy, ptr %0, align 8, !dbg !410
  call void asm sideeffect "", "r,~{memory}"(ptr %0), !dbg !410, !srcloc !130
  %_0 = load i64, ptr %0, align 8, !dbg !410
  ret i64 %_0, !dbg !411
}

; core::hint::black_box
; Function Attrs: inlinehint uwtable
define internal align 8 ptr @_ZN4core4hint9black_box17h709ee7b5ddc1146dE(ptr align 8 %dummy) unnamed_addr #1 !dbg !412 {
start:
  %0 = alloca [8 x i8], align 8
  %dummy.dbg.spill = alloca [8 x i8], align 8
  store ptr %dummy, ptr %dummy.dbg.spill, align 8
    #dbg_declare(ptr %dummy.dbg.spill, !420, !DIExpression(), !423)
  store ptr %dummy, ptr %0, align 8, !dbg !424
  call void asm sideeffect "", "r,~{memory}"(ptr %0), !dbg !424, !srcloc !130
  %_0 = load ptr, ptr %0, align 8, !dbg !424
  ret ptr %_0, !dbg !425
}

; core::hint::black_box
; Function Attrs: inlinehint uwtable
define internal align 8 ptr @_ZN4core4hint9black_box17hd2d598ead3f74f17E(ptr align 8 %dummy) unnamed_addr #1 !dbg !426 {
start:
  %0 = alloca [8 x i8], align 8
  %dummy.dbg.spill = alloca [8 x i8], align 8
  store ptr %dummy, ptr %dummy.dbg.spill, align 8
    #dbg_declare(ptr %dummy.dbg.spill, !435, !DIExpression(), !438)
  store ptr %dummy, ptr %0, align 8, !dbg !439
  call void asm sideeffect "", "r,~{memory}"(ptr %0), !dbg !439, !srcloc !130
  %_0 = load ptr, ptr %0, align 8, !dbg !439
  ret ptr %_0, !dbg !440
}

; <() as std::process::Termination>::report
; Function Attrs: inlinehint uwtable
define internal i8 @"_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17ha173b8a5cd1687e2E"() unnamed_addr #1 !dbg !441 {
start:
  %_1.dbg.spill = alloca [0 x i8], align 1
    #dbg_declare(ptr %_1.dbg.spill, !446, !DIExpression(), !447)
  ret i8 0, !dbg !448
}

; typegate_demo::authorize
; Function Attrs: noinline uwtable
define internal zeroext i1 @_ZN13typegate_demo9authorize17h92f2dc252dceb235E(ptr align 8 %o) unnamed_addr #2 !dbg !449 {
start:
  %o.dbg.spill = alloca [8 x i8], align 8
  store ptr %o, ptr %o.dbg.spill, align 8
    #dbg_declare(ptr %o.dbg.spill, !455, !DIExpression(), !456)
; call core::hint::black_box
  %_3 = call align 8 ptr @_ZN4core4hint9black_box17h21508f630dc30fdcE(ptr align 8 %o), !dbg !457
  %_2 = load i64, ptr %_3, align 8, !dbg !457
  %_0 = icmp ne i64 %_2, 0, !dbg !457
  ret i1 %_0, !dbg !458
}

; typegate_demo::read_cipher
; Function Attrs: noinline uwtable
define internal i64 @_ZN13typegate_demo11read_cipher17h1974e6f8132e24d6E(ptr align 8 %c) unnamed_addr #2 !dbg !459 {
start:
  %c.dbg.spill = alloca [8 x i8], align 8
  store ptr %c, ptr %c.dbg.spill, align 8
    #dbg_declare(ptr %c.dbg.spill, !463, !DIExpression(), !464)
; call core::hint::black_box
  %_2 = call align 8 ptr @_ZN4core4hint9black_box17h709ee7b5ddc1146dE(ptr align 8 %c), !dbg !465
  %_0 = load i64, ptr %_2, align 8, !dbg !465
  ret i64 %_0, !dbg !466
}

; typegate_demo::handler
; Function Attrs: noinline uwtable
define internal i64 @_ZN13typegate_demo7handler17hc0b034d9b0b14b6bE(ptr align 8 %ctx) unnamed_addr #2 !dbg !467 {
start:
  %ctx.dbg.spill = alloca [8 x i8], align 8
  %_0 = alloca [8 x i8], align 8
  store ptr %ctx, ptr %ctx.dbg.spill, align 8
    #dbg_declare(ptr %ctx.dbg.spill, !471, !DIExpression(), !472)
; call typegate_demo::authorize
  %_2 = call zeroext i1 @_ZN13typegate_demo9authorize17h92f2dc252dceb235E(ptr align 8 %ctx), !dbg !473
  br i1 %_2, label %bb2, label %bb3, !dbg !473

bb3:                                              ; preds = %start
  store i64 0, ptr %_0, align 8, !dbg !474
  br label %bb4, !dbg !475

bb2:                                              ; preds = %start
  %_4 = getelementptr inbounds i8, ptr %ctx, i64 8, !dbg !476
; call typegate_demo::read_cipher
  %0 = call i64 @_ZN13typegate_demo11read_cipher17h1974e6f8132e24d6E(ptr align 8 %_4), !dbg !477
  store i64 %0, ptr %_0, align 8, !dbg !477
  br label %bb4, !dbg !477

bb4:                                              ; preds = %bb2, %bb3
  %1 = load i64, ptr %_0, align 8, !dbg !478
  ret i64 %1, !dbg !478
}

; typegate_demo::main
; Function Attrs: uwtable
define internal void @_ZN13typegate_demo4main17h9908b2f4a824e68fE() unnamed_addr #0 !dbg !479 {
start:
  %_13 = alloca [8 x i8], align 8
  %_11 = alloca [16 x i8], align 8
  %_10 = alloca [16 x i8], align 8
  %_7 = alloca [48 x i8], align 8
  %ctx = alloca [16 x i8], align 8
    #dbg_declare(ptr %ctx, !481, !DIExpression(), !483)
; call core::hint::black_box
  %_3 = call i64 @_ZN4core4hint9black_box17h2ec950dafec18a79E(i64 1), !dbg !484
; call core::hint::black_box
  %_5 = call i64 @_ZN4core4hint9black_box17h2ec950dafec18a79E(i64 42), !dbg !485
  store i64 %_3, ptr %ctx, align 8, !dbg !486
  %0 = getelementptr inbounds i8, ptr %ctx, i64 8, !dbg !486
  store i64 %_5, ptr %0, align 8, !dbg !486
; call core::hint::black_box
  %_14 = call align 8 ptr @_ZN4core4hint9black_box17hd2d598ead3f74f17E(ptr align 8 %ctx), !dbg !487
; call typegate_demo::handler
  %1 = call i64 @_ZN13typegate_demo7handler17hc0b034d9b0b14b6bE(ptr align 8 %_14), !dbg !488
  store i64 %1, ptr %_13, align 8, !dbg !488
; call core::fmt::rt::Argument::new_display
  call void @_ZN4core3fmt2rt8Argument11new_display17hf1046c42d0dbd6c6E(ptr sret([16 x i8]) align 8 %_11, ptr align 8 %_13), !dbg !489
  %2 = getelementptr inbounds %"core::fmt::rt::Argument<'_>", ptr %_10, i64 0, !dbg !489
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %2, ptr align 8 %_11, i64 16, i1 false), !dbg !489
; call core::fmt::Arguments::new_v1
  call void @_ZN4core3fmt9Arguments6new_v117h6101c022456de8fbE(ptr sret([48 x i8]) align 8 %_7, ptr align 8 @alloc_9771be2481f51be410bd2ac520d18601, ptr align 8 %_10), !dbg !489
; call std::io::stdio::_print
  call void @_ZN3std2io5stdio6_print17h6200d46cef53dee1E(ptr align 8 %_7), !dbg !489
  ret void, !dbg !490
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

; std::io::stdio::_print
; Function Attrs: uwtable
declare void @_ZN3std2io5stdio6_print17h6200d46cef53dee1E(ptr align 8) unnamed_addr #0

define i32 @main(i32 %0, ptr %1) unnamed_addr #5 {
top:
  %2 = sext i32 %0 to i64
; call std::rt::lang_start
  %3 = call i64 @_ZN3std2rt10lang_start17hbd80991e398338c5E(ptr @_ZN13typegate_demo4main17h9908b2f4a824e68fE, i64 %2, ptr %1, i8 0)
  %4 = trunc i64 %3 to i32
  ret i32 %4
}

attributes #0 = { uwtable "frame-pointer"="non-leaf" "probe-stack"="inline-asm" "target-cpu"="apple-m1" }
attributes #1 = { inlinehint uwtable "frame-pointer"="non-leaf" "probe-stack"="inline-asm" "target-cpu"="apple-m1" }
attributes #2 = { noinline uwtable "frame-pointer"="non-leaf" "probe-stack"="inline-asm" "target-cpu"="apple-m1" }
attributes #3 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { nounwind uwtable "frame-pointer"="non-leaf" "probe-stack"="inline-asm" "target-cpu"="apple-m1" }
attributes #5 = { "frame-pointer"="non-leaf" "target-cpu"="apple-m1" }

!llvm.module.flags = !{!24, !25, !26, !27}
!llvm.ident = !{!28}
!llvm.dbg.cu = !{!29}

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
!24 = !{i32 8, !"PIC Level", i32 2}
!25 = !{i32 7, !"PIE Level", i32 2}
!26 = !{i32 7, !"Dwarf Version", i32 4}
!27 = !{i32 2, !"Debug Info Version", i32 3}
!28 = !{!"rustc version 1.86.0 (05f9846f8 2025-03-31)"}
!29 = distinct !DICompileUnit(language: DW_LANG_Rust, file: !30, producer: "clang LLVM (rustc version 1.86.0 (05f9846f8 2025-03-31))", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !31, globals: !44, splitDebugInlining: false, nameTableKind: None)
!30 = !DIFile(filename: "typegate_demo.rs/@/typegate_demo.5e6a099dc21d582d-cgu.0", directory: "/Users/sanjib/codes/apace_lab/soap_afg_2026/repositories/AFG/afg_prototype/experiments/typegate-demo")
!31 = !{!32, !40}
!32 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "Alignment", scope: !33, file: !2, baseType: !35, size: 8, align: 8, flags: DIFlagEnumClass, elements: !36)
!33 = !DINamespace(name: "fmt", scope: !34)
!34 = !DINamespace(name: "core", scope: null)
!35 = !DIBasicType(name: "u8", size: 8, encoding: DW_ATE_unsigned)
!36 = !{!37, !38, !39}
!37 = !DIEnumerator(name: "Left", value: 0, isUnsigned: true)
!38 = !DIEnumerator(name: "Right", value: 1, isUnsigned: true)
!39 = !DIEnumerator(name: "Center", value: 2, isUnsigned: true)
!40 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "Alignment", scope: !41, file: !2, baseType: !35, size: 8, align: 8, flags: DIFlagEnumClass, elements: !42)
!41 = !DINamespace(name: "rt", scope: !33)
!42 = !{!37, !38, !39, !43}
!43 = !DIEnumerator(name: "Unknown", value: 3, isUnsigned: true)
!44 = !{!0}
!45 = distinct !DISubprogram(name: "lang_start<()>", linkageName: "_ZN3std2rt10lang_start17hbd80991e398338c5E", scope: !16, file: !46, line: 192, type: !47, scopeLine: 192, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !57, retainedNodes: !52)
!46 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/std/src/rt.rs", directory: "", checksumkind: CSK_MD5, checksum: "5ed61ab28987f8860d5842313c6741b3")
!47 = !DISubroutineType(types: !48)
!48 = !{!49, !20, !49, !50, !35}
!49 = !DIBasicType(name: "isize", size: 64, encoding: DW_ATE_signed)
!50 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*const *const u8", baseType: !51, size: 64, align: 64, dwarfAddressSpace: 0)
!51 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*const u8", baseType: !35, size: 64, align: 64, dwarfAddressSpace: 0)
!52 = !{!53, !54, !55, !56}
!53 = !DILocalVariable(name: "main", arg: 1, scope: !45, file: !46, line: 193, type: !20)
!54 = !DILocalVariable(name: "argc", arg: 2, scope: !45, file: !46, line: 194, type: !49)
!55 = !DILocalVariable(name: "argv", arg: 3, scope: !45, file: !46, line: 195, type: !50)
!56 = !DILocalVariable(name: "sigpipe", arg: 4, scope: !45, file: !46, line: 196, type: !35)
!57 = !{!58}
!58 = !DITemplateTypeParameter(name: "T", type: !7)
!59 = !DILocation(line: 193, column: 5, scope: !45)
!60 = !DILocation(line: 194, column: 5, scope: !45)
!61 = !DILocation(line: 195, column: 5, scope: !45)
!62 = !DILocation(line: 196, column: 5, scope: !45)
!63 = !DILocation(line: 199, column: 10, scope: !45)
!64 = !DILocation(line: 198, column: 5, scope: !45)
!65 = !DILocation(line: 204, column: 2, scope: !45)
!66 = distinct !DISubprogram(name: "{closure#0}<()>", linkageName: "_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h7cf1e36b6bd10a01E", scope: !15, file: !46, line: 199, type: !67, scopeLine: 199, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !57, retainedNodes: !71)
!67 = !DISubroutineType(types: !68)
!68 = !{!69, !70}
!69 = !DIBasicType(name: "i32", size: 32, encoding: DW_ATE_signed)
!70 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&std::rt::lang_start::{closure_env#0}<()>", baseType: !14, size: 64, align: 64, dwarfAddressSpace: 0)
!71 = !{!72}
!72 = !DILocalVariable(name: "main", scope: !66, file: !46, line: 193, type: !20, align: 64)
!73 = !DILocation(line: 193, column: 5, scope: !66)
!74 = !DILocation(line: 199, column: 70, scope: !66)
!75 = !DILocation(line: 199, column: 18, scope: !66)
!76 = !DILocalVariable(name: "self", arg: 1, scope: !77, file: !78, line: 2060, type: !79)
!77 = distinct !DISubprogram(name: "to_i32", linkageName: "_ZN3std7process8ExitCode6to_i3217h916198a91393e649E", scope: !79, file: !78, line: 2060, type: !91, scopeLine: 2060, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !23, declaration: !93, retainedNodes: !94)
!78 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/std/src/process.rs", directory: "", checksumkind: CSK_MD5, checksum: "09b44bf6e4bf5afa11f0c8ce942ef3a7")
!79 = !DICompositeType(tag: DW_TAG_structure_type, name: "ExitCode", scope: !80, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !81, templateParams: !23, identifier: "341afe2df648aa4bace9fb75ede0934e")
!80 = !DINamespace(name: "process", scope: !17)
!81 = !{!82}
!82 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !79, file: !2, baseType: !83, size: 8, align: 8, flags: DIFlagPrivate)
!83 = !DICompositeType(tag: DW_TAG_structure_type, name: "ExitCode", scope: !84, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !89, templateParams: !23, identifier: "93d9edbbd2a7a81ad68d79f01998a178")
!84 = !DINamespace(name: "process_common", scope: !85)
!85 = !DINamespace(name: "process", scope: !86)
!86 = !DINamespace(name: "unix", scope: !87)
!87 = !DINamespace(name: "pal", scope: !88)
!88 = !DINamespace(name: "sys", scope: !17)
!89 = !{!90}
!90 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !83, file: !2, baseType: !35, size: 8, align: 8, flags: DIFlagPrivate)
!91 = !DISubroutineType(types: !92)
!92 = !{!69, !79}
!93 = !DISubprogram(name: "to_i32", linkageName: "_ZN3std7process8ExitCode6to_i3217h916198a91393e649E", scope: !79, file: !78, line: 2060, type: !91, scopeLine: 2060, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!94 = !{!76}
!95 = !DILocation(line: 2060, column: 19, scope: !77, inlinedAt: !96)
!96 = !DILocation(line: 199, column: 85, scope: !66)
!97 = !DILocation(line: 636, column: 9, scope: !98, inlinedAt: !104)
!98 = distinct !DISubprogram(name: "as_i32", linkageName: "_ZN3std3sys3pal4unix7process14process_common8ExitCode6as_i3217h53b3194072644f8aE", scope: !83, file: !99, line: 635, type: !100, scopeLine: 635, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !23, declaration: !103)
!99 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/std/src/sys/pal/unix/process/process_common.rs", directory: "", checksumkind: CSK_MD5, checksum: "7107dec5baaefd58adc486b058fd5a71")
!100 = !DISubroutineType(types: !101)
!101 = !{!69, !102}
!102 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&std::sys::pal::unix::process::process_common::ExitCode", baseType: !83, size: 64, align: 64, dwarfAddressSpace: 0)
!103 = !DISubprogram(name: "as_i32", linkageName: "_ZN3std3sys3pal4unix7process14process_common8ExitCode6as_i3217h53b3194072644f8aE", scope: !83, file: !99, line: 635, type: !100, scopeLine: 635, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!104 = !DILocation(line: 2061, column: 16, scope: !77, inlinedAt: !96)
!105 = !DILocation(line: 199, column: 93, scope: !66)
!106 = distinct !DISubprogram(name: "__rust_begin_short_backtrace<fn(), ()>", linkageName: "_ZN3std3sys9backtrace28__rust_begin_short_backtrace17he5abbf7b33347f31E", scope: !108, file: !107, line: 148, type: !109, scopeLine: 148, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !115, retainedNodes: !111)
!107 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/std/src/sys/backtrace.rs", directory: "", checksumkind: CSK_MD5, checksum: "9e30c70624c3cf40238860e740bd696f")
!108 = !DINamespace(name: "backtrace", scope: !88)
!109 = !DISubroutineType(types: !110)
!110 = !{null, !20}
!111 = !{!112, !113}
!112 = !DILocalVariable(name: "f", arg: 1, scope: !106, file: !107, line: 148, type: !20)
!113 = !DILocalVariable(name: "result", scope: !114, file: !107, line: 152, type: !7, align: 8)
!114 = distinct !DILexicalBlock(scope: !106, file: !107, line: 152, column: 5)
!115 = !{!116, !58}
!116 = !DITemplateTypeParameter(name: "F", type: !20)
!117 = !DILocation(line: 152, column: 9, scope: !114)
!118 = !DILocation(line: 148, column: 43, scope: !106)
!119 = !DILocalVariable(name: "dummy", scope: !120, file: !121, line: 476, type: !7, align: 8)
!120 = distinct !DISubprogram(name: "black_box<()>", linkageName: "_ZN4core4hint9black_box17hba7ef742436de10fE", scope: !122, file: !121, line: 476, type: !123, scopeLine: 476, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !57, retainedNodes: !125)
!121 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/hint.rs", directory: "", checksumkind: CSK_MD5, checksum: "4d6fc217f737459a7201759c6559d6c1")
!122 = !DINamespace(name: "hint", scope: !34)
!123 = !DISubroutineType(types: !124)
!124 = !{null, !7}
!125 = !{!119}
!126 = !DILocation(line: 476, column: 27, scope: !120, inlinedAt: !127)
!127 = !DILocation(line: 155, column: 5, scope: !114)
!128 = !DILocation(line: 152, column: 18, scope: !106)
!129 = !DILocation(line: 477, column: 5, scope: !120, inlinedAt: !127)
!130 = !{i64 5586846215297298}
!131 = !DILocation(line: 158, column: 2, scope: !106)
!132 = distinct !DISubprogram(name: "new_display<u64>", linkageName: "_ZN4core3fmt2rt8Argument11new_display17hf1046c42d0dbd6c6E", scope: !134, file: !133, line: 113, type: !234, scopeLine: 113, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !238, declaration: !237, retainedNodes: !240)
!133 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/fmt/rt.rs", directory: "", checksumkind: CSK_MD5, checksum: "03cc435a170c7724e037ef722264e101")
!134 = !DICompositeType(tag: DW_TAG_structure_type, name: "Argument", scope: !41, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !135, templateParams: !23, identifier: "a664b527b69c03545f8bc05bdc2a7f06")
!135 = !{!136}
!136 = !DIDerivedType(tag: DW_TAG_member, name: "ty", scope: !134, file: !2, baseType: !137, size: 128, align: 64, flags: DIFlagPrivate)
!137 = !DICompositeType(tag: DW_TAG_structure_type, name: "ArgumentType", scope: !41, file: !2, size: 128, align: 64, flags: DIFlagPrivate, elements: !138, templateParams: !23, identifier: "6251445db8f9510fd4be5cc1b840f8f4")
!138 = !{!139}
!139 = !DICompositeType(tag: DW_TAG_variant_part, scope: !137, file: !2, size: 128, align: 64, elements: !140, templateParams: !23, identifier: "5c92422e0be9a7b32f4f7de4ef9137d2", discriminator: !233)
!140 = !{!141, !229}
!141 = !DIDerivedType(tag: DW_TAG_member, name: "Placeholder", scope: !139, file: !2, baseType: !142, size: 128, align: 64)
!142 = !DICompositeType(tag: DW_TAG_structure_type, name: "Placeholder", scope: !137, file: !2, size: 128, align: 64, flags: DIFlagPrivate, elements: !143, templateParams: !23, identifier: "20e6221e04bdfd7d1fcb39a3790c6e33")
!143 = !{!144, !150, !223}
!144 = !DIDerivedType(tag: DW_TAG_member, name: "value", scope: !142, file: !2, baseType: !145, size: 64, align: 64, flags: DIFlagPrivate)
!145 = !DICompositeType(tag: DW_TAG_structure_type, name: "NonNull<()>", scope: !146, file: !2, size: 64, align: 64, flags: DIFlagPublic, elements: !148, templateParams: !57, identifier: "cf5c1ba45dbb550b74727209a45e522f")
!146 = !DINamespace(name: "non_null", scope: !147)
!147 = !DINamespace(name: "ptr", scope: !34)
!148 = !{!149}
!149 = !DIDerivedType(tag: DW_TAG_member, name: "pointer", scope: !145, file: !2, baseType: !6, size: 64, align: 64, flags: DIFlagPrivate)
!150 = !DIDerivedType(tag: DW_TAG_member, name: "formatter", scope: !142, file: !2, baseType: !151, size: 64, align: 64, offset: 64, flags: DIFlagPrivate)
!151 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "unsafe fn(core::ptr::non_null::NonNull<()>, &mut core::fmt::Formatter) -> core::result::Result<(), core::fmt::Error>", baseType: !152, size: 64, align: 64, dwarfAddressSpace: 0)
!152 = !DISubroutineType(types: !153)
!153 = !{!154, !145, !171}
!154 = !DICompositeType(tag: DW_TAG_structure_type, name: "Result<(), core::fmt::Error>", scope: !155, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !156, templateParams: !23, identifier: "c5a7ad530f7adf62d2fecbcc7362b6f7")
!155 = !DINamespace(name: "result", scope: !34)
!156 = !{!157}
!157 = !DICompositeType(tag: DW_TAG_variant_part, scope: !154, file: !2, size: 8, align: 8, elements: !158, templateParams: !23, identifier: "ac779e5943fbf99477fa03a0b0bc4e54", discriminator: !170)
!158 = !{!159, !166}
!159 = !DIDerivedType(tag: DW_TAG_member, name: "Ok", scope: !157, file: !2, baseType: !160, size: 8, align: 8, extraData: i8 0)
!160 = !DICompositeType(tag: DW_TAG_structure_type, name: "Ok", scope: !154, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !161, templateParams: !163, identifier: "97f51036cf4af0b1e783eb2f4e594c6")
!161 = !{!162}
!162 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !160, file: !2, baseType: !7, align: 8, offset: 8, flags: DIFlagPublic)
!163 = !{!58, !164}
!164 = !DITemplateTypeParameter(name: "E", type: !165)
!165 = !DICompositeType(tag: DW_TAG_structure_type, name: "Error", scope: !33, file: !2, align: 8, flags: DIFlagPublic, elements: !23, identifier: "20e3adf778d4de669c6748e62a470a70")
!166 = !DIDerivedType(tag: DW_TAG_member, name: "Err", scope: !157, file: !2, baseType: !167, size: 8, align: 8, extraData: i8 1)
!167 = !DICompositeType(tag: DW_TAG_structure_type, name: "Err", scope: !154, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !168, templateParams: !163, identifier: "41728e5f243f1d8b9681f4bd5ba681de")
!168 = !{!169}
!169 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !167, file: !2, baseType: !165, align: 8, offset: 8, flags: DIFlagPublic)
!170 = !DIDerivedType(tag: DW_TAG_member, scope: !154, file: !2, baseType: !35, size: 8, align: 8, flags: DIFlagArtificial)
!171 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut core::fmt::Formatter", baseType: !172, size: 64, align: 64, dwarfAddressSpace: 0)
!172 = !DICompositeType(tag: DW_TAG_structure_type, name: "Formatter", scope: !33, file: !2, size: 512, align: 64, flags: DIFlagPublic, elements: !173, templateParams: !23, identifier: "52755d1a359ac843f3ec4fcaa35d3f")
!173 = !{!174, !212}
!174 = !DIDerivedType(tag: DW_TAG_member, name: "options", scope: !172, file: !2, baseType: !175, size: 384, align: 64, flags: DIFlagPrivate)
!175 = !DICompositeType(tag: DW_TAG_structure_type, name: "FormattingOptions", scope: !33, file: !2, size: 384, align: 64, flags: DIFlagPublic, elements: !176, templateParams: !23, identifier: "7dbfe1d703871c54b07bd54d02647d8")
!176 = !{!177, !179, !181, !196, !211}
!177 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !175, file: !2, baseType: !178, size: 32, align: 32, offset: 288, flags: DIFlagPrivate)
!178 = !DIBasicType(name: "u32", size: 32, encoding: DW_ATE_unsigned)
!179 = !DIDerivedType(tag: DW_TAG_member, name: "fill", scope: !175, file: !2, baseType: !180, size: 32, align: 32, offset: 256, flags: DIFlagPrivate)
!180 = !DIBasicType(name: "char", size: 32, encoding: DW_ATE_UTF)
!181 = !DIDerivedType(tag: DW_TAG_member, name: "align", scope: !175, file: !2, baseType: !182, size: 8, align: 8, offset: 320, flags: DIFlagPrivate)
!182 = !DICompositeType(tag: DW_TAG_structure_type, name: "Option<core::fmt::Alignment>", scope: !183, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !184, templateParams: !23, identifier: "187967e034abadf554783ea9627f2c4c")
!183 = !DINamespace(name: "option", scope: !34)
!184 = !{!185}
!185 = !DICompositeType(tag: DW_TAG_variant_part, scope: !182, file: !2, size: 8, align: 8, elements: !186, templateParams: !23, identifier: "cb055755af32967a2c89ea484bc45b19", discriminator: !195)
!186 = !{!187, !191}
!187 = !DIDerivedType(tag: DW_TAG_member, name: "None", scope: !185, file: !2, baseType: !188, size: 8, align: 8, extraData: i8 3)
!188 = !DICompositeType(tag: DW_TAG_structure_type, name: "None", scope: !182, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !23, templateParams: !189, identifier: "d4d2ab0f9d5d0342724ccea6249b16cd")
!189 = !{!190}
!190 = !DITemplateTypeParameter(name: "T", type: !32)
!191 = !DIDerivedType(tag: DW_TAG_member, name: "Some", scope: !185, file: !2, baseType: !192, size: 8, align: 8)
!192 = !DICompositeType(tag: DW_TAG_structure_type, name: "Some", scope: !182, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !193, templateParams: !189, identifier: "4457b62b678dcd564d38c3283bcd3c06")
!193 = !{!194}
!194 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !192, file: !2, baseType: !32, size: 8, align: 8, flags: DIFlagPublic)
!195 = !DIDerivedType(tag: DW_TAG_member, scope: !182, file: !2, baseType: !35, size: 8, align: 8, flags: DIFlagArtificial)
!196 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !175, file: !2, baseType: !197, size: 128, align: 64, flags: DIFlagPrivate)
!197 = !DICompositeType(tag: DW_TAG_structure_type, name: "Option<usize>", scope: !183, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !198, templateParams: !23, identifier: "8045954f929eb45a5528fd8a14b4f02d")
!198 = !{!199}
!199 = !DICompositeType(tag: DW_TAG_variant_part, scope: !197, file: !2, size: 128, align: 64, elements: !200, templateParams: !23, identifier: "2fdae1f8d2eb65dff6da1604f1815b04", discriminator: !209)
!200 = !{!201, !205}
!201 = !DIDerivedType(tag: DW_TAG_member, name: "None", scope: !199, file: !2, baseType: !202, size: 128, align: 64, extraData: i64 0)
!202 = !DICompositeType(tag: DW_TAG_structure_type, name: "None", scope: !197, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !23, templateParams: !203, identifier: "5e26e76789ea6e1bf656dfc0884a24bd")
!203 = !{!204}
!204 = !DITemplateTypeParameter(name: "T", type: !9)
!205 = !DIDerivedType(tag: DW_TAG_member, name: "Some", scope: !199, file: !2, baseType: !206, size: 128, align: 64, extraData: i64 1)
!206 = !DICompositeType(tag: DW_TAG_structure_type, name: "Some", scope: !197, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !207, templateParams: !203, identifier: "f4e093de6b7b2d9cbf46b7d59706431")
!207 = !{!208}
!208 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !206, file: !2, baseType: !9, size: 64, align: 64, offset: 64, flags: DIFlagPublic)
!209 = !DIDerivedType(tag: DW_TAG_member, scope: !197, file: !2, baseType: !210, size: 64, align: 64, flags: DIFlagArtificial)
!210 = !DIBasicType(name: "u64", size: 64, encoding: DW_ATE_unsigned)
!211 = !DIDerivedType(tag: DW_TAG_member, name: "precision", scope: !175, file: !2, baseType: !197, size: 128, align: 64, offset: 128, flags: DIFlagPrivate)
!212 = !DIDerivedType(tag: DW_TAG_member, name: "buf", scope: !172, file: !2, baseType: !213, size: 128, align: 64, offset: 384, flags: DIFlagPrivate)
!213 = !DICompositeType(tag: DW_TAG_structure_type, name: "&mut dyn core::fmt::Write", file: !2, size: 128, align: 64, elements: !214, templateParams: !23, identifier: "98297a6fbd62117e7da99e38e823d6ab")
!214 = !{!215, !218}
!215 = !DIDerivedType(tag: DW_TAG_member, name: "pointer", scope: !213, file: !2, baseType: !216, size: 64, align: 64)
!216 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !217, size: 64, align: 64, dwarfAddressSpace: 0)
!217 = !DICompositeType(tag: DW_TAG_structure_type, name: "dyn core::fmt::Write", file: !2, align: 8, elements: !23, identifier: "21d5e048ae7c921567058459068d0b4d")
!218 = !DIDerivedType(tag: DW_TAG_member, name: "vtable", scope: !213, file: !2, baseType: !219, size: 64, align: 64, offset: 64)
!219 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&[usize; 6]", baseType: !220, size: 64, align: 64, dwarfAddressSpace: 0)
!220 = !DICompositeType(tag: DW_TAG_array_type, baseType: !9, size: 384, align: 64, elements: !221)
!221 = !{!222}
!222 = !DISubrange(count: 6, lowerBound: 0)
!223 = !DIDerivedType(tag: DW_TAG_member, name: "_lifetime", scope: !142, file: !2, baseType: !224, align: 8, offset: 128, flags: DIFlagPrivate)
!224 = !DICompositeType(tag: DW_TAG_structure_type, name: "PhantomData<&()>", scope: !225, file: !2, align: 8, flags: DIFlagPublic, elements: !23, templateParams: !226, identifier: "f7ebfa6b21c1c02d5aa8b8770d0b11ef")
!225 = !DINamespace(name: "marker", scope: !34)
!226 = !{!227}
!227 = !DITemplateTypeParameter(name: "T", type: !228)
!228 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&()", baseType: !7, size: 64, align: 64, dwarfAddressSpace: 0)
!229 = !DIDerivedType(tag: DW_TAG_member, name: "Count", scope: !139, file: !2, baseType: !230, size: 128, align: 64, extraData: i64 0)
!230 = !DICompositeType(tag: DW_TAG_structure_type, name: "Count", scope: !137, file: !2, size: 128, align: 64, flags: DIFlagPrivate, elements: !231, templateParams: !23, identifier: "f6a8f247f1ab86955db6fdbdb79b3fa7")
!231 = !{!232}
!232 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !230, file: !2, baseType: !9, size: 64, align: 64, offset: 64, flags: DIFlagPrivate)
!233 = !DIDerivedType(tag: DW_TAG_member, scope: !137, file: !2, baseType: !210, size: 64, align: 64, flags: DIFlagArtificial)
!234 = !DISubroutineType(types: !235)
!235 = !{!134, !236}
!236 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&u64", baseType: !210, size: 64, align: 64, dwarfAddressSpace: 0)
!237 = !DISubprogram(name: "new_display<u64>", linkageName: "_ZN4core3fmt2rt8Argument11new_display17hf1046c42d0dbd6c6E", scope: !134, file: !133, line: 113, type: !234, scopeLine: 113, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !238)
!238 = !{!239}
!239 = !DITemplateTypeParameter(name: "T", type: !210)
!240 = !{!241}
!241 = !DILocalVariable(name: "x", arg: 1, scope: !132, file: !133, line: 113, type: !236)
!242 = !DILocation(line: 113, column: 36, scope: !132)
!243 = !DILocalVariable(name: "x", arg: 1, scope: !244, file: !133, line: 99, type: !236)
!244 = distinct !DISubprogram(name: "new<u64>", linkageName: "_ZN4core3fmt2rt8Argument3new17h171e49ace7ee481aE", scope: !134, file: !133, line: 99, type: !245, scopeLine: 99, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !238, declaration: !250, retainedNodes: !251)
!245 = !DISubroutineType(types: !246)
!246 = !{!134, !236, !247}
!247 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "fn(&u64, &mut core::fmt::Formatter) -> core::result::Result<(), core::fmt::Error>", baseType: !248, size: 64, align: 64, dwarfAddressSpace: 0)
!248 = !DISubroutineType(types: !249)
!249 = !{!154, !236, !171}
!250 = !DISubprogram(name: "new<u64>", linkageName: "_ZN4core3fmt2rt8Argument3new17h171e49ace7ee481aE", scope: !134, file: !133, line: 99, type: !245, scopeLine: 99, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !238)
!251 = !{!243}
!252 = !DILocation(line: 99, column: 25, scope: !244, inlinedAt: !253)
!253 = !DILocation(line: 114, column: 9, scope: !132)
!254 = !DILocalVariable(name: "r", arg: 1, scope: !255, file: !256, line: 268, type: !236)
!255 = distinct !DISubprogram(name: "from_ref<u64>", linkageName: "_ZN4core3ptr8non_null16NonNull$LT$T$GT$8from_ref17hb78f8b577c214dd1E", scope: !257, file: !256, line: 268, type: !261, scopeLine: 268, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !238, declaration: !263, retainedNodes: !264)
!256 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/ptr/non_null.rs", directory: "", checksumkind: CSK_MD5, checksum: "f45049b8fe718e09b04e14006dd7e8d3")
!257 = !DICompositeType(tag: DW_TAG_structure_type, name: "NonNull<u64>", scope: !146, file: !2, size: 64, align: 64, flags: DIFlagPublic, elements: !258, templateParams: !238, identifier: "f0315fbb7066bb2768a6e4ebf06aee69")
!258 = !{!259}
!259 = !DIDerivedType(tag: DW_TAG_member, name: "pointer", scope: !257, file: !2, baseType: !260, size: 64, align: 64, flags: DIFlagPrivate)
!260 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*const u64", baseType: !210, size: 64, align: 64, dwarfAddressSpace: 0)
!261 = !DISubroutineType(types: !262)
!262 = !{!257, !236}
!263 = !DISubprogram(name: "from_ref<u64>", linkageName: "_ZN4core3ptr8non_null16NonNull$LT$T$GT$8from_ref17hb78f8b577c214dd1E", scope: !257, file: !256, line: 268, type: !261, scopeLine: 268, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !238)
!264 = !{!254}
!265 = !DILocation(line: 268, column: 27, scope: !255, inlinedAt: !266)
!266 = !DILocation(line: 104, column: 24, scope: !244, inlinedAt: !253)
!267 = !DILocation(line: 103, column: 17, scope: !244, inlinedAt: !253)
!268 = !DILocation(line: 100, column: 9, scope: !244, inlinedAt: !253)
!269 = !DILocation(line: 115, column: 6, scope: !132)
!270 = distinct !DISubprogram(name: "new_v1<2, 1>", linkageName: "_ZN4core3fmt9Arguments6new_v117h6101c022456de8fbE", scope: !272, file: !271, line: 608, type: !333, scopeLine: 608, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !23, declaration: !343, retainedNodes: !344)
!271 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/fmt/mod.rs", directory: "", checksumkind: CSK_MD5, checksum: "622ef1b3b6e3beca6d52f42f40384739")
!272 = !DICompositeType(tag: DW_TAG_structure_type, name: "Arguments", scope: !33, file: !2, size: 384, align: 64, flags: DIFlagPublic, elements: !273, templateParams: !23, identifier: "dddafec8d5877f1396e365b41f9d97e0")
!273 = !{!274, !285, !327}
!274 = !DIDerivedType(tag: DW_TAG_member, name: "pieces", scope: !272, file: !2, baseType: !275, size: 128, align: 64, flags: DIFlagPrivate)
!275 = !DICompositeType(tag: DW_TAG_structure_type, name: "&[&str]", file: !2, size: 128, align: 64, elements: !276, templateParams: !23, identifier: "4e66b00a376d6af5b8765440fb2839f")
!276 = !{!277, !284}
!277 = !DIDerivedType(tag: DW_TAG_member, name: "data_ptr", scope: !275, file: !2, baseType: !278, size: 64, align: 64)
!278 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !279, size: 64, align: 64, dwarfAddressSpace: 0)
!279 = !DICompositeType(tag: DW_TAG_structure_type, name: "&str", file: !2, size: 128, align: 64, elements: !280, templateParams: !23, identifier: "9277eecd40495f85161460476aacc992")
!280 = !{!281, !283}
!281 = !DIDerivedType(tag: DW_TAG_member, name: "data_ptr", scope: !279, file: !2, baseType: !282, size: 64, align: 64)
!282 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !35, size: 64, align: 64, dwarfAddressSpace: 0)
!283 = !DIDerivedType(tag: DW_TAG_member, name: "length", scope: !279, file: !2, baseType: !9, size: 64, align: 64, offset: 64)
!284 = !DIDerivedType(tag: DW_TAG_member, name: "length", scope: !275, file: !2, baseType: !9, size: 64, align: 64, offset: 64)
!285 = !DIDerivedType(tag: DW_TAG_member, name: "fmt", scope: !272, file: !2, baseType: !286, size: 128, align: 64, offset: 256, flags: DIFlagPrivate)
!286 = !DICompositeType(tag: DW_TAG_structure_type, name: "Option<&[core::fmt::rt::Placeholder]>", scope: !183, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !287, templateParams: !23, identifier: "1e413fbc1716d1313bc5a6473de47705")
!287 = !{!288}
!288 = !DICompositeType(tag: DW_TAG_variant_part, scope: !286, file: !2, size: 128, align: 64, elements: !289, templateParams: !23, identifier: "9f08d569bfdf661b7c43becc63b66f17", discriminator: !326)
!289 = !{!290, !322}
!290 = !DIDerivedType(tag: DW_TAG_member, name: "None", scope: !288, file: !2, baseType: !291, size: 128, align: 64, extraData: i64 0)
!291 = !DICompositeType(tag: DW_TAG_structure_type, name: "None", scope: !286, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !23, templateParams: !292, identifier: "51381d817c48247dc57111932f86b1da")
!292 = !{!293}
!293 = !DITemplateTypeParameter(name: "T", type: !294)
!294 = !DICompositeType(tag: DW_TAG_structure_type, name: "&[core::fmt::rt::Placeholder]", file: !2, size: 128, align: 64, elements: !295, templateParams: !23, identifier: "797a5e35b920879820f0bb337aac7839")
!295 = !{!296, !321}
!296 = !DIDerivedType(tag: DW_TAG_member, name: "data_ptr", scope: !294, file: !2, baseType: !297, size: 64, align: 64)
!297 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !298, size: 64, align: 64, dwarfAddressSpace: 0)
!298 = !DICompositeType(tag: DW_TAG_structure_type, name: "Placeholder", scope: !41, file: !2, size: 448, align: 64, flags: DIFlagPublic, elements: !299, templateParams: !23, identifier: "9154d1af9bcc2ef75e3aff1bc2fa3dcd")
!299 = !{!300, !301, !302, !303, !304, !320}
!300 = !DIDerivedType(tag: DW_TAG_member, name: "position", scope: !298, file: !2, baseType: !9, size: 64, align: 64, offset: 256, flags: DIFlagPublic)
!301 = !DIDerivedType(tag: DW_TAG_member, name: "fill", scope: !298, file: !2, baseType: !180, size: 32, align: 32, offset: 320, flags: DIFlagPublic)
!302 = !DIDerivedType(tag: DW_TAG_member, name: "align", scope: !298, file: !2, baseType: !40, size: 8, align: 8, offset: 384, flags: DIFlagPublic)
!303 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !298, file: !2, baseType: !178, size: 32, align: 32, offset: 352, flags: DIFlagPublic)
!304 = !DIDerivedType(tag: DW_TAG_member, name: "precision", scope: !298, file: !2, baseType: !305, size: 128, align: 64, flags: DIFlagPublic)
!305 = !DICompositeType(tag: DW_TAG_structure_type, name: "Count", scope: !41, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !306, templateParams: !23, identifier: "e26a82e73433e407a87f263dd77def32")
!306 = !{!307}
!307 = !DICompositeType(tag: DW_TAG_variant_part, scope: !305, file: !2, size: 128, align: 64, elements: !308, templateParams: !23, identifier: "77e32cf5833c5f3e6cd3e97392cd8af3", discriminator: !319)
!308 = !{!309, !313, !317}
!309 = !DIDerivedType(tag: DW_TAG_member, name: "Is", scope: !307, file: !2, baseType: !310, size: 128, align: 64, extraData: i64 0)
!310 = !DICompositeType(tag: DW_TAG_structure_type, name: "Is", scope: !305, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !311, templateParams: !23, identifier: "5116bec7d245076f68fc64938e054ffc")
!311 = !{!312}
!312 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !310, file: !2, baseType: !9, size: 64, align: 64, offset: 64, flags: DIFlagPublic)
!313 = !DIDerivedType(tag: DW_TAG_member, name: "Param", scope: !307, file: !2, baseType: !314, size: 128, align: 64, extraData: i64 1)
!314 = !DICompositeType(tag: DW_TAG_structure_type, name: "Param", scope: !305, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !315, templateParams: !23, identifier: "621a25d2838569fdd07983f37e504800")
!315 = !{!316}
!316 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !314, file: !2, baseType: !9, size: 64, align: 64, offset: 64, flags: DIFlagPublic)
!317 = !DIDerivedType(tag: DW_TAG_member, name: "Implied", scope: !307, file: !2, baseType: !318, size: 128, align: 64, extraData: i64 2)
!318 = !DICompositeType(tag: DW_TAG_structure_type, name: "Implied", scope: !305, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !23, identifier: "2d4685281a55fa2636628f64f3a88ce7")
!319 = !DIDerivedType(tag: DW_TAG_member, scope: !305, file: !2, baseType: !210, size: 64, align: 64, flags: DIFlagArtificial)
!320 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !298, file: !2, baseType: !305, size: 128, align: 64, offset: 128, flags: DIFlagPublic)
!321 = !DIDerivedType(tag: DW_TAG_member, name: "length", scope: !294, file: !2, baseType: !9, size: 64, align: 64, offset: 64)
!322 = !DIDerivedType(tag: DW_TAG_member, name: "Some", scope: !288, file: !2, baseType: !323, size: 128, align: 64)
!323 = !DICompositeType(tag: DW_TAG_structure_type, name: "Some", scope: !286, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !324, templateParams: !292, identifier: "b9092a96320a352152f63d8bb09d833")
!324 = !{!325}
!325 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !323, file: !2, baseType: !294, size: 128, align: 64, flags: DIFlagPublic)
!326 = !DIDerivedType(tag: DW_TAG_member, scope: !286, file: !2, baseType: !210, size: 64, align: 64, flags: DIFlagArtificial)
!327 = !DIDerivedType(tag: DW_TAG_member, name: "args", scope: !272, file: !2, baseType: !328, size: 128, align: 64, offset: 128, flags: DIFlagPrivate)
!328 = !DICompositeType(tag: DW_TAG_structure_type, name: "&[core::fmt::rt::Argument]", file: !2, size: 128, align: 64, elements: !329, templateParams: !23, identifier: "6334efd1704d5b576a75bbdae36749de")
!329 = !{!330, !332}
!330 = !DIDerivedType(tag: DW_TAG_member, name: "data_ptr", scope: !328, file: !2, baseType: !331, size: 64, align: 64)
!331 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !134, size: 64, align: 64, dwarfAddressSpace: 0)
!332 = !DIDerivedType(tag: DW_TAG_member, name: "length", scope: !328, file: !2, baseType: !9, size: 64, align: 64, offset: 64)
!333 = !DISubroutineType(types: !334)
!334 = !{!272, !335, !339}
!335 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&[&str; 2]", baseType: !336, size: 64, align: 64, dwarfAddressSpace: 0)
!336 = !DICompositeType(tag: DW_TAG_array_type, baseType: !279, size: 256, align: 64, elements: !337)
!337 = !{!338}
!338 = !DISubrange(count: 2, lowerBound: 0)
!339 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&[core::fmt::rt::Argument; 1]", baseType: !340, size: 64, align: 64, dwarfAddressSpace: 0)
!340 = !DICompositeType(tag: DW_TAG_array_type, baseType: !134, size: 128, align: 64, elements: !341)
!341 = !{!342}
!342 = !DISubrange(count: 1, lowerBound: 0)
!343 = !DISubprogram(name: "new_v1<2, 1>", linkageName: "_ZN4core3fmt9Arguments6new_v117h6101c022456de8fbE", scope: !272, file: !271, line: 608, type: !333, scopeLine: 608, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!344 = !{!345, !346}
!345 = !DILocalVariable(name: "pieces", arg: 1, scope: !270, file: !271, line: 609, type: !335)
!346 = !DILocalVariable(name: "args", arg: 2, scope: !270, file: !271, line: 610, type: !339)
!347 = !DILocation(line: 609, column: 9, scope: !270)
!348 = !DILocation(line: 610, column: 9, scope: !270)
!349 = !DILocation(line: 613, column: 9, scope: !270)
!350 = !DILocation(line: 614, column: 6, scope: !270)
!351 = distinct !DISubprogram(name: "call_once<std::rt::lang_start::{closure_env#0}<()>, ()>", linkageName: "_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h01c75b192465ab24E", scope: !353, file: !352, line: 250, type: !356, scopeLine: 250, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !362, retainedNodes: !359)
!352 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/ops/function.rs", directory: "", checksumkind: CSK_MD5, checksum: "27f40bbdeb6cc525c0d0d7cf434d92c4")
!353 = !DINamespace(name: "FnOnce", scope: !354)
!354 = !DINamespace(name: "function", scope: !355)
!355 = !DINamespace(name: "ops", scope: !34)
!356 = !DISubroutineType(types: !357)
!357 = !{!69, !358}
!358 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*mut std::rt::lang_start::{closure_env#0}<()>", baseType: !14, size: 64, align: 64, dwarfAddressSpace: 0)
!359 = !{!360, !361}
!360 = !DILocalVariable(arg: 1, scope: !351, file: !352, line: 250, type: !358)
!361 = !DILocalVariable(arg: 2, scope: !351, file: !352, line: 250, type: !7)
!362 = !{!363, !364}
!363 = !DITemplateTypeParameter(name: "Self", type: !14)
!364 = !DITemplateTypeParameter(name: "Args", type: !7)
!365 = !DILocation(line: 250, column: 5, scope: !351)
!366 = distinct !DISubprogram(name: "call_once<std::rt::lang_start::{closure_env#0}<()>, ()>", linkageName: "_ZN4core3ops8function6FnOnce9call_once17h1fd4289948593c7cE", scope: !353, file: !352, line: 250, type: !367, scopeLine: 250, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !362, retainedNodes: !369)
!367 = !DISubroutineType(types: !368)
!368 = !{!69, !14}
!369 = !{!370, !371}
!370 = !DILocalVariable(arg: 1, scope: !366, file: !352, line: 250, type: !14)
!371 = !DILocalVariable(arg: 2, scope: !366, file: !352, line: 250, type: !7)
!372 = !DILocation(line: 250, column: 5, scope: !366)
!373 = distinct !DISubprogram(name: "call_once<fn(), ()>", linkageName: "_ZN4core3ops8function6FnOnce9call_once17h6adfa9c64bd4cda4E", scope: !353, file: !352, line: 250, type: !109, scopeLine: 250, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !377, retainedNodes: !374)
!374 = !{!375, !376}
!375 = !DILocalVariable(arg: 1, scope: !373, file: !352, line: 250, type: !20)
!376 = !DILocalVariable(arg: 2, scope: !373, file: !352, line: 250, type: !7)
!377 = !{!378, !364}
!378 = !DITemplateTypeParameter(name: "Self", type: !20)
!379 = !DILocation(line: 250, column: 5, scope: !373)
!380 = distinct !DISubprogram(name: "drop_in_place<std::rt::lang_start::{closure_env#0}<()>>", linkageName: "_ZN4core3ptr85drop_in_place$LT$std..rt..lang_start$LT$$LP$$RP$$GT$..$u7b$$u7b$closure$u7d$$u7d$$GT$17hb11962db33b9a3cdE", scope: !147, file: !381, line: 523, type: !382, scopeLine: 523, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !386, retainedNodes: !384)
!381 = !DIFile(filename: "/rustc/05f9846f893b09a1be1fc8560e33fc3c815cfecb/library/core/src/ptr/mod.rs", directory: "", checksumkind: CSK_MD5, checksum: "e9c4ba6bc13274cb82fe40874c88ba3f")
!382 = !DISubroutineType(types: !383)
!383 = !{null, !358}
!384 = !{!385}
!385 = !DILocalVariable(arg: 1, scope: !380, file: !381, line: 523, type: !358)
!386 = !{!387}
!387 = !DITemplateTypeParameter(name: "T", type: !14)
!388 = !DILocation(line: 523, column: 1, scope: !380)
!389 = distinct !DISubprogram(name: "black_box<&typegate_demo::Org>", linkageName: "_ZN4core4hint9black_box17h21508f630dc30fdcE", scope: !122, file: !121, line: 476, type: !390, scopeLine: 476, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !399, retainedNodes: !397)
!390 = !DISubroutineType(types: !391)
!391 = !{!392, !392}
!392 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&typegate_demo::Org", baseType: !393, size: 64, align: 64, dwarfAddressSpace: 0)
!393 = !DICompositeType(tag: DW_TAG_structure_type, name: "Org", scope: !394, file: !2, size: 64, align: 64, flags: DIFlagPublic, elements: !395, templateParams: !23, identifier: "65ed7134bdf53ad24cae8089ebe8f68f")
!394 = !DINamespace(name: "typegate_demo", scope: null)
!395 = !{!396}
!396 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !393, file: !2, baseType: !210, size: 64, align: 64, flags: DIFlagPublic)
!397 = !{!398}
!398 = !DILocalVariable(name: "dummy", arg: 1, scope: !389, file: !121, line: 476, type: !392)
!399 = !{!400}
!400 = !DITemplateTypeParameter(name: "T", type: !392)
!401 = !DILocation(line: 476, column: 27, scope: !389)
!402 = !DILocation(line: 477, column: 5, scope: !389)
!403 = !DILocation(line: 478, column: 2, scope: !389)
!404 = distinct !DISubprogram(name: "black_box<u64>", linkageName: "_ZN4core4hint9black_box17h2ec950dafec18a79E", scope: !122, file: !121, line: 476, type: !405, scopeLine: 476, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !238, retainedNodes: !407)
!405 = !DISubroutineType(types: !406)
!406 = !{!210, !210}
!407 = !{!408}
!408 = !DILocalVariable(name: "dummy", arg: 1, scope: !404, file: !121, line: 476, type: !210)
!409 = !DILocation(line: 476, column: 27, scope: !404)
!410 = !DILocation(line: 477, column: 5, scope: !404)
!411 = !DILocation(line: 478, column: 2, scope: !404)
!412 = distinct !DISubprogram(name: "black_box<&typegate_demo::Cipher>", linkageName: "_ZN4core4hint9black_box17h709ee7b5ddc1146dE", scope: !122, file: !121, line: 476, type: !413, scopeLine: 476, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !421, retainedNodes: !419)
!413 = !DISubroutineType(types: !414)
!414 = !{!415, !415}
!415 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&typegate_demo::Cipher", baseType: !416, size: 64, align: 64, dwarfAddressSpace: 0)
!416 = !DICompositeType(tag: DW_TAG_structure_type, name: "Cipher", scope: !394, file: !2, size: 64, align: 64, flags: DIFlagPublic, elements: !417, templateParams: !23, identifier: "6ae86d2e299e8709c0db07cf7bf426d6")
!417 = !{!418}
!418 = !DIDerivedType(tag: DW_TAG_member, name: "secret", scope: !416, file: !2, baseType: !210, size: 64, align: 64, flags: DIFlagPublic)
!419 = !{!420}
!420 = !DILocalVariable(name: "dummy", arg: 1, scope: !412, file: !121, line: 476, type: !415)
!421 = !{!422}
!422 = !DITemplateTypeParameter(name: "T", type: !415)
!423 = !DILocation(line: 476, column: 27, scope: !412)
!424 = !DILocation(line: 477, column: 5, scope: !412)
!425 = !DILocation(line: 478, column: 2, scope: !412)
!426 = distinct !DISubprogram(name: "black_box<&typegate_demo::Ctx>", linkageName: "_ZN4core4hint9black_box17hd2d598ead3f74f17E", scope: !122, file: !121, line: 476, type: !427, scopeLine: 476, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !436, retainedNodes: !434)
!427 = !DISubroutineType(types: !428)
!428 = !{!429, !429}
!429 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&typegate_demo::Ctx", baseType: !430, size: 64, align: 64, dwarfAddressSpace: 0)
!430 = !DICompositeType(tag: DW_TAG_structure_type, name: "Ctx", scope: !394, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !431, templateParams: !23, identifier: "bcd63c2e950b25abe8e543f42733f547")
!431 = !{!432, !433}
!432 = !DIDerivedType(tag: DW_TAG_member, name: "org", scope: !430, file: !2, baseType: !393, size: 64, align: 64, flags: DIFlagPublic)
!433 = !DIDerivedType(tag: DW_TAG_member, name: "cipher", scope: !430, file: !2, baseType: !416, size: 64, align: 64, offset: 64, flags: DIFlagPublic)
!434 = !{!435}
!435 = !DILocalVariable(name: "dummy", arg: 1, scope: !426, file: !121, line: 476, type: !429)
!436 = !{!437}
!437 = !DITemplateTypeParameter(name: "T", type: !429)
!438 = !DILocation(line: 476, column: 27, scope: !426)
!439 = !DILocation(line: 477, column: 5, scope: !426)
!440 = !DILocation(line: 478, column: 2, scope: !426)
!441 = distinct !DISubprogram(name: "report", linkageName: "_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17ha173b8a5cd1687e2E", scope: !442, file: !78, line: 2427, type: !443, scopeLine: 2427, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !23, retainedNodes: !445)
!442 = !DINamespace(name: "{impl#57}", scope: !80)
!443 = !DISubroutineType(types: !444)
!444 = !{!79, !7}
!445 = !{!446}
!446 = !DILocalVariable(arg: 1, scope: !441, file: !78, line: 2427, type: !7)
!447 = !DILocation(line: 2427, column: 15, scope: !441)
!448 = !DILocation(line: 2429, column: 6, scope: !441)
!449 = distinct !DISubprogram(name: "authorize", linkageName: "_ZN13typegate_demo9authorize17h92f2dc252dceb235E", scope: !394, file: !450, line: 26, type: !451, scopeLine: 26, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !23, retainedNodes: !454)
!450 = !DIFile(filename: "typegate_demo.rs", directory: "/Users/sanjib/codes/apace_lab/soap_afg_2026/repositories/AFG/afg_prototype/experiments/typegate-demo", checksumkind: CSK_MD5, checksum: "780c98304728ae1a153dfe63af974082")
!451 = !DISubroutineType(types: !452)
!452 = !{!453, !392}
!453 = !DIBasicType(name: "bool", size: 8, encoding: DW_ATE_boolean)
!454 = !{!455}
!455 = !DILocalVariable(name: "o", arg: 1, scope: !449, file: !450, line: 26, type: !392)
!456 = !DILocation(line: 26, column: 18, scope: !449)
!457 = !DILocation(line: 27, column: 5, scope: !449)
!458 = !DILocation(line: 28, column: 2, scope: !449)
!459 = distinct !DISubprogram(name: "read_cipher", linkageName: "_ZN13typegate_demo11read_cipher17h1974e6f8132e24d6E", scope: !394, file: !450, line: 31, type: !460, scopeLine: 31, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !23, retainedNodes: !462)
!460 = !DISubroutineType(types: !461)
!461 = !{!210, !415}
!462 = !{!463}
!463 = !DILocalVariable(name: "c", arg: 1, scope: !459, file: !450, line: 31, type: !415)
!464 = !DILocation(line: 31, column: 20, scope: !459)
!465 = !DILocation(line: 32, column: 5, scope: !459)
!466 = !DILocation(line: 33, column: 2, scope: !459)
!467 = distinct !DISubprogram(name: "handler", linkageName: "_ZN13typegate_demo7handler17hc0b034d9b0b14b6bE", scope: !394, file: !450, line: 38, type: !468, scopeLine: 38, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !23, retainedNodes: !470)
!468 = !DISubroutineType(types: !469)
!469 = !{!210, !429}
!470 = !{!471}
!471 = !DILocalVariable(name: "ctx", arg: 1, scope: !467, file: !450, line: 38, type: !429)
!472 = !DILocation(line: 38, column: 16, scope: !467)
!473 = !DILocation(line: 39, column: 8, scope: !467)
!474 = !DILocation(line: 42, column: 9, scope: !467)
!475 = !DILocation(line: 39, column: 5, scope: !467)
!476 = !DILocation(line: 40, column: 21, scope: !467)
!477 = !DILocation(line: 40, column: 9, scope: !467)
!478 = !DILocation(line: 44, column: 2, scope: !467)
!479 = distinct !DISubprogram(name: "main", linkageName: "_ZN13typegate_demo4main17h9908b2f4a824e68fE", scope: !394, file: !450, line: 46, type: !21, scopeLine: 46, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagMainSubprogram, unit: !29, templateParams: !23, retainedNodes: !480)
!480 = !{!481}
!481 = !DILocalVariable(name: "ctx", scope: !482, file: !450, line: 47, type: !430, align: 64)
!482 = distinct !DILexicalBlock(scope: !479, file: !450, line: 47, column: 5)
!483 = !DILocation(line: 47, column: 9, scope: !482)
!484 = !DILocation(line: 48, column: 24, scope: !479)
!485 = !DILocation(line: 49, column: 34, scope: !479)
!486 = !DILocation(line: 47, column: 15, scope: !479)
!487 = !DILocation(line: 51, column: 28, scope: !482)
!488 = !DILocation(line: 51, column: 20, scope: !482)
!489 = !DILocation(line: 51, column: 5, scope: !482)
!490 = !DILocation(line: 52, column: 2, scope: !479)
