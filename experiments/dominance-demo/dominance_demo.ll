; ModuleID = 'dominance_demo.c1c20ed8f98c8587-cgu.0'
source_filename = "dominance_demo.c1c20ed8f98c8587-cgu.0"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx11.0.0"

%"core::fmt::rt::Argument<'_>" = type { %"core::fmt::rt::ArgumentType<'_>" }
%"core::fmt::rt::ArgumentType<'_>" = type { ptr, [1 x i64] }

@vtable.0 = private unnamed_addr constant <{ [24 x i8], ptr, ptr, ptr }> <{ [24 x i8] c"\00\00\00\00\00\00\00\00\08\00\00\00\00\00\00\00\08\00\00\00\00\00\00\00", ptr @"_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h90313431f418f405E", ptr @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h090a705701f68211E", ptr @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h090a705701f68211E" }>, align 8
@0 = private unnamed_addr constant <{ [8 x i8], [8 x i8] }> <{ [8 x i8] zeroinitializer, [8 x i8] undef }>, align 8
@alloc_49a1e817e911805af64bbc7efb390101 = private unnamed_addr constant <{ [1 x i8] }> <{ [1 x i8] c"\0A" }>, align 1
@alloc_9771be2481f51be410bd2ac520d18601 = private unnamed_addr constant <{ ptr, [8 x i8], ptr, [8 x i8] }> <{ ptr inttoptr (i64 1 to ptr), [8 x i8] zeroinitializer, ptr @alloc_49a1e817e911805af64bbc7efb390101, [8 x i8] c"\01\00\00\00\00\00\00\00" }>, align 8

; std::rt::lang_start
; Function Attrs: uwtable
define hidden i64 @_ZN3std2rt10lang_start17h44ba09a7e55f8370E(ptr %main, i64 %argc, ptr %argv, i8 %sigpipe) unnamed_addr #0 {
start:
  %_8 = alloca [8 x i8], align 8
  %_5 = alloca [8 x i8], align 8
  store ptr %main, ptr %_8, align 8
; call std::rt::lang_start_internal
  %0 = call i64 @_ZN3std2rt19lang_start_internal17h5f91760815528aa2E(ptr align 1 %_8, ptr align 8 @vtable.0, i64 %argc, ptr %argv, i8 %sigpipe)
  store i64 %0, ptr %_5, align 8
  %v = load i64, ptr %_5, align 8
  ret i64 %v
}

; std::rt::lang_start::{{closure}}
; Function Attrs: inlinehint uwtable
define internal i32 @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h090a705701f68211E"(ptr align 8 %_1) unnamed_addr #1 {
start:
  %_4 = load ptr, ptr %_1, align 8
; call std::sys::backtrace::__rust_begin_short_backtrace
  call void @_ZN3std3sys9backtrace28__rust_begin_short_backtrace17h4a4ac80fb1e07d16E(ptr %_4)
; call <() as std::process::Termination>::report
  %self = call i8 @"_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17h4a178751daf42e09E"()
  %_0 = zext i8 %self to i32
  ret i32 %_0
}

; std::sys::backtrace::__rust_begin_short_backtrace
; Function Attrs: noinline uwtable
define internal void @_ZN3std3sys9backtrace28__rust_begin_short_backtrace17h4a4ac80fb1e07d16E(ptr %f) unnamed_addr #2 {
start:
; call core::ops::function::FnOnce::call_once
  call void @_ZN4core3ops8function6FnOnce9call_once17hb6956567cff0305aE(ptr %f)
  call void asm sideeffect "", "~{memory}"(), !srcloc !3
  ret void
}

; core::fmt::rt::Argument::new_display
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3fmt2rt8Argument11new_display17h886ee6e4258d90c7E(ptr sret([16 x i8]) align 8 %_0, ptr align 8 %x) unnamed_addr #1 {
start:
; call core::fmt::rt::Argument::new
  call void @_ZN4core3fmt2rt8Argument3new17hcad4fb8a87d49b5cE(ptr sret([16 x i8]) align 8 %_0, ptr align 8 %x, ptr @"_ZN4core3fmt3num3imp52_$LT$impl$u20$core..fmt..Display$u20$for$u20$u64$GT$3fmt17hf38c5fc9304f84d8E")
  ret void
}

