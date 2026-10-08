// Real-IR discrimination demo for the access-control dominance pass.
// `authorize` is a (cataloged) access-control check; `db_read` is a (cataloged) data access.
pub struct Resource { pub id: u64, pub data: u64 }

#[inline(never)]
pub fn authorize(r: &Resource) -> bool { std::hint::black_box(r.id) != 0 }

#[inline(never)]
pub fn db_read(r: &Resource) -> u64 { std::hint::black_box(r.data) }

// GUARDED: the check dominates the access and is bound to the same resource.
#[inline(never)]
pub fn guarded(r: &Resource) -> u64 {
    if authorize(r) { db_read(r) } else { 0 }
}

// UNGUARDED: the access has no access-control check on its path.
#[inline(never)]
pub fn unguarded(r: &Resource) -> u64 {
    db_read(r)
}

// WRONG RESOURCE: a check dominates the access, but it guards a different resource.
#[inline(never)]
pub fn wrong_resource(auth_res: &Resource, data_res: &Resource) -> u64 {
    if authorize(auth_res) { db_read(data_res) } else { 0 }
}

fn main() {
    let a = Resource { id: 1, data: 100 };
    let b = Resource { id: 2, data: 200 };
    let c = Resource { id: 3, data: 300 };
    let d = Resource { id: 4, data: 400 };
    let mut acc = 0u64;
    acc = acc.wrapping_add(guarded(&a));
    acc = acc.wrapping_add(unguarded(&b));
    acc = acc.wrapping_add(wrong_resource(&c, &d));
    println!("{}", std::hint::black_box(acc));
}
