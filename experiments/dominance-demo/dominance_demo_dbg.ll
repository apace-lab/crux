; ModuleID = 'dominance_demo.c1c20ed8f98c8587-cgu.0'
source_filename = "dominance_demo.c1c20ed8f98c8587-cgu.0"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx11.0.0"

%"core::fmt::rt::Argument<'_>" = type { %"core::fmt::rt::ArgumentType<'_>" }
%"core::fmt::rt::ArgumentType<'_>" = type { ptr, [1 x i64] }

@vtable.0 = private constant <{ [24 x i8], ptr, ptr, ptr }> <{ [24 x i8] c"\00\00\00\00\00\00\00\00\08\00\00\00\00\00\00\00\08\00\00\00\00\00\00\00", ptr @"_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h90313431f418f405E", ptr @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h090a705701f68211E", ptr @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h090a705701f68211E" }>, align 8, !dbg !0
@0 = private unnamed_addr constant <{ [8 x i8], [8 x i8] }> <{ [8 x i8] zeroinitializer, [8 x i8] undef }>, align 8
@alloc_49a1e817e911805af64bbc7efb390101 = private unnamed_addr constant <{ [1 x i8] }> <{ [1 x i8] c"\0A" }>, align 1
@alloc_9771be2481f51be410bd2ac520d18601 = private unnamed_addr constant <{ ptr, [8 x i8], ptr, [8 x i8] }> <{ ptr inttoptr (i64 1 to ptr), [8 x i8] zeroinitializer, ptr @alloc_49a1e817e911805af64bbc7efb390101, [8 x i8] c"\01\00\00\00\00\00\00\00" }>, align 8

; std::rt::lang_start
; Function Attrs: uwtable
define hidden i64 @_ZN3std2rt10lang_start17h44ba09a7e55f8370E(ptr %main, i64 %argc, ptr %argv, i8 %sigpipe) unnamed_addr #0 !dbg !45 {
start:
  %v.dbg.spill = alloca [8 x i8], align 8
  %sigpipe.dbg.spill = alloca [1 x i8], align 1
  %argv.dbg.spill = alloca [8 x i8], align 8
  %argc.dbg.spill = alloca [8 x i8], align 8
  %main.dbg.spill = alloca [8 x i8], align 8
  %_8 = alloca [8 x i8], align 8
  %_5 = alloca [8 x i8], align 8
  store ptr %main, ptr %main.dbg.spill, align 8
    #dbg_declare(ptr %main.dbg.spill, !53, !DIExpression(), !61)
  store i64 %argc, ptr %argc.dbg.spill, align 8
    #dbg_declare(ptr %argc.dbg.spill, !54, !DIExpression(), !62)
  store ptr %argv, ptr %argv.dbg.spill, align 8
    #dbg_declare(ptr %argv.dbg.spill, !55, !DIExpression(), !63)
  store i8 %sigpipe, ptr %sigpipe.dbg.spill, align 1
    #dbg_declare(ptr %sigpipe.dbg.spill, !56, !DIExpression(), !64)
  store ptr %main, ptr %_8, align 8, !dbg !65
; call std::rt::lang_start_internal
  %0 = call i64 @_ZN3std2rt19lang_start_internal17h5f91760815528aa2E(ptr align 1 %_8, ptr align 8 @vtable.0, i64 %argc, ptr %argv, i8 %sigpipe), !dbg !66
  store i64 %0, ptr %_5, align 8, !dbg !66
  %v = load i64, ptr %_5, align 8, !dbg !67
  store i64 %v, ptr %v.dbg.spill, align 8, !dbg !67
    #dbg_declare(ptr %v.dbg.spill, !57, !DIExpression(), !68)
  ret i64 %v, !dbg !69
}

; std::rt::lang_start::{{closure}}
; Function Attrs: inlinehint uwtable
define internal i32 @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h090a705701f68211E"(ptr align 8 %_1) unnamed_addr #1 !dbg !70 {
start:
  %self.dbg.spill = alloca [1 x i8], align 1
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !76, !DIExpression(DW_OP_deref), !77)
  %_4 = load ptr, ptr %_1, align 8, !dbg !78
; call std::sys::backtrace::__rust_begin_short_backtrace
  call void @_ZN3std3sys9backtrace28__rust_begin_short_backtrace17h4a4ac80fb1e07d16E(ptr %_4), !dbg !79
; call <() as std::process::Termination>::report
  %self = call i8 @"_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17h4a178751daf42e09E"(), !dbg !79
  store i8 %self, ptr %self.dbg.spill, align 1, !dbg !79
    #dbg_declare(ptr %self.dbg.spill, !80, !DIExpression(), !99)
  %_0 = zext i8 %self to i32, !dbg !101
  ret i32 %_0, !dbg !109
}

; std::sys::backtrace::__rust_begin_short_backtrace
; Function Attrs: noinline uwtable
define internal void @_ZN3std3sys9backtrace28__rust_begin_short_backtrace17h4a4ac80fb1e07d16E(ptr %f) unnamed_addr #2 !dbg !110 {
start:
  %dummy.dbg.spill = alloca [0 x i8], align 1
  %f.dbg.spill = alloca [8 x i8], align 8
  %result.dbg.spill = alloca [0 x i8], align 1
    #dbg_declare(ptr %result.dbg.spill, !117, !DIExpression(), !121)
  store ptr %f, ptr %f.dbg.spill, align 8
    #dbg_declare(ptr %f.dbg.spill, !116, !DIExpression(), !122)
    #dbg_declare(ptr %dummy.dbg.spill, !123, !DIExpression(), !130)
; call core::ops::function::FnOnce::call_once
  call void @_ZN4core3ops8function6FnOnce9call_once17hb6956567cff0305aE(ptr %f), !dbg !132
  call void asm sideeffect "", "~{memory}"(), !dbg !133, !srcloc !134
  ret void, !dbg !135
}

; core::fmt::rt::Argument::new_display
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3fmt2rt8Argument11new_display17h886ee6e4258d90c7E(ptr sret([16 x i8]) align 8 %_0, ptr align 8 %x) unnamed_addr #1 !dbg !136 {
start:
  %x.dbg.spill = alloca [8 x i8], align 8
  store ptr %x, ptr %x.dbg.spill, align 8
    #dbg_declare(ptr %x.dbg.spill, !245, !DIExpression(), !246)
; call core::fmt::rt::Argument::new
  call void @_ZN4core3fmt2rt8Argument3new17hcad4fb8a87d49b5cE(ptr sret([16 x i8]) align 8 %_0, ptr align 8 %x, ptr @"_ZN4core3fmt3num3imp52_$LT$impl$u20$core..fmt..Display$u20$for$u20$u64$GT$3fmt17hf38c5fc9304f84d8E"), !dbg !247
  ret void, !dbg !248
}

; core::fmt::rt::Argument::new
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3fmt2rt8Argument3new17hcad4fb8a87d49b5cE(ptr sret([16 x i8]) align 8 %_0, ptr align 8 %x, ptr %f) unnamed_addr #1 !dbg !249 {
start:
  %f.dbg.spill = alloca [8 x i8], align 8
  %x.dbg.spill = alloca [8 x i8], align 8
  %_3 = alloca [16 x i8], align 8
  store ptr %x, ptr %x.dbg.spill, align 8
    #dbg_declare(ptr %x.dbg.spill, !257, !DIExpression(), !259)
    #dbg_declare(ptr %x.dbg.spill, !260, !DIExpression(), !271)
    #dbg_declare(ptr %x.dbg.spill, !273, !DIExpression(), !277)
  store ptr %f, ptr %f.dbg.spill, align 8
    #dbg_declare(ptr %f.dbg.spill, !258, !DIExpression(), !279)
  store ptr %x, ptr %_3, align 8, !dbg !280
  %0 = getelementptr inbounds i8, ptr %_3, i64 8, !dbg !280
  store ptr %f, ptr %0, align 8, !dbg !280
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_0, ptr align 8 %_3, i64 16, i1 false), !dbg !281
  ret void, !dbg !282
}

; core::fmt::Arguments::new_v1
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3fmt9Arguments6new_v117h7d764aeb42f66c7fE(ptr sret([48 x i8]) align 8 %_0, ptr align 8 %pieces, ptr align 8 %args) unnamed_addr #1 !dbg !283 {
start:
  %args.dbg.spill = alloca [8 x i8], align 8
  %pieces.dbg.spill = alloca [8 x i8], align 8
  store ptr %pieces, ptr %pieces.dbg.spill, align 8
    #dbg_declare(ptr %pieces.dbg.spill, !358, !DIExpression(), !360)
  store ptr %args, ptr %args.dbg.spill, align 8
    #dbg_declare(ptr %args.dbg.spill, !359, !DIExpression(), !361)
  store ptr %pieces, ptr %_0, align 8, !dbg !362
  %0 = getelementptr inbounds i8, ptr %_0, i64 8, !dbg !362
  store i64 2, ptr %0, align 8, !dbg !362
  %1 = load ptr, ptr @0, align 8, !dbg !362
  %2 = load i64, ptr getelementptr inbounds (i8, ptr @0, i64 8), align 8, !dbg !362
  %3 = getelementptr inbounds i8, ptr %_0, i64 32, !dbg !362
  store ptr %1, ptr %3, align 8, !dbg !362
  %4 = getelementptr inbounds i8, ptr %3, i64 8, !dbg !362
  store i64 %2, ptr %4, align 8, !dbg !362
  %5 = getelementptr inbounds i8, ptr %_0, i64 16, !dbg !362
  store ptr %args, ptr %5, align 8, !dbg !362
  %6 = getelementptr inbounds i8, ptr %5, i64 8, !dbg !362
  store i64 1, ptr %6, align 8, !dbg !362
  ret void, !dbg !363
}

; core::ops::function::FnOnce::call_once{{vtable.shim}}
; Function Attrs: inlinehint uwtable
define internal i32 @"_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h90313431f418f405E"(ptr %_1) unnamed_addr #1 !dbg !364 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  %_2 = alloca [0 x i8], align 1
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !373, !DIExpression(), !378)
    #dbg_declare(ptr %_2, !374, !DIExpression(), !378)
  %0 = load ptr, ptr %_1, align 8, !dbg !378