; core::fmt::rt::Argument::new
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3fmt2rt8Argument3new17hcad4fb8a87d49b5cE(ptr sret([16 x i8]) align 8 %_0, ptr align 8 %x, ptr %f) unnamed_addr #1 {
start:
  %_3 = alloca [16 x i8], align 8
  store ptr %x, ptr %_3, align 8
  %0 = getelementptr inbounds i8, ptr %_3, i64 8
  store ptr %f, ptr %0, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_0, ptr align 8 %_3, i64 16, i1 false)
  ret void
}

; core::fmt::Arguments::new_v1
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3fmt9Arguments6new_v117h7d764aeb42f66c7fE(ptr sret([48 x i8]) align 8 %_0, ptr align 8 %pieces, ptr align 8 %args) unnamed_addr #1 {
start:
  store ptr %pieces, ptr %_0, align 8
  %0 = getelementptr inbounds i8, ptr %_0, i64 8
  store i64 2, ptr %0, align 8
  %1 = load ptr, ptr @0, align 8
  %2 = load i64, ptr getelementptr inbounds (i8, ptr @0, i64 8), align 8
  %3 = getelementptr inbounds i8, ptr %_0, i64 32
  store ptr %1, ptr %3, align 8
  %4 = getelementptr inbounds i8, ptr %3, i64 8
  store i64 %2, ptr %4, align 8
  %5 = getelementptr inbounds i8, ptr %_0, i64 16
  store ptr %args, ptr %5, align 8
  %6 = getelementptr inbounds i8, ptr %5, i64 8
  store i64 1, ptr %6, align 8
  ret void
}

; core::ops::function::FnOnce::call_once{{vtable.shim}}
; Function Attrs: inlinehint uwtable
define internal i32 @"_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h90313431f418f405E"(ptr %_1) unnamed_addr #1 {
start:
  %_2 = alloca [0 x i8], align 1
  %0 = load ptr, ptr %_1, align 8
; call core::ops::function::FnOnce::call_once
  %_0 = call i32 @_ZN4core3ops8function6FnOnce9call_once17h0b121461d8910734E(ptr %0)
  ret i32 %_0
}

; core::ops::function::FnOnce::call_once
; Function Attrs: inlinehint uwtable
define internal i32 @_ZN4core3ops8function6FnOnce9call_once17h0b121461d8910734E(ptr %0) unnamed_addr #1 personality ptr @rust_eh_personality {
start:
  %1 = alloca [16 x i8], align 8
  %_2 = alloca [0 x i8], align 1
  %_1 = alloca [8 x i8], align 8
  store ptr %0, ptr %_1, align 8
; invoke std::rt::lang_start::{{closure}}
  %_0 = invoke i32 @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h090a705701f68211E"(ptr align 8 %_1)
          to label %bb1 unwind label %cleanup

bb3:                                              ; preds = %cleanup
  %2 = load ptr, ptr %1, align 8
  %3 = getelementptr inbounds i8, ptr %1, i64 8
  %4 = load i32, ptr %3, align 8
  %5 = insertvalue { ptr, i32 } poison, ptr %2, 0
  %6 = insertvalue { ptr, i32 } %5, i32 %4, 1
  resume { ptr, i32 } %6

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
  ret i32 %_0
}

; core::ops::function::FnOnce::call_once
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3ops8function6FnOnce9call_once17hb6956567cff0305aE(ptr %_1) unnamed_addr #1 {
start:
  %_2 = alloca [0 x i8], align 1
  call void %_1()
  ret void
}

; core::ptr::drop_in_place<std::rt::lang_start<()>::{{closure}}>
; Function Attrs: inlinehint uwtable
define internal void @"_ZN4core3ptr85drop_in_place$LT$std..rt..lang_start$LT$$LP$$RP$$GT$..$u7b$$u7b$closure$u7d$$u7d$$GT$17h60c9aa0d2f0851d5E"(ptr align 8 %_1) unnamed_addr #1 {
start:
  ret void
}

