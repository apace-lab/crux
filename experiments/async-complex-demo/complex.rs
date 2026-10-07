// Mirrors vaultwarden get_cipher's real shape: load (let-else), check (if-branch), then
// serve, each across its own `.await`. The serve must be recognized as dominated by the
// check despite the multiple await/resume points and the early-return branches.

use std::future::Future;
use std::pin::pin;
use std::task::{Context, Poll, RawWaker, RawWakerVTable, Waker};

pub struct Cipher { pub id: u64, pub data: u64 }

#[inline(never)]
pub async fn find(id: u64) -> Option<Cipher> {
    if std::hint::black_box(id) == 0 { None } else { Some(Cipher { id, data: 7 }) }
}

#[inline(never)]
pub async fn is_accessible(c: &Cipher) -> bool {
    std::hint::black_box(c).id != 0
}

#[inline(never)]
pub async fn to_json(c: &Cipher) -> u64 {
    std::hint::black_box(c).data
}

// SAFE: load -> check -> serve (get_cipher shape). Serve dominated by the check.
#[inline(never)]
pub async fn get_cipher(id: u64) -> u64 {
    let Some(c) = find(id).await else { return 0 };
    if !is_accessible(&c).await {
        return 0;
    }
    to_json(&c).await
}

// LEAK: load -> serve, no check (the CVE shape).
#[inline(never)]
pub async fn get_cipher_leak(id: u64) -> u64 {
    let Some(c) = find(id).await else { return 0 };
    to_json(&c).await
}

fn noop(_: *const ()) {}
fn clone_w(_: *const ()) -> RawWaker { RawWaker::new(std::ptr::null(), &VT) }
static VT: RawWakerVTable = RawWakerVTable::new(clone_w, noop, noop, noop);
fn block_on<F: Future>(f: F) -> F::Output {
    let mut f = pin!(f);
    let w = unsafe { Waker::from_raw(RawWaker::new(std::ptr::null(), &VT)) };
    let mut cx = Context::from_waker(&w);
    loop { if let Poll::Ready(v) = f.as_mut().poll(&mut cx) { return v; } }
}

fn main() {
    println!("{}", block_on(get_cipher(std::hint::black_box(1))));
    println!("{}", block_on(get_cipher_leak(std::hint::black_box(2))));
}