; call core::ops::function::FnOnce::call_once
  %_0 = call i32 @_ZN4core3ops8function6FnOnce9call_once17h0b121461d8910734E(ptr %0), !dbg !378
  ret i32 %_0, !dbg !378
}

; core::ops::function::FnOnce::call_once
; Function Attrs: inlinehint uwtable
define internal i32 @_ZN4core3ops8function6FnOnce9call_once17h0b121461d8910734E(ptr %0) unnamed_addr #1 personality ptr @rust_eh_personality !dbg !379 {
start:
  %1 = alloca [16 x i8], align 8
  %_2 = alloca [0 x i8], align 1
  %_1 = alloca [8 x i8], align 8
  store ptr %0, ptr %_1, align 8
    #dbg_declare(ptr %_1, !383, !DIExpression(), !385)
    #dbg_declare(ptr %_2, !384, !DIExpression(), !385)
; invoke std::rt::lang_start::{{closure}}
  %_0 = invoke i32 @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h090a705701f68211E"(ptr align 8 %_1)
          to label %bb1 unwind label %cleanup, !dbg !385

bb3:                                              ; preds = %cleanup
  %2 = load ptr, ptr %1, align 8, !dbg !385
  %3 = getelementptr inbounds i8, ptr %1, i64 8, !dbg !385
  %4 = load i32, ptr %3, align 8, !dbg !385
  %5 = insertvalue { ptr, i32 } poison, ptr %2, 0, !dbg !385
  %6 = insertvalue { ptr, i32 } %5, i32 %4, 1, !dbg !385
  resume { ptr, i32 } %6, !dbg !385

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
  ret i32 %_0, !dbg !385
}

; core::ops::function::FnOnce::call_once
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3ops8function6FnOnce9call_once17hb6956567cff0305aE(ptr %_1) unnamed_addr #1 !dbg !386 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  %_2 = alloca [0 x i8], align 1
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !388, !DIExpression(), !392)
    #dbg_declare(ptr %_2, !389, !DIExpression(), !392)
  call void %_1(), !dbg !392
  ret void, !dbg !392
}

; core::ptr::drop_in_place<std::rt::lang_start<()>::{{closure}}>
; Function Attrs: inlinehint uwtable
define internal void @"_ZN4core3ptr85drop_in_place$LT$std..rt..lang_start$LT$$LP$$RP$$GT$..$u7b$$u7b$closure$u7d$$u7d$$GT$17h60c9aa0d2f0851d5E"(ptr align 8 %_1) unnamed_addr #1 !dbg !393 {
start:
  %_1.dbg.spill = alloca [8 x i8], align 8
  store ptr %_1, ptr %_1.dbg.spill, align 8
    #dbg_declare(ptr %_1.dbg.spill, !398, !DIExpression(), !401)
  ret void, !dbg !401
}

; core::hint::black_box
; Function Attrs: inlinehint uwtable
define internal i64 @_ZN4core4hint9black_box17h1d4404d5b13d5cedE(i64 %dummy) unnamed_addr #1 !dbg !402 {
start:
  %0 = alloca [8 x i8], align 8
  %dummy.dbg.spill = alloca [8 x i8], align 8
  store i64 %dummy, ptr %dummy.dbg.spill, align 8
    #dbg_declare(ptr %dummy.dbg.spill, !406, !DIExpression(), !407)
  store i64 %dummy, ptr %0, align 8, !dbg !408
  call void asm sideeffect "", "r,~{memory}"(ptr %0), !dbg !408, !srcloc !134
  %_0 = load i64, ptr %0, align 8, !dbg !408
  ret i64 %_0, !dbg !409
}

; <() as std::process::Termination>::report
; Function Attrs: inlinehint uwtable
define internal i8 @"_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17h4a178751daf42e09E"() unnamed_addr #1 !dbg !410 {
start:
  %_1.dbg.spill = alloca [0 x i8], align 1
    #dbg_declare(ptr %_1.dbg.spill, !415, !DIExpression(), !416)
  ret i8 0, !dbg !417
}

; dominance_demo::authorize
; Function Attrs: noinline uwtable
define internal zeroext i1 @_ZN14dominance_demo9authorize17h6e1015dd745dd6e2E(ptr align 8 %r) unnamed_addr #2 !dbg !418 {
start:
  %r.dbg.spill = alloca [8 x i8], align 8
  store ptr %r, ptr %r.dbg.spill, align 8
    #dbg_declare(ptr %r.dbg.spill, !430, !DIExpression(), !431)
  %_3 = load i64, ptr %r, align 8, !dbg !432
; call core::hint::black_box
  %_2 = call i64 @_ZN4core4hint9black_box17h1d4404d5b13d5cedE(i64 %_3), !dbg !433
  %_0 = icmp ne i64 %_2, 0, !dbg !433
  ret i1 %_0, !dbg !434
}

; dominance_demo::db_read
; Function Attrs: noinline uwtable
define internal i64 @_ZN14dominance_demo7db_read17he1aaae39845a1444E(ptr align 8 %r) unnamed_addr #2 !dbg !435 {
start:
  %r.dbg.spill = alloca [8 x i8], align 8
  store ptr %r, ptr %r.dbg.spill, align 8
    #dbg_declare(ptr %r.dbg.spill, !439, !DIExpression(), !440)
  %0 = getelementptr inbounds i8, ptr %r, i64 8, !dbg !441
  %_2 = load i64, ptr %0, align 8, !dbg !441
; call core::hint::black_box
  %_0 = call i64 @_ZN4core4hint9black_box17h1d4404d5b13d5cedE(i64 %_2), !dbg !442
  ret i64 %_0, !dbg !443
}

; dominance_demo::guarded
; Function Attrs: noinline uwtable
define internal i64 @_ZN14dominance_demo7guarded17h3c30c3bfdea5169fE(ptr align 8 %r) unnamed_addr #2 !dbg !444 {
start:
  %r.dbg.spill = alloca [8 x i8], align 8
  %_0 = alloca [8 x i8], align 8
  store ptr %r, ptr %r.dbg.spill, align 8
    #dbg_declare(ptr %r.dbg.spill, !446, !DIExpression(), !447)
; call dominance_demo::authorize
  %_2 = call zeroext i1 @_ZN14dominance_demo9authorize17h6e1015dd745dd6e2E(ptr align 8 %r), !dbg !448
  br i1 %_2, label %bb2, label %bb3, !dbg !448

bb3:                                              ; preds = %start
  store i64 0, ptr %_0, align 8, !dbg !449
  br label %bb4, !dbg !450

bb2:                                              ; preds = %start
; call dominance_demo::db_read
  %0 = call i64 @_ZN14dominance_demo7db_read17he1aaae39845a1444E(ptr align 8 %r), !dbg !451
  store i64 %0, ptr %_0, align 8, !dbg !451
  br label %bb4, !dbg !451

bb4:                                              ; preds = %bb2, %bb3
  %1 = load i64, ptr %_0, align 8, !dbg !452
  ret i64 %1, !dbg !452
}

; dominance_demo::unguarded
; Function Attrs: noinline uwtable
define internal i64 @_ZN14dominance_demo9unguarded17h55eba95306b1291aE(ptr align 8 %r) unnamed_addr #2 !dbg !453 {
start:
  %r.dbg.spill = alloca [8 x i8], align 8
  store ptr %r, ptr %r.dbg.spill, align 8
    #dbg_declare(ptr %r.dbg.spill, !455, !DIExpression(), !456)
; call dominance_demo::db_read
  %_0 = call i64 @_ZN14dominance_demo7db_read17he1aaae39845a1444E(ptr align 8 %r), !dbg !457
  ret i64 %_0, !dbg !458
}

; dominance_demo::wrong_resource
; Function Attrs: noinline uwtable
define internal i64 @_ZN14dominance_demo14wrong_resource17h48098f4b325a2289E(ptr align 8 %auth_res, ptr align 8 %data_res) unnamed_addr #2 !dbg !459 {
start:
  %data_res.dbg.spill = alloca [8 x i8], align 8
  %auth_res.dbg.spill = alloca [8 x i8], align 8
  %_0 = alloca [8 x i8], align 8
  store ptr %auth_res, ptr %auth_res.dbg.spill, align 8
    #dbg_declare(ptr %auth_res.dbg.spill, !463, !DIExpression(), !465)
  store ptr %data_res, ptr %data_res.dbg.spill, align 8
    #dbg_declare(ptr %data_res.dbg.spill, !464, !DIExpression(), !466)
; call dominance_demo::authorize
  %_3 = call zeroext i1 @_ZN14dominance_demo9authorize17h6e1015dd745dd6e2E(ptr align 8 %auth_res), !dbg !467
  br i1 %_3, label %bb2, label %bb3, !dbg !467

bb3:                                              ; preds = %start
  store i64 0, ptr %_0, align 8, !dbg !468
  br label %bb4, !dbg !469

bb2:                                              ; preds = %start
; call dominance_demo::db_read
  %0 = call i64 @_ZN14dominance_demo7db_read17he1aaae39845a1444E(ptr align 8 %data_res), !dbg !470
  store i64 %0, ptr %_0, align 8, !dbg !470
  br label %bb4, !dbg !470

bb4:                                              ; preds = %bb2, %bb3
  %1 = load i64, ptr %_0, align 8, !dbg !471
  ret i64 %1, !dbg !471
}

