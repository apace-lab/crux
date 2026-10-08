// A real-IR case for the debug-type gate: a single context struct holds two DIFFERENT
// resource types. The access-control check guards one (the Org), and the data read touches
// the other (the Cipher). Under opaque pointers both are reached by byte-offset GEPs from
// the same `ctx` base, so a type-blind points-to can merge them and wrongly treat the
// Org-check as covering the Cipher-read. The debug types tell Org and Cipher apart.
//
// This is the vaultwarden shape in miniature: an organization-level check standing in for a
// per-cipher check.

#[derive(Debug)]
pub struct Org {
    pub id: u64,
}

#[derive(Debug)]
pub struct Cipher {
    pub secret: u64,
}

pub struct Ctx {
    pub org: Org,
    pub cipher: Cipher,
}

#[inline(never)]
pub fn authorize(o: &Org) -> bool {
    std::hint::black_box(o).id != 0
}

#[inline(never)]
pub fn read_cipher(c: &Cipher) -> u64 {
    std::hint::black_box(c).secret
}

// The check on ctx.org dominates the read of ctx.cipher. Correct code would check the
// cipher's own collection; checking only the org is the gap.
#[inline(never)]
pub fn handler(ctx: &Ctx) -> u64 {
    if authorize(&ctx.org) {
        read_cipher(&ctx.cipher)
    } else {
        0
    }
}

fn main() {
    let ctx = Ctx {
        org: Org { id: std::hint::black_box(1) },
        cipher: Cipher { secret: std::hint::black_box(42) },
    };
    println!("{}", handler(std::hint::black_box(&ctx)));
}