; core::hint::black_box
; Function Attrs: inlinehint uwtable
define internal i64 @_ZN4core4hint9black_box17h1d4404d5b13d5cedE(i64 %dummy) unnamed_addr #1 {
start:
  %0 = alloca [8 x i8], align 8
  store i64 %dummy, ptr %0, align 8
  call void asm sideeffect "", "r,~{memory}"(ptr %0), !srcloc !3
  %_0 = load i64, ptr %0, align 8
  ret i64 %_0
}

; <() as std::process::Termination>::report
; Function Attrs: inlinehint uwtable
define internal i8 @"_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17h4a178751daf42e09E"() unnamed_addr #1 {
start:
  ret i8 0
}

; dominance_demo::authorize
; Function Attrs: noinline uwtable
define internal zeroext i1 @_ZN14dominance_demo9authorize17h6e1015dd745dd6e2E(ptr align 8 %r) unnamed_addr #2 {
start:
  %_3 = load i64, ptr %r, align 8
; call core::hint::black_box
  %_2 = call i64 @_ZN4core4hint9black_box17h1d4404d5b13d5cedE(i64 %_3)
  %_0 = icmp ne i64 %_2, 0
  ret i1 %_0
}

; dominance_demo::db_read
; Function Attrs: noinline uwtable
define internal i64 @_ZN14dominance_demo7db_read17he1aaae39845a1444E(ptr align 8 %r) unnamed_addr #2 {
start:
  %0 = getelementptr inbounds i8, ptr %r, i64 8
  %_2 = load i64, ptr %0, align 8
; call core::hint::black_box
  %_0 = call i64 @_ZN4core4hint9black_box17h1d4404d5b13d5cedE(i64 %_2)
  ret i64 %_0
}

; dominance_demo::guarded
; Function Attrs: noinline uwtable
define internal i64 @_ZN14dominance_demo7guarded17h3c30c3bfdea5169fE(ptr align 8 %r) unnamed_addr #2 {
start:
  %_0 = alloca [8 x i8], align 8
; call dominance_demo::authorize
  %_2 = call zeroext i1 @_ZN14dominance_demo9authorize17h6e1015dd745dd6e2E(ptr align 8 %r)
  br i1 %_2, label %bb2, label %bb3

bb3:                                              ; preds = %start
  store i64 0, ptr %_0, align 8
  br label %bb4

bb2:                                              ; preds = %start
; call dominance_demo::db_read
  %0 = call i64 @_ZN14dominance_demo7db_read17he1aaae39845a1444E(ptr align 8 %r)
  store i64 %0, ptr %_0, align 8
  br label %bb4

bb4:                                              ; preds = %bb2, %bb3
  %1 = load i64, ptr %_0, align 8
  ret i64 %1
}

; dominance_demo::unguarded
; Function Attrs: noinline uwtable
define internal i64 @_ZN14dominance_demo9unguarded17h55eba95306b1291aE(ptr align 8 %r) unnamed_addr #2 {
start:
; call dominance_demo::db_read
  %_0 = call i64 @_ZN14dominance_demo7db_read17he1aaae39845a1444E(ptr align 8 %r)
  ret i64 %_0
}

; dominance_demo::wrong_resource
; Function Attrs: noinline uwtable
define internal i64 @_ZN14dominance_demo14wrong_resource17h48098f4b325a2289E(ptr align 8 %auth_res, ptr align 8 %data_res) unnamed_addr #2 {
start:
  %_0 = alloca [8 x i8], align 8
; call dominance_demo::authorize
  %_3 = call zeroext i1 @_ZN14dominance_demo9authorize17h6e1015dd745dd6e2E(ptr align 8 %auth_res)
  br i1 %_3, label %bb2, label %bb3

bb3:                                              ; preds = %start
  store i64 0, ptr %_0, align 8
  br label %bb4