; dominance_demo::main
; Function Attrs: uwtable
define internal void @_ZN14dominance_demo4main17ha21bbafcd7919246E() unnamed_addr #0 !dbg !472 {
start:
  %rhs.dbg.spill.i4 = alloca [8 x i8], align 8
  %self.dbg.spill.i5 = alloca [8 x i8], align 8
  %rhs.dbg.spill.i1 = alloca [8 x i8], align 8
  %self.dbg.spill.i2 = alloca [8 x i8], align 8
  %rhs.dbg.spill.i = alloca [8 x i8], align 8
  %self.dbg.spill.i = alloca [8 x i8], align 8
  %_26 = alloca [8 x i8], align 8
  %_24 = alloca [16 x i8], align 8
  %_23 = alloca [16 x i8], align 8
  %_20 = alloca [48 x i8], align 8
  %acc = alloca [8 x i8], align 8
  %d = alloca [16 x i8], align 8
  %c = alloca [16 x i8], align 8
  %b = alloca [16 x i8], align 8
  %a = alloca [16 x i8], align 8
    #dbg_declare(ptr %a, !474, !DIExpression(), !484)
    #dbg_declare(ptr %b, !476, !DIExpression(), !485)
    #dbg_declare(ptr %c, !478, !DIExpression(), !486)
    #dbg_declare(ptr %d, !480, !DIExpression(), !487)
    #dbg_declare(ptr %acc, !482, !DIExpression(), !488)
  store i64 1, ptr %a, align 8, !dbg !489
  %0 = getelementptr inbounds i8, ptr %a, i64 8, !dbg !489
  store i64 100, ptr %0, align 8, !dbg !489
  store i64 2, ptr %b, align 8, !dbg !490
  %1 = getelementptr inbounds i8, ptr %b, i64 8, !dbg !490
  store i64 200, ptr %1, align 8, !dbg !490
  store i64 3, ptr %c, align 8, !dbg !491
  %2 = getelementptr inbounds i8, ptr %c, i64 8, !dbg !491
  store i64 300, ptr %2, align 8, !dbg !491
  store i64 4, ptr %d, align 8, !dbg !492
  %3 = getelementptr inbounds i8, ptr %d, i64 8, !dbg !492
  store i64 400, ptr %3, align 8, !dbg !492
  store i64 0, ptr %acc, align 8, !dbg !493
  %_7 = load i64, ptr %acc, align 8, !dbg !494
; call dominance_demo::guarded
  %_8 = call i64 @_ZN14dominance_demo7guarded17h3c30c3bfdea5169fE(ptr align 8 %a), !dbg !495
  store i64 %_7, ptr %self.dbg.spill.i5, align 8
    #dbg_declare(ptr %self.dbg.spill.i5, !496, !DIExpression(), !505)
  store i64 %_8, ptr %rhs.dbg.spill.i4, align 8
    #dbg_declare(ptr %rhs.dbg.spill.i4, !504, !DIExpression(), !507)
  %_0.i6 = add i64 %_7, %_8, !dbg !508
  store i64 %_0.i6, ptr %acc, align 8, !dbg !509
  %_11 = load i64, ptr %acc, align 8, !dbg !510
; call dominance_demo::unguarded
  %_12 = call i64 @_ZN14dominance_demo9unguarded17h55eba95306b1291aE(ptr align 8 %b), !dbg !511
  store i64 %_11, ptr %self.dbg.spill.i2, align 8
    #dbg_declare(ptr %self.dbg.spill.i2, !496, !DIExpression(), !512)
  store i64 %_12, ptr %rhs.dbg.spill.i1, align 8
    #dbg_declare(ptr %rhs.dbg.spill.i1, !504, !DIExpression(), !514)
  %_0.i3 = add i64 %_11, %_12, !dbg !515
  store i64 %_0.i3, ptr %acc, align 8, !dbg !516
  %_15 = load i64, ptr %acc, align 8, !dbg !517
; call dominance_demo::wrong_resource
  %_16 = call i64 @_ZN14dominance_demo14wrong_resource17h48098f4b325a2289E(ptr align 8 %c, ptr align 8 %d), !dbg !518
  store i64 %_15, ptr %self.dbg.spill.i, align 8
    #dbg_declare(ptr %self.dbg.spill.i, !496, !DIExpression(), !519)
  store i64 %_16, ptr %rhs.dbg.spill.i, align 8
    #dbg_declare(ptr %rhs.dbg.spill.i, !504, !DIExpression(), !521)
  %_0.i = add i64 %_15, %_16, !dbg !522
  store i64 %_0.i, ptr %acc, align 8, !dbg !523
  %_27 = load i64, ptr %acc, align 8, !dbg !524
; call core::hint::black_box
  %4 = call i64 @_ZN4core4hint9black_box17h1d4404d5b13d5cedE(i64 %_27), !dbg !525
  store i64 %4, ptr %_26, align 8, !dbg !525
; call core::fmt::rt::Argument::new_display
  call void @_ZN4core3fmt2rt8Argument11new_display17h886ee6e4258d90c7E(ptr sret([16 x i8]) align 8 %_24, ptr align 8 %_26), !dbg !526
  %5 = getelementptr inbounds %"core::fmt::rt::Argument<'_>", ptr %_23, i64 0, !dbg !526
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %5, ptr align 8 %_24, i64 16, i1 false), !dbg !526
; call core::fmt::Arguments::new_v1
  call void @_ZN4core3fmt9Arguments6new_v117h7d764aeb42f66c7fE(ptr sret([48 x i8]) align 8 %_20, ptr align 8 @alloc_9771be2481f51be410bd2ac520d18601, ptr align 8 %_23), !dbg !526
; call std::io::stdio::_print
  call void @_ZN3std2io5stdio6_print17h91e586dc5ea11662E(ptr align 8 %_20), !dbg !526
  ret void, !dbg !527
}

; std::rt::lang_start_internal
; Function Attrs: uwtable
declare i64 @_ZN3std2rt19lang_start_internal17h5f91760815528aa2E(ptr align 1, ptr align 8, i64, ptr, i8) unnamed_addr #0

; core::fmt::num::imp::<impl core::fmt::Display for u64>::fmt
; Function Attrs: uwtable
declare zeroext i1 @"_ZN4core3fmt3num3imp52_$LT$impl$u20$core..fmt..Display$u20$for$u20$u64$GT$3fmt17hf38c5fc9304f84d8E"(ptr align 8, ptr align 8) unnamed_addr #0

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #3

; Function Attrs: nounwind uwtable
declare i32 @rust_eh_personality(i32, i32, i64, ptr, ptr) unnamed_addr #4

; std::io::stdio::_print
; Function Attrs: uwtable
declare void @_ZN3std2io5stdio6_print17h91e586dc5ea11662E(ptr align 8) unnamed_addr #0

define i32 @main(i32 %0, ptr %1) unnamed_addr #5 {
top:
  %2 = sext i32 %0 to i64
