module sui_playground::optionals {
    use std::option::{Self, Option};

    struct Something has copy, drop {
        a: Option<u64>,
        b: Option<u64>
    }

    public fun return_option(): (Option<u64>, Option<u64>, u64, Option<u8>, Option<u8>, u8) {
        (option::some(9777777), option::none(), 577777, option::some(254), option::none(), 13)
    }

    public fun test_bcs(): (Option<u64>, Something, Something, Something, Something) {
        (option::none(), Something { a: option::none(), b: option::none() }, Something { a: option::none(), b: option::some(254) }, Something { a: option::some(254), b: option::none() }, Something { a: option::some(254), b: option::some(254) })
    }
}

#[test_only]
module sui_playground::test {
    // use sui_playground::optionals;
    // use sui::bcs;
    // use std::debug;

    #[test]
    public fun test_it() {
        // let (option, structy) = optionals::test_bcs();
        // debug::print(&bcs::to_bytes(&option));
        // debug::print(&bcs::to_bytes(&structy));
    }
}