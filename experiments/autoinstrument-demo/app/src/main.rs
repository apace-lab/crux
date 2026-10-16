pub struct Resource {
    pub id: u64,
    pub data: u64,
}

// Cataloged as a data-access; the static stage flags its call site and the
// auto-instrumenter injects an crux_access! probe there (no hand placement).
#[inline(never)]
pub fn db_read(r: &Resource) -> u64 {
    std::hint::black_box(r).data
}

fn main() {
    let r = Resource { id: std::hint::black_box(1), data: std::hint::black_box(42) };
    let v = db_read(std::hint::black_box(&r));
    println!("{v}");
}