; call std::rt::lang_start
  %3 = call i64 @_ZN3std2rt10lang_start17h44ba09a7e55f8370E(ptr @_ZN14dominance_demo4main17ha21bbafcd7919246E, i64 %2, ptr %1, i8 0)
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
!3 = !DICompositeType(tag: DW_TAG_structure_type, name: "<std::rt::lang_start::{closure_env#0}<()> as core::ops::function::Fn<()>>::{vtable_type}", file: !2, size: 384, align: 64, flags: DIFlagArtificial, elements: !4, vtableHolder: !14, templateParams: !23, identifier: "399b7e8fbba358ba1b2e33873a38ee91")
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
!14 = !DICompositeType(tag: DW_TAG_structure_type, name: "{closure_env#0}<()>", scope: !15, file: !2, size: 64, align: 64, elements: !18, templateParams: !23, identifier: "2566e0276c222e6aa209055f0ee30460")
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
!26 = !{i32 2, !"Dwarf Version", i32 4}
!27 = !{i32 2, !"Debug Info Version", i32 3}
!28 = !{!"rustc version 1.85.0 (4d91de4e4 2025-02-17)"}
!29 = distinct !DICompileUnit(language: DW_LANG_Rust, file: !30, producer: "clang LLVM (rustc version 1.85.0 (4d91de4e4 2025-02-17))", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !31, globals: !44, splitDebugInlining: false, nameTableKind: None)
!30 = !DIFile(filename: "dominance_demo.rs/@/dominance_demo.c1c20ed8f98c8587-cgu.0", directory: "/private/tmp/claude-501/-Users-sanjib-codes-apace-lab-lima-repositories/4bc88783-f66f-4021-9d50-0df96e2f0ba6/scratchpad")
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
!45 = distinct !DISubprogram(name: "lang_start<()>", linkageName: "_ZN3std2rt10lang_start17h44ba09a7e55f8370E", scope: !16, file: !46, line: 188, type: !47, scopeLine: 188, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !59, retainedNodes: !52)
!46 = !DIFile(filename: "/rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688/library/std/src/rt.rs", directory: "", checksumkind: CSK_MD5, checksum: "1f3acc0374c7f5dba2b7965889da591f")
!47 = !DISubroutineType(types: !48)
!48 = !{!49, !20, !49, !50, !35}
!49 = !DIBasicType(name: "isize", size: 64, encoding: DW_ATE_signed)
!50 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*const *const u8", baseType: !51, size: 64, align: 64, dwarfAddressSpace: 0)
!51 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*const u8", baseType: !35, size: 64, align: 64, dwarfAddressSpace: 0)
!52 = !{!53, !54, !55, !56, !57}
!53 = !DILocalVariable(name: "main", arg: 1, scope: !45, file: !46, line: 189, type: !20)
!54 = !DILocalVariable(name: "argc", arg: 2, scope: !45, file: !46, line: 190, type: !49)
!55 = !DILocalVariable(name: "argv", arg: 3, scope: !45, file: !46, line: 191, type: !50)
!56 = !DILocalVariable(name: "sigpipe", arg: 4, scope: !45, file: !46, line: 192, type: !35)
!57 = !DILocalVariable(name: "v", scope: !58, file: !46, line: 194, type: !49, align: 8)
!58 = distinct !DILexicalBlock(scope: !45, file: !46, line: 194, column: 5)
!59 = !{!60}
!60 = !DITemplateTypeParameter(name: "T", type: !7)
!61 = !DILocation(line: 189, column: 5, scope: !45)
!62 = !DILocation(line: 190, column: 5, scope: !45)
!63 = !DILocation(line: 191, column: 5, scope: !45)
!64 = !DILocation(line: 192, column: 5, scope: !45)
!65 = !DILocation(line: 195, column: 10, scope: !45)
!66 = !DILocation(line: 194, column: 17, scope: !45)
!67 = !DILocation(line: 194, column: 12, scope: !45)
!68 = !DILocation(line: 194, column: 12, scope: !58)
!69 = !DILocation(line: 201, column: 2, scope: !45)
!70 = distinct !DISubprogram(name: "{closure#0}<()>", linkageName: "_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h090a705701f68211E", scope: !15, file: !46, line: 195, type: !71, scopeLine: 195, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !59, retainedNodes: !75)
!71 = !DISubroutineType(types: !72)
!72 = !{!73, !74}
!73 = !DIBasicType(name: "i32", size: 32, encoding: DW_ATE_signed)
!74 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&std::rt::lang_start::{closure_env#0}<()>", baseType: !14, size: 64, align: 64, dwarfAddressSpace: 0)
!75 = !{!76}
!76 = !DILocalVariable(name: "main", scope: !70, file: !46, line: 189, type: !20, align: 8)
!77 = !DILocation(line: 189, column: 5, scope: !70)
!78 = !DILocation(line: 195, column: 70, scope: !70)
!79 = !DILocation(line: 195, column: 18, scope: !70)
!80 = !DILocalVariable(name: "self", arg: 1, scope: !81, file: !82, line: 2052, type: !83)
!81 = distinct !DISubprogram(name: "to_i32", linkageName: "_ZN3std7process8ExitCode6to_i3217h76ef7e8199127793E", scope: !83, file: !82, line: 2052, type: !95, scopeLine: 2052, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !23, declaration: !97, retainedNodes: !98)
!82 = !DIFile(filename: "/rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688/library/std/src/process.rs", directory: "", checksumkind: CSK_MD5, checksum: "fc26264ad5c7a2e8bfbec28c5bdc726f")
!83 = !DICompositeType(tag: DW_TAG_structure_type, name: "ExitCode", scope: !84, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !85, templateParams: !23, identifier: "d5ac2f3c8763905eb14728d92a362260")
!84 = !DINamespace(name: "process", scope: !17)
!85 = !{!86}
!86 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !83, file: !2, baseType: !87, size: 8, align: 8, flags: DIFlagPrivate)
!87 = !DICompositeType(tag: DW_TAG_structure_type, name: "ExitCode", scope: !88, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !93, templateParams: !23, identifier: "3b79588209b6dd92b71a29e19a3df783")
!88 = !DINamespace(name: "process_common", scope: !89)
!89 = !DINamespace(name: "process", scope: !90)
!90 = !DINamespace(name: "unix", scope: !91)
!91 = !DINamespace(name: "pal", scope: !92)
!92 = !DINamespace(name: "sys", scope: !17)
!93 = !{!94}
!94 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !87, file: !2, baseType: !35, size: 8, align: 8, flags: DIFlagPrivate)
!95 = !DISubroutineType(types: !96)
!96 = !{!73, !83}
!97 = !DISubprogram(name: "to_i32", linkageName: "_ZN3std7process8ExitCode6to_i3217h76ef7e8199127793E", scope: !83, file: !82, line: 2052, type: !95, scopeLine: 2052, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!98 = !{!80}
!99 = !DILocation(line: 2052, column: 19, scope: !81, inlinedAt: !100)
!100 = !DILocation(line: 195, column: 85, scope: !70)
!101 = !DILocation(line: 636, column: 9, scope: !102, inlinedAt: !108)
!102 = distinct !DISubprogram(name: "as_i32", linkageName: "_ZN3std3sys3pal4unix7process14process_common8ExitCode6as_i3217hb0b8f84b3f790179E", scope: !87, file: !103, line: 635, type: !104, scopeLine: 635, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !23, declaration: !107)
!103 = !DIFile(filename: "/rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688/library/std/src/sys/pal/unix/process/process_common.rs", directory: "", checksumkind: CSK_MD5, checksum: "7107dec5baaefd58adc486b058fd5a71")
!104 = !DISubroutineType(types: !105)
!105 = !{!73, !106}
!106 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&std::sys::pal::unix::process::process_common::ExitCode", baseType: !87, size: 64, align: 64, dwarfAddressSpace: 0)
!107 = !DISubprogram(name: "as_i32", linkageName: "_ZN3std3sys3pal4unix7process14process_common8ExitCode6as_i3217hb0b8f84b3f790179E", scope: !87, file: !103, line: 635, type: !104, scopeLine: 635, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!108 = !DILocation(line: 2053, column: 16, scope: !81, inlinedAt: !100)
!109 = !DILocation(line: 195, column: 93, scope: !70)
!110 = distinct !DISubprogram(name: "__rust_begin_short_backtrace<fn(), ()>", linkageName: "_ZN3std3sys9backtrace28__rust_begin_short_backtrace17h4a4ac80fb1e07d16E", scope: !112, file: !111, line: 148, type: !113, scopeLine: 148, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !119, retainedNodes: !115)
!111 = !DIFile(filename: "/rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688/library/std/src/sys/backtrace.rs", directory: "", checksumkind: CSK_MD5, checksum: "9e30c70624c3cf40238860e740bd696f")
!112 = !DINamespace(name: "backtrace", scope: !92)
!113 = !DISubroutineType(types: !114)
!114 = !{null, !20}
!115 = !{!116, !117}
!116 = !DILocalVariable(name: "f", arg: 1, scope: !110, file: !111, line: 148, type: !20)
!117 = !DILocalVariable(name: "result", scope: !118, file: !111, line: 152, type: !7, align: 1)
!118 = distinct !DILexicalBlock(scope: !110, file: !111, line: 152, column: 5)
!119 = !{!120, !60}
!120 = !DITemplateTypeParameter(name: "F", type: !20)
!121 = !DILocation(line: 152, column: 9, scope: !118)
!122 = !DILocation(line: 148, column: 43, scope: !110)
!123 = !DILocalVariable(name: "dummy", scope: !124, file: !125, line: 474, type: !7, align: 1)
!124 = distinct !DISubprogram(name: "black_box<()>", linkageName: "_ZN4core4hint9black_box17hfed861b92992d21cE", scope: !126, file: !125, line: 474, type: !127, scopeLine: 474, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !59, retainedNodes: !129)
!125 = !DIFile(filename: "/rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688/library/core/src/hint.rs", directory: "", checksumkind: CSK_MD5, checksum: "74a4d757e2c25cd53bc30e9481332d4b")
!126 = !DINamespace(name: "hint", scope: !34)
!127 = !DISubroutineType(types: !128)
!128 = !{null, !7}
!129 = !{!123}
!130 = !DILocation(line: 474, column: 27, scope: !124, inlinedAt: !131)
!131 = !DILocation(line: 155, column: 5, scope: !118)
!132 = !DILocation(line: 152, column: 18, scope: !110)
!133 = !DILocation(line: 475, column: 5, scope: !124, inlinedAt: !131)
!134 = !{i64 4365933041648296}
!135 = !DILocation(line: 158, column: 2, scope: !110)
!136 = distinct !DISubprogram(name: "new_display<u64>", linkageName: "_ZN4core3fmt2rt8Argument11new_display17h886ee6e4258d90c7E", scope: !138, file: !137, line: 113, type: !238, scopeLine: 113, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !242, declaration: !241, retainedNodes: !244)
!137 = !DIFile(filename: "/rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688/library/core/src/fmt/rt.rs", directory: "", checksumkind: CSK_MD5, checksum: "bfb0c92e92ea1d9b7675e4ea04f7c60f")
!138 = !DICompositeType(tag: DW_TAG_structure_type, name: "Argument", scope: !41, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !139, templateParams: !23, identifier: "65de2e77012ce3d92d134d3cea412538")
!139 = !{!140}
!140 = !DIDerivedType(tag: DW_TAG_member, name: "ty", scope: !138, file: !2, baseType: !141, size: 128, align: 64, flags: DIFlagPrivate)
!141 = !DICompositeType(tag: DW_TAG_structure_type, name: "ArgumentType", scope: !41, file: !2, size: 128, align: 64, flags: DIFlagPrivate, elements: !142, templateParams: !23, identifier: "f05fbfee25867ee1bdce31b265c3f0d5")
!142 = !{!143}
!143 = !DICompositeType(tag: DW_TAG_variant_part, scope: !141, file: !2, size: 128, align: 64, elements: !144, templateParams: !23, identifier: "8386d2f00a66fa08380f64706b1e9027", discriminator: !237)
!144 = !{!145, !233}
!145 = !DIDerivedType(tag: DW_TAG_member, name: "Placeholder", scope: !143, file: !2, baseType: !146, size: 128, align: 64)
!146 = !DICompositeType(tag: DW_TAG_structure_type, name: "Placeholder", scope: !141, file: !2, size: 128, align: 64, flags: DIFlagPrivate, elements: !147, templateParams: !23, identifier: "c902823539d9be6abab954a1d4d1bf6e")
!147 = !{!148, !154, !227}
!148 = !DIDerivedType(tag: DW_TAG_member, name: "value", scope: !146, file: !2, baseType: !149, size: 64, align: 64, flags: DIFlagPrivate)
!149 = !DICompositeType(tag: DW_TAG_structure_type, name: "NonNull<()>", scope: !150, file: !2, size: 64, align: 64, flags: DIFlagPublic, elements: !152, templateParams: !59, identifier: "a338b653696a5675e987e28b5cd3a54e")
!150 = !DINamespace(name: "non_null", scope: !151)
!151 = !DINamespace(name: "ptr", scope: !34)
!152 = !{!153}
!153 = !DIDerivedType(tag: DW_TAG_member, name: "pointer", scope: !149, file: !2, baseType: !6, size: 64, align: 64, flags: DIFlagPrivate)
!154 = !DIDerivedType(tag: DW_TAG_member, name: "formatter", scope: !146, file: !2, baseType: !155, size: 64, align: 64, offset: 64, flags: DIFlagPrivate)
!155 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "unsafe fn(core::ptr::non_null::NonNull<()>, &mut core::fmt::Formatter) -> core::result::Result<(), core::fmt::Error>", baseType: !156, size: 64, align: 64, dwarfAddressSpace: 0)
!156 = !DISubroutineType(types: !157)
!157 = !{!158, !149, !175}
!158 = !DICompositeType(tag: DW_TAG_structure_type, name: "Result<(), core::fmt::Error>", scope: !159, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !160, templateParams: !23, identifier: "cd4e3c500ee523e1fa389583f88cabf3")
!159 = !DINamespace(name: "result", scope: !34)
!160 = !{!161}
!161 = !DICompositeType(tag: DW_TAG_variant_part, scope: !158, file: !2, size: 8, align: 8, elements: !162, templateParams: !23, identifier: "962593ae910cc4a5856c5e991598bf07", discriminator: !174)
!162 = !{!163, !170}
!163 = !DIDerivedType(tag: DW_TAG_member, name: "Ok", scope: !161, file: !2, baseType: !164, size: 8, align: 8, extraData: i128 0)
!164 = !DICompositeType(tag: DW_TAG_structure_type, name: "Ok", scope: !158, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !165, templateParams: !167, identifier: "c493614f204b640e16e9d9cac87d2c90")
!165 = !{!166}
!166 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !164, file: !2, baseType: !7, align: 8, offset: 8, flags: DIFlagPublic)
!167 = !{!60, !168}
!168 = !DITemplateTypeParameter(name: "E", type: !169)
!169 = !DICompositeType(tag: DW_TAG_structure_type, name: "Error", scope: !33, file: !2, align: 8, flags: DIFlagPublic, elements: !23, identifier: "725ee120683636dd241b146213dc58b9")
!170 = !DIDerivedType(tag: DW_TAG_member, name: "Err", scope: !161, file: !2, baseType: !171, size: 8, align: 8, extraData: i128 1)
!171 = !DICompositeType(tag: DW_TAG_structure_type, name: "Err", scope: !158, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !172, templateParams: !167, identifier: "1e8ced4f991a816bdbbf9cff05717a64")
!172 = !{!173}
!173 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !171, file: !2, baseType: !169, align: 8, offset: 8, flags: DIFlagPublic)
!174 = !DIDerivedType(tag: DW_TAG_member, scope: !158, file: !2, baseType: !35, size: 8, align: 8, flags: DIFlagArtificial)
!175 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&mut core::fmt::Formatter", baseType: !176, size: 64, align: 64, dwarfAddressSpace: 0)
!176 = !DICompositeType(tag: DW_TAG_structure_type, name: "Formatter", scope: !33, file: !2, size: 512, align: 64, flags: DIFlagPublic, elements: !177, templateParams: !23, identifier: "ed724e408517c0b1d389592502707b04")
!177 = !{!178, !216}
!178 = !DIDerivedType(tag: DW_TAG_member, name: "options", scope: !176, file: !2, baseType: !179, size: 384, align: 64, flags: DIFlagPrivate)
!179 = !DICompositeType(tag: DW_TAG_structure_type, name: "FormattingOptions", scope: !33, file: !2, size: 384, align: 64, flags: DIFlagPublic, elements: !180, templateParams: !23, identifier: "78f7d489797cf3005a81c516a5702bc7")
!180 = !{!181, !183, !185, !200, !215}
!181 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !179, file: !2, baseType: !182, size: 32, align: 32, offset: 288, flags: DIFlagPrivate)
!182 = !DIBasicType(name: "u32", size: 32, encoding: DW_ATE_unsigned)
!183 = !DIDerivedType(tag: DW_TAG_member, name: "fill", scope: !179, file: !2, baseType: !184, size: 32, align: 32, offset: 256, flags: DIFlagPrivate)
!184 = !DIBasicType(name: "char", size: 32, encoding: DW_ATE_UTF)
!185 = !DIDerivedType(tag: DW_TAG_member, name: "align", scope: !179, file: !2, baseType: !186, size: 8, align: 8, offset: 320, flags: DIFlagPrivate)
!186 = !DICompositeType(tag: DW_TAG_structure_type, name: "Option<core::fmt::Alignment>", scope: !187, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !188, templateParams: !23, identifier: "d01fc77ea546df1cafc16061ba8c795c")
!187 = !DINamespace(name: "option", scope: !34)
!188 = !{!189}
!189 = !DICompositeType(tag: DW_TAG_variant_part, scope: !186, file: !2, size: 8, align: 8, elements: !190, templateParams: !23, identifier: "11903227326f3956d00a5899a3922e3d", discriminator: !199)
!190 = !{!191, !195}
!191 = !DIDerivedType(tag: DW_TAG_member, name: "None", scope: !189, file: !2, baseType: !192, size: 8, align: 8, extraData: i128 3)
!192 = !DICompositeType(tag: DW_TAG_structure_type, name: "None", scope: !186, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !23, templateParams: !193, identifier: "1844ad98e406ac2c2c94a85711d8923b")
!193 = !{!194}
!194 = !DITemplateTypeParameter(name: "T", type: !32)
!195 = !DIDerivedType(tag: DW_TAG_member, name: "Some", scope: !189, file: !2, baseType: !196, size: 8, align: 8)
!196 = !DICompositeType(tag: DW_TAG_structure_type, name: "Some", scope: !186, file: !2, size: 8, align: 8, flags: DIFlagPublic, elements: !197, templateParams: !193, identifier: "f74431457d04433971574babfb42636d")
!197 = !{!198}
!198 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !196, file: !2, baseType: !32, size: 8, align: 8, flags: DIFlagPublic)
!199 = !DIDerivedType(tag: DW_TAG_member, scope: !186, file: !2, baseType: !35, size: 8, align: 8, flags: DIFlagArtificial)
!200 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !179, file: !2, baseType: !201, size: 128, align: 64, flags: DIFlagPrivate)
!201 = !DICompositeType(tag: DW_TAG_structure_type, name: "Option<usize>", scope: !187, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !202, templateParams: !23, identifier: "77a2b2245de265376f6fa660bd8684fb")
!202 = !{!203}
!203 = !DICompositeType(tag: DW_TAG_variant_part, scope: !201, file: !2, size: 128, align: 64, elements: !204, templateParams: !23, identifier: "e66b7a320ef07283e7fe8ea64044ff0a", discriminator: !213)
!204 = !{!205, !209}
!205 = !DIDerivedType(tag: DW_TAG_member, name: "None", scope: !203, file: !2, baseType: !206, size: 128, align: 64, extraData: i128 0)
!206 = !DICompositeType(tag: DW_TAG_structure_type, name: "None", scope: !201, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !23, templateParams: !207, identifier: "2a9681c83539a80f2d68147ff3586650")
!207 = !{!208}
!208 = !DITemplateTypeParameter(name: "T", type: !9)
!209 = !DIDerivedType(tag: DW_TAG_member, name: "Some", scope: !203, file: !2, baseType: !210, size: 128, align: 64, extraData: i128 1)
!210 = !DICompositeType(tag: DW_TAG_structure_type, name: "Some", scope: !201, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !211, templateParams: !207, identifier: "bd0b490c84300a4c43c488985ea76466")
!211 = !{!212}
!212 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !210, file: !2, baseType: !9, size: 64, align: 64, offset: 64, flags: DIFlagPublic)
!213 = !DIDerivedType(tag: DW_TAG_member, scope: !201, file: !2, baseType: !214, size: 64, align: 64, flags: DIFlagArtificial)
!214 = !DIBasicType(name: "u64", size: 64, encoding: DW_ATE_unsigned)
!215 = !DIDerivedType(tag: DW_TAG_member, name: "precision", scope: !179, file: !2, baseType: !201, size: 128, align: 64, offset: 128, flags: DIFlagPrivate)
!216 = !DIDerivedType(tag: DW_TAG_member, name: "buf", scope: !176, file: !2, baseType: !217, size: 128, align: 64, offset: 384, flags: DIFlagPrivate)
!217 = !DICompositeType(tag: DW_TAG_structure_type, name: "&mut dyn core::fmt::Write", file: !2, size: 128, align: 64, elements: !218, templateParams: !23, identifier: "2049da168fb5dabcd56da44a16c68579")
!218 = !{!219, !222}
!219 = !DIDerivedType(tag: DW_TAG_member, name: "pointer", scope: !217, file: !2, baseType: !220, size: 64, align: 64)
!220 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !221, size: 64, align: 64, dwarfAddressSpace: 0)
!221 = !DICompositeType(tag: DW_TAG_structure_type, name: "dyn core::fmt::Write", file: !2, align: 8, elements: !23, identifier: "7d86f99d9ce67f7c1c1961ccfdd83afa")
!222 = !DIDerivedType(tag: DW_TAG_member, name: "vtable", scope: !217, file: !2, baseType: !223, size: 64, align: 64, offset: 64)
!223 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&[usize; 6]", baseType: !224, size: 64, align: 64, dwarfAddressSpace: 0)
!224 = !DICompositeType(tag: DW_TAG_array_type, baseType: !9, size: 384, align: 64, elements: !225)
!225 = !{!226}
!226 = !DISubrange(count: 6, lowerBound: 0)
!227 = !DIDerivedType(tag: DW_TAG_member, name: "_lifetime", scope: !146, file: !2, baseType: !228, align: 8, offset: 128, flags: DIFlagPrivate)
!228 = !DICompositeType(tag: DW_TAG_structure_type, name: "PhantomData<&()>", scope: !229, file: !2, align: 8, flags: DIFlagPublic, elements: !23, templateParams: !230, identifier: "729902b8c9e515cdc101e1aff630f3ee")
!229 = !DINamespace(name: "marker", scope: !34)
!230 = !{!231}
!231 = !DITemplateTypeParameter(name: "T", type: !232)
!232 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&()", baseType: !7, size: 64, align: 64, dwarfAddressSpace: 0)
!233 = !DIDerivedType(tag: DW_TAG_member, name: "Count", scope: !143, file: !2, baseType: !234, size: 128, align: 64, extraData: i128 0)
!234 = !DICompositeType(tag: DW_TAG_structure_type, name: "Count", scope: !141, file: !2, size: 128, align: 64, flags: DIFlagPrivate, elements: !235, templateParams: !23, identifier: "62ebbcf7602669c37a51ac315a42b0ff")
!235 = !{!236}
!236 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !234, file: !2, baseType: !9, size: 64, align: 64, offset: 64, flags: DIFlagPrivate)
!237 = !DIDerivedType(tag: DW_TAG_member, scope: !141, file: !2, baseType: !214, size: 64, align: 64, flags: DIFlagArtificial)
!238 = !DISubroutineType(types: !239)
!239 = !{!138, !240}
!240 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&u64", baseType: !214, size: 64, align: 64, dwarfAddressSpace: 0)
!241 = !DISubprogram(name: "new_display<u64>", linkageName: "_ZN4core3fmt2rt8Argument11new_display17h886ee6e4258d90c7E", scope: !138, file: !137, line: 113, type: !238, scopeLine: 113, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !242)
!242 = !{!243}
!243 = !DITemplateTypeParameter(name: "T", type: !214)
!244 = !{!245}
!245 = !DILocalVariable(name: "x", arg: 1, scope: !136, file: !137, line: 113, type: !240)
!246 = !DILocation(line: 113, column: 36, scope: !136)
!247 = !DILocation(line: 114, column: 9, scope: !136)
!248 = !DILocation(line: 115, column: 6, scope: !136)
!249 = distinct !DISubprogram(name: "new<u64>", linkageName: "_ZN4core3fmt2rt8Argument3new17hcad4fb8a87d49b5cE", scope: !138, file: !137, line: 99, type: !250, scopeLine: 99, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !242, declaration: !255, retainedNodes: !256)
!250 = !DISubroutineType(types: !251)
!251 = !{!138, !240, !252}
!252 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "fn(&u64, &mut core::fmt::Formatter) -> core::result::Result<(), core::fmt::Error>", baseType: !253, size: 64, align: 64, dwarfAddressSpace: 0)
!253 = !DISubroutineType(types: !254)
!254 = !{!158, !240, !175}
!255 = !DISubprogram(name: "new<u64>", linkageName: "_ZN4core3fmt2rt8Argument3new17hcad4fb8a87d49b5cE", scope: !138, file: !137, line: 99, type: !250, scopeLine: 99, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !242)
!256 = !{!257, !258}
!257 = !DILocalVariable(name: "x", arg: 1, scope: !249, file: !137, line: 99, type: !240)
!258 = !DILocalVariable(name: "f", arg: 2, scope: !249, file: !137, line: 99, type: !252)
!259 = !DILocation(line: 99, column: 19, scope: !249)
!260 = !DILocalVariable(name: "r", arg: 1, scope: !261, file: !262, line: 1639, type: !240)
!261 = distinct !DISubprogram(name: "from<u64>", linkageName: "_ZN90_$LT$core..ptr..non_null..NonNull$LT$T$GT$$u20$as$u20$core..convert..From$LT$$RF$T$GT$$GT$4from17h7d21312df7a25b2eE", scope: !263, file: !262, line: 1639, type: !264, scopeLine: 1639, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !242, retainedNodes: !270)
!262 = !DIFile(filename: "/rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688/library/core/src/ptr/non_null.rs", directory: "", checksumkind: CSK_MD5, checksum: "f7ab22e7456fca593f8b8834ac6cab2f")
!263 = !DINamespace(name: "{impl#20}", scope: !150)
!264 = !DISubroutineType(types: !265)
!265 = !{!266, !240}
!266 = !DICompositeType(tag: DW_TAG_structure_type, name: "NonNull<u64>", scope: !150, file: !2, size: 64, align: 64, flags: DIFlagPublic, elements: !267, templateParams: !242, identifier: "9463586ba835c0db4fc896e54920f0a7")
!267 = !{!268}
!268 = !DIDerivedType(tag: DW_TAG_member, name: "pointer", scope: !266, file: !2, baseType: !269, size: 64, align: 64, flags: DIFlagPrivate)
!269 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*const u64", baseType: !214, size: 64, align: 64, dwarfAddressSpace: 0)
!270 = !{!260}
!271 = !DILocation(line: 1639, column: 13, scope: !261, inlinedAt: !272)
!272 = !DILocation(line: 104, column: 24, scope: !249)
!273 = !DILocalVariable(name: "r", arg: 1, scope: !274, file: !262, line: 241, type: !240)
!274 = distinct !DISubprogram(name: "from_ref<u64>", linkageName: "_ZN4core3ptr8non_null16NonNull$LT$T$GT$8from_ref17hbf892eaa3861c24eE", scope: !266, file: !262, line: 241, type: !264, scopeLine: 241, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !242, declaration: !275, retainedNodes: !276)
!275 = !DISubprogram(name: "from_ref<u64>", linkageName: "_ZN4core3ptr8non_null16NonNull$LT$T$GT$8from_ref17hbf892eaa3861c24eE", scope: !266, file: !262, line: 241, type: !264, scopeLine: 241, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !242)
!276 = !{!273}
!277 = !DILocation(line: 241, column: 27, scope: !274, inlinedAt: !278)
!278 = !DILocation(line: 1640, column: 9, scope: !261, inlinedAt: !272)
!279 = !DILocation(line: 99, column: 29, scope: !249)
!280 = !DILocation(line: 103, column: 17, scope: !249)
!281 = !DILocation(line: 100, column: 9, scope: !249)
!282 = !DILocation(line: 110, column: 6, scope: !249)
!283 = distinct !DISubprogram(name: "new_v1<2, 1>", linkageName: "_ZN4core3fmt9Arguments6new_v117h7d764aeb42f66c7fE", scope: !285, file: !284, line: 599, type: !346, scopeLine: 599, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !23, declaration: !356, retainedNodes: !357)
!284 = !DIFile(filename: "/rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688/library/core/src/fmt/mod.rs", directory: "", checksumkind: CSK_MD5, checksum: "c11a22e991b00fe7e2b5b5eee45fabb7")
!285 = !DICompositeType(tag: DW_TAG_structure_type, name: "Arguments", scope: !33, file: !2, size: 384, align: 64, flags: DIFlagPublic, elements: !286, templateParams: !23, identifier: "af592df6f1d2671e2a266da2f6e77acb")
!286 = !{!287, !298, !340}
!287 = !DIDerivedType(tag: DW_TAG_member, name: "pieces", scope: !285, file: !2, baseType: !288, size: 128, align: 64, flags: DIFlagPrivate)
!288 = !DICompositeType(tag: DW_TAG_structure_type, name: "&[&str]", file: !2, size: 128, align: 64, elements: !289, templateParams: !23, identifier: "4e66b00a376d6af5b8765440fb2839f")
!289 = !{!290, !297}
!290 = !DIDerivedType(tag: DW_TAG_member, name: "data_ptr", scope: !288, file: !2, baseType: !291, size: 64, align: 64)
!291 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !292, size: 64, align: 64, dwarfAddressSpace: 0)
!292 = !DICompositeType(tag: DW_TAG_structure_type, name: "&str", file: !2, size: 128, align: 64, elements: !293, templateParams: !23, identifier: "9277eecd40495f85161460476aacc992")
!293 = !{!294, !296}
!294 = !DIDerivedType(tag: DW_TAG_member, name: "data_ptr", scope: !292, file: !2, baseType: !295, size: 64, align: 64)
!295 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !35, size: 64, align: 64, dwarfAddressSpace: 0)
!296 = !DIDerivedType(tag: DW_TAG_member, name: "length", scope: !292, file: !2, baseType: !9, size: 64, align: 64, offset: 64)
!297 = !DIDerivedType(tag: DW_TAG_member, name: "length", scope: !288, file: !2, baseType: !9, size: 64, align: 64, offset: 64)
!298 = !DIDerivedType(tag: DW_TAG_member, name: "fmt", scope: !285, file: !2, baseType: !299, size: 128, align: 64, offset: 256, flags: DIFlagPrivate)
!299 = !DICompositeType(tag: DW_TAG_structure_type, name: "Option<&[core::fmt::rt::Placeholder]>", scope: !187, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !300, templateParams: !23, identifier: "3fe60f7eab2f17b42af444caa2d764cd")
!300 = !{!301}
!301 = !DICompositeType(tag: DW_TAG_variant_part, scope: !299, file: !2, size: 128, align: 64, elements: !302, templateParams: !23, identifier: "73ab82db4192389265b715d9d00b385d", discriminator: !339)
!302 = !{!303, !335}
!303 = !DIDerivedType(tag: DW_TAG_member, name: "None", scope: !301, file: !2, baseType: !304, size: 128, align: 64, extraData: i128 0)
!304 = !DICompositeType(tag: DW_TAG_structure_type, name: "None", scope: !299, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !23, templateParams: !305, identifier: "26dab956bba1e50630c5bbf73228ba15")
!305 = !{!306}
!306 = !DITemplateTypeParameter(name: "T", type: !307)
!307 = !DICompositeType(tag: DW_TAG_structure_type, name: "&[core::fmt::rt::Placeholder]", file: !2, size: 128, align: 64, elements: !308, templateParams: !23, identifier: "93fcd380cc9967a2d145116e65235aa7")
!308 = !{!309, !334}
!309 = !DIDerivedType(tag: DW_TAG_member, name: "data_ptr", scope: !307, file: !2, baseType: !310, size: 64, align: 64)
!310 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !311, size: 64, align: 64, dwarfAddressSpace: 0)
!311 = !DICompositeType(tag: DW_TAG_structure_type, name: "Placeholder", scope: !41, file: !2, size: 448, align: 64, flags: DIFlagPublic, elements: !312, templateParams: !23, identifier: "ebac3d8140faa5e3ca974ea3ef933e33")
!312 = !{!313, !314, !315, !316, !317, !333}
!313 = !DIDerivedType(tag: DW_TAG_member, name: "position", scope: !311, file: !2, baseType: !9, size: 64, align: 64, offset: 256, flags: DIFlagPublic)
!314 = !DIDerivedType(tag: DW_TAG_member, name: "fill", scope: !311, file: !2, baseType: !184, size: 32, align: 32, offset: 320, flags: DIFlagPublic)
!315 = !DIDerivedType(tag: DW_TAG_member, name: "align", scope: !311, file: !2, baseType: !40, size: 8, align: 8, offset: 384, flags: DIFlagPublic)
!316 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !311, file: !2, baseType: !182, size: 32, align: 32, offset: 352, flags: DIFlagPublic)
!317 = !DIDerivedType(tag: DW_TAG_member, name: "precision", scope: !311, file: !2, baseType: !318, size: 128, align: 64, flags: DIFlagPublic)
!318 = !DICompositeType(tag: DW_TAG_structure_type, name: "Count", scope: !41, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !319, templateParams: !23, identifier: "983781e1a5dc75df71c47a71bcff489")
!319 = !{!320}
!320 = !DICompositeType(tag: DW_TAG_variant_part, scope: !318, file: !2, size: 128, align: 64, elements: !321, templateParams: !23, identifier: "57f2bdf043ade4518e885bc7c207ba66", discriminator: !332)
!321 = !{!322, !326, !330}
!322 = !DIDerivedType(tag: DW_TAG_member, name: "Is", scope: !320, file: !2, baseType: !323, size: 128, align: 64, extraData: i128 0)
!323 = !DICompositeType(tag: DW_TAG_structure_type, name: "Is", scope: !318, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !324, templateParams: !23, identifier: "4f824ad79b9a8070c5f5563ea88e718f")
!324 = !{!325}
!325 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !323, file: !2, baseType: !9, size: 64, align: 64, offset: 64, flags: DIFlagPublic)
!326 = !DIDerivedType(tag: DW_TAG_member, name: "Param", scope: !320, file: !2, baseType: !327, size: 128, align: 64, extraData: i128 1)
!327 = !DICompositeType(tag: DW_TAG_structure_type, name: "Param", scope: !318, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !328, templateParams: !23, identifier: "aaaed82aa56f22c6b1ff8d5362c90e47")
!328 = !{!329}
!329 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !327, file: !2, baseType: !9, size: 64, align: 64, offset: 64, flags: DIFlagPublic)
!330 = !DIDerivedType(tag: DW_TAG_member, name: "Implied", scope: !320, file: !2, baseType: !331, size: 128, align: 64, extraData: i128 2)
!331 = !DICompositeType(tag: DW_TAG_structure_type, name: "Implied", scope: !318, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !23, identifier: "f5029ba09527ad05822ace6acbe3edaf")
!332 = !DIDerivedType(tag: DW_TAG_member, scope: !318, file: !2, baseType: !214, size: 64, align: 64, flags: DIFlagArtificial)
!333 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !311, file: !2, baseType: !318, size: 128, align: 64, offset: 128, flags: DIFlagPublic)
!334 = !DIDerivedType(tag: DW_TAG_member, name: "length", scope: !307, file: !2, baseType: !9, size: 64, align: 64, offset: 64)
!335 = !DIDerivedType(tag: DW_TAG_member, name: "Some", scope: !301, file: !2, baseType: !336, size: 128, align: 64)
!336 = !DICompositeType(tag: DW_TAG_structure_type, name: "Some", scope: !299, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !337, templateParams: !305, identifier: "fa3e94dc5bdef138c78fab9a266c6b1d")
!337 = !{!338}
!338 = !DIDerivedType(tag: DW_TAG_member, name: "__0", scope: !336, file: !2, baseType: !307, size: 128, align: 64, flags: DIFlagPublic)
!339 = !DIDerivedType(tag: DW_TAG_member, scope: !299, file: !2, baseType: !214, size: 64, align: 64, flags: DIFlagArtificial)
!340 = !DIDerivedType(tag: DW_TAG_member, name: "args", scope: !285, file: !2, baseType: !341, size: 128, align: 64, offset: 128, flags: DIFlagPrivate)
!341 = !DICompositeType(tag: DW_TAG_structure_type, name: "&[core::fmt::rt::Argument]", file: !2, size: 128, align: 64, elements: !342, templateParams: !23, identifier: "954ea9bd895c06daa45e0a629c5ad3e9")
!342 = !{!343, !345}
!343 = !DIDerivedType(tag: DW_TAG_member, name: "data_ptr", scope: !341, file: !2, baseType: !344, size: 64, align: 64)
!344 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !138, size: 64, align: 64, dwarfAddressSpace: 0)
!345 = !DIDerivedType(tag: DW_TAG_member, name: "length", scope: !341, file: !2, baseType: !9, size: 64, align: 64, offset: 64)
!346 = !DISubroutineType(types: !347)
!347 = !{!285, !348, !352}
!348 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&[&str; 2]", baseType: !349, size: 64, align: 64, dwarfAddressSpace: 0)
!349 = !DICompositeType(tag: DW_TAG_array_type, baseType: !292, size: 256, align: 64, elements: !350)
!350 = !{!351}
!351 = !DISubrange(count: 2, lowerBound: 0)
!352 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&[core::fmt::rt::Argument; 1]", baseType: !353, size: 64, align: 64, dwarfAddressSpace: 0)
!353 = !DICompositeType(tag: DW_TAG_array_type, baseType: !138, size: 128, align: 64, elements: !354)
!354 = !{!355}
!355 = !DISubrange(count: 1, lowerBound: 0)
!356 = !DISubprogram(name: "new_v1<2, 1>", linkageName: "_ZN4core3fmt9Arguments6new_v117h7d764aeb42f66c7fE", scope: !285, file: !284, line: 599, type: !346, scopeLine: 599, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit, templateParams: !23)
!357 = !{!358, !359}
!358 = !DILocalVariable(name: "pieces", arg: 1, scope: !283, file: !284, line: 600, type: !348)
!359 = !DILocalVariable(name: "args", arg: 2, scope: !283, file: !284, line: 601, type: !352)
!360 = !DILocation(line: 600, column: 9, scope: !283)
!361 = !DILocation(line: 601, column: 9, scope: !283)
!362 = !DILocation(line: 604, column: 9, scope: !283)
!363 = !DILocation(line: 605, column: 6, scope: !283)
!364 = distinct !DISubprogram(name: "call_once<std::rt::lang_start::{closure_env#0}<()>, ()>", linkageName: "_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h90313431f418f405E", scope: !366, file: !365, line: 250, type: !369, scopeLine: 250, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !375, retainedNodes: !372)
!365 = !DIFile(filename: "/rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688/library/core/src/ops/function.rs", directory: "", checksumkind: CSK_MD5, checksum: "27f40bbdeb6cc525c0d0d7cf434d92c4")
!366 = !DINamespace(name: "FnOnce", scope: !367)
!367 = !DINamespace(name: "function", scope: !368)
!368 = !DINamespace(name: "ops", scope: !34)
!369 = !DISubroutineType(types: !370)
!370 = !{!73, !371}
!371 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "*mut std::rt::lang_start::{closure_env#0}<()>", baseType: !14, size: 64, align: 64, dwarfAddressSpace: 0)
!372 = !{!373, !374}
!373 = !DILocalVariable(arg: 1, scope: !364, file: !365, line: 250, type: !371)
!374 = !DILocalVariable(arg: 2, scope: !364, file: !365, line: 250, type: !7)
!375 = !{!376, !377}
!376 = !DITemplateTypeParameter(name: "Self", type: !14)
!377 = !DITemplateTypeParameter(name: "Args", type: !7)
!378 = !DILocation(line: 250, column: 5, scope: !364)
!379 = distinct !DISubprogram(name: "call_once<std::rt::lang_start::{closure_env#0}<()>, ()>", linkageName: "_ZN4core3ops8function6FnOnce9call_once17h0b121461d8910734E", scope: !366, file: !365, line: 250, type: !380, scopeLine: 250, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !375, retainedNodes: !382)
!380 = !DISubroutineType(types: !381)
!381 = !{!73, !14}
!382 = !{!383, !384}
!383 = !DILocalVariable(arg: 1, scope: !379, file: !365, line: 250, type: !14)
!384 = !DILocalVariable(arg: 2, scope: !379, file: !365, line: 250, type: !7)
!385 = !DILocation(line: 250, column: 5, scope: !379)
!386 = distinct !DISubprogram(name: "call_once<fn(), ()>", linkageName: "_ZN4core3ops8function6FnOnce9call_once17hb6956567cff0305aE", scope: !366, file: !365, line: 250, type: !113, scopeLine: 250, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !390, retainedNodes: !387)
!387 = !{!388, !389}
!388 = !DILocalVariable(arg: 1, scope: !386, file: !365, line: 250, type: !20)
!389 = !DILocalVariable(arg: 2, scope: !386, file: !365, line: 250, type: !7)
!390 = !{!391, !377}
!391 = !DITemplateTypeParameter(name: "Self", type: !20)
!392 = !DILocation(line: 250, column: 5, scope: !386)
!393 = distinct !DISubprogram(name: "drop_in_place<std::rt::lang_start::{closure_env#0}<()>>", linkageName: "_ZN4core3ptr85drop_in_place$LT$std..rt..lang_start$LT$$LP$$RP$$GT$..$u7b$$u7b$closure$u7d$$u7d$$GT$17h60c9aa0d2f0851d5E", scope: !151, file: !394, line: 523, type: !395, scopeLine: 523, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !399, retainedNodes: !397)
!394 = !DIFile(filename: "/rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688/library/core/src/ptr/mod.rs", directory: "", checksumkind: CSK_MD5, checksum: "5f0c83af0bf11bb6e08bd85f47d89b0b")
!395 = !DISubroutineType(types: !396)
!396 = !{null, !371}
!397 = !{!398}
!398 = !DILocalVariable(arg: 1, scope: !393, file: !394, line: 523, type: !371)
!399 = !{!400}
!400 = !DITemplateTypeParameter(name: "T", type: !14)
!401 = !DILocation(line: 523, column: 1, scope: !393)
!402 = distinct !DISubprogram(name: "black_box<u64>", linkageName: "_ZN4core4hint9black_box17h1d4404d5b13d5cedE", scope: !126, file: !125, line: 474, type: !403, scopeLine: 474, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !242, retainedNodes: !405)
!403 = !DISubroutineType(types: !404)
!404 = !{!214, !214}
!405 = !{!406}
!406 = !DILocalVariable(name: "dummy", arg: 1, scope: !402, file: !125, line: 474, type: !214)
!407 = !DILocation(line: 474, column: 27, scope: !402)
!408 = !DILocation(line: 475, column: 5, scope: !402)
!409 = !DILocation(line: 476, column: 2, scope: !402)
!410 = distinct !DISubprogram(name: "report", linkageName: "_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17h4a178751daf42e09E", scope: !411, file: !82, line: 2423, type: !412, scopeLine: 2423, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !23, retainedNodes: !414)
!411 = !DINamespace(name: "{impl#57}", scope: !84)
!412 = !DISubroutineType(types: !413)
!413 = !{!83, !7}
!414 = !{!415}
!415 = !DILocalVariable(arg: 1, scope: !410, file: !82, line: 2423, type: !7)
!416 = !DILocation(line: 2423, column: 15, scope: !410)
!417 = !DILocation(line: 2425, column: 6, scope: !410)
!418 = distinct !DISubprogram(name: "authorize", linkageName: "_ZN14dominance_demo9authorize17h6e1015dd745dd6e2E", scope: !420, file: !419, line: 6, type: !421, scopeLine: 6, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !23, retainedNodes: !429)
!419 = !DIFile(filename: "dominance_demo.rs", directory: "/private/tmp/claude-501/-Users-sanjib-codes-apace-lab-lima-repositories/4bc88783-f66f-4021-9d50-0df96e2f0ba6/scratchpad", checksumkind: CSK_MD5, checksum: "153867eed95d8866a4d3234a00557bd7")
!420 = !DINamespace(name: "dominance_demo", scope: null)
!421 = !DISubroutineType(types: !422)
!422 = !{!423, !424}
!423 = !DIBasicType(name: "bool", size: 8, encoding: DW_ATE_boolean)
!424 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "&dominance_demo::Resource", baseType: !425, size: 64, align: 64, dwarfAddressSpace: 0)
!425 = !DICompositeType(tag: DW_TAG_structure_type, name: "Resource", scope: !420, file: !2, size: 128, align: 64, flags: DIFlagPublic, elements: !426, templateParams: !23, identifier: "7deb583bfbe57f8b93782909f65483f8")
!426 = !{!427, !428}
!427 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !425, file: !2, baseType: !214, size: 64, align: 64, flags: DIFlagPublic)
!428 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !425, file: !2, baseType: !214, size: 64, align: 64, offset: 64, flags: DIFlagPublic)
!429 = !{!430}
!430 = !DILocalVariable(name: "r", arg: 1, scope: !418, file: !419, line: 6, type: !424)
!431 = !DILocation(line: 6, column: 18, scope: !418)
!432 = !DILocation(line: 6, column: 63, scope: !418)
!433 = !DILocation(line: 6, column: 42, scope: !418)
!434 = !DILocation(line: 6, column: 75, scope: !418)
!435 = distinct !DISubprogram(name: "db_read", linkageName: "_ZN14dominance_demo7db_read17he1aaae39845a1444E", scope: !420, file: !419, line: 9, type: !436, scopeLine: 9, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !23, retainedNodes: !438)
!436 = !DISubroutineType(types: !437)
!437 = !{!214, !424}
!438 = !{!439}
!439 = !DILocalVariable(name: "r", arg: 1, scope: !435, file: !419, line: 9, type: !424)
!440 = !DILocation(line: 9, column: 16, scope: !435)
!441 = !DILocation(line: 9, column: 60, scope: !435)
!442 = !DILocation(line: 9, column: 39, scope: !435)
!443 = !DILocation(line: 9, column: 69, scope: !435)
!444 = distinct !DISubprogram(name: "guarded", linkageName: "_ZN14dominance_demo7guarded17h3c30c3bfdea5169fE", scope: !420, file: !419, line: 13, type: !436, scopeLine: 13, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !23, retainedNodes: !445)
!445 = !{!446}
!446 = !DILocalVariable(name: "r", arg: 1, scope: !444, file: !419, line: 13, type: !424)
!447 = !DILocation(line: 13, column: 16, scope: !444)
!448 = !DILocation(line: 14, column: 8, scope: !444)
!449 = !DILocation(line: 14, column: 43, scope: !444)
!450 = !DILocation(line: 14, column: 5, scope: !444)
!451 = !DILocation(line: 14, column: 23, scope: !444)
!452 = !DILocation(line: 15, column: 2, scope: !444)
!453 = distinct !DISubprogram(name: "unguarded", linkageName: "_ZN14dominance_demo9unguarded17h55eba95306b1291aE", scope: !420, file: !419, line: 19, type: !436, scopeLine: 19, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !23, retainedNodes: !454)
!454 = !{!455}
!455 = !DILocalVariable(name: "r", arg: 1, scope: !453, file: !419, line: 19, type: !424)
!456 = !DILocation(line: 19, column: 18, scope: !453)
!457 = !DILocation(line: 20, column: 5, scope: !453)
!458 = !DILocation(line: 21, column: 2, scope: !453)
!459 = distinct !DISubprogram(name: "wrong_resource", linkageName: "_ZN14dominance_demo14wrong_resource17h48098f4b325a2289E", scope: !420, file: !419, line: 25, type: !460, scopeLine: 25, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !23, retainedNodes: !462)
!460 = !DISubroutineType(types: !461)
!461 = !{!214, !424, !424}
!462 = !{!463, !464}
!463 = !DILocalVariable(name: "auth_res", arg: 1, scope: !459, file: !419, line: 25, type: !424)
!464 = !DILocalVariable(name: "data_res", arg: 2, scope: !459, file: !419, line: 25, type: !424)
!465 = !DILocation(line: 25, column: 23, scope: !459)
!466 = !DILocation(line: 25, column: 44, scope: !459)
!467 = !DILocation(line: 26, column: 8, scope: !459)
!468 = !DILocation(line: 26, column: 57, scope: !459)
!469 = !DILocation(line: 26, column: 5, scope: !459)
!470 = !DILocation(line: 26, column: 30, scope: !459)
!471 = !DILocation(line: 27, column: 2, scope: !459)
!472 = distinct !DISubprogram(name: "main", linkageName: "_ZN14dominance_demo4main17ha21bbafcd7919246E", scope: !420, file: !419, line: 29, type: !21, scopeLine: 29, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagMainSubprogram, unit: !29, templateParams: !23, retainedNodes: !473)
!473 = !{!474, !476, !478, !480, !482}
!474 = !DILocalVariable(name: "a", scope: !475, file: !419, line: 30, type: !425, align: 8)
!475 = distinct !DILexicalBlock(scope: !472, file: !419, line: 30, column: 5)
!476 = !DILocalVariable(name: "b", scope: !477, file: !419, line: 31, type: !425, align: 8)
!477 = distinct !DILexicalBlock(scope: !475, file: !419, line: 31, column: 5)
!478 = !DILocalVariable(name: "c", scope: !479, file: !419, line: 32, type: !425, align: 8)
!479 = distinct !DILexicalBlock(scope: !477, file: !419, line: 32, column: 5)
!480 = !DILocalVariable(name: "d", scope: !481, file: !419, line: 33, type: !425, align: 8)
!481 = distinct !DILexicalBlock(scope: !479, file: !419, line: 33, column: 5)
!482 = !DILocalVariable(name: "acc", scope: !483, file: !419, line: 34, type: !214, align: 8)
!483 = distinct !DILexicalBlock(scope: !481, file: !419, line: 34, column: 5)
!484 = !DILocation(line: 30, column: 9, scope: !475)
!485 = !DILocation(line: 31, column: 9, scope: !477)
!486 = !DILocation(line: 32, column: 9, scope: !479)
!487 = !DILocation(line: 33, column: 9, scope: !481)
!488 = !DILocation(line: 34, column: 9, scope: !483)
!489 = !DILocation(line: 30, column: 13, scope: !472)
!490 = !DILocation(line: 31, column: 13, scope: !475)
!491 = !DILocation(line: 32, column: 13, scope: !477)
!492 = !DILocation(line: 33, column: 13, scope: !479)
!493 = !DILocation(line: 34, column: 19, scope: !481)
!494 = !DILocation(line: 35, column: 11, scope: !483)
!495 = !DILocation(line: 35, column: 28, scope: !483)
!496 = !DILocalVariable(name: "self", arg: 1, scope: !497, file: !498, line: 1936, type: !214)
!497 = distinct !DISubprogram(name: "wrapping_add", linkageName: "_ZN4core3num21_$LT$impl$u20$u64$GT$12wrapping_add17h311b4d560ab8541fE", scope: !499, file: !498, line: 1936, type: !501, scopeLine: 1936, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !29, templateParams: !23, retainedNodes: !503)
!498 = !DIFile(filename: "/rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688/library/core/src/num/uint_macros.rs", directory: "", checksumkind: CSK_MD5, checksum: "40608eb764697ec115542843165a02b8")
!499 = !DINamespace(name: "{impl#9}", scope: !500)
!500 = !DINamespace(name: "num", scope: !34)
!501 = !DISubroutineType(types: !502)
!502 = !{!214, !214, !214}
!503 = !{!496, !504}
!504 = !DILocalVariable(name: "rhs", arg: 2, scope: !497, file: !498, line: 1936, type: !214)
!505 = !DILocation(line: 1936, column: 35, scope: !497, inlinedAt: !506)
!506 = distinct !DILocation(line: 35, column: 11, scope: !483)
!507 = !DILocation(line: 1936, column: 41, scope: !497, inlinedAt: !506)
!508 = !DILocation(line: 1937, column: 13, scope: !497, inlinedAt: !506)
!509 = !DILocation(line: 35, column: 5, scope: !483)
!510 = !DILocation(line: 36, column: 11, scope: !483)
!511 = !DILocation(line: 36, column: 28, scope: !483)
!512 = !DILocation(line: 1936, column: 35, scope: !497, inlinedAt: !513)
!513 = distinct !DILocation(line: 36, column: 11, scope: !483)
!514 = !DILocation(line: 1936, column: 41, scope: !497, inlinedAt: !513)
!515 = !DILocation(line: 1937, column: 13, scope: !497, inlinedAt: !513)
!516 = !DILocation(line: 36, column: 5, scope: !483)
!517 = !DILocation(line: 37, column: 11, scope: !483)
!518 = !DILocation(line: 37, column: 28, scope: !483)
!519 = !DILocation(line: 1936, column: 35, scope: !497, inlinedAt: !520)
!520 = distinct !DILocation(line: 37, column: 11, scope: !483)
!521 = !DILocation(line: 1936, column: 41, scope: !497, inlinedAt: !520)
!522 = !DILocation(line: 1937, column: 13, scope: !497, inlinedAt: !520)
!523 = !DILocation(line: 37, column: 5, scope: !483)
!524 = !DILocation(line: 38, column: 41, scope: !483)
!525 = !DILocation(line: 38, column: 20, scope: !483)
!526 = !DILocation(line: 38, column: 5, scope: !483)
!527 = !DILocation(line: 39, column: 2, scope: !472)
