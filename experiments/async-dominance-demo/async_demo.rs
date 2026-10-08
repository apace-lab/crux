// Async analog of typegate-demo: a check `.await` then a read `.await`, so the await
// between them puts the read in a post-resume block the check does not dominate in the
// raw CFG. Coroutine-aware dominance should recognize that `authorize` still precedes
// `db_read` and clear `guarded`, while `unguarded` stays a candidate.

use std::future::Future;
use std::pin::pin;
use std::task::{Context, Poll, RawWaker, RawWakerVTable, Waker};

pub struct Resource {
    pub id: u64,
    pub data: u64,
}

#[inline(never)]
pub async fn authorize(r: &Resource) -> bool {
    std::hint::black_box(r).id != 0
}

#[inline(never)]
pub async fn db_read(r: &Resource) -> u64 {
    std::hint::black_box(r).data
}

// The check `.await` dominates the read `.await` in source order, but an await sits
// between them (so the read's block is a coroutine resume block).
#[inline(never)]
pub async fn guarded(r: &Resource) -> u64 {
    if authorize(r).await {
        db_read(r).await
    } else {
        0
    }
}

#[inline(never)]
pub async fn unguarded(r: &Resource) -> u64 {
    db_read(r).await
}

fn noop(_: *const ()) {}
fn clone_w(_: *const ()) -> RawWaker {
    RawWaker::new(std::ptr::null(), &VT)
}
static VT: RawWakerVTable = RawWakerVTable::new(clone_w, noop, noop, noop);

fn block_on<F: Future>(f: F) -> F::Output {
    let mut f = pin!(f);
    let w = unsafe { Waker::from_raw(RawWaker::new(std::ptr::null(), &VT)) };
    let mut cx = Context::from_waker(&w);
    loop {
        if let Poll::Ready(v) = f.as_mut().poll(&mut cx) {
            return v;
        }
    }
}

fn main() {
    let a = Resource { id: std::hint::black_box(1), data: std::hint::black_box(10) };
    let b = Resource { id: std::hint::black_box(2), data: std::hint::black_box(20) };
    println!("{}", block_on(guarded(std::hint::black_box(&a))));
    println!("{}", block_on(unguarded(std::hint::black_box(&b))));
}