bb2:                                              ; preds = %start
; call dominance_demo::db_read
  %0 = call i64 @_ZN14dominance_demo7db_read17he1aaae39845a1444E(ptr align 8 %data_res)
  store i64 %0, ptr %_0, align 8
  br label %bb4

bb4:                                              ; preds = %bb2, %bb3
  %1 = load i64, ptr %_0, align 8
  ret i64 %1
}

; dominance_demo::main
; Function Attrs: uwtable
define internal void @_ZN14dominance_demo4main17ha21bbafcd7919246E() unnamed_addr #0 {
start:
  %_26 = alloca [8 x i8], align 8
  %_24 = alloca [16 x i8], align 8
  %_23 = alloca [16 x i8], align 8
  %_20 = alloca [48 x i8], align 8
  %acc = alloca [8 x i8], align 8
  %d = alloca [16 x i8], align 8
  %c = alloca [16 x i8], align 8
  %b = alloca [16 x i8], align 8
  %a = alloca [16 x i8], align 8
  store i64 1, ptr %a, align 8
  %0 = getelementptr inbounds i8, ptr %a, i64 8
  store i64 100, ptr %0, align 8
  store i64 2, ptr %b, align 8
  %1 = getelementptr inbounds i8, ptr %b, i64 8
  store i64 200, ptr %1, align 8
  store i64 3, ptr %c, align 8
  %2 = getelementptr inbounds i8, ptr %c, i64 8
  store i64 300, ptr %2, align 8
  store i64 4, ptr %d, align 8
  %3 = getelementptr inbounds i8, ptr %d, i64 8
  store i64 400, ptr %3, align 8
  store i64 0, ptr %acc, align 8
  %_7 = load i64, ptr %acc, align 8
; call dominance_demo::guarded
  %_8 = call i64 @_ZN14dominance_demo7guarded17h3c30c3bfdea5169fE(ptr align 8 %a)
  %_0.i2 = add i64 %_7, %_8
  store i64 %_0.i2, ptr %acc, align 8
  %_11 = load i64, ptr %acc, align 8
; call dominance_demo::unguarded
  %_12 = call i64 @_ZN14dominance_demo9unguarded17h55eba95306b1291aE(ptr align 8 %b)
  %_0.i1 = add i64 %_11, %_12
  store i64 %_0.i1, ptr %acc, align 8
  %_15 = load i64, ptr %acc, align 8
; call dominance_demo::wrong_resource
  %_16 = call i64 @_ZN14dominance_demo14wrong_resource17h48098f4b325a2289E(ptr align 8 %c, ptr align 8 %d)
  %_0.i = add i64 %_15, %_16
  store i64 %_0.i, ptr %acc, align 8
  %_27 = load i64, ptr %acc, align 8
; call core::hint::black_box
  %4 = call i64 @_ZN4core4hint9black_box17h1d4404d5b13d5cedE(i64 %_27)
  store i64 %4, ptr %_26, align 8
; call core::fmt::rt::Argument::new_display
  call void @_ZN4core3fmt2rt8Argument11new_display17h886ee6e4258d90c7E(ptr sret([16 x i8]) align 8 %_24, ptr align 8 %_26)
  %5 = getelementptr inbounds %"core::fmt::rt::Argument<'_>", ptr %_23, i64 0
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %5, ptr align 8 %_24, i64 16, i1 false)
; call core::fmt::Arguments::new_v1
  call void @_ZN4core3fmt9Arguments6new_v117h7d764aeb42f66c7fE(ptr sret([48 x i8]) align 8 %_20, ptr align 8 @alloc_9771be2481f51be410bd2ac520d18601, ptr align 8 %_23)
; call std::io::stdio::_print
  call void @_ZN3std2io5stdio6_print17h91e586dc5ea11662E(ptr align 8 %_20)
  ret void
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

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 8, !"PIC Level", i32 2}
!1 = !{i32 7, !"PIE Level", i32 2}
!2 = !{!"rustc version 1.85.0 (4d91de4e4 2025-02-17)"}
!3 = !{i64 4365933041648296}
